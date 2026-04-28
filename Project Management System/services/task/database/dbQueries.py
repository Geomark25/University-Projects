from .taskDatabase import init_db, SessionLocal
from .taskModel import Task, TaskPriority, TaskState, TaskComment, TaskUser, TaskAttachment, Notification
from sqlalchemy import select, or_, insert, update, delete
from sqlalchemy.orm import defer
from datetime import datetime

init_db()

def get_all():
    db = SessionLocal()
    try:
        return db.query(Task).all()
    finally:
        db.close()
    
def get_comments(task_id):
    db = SessionLocal()
    try:
        stmt = (
            select(TaskComment)
            .where(TaskComment.task_id == task_id)
            .order_by(TaskComment.created_at.asc())
        )
        res = db.execute(stmt).all()
        return [
            {
                "id": r.TaskComment.id,
                "content": r.TaskComment.content,
                "user_id": r.TaskComment.user_id,
                "created_at": r.TaskComment.created_at
            } for r in res
        ]
    finally:
        db.close()

def delete_tasks(team_id):
    db = SessionLocal()
    try:
        stmt = (
            delete(Task)
            .where(Task.team_id == team_id)
        )
        db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def create_task(team_id, user_id, payload: dict):
    db = SessionLocal()
    try:
        # 1. Create the Task object
        new_task = Task(
            team_id = team_id,
            title = payload.get("title"),
            description = payload.get("description"),
            state = payload.get("state"),
            priority = payload.get("priority"),
            deadline = payload.get("deadline") if "deadline" in payload else None,
            created_by = user_id,
            created_at = datetime.utcnow()
        )
        
        db.add(new_task)
        db.flush() # Flush to generate new_task.id

        assignee_ids = payload.get("assignee_ids", [])
        if assignee_ids:
            for assignee_id in assignee_ids:
                new_assignment = TaskUser(
                    task_id=new_task.id,
                    user_id=assignee_id
                )
                db.add(new_assignment)

                if int(assignee_id) != int(user_id):
                    alert = Notification(
                        user_id=assignee_id,
                        title="New Task Assignment",
                        message=f"You have been assigned to task '{new_task.title}'"
                    )
                    db.add(alert)
        
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def get_assignees(task_id):
    db = SessionLocal()
    try:
        return db.query(TaskUser).where(TaskUser.task_id == task_id).all()
    finally:
        db.close()

def get_tasks_by_user_id(user_id):
    db = SessionLocal()
    try:
        user_id = int(user_id)
        stmt = (
            select(Task)
            .outerjoin(TaskUser)
            .where(
                or_(
                    Task.created_by == user_id,
                    TaskUser.user_id == user_id
                )
            )
            .distinct()
        )
        return db.execute(stmt).scalars().all()
    finally:
        db.close()

def add_comment(task_id: int, user_id: int, data: dict):
    db = SessionLocal()
    try:
        stmt = (
            insert(TaskComment)
            .values(
                task_id=task_id,
                user_id=user_id,
                content=data.get("content"),
                created_at=datetime.utcnow()
            )
        )
        db.execute(stmt)
        db.commit()
    except Exception as e:
        db.rollback()
        raise
    finally:
        db.close()

def update_state(task_id, state):
    db = SessionLocal()
    try:
        stmt = (
            update(Task)
            .where(Task.id == task_id)
            .values(
                state = TaskState(state)
            )
        )
        db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def get_tasks_by_team_id(team_id):
    db = SessionLocal()
    try:
        return db.query(Task).where(Task.team_id == team_id).all()
    finally:
        db.close()

def get_attachment_names(task_id):
    db = SessionLocal()
    try:
        return db.query(TaskAttachment).filter(TaskAttachment.task_id == task_id).options(defer(TaskAttachment.file_data)).all()
    finally:
        db.close()

def add_attachment(task_id, file_conent, file):
    db = SessionLocal()
    try:
        new_file = TaskAttachment(
            task_id = task_id,
            filename = file.filename,
            content_type = file.content_type,
            file_data = file_conent
        )
        db.add(new_file)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.commit()

def get_attachment_by_id(attachment_id) -> TaskAttachment:
    db = SessionLocal()
    try:
        return db.query(TaskAttachment).filter(TaskAttachment.id == attachment_id).first()
    finally:
        db.close()

def delete_attachment(attachment_id):
    db = SessionLocal()
    try:
        stmt = delete(TaskAttachment).where(TaskAttachment.id == attachment_id)
        db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()


def get_my_notifications(user_id):
    db = SessionLocal()
    try:
        return db.query(Notification)\
                 .filter(Notification.user_id == int(user_id))\
                 .order_by(Notification.created_at.desc())\
                 .all()
    finally:
        db.close()

def mark_notification_read(notif_id, user_id):
    db = SessionLocal()
    try:
        notif = db.query(Notification).filter(Notification.id == notif_id).first()
        if not notif:
            return False
        
        if notif.user_id != int(user_id):
            return False
            
        notif.is_read = True
        db.commit()
        return True
    except:
        db.rollback()
        raise
    finally:
        db.close()

def create_notification(user_id: int, title: str, message: str):
    db = SessionLocal()
    try:
        notif = Notification(
            user_id=user_id,
            title=title,
            message=message,
            created_at=datetime.utcnow(),
            is_read=False
        )
        db.add(notif)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def delete_notification(user_id: int):
    db = SessionLocal()
    try:
        stmt = delete(Notification).where(
            Notification.user_id == user_id
        )
        result = db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()