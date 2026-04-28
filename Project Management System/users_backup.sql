--
-- PostgreSQL database dump
--

\restrict o9gVeVfQRMxxAeNHbo49E6aiIqB9kkFAscGDeAEGjAokIacPx3EnSz7rm4w7kWK

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
-- Name: user_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role AS ENUM (
    'ADMIN',
    'MEMBER'
);


ALTER TYPE public.user_role OWNER TO postgres;

--
-- Name: user_state; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_state AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'DEACTIVATED',
    'DELETED'
);


ALTER TYPE public.user_state OWNER TO postgres;

--
-- Name: userrole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.userrole AS ENUM (
    'ADMIN',
    'MEMBER'
);


ALTER TYPE public.userrole OWNER TO postgres;

--
-- Name: userstate; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.userstate AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'DEACTIVATED',
    'DELETED'
);


ALTER TYPE public.userstate OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    user_role public.user_role DEFAULT 'MEMBER'::public.user_role NOT NULL,
    user_state public.user_state DEFAULT 'INACTIVE'::public.user_state NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, email, hashed_password, first_name, last_name, user_role, user_state) FROM stdin;
27	john_dev	john@pm.com	scrypt_hash_3	John	Doe	MEMBER	ACTIVE
28	jane_qa	jane@pm.com	scrypt_hash_4	Jane	Smith	MEMBER	ACTIVE
29	mike_dev	mike@pm.com	scrypt_hash_5	Mike	Ross	MEMBER	ACTIVE
30	rachel_z	rachel@pm.com	scrypt_hash_6	Rachel	Zane	MEMBER	ACTIVE
31	harvey_s	harvey@pm.com	scrypt_hash_7	Harvey	Specter	ADMIN	ACTIVE
32	donna_p	donna@pm.com	scrypt_hash_8	Donna	Paulsen	ADMIN	ACTIVE
33	louis_l	louis@pm.com	scrypt_hash_9	Louis	Litt	MEMBER	ACTIVE
34	katrina_b	katrina@pm.com	scrypt_hash_10	Katrina	Bennett	MEMBER	ACTIVE
35	bruce_w	bruce@pm.com	scrypt_hash_11	Bruce	Wayne	MEMBER	ACTIVE
36	clark_k	clark@pm.com	scrypt_hash_12	Clark	Kent	MEMBER	ACTIVE
37	diana_p	diana@pm.com	scrypt_hash_13	Diana	Prince	MEMBER	ACTIVE
38	barry_a	barry@pm.com	scrypt_hash_14	Barry	Allen	MEMBER	ACTIVE
39	arthur_c	arthur@pm.com	scrypt_hash_15	Arthur	Curry	MEMBER	ACTIVE
40	victor_s	victor@pm.com	scrypt_hash_16	Victor	Stone	MEMBER	ACTIVE
41	hal_j	hal@pm.com	scrypt_hash_17	Hal	Jordan	MEMBER	ACTIVE
42	tony_s	tony@pm.com	scrypt_hash_18	Tony	Stark	ADMIN	ACTIVE
43	steve_r	steve@pm.com	scrypt_hash_19	Steve	Rogers	MEMBER	ACTIVE
44	nat_r	nat@pm.com	scrypt_hash_20	Natasha	Romanoff	MEMBER	ACTIVE
45	bruce_b	bruce_b@pm.com	scrypt_hash_21	Bruce	Banner	MEMBER	ACTIVE
46	wanda_m	wanda@pm.com	scrypt_hash_22	Wanda	Maximoff	MEMBER	ACTIVE
47	pietro_m	pietro@pm.com	scrypt_hash_23	Pietro	Maximoff	MEMBER	ACTIVE
48	vision_v	vision@pm.com	scrypt_hash_24	Vision	Android	MEMBER	ACTIVE
49	sam_w	sam@pm.com	scrypt_hash_25	Sam	Wilson	MEMBER	ACTIVE
50	bucky_b	bucky@pm.com	scrypt_hash_26	Bucky	Barnes	MEMBER	ACTIVE
51	scott_l	scott@pm.com	scrypt_hash_27	Scott	Lang	MEMBER	ACTIVE
52	hope_v	hope@pm.com	scrypt_hash_28	Hope	VanDyne	MEMBER	ACTIVE
53	t_challa	t@pm.com	scrypt_hash_29	T	Challa	ADMIN	ACTIVE
54	shuri_w	shuri@pm.com	scrypt_hash_30	Shuri	Wakanda	MEMBER	ACTIVE
25	alex_admin	alex@pm.com	scrypt_hash_1	Alex	Vance	ADMIN	ACTIVE
26	sarah_lead	sarah@pm.com	scrypt_hash_2	Sarah	Connor	MEMBER	ACTIVE
\.


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 54, true);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- PostgreSQL database dump complete
--

\unrestrict o9gVeVfQRMxxAeNHbo49E6aiIqB9kkFAscGDeAEGjAokIacPx3EnSz7rm4w7kWK

