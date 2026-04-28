--
-- PostgreSQL database dump
--

\restrict 5R4NbZNdJbLhcehJdtwHUt2LxjKSwLuM9so8F6rxvAkY2Eiridnqw4vM2ROvBC5

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
-- Name: role_in_team_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.role_in_team_enum AS ENUM (
    'LEADER',
    'MEMBER'
);


ALTER TYPE public.role_in_team_enum OWNER TO postgres;

--
-- Name: roleinteam; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.roleinteam AS ENUM (
    'LEADER',
    'MEMBER'
);


ALTER TYPE public.roleinteam OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: team_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_users (
    team_id integer NOT NULL,
    user_id integer NOT NULL,
    role_in_team public.role_in_team_enum DEFAULT 'MEMBER'::public.role_in_team_enum NOT NULL
);


ALTER TABLE public.team_users OWNER TO postgres;

--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    date_created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Data for Name: team_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_users (team_id, user_id, role_in_team) FROM stdin;
4	4	MEMBER
4	23	MEMBER
4	24	MEMBER
4	25	MEMBER
4	8	MEMBER
4	44	MEMBER
4	26	MEMBER
40	45	MEMBER
40	26	MEMBER
41	25	MEMBER
41	26	MEMBER
3	7	MEMBER
3	3	MEMBER
3	19	MEMBER
3	20	MEMBER
3	21	MEMBER
3	22	MEMBER
3	26	MEMBER
44	25	MEMBER
5	29	LEADER
5	9	MEMBER
5	10	MEMBER
5	27	MEMBER
5	28	MEMBER
5	30	MEMBER
39	25	MEMBER
42	25	MEMBER
43	25	MEMBER
45	25	MEMBER
46	25	MEMBER
47	25	MEMBER
48	25	MEMBER
49	25	MEMBER
1	5	MEMBER
1	11	MEMBER
1	12	MEMBER
1	13	MEMBER
1	14	MEMBER
1	1	MEMBER
1	26	LEADER
2	2	MEMBER
2	6	MEMBER
2	15	MEMBER
2	16	MEMBER
2	17	MEMBER
2	18	MEMBER
2	26	MEMBER
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (id, name, description, date_created) FROM stdin;
5	Project Management	Coordinating team deliverables	2025-01-12 00:00:00
1	Infrastructure	Core platform and API Gateway management	2025-01-01 00:00:00
2	Frontend	React and Design System development	2025-01-05 00:00:00
4	Quality Assurance	Testing and CI/CD pipelines	2025-01-10 00:00:00
40	Cloud Security	Managing AWS/Azure permissions.	2026-01-09 00:00:00
41	Data Analytics	Business intelligence and reporting.	2026-01-09 00:00:00
3	Backend	Python microservices and data persistence	2025-01-05 00:00:00
44	Legal Compliance	Ensuring GDPR and SOC2 standards.	2026-01-09 00:00:00
39	Beta Testers	Focus on early access feedback.	2026-01-09 00:00:00
42	Mobile Core	Swift and Kotlin development.	2026-01-09 00:00:00
43	DevOps Automation	CI/CD and Terraform scripts.	2026-01-09 00:00:00
45	Customer Success	User onboarding and support.	2026-01-09 00:00:00
46	API Design	Drafting REST and GraphQL specs.	2026-01-09 00:00:00
47	Performance Tuning	Database and cache optimization.	2026-01-09 00:00:00
48	Marketing Ops	Internal branding and outreach.	2026-01-09 00:00:00
49	Research & Dev	Experimental feature prototyping.	2026-01-09 00:00:00
\.


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_id_seq', 54, true);


--
-- Name: team_users team_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_users
    ADD CONSTRAINT team_users_pkey PRIMARY KEY (team_id, user_id);


--
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: team_users team_users_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_users
    ADD CONSTRAINT team_users_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 5R4NbZNdJbLhcehJdtwHUt2LxjKSwLuM9so8F6rxvAkY2Eiridnqw4vM2ROvBC5

