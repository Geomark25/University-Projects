sudo docker exec -i pms-user-db-1 psql -U postgres -d user_db < users_backup.sql
sudo docker exec -i pms-team-db-1 psql -U postgres -d team_db < teams_backup.sql
sudo docker exec -i pms-task-db-1 psql -U postgres -d task_db < tasks_backup.sql