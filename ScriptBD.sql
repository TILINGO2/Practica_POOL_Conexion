--
-- PostgreSQL database dump
--

\restrict gKhRfxaMk2JyhGWMu30nOfvAnOf4PEngLDwNI1B46OdnCzRtg9TugoueGUuEoSm

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-07-07 21:06:02

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16464)
-- Name: cuentas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cuentas (
    id integer NOT NULL,
    propietario character varying(50),
    saldo numeric(10,2)
);


ALTER TABLE public.cuentas OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16463)
-- Name: cuentas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cuentas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cuentas_id_seq OWNER TO postgres;

--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 219
-- Name: cuentas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cuentas_id_seq OWNED BY public.cuentas.id;


--
-- TOC entry 228 (class 1259 OID 16497)
-- Name: detalle_pedido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_pedido (
    id integer NOT NULL,
    pedido_id integer,
    producto character varying(50),
    cantidad integer
);


ALTER TABLE public.detalle_pedido OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16496)
-- Name: detalle_pedido_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.detalle_pedido_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detalle_pedido_id_seq OWNER TO postgres;

--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 227
-- Name: detalle_pedido_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.detalle_pedido_id_seq OWNED BY public.detalle_pedido.id;


--
-- TOC entry 226 (class 1259 OID 16489)
-- Name: pedido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedido (
    id integer NOT NULL,
    cliente character varying(50)
);


ALTER TABLE public.pedido OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16488)
-- Name: pedido_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pedido_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pedido_id_seq OWNER TO postgres;

--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 225
-- Name: pedido_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedido_id_seq OWNED BY public.pedido.id;


--
-- TOC entry 222 (class 1259 OID 16472)
-- Name: reservas_hotel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservas_hotel (
    id integer NOT NULL,
    cliente character varying(50),
    estado character varying(20)
);


ALTER TABLE public.reservas_hotel OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16471)
-- Name: reservas_hotel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservas_hotel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservas_hotel_id_seq OWNER TO postgres;

--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 221
-- Name: reservas_hotel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservas_hotel_id_seq OWNED BY public.reservas_hotel.id;


--
-- TOC entry 224 (class 1259 OID 16480)
-- Name: reservas_vuelo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservas_vuelo (
    id integer NOT NULL,
    cliente character varying(50),
    estado character varying(20)
);


ALTER TABLE public.reservas_vuelo OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16479)
-- Name: reservas_vuelo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservas_vuelo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservas_vuelo_id_seq OWNER TO postgres;

--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 223
-- Name: reservas_vuelo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservas_vuelo_id_seq OWNED BY public.reservas_vuelo.id;


--
-- TOC entry 4876 (class 2604 OID 16467)
-- Name: cuentas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cuentas ALTER COLUMN id SET DEFAULT nextval('public.cuentas_id_seq'::regclass);


--
-- TOC entry 4880 (class 2604 OID 16500)
-- Name: detalle_pedido id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_pedido ALTER COLUMN id SET DEFAULT nextval('public.detalle_pedido_id_seq'::regclass);


--
-- TOC entry 4879 (class 2604 OID 16492)
-- Name: pedido id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido ALTER COLUMN id SET DEFAULT nextval('public.pedido_id_seq'::regclass);


--
-- TOC entry 4877 (class 2604 OID 16475)
-- Name: reservas_hotel id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservas_hotel ALTER COLUMN id SET DEFAULT nextval('public.reservas_hotel_id_seq'::regclass);


--
-- TOC entry 4878 (class 2604 OID 16483)
-- Name: reservas_vuelo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservas_vuelo ALTER COLUMN id SET DEFAULT nextval('public.reservas_vuelo_id_seq'::regclass);


--
-- TOC entry 4882 (class 2606 OID 16470)
-- Name: cuentas cuentas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cuentas
    ADD CONSTRAINT cuentas_pkey PRIMARY KEY (id);


--
-- TOC entry 4890 (class 2606 OID 16503)
-- Name: detalle_pedido detalle_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT detalle_pedido_pkey PRIMARY KEY (id);


--
-- TOC entry 4888 (class 2606 OID 16495)
-- Name: pedido pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (id);


--
-- TOC entry 4884 (class 2606 OID 16478)
-- Name: reservas_hotel reservas_hotel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservas_hotel
    ADD CONSTRAINT reservas_hotel_pkey PRIMARY KEY (id);


--
-- TOC entry 4886 (class 2606 OID 16486)
-- Name: reservas_vuelo reservas_vuelo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservas_vuelo
    ADD CONSTRAINT reservas_vuelo_pkey PRIMARY KEY (id);


--
-- TOC entry 4891 (class 2606 OID 16504)
-- Name: detalle_pedido detalle_pedido_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT detalle_pedido_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedido(id);


-- Completed on 2026-07-07 21:06:02

--
-- PostgreSQL database dump complete
--

\unrestrict gKhRfxaMk2JyhGWMu30nOfvAnOf4PEngLDwNI1B46OdnCzRtg9TugoueGUuEoSm

