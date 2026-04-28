from fastapi import FastAPI, Depends, HTTPException, Header, Body, UploadFile, File
from fastapi.responses import Response
from jose import JWTError, jwt
from database import dbQueries as db
from database import AttachmentMetadata

app = FastAPI()

SECRET_KEY = "your_secret_key" 
ALGORITHM = "HS256"

API_URL = "http://nginx-gateway/api"

def verify_jwt(authorization: str = Header(None)):
    if not authorization:
        raise HTTPException(status_code=403, detail="No authorization header provided")
    
    try:
        parts = authorization.split(" ", 1)
        if len(parts) != 2 or parts[0].lower() != 'bearer':
            raise HTTPException(status_code=401, detail="Invalid authentication scheme")
            
        token = parts[1]
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload 
        
    except JWTError:
        raise HTTPException(status_code=403, detail="Could not validate credentials")
    except Exception:
        raise HTTPException(status_code=403, detail="Invalid token format")

@app.get("/")
def health_check():
    return {"status": "success", "message": "Task Service is running"}

@app.get("/all")
def get_all(token_body: dict = Depends(verify_jwt)):
    if token_body.get("role") == "ADMIN":
        return db.get_all()
    
@app.get("/{task_id}/comments", dependencies=[Depends(verify_jwt)])
def get_comments(task_id:int):
    return db.get_comments(task_id)

@app.post("/{task_id}/comments")
def new_comment(task_id: int , token_body = Depends(verify_jwt), data: dict = Body()):
    db.add_comment(task_id, int(token_body.get("sub")), data)

@app.get("/{task_id}/assignees", dependencies=[Depends(verify_jwt)])
def get_assignee(task_id: int):
    return db.get_assignees(task_id)

@app.get("/my_tasks")
def get_my_tasks(token_body: dict = Depends(verify_jwt)):
    user_id = token_body.get("sub")
    return db.get_tasks_by_user_id(user_id)

@app.get("/{team_id}/tasks", dependencies=[Depends(verify_jwt)])
def get_teams_tasks(team_id: int):
    return db.get_tasks_by_team_id(team_id)

@app.patch("/{task_id}", dependencies=[Depends(verify_jwt)])
def upate_status(task_id: int, state: dict = Body()):
    db.update_state(task_id, state.get("state"))

@app.delete("/delete/{team_id}")
def delete_tasks(team_id: int):
    db.delete_tasks(team_id)

@app.post("/{team_id}/tasks")
def create_task(team_id: int, token:dict = Depends(verify_jwt),payload: dict = Body()):
    db.create_task(team_id, token.get("sub"), payload)

@app.get("/{task_id}/attachments", response_model=list[AttachmentMetadata])
def get_attachment_names(task_id: int):
    return db.get_attachment_names(task_id)

@app.post("/{task_id}/attachments", status_code=201)
async def upload_attachment(task_id: int, file: UploadFile = File(...)):
    file_content = await file.read()
    db.add_attachment(task_id, file_content, file)

@app.get("/attachments/{attachment_id}/download")
def download_attachment(attachment_id: int):
    attachment = db.get_attachment_by_id(attachment_id)
    return Response(
        content = attachment.file_data,
        media_type = attachment.content_type,
        headers={
            "Content-Disposition":f'attachment; filename={attachment.filename}'
        }
    )

@app.delete("/attachments/{attachment_id}", status_code=204)
def delete_attachment(attachment_id: int):
    db.delete_attachment(attachment_id)

# --- NOTIFICATION ENDPOINTS ---

@app.get("/notifications")
def get_notifications(token_body: dict = Depends(verify_jwt)):
    user_id = token_body.get("sub")
    return db.get_my_notifications(user_id)

@app.put("/notifications/{notif_id}/read")
def read_notification(notif_id: int, token_body: dict = Depends(verify_jwt)):
    user_id = token_body.get("sub")
    success = db.mark_notification_read(notif_id, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="Notification not found or access denied")
    return {"status": "success"}

@app.delete("/notifications")
def delete_notification(token_body: dict = Depends(verify_jwt)):
    user_id = int(token_body.get("sub"))
    db.delete_notification(user_id)


@app.post("/notifications/internal")
def create_internal_notification(payload: dict = Body()):
    try:
        db.create_notification(
            user_id=int(payload.get("user_id")),
            title=payload.get("title"),
            message=payload.get("message")
        )
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))