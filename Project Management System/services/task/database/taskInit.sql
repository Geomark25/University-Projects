-- 1. Initialize Types (Removed task_status)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'taskstate') THEN
        CREATE TYPE taskstate AS ENUM ('TODO', 'IN_PROGRESS', 'DONE');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'taskpriority') THEN
        CREATE TYPE taskpriority AS ENUM ('LOW', 'MEDIUM', 'HIGH');
    END IF;
END $$;

-- 2. Create Task Table (Status column removed)
CREATE TABLE IF NOT EXISTS task (
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    description TEXT,
    team_id INTEGER NOT NULL,
    state taskstate DEFAULT 'TODO',
    priority taskpriority DEFAULT 'LOW',
    deadline TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by INTEGER NOT NULL
);

-- 3. Create Multi-User Assignment Table
CREATE TABLE IF NOT EXISTS task_user (
    id SERIAL PRIMARY KEY,
    task_id INTEGER NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL
);

-- 4. Insert 30 Tasks (Status values removed)
INSERT INTO task (title, description, team_id, state, priority, deadline, created_by) VALUES
('Setup API Gateway', 'Route all services through the central gateway.', 1, 'IN_PROGRESS', 'HIGH', '2026-02-01', 1),
('Design Admin Dashboard', 'Create the HIGH-contrast operational overview.', 2, 'TODO', 'MEDIUM', '2026-01-20', 1),
('Task Persistence Layer', 'Implement SQLAlchemy models for tasks.', 3, 'DONE', 'HIGH', '2026-01-10', 7),
('Unit Tests for Auth', 'Cover all edge cases for JWT validation.', 4, 'IN_PROGRESS', 'MEDIUM', '2026-01-25', 8),
('Team Resource Audit', 'Review team workloads for Q1.', 5, 'TODO', 'LOW', '2026-03-01', 29),
('CI/CD Pipeline Fix', 'Repair the broken build on Jenkins.', 4, 'DONE', 'HIGH', '2026-01-05', 8),
('Documentation for API', 'Draft Swagger documentation for all endpoints.', 3, 'TODO', 'MEDIUM', '2026-02-15', 7),
('User Preference UI', 'Build the settings page for user profiles.', 2, 'IN_PROGRESS', 'LOW', '2026-02-10', 1),
('Database Indexing', 'Optimize task searches by adding indexes.', 1, 'DONE', 'HIGH', '2026-01-07', 1),
('Bug: Comment Sorting', 'Fix the date sorting issue in task view.', 2, 'TODO', 'MEDIUM', '2026-01-18', 1),
('Log Aggregation', 'Setup ELK stack for service logs.', 1, 'TODO', 'HIGH', '2026-03-15', 1),
('Password Hashing Update', 'Switch from scrypt to Argon2.', 3, 'IN_PROGRESS', 'HIGH', '2026-02-28', 7),
('Mobile Responsive CSS', 'Fix the task table on mobile views.', 2, 'DONE', 'LOW', '2026-01-06', 1),
('Frontend State Fix', 'Resolve the null filter error in AdminPanel.', 2, 'DONE', 'HIGH', '2026-01-08', 1),
('Staging Env Setup', 'Replicate production environment for testing.', 4, 'TODO', 'MEDIUM', '2026-02-05', 8),
('Security Audit', 'Review gateway permissions for all routes.', 1, 'IN_PROGRESS', 'HIGH', '2026-02-10', 1),
('Email Service Hook', 'Connect SMTP for task notifications.', 3, 'TODO', 'MEDIUM', '2026-03-20', 7),
('Bug: Team ID Match', 'Fix the mismatch in TeamManagerOverlay.', 2, 'IN_PROGRESS', 'MEDIUM', '2026-01-15', 1),
('Performance Benchmarking', 'Test API response times under load.', 4, 'TODO', 'LOW', '2026-04-01', 8),
('Analytics Middleware', 'Track API usage via custom middleware.', 1, 'TODO', 'MEDIUM', '2026-03-10', 1),
('Migration Strategy', 'Plan the move from v1 to v2 API.', 5, 'IN_PROGRESS', 'MEDIUM', '2026-02-20', 29),
('Task Reassignment Logic', 'Allow leads to swap assignees.', 3, 'TODO', 'HIGH', '2026-02-15', 7),
('Search Index Update', 'Refresh indices for the global search.', 1, 'DONE', 'MEDIUM', '2026-01-04', 1),
('Theme Switcher', 'Implement dark mode toggle.', 2, 'TODO', 'LOW', '2026-03-05', 1),
('Auth Token Expiry Fix', 'Increase duration for long-running sessions.', 3, 'DONE', 'MEDIUM', '2026-01-02', 7),
('Load Balancer Config', 'Setup NGINX for the gateway.', 1, 'TODO', 'HIGH', '2026-02-25', 1),
('Regression Test Suite', 'Automate tests for core features.', 4, 'IN_PROGRESS', 'MEDIUM', '2026-02-12', 8),
('Team Lead Onboarding', 'Train new leads on the dashboard.', 5, 'DONE', 'LOW', '2026-01-01', 29),
('API Rate Limiting', 'Prevent brute force on login routes.', 1, 'IN_PROGRESS', 'HIGH', '2026-02-15', 1),
('Cloud Storage Sync', 'Attach assets to tasks via S3.', 3, 'TODO', 'MEDIUM', '2026-03-25', 7);

-- 5. Task User Assignments
INSERT INTO task_user (task_id, user_id) VALUES
(1, 1), (1, 5), (1, 11), (2, 2), (2, 6), (3, 7), (3, 3), (3, 19), (4, 8), (4, 4),
(5, 29), (5, 9), (6, 8), (6, 23), (7, 7), (7, 20), (8, 2), (8, 15), (9, 1), (9, 12),
(10, 2), (10, 16), (11, 1), (11, 13), (12, 7), (12, 21), (13, 2), (13, 17), (14, 2), (14, 18),
(15, 8), (15, 24), (16, 1), (16, 14), (17, 7), (17, 22), (18, 2), (18, 15), (19, 8), (19, 25),
(20, 1), (20, 5), (21, 29), (21, 10), (22, 7), (22, 3), (23, 1), (23, 11), (24, 2), (24, 6),
(25, 7), (25, 19), (26, 1), (26, 12), (27, 8), (27, 26), (28, 29), (28, 27), (29, 1), (29, 13), (30, 7), (30, 21);

-- 6. Task Comments Table
CREATE TABLE IF NOT EXISTS task_comment (
    id SERIAL PRIMARY KEY,
    task_id INTEGER NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 7. Insert Comments
INSERT INTO task_comment (task_id, user_id, content, created_at) VALUES
(1, 1, 'Started the gateway config.', '2026-01-08 10:00:00'),
(1, 5, 'Found a routing conflict with the Auth service.', '2026-01-08 11:30:00'),
(3, 7, 'Models are pushed to the dev branch.', '2026-01-09 09:00:00'),
(3, 3, 'Reviewed and looks good.', '2026-01-09 10:15:00'),
(4, 8, 'QA testing initiated for login routes.', '2026-01-08 14:00:00'),
(6, 8, 'Fixed the build issue.', '2026-01-05 12:00:00'),
(8, 2, 'The settings UI is too complex, simplifying.', '2026-01-08 16:45:00'),
(1, 1, 'Routing conflict resolved.', '2026-01-08 17:00:00'),
(12, 7, 'Hashing logic needs to be backwards compatible.', '2026-01-08 12:00:00'),
(14, 1, 'Null filter bug was a race condition in useEffect.', '2026-01-08 15:30:00'),
(2, 1, 'Will start the dashboard after the API is stable.', '2026-01-07 09:00:00'),
(9, 12, 'Indices added to task_id and user_id.', '2026-01-07 11:00:00'),
(18, 15, 'Need more info on the Team ID mismatch.', '2026-01-08 13:00:00'),
(28, 27, 'Training materials for leads are ready.', '2026-01-01 10:00:00'),
(21, 29, 'Migration plan is in the shared drive.', '2026-01-08 14:30:00'),
(16, 14, 'Access denied on /admin/users route, checking gateway.', '2026-01-08 11:00:00'),
(25, 7, 'JWT expiry is now 24 hours.', '2026-01-02 16:00:00'),
(4, 23, 'Testing the logout flow now.', '2026-01-09 08:30:00'),
(12, 21, 'Argon2 parameters have been tuned.', '2026-01-08 13:00:00'),
(3, 19, 'Added relationship mapping for comments.', '2026-01-09 11:00:00'),
(1, 11, 'NGINX ingress is now configured.', '2026-01-08 18:00:00'),
(27, 8, 'Selenium tests are running on every push.', '2026-01-09 09:45:00'),
(29, 1, 'Rate limiting set to 100 req/min.', '2026-01-08 10:15:00'),
(1, 5, 'Traffic is flowing correctly through the gateway.', '2026-01-08 19:00:00'),
(30, 21, 'Storage bucket permissions verified.', '2026-01-08 12:30:00'),
(8, 15, 'Icons added for the profile settings.', '2026-01-08 17:00:00'),
(7, 20, 'Swagger UI is available at /docs.', '2026-01-08 14:00:00'),
(22, 3, 'Losing data on reassignment, investigating.', '2026-01-08 16:00:00'),
(16, 1, 'Gateway rule for AdminPanel fixed.', '2026-01-08 11:45:00'),
(11, 13, 'Elasticsearch instance is up.', '2026-01-08 12:00:00');