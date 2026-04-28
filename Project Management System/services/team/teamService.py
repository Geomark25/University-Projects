import os
from fastapi import FastAPI, Depends, HTTPException, Header, status, Body
import httpx
from jose import jwt, JWTError
from database import dbQueries as db

app = FastAPI()

# Configuration
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
    return {"status": "success", "message": "Team Service is running"}

@app.get("/all")
def fetch_all(token_data: dict = Depends(verify_jwt)):
    if token_data.get("role") != "ADMIN":
        raise HTTPException(status_code=403, detail="Request was not made by an admin")
    else:
        return db.get_all()

@app.get("/my_teams")
def get_teams_api(token_data: dict = Depends(verify_jwt)):
    try:
        user_id = int(token_data.get("sub"))
    except (TypeError, ValueError):
        raise HTTPException(status_code=400, detail="Invalid user ID in token")
        
    teams = db.getMyTeams(user_id=user_id)
    return teams

@app.get("/{team_id}/members", dependencies=[Depends(verify_jwt)])
def get_members(team_id: int):
    try:
        return db.getUsers(team_id)
    except:
        raise

@app.delete("/delete_user/{user_id}")
async def delete_user(user_id: int):
    try:
        db.delete_by_user_id(user_id)
    except:
        raise

@app.post("/create", dependencies=[Depends(verify_jwt)])
def create_team(payload: dict = Body()):
    return db.create_team(payload)

@app.patch("/update/{team_id}", dependencies=[Depends(verify_jwt)])
async def update_teams(team_id: int, payload: dict = Body()):
    try:
        if("name" in payload):
            db.update_team_by_id(team_id, payload)
        
        assigned_leader_id = payload.get("assigned_user_id")
        if assigned_leader_id:
            db.update_leader(team_id, assigned_leader_id)
            
            # Notify new leader
            async with httpx.AsyncClient() as client:
                await client.post(
                    f"{API_URL}/tasks/notifications/internal",
                    json={
                        "user_id": assigned_leader_id,
                        "title": "Team Leadership",
                        "message": f"You are now the leader of team ID {team_id}"
                    }
                )
    except:
        raise

@app.post("/{team_id}/add_member", dependencies=[Depends(verify_jwt)])
async def add_user_to_team(team_id: int, payload: dict = Body()):
    try:
        user_id = int(payload.get("user_id"))
        db.add_user(team_id, user_id)
        
        # Notify User
        async with httpx.AsyncClient() as client:
            await client.post(
                f"{API_URL}/tasks/notifications/internal",
                json={
                    "user_id": user_id,
                    "title": "Added to Team",
                    "message": f"You have been added to team ID {team_id}"
                }
            )
    except:
        raise

@app.delete("/{team_id}/delete_member", dependencies=[Depends(verify_jwt)])
async def delete_user_from_team(team_id: int, payload: dict = Body()):
    try:
        user_id = int(payload.get("user_id"))
        db.remove_user(team_id, user_id)
        
        # Notify User
        async with httpx.AsyncClient() as client:
            await client.post(
                f"{API_URL}/tasks/notifications/internal",
                json={
                    "user_id": user_id,
                    "title": "Removed from Team",
                    "message": f"You have been removed from team ID {team_id}"
                }
            )
    except:
        raise

@app.delete("/{team_id}/delete", dependencies=[Depends(verify_jwt)])
async def delete_team(team_id: int):
    try:
        db.delete_team(team_id)
        async with httpx.AsyncClient() as client:
            await client.delete(f"{API_URL}/tasks/delete/{team_id}")
    except:
        raise