import enum
from sqlalchemy import Column, Integer, String, Boolean, Enum
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    pass

class UserRole(str, enum.Enum):
    ADMIN = "ADMIN"
    MEMBER= "MEMBER"

class UserState(str, enum.Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    DEACTIVATED = "DEACTIVATED"
    DELETED = "DELETED"

class User(Base):
    __tablename__ = 'users'

    user_id = Column(Integer, primary_key=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    user_role = Column(Enum(UserRole), default=UserRole.MEMBER, nullable=False)
    user_state = Column(Enum(UserState), default=UserState.INACTIVE, nullable=False)
    