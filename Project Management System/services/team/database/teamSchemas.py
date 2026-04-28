from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, List
from enum import Enum

# Matches your RoleInTeam enum [cite: 53]
class RoleInTeam(str, Enum):
    LEADER = "LEADER"
    MEMBER = "MEMBER"

# Schema for the membership association [cite: 123]
class TeamUserBase(BaseModel):
    user_id: int
    role_in_team: RoleInTeam = RoleInTeam.MEMBER

class TeamUserScheme(TeamUserBase):
    team_id: int
    
    class Config:
        from_attributes = True


class TeamCreate(BaseModel):
    name: str
    description: Optional[str] = None

class TeamScheme(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    date_created: datetime

    class Config:
        from_attributes = True


class TeamDetailSchema(TeamScheme):
    members: List[TeamUserBase] = []

    class Config:
        from_attributes = True