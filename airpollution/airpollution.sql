--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = epd, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: airpollution; Type: TABLE; Schema: epd; Owner: opengov; Tablespace: 
--

CREATE TABLE airpollution (
    region character varying(32) NOT NULL,
    snapshot character varying(16) NOT NULL,
    recorded timestamp without time zone NOT NULL,
    no2 numeric,
    o3 numeric,
    so2 numeric,
    co numeric,
    rsp numeric,
    fsp numeric
);


ALTER TABLE epd.airpollution OWNER TO opengov;

--
-- Name: airpollution_pkey; Type: CONSTRAINT; Schema: epd; Owner: opengov; Tablespace: 
--

ALTER TABLE ONLY airpollution
    ADD CONSTRAINT airpollution_pkey PRIMARY KEY (region, recorded, snapshot);


--
-- PostgreSQL database dump complete
--

