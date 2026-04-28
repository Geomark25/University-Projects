import enum
from sqlalchemy import Column, DateTime, Integer, String, Enum, ForeignKey, LargeBinary, Boolean
from sqlalchemy.orm import DeclarativeBase, relationship
from datetime import datetime
from pydantic import BaseModel

class Base(DeclarativeBase):
    pass

class TaskState(str, enum.Enum):
    TODO = "to_do"
    IN_PROGRESS = "in_progress"
    DONE = "done"

class TaskPriority(str, enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

class Task(Base):
    __tablename__ = "task"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    team_id = Column(Integer, nullable=False)
    state = Column(Enum(TaskState), default=TaskState.TODO)
    priority = Column(Enum(TaskPriority), default=TaskPriority.LOW)
    deadline = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    created_by = Column(Integer, nullable=False)

    # Relationship to Comments
    comments = relationship("TaskComment", back_populates="task", cascade="all, delete-orphan")
    attachments = relationship("TaskAttachment", back_populates="task", cascade="all, delete-orphan")
    assigned_users = relationship("TaskUser", back_populates="task", cascade="all, delete-orphan")

class TaskComment(Base):
    __tablename__ = "task_comment"

    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, ForeignKey("task.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, nullable=False)
    content = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    task = relationship("Task", back_populates="comments")

class TaskUser(Base):
    __tablename__ = "task_user"
    
    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, ForeignKey("task.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, nullable=False)

    # back_populates must match the property name in the Task class
    task = relationship("Task", back_populates="assigned_users")

class TaskAttachment(Base):
    __tablename__ = "task_attachment"

    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, ForeignKey("task.id", ondelete="CASCADE"), nullable=False)
    
    filename = Column(String, nullable=False)
    content_type = Column(String, nullable=False)
    file_data = Column(LargeBinary, nullable=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)

    task = relationship("Task", back_populates="attachments")

class Notification(Base):
    __tablename__ = "notification"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False) # The recipient
    title = Column(String, nullable=False)
    message = Column(String, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class AttachmentMetadata(BaseModel):
    id: int
    task_id: int
    filename: str
    content_type: str
    created_at: datetime

    class Config:
        from_attributes = True