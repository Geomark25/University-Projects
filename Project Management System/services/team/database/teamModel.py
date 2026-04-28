import enum
from sqlalchemy import Column, ForeignKey, Integer, String, DateTime, Enum
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    pass

class RoleInTeam(str, enum.Enum):
    LEADER = "LEADER"
    MEMBER = "MEMBER"

class Team(Base):
    __tablename__ = 'teams'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    description = Column(String, nullable=True)
    date_created = Column(DateTime, nullable=False)

class TeamUser(Base):
    __tablename__ = 'team_users'

    team_id = Column(Integer, ForeignKey('teams.id'), index=True)
    user_id = Column(Integer, primary_key=True, index=True)
    role_in_team = Column(Enum(RoleInTeam), default=RoleInTeam.MEMBER, nullable=False)