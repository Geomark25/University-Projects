--
-- PostgreSQL database dump
--

\restrict swy93AUVTOI4h4RaB0f7oLBIPsLcytbC6n46EZ97eGiICAa7wkU4wMg0nLM4jNK

-- Dumped from database version 17.7 (Debian 17.7-3.pgdg13+1)
-- Dumped by pg_dump version 17.7 (Debian 17.7-3.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: taskpriority; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.taskpriority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH'
);


ALTER TYPE public.taskpriority OWNER TO postgres;

--
-- Name: taskstate; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.taskstate AS ENUM (
    'TODO',
    'IN_PROGRESS',
    'DONE'
);


ALTER TYPE public.taskstate OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying NOT NULL,
    message character varying NOT NULL,
    is_read boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_id_seq OWNER TO postgres;

--
-- Name: notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_id_seq OWNED BY public.notification.id;


--
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task (
    id integer NOT NULL,
    title character varying NOT NULL,
    description text,
    team_id integer NOT NULL,
    state public.taskstate DEFAULT 'TODO'::public.taskstate,
    priority public.taskpriority DEFAULT 'LOW'::public.taskpriority,
    deadline timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by integer NOT NULL
);


ALTER TABLE public.task OWNER TO postgres;

--
-- Name: task_attachment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_attachment (
    id integer NOT NULL,
    task_id integer NOT NULL,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    file_data bytea NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.task_attachment OWNER TO postgres;

--
-- Name: task_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_attachment_id_seq OWNER TO postgres;

--
-- Name: task_attachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_attachment_id_seq OWNED BY public.task_attachment.id;


--
-- Name: task_comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_comment (
    id integer NOT NULL,
    task_id integer NOT NULL,
    user_id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.task_comment OWNER TO postgres;

--
-- Name: task_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_comment_id_seq OWNER TO postgres;

--
-- Name: task_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_comment_id_seq OWNED BY public.task_comment.id;


--
-- Name: task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_id_seq OWNER TO postgres;

--
-- Name: task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_id_seq OWNED BY public.task.id;


--
-- Name: task_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_user (
    id integer NOT NULL,
    task_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.task_user OWNER TO postgres;

--
-- Name: task_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_user_id_seq OWNER TO postgres;

--
-- Name: task_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_user_id_seq OWNED BY public.task_user.id;


--
-- Name: notification id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification ALTER COLUMN id SET DEFAULT nextval('public.notification_id_seq'::regclass);


--
-- Name: task id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task ALTER COLUMN id SET DEFAULT nextval('public.task_id_seq'::regclass);


--
-- Name: task_attachment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachment ALTER COLUMN id SET DEFAULT nextval('public.task_attachment_id_seq'::regclass);


--
-- Name: task_comment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment ALTER COLUMN id SET DEFAULT nextval('public.task_comment_id_seq'::regclass);


--
-- Name: task_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_user ALTER COLUMN id SET DEFAULT nextval('public.task_user_id_seq'::regclass);


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, user_id, title, message, is_read, created_at) FROM stdin;
\.


--
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (id, title, description, team_id, state, priority, deadline, created_at, created_by) FROM stdin;
1	Setup API Gateway	Route all services through the central gateway.	1	IN_PROGRESS	HIGH	2026-02-01 00:00:00	2026-01-08 23:02:53.943382	1
2	Design Admin Dashboard	Create the HIGH-contrast operational overview.	2	TODO	MEDIUM	2026-01-20 00:00:00	2026-01-08 23:02:53.943382	1
3	Task Persistence Layer	Implement SQLAlchemy models for tasks.	3	DONE	HIGH	2026-01-10 00:00:00	2026-01-08 23:02:53.943382	7
4	Unit Tests for Auth	Cover all edge cases for JWT validation.	4	IN_PROGRESS	MEDIUM	2026-01-25 00:00:00	2026-01-08 23:02:53.943382	8
5	Team Resource Audit	Review team workloads for Q1.	5	TODO	LOW	2026-03-01 00:00:00	2026-01-08 23:02:53.943382	29
6	CI/CD Pipeline Fix	Repair the broken build on Jenkins.	4	DONE	HIGH	2026-01-05 00:00:00	2026-01-08 23:02:53.943382	8
7	Documentation for API	Draft Swagger documentation for all endpoints.	3	TODO	MEDIUM	2026-02-15 00:00:00	2026-01-08 23:02:53.943382	7
8	User Preference UI	Build the settings page for user profiles.	2	IN_PROGRESS	LOW	2026-02-10 00:00:00	2026-01-08 23:02:53.943382	1
9	Database Indexing	Optimize task searches by adding indexes.	1	DONE	HIGH	2026-01-07 00:00:00	2026-01-08 23:02:53.943382	1
10	Bug: Comment Sorting	Fix the date sorting issue in task view.	2	TODO	MEDIUM	2026-01-18 00:00:00	2026-01-08 23:02:53.943382	1
11	Log Aggregation	Setup ELK stack for service logs.	1	TODO	HIGH	2026-03-15 00:00:00	2026-01-08 23:02:53.943382	1
12	Password Hashing Update	Switch from scrypt to Argon2.	3	IN_PROGRESS	HIGH	2026-02-28 00:00:00	2026-01-08 23:02:53.943382	7
13	Mobile Responsive CSS	Fix the task table on mobile views.	2	DONE	LOW	2026-01-06 00:00:00	2026-01-08 23:02:53.943382	1
14	Frontend State Fix	Resolve the null filter error in AdminPanel.	2	DONE	HIGH	2026-01-08 00:00:00	2026-01-08 23:02:53.943382	1
15	Staging Env Setup	Replicate production environment for testing.	4	TODO	MEDIUM	2026-02-05 00:00:00	2026-01-08 23:02:53.943382	8
16	Security Audit	Review gateway permissions for all routes.	1	IN_PROGRESS	HIGH	2026-02-10 00:00:00	2026-01-08 23:02:53.943382	1
17	Email Service Hook	Connect SMTP for task notifications.	3	TODO	MEDIUM	2026-03-20 00:00:00	2026-01-08 23:02:53.943382	7
18	Bug: Team ID Match	Fix the mismatch in TeamManagerOverlay.	2	IN_PROGRESS	MEDIUM	2026-01-15 00:00:00	2026-01-08 23:02:53.943382	1
20	Analytics Middleware	Track API usage via custom middleware.	1	TODO	MEDIUM	2026-03-10 00:00:00	2026-01-08 23:02:53.943382	1
21	Migration Strategy	Plan the move from v1 to v2 API.	5	IN_PROGRESS	MEDIUM	2026-02-20 00:00:00	2026-01-08 23:02:53.943382	29
22	Task Reassignment Logic	Allow leads to swap assignees.	3	TODO	HIGH	2026-02-15 00:00:00	2026-01-08 23:02:53.943382	7
23	Search Index Update	Refresh indices for the global search.	1	DONE	MEDIUM	2026-01-04 00:00:00	2026-01-08 23:02:53.943382	1
24	Theme Switcher	Implement dark mode toggle.	2	TODO	LOW	2026-03-05 00:00:00	2026-01-08 23:02:53.943382	1
25	Auth Token Expiry Fix	Increase duration for long-running sessions.	3	DONE	MEDIUM	2026-01-02 00:00:00	2026-01-08 23:02:53.943382	7
26	Load Balancer Config	Setup NGINX for the gateway.	1	TODO	HIGH	2026-02-25 00:00:00	2026-01-08 23:02:53.943382	1
28	Team Lead Onboarding	Train new leads on the dashboard.	5	DONE	LOW	2026-01-01 00:00:00	2026-01-08 23:02:53.943382	29
29	API Rate Limiting	Prevent brute force on login routes.	1	IN_PROGRESS	HIGH	2026-02-15 00:00:00	2026-01-08 23:02:53.943382	1
30	Cloud Storage Sync	Attach assets to tasks via S3.	3	TODO	MEDIUM	2026-03-25 00:00:00	2026-01-08 23:02:53.943382	7
32	User 25: Frontend Sync	Sync styles with the AdminPanel.	2	TODO	MEDIUM	2026-02-05 00:00:00	2026-01-09 12:29:03.384672	25
33	User 25: SQL Optimization	Review slow queries in Task Service.	3	DONE	HIGH	2026-01-15 00:00:00	2026-01-09 12:29:03.384672	25
34	User 25: Auth Refactor	Transition from JWT to Session tokens.	1	IN_PROGRESS	HIGH	2026-02-10 00:00:00	2026-01-09 12:29:03.384672	25
35	User 25: UI Polish	Update HIGH-contrast color variables.	2	TODO	LOW	2026-02-20 00:00:00	2026-01-09 12:29:03.384672	25
36	User 25: Legacy Cleanup	Remove old status column references.	3	DONE	MEDIUM	2026-01-12 00:00:00	2026-01-09 12:29:03.384672	25
37	User 25: Error Logging	Implement Sentry for the Gateway.	1	TODO	HIGH	2026-03-01 00:00:00	2026-01-09 12:29:03.384672	25
38	User 25: Docker Update	Update base images to Python 3.13.	3	IN_PROGRESS	MEDIUM	2026-02-28 00:00:00	2026-01-09 12:29:03.384672	25
39	User 25: Team Onboarding	Welcome new members to Team Infra.	1	TODO	LOW	2026-03-05 00:00:00	2026-01-09 12:29:03.384672	25
40	User 25: Schema Migration	Finalize many-to-many relationship.	3	DONE	HIGH	2026-01-08 00:00:00	2026-01-09 12:29:03.384672	25
41	User 25: Unit Testing	Achieve 90% coverage on Task service.	3	IN_PROGRESS	MEDIUM	2026-02-15 00:00:00	2026-01-09 12:29:03.384672	25
42	User 25: Security Patch	Apply critical kernel updates.	1	TODO	HIGH	2026-01-25 00:00:00	2026-01-09 12:29:03.384672	25
43	User 25: Load Test	Benchmark the API Gateway under load.	1	TODO	MEDIUM	2026-03-10 00:00:00	2026-01-09 12:29:03.384672	25
44	User 25: Design Review	Approve the new Dashboard mockups.	2	DONE	LOW	2026-01-05 00:00:00	2026-01-09 12:29:03.384672	25
45	User 25: Cache Strategy	Implement Redis for task lookups.	3	IN_PROGRESS	HIGH	2026-02-22 00:00:00	2026-01-09 12:29:03.384672	25
31	User 25: API Audit	Perform a full audit of Gateway routes.	1	DONE	HIGH	2026-02-01 00:00:00	2026-01-09 12:29:03.384672	25
19	Performance Benchmarking	Test API response times under load.	4	TODO	LOW	2026-04-01 00:00:00	2026-01-08 23:02:53.943382	8
46	Hehe		40	TODO	MEDIUM	\N	2026-01-10 12:20:33.754759	25
27	Regression Test Suite	Automate tests for core features.	4	DONE	MEDIUM	2026-02-12 00:00:00	2026-01-08 23:02:53.943382	8
47	fd	d	1	TODO	MEDIUM	\N	2026-01-10 20:31:47.922621	26
\.


--
-- Data for Name: task_attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_attachment (id, task_id, filename, content_type, file_data, created_at) FROM stdin;
\.


--
-- Data for Name: task_comment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_comment (id, task_id, user_id, content, created_at) FROM stdin;
1	1	1	Started the gateway config.	2026-01-08 10:00:00
2	1	5	Found a routing conflict with the Auth service.	2026-01-08 11:30:00
3	3	7	Models are pushed to the dev branch.	2026-01-09 09:00:00
4	3	3	Reviewed and looks good.	2026-01-09 10:15:00
5	4	8	QA testing initiated for login routes.	2026-01-08 14:00:00
6	6	8	Fixed the build issue.	2026-01-05 12:00:00
7	8	2	The settings UI is too complex, simplifying.	2026-01-08 16:45:00
8	1	1	Routing conflict resolved.	2026-01-08 17:00:00
9	12	7	Hashing logic needs to be backwards compatible.	2026-01-08 12:00:00
10	14	1	Null filter bug was a race condition in useEffect.	2026-01-08 15:30:00
11	2	1	Will start the dashboard after the API is stable.	2026-01-07 09:00:00
12	9	12	Indices added to task_id and user_id.	2026-01-07 11:00:00
13	18	15	Need more info on the Team ID mismatch.	2026-01-08 13:00:00
14	28	27	Training materials for leads are ready.	2026-01-01 10:00:00
15	21	29	Migration plan is in the shared drive.	2026-01-08 14:30:00
16	16	14	Access denied on /admin/users route, checking gateway.	2026-01-08 11:00:00
17	25	7	JWT expiry is now 24 hours.	2026-01-02 16:00:00
18	4	23	Testing the logout flow now.	2026-01-09 08:30:00
19	12	21	Argon2 parameters have been tuned.	2026-01-08 13:00:00
20	3	19	Added relationship mapping for comments.	2026-01-09 11:00:00
21	1	11	NGINX ingress is now configured.	2026-01-08 18:00:00
22	27	8	Selenium tests are running on every push.	2026-01-09 09:45:00
23	29	1	Rate limiting set to 100 req/min.	2026-01-08 10:15:00
24	1	5	Traffic is flowing correctly through the gateway.	2026-01-08 19:00:00
25	30	21	Storage bucket permissions verified.	2026-01-08 12:30:00
26	8	15	Icons added for the profile settings.	2026-01-08 17:00:00
27	7	20	Swagger UI is available at /docs.	2026-01-08 14:00:00
28	22	3	Losing data on reassignment, investigating.	2026-01-08 16:00:00
29	16	1	Gateway rule for AdminPanel fixed.	2026-01-08 11:45:00
30	11	13	Elasticsearch instance is up.	2026-01-08 12:00:00
31	31	1	Initial audit of the Gateway is underway.	2026-01-09 02:29:17.591748
32	31	25	Found some unauthorized routes in the dev profile.	2026-01-09 03:29:17.591748
33	31	7	Checking if these match the current Swagger spec.	2026-01-09 03:59:17.591748
34	31	25	The Swagger spec is outdated, updating now.	2026-01-09 04:29:17.591748
35	31	1	Wait for the frontend team before pushing changes.	2026-01-09 04:44:17.591748
36	31	25	Frontend team notified. Proceeding with the fix.	2026-01-09 05:29:17.591748
37	31	4	CI/CD pipeline failed on the audit branch.	2026-01-09 05:59:17.591748
38	31	25	Investigating the build logs now.	2026-01-09 06:29:17.591748
39	31	25	Fixed: Missing environment variable for API_KEY.	2026-01-09 06:59:17.591748
40	31	4	Pipeline is green. Proceeding with testing.	2026-01-09 07:29:17.591748
41	31	1	Good job on the quick fix User 25.	2026-01-09 07:59:17.591748
42	31	25	Running the integration suite now.	2026-01-09 08:29:17.591748
43	31	25	Tests passed. Requesting peer review.	2026-01-09 08:59:17.591748
44	31	7	Reviewing the code changes now.	2026-01-09 09:29:17.591748
45	31	7	Minor typo in line 42, please correct.	2026-01-09 09:59:17.591748
46	31	25	Typo fixed. Pushed again.	2026-01-09 10:29:17.591748
47	31	7	Approved. Ready for staging.	2026-01-09 10:59:17.591748
48	31	1	Staging deployment scheduled for tonight.	2026-01-09 11:29:17.591748
49	31	25	Monitoring logs during deployment.	2026-01-09 11:59:17.591748
50	31	25	Audit complete. Gateway is secure.	2026-01-09 12:24:17.591748
51	19	25	af	2026-01-09 12:55:52.148644
52	19	25	ha	2026-01-09 13:00:43.391095
53	19	25	f	2026-01-09 13:02:20.985499
54	19	25	ff	2026-01-09 13:04:53.070418
55	19	25	a	2026-01-09 13:09:11.645839
56	46	25	Lemaoo	2026-01-10 12:25:14.082257
57	46	25	haha	2026-01-10 13:30:23.855333
58	46	25	f	2026-01-10 13:30:29.488817
59	27	25	Haha	2026-01-10 20:19:55.506733
\.


--
-- Data for Name: task_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_user (id, task_id, user_id) FROM stdin;
1	1	1
2	1	5
3	1	11
4	2	2
5	2	6
6	3	7
7	3	3
8	3	19
9	4	8
10	4	4
11	5	29
12	5	9
13	6	8
14	6	23
15	7	7
16	7	20
17	8	2
18	8	15
19	9	1
20	9	12
21	10	2
22	10	16
23	11	1
24	11	13
25	12	7
26	12	21
27	13	2
28	13	17
29	14	2
30	14	18
31	15	8
32	15	24
33	16	1
34	16	14
35	17	7
36	17	22
37	18	2
38	18	15
39	19	8
40	19	25
41	20	1
42	20	5
43	21	29
44	21	10
45	22	7
46	22	3
47	23	1
48	23	11
49	24	2
50	24	6
51	25	7
52	25	19
53	26	1
54	26	12
55	27	8
56	27	26
57	28	29
58	28	27
59	29	1
60	29	13
61	30	7
62	30	21
63	31	25
64	32	25
65	33	25
66	34	25
67	35	25
68	36	25
69	37	25
70	38	25
71	39	25
72	40	25
73	41	25
74	42	25
75	43	25
76	44	25
77	45	25
78	47	26
\.


--
-- Name: notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_id_seq', 18, true);


--
-- Name: task_attachment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_attachment_id_seq', 1, true);


--
-- Name: task_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_comment_id_seq', 59, true);


--
-- Name: task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_id_seq', 47, true);


--
-- Name: task_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_user_id_seq', 78, true);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: task_attachment task_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachment
    ADD CONSTRAINT task_attachment_pkey PRIMARY KEY (id);


--
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: task_user task_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_user
    ADD CONSTRAINT task_user_pkey PRIMARY KEY (id);


--
-- Name: ix_notification_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notification_id ON public.notification USING btree (id);


--
-- Name: ix_task_attachment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_task_attachment_id ON public.task_attachment USING btree (id);


--
-- Name: task_attachment task_attachment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachment
    ADD CONSTRAINT task_attachment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: task_user task_user_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_user
    ADD CONSTRAINT task_user_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict swy93AUVTOI4h4RaB0f7oLBIPsLcytbC6n46EZ97eGiICAa7wkU4wMg0nLM4jNK

