--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: h2h_matches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE h2h_matches (
    id integer NOT NULL,
    match_id integer,
    match_order integer,
    home_manager_id integer,
    away_manager_id integer,
    home_score integer,
    away_score integer,
    info text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: h2h_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE h2h_matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h2h_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE h2h_matches_id_seq OWNED BY h2h_matches.id;


--
-- Name: managers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE managers (
    id integer NOT NULL,
    fpl_id integer,
    team_id integer,
    fpl_name character varying(255),
    fiso_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: managers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE managers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: managers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE managers_id_seq OWNED BY managers.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matches (
    id integer NOT NULL,
    game_week integer,
    home_team_id integer,
    away_team_id integer,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matches_id_seq OWNED BY matches.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE players (
    id integer NOT NULL,
    h2h_match_id integer,
    manager_id integer,
    name character varying(255),
    games_left integer,
    captain boolean,
    vice_captain boolean,
    bench boolean,
    "position" character varying(255),
    points integer,
    minutes_played integer,
    match_over boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE players_id_seq OWNED BY players.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE teams (
    id integer NOT NULL,
    name character varying(255),
    fpl_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE teams_id_seq OWNED BY teams.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY h2h_matches ALTER COLUMN id SET DEFAULT nextval('h2h_matches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY managers ALTER COLUMN id SET DEFAULT nextval('managers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matches ALTER COLUMN id SET DEFAULT nextval('matches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY players ALTER COLUMN id SET DEFAULT nextval('players_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams ALTER COLUMN id SET DEFAULT nextval('teams_id_seq'::regclass);


--
-- Name: h2h_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY h2h_matches
    ADD CONSTRAINT h2h_matches_pkey PRIMARY KEY (id);


--
-- Name: managers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY managers
    ADD CONSTRAINT managers_pkey PRIMARY KEY (id);


--
-- Name: matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: players_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130825124819');

INSERT INTO schema_migrations (version) VALUES ('20130825125254');

INSERT INTO schema_migrations (version) VALUES ('20130825132201');

INSERT INTO schema_migrations (version) VALUES ('20130825132433');

INSERT INTO schema_migrations (version) VALUES ('20130825132813');
