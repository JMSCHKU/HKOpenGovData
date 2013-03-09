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
-- Name: pdfs; Type: TABLE; Schema: gazette; Owner: opengov; Tablespace: 
--

CREATE TABLE pdfs (
    link character varying(512) NOT NULL,
    filename character varying(128) NOT NULL,
    filehash character varying(32) NOT NULL,
    dbinserted timestamp without time zone DEFAULT now() NOT NULL,
    dbupdated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE gazette.pdfs OWNER TO opengov;

--
-- Name: link_filename_filehash; Type: CONSTRAINT; Schema: gazette; Owner: opengov; Tablespace: 
--

ALTER TABLE ONLY pdfs
    ADD CONSTRAINT link_filename_filehash PRIMARY KEY (link, filename, filehash);


--
-- PostgreSQL database dump complete
--

