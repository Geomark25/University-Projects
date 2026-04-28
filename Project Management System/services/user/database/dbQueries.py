from .userModel import User, UserRole
from .userSchemas import UserScheme, userRoleEnum, userStateEnum, UserUpdate, UserStateScheme
from .userDatabase import init_db, SessionLocal
from sqlalchemy.exc import IntegrityError
from email_validator import validate_email, EmailNotValidError

init_db()

def create_user(user: UserScheme) -> UserScheme | None:
    db = SessionLocal()
    try:
        dbuser = User(
            username=user.username,
            email=user.email,
            hashed_password=user.hashed_password,
            first_name=user.first_name,
            last_name=user.last_name,
            user_role=userRoleEnum(user.user_role),
            user_state=userStateEnum(user.user_state)
        )
        db.add(dbuser)
        db.commit()
        db.refresh(dbuser)
        return UserScheme.model_validate(dbuser)
    except IntegrityError:
        db.rollback()
        return None
    finally:
        db.close()

def get_user_by_identifier(identifier: str) -> UserScheme | None:
    db = SessionLocal()
    try:
        user = db.query(User).filter(
            (User.username == identifier) | (User.email == identifier)
        ).first()
        if user:
            return UserScheme.model_validate(user)
        return None
    finally:
        db.close()

def get_user_by_id(user_id: int) -> UserScheme | None:
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.user_id == user_id).first()
        if user:
            return UserScheme.model_validate(user)
        return None
    finally:
        db.close()

def update_user_by_id(user_id: int, info: UserUpdate)-> UserScheme | None:
    db = SessionLocal()
    try:
        validate_email(info.email, check_deliverability=False)

        db.query(User).filter(User.user_id == user_id).update(info.model_dump())
        db.commit()
    except EmailNotValidError:
        raise
    except IntegrityError:
        db.rollback()
        raise
    finally:
        db.close()

def update_user_by_id(user_id: int, info: UserStateScheme):
    db = SessionLocal()
    try:
        db.query(User).filter(User.user_id == user_id).update(info.model_dump())
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

    
def get_users():
    db = SessionLocal()
    try:
        return db.query(User).all()
    finally:
        db.close()

def delete_user(user_id: int):
    db = SessionLocal()
    try:
        db.query(User).filter(User.user_id == user_id).update({User.user_state: userStateEnum.DELETED})
        db.commit()
    except:
        raise
    finally:
        db.close()

def change_pass(user_id: int, password: str):
    db = SessionLocal()
    try:
        db.query(User).filter(User.user_id == user_id).update({User.hashed_password: password})
        db.commit()
    except:
        raise
    finally:
        db.close()

def get_users_by_id(ids):
    db = SessionLocal()
    try:
        return db.query(User).filter(User.user_id.in_(ids)).all()
    except:
        raise
    finally:
        db.close()