from fastapi import Depends, FastAPI, HTTPException, Body, Header, Query
from sqlalchemy.exc import IntegrityError
import database.dbQueries as db
from database import User
from database import UserScheme, userStateEnum, UserUpdate, UserStateScheme, userRoleEnum
from datetime import datetime, timedelta
from jose import JWTError, jwt
import httpx
from email_validator import EmailNotValidError

app = FastAPI()

SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

API_URL = "http://nginx-gateway/api"

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

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
    return {"status": "success", "message": "User Service is running"}

@app.get("/all")
def fetch_all(token_data: dict = Depends(verify_jwt)):
        return db.get_users()

@app.post("/signup")
def signup(user: UserScheme):
    try:
        created_user = db.create_user(user)

        if not created_user:
            raise HTTPException(status_code=409, detail="User already exists")

        token_data = {
            "sub": created_user.username,
            "role": created_user.user_role,
        }

        token = create_access_token(data=token_data)

        return {
            "status": "success",
            "token": token,
            "token_type": "bearer"
        }
    
    except IntegrityError:
        raise
    except Exception:
        raise
    

@app.post("/login")
def login_user(credentials: dict = Body(...)):
    identifier = credentials.get("identifier")
    password = credentials.get("password")
    
    user = db.get_user_by_identifier(identifier) 
    
    if not user or not (password == user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    

    match user.user_state:
        case userStateEnum.INACTIVE:
            raise HTTPException(status_code=403, detail="Account needs approval from admin")
        case userStateEnum.DEACTIVATED:
            raise HTTPException(status_code=403, detail="User has been temporarily deactivated")
        case userStateEnum.DELETED:
            raise HTTPException(status_code=403, detail="User has been deleted")
        case _:
            pass
    
    token_data = {
        "sub": str(user.user_id),
        "username": user.username,
        "role": user.user_role,
        "email": user.email
    }
    
    token = create_access_token(token_data)
    
    return {
        "status": "success",
        "token": token,
        "token_type": "bearer"
    }

@app.get("/get_user")
def get_user_info(token_data: dict = Depends(verify_jwt)):
    user_id = int(token_data.get("sub"))
    user = db.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.patch("/update_user")
def update_self(info: UserUpdate, token_data: dict = Depends(verify_jwt)):
    user_id = int(token_data.get("sub"))

    try:
        db.update_user_by_id(user_id, info)
    except EmailNotValidError:
        raise HTTPException(status_code=400, detail="Email is not valid")
    except IntegrityError as e:
        error = str(e.orig)
        if "username" in error:
            detail = "Username is taken"
        elif "email" in error:
            detail = "Email is already registered"
        else:
            raise

        raise HTTPException(status_code=409, detail=detail)

@app.patch("/update_user/{user_id}")
async def update_user(user_id: int, info: dict = Body()):
    data = UserStateScheme(
        user_role = info.get("user_role"),
        user_state = info.get("user_state")
    )
    try:
        db.update_user_by_id(user_id, data)

        # Notify user if their account is activated
        if info.get("user_state") == "ACTIVE":
            async with httpx.AsyncClient() as client:
                await client.post(
                    f"{API_URL}/tasks/notifications/internal",
                    json={
                        "user_id": user_id,
                        "title": "Account Activated",
                        "message": "Your account has been approved by an administrator."
                    }
                )

    except:
        raise
    
@app.delete("/delete")
async def delete_user(token_data: dict = Depends(verify_jwt)):
    user_id = int(token_data.get("sub"))

    db.delete_user(user_id)
    async with httpx.AsyncClient() as client:
        await client.delete(f"{API_URL}/teams/delete_user/{user_id}")

@app.delete("/delete_by_id/{user_id}", dependencies=[Depends(verify_jwt)])
async def delete_user_by_id(user_id: int):
    db.delete_user(user_id)
    async with httpx.AsyncClient() as client:
        await client.delete(f"{API_URL}/teams/delete_user/{user_id}")


@app.patch("/password")
def change_pass(password: dict = Body(), token_data: dict = Depends(verify_jwt)):
    user_id = int(token_data.get("sub"))

    try:
        db.change_pass(user_id, password["new_password"])
    except IntegrityError as e:
        raise HTTPException(status_code=400, detail=e.orig)
    
@app.get("/get_by_id", dependencies=[Depends(verify_jwt)])
def get_by_id(ids: list[int] = Query(None)):
    try:
        return db.get_users_by_id(ids)
    except:
        raise

@app.post("/create", dependencies=[Depends(verify_jwt)])
def create_user(payload: dict):
    user = UserScheme(
        username=payload.get("username"),
        email=payload.get("email"),
        hashed_password=payload.get("password"),
        first_name=payload.get("first_name"),
        last_name=payload.get("last_name"),
        user_role=payload.get("role"),
        user_state=payload.get("state")
    )
    try:
        db.create_user(user)
    except:
        raise