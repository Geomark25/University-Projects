from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from enum import Enum

class userRoleEnum(str, Enum):
    ADMIN = "ADMIN"
    MEMBER = "MEMBER"

class userStateEnum(str, Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    DEACTIVATED = "DEACTIVATED"
    DELETED = "DELETED"


class UserScheme(BaseModel):
    user_id : Optional[int] = None
    username: str
    email: EmailStr
    hashed_password: str
    first_name: str
    last_name: str
    user_role: userRoleEnum = Field(default = userRoleEnum.MEMBER)
    user_state: userStateEnum = Field(default = userStateEnum.INACTIVE)

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    username: str
    email: EmailStr
    first_name: str
    last_name: str

class UserStateScheme(BaseModel):
    user_role: userRoleEnum = Field()
    user_state: userStateEnum = Field()