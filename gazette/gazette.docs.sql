--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = gazette, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: docs; Type: TABLE; Schema: gazette; Owner: opengov; Tablespace: 
--

CREATE TABLE docs (
    gazdate date NOT NULL,
    vol smallint NOT NULL,
    no smallint NOT NULL,
    extra boolean NOT NULL,
    typeid smallint NOT NULL,
    typedesc character varying(64),
    section character varying(128),
    rev date,
    notice_no integer,
    subject text,
    dept character varying(256),
    deptemail character varying(64),
    officer character varying(256),
    groupdesc character varying(512),
    classification character varying(1024),
    link character varying(512) NOT NULL,
    dbinserted timestamp without time zone DEFAULT now() NOT NULL,
    dbupdated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE gazette.docs OWNER TO opengov;

--
-- Name: link; Type: CONSTRAINT; Schema: gazette; Owner: opengov; Tablespace: 
--

ALTER TABLE ONLY docs
    ADD CONSTRAINT link PRIMARY KEY (link);


--
-- PostgreSQL database dump complete
--

