from .teamDatabase import init_db, SessionLocal
from sqlalchemy import update, insert, delete, case, cast, select, and_, insert
from .teamModel import Base, RoleInTeam, Team, TeamUser
from .teamSchemas import TeamScheme, TeamUserScheme
from datetime import datetime

init_db()

def get_all():
    db_session = SessionLocal()
    try:
        leader_subquery = (
        select(TeamUser.user_id)
        .where(
            and_(
                TeamUser.team_id == Team.id, # Link to the outer Team query
                TeamUser.role_in_team == RoleInTeam.LEADER
            )
        )
        .scalar_subquery() # Ensures it returns a single value per row
        )
        results = (
        db_session.query(
            Team, 
            leader_subquery.label("assigned_user_id")
        )
        .all()
    )

        output = []
        for row in results:
            row_dict = row._asdict()
            team_obj = row_dict["Team"]
            
            team_data = {
                "id": team_obj.id,
                "name": team_obj.name,
                "description": team_obj.description,
                "assigned_user_id": row_dict["assigned_user_id"]
            }
            output.append(team_data)

        return output
    finally:
        db_session.close()

def getMyTeams(user_id: int):
    try:
        db_session = SessionLocal()
        res= db_session.query(Team, TeamUser.role_in_team).join(TeamUser, TeamUser.team_id == Team.id).filter(TeamUser.user_id == user_id).all()

        teams_with_roles = []
        for team, role in res:
            team_dict = {
                "id": team.id,
                "name": team.name,
                "description": team.description,
                "date_created": team.date_created,
                "my_role": role # Specific role for the logged-in user
            }
            teams_with_roles.append(team_dict)
            
        return teams_with_roles
    finally:
        db_session.close()

def delete_by_user_id(user_id: int):
    try:
        db_session = SessionLocal()
        db_session.query(TeamUser).filter(TeamUser.user_id == user_id).delete()
        db_session.commit()
    except:
        db_session.rollback
        raise
    finally:
        db_session.close()

def create_team(payload: dict):
    try:
        desc = payload.get("description")
        if desc == "":
            desc = None
        db = SessionLocal()
        stmt = insert(Team).values(
            name=payload.get("name"),
            description = desc,
            date_created = datetime.utcnow()
        ).returning(Team.id)
        res = db.execute(stmt)
        db.commit()
        return res.scalar()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def update_team_by_id(team_id: int, data: dict):
    db = SessionLocal()
    try:
        stmt = (
            update(Team)
            .where(Team.id == team_id)
            .values(
                name = data.get("name"),
                description = data.get("description")
            )
            .execution_options(synchronize_session="fetch")
        )
        db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def getUsers(team_id):
    db_session = SessionLocal() #
    try:
        if team_id:
            # 1. Fetch the user_id where role_in_team is LEADER
            leader_row = db_session.query(TeamUser.user_id).filter(
                and_(
                    TeamUser.team_id == team_id,
                    TeamUser.role_in_team == RoleInTeam.LEADER
                )
            ).first()
            
            # Use the result or fallback to None
            assigned_id = leader_row[0] if leader_row else None
            
            # 2. Fetch all user_ids for the members list
            results = db_session.query(TeamUser.user_id).filter(TeamUser.team_id == team_id).all()
            member_ids = [row[0] for row in results]
            
            # 3. Return consolidated object for the frontend
            return {
                "members": member_ids,
                "assigned_id": assigned_id
            }
        return {"members": [], "assigned_id": None}
    except Exception:
        raise
    finally:
        db_session.close()

def update_leader(team_id, user_id):
    db = SessionLocal()
    try:
        if user_id is not None:
            user_id = int(user_id)
            db.execute(
                update(TeamUser)
                .where(TeamUser.team_id == team_id)
                .values(role_in_team=RoleInTeam.MEMBER)
            )
            db.execute(
                update(TeamUser)
                .where(TeamUser.team_id == team_id)
                .where(TeamUser.user_id == user_id)
                .values(role_in_team = RoleInTeam.LEADER)
            )
        else:
            stmt = (
                update(TeamUser)
                .where(TeamUser.team_id == team_id)
                .values(
                    role_in_team = "MEMBER"
                )
            )
            db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def add_user(team_id, user_id):
    db = SessionLocal()
    try:
        stmt = (
            insert(TeamUser)
            .values(
                team_id = team_id,
                user_id = user_id,
                role_in_team = "MEMBER"
            )
        )
        db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def remove_user(team_id, user_id):
    db = SessionLocal()
    try:
        stmt = (
            delete(TeamUser)
            .where(TeamUser.team_id == team_id)
            .where(TeamUser.user_id == user_id)
        )
        db.execute(stmt)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()

def delete_team(team_id):
    db = SessionLocal()
    try:
        stmt1 = (
            delete(Team)
            .where(Team.id == team_id)
        )
        db.execute(stmt1)
        stmt2 = (
            delete(TeamUser)
            .where(TeamUser.team_id == team_id)
        )
        db.execute(stmt2)
        db.commit()
    except:
        db.rollback()
        raise
    finally:
        db.close()