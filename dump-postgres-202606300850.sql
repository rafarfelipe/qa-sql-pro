--
-- PostgreSQL database dump
--

\restrict p2OU1l1nkDYlvrUIcvxyeZiSnPoHjsTHd3Jbc957XdB7JLP0STZCoXdt1xMZ9es

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.10

-- Started on 2026-06-30 08:50:48

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
-- TOC entry 73 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- TOC entry 4050 (class 0 OID 0)
-- Dependencies: 73
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 501 (class 1255 OID 17873)
-- Name: generate_order_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_order_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.order_number = 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(NEW.id::TEXT, 6, '0');
  RETURN NEW;
END;
$$;


--
-- TOC entry 503 (class 1255 OID 17877)
-- Name: log_order_status_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_order_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF TG_OP = 'INSERT' OR OLD.status != NEW.status THEN
    INSERT INTO order_history (order_id, status, notes)
    VALUES (NEW.id, NEW.status, 'Status atualizado');
  END IF;
  RETURN NEW;
END;
$$;


--
-- TOC entry 502 (class 1255 OID 17875)
-- Name: update_product_rating(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_product_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE products
  SET 
    rating = (SELECT AVG(rating)::NUMERIC(3,2) FROM reviews WHERE product_id = NEW.product_id AND is_approved = true),
    reviews_count = (SELECT COUNT(*) FROM reviews WHERE product_id = NEW.product_id AND is_approved = true)
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$;


--
-- TOC entry 500 (class 1255 OID 17863)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 370 (class 1259 OID 19381)
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    user_id uuid,
    address_type character varying(20) DEFAULT 'shipping'::character varying,
    label character varying(100),
    street text NOT NULL,
    number character varying(20),
    complement character varying(100),
    neighborhood character varying(100),
    city character varying(100) NOT NULL,
    state character varying(2) NOT NULL,
    zip_code character varying(10) NOT NULL,
    country character varying(100) DEFAULT 'Brazil'::character varying,
    is_default boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT addresses_address_type_check CHECK (((address_type)::text = ANY ((ARRAY['shipping'::character varying, 'billing'::character varying, 'both'::character varying])::text[])))
);


--
-- TOC entry 369 (class 1259 OID 19380)
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4051 (class 0 OID 0)
-- Dependencies: 369
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- TOC entry 394 (class 1259 OID 19662)
-- Name: cart_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    user_id uuid,
    product_id integer,
    quantity integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT cart_items_quantity_check CHECK ((quantity > 0))
);


--
-- TOC entry 393 (class 1259 OID 19661)
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4052 (class 0 OID 0)
-- Dependencies: 393
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- TOC entry 372 (class 1259 OID 19401)
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    image_url character varying(500),
    icon character varying(50),
    display_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


--
-- TOC entry 371 (class 1259 OID 19400)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4053 (class 0 OID 0)
-- Dependencies: 371
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 380 (class 1259 OID 19484)
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    description text,
    discount_type character varying(20),
    discount_value numeric(10,2) NOT NULL,
    min_purchase_amount numeric(10,2),
    max_discount_amount numeric(10,2),
    usage_limit integer,
    used_count integer DEFAULT 0,
    valid_from timestamp with time zone,
    valid_until timestamp with time zone,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT coupons_discount_type_check CHECK (((discount_type)::text = ANY ((ARRAY['percentage'::character varying, 'fixed'::character varying])::text[])))
);


--
-- TOC entry 379 (class 1259 OID 19483)
-- Name: coupons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.coupons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4054 (class 0 OID 0)
-- Dependencies: 379
-- Name: coupons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.coupons_id_seq OWNED BY public.coupons.id;


--
-- TOC entry 368 (class 1259 OID 19357)
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    user_id uuid,
    employee_code character varying(20) NOT NULL,
    department character varying(100),
    "position" character varying(100),
    salary numeric(10,2),
    hire_date date NOT NULL,
    reports_to integer,
    is_active boolean DEFAULT true,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- TOC entry 367 (class 1259 OID 19356)
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4055 (class 0 OID 0)
-- Dependencies: 367
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- TOC entry 396 (class 1259 OID 48513)
-- Name: keepalive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.keepalive (
    id integer NOT NULL,
    last_ping timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 397 (class 1259 OID 49640)
-- Name: keepalive_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.keepalive ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.keepalive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 386 (class 1259 OID 19567)
-- Name: order_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_history (
    id integer NOT NULL,
    order_id integer,
    status character varying(20) NOT NULL,
    notes text,
    changed_by uuid,
    created_at timestamp with time zone DEFAULT now()
);


--
-- TOC entry 385 (class 1259 OID 19566)
-- Name: order_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4056 (class 0 OID 0)
-- Dependencies: 385
-- Name: order_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_history_id_seq OWNED BY public.order_history.id;


--
-- TOC entry 384 (class 1259 OID 19545)
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0,
    subtotal numeric(10,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


--
-- TOC entry 383 (class 1259 OID 19544)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4057 (class 0 OID 0)
-- Dependencies: 383
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 382 (class 1259 OID 19500)
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    user_id uuid,
    order_number character varying(50) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    subtotal numeric(10,2) NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0,
    shipping_cost numeric(10,2) DEFAULT 0,
    tax_amount numeric(10,2) DEFAULT 0,
    total_amount numeric(10,2) NOT NULL,
    coupon_id integer,
    shipper_id integer,
    shipping_address_id integer,
    billing_address_id integer,
    tracking_number character varying(100),
    estimated_delivery date,
    delivered_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'processing'::character varying, 'shipped'::character varying, 'delivered'::character varying, 'cancelled'::character varying, 'refunded'::character varying])::text[])))
);


--
-- TOC entry 381 (class 1259 OID 19499)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4058 (class 0 OID 0)
-- Dependencies: 381
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 388 (class 1259 OID 19588)
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    order_id integer,
    payment_method character varying(50) NOT NULL,
    payment_status character varying(20) DEFAULT 'pending'::character varying,
    amount numeric(10,2) NOT NULL,
    transaction_id character varying(255),
    payment_date timestamp with time zone,
    card_last_digits character varying(4),
    installments integer DEFAULT 1,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payments_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['credit_card'::character varying, 'debit_card'::character varying, 'pix'::character varying, 'boleto'::character varying, 'paypal'::character varying])::text[]))),
    CONSTRAINT payments_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'paid'::character varying, 'failed'::character varying, 'refunded'::character varying, 'cancelled'::character varying])::text[])))
);


--
-- TOC entry 387 (class 1259 OID 19587)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4059 (class 0 OID 0)
-- Dependencies: 387
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- TOC entry 376 (class 1259 OID 19432)
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    category_id integer,
    supplier_id integer,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    short_description character varying(500),
    price numeric(10,2) NOT NULL,
    cost_price numeric(10,2),
    stock_quantity integer DEFAULT 0,
    reorder_level integer DEFAULT 10,
    image_url character varying(500),
    sku character varying(50) NOT NULL,
    barcode character varying(50),
    weight numeric(10,3),
    is_active boolean DEFAULT true,
    is_featured boolean DEFAULT false,
    discount_percentage numeric(5,2) DEFAULT 0,
    rating numeric(3,2) DEFAULT 0,
    reviews_count integer DEFAULT 0,
    views_count integer DEFAULT 0,
    sales_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT products_discount_percentage_check CHECK (((discount_percentage >= (0)::numeric) AND (discount_percentage <= (100)::numeric))),
    CONSTRAINT products_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT products_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric))),
    CONSTRAINT products_stock_quantity_check CHECK ((stock_quantity >= 0))
);


--
-- TOC entry 375 (class 1259 OID 19431)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4060 (class 0 OID 0)
-- Dependencies: 375
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- TOC entry 390 (class 1259 OID 19608)
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    product_id integer,
    user_id uuid,
    order_id integer,
    rating integer NOT NULL,
    title character varying(255),
    comment text,
    is_verified_purchase boolean DEFAULT false,
    is_approved boolean DEFAULT false,
    helpful_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- TOC entry 389 (class 1259 OID 19607)
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4061 (class 0 OID 0)
-- Dependencies: 389
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- TOC entry 378 (class 1259 OID 19473)
-- Name: shippers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shippers (
    id integer NOT NULL,
    company_name character varying(255) NOT NULL,
    phone character varying(20),
    email character varying(255),
    website character varying(500),
    delivery_time_days integer,
    tracking_url character varying(500),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


--
-- TOC entry 377 (class 1259 OID 19472)
-- Name: shippers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shippers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4062 (class 0 OID 0)
-- Dependencies: 377
-- Name: shippers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shippers_id_seq OWNED BY public.shippers.id;


--
-- TOC entry 374 (class 1259 OID 19416)
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    id integer NOT NULL,
    company_name character varying(255) NOT NULL,
    contact_name character varying(255),
    contact_title character varying(100),
    email character varying(255),
    phone character varying(20),
    cnpj character varying(18),
    street text,
    city character varying(100),
    state character varying(2),
    zip_code character varying(10),
    country character varying(100) DEFAULT 'Brazil'::character varying,
    website character varying(500),
    rating numeric(3,2) DEFAULT 0,
    is_active boolean DEFAULT true,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- TOC entry 373 (class 1259 OID 19415)
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suppliers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4063 (class 0 OID 0)
-- Dependencies: 373
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- TOC entry 366 (class 1259 OID 19336)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    birth_date date,
    phone character varying(20),
    cpf character varying(14),
    gender character varying(20),
    is_active boolean DEFAULT true,
    role character varying(20) DEFAULT 'customer'::character varying,
    access_code character varying(50),
    last_login timestamp with time zone,
    email_verified boolean DEFAULT false,
    avatar_url character varying(500),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['customer'::character varying, 'admin'::character varying])::text[])))
);


--
-- TOC entry 392 (class 1259 OID 19639)
-- Name: wishlists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wishlists (
    id integer NOT NULL,
    user_id uuid,
    product_id integer,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- TOC entry 391 (class 1259 OID 19638)
-- Name: wishlists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wishlists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4064 (class 0 OID 0)
-- Dependencies: 391
-- Name: wishlists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wishlists_id_seq OWNED BY public.wishlists.id;


--
-- TOC entry 3684 (class 2604 OID 19384)
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- TOC entry 3739 (class 2604 OID 19665)
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- TOC entry 3689 (class 2604 OID 19404)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 3713 (class 2604 OID 19487)
-- Name: coupons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons ALTER COLUMN id SET DEFAULT nextval('public.coupons_id_seq'::regclass);


--
-- TOC entry 3681 (class 2604 OID 19360)
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- TOC entry 3726 (class 2604 OID 19570)
-- Name: order_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_history ALTER COLUMN id SET DEFAULT nextval('public.order_history_id_seq'::regclass);


--
-- TOC entry 3723 (class 2604 OID 19548)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 3717 (class 2604 OID 19503)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 3728 (class 2604 OID 19591)
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- TOC entry 3698 (class 2604 OID 19435)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 3732 (class 2604 OID 19611)
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- TOC entry 3710 (class 2604 OID 19476)
-- Name: shippers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shippers ALTER COLUMN id SET DEFAULT nextval('public.shippers_id_seq'::regclass);


--
-- TOC entry 3693 (class 2604 OID 19419)
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- TOC entry 3737 (class 2604 OID 19642)
-- Name: wishlists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists ALTER COLUMN id SET DEFAULT nextval('public.wishlists_id_seq'::regclass);


--
-- TOC entry 4018 (class 0 OID 19381)
-- Dependencies: 370
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.addresses VALUES (1, 'c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'both', NULL, 'Rua das Flores', '123', NULL, NULL, 'São Paulo', 'SP', '01310-100', 'Brazil', true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.addresses VALUES (2, '5efbb6a1-3c2e-4f71-8939-a1bcb5e5e7d4', 'both', NULL, 'Rua Copacabana', '567', NULL, NULL, 'Rio de Janeiro', 'RJ', '22020-010', 'Brazil', true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.addresses VALUES (3, '9a98ee38-14dd-418f-b5ef-414c38abea03', 'both', NULL, 'Av Paulista', '1000', NULL, NULL, 'São Paulo', 'SP', '01310-200', 'Brazil', true, '2025-11-22 19:13:30.023236+00');


--
-- TOC entry 4042 (class 0 OID 19662)
-- Dependencies: 394
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cart_items VALUES (3, NULL, 273, 2, '2026-04-19 00:37:10.969427+00');
INSERT INTO public.cart_items VALUES (4, NULL, 273, 1, '2026-04-19 00:37:10.969427+00');
INSERT INTO public.cart_items VALUES (12, '9a98ee38-14dd-418f-b5ef-414c38abea03', 762, 1, '2026-06-21 18:32:43.034439+00');
INSERT INTO public.cart_items VALUES (13, '9a98ee38-14dd-418f-b5ef-414c38abea03', 222, 7, '2026-06-28 00:10:58.382867+00');


--
-- TOC entry 4020 (class 0 OID 19401)
-- Dependencies: 372
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories VALUES (89, 'Categoria Slug Teste 1777820803963', 'categoria-slug-teste-1777820803963', 'Descricao Slug 1777820803963', NULL, NULL, 0, true, '2026-05-03 15:06:43.806042+00');
INSERT INTO public.categories VALUES (2, 'Livros', 'livros', 'Literatura e técnicos', NULL, 'menu_book', 2, true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.categories VALUES (3, 'Roupas', 'roupas', 'Moda em geral', NULL, 'checkroom', 3, true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.categories VALUES (6, 'Esportes', 'esportes', 'Artigos esportivos e fitness', NULL, 'sports_soccer', 6, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (5, 'Casa&Cozinha', 'casa-e-cozinha', 'Produtos eletrônicos variados', NULL, 'kitchen', 5, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (91, 'Categoria Atualizar 1777821092766', 'categoria-atualizar-1777821092766', 'Descricao Atualizar 1777821092766', NULL, NULL, 0, true, '2026-05-03 15:11:32.57319+00');
INSERT INTO public.categories VALUES (93, 'Categoria Atualizar 1777822225215', 'categoria-atualizar-1777822225215', 'Descricao Atualizar 1777822225215', NULL, NULL, 0, true, '2026-05-03 15:30:24.956638+00');
INSERT INTO public.categories VALUES (11, 'Pets', 'pets', 'Produtos para animais de estimação', NULL, 'pets', 11, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (12, 'Móveis', 'moveis', 'Móveis e decoração', NULL, 'weekend', 12, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (13, 'Games', 'games', 'Videogames, consoles e acessórios', NULL, 'sports_esports', 13, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (20, 'Eletrônicos uteis', 'eletronicos-uteis', 'Produtos eletrônicos variados', NULL, NULL, 0, true, '2026-01-31 17:09:47.802654+00');
INSERT INTO public.categories VALUES (180, 'Categoria 1777853577756', 'categoria-1777853577756', 'Descricao 1777853577756', NULL, NULL, 0, true, '2026-05-04 00:12:57.034472+00');
INSERT INTO public.categories VALUES (264, 'Categoria 1778031414645', 'categoria-1778031414645', 'Descricao 1778031414645', NULL, NULL, 0, true, '2026-05-06 01:36:54.782101+00');
INSERT INTO public.categories VALUES (463, 'Jr.', 'jr.', 'inventore', NULL, NULL, 0, true, '2026-05-25 01:01:47.488221+00');
INSERT INTO public.categories VALUES (9, 'Eletrônicos7', 'informatica', 'Produtos eletrônicos variados', NULL, 'memory', 9, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (99, 'Categoria 1777826024292', 'categoria-1777826024292', 'Descricao 1777826024292', NULL, NULL, 0, true, '2026-05-03 16:33:43.860345+00');
INSERT INTO public.categories VALUES (101, 'Categoria 1777826040367', 'categoria-1777826040367', 'Descricao 1777826040367', NULL, NULL, 0, true, '2026-05-03 16:33:59.902647+00');
INSERT INTO public.categories VALUES (148, 'Categoria 1777847364534', 'categoria-1777847364534', 'Descricao 1777847364534', NULL, NULL, 0, true, '2026-05-03 22:29:24.151317+00');
INSERT INTO public.categories VALUES (10, 'Eletrônicos visuais', 'eletronicos-visuais', 'Produtos eletrônicos variados por patch', NULL, 'directions_car', 10, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (103, 'Categoria Alterado 949', 'categoria-slug-949', 'Descricao Slug 1777826040995', NULL, NULL, 0, true, '2026-05-03 16:34:00.519122+00');
INSERT INTO public.categories VALUES (19, 'Eletrônicos Portateisfff', 'eletronicos-portateis', 'Produtos eletrônicos variados', NULL, NULL, 0, true, '2026-01-31 01:44:57.461237+00');
INSERT INTO public.categories VALUES (4, 'Eletrônicos Triplode', 'acessorios', 'Produtos eeletrônicos variados', NULL, 'extension', 4, true, '2025-11-27 18:26:17.91015+00');
INSERT INTO public.categories VALUES (108, 'Categoria Alterado 990', 'categoria-slug-990', 'Descricao Slug 1777826801977', NULL, NULL, 0, true, '2026-05-03 16:46:41.518898+00');
INSERT INTO public.categories VALUES (189, 'Categoria 1777853819150', 'categoria-1777853819150', 'Descricao 1777853819150', NULL, NULL, 0, true, '2026-05-04 00:16:58.562798+00');
INSERT INTO public.categories VALUES (26, 'EletrônicosAVC', 'eletrônicosavc', 'Produtos eletrônicos variados', NULL, NULL, 0, true, '2026-04-26 22:29:01.741956+00');
INSERT INTO public.categories VALUES (268, 'Categoria 1778031491848', 'categoria-1778031491848', 'Descricao 1778031491848', NULL, NULL, 0, true, '2026-05-06 01:38:11.956831+00');
INSERT INTO public.categories VALUES (114, 'Categoria 1777833077471', 'categoria-1777833077471', 'Descricao 1777833077471', NULL, NULL, 0, true, '2026-05-03 18:31:16.63164+00');
INSERT INTO public.categories VALUES (118, 'Categoria 1777833530714', 'categoria-1777833530714', 'Descricao 1777833530714', NULL, NULL, 0, true, '2026-05-03 18:38:49.811134+00');
INSERT INTO public.categories VALUES (121, 'Categoria Alterado 88', 'categoria-slug-88', 'Descricao Slug 1777833531640', NULL, NULL, 0, true, '2026-05-03 18:38:50.74158+00');
INSERT INTO public.categories VALUES (123, 'Categoria 1777835473939', 'categoria-1777835473939', 'Descricao 1777835473939', NULL, NULL, 0, true, '2026-05-03 19:11:12.944105+00');
INSERT INTO public.categories VALUES (126, 'Categoria Alterado 996', 'categoria-slug-996', 'Descricao Slug 1777835474783', NULL, NULL, 0, true, '2026-05-03 19:11:13.876769+00');
INSERT INTO public.categories VALUES (128, 'Categoria 1777838818336', 'categoria-1777838818336', 'Descricao 1777838818336', NULL, NULL, 0, true, '2026-05-03 20:06:58.438247+00');
INSERT INTO public.categories VALUES (200, 'Categoria 1777854207552', 'categoria-1777854207552', 'Descricao 1777854207552', NULL, NULL, 0, true, '2026-05-04 00:23:26.959787+00');
INSERT INTO public.categories VALUES (272, 'Categoria 1778031522167', 'categoria-1778031522167', 'Descricao 1778031522167', NULL, NULL, 0, true, '2026-05-06 01:38:42.26789+00');
INSERT INTO public.categories VALUES (153, 'Categoria 1777847460392', 'categoria-1777847460392', 'Descricao 1777847460392', NULL, NULL, 0, true, '2026-05-03 22:31:00.063147+00');
INSERT INTO public.categories VALUES (131, 'Categoria Alterado 539', 'categoria-slug-539', 'Descricao Slug 1777838826625', NULL, NULL, 0, true, '2026-05-03 20:07:06.719965+00');
INSERT INTO public.categories VALUES (132, 'Categoria Alterado 892', 'categoria-slug-892', 'Descricao Slug 1777838827950', NULL, NULL, 0, true, '2026-05-03 20:07:08.04448+00');
INSERT INTO public.categories VALUES (133, 'Categoria Alterado 826', 'categoria-slug-826', 'Descricao Slug 1777838829267', NULL, NULL, 0, true, '2026-05-03 20:07:09.373196+00');
INSERT INTO public.categories VALUES (292, 'Categoria 1778034213614', 'categoria-1778034213614', 'Descricao 1778034213614', NULL, NULL, 0, true, '2026-05-06 02:23:33.776499+00');
INSERT INTO public.categories VALUES (280, 'Categoria 1778032070850', 'categoria-1778032070850', 'Descricao 1778032070850', NULL, NULL, 0, true, '2026-05-06 01:47:50.944679+00');
INSERT INTO public.categories VALUES (160, 'Categoria 1777850684045', 'categoria-1777850684045', 'Descricao 1777850684045', NULL, NULL, 0, true, '2026-05-03 23:24:43.502461+00');
INSERT INTO public.categories VALUES (212, 'Categoria 1777855660372', 'categoria-1777855660372', 'Descricao 1777855660372', NULL, NULL, 0, true, '2026-05-04 00:47:39.521053+00');
INSERT INTO public.categories VALUES (220, 'Categoria 1777860195446', 'categoria-1777860195446', 'Descricao 1777860195446', NULL, NULL, 0, true, '2026-05-04 02:03:15.586428+00');
INSERT INTO public.categories VALUES (284, 'Categoria 1778032636165', 'categoria-1778032636165', 'Descricao 1778032636165', NULL, NULL, 0, true, '2026-05-06 01:57:16.311107+00');
INSERT INTO public.categories VALUES (169, 'Categoria 1777850894936', 'categoria-1777850894936', 'Descricao 1777850894936', NULL, NULL, 0, true, '2026-05-03 23:28:14.350699+00');
INSERT INTO public.categories VALUES (172, 'Categoria 1777851120923', 'categoria-1777851120923', 'Descricao 1777851120923', NULL, NULL, 0, true, '2026-05-03 23:32:01.056275+00');
INSERT INTO public.categories VALUES (288, 'Categoria 1778032814498', 'categoria-1778032814498', 'Descricao 1778032814498', NULL, NULL, 0, true, '2026-05-06 02:00:14.651957+00');
INSERT INTO public.categories VALUES (228, 'Categoria 1777860750158', 'categoria-1777860750158', 'Descricao 1777860750158', NULL, NULL, 0, true, '2026-05-04 02:12:29.006086+00');
INSERT INTO public.categories VALUES (296, 'Categoria 1778035292701', 'categoria-1778035292701', 'Descricao 1778035292701', NULL, NULL, 0, true, '2026-05-06 02:41:32.805489+00');
INSERT INTO public.categories VALUES (300, 'Categoria 1778208128793', 'categoria-1778208128793', 'Descricao 1778208128793', NULL, NULL, 0, true, '2026-05-08 02:42:08.959251+00');
INSERT INTO public.categories VALUES (326, 'rrrr', 'rrrr', 'rrrrr', NULL, NULL, 0, true, '2026-05-23 18:36:46.136586+00');
INSERT INTO public.categories VALUES (307, 'Eletrônicosd', 'eletrônicosd', 'Produtos eletdrônicos variados', NULL, NULL, 0, true, '2026-05-20 23:59:46.084979+00');
INSERT INTO public.categories VALUES (310, 'Eletrônicostrn', 'eletrônicostrn', 'Prodnurttos eletrônicos variados', NULL, NULL, 0, true, '2026-05-21 00:03:46.60139+00');
INSERT INTO public.categories VALUES (312, 'Cummings', 'cummings', 'Rubber circuit', NULL, NULL, 0, true, '2026-05-21 00:08:06.957889+00');
INSERT INTO public.categories VALUES (322, 'Heidenreich', 'heidenreich', 'Shirt deposit Savings parse', NULL, NULL, 0, true, '2026-05-22 11:59:05.332081+00');
INSERT INTO public.categories VALUES (256, 'Categoria 1778030711822', 'categoria-1778030711822', 'Descricao 1778030711822', NULL, NULL, 0, true, '2026-05-06 01:25:11.967472+00');
INSERT INTO public.categories VALUES (330, 'rrrrr', 'rrrrr', 'rrrrrrrrrrrrrrrrr', NULL, NULL, 0, true, '2026-05-23 18:45:23.296112+00');
INSERT INTO public.categories VALUES (332, 'Informática e Acessórrios', 'informática-e-acessórrios', 'Produtos de tecnoalogia, periféricos e itens para computadores', NULL, NULL, 0, true, '2026-05-23 19:02:06.999127+00');
INSERT INTO public.categories VALUES (334, 'Móveis para Escrritório', 'móveis-para-escrritório', 'Itens ergonômicaos e funcionais para ambientes corporativos', NULL, NULL, 0, true, '2026-05-23 19:02:08.674577+00');
INSERT INTO public.categories VALUES (335, 'Decoração e Utilidadesr', 'decoração-e-utilidadesr', 'Objetos decorataivos e utilidades para ambientes internos', NULL, NULL, 0, true, '2026-05-23 19:02:09.449085+00');
INSERT INTO public.categories VALUES (90, 'Categoria Slug Teste 1777821037389', 'categoria-slug-teste-1777821037389', 'Descricao Slug 1777821037389', NULL, NULL, 0, true, '2026-05-03 15:10:37.199095+00');
INSERT INTO public.categories VALUES (92, 'Categoria Atualizar 1777821192681', 'categoria-atualizar-1777821192681', 'Descricao Atualizar 1777821192681', NULL, NULL, 0, true, '2026-05-03 15:13:12.487401+00');
INSERT INTO public.categories VALUES (94, 'Categoria 1777823486675', 'categoria-1777823486675', 'Descricao 1777823486675', NULL, NULL, 0, true, '2026-05-03 15:51:26.3683+00');
INSERT INTO public.categories VALUES (97, 'Categoria Alterado 793', 'categoria-slug-793', 'Descricao Slug 1777823487642', NULL, NULL, 0, true, '2026-05-03 15:51:27.317614+00');
INSERT INTO public.categories VALUES (441, 'Eletrônicoss de Uso Diário', 'eletrônicoss-de-uso-diário', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:00.234518+00');
INSERT INTO public.categories VALUES (185, 'Categoria 1777853735186', 'categoria-1777853735186', 'Descricao 1777853735186', NULL, NULL, 0, true, '2026-05-04 00:15:34.451997+00');
INSERT INTO public.categories VALUES (106, 'Categoria 1777826800835', 'categoria-1777826800835', 'Descricao 1777826800835', NULL, NULL, 0, true, '2026-05-03 16:46:40.328461+00');
INSERT INTO public.categories VALUES (224, 'Categoria 1777860655680', 'categoria-1777860655680', 'Descricao 1777860655680', NULL, NULL, 0, true, '2026-05-04 02:10:55.775047+00');
INSERT INTO public.categories VALUES (50, 'Categoria 1777427878651', 'categoria-1777427878651', 'Descricao 1777427878651', NULL, NULL, 0, true, '2026-04-29 01:57:58.660887+00');
INSERT INTO public.categories VALUES (51, 'Categoria 1777427882670', 'categoria-1777427882670', 'Descricao 1777427882670', NULL, NULL, 0, true, '2026-04-29 01:58:02.663319+00');
INSERT INTO public.categories VALUES (52, 'Categoria 1777427890440', 'categoria-1777427890440', 'Descricao 1777427890440', NULL, NULL, 0, true, '2026-04-29 01:58:10.441661+00');
INSERT INTO public.categories VALUES (277, 'Categoria 1778031854158', 'categoria-1778031854158', 'Descricao 1778031854158', NULL, NULL, 0, true, '2026-05-06 01:44:13.959399+00');
INSERT INTO public.categories VALUES (111, 'Categoria 1777828222942', 'categoria-1777828222942', 'Descricao 1777828222942', NULL, NULL, 0, true, '2026-05-03 17:10:22.384725+00');
INSERT INTO public.categories VALUES (58, 'Categoria 1777428263093', 'categoria-1777428263093', 'Descricao 1777428263093', NULL, NULL, 0, true, '2026-04-29 02:04:23.093423+00');
INSERT INTO public.categories VALUES (115, 'Categoria Alterado 666', 'categoria-slug-666', 'Descricao Slug 1777833078399', NULL, NULL, 0, true, '2026-05-03 18:31:17.534629+00');
INSERT INTO public.categories VALUES (192, 'Categoria 1777853937855', 'categoria-1777853937855', 'Descricao 1777853937855', NULL, NULL, 0, true, '2026-05-04 00:18:57.295542+00');
INSERT INTO public.categories VALUES (61, 'Eletrônicos', 'eletrônicos', 'Produtos eletrônicos variados', NULL, NULL, 0, true, '2026-05-01 01:18:02.798076+00');
INSERT INTO public.categories VALUES (64, 'Categoria 1777602855890', 'categoria-1777602855890', 'Descricao 1777602855890', NULL, NULL, 0, true, '2026-05-01 02:34:16.022669+00');
INSERT INTO public.categories VALUES (308, 'Eletrônicosrn', 'eletrônicosrn', 'Prodnurtos eletrônicos variados', NULL, NULL, 0, true, '2026-05-21 00:02:36.836733+00');
INSERT INTO public.categories VALUES (66, 'Eletrôniceros', 'eletrôniceros', 'Produertos eletrônicos variados', NULL, NULL, 0, true, '2026-05-01 02:40:52.255997+00');
INSERT INTO public.categories VALUES (197, 'Categoria 1777854020509', 'categoria-1777854020509', 'Descricao 1777854020509', NULL, NULL, 0, true, '2026-05-04 00:20:19.859342+00');
INSERT INTO public.categories VALUES (68, 'Categoria HAR', 'categoria-har', 'Teste via HAR', NULL, NULL, 0, true, '2026-05-01 03:01:20.62953+00');
INSERT INTO public.categories VALUES (156, 'Categoria 1777849101619', 'categoria-1777849101619', 'Descricao 1777849101619', NULL, NULL, 0, true, '2026-05-03 22:58:21.15709+00');
INSERT INTO public.categories VALUES (71, 'Noba Teste Everton', 'noba-teste-everton', 'Noba Teste Everton', NULL, NULL, 0, true, '2026-05-01 17:20:54.181059+00');
INSERT INTO public.categories VALUES (72, 'Eletrônicos HAR', 'eletrônicos-har', 'Produtos eletrônicos variados HAR', NULL, NULL, 0, true, '2026-05-01 18:43:25.75446+00');
INSERT INTO public.categories VALUES (74, 'Categoria 1777765754856', 'categoria-1777765754856', 'Descricao 1777765754856', NULL, NULL, 0, true, '2026-05-02 23:49:13.605145+00');
INSERT INTO public.categories VALUES (135, 'Categoria 1777846430464', 'categoria-1777846430464', 'Descricao 1777846430464', NULL, NULL, 0, true, '2026-05-03 22:13:50.314844+00');
INSERT INTO public.categories VALUES (204, 'Categoria 1777854259148', 'categoria-1777854259148', 'Descricao 1777854259148', NULL, NULL, 0, true, '2026-05-04 00:24:18.376501+00');
INSERT INTO public.categories VALUES (78, 'Categoria 1777766228950', 'categoria-1777766228950', 'Descricao 1777766228950', NULL, NULL, 0, true, '2026-05-02 23:57:07.730907+00');
INSERT INTO public.categories VALUES (81, 'Categoria 1777766533130', 'categoria-1777766533130', 'Descricao 1777766533130', NULL, NULL, 0, true, '2026-05-03 00:02:11.863484+00');
INSERT INTO public.categories VALUES (138, 'Categoria Alterado 548', 'categoria-slug-548', 'Descricao Slug 1777846475046', NULL, NULL, 0, true, '2026-05-03 22:14:34.723771+00');
INSERT INTO public.categories VALUES (84, 'Eletrônicos4', 'eletrônicos4', 'Produtos eletrônicos variados', NULL, NULL, 0, true, '2026-05-03 13:38:17.494938+00');
INSERT INTO public.categories VALUES (140, 'Categoria 1777846780469', 'categoria-1777846780469', 'Descricao 1777846780469', NULL, NULL, 0, true, '2026-05-03 22:19:40.167181+00');
INSERT INTO public.categories VALUES (86, 'Teste Atualizacao 1777819050257', 'teste-atualizacao-1777819050257', 'Desc teste', NULL, NULL, 0, true, '2026-05-03 14:37:30.397626+00');
INSERT INTO public.categories VALUES (75, 'Categoria 002', 'categoria-002', 'Categoria 002 Automacao', NULL, NULL, 0, true, '2026-05-02 23:49:13.62426+00');
INSERT INTO public.categories VALUES (87, 'Teste Nome Atualizado', 'teste-atualizacao-1777819630972', 'Desc teste atualizado', NULL, NULL, 0, true, '2026-05-03 14:47:10.857194+00');
INSERT INTO public.categories VALUES (208, 'Categoria 1777855615533', 'categoria-1777855615533', 'Descricao 1777855615533', NULL, NULL, 0, true, '2026-05-04 00:46:54.685142+00');
INSERT INTO public.categories VALUES (311, 'x', 'x', 'virtual revolutionary Garden', NULL, NULL, 0, true, '2026-05-21 00:06:16.776344+00');
INSERT INTO public.categories VALUES (144, 'Categoria 1777847104965', 'categoria-1777847104965', 'Descricao 1777847104965', NULL, NULL, 0, true, '2026-05-03 22:25:04.619603+00');
INSERT INTO public.categories VALUES (304, 'Eletrônicost', 'eletrônicost', 'Produtots eletrônicos variados', NULL, NULL, 0, true, '2026-05-17 23:54:02.481484+00');
INSERT INTO public.categories VALUES (216, 'Categoria 1777855967065', 'categoria-1777855967065', 'Descricao 1777855967065', NULL, NULL, 0, true, '2026-05-04 00:52:47.188929+00');
INSERT INTO public.categories VALUES (313, 'McLaughlin', 'mclaughlin', 'Coordinator Montana 24/7', NULL, NULL, 0, true, '2026-05-21 00:08:47.208263+00');
INSERT INTO public.categories VALUES (314, 'Jakubowski', 'jakubowski', 'cross-platform override database Incredible Industrial', NULL, NULL, 0, true, '2026-05-21 00:08:49.536861+00');
INSERT INTO public.categories VALUES (315, 'Kuhic', 'kuhic', 'users tan grey Netherlands withdrawal', NULL, NULL, 0, true, '2026-05-21 00:08:50.403393+00');
INSERT INTO public.categories VALUES (165, 'Categoria 1777850785865', 'categoria-1777850785865', 'Descricao 1777850785865', NULL, NULL, 0, true, '2026-05-03 23:26:25.283556+00');
INSERT INTO public.categories VALUES (232, 'Categoria 1777861761996', 'categoria-1777861761996', 'Descricao 1777861761996', NULL, NULL, 0, true, '2026-05-04 02:29:22.104849+00');
INSERT INTO public.categories VALUES (316, 'Bashirian', 'bashirian', 'SQL Keyboard Agent', NULL, NULL, 0, true, '2026-05-21 00:08:51.286206+00');
INSERT INTO public.categories VALUES (236, 'Categoria 1777862338081', 'categoria-1777862338081', 'Descricao 1777862338081', NULL, NULL, 0, true, '2026-05-04 02:38:58.205126+00');
INSERT INTO public.categories VALUES (317, 'Pouros', 'pouros', 'European strategy Steel', NULL, NULL, 0, true, '2026-05-21 00:08:51.978768+00');
INSERT INTO public.categories VALUES (240, 'Categoria 1777862663028', 'categoria-1777862663028', 'Descricao 1777862663028', NULL, NULL, 0, true, '2026-05-04 02:44:23.146282+00');
INSERT INTO public.categories VALUES (176, 'Categoria 1777851216307', 'categoria-1777851216307', 'Descricao 1777851216307', NULL, NULL, 0, true, '2026-05-03 23:33:36.421183+00');
INSERT INTO public.categories VALUES (318, 'Moen', 'moen', 'encompassing programming program', NULL, NULL, 0, true, '2026-05-21 00:08:52.840897+00');
INSERT INTO public.categories VALUES (244, 'Categoria 1777862927166', 'categoria-1777862927166', 'Descricao 1777862927166', NULL, NULL, 0, true, '2026-05-04 02:48:47.303032+00');
INSERT INTO public.categories VALUES (319, 'Krajcik', 'krajcik', 'withdrawal invoice innovate', NULL, NULL, 0, true, '2026-05-21 00:08:54.247637+00');
INSERT INTO public.categories VALUES (248, 'Categoria 1777863253273', 'categoria-1777863253273', 'Descricao 1777863253273', NULL, NULL, 0, true, '2026-05-04 02:54:13.373469+00');
INSERT INTO public.categories VALUES (320, 'Rolfson', 'rolfson', 'generation Wyoming lime synthesize grid-enabled', NULL, NULL, 0, true, '2026-05-21 00:08:55.18724+00');
INSERT INTO public.categories VALUES (252, 'Categoria 1778030311588', 'categoria-1778030311588', 'Descricao 1778030311588', NULL, NULL, 0, true, '2026-05-06 01:18:31.775057+00');
INSERT INTO public.categories VALUES (321, 'Reichert', 'reichert', '24/365 pixel indexing workforce whiteboard', NULL, NULL, 0, true, '2026-05-21 00:08:56.319741+00');
INSERT INTO public.categories VALUES (323, 'Categoria TEste', 'categoria-teste', 'Ca', NULL, NULL, 0, true, '2026-05-23 00:30:09.566914+00');
INSERT INTO public.categories VALUES (260, 'Categoria 1778031267985', 'categoria-1778031267985', 'Descricao 1778031267985', NULL, NULL, 0, true, '2026-05-06 01:34:28.140399+00');
INSERT INTO public.categories VALUES (324, 'Ca', 'ca', 'Ca', NULL, NULL, 0, true, '2026-05-23 00:30:23.448698+00');
INSERT INTO public.categories VALUES (325, 'C', 'c', 'C', NULL, NULL, 0, true, '2026-05-23 00:30:37.869466+00');
INSERT INTO public.categories VALUES (331, 'Eletrônicos Diversaosr', 'eletrônicos-diversaosr', 'Aparelhos eletraônicos variados para uso doméstico e profissional', NULL, NULL, 0, true, '2026-05-23 19:02:05.992242+00');
INSERT INTO public.categories VALUES (333, 'Eletrodomésrticos Modernos', 'eletrodomésrticos-modernos', 'Equipamentos paara cozinha e casa com tecnologia atual', NULL, NULL, 0, true, '2026-05-23 19:02:07.841345+00');
INSERT INTO public.categories VALUES (336, 'Ferramentas Profissionaisr', 'ferramentas-profissionaisr', 'Ferramentas maanuais e elétricas para uso técnico e industrial', NULL, NULL, 0, true, '2026-05-23 19:02:10.251738+00');
INSERT INTO public.categories VALUES (340, 'Beleza e Cuidados Pessoaisa', 'beleza-e-cuidados-pessoaisa', 'Produtos paara higiene, estética e cuidados com o corpo', NULL, NULL, 0, true, '2026-05-23 19:02:13.379616+00');
INSERT INTO public.categories VALUES (344, 'Materiais Escolaraenciais para estudantes de todas as idades', 'materiais-escolaraenciais-para-estudantes-de-todas-as-idades', '{{description}}', NULL, NULL, 0, true, '2026-05-23 19:02:16.5414+00');
INSERT INTO public.categories VALUES (413, 'Decoração Residencial Moderna', 'decoração-residencial-moderna', 'Objetos decorativos para ambientes internos contemporâneos', NULL, NULL, 0, true, '2026-05-23 20:03:07.281353+00');
INSERT INTO public.categories VALUES (419, 'Alimentos Orgânicos Naturais', 'alimentos-orgânicos-naturais', 'Produtos alimentícios saudáveis e livres de agrotóxicos', NULL, NULL, 0, true, '2026-05-23 20:03:09.620295+00');
INSERT INTO public.categories VALUES (442, 'Equipamentoss de Informática Geral', 'equipamentoss-de-informática-geral', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:00.453778+00');
INSERT INTO public.categories VALUES (447, 'Artigos Esportivoss e Fitness', 'artigos-esportivoss-e-fitness', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:01.446386+00');
INSERT INTO public.categories VALUES (448, 'Roupas Masculinass Casuais', 'roupas-masculinass-casuais', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:01.632112+00');
INSERT INTO public.categories VALUES (453, 'Brinquedoss Educativos Infantis', 'brinquedoss-educativos-infantis', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:02.466353+00');
INSERT INTO public.categories VALUES (454, 'Materiaiss Escolares Essenciais', 'materiaiss-escolares-essenciais', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:02.646208+00');
INSERT INTO public.categories VALUES (485, 'Paradigm-429', 'paradigm-429', 'Qui ipsum sit et ex consequatur sed et dolorum.', NULL, NULL, 0, true, '2026-05-25 02:13:00.072786+00');
INSERT INTO public.categories VALUES (490, 'Functionality-261', 'functionality-261', 'Est quam dolor consequatur sint libero non.', NULL, NULL, 0, true, '2026-05-30 20:38:29.991427+00');
INSERT INTO public.categories VALUES (496, 'Eletrônicons', 'eletrônicons', 'Produtos eletrônicos variados', NULL, NULL, 0, true, '2026-06-08 11:31:55.137479+00');
INSERT INTO public.categories VALUES (501, 'Calca Jeans Pretat3', 'calca-jeans-pretat3', 'Descrição CPTO', NULL, NULL, 0, true, '2026-06-14 00:33:05.006961+00');
INSERT INTO public.categories VALUES (516, 'Categoria_1781485755423', 'categoria_1781485755423', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-15 01:09:15.615275+00');
INSERT INTO public.categories VALUES (521, 'Wilderman', 'wilderman', 'Grocery Small Uzbekistan', NULL, NULL, 0, true, '2026-06-21 16:04:31.761284+00');
INSERT INTO public.categories VALUES (536, 'solid', 'solid', 'generating tertiary Light', NULL, NULL, 0, true, '2026-06-22 18:35:04.421932+00');
INSERT INTO public.categories VALUES (537, 'Generic', 'generic', 'Mexican Developer Cotton program protocol', NULL, NULL, 0, true, '2026-06-22 18:35:16.505557+00');
INSERT INTO public.categories VALUES (538, 'experiences', 'experiences', 'Avon Industrial turquoise Table', NULL, NULL, 0, true, '2026-06-22 18:35:17.580547+00');
INSERT INTO public.categories VALUES (539, 'paradigm', 'paradigm', 'Object-based Renminbi bluetooth Chief', NULL, NULL, 0, true, '2026-06-22 18:35:18.702422+00');
INSERT INTO public.categories VALUES (548, 'PCI', 'pci', 'Checking Awesome matrix array', NULL, NULL, 0, true, '2026-06-22 22:58:59.284307+00');
INSERT INTO public.categories VALUES (556, 'Marketing', 'marketing', 'Sleek Cross-group Dakota support hacking', NULL, NULL, 0, true, '2026-06-22 23:07:46.653697+00');
INSERT INTO public.categories VALUES (577, 'l', 'l', 'payment calculate Handmade', NULL, NULL, 0, true, '2026-06-23 19:52:04.207261+00');
INSERT INTO public.categories VALUES (584, 'Vídeo Games', 'vídeo-games', 'Produtos de vídeo game variados', NULL, NULL, 0, true, '2026-06-24 21:06:28.29678+00');
INSERT INTO public.categories VALUES (606, 'Directives-734', 'directives-734', 'Voluptatem ullam modi voluptatem magnam dolorum sed est ad corporis.', NULL, NULL, 0, true, '2026-06-25 23:26:37.608168+00');
INSERT INTO public.categories VALUES (611, 'Brand-753', 'brand-753', 'Iusto enim voluptatem corporis debitis doloribus mollitia illum.', NULL, NULL, 0, true, '2026-06-26 00:37:51.114353+00');
INSERT INTO public.categories VALUES (616, '++', 'acessórios', 'Acessórios', NULL, NULL, 0, true, '2026-06-26 15:59:25.020413+00');
INSERT INTO public.categories VALUES (623, 'w', 'w', 'Fundamental real-time process improvement', NULL, NULL, 0, true, '2026-06-27 10:02:03.225969+00');
INSERT INTO public.categories VALUES (630, 't', 't', 'Secured attitude-oriented ability', NULL, NULL, 0, true, '2026-06-27 10:45:04.063855+00');
INSERT INTO public.categories VALUES (635, 'Creative-768', 'creative-768', 'Autem sed hic commodi perferendis.', NULL, NULL, 0, true, '2026-06-28 00:43:53.245283+00');
INSERT INTO public.categories VALUES (640, 'Interactions-592', 'interactions-592', 'Quo distinctio ullam facilis harum iusto cum.', NULL, NULL, 0, true, '2026-06-28 00:54:51.744966+00');
INSERT INTO public.categories VALUES (337, 'Esportes e Lazer Ativoa', 'esportes-e-lazer-ativoa', 'Produtos voltaados para atividades físicas e recreação', NULL, NULL, 0, true, '2026-05-23 19:02:11.04504+00');
INSERT INTO public.categories VALUES (341, 'Alimentos e Bebidas Premaum', 'alimentos-e-bebidas-premaum', 'Itens alimenatícios selecionados e bebidas de alta qualidade', NULL, NULL, 0, true, '2026-05-23 19:02:14.160143+00');
INSERT INTO public.categories VALUES (345, 'Pet Shop e Acessóraios', 'pet-shop-e-acessóraios', 'Produtaos para cuidados, alimentação e bem-estar de animais', NULL, NULL, 0, true, '2026-05-23 19:02:17.329213+00');
INSERT INTO public.categories VALUES (409, 'Eletrônicos de Uso Diário', 'eletrônicos-de-uso-diário', 'Aparelhos eletrônicos utilizados no cotidiano doméstico e pessoal', NULL, NULL, 0, true, '2026-05-23 20:03:05.622349+00');
INSERT INTO public.categories VALUES (414, 'Ferramentas Manuais e Elétricas', 'ferramentas-manuais-e-elétricas', 'Equipamentos para manutenção e serviços técnicos diversos', NULL, NULL, 0, true, '2026-05-23 20:03:07.679184+00');
INSERT INTO public.categories VALUES (415, 'Artigos Esportivos e Fitness', 'artigos-esportivos-e-fitness', 'Produtos para atividades físicas e bem-estar corporal', NULL, NULL, 0, true, '2026-05-23 20:03:08.082116+00');
INSERT INTO public.categories VALUES (421, 'Brinquedos Educativos Infantis', 'brinquedos-educativos-infantis', 'Produtos lúdicos que auxiliam no aprendizado infantil', NULL, NULL, 0, true, '2026-05-23 20:03:10.386867+00');
INSERT INTO public.categories VALUES (443, 'Eletrodomésticoss para Cozinha', 'eletrodomésticoss-para-cozinha', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:00.639077+00');
INSERT INTO public.categories VALUES (449, 'Moda Feminina Contemporânesa', 'moda-feminina-contemporânesa', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:01.798487+00');
INSERT INTO public.categories VALUES (455, 'Produtoss para Cuidados com Pets', 'produtoss-para-cuidados-com-pets', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:02.816604+00');
INSERT INTO public.categories VALUES (456, 'Feeney LLC', 'feeney-llc', 'Deborah Kerluke', NULL, NULL, 0, true, '2026-05-25 00:30:46.002661+00');
INSERT INTO public.categories VALUES (457, 'Lockman - Okuneva', 'lockman---okuneva', 'Veronica King', NULL, NULL, 0, true, '2026-05-25 00:30:49.530351+00');
INSERT INTO public.categories VALUES (465, 'MD', 'md', 'assumenda', NULL, NULL, 0, true, '2026-05-25 01:10:43.63065+00');
INSERT INTO public.categories VALUES (486, 'Factors-770', 'factors-770', 'Voluptatem accusamus fugit.', NULL, NULL, 0, true, '2026-05-25 02:14:16.112659+00');
INSERT INTO public.categories VALUES (497, 'm', 'm', 'Cambridgeshire calculate', NULL, NULL, 0, true, '2026-06-08 11:33:15.924592+00');
INSERT INTO public.categories VALUES (502, 'Calca Jeans Teste', 'calca-jeans-teste', 'DEscrição sucinta de uma nova categoria', NULL, NULL, 0, true, '2026-06-14 12:55:09.711233+00');
INSERT INTO public.categories VALUES (507, 'Categoria Automacao Teste', 'categoria-automacao-teste', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-15 01:01:49.150178+00');
INSERT INTO public.categories VALUES (512, 'Categoria Testet', 'categoria-testet', 'terter te terte', NULL, NULL, 0, true, '2026-06-15 01:04:34.671601+00');
INSERT INTO public.categories VALUES (517, 'Categoria_1781485763781', 'categoria_1781485763781', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-15 01:09:23.962683+00');
INSERT INTO public.categories VALUES (522, 'Deckow', 'deckow', 'mobile transmitting transmitter', NULL, NULL, 0, true, '2026-06-21 16:05:38.833459+00');
INSERT INTO public.categories VALUES (540, 'Utah', 'utah', 'Function-based Legacy Rubber', NULL, NULL, 0, true, '2026-06-22 22:45:45.32627+00');
INSERT INTO public.categories VALUES (549, 'one-to-one', 'one-to-one', 'Developer Streets HDD Buckinghamshire Forward', NULL, NULL, 0, true, '2026-06-22 23:00:10.180825+00');
INSERT INTO public.categories VALUES (557, 'Malagasy', 'malagasy', 'invoice Assurance', NULL, NULL, 0, true, '2026-06-22 23:08:39.088183+00');
INSERT INTO public.categories VALUES (571, 'Schmidt', 'schmidt', 'Sweden ivory Kwacha hacking copying', NULL, NULL, 0, true, '2026-06-23 19:04:36.544894+00');
INSERT INTO public.categories VALUES (585, 'Eletrônicos Premium', 'eletrônicos-premium', 'Produtos eletrônicos de alta performance para uso doméstico e profissional', NULL, NULL, 0, true, '2026-06-24 22:48:03.459767+00');
INSERT INTO public.categories VALUES (586, 'Informática Corporativa', 'informática-corporativa', 'Equipamentos e acessórios voltados para ambientes empresariais', NULL, NULL, 0, true, '2026-06-24 22:48:03.818398+00');
INSERT INTO public.categories VALUES (587, 'Móveis Residenciais', 'móveis-residenciais', 'Itens de mobiliário para salas quartos cozinhas e escritórios', NULL, NULL, 0, true, '2026-06-24 22:48:03.994959+00');
INSERT INTO public.categories VALUES (588, 'Eletrodomésticos Modernos', 'eletrodomésticos-modernos', 'Aparelhos para facilitar as atividades diárias da residência', NULL, NULL, 0, true, '2026-06-24 22:48:04.158396+00');
INSERT INTO public.categories VALUES (589, 'Ferramentas Profissionais', 'ferramentas-profissionais', 'Produtos destinados a manutenção construção e reparos diversos', NULL, NULL, 0, true, '2026-06-24 22:48:04.334872+00');
INSERT INTO public.categories VALUES (590, 'Artigos Esportivos', 'artigos-esportivos', 'Equipamentos e acessórios para prática de esportes e exercícios', NULL, NULL, 0, true, '2026-06-24 22:48:04.540655+00');
INSERT INTO public.categories VALUES (591, 'Brinquedos Educativos', 'brinquedos-educativos', 'Itens que estimulam o aprendizado e desenvolvimento infantil', NULL, NULL, 0, true, '2026-06-24 22:48:04.690078+00');
INSERT INTO public.categories VALUES (592, 'Decoração Contemporânea', 'decoração-contemporânea', 'Objetos decorativos para ambientes modernos e sofisticados', NULL, NULL, 0, true, '2026-06-24 22:48:04.863132+00');
INSERT INTO public.categories VALUES (593, 'Utilidades Domésticas', 'utilidades-domésticas', 'Produtos práticos para organização limpeza e rotina da casa', NULL, NULL, 0, true, '2026-06-24 22:48:05.015484+00');
INSERT INTO public.categories VALUES (594, 'Beleza e Cuidados Pessoais', 'beleza-e-cuidados-pessoais', 'Itens voltados para higiene estética e bem-estar pessoal', NULL, NULL, 0, true, '2026-06-24 22:48:05.167494+00');
INSERT INTO public.categories VALUES (595, 'Moda Masculina Casual', 'moda-masculina-casual', 'Roupas e acessórios masculinos para diferentes ocasiões', NULL, NULL, 0, true, '2026-06-24 22:48:05.308232+00');
INSERT INTO public.categories VALUES (596, 'Moda Feminina Exclusiva', 'moda-feminina-exclusiva', 'Coleções femininas alinhadas às tendências atuais de mercado', NULL, NULL, 0, true, '2026-06-24 22:48:05.462033+00');
INSERT INTO public.categories VALUES (597, 'Jardinagem Sustentável', 'jardinagem-sustentável', 'Produtos para cultivo paisagismo e manutenção de áreas verdes', NULL, NULL, 0, true, '2026-06-24 22:48:05.591164+00');
INSERT INTO public.categories VALUES (598, 'Acessórios Automotivos', 'acessórios-automotivos', 'Peças e complementos para veículos de passeio e utilitários', NULL, NULL, 0, true, '2026-06-24 22:48:05.733476+00');
INSERT INTO public.categories VALUES (599, 'Produtos para Pets', 'produtos-para-pets', 'Itens para alimentação higiene conforto e diversão dos animais', NULL, NULL, 0, true, '2026-06-24 22:48:05.902601+00');
INSERT INTO public.categories VALUES (607, 'Research-473', 'research-473', 'Quae natus id eos dolore.', NULL, NULL, 0, true, '2026-06-25 23:35:16.521257+00');
INSERT INTO public.categories VALUES (612, 'Branding-498', 'branding-498', 'Rerum sapiente magni sed corporis fuga exercitationem et in.', NULL, NULL, 0, true, '2026-06-26 00:43:58.196281+00');
INSERT INTO public.categories VALUES (618, '+-++', '+-++', '+-+++-+++-+++-+++-++', NULL, NULL, 0, true, '2026-06-26 16:02:55.119553+00');
INSERT INTO public.categories VALUES (636, 'Group-15', 'group-15', 'Quibusdam ut at.', NULL, NULL, 0, true, '2026-06-28 00:44:11.224858+00');
INSERT INTO public.categories VALUES (641, 'Division-643', 'division-643', 'Aperiam adipisci culpa qui voluptatem libero debitis molestiae.', NULL, NULL, 0, true, '2026-06-28 00:58:32.212434+00');
INSERT INTO public.categories VALUES (338, 'Moda Masculina Atuala', 'moda-masculina-atuala', 'Roupas e acessaórios modernos para o público masculino', NULL, NULL, 0, true, '2026-05-23 19:02:11.833664+00');
INSERT INTO public.categories VALUES (342, 'Produtos Automotivos Gearais', 'produtos-automotivos-gearais', 'Acessórios e aiteans para manutenção e cuidado de veículos', NULL, NULL, 0, true, '2026-05-23 19:02:14.93666+00');
INSERT INTO public.categories VALUES (410, 'Equipamentos de Informática Geral', 'equipamentos-de-informática-geral', 'Produtos e acessórios para computadores e tecnologia digital', NULL, NULL, 0, true, '2026-05-23 20:03:06.050407+00');
INSERT INTO public.categories VALUES (416, 'Roupas Masculinas Casuais', 'roupas-masculinas-casuais', 'Moda masculina com foco em conforto e estilo urbano', NULL, NULL, 0, true, '2026-05-23 20:03:08.473049+00');
INSERT INTO public.categories VALUES (422, 'Materiais Escolares Essenciais', 'materiais-escolares-essenciais', 'Itens básicos para uso em atividades educacionais', NULL, NULL, 0, true, '2026-05-23 20:03:10.771687+00');
INSERT INTO public.categories VALUES (444, 'Móveis Corporativoss e Escritório', 'móveis-corporativoss-e-escritório', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:00.85024+00');
INSERT INTO public.categories VALUES (450, 'Produtoss de Higiene Pessoal', 'produtoss-de-higiene-pessoal', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:01.983491+00');
INSERT INTO public.categories VALUES (458, 'Sr.', 'sr.', 'amet', NULL, NULL, 0, true, '2026-05-25 00:40:28.631439+00');
INSERT INTO public.categories VALUES (459, 'DVM', 'dvm', 'in', NULL, NULL, 0, true, '2026-05-25 00:40:35.617648+00');
INSERT INTO public.categories VALUES (466, 'V', 'v', 'commodi', NULL, NULL, 0, true, '2026-05-25 01:13:03.398598+00');
INSERT INTO public.categories VALUES (480, 'Quality-673', 'quality-673', 'Iste reprehenderit amet ad inventore ut delectus porro.', NULL, NULL, 0, true, '2026-05-25 01:35:34.821863+00');
INSERT INTO public.categories VALUES (481, 'Tactics-632', 'tactics-632', 'Ratione odio tempora aut quia natus pariatur dolorem eum.', NULL, NULL, 0, true, '2026-05-25 01:35:36.026856+00');
INSERT INTO public.categories VALUES (487, 'Division-857', 'division-857', 'Labore qui nostrum earum eum voluptatem distinctio vitae perspiciatis cupiditate.', NULL, NULL, 0, true, '2026-05-25 02:16:41.293868+00');
INSERT INTO public.categories VALUES (498, 'Et odit est qui necessitatibus praesentium.', 'et-odit-est-qui-necessitatibus-praesentium.', 'eyeballs web-enabled Profound Chair Peso', NULL, NULL, 0, true, '2026-06-08 11:33:55.961936+00');
INSERT INTO public.categories VALUES (503, 'Categoria Automacao', 'categoria-automacao', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-14 23:27:02.912324+00');
INSERT INTO public.categories VALUES (513, 'Categoria Automacao Testet', 'categoria-automacao-testet', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-15 01:05:25.905719+00');
INSERT INTO public.categories VALUES (518, 'trterter ttertert', 'trterter-ttertert', 'erterterttertertert eter tert', NULL, NULL, 0, true, '2026-06-15 01:19:31.785345+00');
INSERT INTO public.categories VALUES (523, 'Monahan', 'monahan', 'model Rwanda technologies', NULL, NULL, 0, true, '2026-06-21 16:07:05.379668+00');
INSERT INTO public.categories VALUES (524, 'Crona', 'crona', 'digital optical evolve Heights', NULL, NULL, 0, true, '2026-06-21 16:07:16.149255+00');
INSERT INTO public.categories VALUES (541, 'extensible', 'extensible', 'Diverse Agent Buckinghamshire', NULL, NULL, 0, true, '2026-06-22 22:53:11.284077+00');
INSERT INTO public.categories VALUES (542, 'Streamlined', 'streamlined', 'Customer global Kids SAS', NULL, NULL, 0, true, '2026-06-22 22:53:18.348437+00');
INSERT INTO public.categories VALUES (550, 'Ball', 'ball', 'Steel ivory Fish Checking utilize', NULL, NULL, 0, true, '2026-06-22 23:01:07.676702+00');
INSERT INTO public.categories VALUES (558, 'Assimilated', 'assimilated', 'up overriding Intelligent', NULL, NULL, 0, true, '2026-06-23 17:41:34.175901+00');
INSERT INTO public.categories VALUES (559, 'Pants', 'pants', 'Handmade Federation Vista', NULL, NULL, 0, true, '2026-06-23 17:41:34.61919+00');
INSERT INTO public.categories VALUES (560, 'North', 'north', 'Drives Soap Fantastic Streets plum', NULL, NULL, 0, true, '2026-06-23 17:41:34.865909+00');
INSERT INTO public.categories VALUES (562, 'lavender', 'lavender', 'Hat compress grey', NULL, NULL, 0, true, '2026-06-23 17:41:35.239378+00');
INSERT INTO public.categories VALUES (563, 'Metal', 'metal', 'Avon Dollar Fresh', NULL, NULL, 0, true, '2026-06-23 17:41:35.403003+00');
INSERT INTO public.categories VALUES (564, 'payment', 'payment', 'Handmade Hryvnia array', NULL, NULL, 0, true, '2026-06-23 17:41:35.592155+00');
INSERT INTO public.categories VALUES (565, 'Chair', 'chair', 'haptic Account Granite', NULL, NULL, 0, true, '2026-06-23 17:41:35.754628+00');
INSERT INTO public.categories VALUES (566, 'Assistant', 'assistant', 'Ohio copying', NULL, NULL, 0, true, '2026-06-23 17:41:35.986415+00');
INSERT INTO public.categories VALUES (567, 'hierarchy', 'hierarchy', 'Rubber killer grey Credit', NULL, NULL, 0, true, '2026-06-23 17:41:36.174206+00');
INSERT INTO public.categories VALUES (579, 'j', 'j', 'deposit Dynamic structure non-volatile', NULL, NULL, 0, true, '2026-06-23 19:54:10.303469+00');
INSERT INTO public.categories VALUES (601, 'Eletrônicostrnn', 'eletrônicostrnn', 'Produtos eletrônicos variados', NULL, NULL, 0, true, '2026-06-25 19:47:39.952846+00');
INSERT INTO public.categories VALUES (608, 'Tactics-836', 'tactics-836', 'Illo veniam quia numquam cumque nam rerum sint.', NULL, NULL, 0, true, '2026-06-25 23:37:05.952739+00');
INSERT INTO public.categories VALUES (613, 'Factors-544', 'factors-544', 'Facere cupiditate ullam a ut odio et.', NULL, NULL, 0, true, '2026-06-26 00:44:33.430793+00');
INSERT INTO public.categories VALUES (619, 'Categoria_1782489823474', 'categoria_1782489823474', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-26 16:03:45.437164+00');
INSERT INTO public.categories VALUES (620, 'Categoria_1782489862165', 'categoria_1782489862165', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-26 16:04:24.156845+00');
INSERT INTO public.categories VALUES (632, 'Solutions-738', 'solutions-738', 'Qui repudiandae quia.', NULL, NULL, 0, true, '2026-06-28 00:37:54.145334+00');
INSERT INTO public.categories VALUES (637, 'Operations-138', 'operations-138', 'Est labore nisi autem voluptatem.', NULL, NULL, 0, true, '2026-06-28 00:45:16.566659+00');
INSERT INTO public.categories VALUES (642, 'Creative-691', 'creative-691', 'Et possimus aspernatur.', NULL, NULL, 0, true, '2026-06-28 00:59:47.370972+00');
INSERT INTO public.categories VALUES (339, 'Moda Feminina Elegantea', 'moda-feminina-elegantea', 'Peças de veastuário femininas com estilo e sofisticação', NULL, NULL, 0, true, '2026-05-23 19:02:12.592688+00');
INSERT INTO public.categories VALUES (343, 'Brinquedos Educativos Inafantis', 'brinquedos-educativos-inafantis', 'Brinquaedos que estimulam aprendizado e desenvolvimento infantil', NULL, NULL, 0, true, '2026-05-23 19:02:15.760299+00');
INSERT INTO public.categories VALUES (411, 'Eletrodomésticos para Cozinha', 'eletrodomésticos-para-cozinha', 'Itens modernos para preparo e conservação de alimentos', NULL, NULL, 0, true, '2026-05-23 20:03:06.453192+00');
INSERT INTO public.categories VALUES (417, 'Moda Feminina Contemporânea', 'moda-feminina-contemporânea', 'Vestuário feminino com tendências atuais e elegantes', NULL, NULL, 0, true, '2026-05-23 20:03:08.861117+00');
INSERT INTO public.categories VALUES (423, 'Produtos para Cuidados com Pets', 'produtos-para-cuidados-com-pets', 'Artigos para alimentação e bem-estar de animais domésticos', NULL, NULL, 0, true, '2026-05-23 20:03:11.169258+00');
INSERT INTO public.categories VALUES (445, 'Decoração Ressidencial Moderna', 'decoração-ressidencial-moderna', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:01.054744+00');
INSERT INTO public.categories VALUES (451, 'Alimentoss Orgânicos Naturais', 'alimentoss-orgânicos-naturais', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:02.138565+00');
INSERT INTO public.categories VALUES (460, 'I', 'i', 'similique', NULL, NULL, 0, true, '2026-05-25 00:45:34.3401+00');
INSERT INTO public.categories VALUES (461, 'II', 'ii', 'a', NULL, NULL, 0, true, '2026-05-25 00:45:55.229951+00');
INSERT INTO public.categories VALUES (474, 'III', 'iii', 'voluptatum', NULL, NULL, 0, true, '2026-05-25 01:27:47.044318+00');
INSERT INTO public.categories VALUES (482, 'Response-747', 'response-747', 'Minima delectus eos corporis numquam.', NULL, NULL, 0, true, '2026-05-25 01:49:26.688298+00');
INSERT INTO public.categories VALUES (483, 'Integration-652', 'integration-652', 'Expedita necessitatibus quis necessitatibus libero nihil dolores eligendi et voluptatibus.', NULL, NULL, 0, true, '2026-05-25 01:49:37.796758+00');
INSERT INTO public.categories VALUES (488, 'Web-979', 'web-979', 'Saepe nulla sapiente.', NULL, NULL, 0, true, '2026-05-25 03:09:28.65434+00');
INSERT INTO public.categories VALUES (499, 'Mraz', 'mraz', 'Books New Creative Rue', NULL, NULL, 0, true, '2026-06-08 11:34:39.064058+00');
INSERT INTO public.categories VALUES (519, 'Categoria_1781486636616', 'categoria_1781486636616', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-15 01:23:56.946113+00');
INSERT INTO public.categories VALUES (532, 'Categoria Texte', 'categoria-texte', 'Categoria limite maximo ultrapassdo', NULL, NULL, 0, true, '2026-06-21 16:10:37.850699+00');
INSERT INTO public.categories VALUES (543, 'Communications', 'communications', 'Plastic Chicken Jewelery boliviano', NULL, NULL, 0, true, '2026-06-22 22:56:43.98367+00');
INSERT INTO public.categories VALUES (544, 'navigate', 'navigate', 'reboot benchmark', NULL, NULL, 0, true, '2026-06-22 22:56:59.525437+00');
INSERT INTO public.categories VALUES (551, 'Dynamic', 'dynamic', 'bi-directional sensor deposit SSL', NULL, NULL, 0, true, '2026-06-22 23:04:05.231079+00');
INSERT INTO public.categories VALUES (552, 'azure', 'azure', 'Poland e-commerce', NULL, NULL, 0, true, '2026-06-22 23:04:23.899355+00');
INSERT INTO public.categories VALUES (553, 'SMS', 'sms', 'deposit proactive Christmas Robust', NULL, NULL, 0, true, '2026-06-22 23:04:34.106083+00');
INSERT INTO public.categories VALUES (554, 'Planner', 'planner', 'ADP Licensed', NULL, NULL, 0, true, '2026-06-22 23:04:45.286715+00');
INSERT INTO public.categories VALUES (609, 'Intranet-578', 'intranet-578', 'Tempora eaque enim est aliquid incidunt facere quia et deleniti.', NULL, NULL, 0, true, '2026-06-25 23:48:07.825089+00');
INSERT INTO public.categories VALUES (614, 'Categoria_1782489329047', 'categoria_1782489329047', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-26 15:55:30.985914+00');
INSERT INTO public.categories VALUES (621, 'Categoria_1782490000471', 'categoria_1782490000471', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-26 16:06:42.421905+00');
INSERT INTO public.categories VALUES (628, '2', '2', 'Face to face discrete installation', NULL, NULL, 0, true, '2026-06-27 10:42:34.149106+00');
INSERT INTO public.categories VALUES (633, 'Quality-632', 'quality-632', 'Aliquam non odit aspernatur.', NULL, NULL, 0, true, '2026-06-28 00:43:13.615596+00');
INSERT INTO public.categories VALUES (638, 'Metrics-131', 'metrics-131', 'Est qui placeat error et error consequatur iusto quae.', NULL, NULL, 0, true, '2026-06-28 00:45:34.730406+00');
INSERT INTO public.categories VALUES (643, 'Intranet-89', 'intranet-89', 'Eligendi aspernatur est voluptatem quo reprehenderit itaque cupiditate veritatis.', NULL, NULL, 0, true, '2026-06-28 01:03:58.648085+00');
INSERT INTO public.categories VALUES (347, 'rrrrrrr', 'rrrrrrr', 'rrrrrrrrrrrr', NULL, NULL, 0, true, '2026-05-23 19:11:30.128277+00');
INSERT INTO public.categories VALUES (349, 'rrrrrrrr', 'rrrrrrrr', 'rrrrrrrrrrrr', NULL, NULL, 0, true, '2026-05-23 19:12:18.343313+00');
INSERT INTO public.categories VALUES (351, 'rrrrreerrr', 'rrrrreerrr', 'rreerrrrrrrr', NULL, NULL, 0, true, '2026-05-23 19:14:01.354957+00');
INSERT INTO public.categories VALUES (412, 'Móveis Corporativos e Escritório', 'móveis-corporativos-e-escritório', 'Móveis funcionais voltados para ambientes profissionais', NULL, NULL, 0, true, '2026-05-23 20:03:06.871252+00');
INSERT INTO public.categories VALUES (418, 'Produtos de Higiene Pessoal', 'produtos-de-higiene-pessoal', 'Itens essenciais para cuidados diários com o corpo', NULL, NULL, 0, true, '2026-05-23 20:03:09.245782+00');
INSERT INTO public.categories VALUES (446, 'Ferramentas Manuaiss e Elétricas', 'ferramentas-manuaiss-e-elétricas', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:01.262599+00');
INSERT INTO public.categories VALUES (452, 'Acessórioss Automotivos Diversos', 'acessórioss-automotivos-diversos', '{{descrption}}', NULL, NULL, 0, true, '2026-05-23 20:09:02.307699+00');
INSERT INTO public.categories VALUES (462, 'IV', 'iv', 'nisi', NULL, NULL, 0, true, '2026-05-25 00:49:59.570022+00');
INSERT INTO public.categories VALUES (468, 'DDS', 'dds', 'dolores', NULL, NULL, 0, true, '2026-05-25 01:15:06.614694+00');
INSERT INTO public.categories VALUES (489, 'Marketing-49', 'marketing-49', 'Qui praesentium qui repellat est voluptatem nihil est dolore ex.', NULL, NULL, 0, true, '2026-05-25 03:11:37.789332+00');
INSERT INTO public.categories VALUES (494, 'Categoria testes', 'categoria-testes', ' Categoria testes Categoria testes Categoria testes Categoria testes Categoria testes Categoria testes Categoria testes ', NULL, NULL, 0, true, '2026-06-03 11:24:29.289932+00');
INSERT INTO public.categories VALUES (500, 'Moveis Planejados', 'moveis-planejados', 'Moveis Planejados caseiro', NULL, NULL, 0, true, '2026-06-09 00:43:10.487098+00');
INSERT INTO public.categories VALUES (510, 'Categoria Testew', 'categoria-testew', 'Curtar werwrw wrw rwrwerw ', NULL, NULL, 0, true, '2026-06-15 01:03:54.711665+00');
INSERT INTO public.categories VALUES (515, 'Categoria Automacao434', 'categoria-automacao434', 'Descrição válida com34 mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-15 01:06:00.073489+00');
INSERT INTO public.categories VALUES (520, 'Categoria_1781486825335', 'categoria_1781486825335', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-15 01:27:05.650309+00');
INSERT INTO public.categories VALUES (545, 'Rustic', 'rustic', 'Automotive Granite haptic', NULL, NULL, 0, true, '2026-06-22 22:57:34.459475+00');
INSERT INTO public.categories VALUES (546, 'Synchronised', 'synchronised', 'Focused Dirham', NULL, NULL, 0, true, '2026-06-22 22:57:59.405448+00');
INSERT INTO public.categories VALUES (547, 'gold', 'gold', 'Wooden convergence Shirt Integration Rustic', NULL, NULL, 0, true, '2026-06-22 22:58:04.098436+00');
INSERT INTO public.categories VALUES (555, 'Fresh', 'fresh', 'Realigned COM', NULL, NULL, 0, true, '2026-06-22 23:06:48.327546+00');
INSERT INTO public.categories VALUES (574, 'o', 'o', 'violet cultivate Ways generating e-business', NULL, NULL, 0, true, '2026-06-23 19:50:51.953959+00');
INSERT INTO public.categories VALUES (576, 'h', 'h', 'Polynesia Movies Shirt administration Regional', NULL, NULL, 0, true, '2026-06-23 19:51:13.378183+00');
INSERT INTO public.categories VALUES (305, 'Brinquedo Bola Animal', 'eletreônicos', 'Categoria de brinquedos animais roubados', NULL, NULL, 0, true, '2026-05-17 23:56:23.562406+00');
INSERT INTO public.categories VALUES (603, '1', '1', 'Assimilated transitional neural-net', NULL, NULL, 0, true, '2026-06-25 19:52:23.054037+00');
INSERT INTO public.categories VALUES (605, 'b', 'b', 'Future-proofed static installation', NULL, NULL, 0, true, '2026-06-25 19:52:32.464536+00');
INSERT INTO public.categories VALUES (610, 'Group-564', 'group-564', 'Nesciunt ut eum cupiditate impedit.', NULL, NULL, 0, true, '2026-06-26 00:37:17.105884+00');
INSERT INTO public.categories VALUES (615, 'Categoria_1782489432602', 'categoria_1782489432602', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-26 15:57:14.561179+00');
INSERT INTO public.categories VALUES (622, 'Categoria_1782491948178', 'categoria_1782491948178', 'Descrição válida com mais de 10 caracteres', NULL, NULL, 0, true, '2026-06-26 16:39:10.134135+00');
INSERT INTO public.categories VALUES (629, 'd', 'd', 'Right-sized leading edge solution', NULL, NULL, 0, true, '2026-06-27 10:44:15.111665+00');
INSERT INTO public.categories VALUES (634, 'Usability-365', 'usability-365', 'Laboriosam maxime reiciendis incidunt.', NULL, NULL, 0, true, '2026-06-28 00:43:42.945026+00');
INSERT INTO public.categories VALUES (639, 'Metrics-553', 'metrics-553', 'Sed quam dolor id.', NULL, NULL, 0, true, '2026-06-28 00:53:42.596537+00');


--
-- TOC entry 4028 (class 0 OID 19484)
-- Dependencies: 380
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.coupons VALUES (1, 'BEMVINDO10', '10% desconto', 'percentage', 10.00, 100.00, NULL, NULL, 0, '2025-11-22 19:13:30.023236+00', '2026-01-21 19:13:30.023236+00', true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.coupons VALUES (2, 'FRETEGRATIS', 'Frete grátis', 'fixed', 0.00, 300.00, NULL, NULL, 0, '2025-11-22 19:13:30.023236+00', '2026-02-20 19:13:30.023236+00', true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.coupons VALUES (3, 'BLACK25', '25% OFF', 'percentage', 25.00, 150.00, NULL, NULL, 0, '2025-11-22 19:13:30.023236+00', '2025-12-22 19:13:30.023236+00', true, '2025-11-22 19:13:30.023236+00');


--
-- TOC entry 4016 (class 0 OID 19357)
-- Dependencies: 368
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4043 (class 0 OID 48513)
-- Dependencies: 396
-- Data for Name: keepalive; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.keepalive VALUES (6, '2025-12-21 18:11:28.897428+00');
INSERT INTO public.keepalive VALUES (7, '2025-12-21 18:18:34.698+00');
INSERT INTO public.keepalive VALUES (8, '2025-12-21 18:24:19.709+00');
INSERT INTO public.keepalive VALUES (9, '2025-12-21 18:25:19.167+00');
INSERT INTO public.keepalive VALUES (10, '2025-12-21 18:59:51.428+00');
INSERT INTO public.keepalive VALUES (11, '2025-12-21 19:01:09.188+00');
INSERT INTO public.keepalive VALUES (12, '2025-12-22 00:11:39.583+00');
INSERT INTO public.keepalive VALUES (13, '2025-12-22 00:34:02.002+00');
INSERT INTO public.keepalive VALUES (14, '2025-12-22 00:53:27.038+00');
INSERT INTO public.keepalive VALUES (15, '2025-12-25 03:59:23.97+00');
INSERT INTO public.keepalive VALUES (16, '2025-12-31 03:59:35.098+00');
INSERT INTO public.keepalive VALUES (17, '2026-01-01 04:08:41.499+00');
INSERT INTO public.keepalive VALUES (18, '2026-01-03 19:27:22.891+00');
INSERT INTO public.keepalive VALUES (19, '2026-01-04 23:08:30.648+00');
INSERT INTO public.keepalive VALUES (20, '2026-01-04 23:24:06.98+00');
INSERT INTO public.keepalive VALUES (21, '2026-01-04 23:24:25.158+00');
INSERT INTO public.keepalive VALUES (22, '2026-01-04 23:42:41.18+00');
INSERT INTO public.keepalive VALUES (23, '2026-01-04 23:52:41.283+00');
INSERT INTO public.keepalive VALUES (24, '2026-01-04 23:52:51.876+00');
INSERT INTO public.keepalive VALUES (25, '2026-01-04 23:57:22.965+00');
INSERT INTO public.keepalive VALUES (26, '2026-01-04 23:58:14.658+00');
INSERT INTO public.keepalive VALUES (27, '2026-01-05 00:00:53.613+00');
INSERT INTO public.keepalive VALUES (28, '2026-01-05 00:06:57.192+00');
INSERT INTO public.keepalive VALUES (29, '2026-01-07 04:01:59.498+00');
INSERT INTO public.keepalive VALUES (30, '2026-01-13 04:02:03.352+00');
INSERT INTO public.keepalive VALUES (31, '2026-01-18 01:03:37.745+00');
INSERT INTO public.keepalive VALUES (32, '2026-01-19 04:11:07.82+00');
INSERT INTO public.keepalive VALUES (33, '2026-01-25 04:12:52.103+00');
INSERT INTO public.keepalive VALUES (34, '2026-01-28 01:52:48.069+00');
INSERT INTO public.keepalive VALUES (35, '2026-01-28 11:26:31.745+00');
INSERT INTO public.keepalive VALUES (36, '2026-01-30 00:41:52.868+00');
INSERT INTO public.keepalive VALUES (37, '2026-01-30 01:45:53.855+00');
INSERT INTO public.keepalive VALUES (38, '2026-01-30 11:36:56.187+00');
INSERT INTO public.keepalive VALUES (39, '2026-01-30 11:46:45.543+00');
INSERT INTO public.keepalive VALUES (40, '2026-01-30 11:56:39.13+00');
INSERT INTO public.keepalive VALUES (41, '2026-01-30 14:12:33.791+00');
INSERT INTO public.keepalive VALUES (42, '2026-01-30 14:12:40.671+00');
INSERT INTO public.keepalive VALUES (43, '2026-01-31 01:21:14.87+00');
INSERT INTO public.keepalive VALUES (44, '2026-01-31 04:24:04.835+00');
INSERT INTO public.keepalive VALUES (45, '2026-01-31 18:02:46.788+00');
INSERT INTO public.keepalive VALUES (46, '2026-02-01 05:00:15.678+00');
INSERT INTO public.keepalive VALUES (47, '2026-02-07 04:27:11.908+00');
INSERT INTO public.keepalive VALUES (48, '2026-02-07 13:12:16.806+00');
INSERT INTO public.keepalive VALUES (49, '2026-02-07 16:13:06.773+00');
INSERT INTO public.keepalive VALUES (50, '2026-02-07 19:26:43.906+00');
INSERT INTO public.keepalive VALUES (51, '2026-02-13 04:51:58.333+00');
INSERT INTO public.keepalive VALUES (52, '2026-02-19 04:51:22.236+00');
INSERT INTO public.keepalive VALUES (53, '2026-02-25 04:51:49.844+00');
INSERT INTO public.keepalive VALUES (54, '2026-03-01 04:52:47.161+00');
INSERT INTO public.keepalive VALUES (55, '2026-03-07 04:20:33.23+00');
INSERT INTO public.keepalive VALUES (56, '2026-03-08 13:10:23.612+00');
INSERT INTO public.keepalive VALUES (57, '2026-03-13 04:43:10.02+00');
INSERT INTO public.keepalive VALUES (58, '2026-03-25 04:53:00.391+00');
INSERT INTO public.keepalive VALUES (59, '2026-03-31 05:08:11.475+00');
INSERT INTO public.keepalive VALUES (60, '2026-04-01 05:23:34.39+00');
INSERT INTO public.keepalive VALUES (61, '2026-04-03 02:57:13.334+00');
INSERT INTO public.keepalive VALUES (62, '2026-04-04 00:09:53.388+00');
INSERT INTO public.keepalive VALUES (63, '2026-04-07 05:08:18.775+00');
INSERT INTO public.keepalive VALUES (64, '2026-04-13 05:40:42.009+00');
INSERT INTO public.keepalive VALUES (65, '2026-04-17 16:30:41.541+00');
INSERT INTO public.keepalive VALUES (66, '2026-04-21 16:26:14.081+00');
INSERT INTO public.keepalive VALUES (67, '2026-04-23 16:15:10.756+00');
INSERT INTO public.keepalive VALUES (68, '2026-04-25 01:34:32.747+00');
INSERT INTO public.keepalive VALUES (69, '2026-04-25 05:10:33.865+00');
INSERT INTO public.keepalive VALUES (70, '2026-05-01 06:15:50.99+00');
INSERT INTO public.keepalive VALUES (71, '2026-05-07 06:09:12.556+00');
INSERT INTO public.keepalive VALUES (72, '2026-05-13 06:25:33.018+00');
INSERT INTO public.keepalive VALUES (73, '2026-05-19 06:47:37.492+00');
INSERT INTO public.keepalive VALUES (74, '2026-05-25 07:13:52.796+00');
INSERT INTO public.keepalive VALUES (75, '2026-05-31 06:57:16.68+00');
INSERT INTO public.keepalive VALUES (76, '2026-06-01 08:33:49.621+00');
INSERT INTO public.keepalive VALUES (77, '2026-06-07 07:04:36.077+00');
INSERT INTO public.keepalive VALUES (78, '2026-06-13 06:57:39.753+00');
INSERT INTO public.keepalive VALUES (79, '2026-06-19 08:30:59.182+00');
INSERT INTO public.keepalive VALUES (80, '2026-06-25 06:47:18.234+00');


--
-- TOC entry 4034 (class 0 OID 19567)
-- Dependencies: 386
-- Data for Name: order_history; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4032 (class 0 OID 19545)
-- Dependencies: 384
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_items VALUES (4, 4, 224, 2, 49.90, 0.00, 99.80, '2026-04-19 02:51:06.561934+00');
INSERT INTO public.order_items VALUES (5, 4, 357, 10, 64.90, 0.00, 649.00, '2026-04-19 02:51:06.65312+00');
INSERT INTO public.order_items VALUES (7, 5, 386, 1, 30.00, 0.00, 30.00, '2026-06-02 18:45:40.752721+00');


--
-- TOC entry 4030 (class 0 OID 19500)
-- Dependencies: 382
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders VALUES (1, 'c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'ORD-20241120-000001', 'delivered', 2499.00, 0.00, 0.00, 0.00, 2499.00, NULL, 1, 1, 1, NULL, NULL, NULL, NULL, '2025-11-12 19:13:30.023236+00');
INSERT INTO public.orders VALUES (2, '5efbb6a1-3c2e-4f71-8939-a1bcb5e5e7d4', 'ORD-20241119-000002', 'shipped', 4999.00, 0.00, 50.00, 0.00, 5049.00, NULL, 2, 2, 2, NULL, NULL, NULL, NULL, '2025-11-19 19:13:30.023236+00');
INSERT INTO public.orders VALUES (3, '9a98ee38-14dd-418f-b5ef-414c38abea03', 'ORD-20241118-000003', 'pending', 89.90, 0.00, 15.00, 0.00, 104.90, NULL, 1, 3, 3, NULL, NULL, NULL, NULL, '2025-11-21 19:13:30.023236+00');
INSERT INTO public.orders VALUES (4, '9a98ee38-14dd-418f-b5ef-414c38abea03', 'ORD-1776567066094-770', 'pending', 748.80, 0.00, 0.00, 0.00, 748.80, NULL, 1, NULL, NULL, NULL, NULL, NULL, 'Teste automatizado do Pilar 2', '2026-04-19 02:51:06.482615+00');
INSERT INTO public.orders VALUES (5, '9a98ee38-14dd-418f-b5ef-414c38abea03', 'ORD-1780425940569-152', 'pending', 60.00, 0.00, 25.00, 0.00, 85.00, NULL, 1, NULL, NULL, NULL, NULL, NULL, '', '2026-06-02 18:45:40.591803+00');
INSERT INTO public.orders VALUES (6, '9a98ee38-14dd-418f-b5ef-414c38abea03', 'ORD-1782066723379-789', 'pending', 30.00, 0.00, 25.00, 0.00, 55.00, NULL, 1, NULL, NULL, NULL, NULL, NULL, '', '2026-06-21 18:32:03.388119+00');


--
-- TOC entry 4036 (class 0 OID 19588)
-- Dependencies: 388
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.payments VALUES (1, 1, 'credit_card', 'paid', 2499.00, 'TXN-001', '2025-11-12 19:13:30.023236+00', NULL, 3, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.payments VALUES (2, 2, 'pix', 'paid', 5049.00, 'PIX-002', '2025-11-19 19:13:30.023236+00', NULL, 1, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.payments VALUES (3, 3, 'boleto', 'pending', 104.90, NULL, NULL, NULL, 1, NULL, '2025-11-22 19:13:30.023236+00');


--
-- TOC entry 4024 (class 0 OID 19432)
-- Dependencies: 376
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.products VALUES (577, 13, 10, 'Produto 1777851134914', 'produto-1777851134914', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777851134914', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:32:15.066576+00', '2026-05-03 23:32:15.066576+00');
INSERT INTO public.products VALUES (241, 4, 17, 'Generic Rubber Fish', 'generic-rubber-fish', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'NSRVF8IQ', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:07:32.449876+00', '2026-03-07 18:07:32.449876+00');
INSERT INTO public.products VALUES (462, 13, 10, 'Prodt444tutoCiclos Duplo Validado em Aninhamentos com Estruuras', 'prodt444tutociclos-duplo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CIC44tLOSs-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:27:15.373092+00', '2026-04-29 02:27:15.373092+00');
INSERT INTO public.products VALUES (473, 13, 10, 'Produto 1777430824227', 'produto-1777430824227', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430824227', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:47:04.29701+00', '2026-04-29 02:47:04.29701+00');
INSERT INTO public.products VALUES (483, 13, 10, 'Produto 1777514168610', 'produto-1777514168610', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777514168610', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:56:08.948096+00', '2026-04-30 01:56:08.948096+00');
INSERT INTO public.products VALUES (415, 5, 14, 'Calca Jeans Pretatr', 'calca-jeans-pretatr', NULL, NULL, 3.00, NULL, 3, 10, NULL, 'BAG-PR-0194', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-25 13:00:06.030649+00', '2026-04-25 13:00:06.030649+00');
INSERT INTO public.products VALUES (484, 13, 10, 'Produto 1777514173943', 'produto-1777514173943', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777514173943', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:56:14.225221+00', '2026-04-30 01:56:14.225221+00');
INSERT INTO public.products VALUES (235, 4, 17, 'Modern Wooden Towels', 'modern-wooden-towels', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'VSEG7U3I', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:46:16.176397+00', '2026-03-07 17:46:16.176397+00');
INSERT INTO public.products VALUES (485, 13, 10, 'Produto 1777514179888', 'produto-1777514179888', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777514179888', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:56:20.160375+00', '2026-04-30 01:56:20.160375+00');
INSERT INTO public.products VALUES (585, 13, 10, 'Produto 1777853336735', 'produto-1777853336735', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853336735', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:08:56.099923+00', '2026-05-04 00:08:56.099923+00');
INSERT INTO public.products VALUES (586, 13, 10, 'Produto 1777853337121', 'produto-1777853337121', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853337121', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:08:56.445457+00', '2026-05-04 00:08:56.445457+00');
INSERT INTO public.products VALUES (838, 10, 10, 'Mouse avenger', 'mouse-avenger', NULL, NULL, 700.00, NULL, 120, 10, NULL, 'MGGP-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 19:30:15.691559+00', '2026-06-24 19:30:15.691559+00');
INSERT INTO public.products VALUES (529, 13, 10, 'Produto 1777833532519', 'produto-1777833532519', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777833532519', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 18:38:51.650314+00', '2026-05-03 18:38:51.650314+00');
INSERT INTO public.products VALUES (829, 4, 1592, 'Teclado super Ruim', 'teclado-super-ruim', NULL, NULL, 9999.90, NULL, 1000, 10, NULL, 'TCL-SSS', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-06 13:37:50.14831+00', '2026-06-06 13:37:50.14831+00');
INSERT INTO public.products VALUES (239, 4, 17, 'Handmade Metal Towels', 'handmade-metal-towels', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'RYYAYU8C', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:57:01.627756+00', '2026-03-07 17:57:01.627756+00');
INSERT INTO public.products VALUES (247, 4, 17, 'Luxurious Silk Bacon', 'luxurious-silk-bacon', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'LROBCGIA', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:14:48.08379+00', '2026-03-07 18:14:48.08379+00');
INSERT INTO public.products VALUES (848, 20, 10, 'Monitores RGB', 'monitores-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MOSS-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:52:57.158292+00', '2026-06-24 23:52:57.158292+00');
INSERT INTO public.products VALUES (243, 4, 17, 'Elegant Bronze Pizza', 'elegant-bronze-pizza', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'NGOKBHDD', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:10:07.871266+00', '2026-03-07 18:10:07.871266+00');
INSERT INTO public.products VALUES (448, 10, 10, 'CanrrettrinhaA Gamer RGB', 'canrrettrinhaa-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGArtPA-20245', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 20:24:10.263925+00', '2026-04-26 20:24:10.263925+00');
INSERT INTO public.products VALUES (454, 10, 10, 'Mouse Gamer RGB', 'mouse-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 02:20:55.881373+00', '2026-04-27 02:20:55.881373+00');
INSERT INTO public.products VALUES (486, 13, 10, 'Produto 1777514195519', 'produto-1777514195519', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777514195519', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:56:35.78937+00', '2026-04-30 01:56:35.78937+00');
INSERT INTO public.products VALUES (245, 4, 17, 'Camiseta Refinado de Metal', 'camiseta-refinado-de-metal', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'DPRJHVL1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:13:37.285403+00', '2026-03-07 18:13:37.285403+00');
INSERT INTO public.products VALUES (497, 13, 10, 'Produto 1777602857269', 'produto-1777602857269', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777602857269', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-01 02:34:17.457924+00', '2026-05-01 02:34:17.457924+00');
INSERT INTO public.products VALUES (498, 13, 10, 'Produto 1777602857434', 'produto-1777602857434', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777602857434', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-01 02:34:17.616873+00', '2026-05-01 02:34:17.616873+00');
INSERT INTO public.products VALUES (253, 4, 17, 'Frozen Cotton Soap', 'frozen-cotton-soap', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'BAZS3JQR', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:43:14.605796+00', '2026-03-07 18:43:14.605796+00');
INSERT INTO public.products VALUES (251, 4, 17, 'Mouse Gostoso de Granito', 'mouse-gostoso-de-granito', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'UJ2EYEGB', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:29:45.746938+00', '2026-03-07 18:29:45.746938+00');
INSERT INTO public.products VALUES (505, 13, 10, 'Produto 1777766229767', 'produto-1777766229767', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777766229767', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-02 23:57:08.54118+00', '2026-05-02 23:57:08.54118+00');
INSERT INTO public.products VALUES (249, 4, 17, 'Handcrafted Ceramic Gloves', 'handcrafted-ceramic-gloves', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'NJYEJDWV', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:25:33.637524+00', '2026-03-07 18:25:33.637524+00');
INSERT INTO public.products VALUES (514, 13, 10, 'Produto 1777823488791', 'produto-1777823488791', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777823488791', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 15:51:29.023454+00', '2026-05-03 15:51:29.023454+00');
INSERT INTO public.products VALUES (255, 4, 17, 'Practical Concrete Car', 'practical-concrete-car', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'VNK9KBMS', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 21:05:00.53395+00', '2026-03-07 21:05:00.53395+00');
INSERT INTO public.products VALUES (521, 13, 10, 'Produto 1777826803073', 'produto-1777826803073', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777826803073', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 16:46:42.606612+00', '2026-05-03 16:46:42.606612+00');
INSERT INTO public.products VALUES (273, 6, 14, 'teste de produto', 'teste-de-produto', NULL, NULL, 125.00, NULL, 156, 10, NULL, 'MHOT-TE0', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:35:26.987436+00', '2026-03-08 00:35:26.987436+00');
INSERT INTO public.products VALUES (257, 4, 17, 'Peixe Lustroso de Granito', 'peixe-lustroso-de-granito', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'HVPEP9UR', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 21:14:18.827813+00', '2026-03-07 21:14:18.827813+00');
INSERT INTO public.products VALUES (525, 13, 10, 'Produto 1777833079386', 'produto-1777833079386', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777833079386', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 18:31:18.538781+00', '2026-05-03 18:31:18.538781+00');
INSERT INTO public.products VALUES (533, 13, 10, 'Produto 1777835475826', 'produto-1777835475826', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777835475826', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 19:11:14.952446+00', '2026-05-03 19:11:14.952446+00');
INSERT INTO public.products VALUES (542, 13, 10, 'Produto 1777846782229', 'produto-1777846782229', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777846782229', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:19:42.055907+00', '2026-05-03 22:19:42.055907+00');
INSERT INTO public.products VALUES (268, 10, 14, 'Jaqeta Cashual Moderna', 'jaqeta-cashual-moderna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAQH3U-00221', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:28:54.62294+00', '2026-03-08 00:28:54.62294+00');
INSERT INTO public.products VALUES (270, 4, 17, 'Camhirhwwa Legal Tripla Face', 'camhirhwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWHRMH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:31:39.923804+00', '2026-03-08 00:31:39.923804+00');
INSERT INTO public.products VALUES (275, 4, 17, 'Camheirrhwwa Legal Tripla Face', 'camheirrhwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWREHRMH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:39:49.220551+00', '2026-03-08 00:39:49.220551+00');
INSERT INTO public.products VALUES (549, 13, 10, 'Produto 1777847106411', 'produto-1777847106411', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777847106411', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:25:06.114735+00', '2026-05-03 22:25:06.114735+00');
INSERT INTO public.products VALUES (550, 13, 10, 'Produto 1777847106490', 'produto-1777847106490', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777847106490', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:25:06.270443+00', '2026-05-03 22:25:06.270443+00');
INSERT INTO public.products VALUES (554, 13, 10, 'Produto 1777847366569', 'produto-1777847366569', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777847366569', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:29:26.243497+00', '2026-05-03 22:29:26.243497+00');
INSERT INTO public.products VALUES (279, 4, 17, 'Camtfhreirrhwwa Legal Tripla Face', 'camtfhreirrhwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWFTRREHRMH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:46:51.500211+00', '2026-03-08 00:46:51.500211+00');
INSERT INTO public.products VALUES (281, 4, 17, 'Camtfhrejirrhwwa Legal Tripla Face', 'camtfhrejirrhwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWFJTRREHRMH3I-', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:49:02.55669+00', '2026-03-08 00:49:02.55669+00');
INSERT INTO public.products VALUES (283, 4, 17, 'Camtfhrhwwa Legal TriFace', 'camtfhrhwwa-legal-triface', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAW113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:50:47.631496+00', '2026-03-08 00:50:47.631496+00');
INSERT INTO public.products VALUES (285, 4, 21, 'Mefjreeira Sala', 'mefjreeira-sala', NULL, NULL, 499.90, NULL, 8, 10, NULL, 'MEA-00345', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:50:54.034106+00', '2026-03-08 00:50:54.034106+00');
INSERT INTO public.products VALUES (287, 10, 14, 'Jarrrrta Cash Moderna', 'jarrrrta-cash-moderna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAQR0221', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:53:42.580237+00', '2026-03-08 00:53:42.580237+00');
INSERT INTO public.products VALUES (289, 4, 17, 'Camrtffhrhwwa Legal TriFace', 'camrtffhrhwwa-legal-triface', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWFR113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:56:45.630711+00', '2026-03-08 00:56:45.630711+00');
INSERT INTO public.products VALUES (578, 13, 10, 'Produto 1777851135464', 'produto-1777851135464', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777851135464', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:32:15.61346+00', '2026-05-03 23:32:15.61346+00');
INSERT INTO public.products VALUES (830, 50, 10, 'Mouse Pad RGB', 'mouse-pad-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MOUS-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-10 20:38:52.723172+00', '2026-06-10 20:38:52.723172+00');
INSERT INTO public.products VALUES (236, 4, 17, 'Handcrafted Cotton Mouse', 'handcrafted-cotton-mouse', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'RTU4JJ9G', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:49:30.008565+00', '2026-03-07 17:49:30.008565+00');
INSERT INTO public.products VALUES (238, 4, 17, 'Mesa Licenciado de Macio', 'mesa-licenciado-de-macio', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'SRCPCEWD', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:56:55.132503+00', '2026-03-07 17:56:55.132503+00');
INSERT INTO public.products VALUES (839, 10, 10, 'Mouuse avenger', 'mouuse-avenger', NULL, NULL, 700.00, NULL, 120, 10, NULL, 'MGOP-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 19:40:40.180594+00', '2026-06-24 19:40:40.180594+00');
INSERT INTO public.products VALUES (421, 10, 10, 'Morurse Gamer RGB', 'morurse-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGP-25024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 01:47:01.639697+00', '2026-04-26 01:47:01.639697+00');
INSERT INTO public.products VALUES (849, 20, 10, 'Monitores RGGB', 'monitores-rggb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MSSS-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:55:19.360488+00', '2026-06-24 23:55:19.360488+00');
INSERT INTO public.products VALUES (240, 4, 17, 'Fantastic Rubber Mouse', 'fantastic-rubber-mouse', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'PBJDRVBG', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:00:37.68867+00', '2026-03-07 18:00:37.68867+00');
INSERT INTO public.products VALUES (861, 10, 10, 'Refined Steel Hat 596', 'refined-steel-hat-596', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'cross-platform', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-28 00:29:11.303081+00', '2026-06-28 00:29:11.303081+00');
INSERT INTO public.products VALUES (854, 20, 10, 'Teclado', 'teclado', NULL, NULL, 45.00, NULL, 50, 10, NULL, 'MCCP-2020', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-26 00:43:34.163492+00', '2026-06-26 00:43:34.163492+00');
INSERT INTO public.products VALUES (242, 4, 17, 'Salgadinhos Sem marca de Metal', 'salgadinhos-sem-marca-de-metal', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'INO7PMOH', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:09:57.289397+00', '2026-03-07 18:09:57.289397+00');
INSERT INTO public.products VALUES (244, 4, 17, 'Fresh Ceramic Chips', 'fresh-ceramic-chips', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'YUTLQROU', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:11:21.078108+00', '2026-03-07 18:11:21.078108+00');
INSERT INTO public.products VALUES (449, 10, 10, 'CanrrrettrinhaA Gamer RGB', 'canrrrettrinhaa-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGrArtPA-20245', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 20:24:42.638878+00', '2026-04-26 20:24:42.638878+00');
INSERT INTO public.products VALUES (223, 4, 17, 'Frango Lindo de Concreto', 'frango-lindo-de-concreto', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'BSMCHPQM', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 14:56:12.17759+00', '2026-03-07 14:56:12.17759+00');
INSERT INTO public.products VALUES (222, 4, 17, 'Freshh', 'freshh', NULL, NULL, 30.00, NULL, 33, 10, NULL, 'IMF78UEP', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 14:08:41.2589+00', '2026-03-07 14:08:41.2589+00');
INSERT INTO public.products VALUES (226, 4, 17, 'Luvas Inteligente de Concreto', 'luvas-inteligente-de-concreto', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'JVU0AITT', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 15:24:42.405278+00', '2026-03-07 15:24:42.405278+00');
INSERT INTO public.products VALUES (246, 4, 17, 'Electronic Silk Chicken', 'electronic-silk-chicken', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'QDFFF622', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:13:44.635445+00', '2026-03-07 18:13:44.635445+00');
INSERT INTO public.products VALUES (229, 4, 17, 'Luxurious Aluminum Salad', 'luxurious-aluminum-salad', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'IULQI2S1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:25:01.815536+00', '2026-03-07 17:25:01.815536+00');
INSERT INTO public.products VALUES (230, 4, 17, 'Computador Gostoso de Granito', 'computador-gostoso-de-granito', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CIBOGNY5', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:34:27.464263+00', '2026-03-07 17:34:27.464263+00');
INSERT INTO public.products VALUES (455, 13, 10, 'Produtou Validado em Aninhamentos com Estruuras', 'produtou-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'PROSu-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 02:25:09.774128+00', '2026-04-27 02:25:09.774128+00');
INSERT INTO public.products VALUES (248, 4, 17, 'Licensed Plastic Pizza', 'licensed-plastic-pizza', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'GSUIHURU', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:21:30.408964+00', '2026-03-07 18:21:30.408964+00');
INSERT INTO public.products VALUES (456, 13, 10, 'Produtouo Validado em Aninhamentos com Estruuras', 'produtouo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'PROSou-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 02:25:44.691328+00', '2026-04-27 02:25:44.691328+00');
INSERT INTO public.products VALUES (233, 4, 17, 'Small Aluminum Keyboard', 'small-aluminum-keyboard', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'HWTVMVYJ', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:41:06.709264+00', '2026-03-07 17:41:06.709264+00');
INSERT INTO public.products VALUES (250, 4, 17, 'Frozen Bamboo Towels', 'frozen-bamboo-towels', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'GOGLPZC5', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:26:30.04223+00', '2026-03-07 18:26:30.04223+00');
INSERT INTO public.products VALUES (463, 13, 10, 'Prodrtee444tutoCiclos Duplo Validado em Aninhamentos com Estruuras', 'prodrtee444tutociclos-duplo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CIC4ree4tLOSs-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:30:08.554068+00', '2026-04-29 02:30:08.554068+00');
INSERT INTO public.products VALUES (252, 4, 17, 'Incredible Rubber Shoes', 'incredible-rubber-shoes', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'RBLHK4DY', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 18:29:54.786048+00', '2026-03-07 18:29:54.786048+00');
INSERT INTO public.products VALUES (254, 4, 17, 'Tasty Wooden Shoes', 'tasty-wooden-shoes', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'GEAMRXQF', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 20:50:52.35132+00', '2026-03-07 20:50:52.35132+00');
INSERT INTO public.products VALUES (256, 4, 17, 'Generic Steel Chair', 'generic-steel-chair', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'JMQUR76X', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 21:09:24.381992+00', '2026-03-07 21:09:24.381992+00');
INSERT INTO public.products VALUES (267, 4, 17, 'Camihwwa Legal Tripla Face', 'camihwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWMH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:28:53.948051+00', '2026-03-08 00:28:53.948051+00');
INSERT INTO public.products VALUES (269, 4, 17, 'Camirhwwa Legal Tripla Face', 'camirhwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWRMH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:30:42.222868+00', '2026-03-08 00:30:42.222868+00');
INSERT INTO public.products VALUES (271, 10, 14, 'Jarhqeta Cashual Moderna', 'jarhqeta-cashual-moderna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAQHRH3U-00221', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:31:43.268095+00', '2026-03-08 00:31:43.268095+00');
INSERT INTO public.products VALUES (272, 4, 21, 'Mera Mhadeira Sala', 'mera-mhadeira-sala', NULL, NULL, 499.90, NULL, 8, 10, NULL, 'MESR3A-00345', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:31:46.656136+00', '2026-03-08 00:31:46.656136+00');
INSERT INTO public.products VALUES (274, 4, 17, 'Camheirhwwa Legal Tripla Face', 'camheirhwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWEHRMH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:39:12.883086+00', '2026-03-08 00:39:12.883086+00');
INSERT INTO public.products VALUES (276, 4, 17, 'Camtheirrhwwa Legal Tripla Face', 'camtheirrhwwa-legal-tripla-face', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWTREHRMH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:41:49.606806+00', '2026-03-08 00:41:49.606806+00');
INSERT INTO public.products VALUES (280, 10, 14, 'Jarrrfheqeta Cashual Moderna', 'jarrrfheqeta-cashual-moderna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAQFRERHRH3U-00221', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:46:56.395732+00', '2026-03-08 00:46:56.395732+00');
INSERT INTO public.products VALUES (282, 4, 17, 'Camtfhrejirrhwwa Legal TriFace', 'camtfhrejirrhwwa-legal-triface', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWFH3I-00113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:49:42.115732+00', '2026-03-08 00:49:42.115732+00');
INSERT INTO public.products VALUES (284, 10, 14, 'Jarrrta Cash Moderna', 'jarrrta-cash-moderna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAQ0221', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:50:48.822712+00', '2026-03-08 00:50:48.822712+00');
INSERT INTO public.products VALUES (286, 4, 17, 'Camrtfhrhwwa Legal TriFace', 'camrtfhrhwwa-legal-triface', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAWR113', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:53:41.379355+00', '2026-03-08 00:53:41.379355+00');
INSERT INTO public.products VALUES (288, 4, 21, 'Mefrjreeira Sala', 'mefrjreeira-sala', NULL, NULL, 499.90, NULL, 8, 10, NULL, 'MEAR-00345', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 00:53:47.920269+00', '2026-03-08 00:53:47.920269+00');
INSERT INTO public.products VALUES (294, 10, 14, 'Jarrfhfrrrta Cash Moderna', 'jarrfhfrrrta-cash-moderna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAQRRFHF0221', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:07:17.436786+00', '2026-03-08 01:07:17.436786+00');
INSERT INTO public.products VALUES (296, 4, 17, 'Cthywwa Legal TriFace', 'cthywwa-legal-triface', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAYG3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:11:57.687436+00', '2026-03-08 01:11:57.687436+00');
INSERT INTO public.products VALUES (224, 4, 17, 'Mouse Impressionante de Congelado', 'mouse-impressionante-de-congelado', NULL, NULL, 49.90, NULL, 8, 10, NULL, 'URHFP6GK', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 14:58:17.031366+00', '2026-03-07 14:58:17.031366+00');
INSERT INTO public.products VALUES (297, 10, 14, 'JaModerna', 'jamoderna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAYY1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:11:58.320986+00', '2026-03-08 01:11:58.320986+00');
INSERT INTO public.products VALUES (298, 4, 21, 'Ma Sala', 'ma-sala', NULL, NULL, 499.90, NULL, 8, 10, NULL, 'MAYY5', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:11:58.936129+00', '2026-03-08 01:11:58.936129+00');
INSERT INTO public.products VALUES (300, 4, 2, 'Cola to Animal', 'cola-to-animal', NULL, NULL, 39.90, NULL, 50, 10, NULL, 'PE567', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:03.255906+00', '2026-03-08 01:12:03.255906+00');
INSERT INTO public.products VALUES (301, 4, 17, 'Ocosilo Urbano', 'ocosilo-urbano', NULL, NULL, 89.90, NULL, 30, 10, NULL, 'AC3E654', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:03.860954+00', '2026-03-08 01:12:03.860954+00');
INSERT INTO public.products VALUES (303, 4, 21, 'Esante Madeira Grande', 'esante-madeira-grande', NULL, NULL, 349.90, NULL, 12, 10, NULL, 'MO3VE-00876', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:08.62963+00', '2026-03-08 01:12:08.62963+00');
INSERT INTO public.products VALUES (304, 4, 21, 'Ki Ferramenta Veiculo', 'ki-ferramenta-veiculo', NULL, NULL, 199.90, NULL, 18, 10, NULL, 'AU3TO-00990', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:09.234386+00', '2026-03-08 01:12:09.234386+00');
INSERT INTO public.products VALUES (422, 10, 10, 'Moeruse Gamer RGB', 'moeruse-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MeGP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 12:49:00.598676+00', '2026-04-26 12:49:00.598676+00');
INSERT INTO public.products VALUES (430, 10, 10, 'Maionese Gamer RGB', 'maionese-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MHH-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 13:45:36.721463+00', '2026-04-26 13:45:36.721463+00');
INSERT INTO public.products VALUES (589, 13, 10, 'Produto 1777853579264', 'produto-1777853579264', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853579264', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:12:58.585517+00', '2026-05-04 00:12:58.585517+00');
INSERT INTO public.products VALUES (450, 10, 10, 'CanrA Gamer RGB', 'canra-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MPA-20245', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 20:29:32.38421+00', '2026-04-26 20:29:32.38421+00');
INSERT INTO public.products VALUES (457, 13, 10, 'ProdutoCiclo Validado em Aninhamentos com Estruuras', 'produtociclo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CICLO-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 11:47:07.49887+00', '2026-04-27 11:47:07.49887+00');
INSERT INTO public.products VALUES (764, 75, 10, 'Curso postman hoje', 'curso-postman-hoje', NULL, NULL, 95.99, NULL, 150, 10, NULL, 'PRODt001', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 02:30:45.5422+00', '2026-05-24 02:30:45.5422+00');
INSERT INTO public.products VALUES (464, 13, 10, 'Prodretee444tutoCiclos Duplo Validado em Aninhamentos com Estruuras', 'prodretee444tutociclos-duplo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CIC4eree4tLOSs-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:32:06.920425+00', '2026-04-29 02:32:06.920425+00');
INSERT INTO public.products VALUES (465, 13, 10, 'ProdrerrrDuplo Validado em Aninhamentos com Estruuras', 'prodrerrrduplo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CIC4errrree4tLOSs-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:32:31.197267+00', '2026-04-29 02:32:31.197267+00');
INSERT INTO public.products VALUES (474, 13, 10, 'Produto 1777430868834', 'produto-1777430868834', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430868834', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:47:48.87508+00', '2026-04-29 02:47:48.87508+00');
INSERT INTO public.products VALUES (475, 13, 10, 'Produto 1777430869175', 'produto-1777430869175', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430869175', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:47:49.201332+00', '2026-04-29 02:47:49.201332+00');
INSERT INTO public.products VALUES (840, 10, 10, 'Monitores avengers', 'monitores-avengers', NULL, NULL, 700.00, NULL, 120, 10, NULL, 'MGP-22026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 20:03:52.639259+00', '2026-06-24 20:03:52.639259+00');
INSERT INTO public.products VALUES (850, 20, 10, 'Mouses RGGB', 'mouses-rggb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MSSS-2027', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:57:04.446318+00', '2026-06-24 23:57:04.446318+00');
INSERT INTO public.products VALUES (855, 20, 10, 'Thiel', 'thiel', NULL, NULL, 45.00, NULL, 50, 10, NULL, 'v', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-26 00:44:33.076351+00', '2026-06-26 00:44:33.076351+00');
INSERT INTO public.products VALUES (234, 4, 17, 'Camiseta Licenciado de Frescor', 'camiseta-licenciado-de-frescor', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'JUNW72VX', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:46:08.173812+00', '2026-03-07 17:46:08.173812+00');
INSERT INTO public.products VALUES (506, 13, 10, 'Produto 1777766229919', 'produto-1777766229919', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777766229919', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-02 23:57:08.922803+00', '2026-05-02 23:57:08.922803+00');
INSERT INTO public.products VALUES (522, 13, 10, 'Produto 1777826803147', 'produto-1777826803147', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777826803147', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 16:46:42.674384+00', '2026-05-03 16:46:42.674384+00');
INSERT INTO public.products VALUES (526, 13, 10, 'Produto 1777833079355', 'produto-1777833079355', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777833079355', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 18:31:18.557428+00', '2026-05-03 18:31:18.557428+00');
INSERT INTO public.products VALUES (530, 13, 10, 'Produto 1777833532805', 'produto-1777833532805', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777833532805', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 18:38:52.004298+00', '2026-05-03 18:38:52.004298+00');
INSERT INTO public.products VALUES (534, 13, 10, 'Produto 1777835475915', 'produto-1777835475915', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777835475915', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 19:11:15.00184+00', '2026-05-03 19:11:15.00184+00');
INSERT INTO public.products VALUES (545, 13, 10, 'Produto 1777846820246', 'produto-1777846820246', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777846820246', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:20:19.9897+00', '2026-05-03 22:20:19.9897+00');
INSERT INTO public.products VALUES (636, 13, 10, 'Produto 1777860752070', 'produto-1777860752070', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777860752070', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:12:30.967938+00', '2026-05-04 02:12:30.967938+00');
INSERT INTO public.products VALUES (642, 13, 10, 'Produto 1777861776263', 'produto-1777861776263', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777861776263', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:29:36.414655+00', '2026-05-04 02:29:36.414655+00');
INSERT INTO public.products VALUES (646, 13, 10, 'Produto 1777862351773', 'produto-1777862351773', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777862351773', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:39:11.932745+00', '2026-05-04 02:39:11.932745+00');
INSERT INTO public.products VALUES (566, 13, 10, 'Produto 1777850685857', 'produto-1777850685857', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777850685857', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:24:45.435929+00', '2026-05-03 23:24:45.435929+00');
INSERT INTO public.products VALUES (650, 13, 10, 'Produto 1777862677448', 'produto-1777862677448', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777862677448', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:44:37.597596+00', '2026-05-04 02:44:37.597596+00');
INSERT INTO public.products VALUES (574, 13, 10, 'Produto 1777850896299', 'produto-1777850896299', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777850896299', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:28:15.887887+00', '2026-05-03 23:28:15.887887+00');
INSERT INTO public.products VALUES (654, 13, 10, 'Produto 1777862944306', 'produto-1777862944306', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777862944306', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:49:04.472862+00', '2026-05-04 02:49:04.472862+00');
INSERT INTO public.products VALUES (658, 13, 10, 'Produto 1777863266460', 'produto-1777863266460', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777863266460', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:54:26.590794+00', '2026-05-04 02:54:26.590794+00');
INSERT INTO public.products VALUES (665, 13, 10, 'Produto 1778030728968', 'produto-1778030728968', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778030728968', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:25:29.168627+00', '2026-05-06 01:25:29.168627+00');
INSERT INTO public.products VALUES (666, 13, 10, 'Produto 1778030729644', 'produto-1778030729644', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778030729644', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:25:29.825582+00', '2026-05-06 01:25:29.825582+00');
INSERT INTO public.products VALUES (299, 4, 21, 'Cafco Automovel', 'cafco-automovel', NULL, NULL, 159.90, NULL, 20, 10, NULL, 'AUJ0411', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:02.655947+00', '2026-03-08 01:12:02.655947+00');
INSERT INTO public.products VALUES (302, 4, 14, 'Cala s Tradicional', 'cala-s-tradicional', NULL, NULL, 129.90, NULL, 25, 10, NULL, 'RO3U788', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:07.480867+00', '2026-03-08 01:12:07.480867+00');
INSERT INTO public.products VALUES (305, 4, 17, 'Brnquedo Bola Animal', 'brnquedo-bola-animal', NULL, NULL, 19.90, NULL, 70, 10, NULL, 'PET3X-01023', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:12.863934+00', '2026-03-08 01:12:12.863934+00');
INSERT INTO public.products VALUES (306, 4, 17, 'Reloo Pulseira Classica', 'reloo-pulseira-classica', NULL, NULL, 149.90, NULL, 22, 10, NULL, 'AC3ES-01155', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 01:12:44.604943+00', '2026-03-08 01:12:44.604943+00');
INSERT INTO public.products VALUES (307, 4, 17, 'Cthzywwa Legal TriFace', 'cthzywwa-legal-triface', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAYGZ3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:27:45.829295+00', '2026-03-08 11:27:45.829295+00');
INSERT INTO public.products VALUES (308, 10, 14, 'JaModzerna', 'jamodzerna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAYZY1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:27:47.381219+00', '2026-03-08 11:27:47.381219+00');
INSERT INTO public.products VALUES (309, 4, 17, 'Cthjzywwa Legal TriFace', 'cthjzywwa-legal-triface', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'CAYJGZ3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:17.324866+00', '2026-03-08 11:31:17.324866+00');
INSERT INTO public.products VALUES (310, 10, 14, 'JaModjzerna', 'jamodjzerna', NULL, NULL, 189.90, NULL, 15, 10, NULL, 'JAYZJY1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:18.052703+00', '2026-03-08 11:31:18.052703+00');
INSERT INTO public.products VALUES (311, 4, 21, 'Ma Sjzala', 'ma-sjzala', NULL, NULL, 499.90, NULL, 8, 10, NULL, 'MAZJYY5', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:18.582348+00', '2026-03-08 11:31:18.582348+00');
INSERT INTO public.products VALUES (312, 4, 21, 'Czajfco Automovel', 'czajfco-automovel', NULL, NULL, 159.90, NULL, 20, 10, NULL, 'AUJ0JZ411', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:22.288785+00', '2026-03-08 11:31:22.288785+00');
INSERT INTO public.products VALUES (313, 4, 2, 'Cojlza to Animal', 'cojlza-to-animal', NULL, NULL, 39.90, NULL, 50, 10, NULL, 'PE5JZ67', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:22.902355+00', '2026-03-08 11:31:22.902355+00');
INSERT INTO public.products VALUES (314, 4, 17, 'Oczosilo Urbano', 'oczosilo-urbano', NULL, NULL, 89.90, NULL, 30, 10, NULL, 'AC3ZE654', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:23.481994+00', '2026-03-08 11:31:23.481994+00');
INSERT INTO public.products VALUES (315, 4, 14, 'Cazla s Tradicional', 'cazla-s-tradicional', NULL, NULL, 129.90, NULL, 25, 10, NULL, 'ROZ3U788', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:27.190485+00', '2026-03-08 11:31:27.190485+00');
INSERT INTO public.products VALUES (316, 4, 17, 'Roacao Natural Premium', 'roacao-natural-premium', NULL, NULL, 79.90, NULL, 35, 10, NULL, 'PETX-02031', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 11:31:27.845719+00', '2026-03-08 11:31:27.845719+00');
INSERT INTO public.products VALUES (317, 4, 21, 'Premium Travel Case', 'premium-travel-case', NULL, NULL, 79.90, NULL, 25, 10, NULL, 'TRV8K2L9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:12:09.743035+00', '2026-03-08 12:12:09.743035+00');
INSERT INTO public.products VALUES (318, 10, 21, 'Compact Car Vacuum', 'compact-car-vacuum', NULL, NULL, 149.50, NULL, 18, 10, NULL, 'CAR4M7P2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:12:10.483476+00', '2026-03-08 12:12:10.483476+00');
INSERT INTO public.products VALUES (319, 4, 2, 'Elegant Leather Wallet', 'elegant-leather-wallet', NULL, NULL, 59.90, NULL, 40, 10, NULL, 'WAL9T3X6', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:12:11.033986+00', '2026-03-08 12:12:11.033986+00');
INSERT INTO public.products VALUES (320, 4, 21, 'Premiumu Travel Case', 'premiumu-travel-case', NULL, NULL, 79.90, NULL, 25, 10, NULL, 'TRV8KU2L9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:15:31.322362+00', '2026-03-08 12:15:31.322362+00');
INSERT INTO public.products VALUES (321, 10, 21, 'Compuact Car Vacuum', 'compuact-car-vacuum', NULL, NULL, 149.50, NULL, 18, 10, NULL, 'CAR4UM7P2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:15:31.95771+00', '2026-03-08 12:15:31.95771+00');
INSERT INTO public.products VALUES (322, 4, 2, 'Elegaunte Leather Wallet', 'elegaunte-leather-wallet', NULL, NULL, 59.90, NULL, 40, 10, NULL, 'WAL9UT3X6E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:15:32.64318+00', '2026-03-08 12:15:32.64318+00');
INSERT INTO public.products VALUES (323, 10, 14, 'Universale Phone Holder', 'universale-phone-holder', NULL, NULL, 34.90, NULL, 62, 10, NULL, 'PHN7B5Q1E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:15:36.26855+00', '2026-03-08 12:15:36.26855+00');
INSERT INTO public.products VALUES (324, 4, 2, 'Durablee Travel Backpack', 'durablee-travel-backpack', NULL, NULL, 199.99, NULL, 12, 10, NULL, 'BAG2D8R4E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:15:36.810685+00', '2026-03-08 12:15:36.810685+00');
INSERT INTO public.products VALUES (325, 10, 14, 'Magnetiec Car Mount', 'magnetiec-car-mount', NULL, NULL, 24.75, NULL, 73, 10, NULL, 'MNT5Z1CE8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:15:37.343132+00', '2026-03-08 12:15:37.343132+00');
INSERT INTO public.products VALUES (349, 6, 17, 'Wirerless Sounrd Speaker', 'wirerless-sounrd-speaker', NULL, NULL, 219.50, NULL, 15, 10, NULL, 'SPRKRR4T8M3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:48:05.008456+00', '2026-03-08 12:48:05.008456+00');
INSERT INTO public.products VALUES (327, 4, 21, 'Pretmitumu Travel Case', 'pretmitumu-travel-case', NULL, NULL, 79.90, NULL, 25, 10, NULL, 'TRV8TKU2L9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:19:00.414919+00', '2026-03-08 12:19:00.414919+00');
INSERT INTO public.products VALUES (328, 10, 21, 'Comtttpuact Car Vacuum', 'comtttpuact-car-vacuum', NULL, NULL, 149.50, NULL, 18, 10, NULL, 'CAR4TTUM7P2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:19:00.989323+00', '2026-03-08 12:19:00.989323+00');
INSERT INTO public.products VALUES (329, 4, 2, 'Eltegtaunte Leather Wallet', 'eltegtaunte-leather-wallet', NULL, NULL, 59.90, NULL, 40, 10, NULL, 'WALT9UTT3X6E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:19:01.552041+00', '2026-03-08 12:19:01.552041+00');
INSERT INTO public.products VALUES (330, 10, 14, 'Univettrsale Phone Holder', 'univettrsale-phone-holder', NULL, NULL, 34.90, NULL, 62, 10, NULL, 'PHNT7TB5Q1E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:19:05.170903+00', '2026-03-08 12:19:05.170903+00');
INSERT INTO public.products VALUES (331, 4, 2, 'Durttablee Travel Backpack', 'durttablee-travel-backpack', NULL, NULL, 199.99, NULL, 12, 10, NULL, 'BAG2TTD8R4E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:19:05.889899+00', '2026-03-08 12:19:05.889899+00');
INSERT INTO public.products VALUES (332, 10, 14, 'Magnetttiec Car Mount', 'magnetttiec-car-mount', NULL, NULL, 24.75, NULL, 73, 10, NULL, 'MNT5ZT1CE8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:19:06.489222+00', '2026-03-08 12:19:06.489222+00');
INSERT INTO public.products VALUES (333, 4, 21, 'Pretmitumuy Travel Case', 'pretmitumuy-travel-case', NULL, NULL, 79.90, NULL, 25, 10, NULL, 'TRV8TYKU2L9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:21:18.991014+00', '2026-03-08 12:21:18.991014+00');
INSERT INTO public.products VALUES (334, 10, 21, 'Comttytpuact Car Vacuum', 'comttytpuact-car-vacuum', NULL, NULL, 149.50, NULL, 18, 10, NULL, 'CAR4TTYUM7P2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:21:19.650039+00', '2026-03-08 12:21:19.650039+00');
INSERT INTO public.products VALUES (335, 4, 2, 'Eltegtyaunte Leather Wallet', 'eltegtyaunte-leather-wallet', NULL, NULL, 59.90, NULL, 40, 10, NULL, 'WALT9UYTT3X6E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:21:20.242746+00', '2026-03-08 12:21:20.242746+00');
INSERT INTO public.products VALUES (336, 10, 14, 'Univettyrsale Phone Holder', 'univettyrsale-phone-holder', NULL, NULL, 34.90, NULL, 62, 10, NULL, 'PHNT7TYB5Q1E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:21:23.787044+00', '2026-03-08 12:21:23.787044+00');
INSERT INTO public.products VALUES (337, 4, 2, 'Duryttablee Travel Backpack', 'duryttablee-travel-backpack', NULL, NULL, 199.99, NULL, 12, 10, NULL, 'BAG2YTTD8R4E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:21:25.262449+00', '2026-03-08 12:21:25.262449+00');
INSERT INTO public.products VALUES (338, 10, 14, 'Magnyetttiec Car Mount', 'magnyetttiec-car-mount', NULL, NULL, 24.75, NULL, 73, 10, NULL, 'MNT5YZT1CE8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:21:25.82182+00', '2026-03-08 12:21:25.82182+00');
INSERT INTO public.products VALUES (339, 4, 21, 'Pretmitumuyu Travel Case', 'pretmitumuyu-travel-case', NULL, NULL, 79.90, NULL, 25, 10, NULL, 'TRV8TYKUU2L9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:22:39.540734+00', '2026-03-08 12:22:39.540734+00');
INSERT INTO public.products VALUES (340, 10, 21, 'Comttyutpuact Car Vacuum', 'comttyutpuact-car-vacuum', NULL, NULL, 149.50, NULL, 18, 10, NULL, 'CAR4TTYUUM7P2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:22:40.07079+00', '2026-03-08 12:22:40.07079+00');
INSERT INTO public.products VALUES (581, 13, 10, 'Produto 1777851229771', 'produto-1777851229771', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777851229771', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:33:49.914497+00', '2026-05-03 23:33:49.914497+00');
INSERT INTO public.products VALUES (351, 10, NULL, 'Stratregic Mind Games', 'stratregic-mind-games', NULL, NULL, 89.99, NULL, 21, 10, NULL, 'GMXR6RH3L8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:48:09.313087+00', '2026-03-08 12:48:09.313087+00');
INSERT INTO public.products VALUES (590, 13, 10, 'Produto 1777853579364', 'produto-1777853579364', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853579364', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:12:58.79128+00', '2026-05-04 00:12:58.79128+00');
INSERT INTO public.products VALUES (431, 10, 10, 'Maionese4 Gamer RGB', 'maionese4-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MUHH-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 13:46:53.981377+00', '2026-04-26 13:46:53.981377+00');
INSERT INTO public.products VALUES (345, 5, 1, 'Portable Desk Lamp', 'portable-desk-lamp', NULL, NULL, 45.90, NULL, 28, 10, NULL, 'LMP7K2Q9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:43:49.140617+00', '2026-03-08 12:43:49.140617+00');
INSERT INTO public.products VALUES (346, 4, 17, 'Portrable Desk Lamp', 'portrable-desk-lamp', NULL, NULL, 45.90, NULL, 28, 10, NULL, 'LMP7RRK2Q9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:47:34.41648+00', '2026-03-08 12:47:34.41648+00');
INSERT INTO public.products VALUES (347, 10, 14, 'Wirerless Sound Speaker', 'wirerless-sound-speaker', NULL, NULL, 219.50, NULL, 15, 10, NULL, 'SPRKR4T8M3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:47:34.962901+00', '2026-03-08 12:47:34.962901+00');
INSERT INTO public.products VALUES (348, 4, 17, 'Portrable Desrk Lamp', 'portrable-desrk-lamp', NULL, NULL, 45.90, NULL, 28, 10, NULL, 'LMPR7RRK2Q9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:48:04.357645+00', '2026-03-08 12:48:04.357645+00');
INSERT INTO public.products VALUES (841, 10, 10, 'Monitor LG', 'monitor-lg', NULL, NULL, 700.00, NULL, 120, 10, NULL, 'MGGP-22026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 20:11:58.632307+00', '2026-06-24 20:11:58.632307+00');
INSERT INTO public.products VALUES (451, 13, 10, 'Produto Validado em Estruuras', 'produto-validado-em-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'PRO-007', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 02:03:07.029309+00', '2026-04-27 02:03:07.029309+00');
INSERT INTO public.products VALUES (353, 4, 17, 'Portrrable Desrk Lamp', 'portrrable-desrk-lamp', NULL, NULL, 45.90, NULL, 28, 10, NULL, 'LMPR7RRRK2Q9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:49:06.284352+00', '2026-03-08 12:49:06.284352+00');
INSERT INTO public.products VALUES (459, 13, 10, 'ProdutoCiclo Duplo Validado em Aninhamentos com Estruuras', 'produtociclo-duplo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CICLOS-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 11:56:01.134216+00', '2026-04-27 11:56:01.134216+00');
INSERT INTO public.products VALUES (354, 10, 14, 'Wirerless Sounrrd Speaker', 'wirerless-sounrrd-speaker', NULL, NULL, 219.50, NULL, 15, 10, NULL, 'SPRKRRR4T8M3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:49:06.935796+00', '2026-03-08 12:49:06.935796+00');
INSERT INTO public.products VALUES (356, 10, 22, 'Stratregic Mind Grames', 'stratregic-mind-grames', NULL, NULL, 89.99, NULL, 21, 10, NULL, 'GMXR6RRH3L8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:49:11.158378+00', '2026-03-08 12:49:11.158378+00');
INSERT INTO public.products VALUES (358, 11, 17, 'Durabrle Pet Crarrier', 'durabrle-pet-crarrier', NULL, NULL, 129.75, NULL, 19, 10, NULL, 'PET5RNR8C6', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:49:12.330873+00', '2026-03-08 12:49:12.330873+00');
INSERT INTO public.products VALUES (605, 13, 10, 'Produto 1777854021760', 'produto-1777854021760', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777854021760', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:20:21.126168+00', '2026-05-04 00:20:21.126168+00');
INSERT INTO public.products VALUES (432, 10, 10, 'Maioneset  RGB', 'maioneset-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'AMUHH-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 13:48:27.58976+00', '2026-04-26 13:48:27.58976+00');
INSERT INTO public.products VALUES (445, 10, 10, 'PrordddutoValidadocom suvesso', 'prordddutovalidadocom-suvesso', NULL, NULL, 566.00, NULL, 50, 10, NULL, 'TrESTE-098', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 19:48:56.00999+00', '2026-04-26 19:48:56.00999+00');
INSERT INTO public.products VALUES (452, 13, 10, 'Produto Validado em Aninhamento com Estruuras', 'produto-validado-em-aninhamento-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'PRO-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 02:08:51.174498+00', '2026-04-27 02:08:51.174498+00');
INSERT INTO public.products VALUES (460, 13, 10, 'ProdutoCiclos Duplo Validado em Aninhamentos com Estruuras', 'produtociclos-duplo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CICLOSs-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 11:56:36.187152+00', '2026-04-27 11:56:36.187152+00');
INSERT INTO public.products VALUES (466, 13, 10, 'Produto 1777430705904', 'produto-1777430705904', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430705904', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:45:06.023461+00', '2026-04-29 02:45:06.023461+00');
INSERT INTO public.products VALUES (467, 13, 10, 'Produto 1777430714376', 'produto-1777430714376', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430714376', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:45:14.450408+00', '2026-04-29 02:45:14.450408+00');
INSERT INTO public.products VALUES (468, 13, 10, 'Produto 1777430717541', 'produto-1777430717541', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430717541', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:45:17.590136+00', '2026-04-29 02:45:17.590136+00');
INSERT INTO public.products VALUES (469, 13, 10, 'Produto 1777430724321', 'produto-1777430724321', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430724321', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:45:24.42928+00', '2026-04-29 02:45:24.42928+00');
INSERT INTO public.products VALUES (606, 13, 10, 'Produto 1777854021916', 'produto-1777854021916', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777854021916', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:20:21.196432+00', '2026-05-04 00:20:21.196432+00');
INSERT INTO public.products VALUES (582, 13, 10, 'Produto 1777851230333', 'produto-1777851230333', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777851230333', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:33:50.487785+00', '2026-05-03 23:33:50.487785+00');
INSERT INTO public.products VALUES (478, 13, 10, 'Produto 1777513688760', 'produto-1777513688760', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777513688760', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:48:09.185461+00', '2026-04-30 01:48:09.185461+00');
INSERT INTO public.products VALUES (479, 13, 10, 'Produto 1777513700712', 'produto-1777513700712', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777513700712', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:48:21.028045+00', '2026-04-30 01:48:21.028045+00');
INSERT INTO public.products VALUES (480, 13, 10, 'Produto 1777513706471', 'produto-1777513706471', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777513706471', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:48:26.759867+00', '2026-04-30 01:48:26.759867+00');
INSERT INTO public.products VALUES (488, 13, 10, 'Produto 1777596345812', 'produto-1777596345812', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777596345812', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-01 00:45:46.170099+00', '2026-05-01 00:45:46.170099+00');
INSERT INTO public.products VALUES (546, 13, 10, 'Produto 1777846820651', 'produto-1777846820651', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777846820651', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:20:20.357099+00', '2026-05-03 22:20:20.357099+00');
INSERT INTO public.products VALUES (832, 10, 10, 'PC para autistas', 'pc-para-autistas', NULL, NULL, 1000.90, NULL, 2, 10, NULL, 'PCTEA-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-17 00:16:13.757984+00', '2026-06-17 00:16:13.757984+00');
INSERT INTO public.products VALUES (609, 13, 10, 'Produto 1777854209167', 'produto-1777854209167', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777854209167', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:23:28.43948+00', '2026-05-04 00:23:28.43948+00');
INSERT INTO public.products VALUES (502, 13, 10, 'Produto 1777765756996', 'produto-1777765756996', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777765756996', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-02 23:49:15.851874+00', '2026-05-02 23:49:15.851874+00');
INSERT INTO public.products VALUES (501, 13, 10, 'Produto 1777765756950', 'produto-1777765756950', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777765756950', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-02 23:49:15.851868+00', '2026-05-02 23:49:15.851868+00');
INSERT INTO public.products VALUES (629, 13, 10, 'Produto 1777860212400', 'produto-1777860212400', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777860212400', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:03:32.58036+00', '2026-05-04 02:03:32.58036+00');
INSERT INTO public.products VALUES (613, 13, 10, 'Produto 1777854261102', 'produto-1777854261102', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777854261102', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:24:20.414184+00', '2026-05-04 00:24:20.414184+00');
INSERT INTO public.products VALUES (614, 13, 10, 'Produto 1777854261334', 'produto-1777854261334', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777854261334', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:24:20.598357+00', '2026-05-04 00:24:20.598357+00');
INSERT INTO public.products VALUES (509, 13, 10, 'Produto 1777766535088', 'produto-1777766535088', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777766535088', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 00:02:13.931568+00', '2026-05-03 00:02:13.931568+00');
INSERT INTO public.products VALUES (630, 13, 10, 'Produto 1777860213117', 'produto-1777860213117', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777860213117', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:03:33.286323+00', '2026-05-04 02:03:33.286323+00');
INSERT INTO public.products VALUES (557, 13, 10, 'Produto 1777847461975', 'produto-1777847461975', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777847461975', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:31:01.686121+00', '2026-05-03 22:31:01.686121+00');
INSERT INTO public.products VALUES (517, 13, 10, 'Produto 1777826042093', 'produto-1777826042093', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777826042093', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 16:34:01.688439+00', '2026-05-03 16:34:01.688439+00');
INSERT INTO public.products VALUES (842, 10, 10, 'Monitor Samsung', 'monitor-samsung', NULL, NULL, 700.00, NULL, 120, 10, NULL, 'MGPP-22026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 20:13:50.14327+00', '2026-06-24 20:13:50.14327+00');
INSERT INTO public.products VALUES (617, 13, 10, 'Produto 1777855617081', 'produto-1777855617081', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777855617081', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:46:56.297009+00', '2026-05-04 00:46:56.297009+00');
INSERT INTO public.products VALUES (561, 13, 10, 'Produto 1777849103067', 'produto-1777849103067', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777849103067', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:58:22.649649+00', '2026-05-03 22:58:22.649649+00');
INSERT INTO public.products VALUES (597, 13, 10, 'Produto 1777853820757', 'produto-1777853820757', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853820757', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:17:00.066531+00', '2026-05-04 00:17:00.066531+00');
INSERT INTO public.products VALUES (631, 10, 989, 'Moetruse Gamer RGB', 'moetruse-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MteGP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:03:37.322863+00', '2026-05-04 02:03:37.322863+00');
INSERT INTO public.products VALUES (601, 13, 10, 'Produto 1777853939411', 'produto-1777853939411', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853939411', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:18:58.696378+00', '2026-05-04 00:18:58.696378+00');
INSERT INTO public.products VALUES (602, 13, 10, 'Produto 1777853939544', 'produto-1777853939544', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853939544', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:18:58.837932+00', '2026-05-04 00:18:58.837932+00');
INSERT INTO public.products VALUES (537, 13, 10, 'Produto 1777838836669', 'produto-1777838836669', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777838836669', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 20:07:16.811055+00', '2026-05-03 20:07:16.811055+00');
INSERT INTO public.products VALUES (538, 13, 10, 'Produto 1777838837197', 'produto-1777838837197', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777838837197', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 20:07:17.345355+00', '2026-05-03 20:07:17.345355+00');
INSERT INTO public.products VALUES (621, 13, 10, 'Produto 1777855661886', 'produto-1777855661886', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777855661886', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:47:41.172886+00', '2026-05-04 00:47:41.172886+00');
INSERT INTO public.products VALUES (637, 13, 10, 'Produto 1777860752079', 'produto-1777860752079', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777860752079', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:12:31.023851+00', '2026-05-04 02:12:31.023851+00');
INSERT INTO public.products VALUES (569, 13, 10, 'Produto 1777850787610', 'produto-1777850787610', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777850787610', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:26:27.10511+00', '2026-05-03 23:26:27.10511+00');
INSERT INTO public.products VALUES (625, 13, 10, 'Produto 1777855981270', 'produto-1777855981270', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777855981270', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:53:01.422437+00', '2026-05-04 00:53:01.422437+00');
INSERT INTO public.products VALUES (669, 13, 10, 'Produto 1778031284645', 'produto-1778031284645', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031284645', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:34:44.828855+00', '2026-05-06 01:34:44.828855+00');
INSERT INTO public.products VALUES (670, 13, 10, 'Produto 1778031285321', 'produto-1778031285321', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031285321', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:34:45.499838+00', '2026-05-06 01:34:45.499838+00');
INSERT INTO public.products VALUES (681, 13, 10, 'Produto 1778031536236', 'produto-1778031536236', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031536236', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:38:56.3964+00', '2026-05-06 01:38:56.3964+00');
INSERT INTO public.products VALUES (682, 13, 10, 'Produto 1778031536769', 'produto-1778031536769', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031536769', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:38:56.916122+00', '2026-05-06 01:38:56.916122+00');
INSERT INTO public.products VALUES (355, 10, 8, 'Classric Corrtton Jacket', 'classric-corrtton-jacket', NULL, NULL, 159.90, NULL, 33, 10, NULL, 'JCRKR9RRP5R1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:49:07.511619+00', '2026-03-08 12:49:07.511619+00');
INSERT INTO public.products VALUES (425, 10, 10, 'ProdutoValidadocom suvesso', 'produtovalidadocom-suvesso', NULL, NULL, 566.00, NULL, 50, 10, NULL, 'FOR-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 13:31:57.648899+00', '2026-04-26 13:31:57.648899+00');
INSERT INTO public.products VALUES (359, 4, 17, 'Potrttrrable Desrk Lamp', 'potrttrrable-desrk-lamp', NULL, NULL, 45.90, NULL, 28, 10, NULL, 'LMPRTK2Q9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:55:47.717349+00', '2026-03-08 12:55:47.717349+00');
INSERT INTO public.products VALUES (446, 10, 10, 'Canetinha Gamer RGB', 'canetinha-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGPA-20245', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 19:56:28.357235+00', '2026-04-26 19:56:28.357235+00');
INSERT INTO public.products VALUES (361, 10, 8, 'Clastttsric Corrtton Jacket', 'clastttsric-corrtton-jacket', NULL, NULL, 159.90, NULL, 33, 10, NULL, 'JCTRRP5R1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:55:49.06648+00', '2026-03-08 12:55:49.06648+00');
INSERT INTO public.products VALUES (362, 10, 22, 'Stratttregic Mind Grames', 'stratttregic-mind-grames', NULL, NULL, 89.99, NULL, 21, 10, NULL, 'GMXTR3L8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:55:52.638781+00', '2026-03-08 12:55:52.638781+00');
INSERT INTO public.products VALUES (833, 11, 11, 'Hellen Computadores', 'hellen-computadores', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'Hell-2000', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-17 00:26:03.355321+00', '2026-06-17 00:26:03.355321+00');
INSERT INTO public.products VALUES (364, 4, 17, 'Potrttrrrable Desrk Lamp', 'potrttrrrable-desrk-lamp', NULL, NULL, 45.90, NULL, 28, 10, NULL, 'LMPRTRK2Q9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:56:47.44125+00', '2026-03-08 12:56:47.44125+00');
INSERT INTO public.products VALUES (365, 10, 14, 'Wirtertless Sounrrrd Speaker', 'wirtertless-sounrrrd-speaker', NULL, NULL, 219.50, NULL, 15, 10, NULL, 'SPRRT4T8M3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:56:48.045216+00', '2026-03-08 12:56:48.045216+00');
INSERT INTO public.products VALUES (366, 4, 17, 'Potrtrable Desrk Lamp', 'potrtrable-desrk-lamp', NULL, NULL, 45.90, NULL, 28, 10, NULL, 'LMPRK2Q9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:57:34.912337+00', '2026-03-08 12:57:34.912337+00');
INSERT INTO public.products VALUES (367, 10, 14, 'Wirteess Sounrrrd Speaker', 'wirteess-sounrrrd-speaker', NULL, NULL, 219.50, NULL, 15, 10, NULL, 'SPT4T8M3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:57:35.564889+00', '2026-03-08 12:57:35.564889+00');
INSERT INTO public.products VALUES (368, 10, 8, 'Clasttic Corrtton Jacket', 'clasttic-corrtton-jacket', NULL, NULL, 159.90, NULL, 33, 10, NULL, 'JRCP5R1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:57:36.088293+00', '2026-03-08 12:57:36.088293+00');
INSERT INTO public.products VALUES (593, 13, 10, 'Produto 1777853736922', 'produto-1777853736922', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853736922', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:15:36.228513+00', '2026-05-04 00:15:36.228513+00');
INSERT INTO public.products VALUES (433, 10, 10, 'Maionesett  RGB', 'maionesett-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'AMUuHH-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 13:50:14.266651+00', '2026-04-26 13:50:14.266651+00');
INSERT INTO public.products VALUES (371, 11, 17, 'Durtabe Pet Crrarrier', 'durtabe-pet-crrarrier', NULL, NULL, 129.75, NULL, 19, 10, NULL, 'PET5TR6', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:57:42.470149+00', '2026-03-08 12:57:42.470149+00');
INSERT INTO public.products VALUES (372, 4, 17, 'Teclado Pequeno de Macio', 'teclado-pequeno-de-macio', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'ISWZ5PDK', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:11:01.400629+00', '2026-03-09 00:11:01.400629+00');
INSERT INTO public.products VALUES (843, 10, 10, 'Tugrik', 'tugrik', NULL, NULL, 200.00, NULL, 50, 10, NULL, 'virtual', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:14:29.218661+00', '2026-06-24 23:14:29.218661+00');
INSERT INTO public.products VALUES (373, 4, 17, 'Elegant Rubber Soap', 'elegant-rubber-soap', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'LIRGIKON', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:13:02.094739+00', '2026-03-09 00:13:02.094739+00');
INSERT INTO public.products VALUES (598, 13, 10, 'Produto 1777853820834', 'produto-1777853820834', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853820834', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:17:00.126999+00', '2026-05-04 00:17:00.126999+00');
INSERT INTO public.products VALUES (374, 4, 17, 'Modern Marble Fish', 'modern-marble-fish', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'GXPO1HQD', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:16:46.806775+00', '2026-03-09 00:16:46.806775+00');
INSERT INTO public.products VALUES (375, 4, 17, 'Salsicha Refinado de Metal', 'salsicha-refinado-de-metal', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'PZD4AY8G', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:26:22.244173+00', '2026-03-09 00:26:22.244173+00');
INSERT INTO public.products VALUES (376, 4, 17, 'Toalhas Gostoso de Madeira', 'toalhas-gostoso-de-madeira', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'QECUJOFQ', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:27:42.008537+00', '2026-03-09 00:27:42.008537+00');
INSERT INTO public.products VALUES (386, 4, 17, 'Fresh Aluminum Bike', 'fresh-aluminum-bike', NULL, NULL, 30.00, NULL, 2, 10, NULL, 'VGMO7CBB', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:52:22.48332+00', '2026-03-09 00:52:22.48332+00');
INSERT INTO public.products VALUES (377, 4, 17, 'Licensed Marble Sausages', 'licensed-marble-sausages', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'GHTSVFJV', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:28:18.187521+00', '2026-03-09 00:28:18.187521+00');
INSERT INTO public.products VALUES (378, 4, 17, 'Oriental Metal Fish', 'oriental-metal-fish', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'MMBAXSO0', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:29:35.4075+00', '2026-03-09 00:29:35.4075+00');
INSERT INTO public.products VALUES (379, 4, 17, 'Luvas Gostoso de Metal', 'luvas-gostoso-de-metal', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'SEX4LLRI', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:35:50.212323+00', '2026-03-09 00:35:50.212323+00');
INSERT INTO public.products VALUES (381, 4, 17, 'Elegant Steel Chair', 'elegant-steel-chair', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'AGNMOASR', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:38:26.056433+00', '2026-03-09 00:38:26.056433+00');
INSERT INTO public.products VALUES (382, 4, 17, 'Unbranded Ceramic Pants', 'unbranded-ceramic-pants', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'JI93EYN3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:41:03.589073+00', '2026-03-09 00:41:03.589073+00');
INSERT INTO public.products VALUES (383, 4, 17, 'Elegant Gold Chicken', 'elegant-gold-chicken', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'BKEBGN5E', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:43:05.51354+00', '2026-03-09 00:43:05.51354+00');
INSERT INTO public.products VALUES (384, 4, 17, 'Refined Bamboo Keyboard', 'refined-bamboo-keyboard', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'B4YIGKAD', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:46:39.251963+00', '2026-03-09 00:46:39.251963+00');
INSERT INTO public.products VALUES (385, 4, 17, 'Frozen Steel Hat', 'frozen-steel-hat', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'RPE08KJ2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:52:06.776449+00', '2026-03-09 00:52:06.776449+00');
INSERT INTO public.products VALUES (387, 4, 17, 'Practical Cotton Gloves', 'practical-cotton-gloves', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'GBPSSAR1', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:52:24.731621+00', '2026-03-09 00:52:24.731621+00');
INSERT INTO public.products VALUES (388, 4, 17, 'Rustic Marble Chicken', 'rustic-marble-chicken', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'CIIKXNSH', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:53:30.003608+00', '2026-03-09 00:53:30.003608+00');
INSERT INTO public.products VALUES (389, 4, 17, 'Unbranded Bamboo Table', 'unbranded-bamboo-table', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'VDLQFGZ2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 00:54:34.542671+00', '2026-03-09 00:54:34.542671+00');
INSERT INTO public.products VALUES (390, 4, 17, 'Elegant Wooden Cheese', 'elegant-wooden-cheese', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'ZNZNU68C', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 01:02:15.053101+00', '2026-03-09 01:02:15.053101+00');
INSERT INTO public.products VALUES (391, 4, 17, 'Small Concrete Chips', 'small-concrete-chips', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'NNJEZSDD', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 01:02:27.190299+00', '2026-03-09 01:02:27.190299+00');
INSERT INTO public.products VALUES (392, 4, 17, 'Recycled Cotton Sausages', 'recycled-cotton-sausages', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'S8HNYX0P', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 01:10:38.894366+00', '2026-03-09 01:10:38.894366+00');
INSERT INTO public.products VALUES (393, 4, 17, 'Generic Rubber Bike', 'generic-rubber-bike', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'OHBOK8GP', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 01:11:33.310097+00', '2026-03-09 01:11:33.310097+00');
INSERT INTO public.products VALUES (394, 4, 17, 'Handcrafted Gold Pants', 'handcrafted-gold-pants', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'MYH0XQQC', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 01:12:22.273065+00', '2026-03-09 01:12:22.273065+00');
INSERT INTO public.products VALUES (395, 4, 17, 'Intelligent Cotton Chair', 'intelligent-cotton-chair', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'BBGC5CPJ', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-09 01:13:16.500958+00', '2026-03-09 01:13:16.500958+00');
INSERT INTO public.products VALUES (396, 4, 17, 'Handcrafted Gold Gloves', 'handcrafted-gold-gloves', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'AZVBS4TR', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-10 12:08:37.466108+00', '2026-03-10 12:08:37.466108+00');
INSERT INTO public.products VALUES (397, 4, 17, 'Oriental Plastic Chicken', 'oriental-plastic-chicken', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'AYKHQJBC', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-10 12:09:37.019588+00', '2026-03-10 12:09:37.019588+00');
INSERT INTO public.products VALUES (399, 4, 17, 'Recycled Concrete Keyboard', 'recycled-concrete-keyboard', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'IYULIMEW', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-10 12:11:05.610453+00', '2026-03-10 12:11:05.610453+00');
INSERT INTO public.products VALUES (400, 4, 17, 'Intelligent Bamboo Chair', 'intelligent-bamboo-chair', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'LSBBHRAB', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-21 18:23:04.782624+00', '2026-03-21 18:23:04.782624+00');
INSERT INTO public.products VALUES (401, 4, 17, 'Intelligent Bamboo Hat', 'intelligent-bamboo-hat', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'VTWWWEWI', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-21 18:27:20.975707+00', '2026-03-21 18:27:20.975707+00');
INSERT INTO public.products VALUES (402, 4, 17, 'Bespoke Steel Chair', 'bespoke-steel-chair', NULL, NULL, 49.90, NULL, 10, 10, NULL, 'ZHBFNTQV', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-21 18:27:23.214461+00', '2026-03-21 18:27:23.214461+00');
INSERT INTO public.products VALUES (404, 4, 17, 'Intelligent Concrete Chicken', 'intelligent-concrete-chicken', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'SAS3Y4HJ', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-21 18:28:25.898237+00', '2026-03-21 18:28:25.898237+00');
INSERT INTO public.products VALUES (405, 4, 17, 'Calca Jeans Pretat', 'calca-jeans-pretat', NULL, NULL, 23.00, NULL, 23, 10, NULL, 'SHOES-BR-0054', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-21 18:54:17.408446+00', '2026-03-21 18:54:17.408446+00');
INSERT INTO public.products VALUES (360, 2, 22, 'Wirtertless Sounrrd Speaker', 'wirtertless-sounrrd-speaker', NULL, NULL, 219.50, NULL, 15, 10, NULL, 'SPRT4T8M3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:55:48.397951+00', '2026-03-08 12:55:48.397951+00');
INSERT INTO public.products VALUES (370, NULL, NULL, 'Novo Nome', 'novo-nome', NULL, NULL, 30.00, NULL, 10, 10, NULL, 'LKI-7675', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:57:41.069593+00', '2026-03-08 12:57:41.069593+00');
INSERT INTO public.products VALUES (369, 12, NULL, 'Strattegic Mirndrames', 'strattegic-mirndrames', NULL, NULL, 89.99, NULL, 21, 10, NULL, 'GMXTL8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:57:40.532449+00', '2026-03-08 12:57:40.532449+00');
INSERT INTO public.products VALUES (408, 4, NULL, 'Calca Jeans Pretatrtr', 'calca-jeans-pretatrtr', NULL, NULL, 435.00, NULL, 60, 10, NULL, 'SHOES-BR-RRR6', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-31 01:06:50.693591+00', '2026-03-31 01:06:50.693591+00');
INSERT INTO public.products VALUES (834, 10, 10, 'Maouse Gamer RGB', 'maouse-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'aMGP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-19 20:07:17.513497+00', '2026-06-19 20:07:17.513497+00');
INSERT INTO public.products VALUES (610, 13, 10, 'Produto 1777854209149', 'produto-1777854209149', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777854209149', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:23:28.460255+00', '2026-05-04 00:23:28.460255+00');
INSERT INTO public.products VALUES (410, 10, 10, 'Mowuse Gamer RGB', 'mowuse-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MwGP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-04 17:10:03.46138+00', '2026-04-04 17:10:03.46138+00');
INSERT INTO public.products VALUES (653, 13, 10, 'Produto 1777862943583', 'produto-1777862943583', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777862943583', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:49:03.754917+00', '2026-05-04 02:49:03.754917+00');
INSERT INTO public.products VALUES (844, 10, 10, 'Denar', 'denar', NULL, NULL, 200.00, NULL, 50, 10, NULL, 'user-centric', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:14:59.335797+00', '2026-06-24 23:14:59.335797+00');
INSERT INTO public.products VALUES (409, 20, 8, 'Moeuse Gamer RGB', 'moeuse-gamer-rgb', NULL, NULL, 2399.90, NULL, 50, 10, NULL, 'MEGP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-03 23:38:55.163076+00', '2026-04-03 23:38:55.163076+00');
INSERT INTO public.products VALUES (411, 9, 22, 'Mouser Gamer RGB', 'mouser-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGPO-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-11 00:28:27.980714+00', '2026-04-11 00:28:27.980714+00');
INSERT INTO public.products VALUES (412, 4, 22, 'rreer erwere', 'rreer-erwere', NULL, NULL, 4434.00, NULL, 34, 10, NULL, 'TTTTGT4', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-17 17:43:37.013729+00', '2026-04-17 17:43:37.013729+00');
INSERT INTO public.products VALUES (413, 2, 7, 'Mochila Guerreira', 'mochila-guerreira', NULL, NULL, 234.00, NULL, 34, 10, NULL, 'CAP-PR-0114', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-21 16:14:28.306234+00', '2026-04-21 16:14:28.306234+00');
INSERT INTO public.products VALUES (414, 2, 7, 'Caderno liso', 'caderno-liso', NULL, NULL, 34.00, NULL, 2, 10, NULL, 'CPP-PR-091', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-21 16:34:30.56044+00', '2026-04-21 16:34:30.56044+00');
INSERT INTO public.products VALUES (851, 20, 10, 'Upton', 'upton', NULL, NULL, 45.00, NULL, 50, 10, NULL, 'o', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-25 00:31:13.3722+00', '2026-06-25 00:31:13.3722+00');
INSERT INTO public.products VALUES (447, 10, 10, 'Canettrinha Gamer RGB', 'canettrinha-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGtPA-20245', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-26 20:00:28.251336+00', '2026-04-26 20:00:28.251336+00');
INSERT INTO public.products VALUES (453, 13, 10, 'Produto Validado em Aninhamentos com Estruuras', 'produto-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'PROS-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-27 02:18:13.965473+00', '2026-04-27 02:18:13.965473+00');
INSERT INTO public.products VALUES (461, 13, 10, 'ProdttutoCiclos Duplo Validado em Aninhamentos com Estruuras', 'prodttutociclos-duplo-validado-em-aninhamentos-com-estruuras', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'CICtLOSs-0078', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:14:09.133248+00', '2026-04-29 02:14:09.133248+00');
INSERT INTO public.products VALUES (472, 13, 10, 'Produto 1777430791248', 'produto-1777430791248', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777430791248', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-29 02:46:31.306949+00', '2026-04-29 02:46:31.306949+00');
INSERT INTO public.products VALUES (481, 13, 10, 'Produto 1777514081206', 'produto-1777514081206', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777514081206', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:54:41.485908+00', '2026-04-30 01:54:41.485908+00');
INSERT INTO public.products VALUES (482, 13, 10, 'Produto 1777514088523', 'produto-1777514088523', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777514088523', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-04-30 01:54:48.81858+00', '2026-04-30 01:54:48.81858+00');
INSERT INTO public.products VALUES (489, 13, 10, 'Produto 1777597508683', 'produto-1777597508683', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777597508683', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-01 01:05:08.979956+00', '2026-05-01 01:05:08.979956+00');
INSERT INTO public.products VALUES (490, 13, 10, 'Produto 1777597509272', 'produto-1777597509272', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777597509272', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-01 01:05:09.523132+00', '2026-05-01 01:05:09.523132+00');
INSERT INTO public.products VALUES (618, 13, 10, 'Produto 1777855617200', 'produto-1777855617200', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777855617200', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:46:56.520539+00', '2026-05-04 00:46:56.520539+00');
INSERT INTO public.products VALUES (677, 13, 10, 'Produto 1778031505082', 'produto-1778031505082', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031505082', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:38:25.267861+00', '2026-05-06 01:38:25.267861+00');
INSERT INTO public.products VALUES (493, 13, 10, 'Produto 1777597535863', 'produto-1777597535863', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777597535863', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-01 01:05:36.072844+00', '2026-05-01 01:05:36.072844+00');
INSERT INTO public.products VALUES (494, 13, 10, 'Produto 1777597536259', 'produto-1777597536259', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777597536259', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-01 01:05:36.438347+00', '2026-05-01 01:05:36.438347+00');
INSERT INTO public.products VALUES (622, 13, 10, 'Produto 1777855662008', 'produto-1777855662008', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777855662008', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:47:41.205673+00', '2026-05-04 00:47:41.205673+00');
INSERT INTO public.products VALUES (856, 10, 10, 'Handmade Frozen Chicken 273', 'handmade-frozen-chicken-273', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'ubiquitous', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-27 23:29:29.046091+00', '2026-06-27 23:29:29.046091+00');
INSERT INTO public.products VALUES (594, 13, 10, 'Produto 1777853737040', 'produto-1777853737040', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777853737040', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:15:36.416856+00', '2026-05-04 00:15:36.416856+00');
INSERT INTO public.products VALUES (510, 13, 10, 'Produto 1777766535213', 'produto-1777766535213', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777766535213', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 00:02:13.998168+00', '2026-05-03 00:02:13.998168+00');
INSERT INTO public.products VALUES (513, 13, 10, 'Produto 1777823488733', 'produto-1777823488733', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777823488733', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 15:51:28.452829+00', '2026-05-03 15:51:28.452829+00');
INSERT INTO public.products VALUES (518, 13, 10, 'Produto 1777826042182', 'produto-1777826042182', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777826042182', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 16:34:01.80733+00', '2026-05-03 16:34:01.80733+00');
INSERT INTO public.products VALUES (641, 13, 10, 'Produto 1777861775697', 'produto-1777861775697', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777861775697', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:29:35.843659+00', '2026-05-04 02:29:35.843659+00');
INSERT INTO public.products VALUES (626, 13, 10, 'Produto 1777855981862', 'produto-1777855981862', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777855981862', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 00:53:02.016171+00', '2026-05-04 00:53:02.016171+00');
INSERT INTO public.products VALUES (541, 13, 10, 'Produto 1777846782116', 'produto-1777846782116', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777846782116', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:19:41.834235+00', '2026-05-03 22:19:41.834235+00');
INSERT INTO public.products VALUES (553, 13, 10, 'Produto 1777847366506', 'produto-1777847366506', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777847366506', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:29:26.174225+00', '2026-05-03 22:29:26.174225+00');
INSERT INTO public.products VALUES (558, 13, 10, 'Produto 1777847461990', 'produto-1777847461990', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777847461990', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:31:01.840916+00', '2026-05-03 22:31:01.840916+00');
INSERT INTO public.products VALUES (562, 13, 10, 'Produto 1777849103289', 'produto-1777849103289', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777849103289', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 22:58:22.979111+00', '2026-05-03 22:58:22.979111+00');
INSERT INTO public.products VALUES (565, 13, 10, 'Produto 1777850685588', 'produto-1777850685588', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777850685588', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:24:45.064875+00', '2026-05-03 23:24:45.064875+00');
INSERT INTO public.products VALUES (570, 13, 10, 'Produto 1777850787637', 'produto-1777850787637', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777850787637', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:26:27.123502+00', '2026-05-03 23:26:27.123502+00');
INSERT INTO public.products VALUES (573, 13, 10, 'Produto 1777850896184', 'produto-1777850896184', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777850896184', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-03 23:28:15.664309+00', '2026-05-03 23:28:15.664309+00');
INSERT INTO public.products VALUES (657, 13, 10, 'Produto 1777863265961', 'produto-1777863265961', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777863265961', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:54:26.095768+00', '2026-05-04 02:54:26.095768+00');
INSERT INTO public.products VALUES (645, 13, 10, 'Produto 1777862351236', 'produto-1777862351236', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777862351236', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:39:11.390787+00', '2026-05-04 02:39:11.390787+00');
INSERT INTO public.products VALUES (673, 13, 10, 'Produto 1778031431547', 'produto-1778031431547', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031431547', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:37:11.734192+00', '2026-05-06 01:37:11.734192+00');
INSERT INTO public.products VALUES (633, 13, 10, 'Produto 1777860668309', 'produto-1777860668309', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777860668309', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:11:08.689262+00', '2026-05-04 02:11:08.689262+00');
INSERT INTO public.products VALUES (634, 13, 10, 'Produto 1777860669302', 'produto-1777860669302', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777860669302', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:11:09.440706+00', '2026-05-04 02:11:09.440706+00');
INSERT INTO public.products VALUES (661, 13, 10, 'Produto 1778030328880', 'produto-1778030328880', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778030328880', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:18:49.078671+00', '2026-05-06 01:18:49.078671+00');
INSERT INTO public.products VALUES (649, 13, 10, 'Produto 1777862676880', 'produto-1777862676880', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1777862676880', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-04 02:44:37.03716+00', '2026-05-04 02:44:37.03716+00');
INSERT INTO public.products VALUES (662, 13, 10, 'Produto 1778030329577', 'produto-1778030329577', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778030329577', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:18:49.77152+00', '2026-05-06 01:18:49.77152+00');
INSERT INTO public.products VALUES (674, 13, 10, 'Produto 1778031432230', 'produto-1778031432230', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031432230', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:37:12.411715+00', '2026-05-06 01:37:12.411715+00');
INSERT INTO public.products VALUES (678, 13, 10, 'Produto 1778031505669', 'produto-1778031505669', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031505669', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:38:25.843088+00', '2026-05-06 01:38:25.843088+00');
INSERT INTO public.products VALUES (835, 10, 10, 'HellenPCS', 'hellenpcs', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'Hell-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-19 20:09:53.067274+00', '2026-06-19 20:09:53.067274+00');
INSERT INTO public.products VALUES (845, 20, 10, 'Mousee Pad RGB', 'mousee-pad-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MOUUS-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:38:12.283924+00', '2026-06-24 23:38:12.283924+00');
INSERT INTO public.products VALUES (857, 10, 10, 'Refined Frozen Table 271', 'refined-frozen-table-271', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'end-to-end', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-27 23:29:54.736429+00', '2026-06-27 23:29:54.736429+00');
INSERT INTO public.products VALUES (858, 10, 10, 'Awesome Concrete Computer 60', 'awesome-concrete-computer-60', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'back-end', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-27 23:30:00.436258+00', '2026-06-27 23:30:00.436258+00');
INSERT INTO public.products VALUES (363, 10, 14, 'Advtatrnced Codingr Guide', 'advtatrnced-codingr-guide', NULL, NULL, 75.00, NULL, 2000, 10, NULL, 'BOTRZ704', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:55:54.076992+00', '2026-03-08 12:55:54.076992+00');
INSERT INTO public.products VALUES (685, 13, 10, 'Produto 1778031855782', 'produto-1778031855782', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031855782', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:44:15.396237+00', '2026-05-06 01:44:15.396237+00');
INSERT INTO public.products VALUES (686, 13, 10, 'Produto 1778031855877', 'produto-1778031855877', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778031855877', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:44:15.471859+00', '2026-05-06 01:44:15.471859+00');
INSERT INTO public.products VALUES (846, 20, 10, 'Mousefe Pad RGB', 'mousefe-pad-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MOUUS-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:42:26.596568+00', '2026-06-24 23:42:26.596568+00');
INSERT INTO public.products VALUES (852, 20, 10, 'Baumbach', 'baumbach', NULL, NULL, 45.00, NULL, 50, 10, NULL, 'MCO-2020', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-26 00:36:13.310218+00', '2026-06-26 00:36:13.310218+00');
INSERT INTO public.products VALUES (689, 13, 10, 'Produto 1778032083207', 'produto-1778032083207', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778032083207', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:48:03.413054+00', '2026-05-06 01:48:03.413054+00');
INSERT INTO public.products VALUES (690, 13, 10, 'Produto 1778032083783', 'produto-1778032083783', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778032083783', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:48:03.921192+00', '2026-05-06 01:48:03.921192+00');
INSERT INTO public.products VALUES (859, 10, 10, 'Handcrafted Rubber Chips 277', 'handcrafted-rubber-chips-277', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'value-added', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-27 23:31:12.799138+00', '2026-06-27 23:31:12.799138+00');
INSERT INTO public.products VALUES (357, 10, 10, 'Produto Via Playwright', 'produto-via-playwright', NULL, NULL, 1000.00, NULL, 1000, 10, NULL, 'NOV-098', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-08 12:49:11.772195+00', '2026-03-08 12:49:11.772195+00');
INSERT INTO public.products VALUES (693, 13, 10, 'Produto 1778032653525', 'produto-1778032653525', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778032653525', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:57:33.71822+00', '2026-05-06 01:57:33.71822+00');
INSERT INTO public.products VALUES (694, 13, 10, 'Produto 1778032654225', 'produto-1778032654225', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778032654225', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 01:57:34.416745+00', '2026-05-06 01:57:34.416745+00');
INSERT INTO public.products VALUES (725, 10, 10, 'Moused Gamer RGB', 'moused-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGPd-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-17 19:14:07.657333+00', '2026-05-17 19:14:07.657333+00');
INSERT INTO public.products VALUES (697, 13, 10, 'Produto 1778032833539', 'produto-1778032833539', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778032833539', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 02:00:33.723037+00', '2026-05-06 02:00:33.723037+00');
INSERT INTO public.products VALUES (698, 13, 10, 'Produto 1778032834244', 'produto-1778032834244', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778032834244', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 02:00:34.435318+00', '2026-05-06 02:00:34.435318+00');
INSERT INTO public.products VALUES (701, 13, 10, 'Produto 1778034232886', 'produto-1778034232886', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778034232886', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 02:23:53.095771+00', '2026-05-06 02:23:53.095771+00');
INSERT INTO public.products VALUES (702, 13, 10, 'Produto 1778034233629', 'produto-1778034233629', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778034233629', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 02:23:53.833555+00', '2026-05-06 02:23:53.833555+00');
INSERT INTO public.products VALUES (727, 10, 10, 'Mouse TriploX', 'mouse-triplox', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MOU-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-17 19:59:12.815628+00', '2026-05-17 19:59:12.815628+00');
INSERT INTO public.products VALUES (705, 13, 10, 'Produto 1778035305941', 'produto-1778035305941', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778035305941', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 02:41:46.08239+00', '2026-05-06 02:41:46.08239+00');
INSERT INTO public.products VALUES (706, 13, 10, 'Produto 1778035306460', 'produto-1778035306460', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778035306460', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-06 02:41:46.601043+00', '2026-05-06 02:41:46.601043+00');
INSERT INTO public.products VALUES (728, 10, 10, 'Mousef Gamer RGB', 'mousef-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGfP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-19 11:57:04.056283+00', '2026-05-19 11:57:04.056283+00');
INSERT INTO public.products VALUES (709, 13, 10, 'Produto 1778200431263', 'produto-1778200431263', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778200431263', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-08 00:33:51.153019+00', '2026-05-08 00:33:51.153019+00');
INSERT INTO public.products VALUES (710, 13, 10, 'Produto 1778200431689', 'produto-1778200431689', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778200431689', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-08 00:33:51.551179+00', '2026-05-08 00:33:51.551179+00');
INSERT INTO public.products VALUES (713, 13, 10, 'Produto 1778208148271', 'produto-1778208148271', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778208148271', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-08 02:42:28.486376+00', '2026-05-08 02:42:28.486376+00');
INSERT INTO public.products VALUES (714, 13, 10, 'Produto 1778208149023', 'produto-1778208149023', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778208149023', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-08 02:42:29.204064+00', '2026-05-08 02:42:29.204064+00');
INSERT INTO public.products VALUES (729, 10, 10, 'Mouse Gamer RGB Triplos X', 'mouse-gamer-rgb-triplos-x', NULL, NULL, 700.00, NULL, 30, 10, NULL, 'MGP-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 02:24:40.340541+00', '2026-05-23 02:24:40.340541+00');
INSERT INTO public.products VALUES (717, 13, 10, 'Produto 1778256897153', 'produto-1778256897153', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778256897153', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-08 16:14:57.679653+00', '2026-05-08 16:14:57.679653+00');
INSERT INTO public.products VALUES (718, 13, 10, 'Produto 1778256898156', 'produto-1778256898156', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778256898156', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-08 16:14:58.339519+00', '2026-05-08 16:14:58.339519+00');
INSERT INTO public.products VALUES (721, 13, 10, 'Produto 1778287121829', 'produto-1778287121829', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778287121829', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-09 00:38:42.020938+00', '2026-05-09 00:38:42.020938+00');
INSERT INTO public.products VALUES (722, 13, 10, 'Produto 1778287122447', 'produto-1778287122447', NULL, NULL, 1234.00, NULL, 350, 10, NULL, 'SKU-1778287122447', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-09 00:38:42.445109+00', '2026-05-09 00:38:42.445109+00');
INSERT INTO public.products VALUES (730, 10, 10, 'Moourse Gamer RGB Triplos X', 'moourse-gamer-rgb-triplos-x', NULL, NULL, 700.00, NULL, 30, 10, NULL, 'MrGP-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 02:29:54.34571+00', '2026-05-23 02:29:54.34571+00');
INSERT INTO public.products VALUES (731, 10, 10, 'Notebook Dell', 'notebook-dell', NULL, NULL, 3500.00, NULL, 30, 10, NULL, 'AAA-1234', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 03:09:14.189168+00', '2026-05-23 03:09:14.189168+00');
INSERT INTO public.products VALUES (732, 10, 10, 'Mousee Gamer RGB', 'mousee-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGRR-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 14:10:14.719405+00', '2026-05-23 14:10:14.719405+00');
INSERT INTO public.products VALUES (733, 10, 10, 'Mootrse Gamer RGB Triplos X', 'mootrse-gamer-rgb-triplos-x', NULL, NULL, 700.00, NULL, 30, 10, NULL, 'MAGP-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 14:18:00.793298+00', '2026-05-23 14:18:00.793298+00');
INSERT INTO public.products VALUES (734, 10, 10, 'Monito Gamer RGB', 'monito-gamer-rgb', NULL, NULL, 700.00, NULL, 30, 10, NULL, 'AAAP-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 14:28:30.171709+00', '2026-05-23 14:28:30.171709+00');
INSERT INTO public.products VALUES (735, 10, 10, 'Monitor TVAA', 'monitor-tvaa', NULL, NULL, 700.00, NULL, 30, 10, NULL, 'AAAAL-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 16:01:42.892674+00', '2026-05-23 16:01:42.892674+00');
INSERT INTO public.products VALUES (237, 4, NULL, 'Licensed Rubber Ball', 'licensed-rubber-ball', NULL, NULL, 30.00, NULL, 3, 10, NULL, 'XIWNEEDO', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-07 17:52:10.337681+00', '2026-03-07 17:52:10.337681+00');
INSERT INTO public.products VALUES (736, 10, 10, 'Won', 'won', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'customized', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:14:23.046147+00', '2026-05-23 21:14:23.046147+00');
INSERT INTO public.products VALUES (737, 10, 10, 'Brunei Dollar', 'brunei-dollar', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'integrated', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:14:29.964793+00', '2026-05-23 21:14:29.964793+00');
INSERT INTO public.products VALUES (738, 10, 10, 'Forint', 'forint', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'efficient', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:17:01.538071+00', '2026-05-23 21:17:01.538071+00');
INSERT INTO public.products VALUES (739, 10, 10, 'Egyptian Pound', 'egyptian-pound', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'cross-media', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:19:07.385332+00', '2026-05-23 21:19:07.385332+00');
INSERT INTO public.products VALUES (740, 10, 10, 'Moroccan Dirham', 'moroccan-dirham', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'viral', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:19:57.718945+00', '2026-05-23 21:19:57.718945+00');
INSERT INTO public.products VALUES (741, 10, 10, 'Bahraini Dinar', 'bahraini-dinar', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'e-business', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:21:40.494103+00', '2026-05-23 21:21:40.494103+00');
INSERT INTO public.products VALUES (743, 10, 10, 'Brazilian Real', 'brazilian-real', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'dot-com', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:42:21.506197+00', '2026-05-23 21:42:21.506197+00');
INSERT INTO public.products VALUES (744, 10, 10, 'US Dollar', 'us-dollar', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'bricks-and-clicks', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:42:22.089476+00', '2026-05-23 21:42:22.089476+00');
INSERT INTO public.products VALUES (745, 10, 10, 'Bond Markets Units European Composite Unit (EURCO)', 'bond-markets-units-european-composite-unit-eurco', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'clicks-and-mortar', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:42:22.714394+00', '2026-05-23 21:42:22.714394+00');
INSERT INTO public.products VALUES (746, 10, 10, 'New Taiwan Dollar', 'new-taiwan-dollar', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'holistic', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:42:23.254512+00', '2026-05-23 21:42:23.254512+00');
INSERT INTO public.products VALUES (747, 10, 10, 'Malagasy Ariary', 'malagasy-ariary', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'transparent', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:42:23.834582+00', '2026-05-23 21:42:23.834582+00');
INSERT INTO public.products VALUES (749, 10, 10, 'Libyan Dinar', 'libyan-dinar', NULL, NULL, 50.00, NULL, 50, 10, NULL, 'robust', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:43:04.100893+00', '2026-05-23 21:43:04.100893+00');
INSERT INTO public.products VALUES (785, 11, 14, 'Postman', 'postman', NULL, NULL, 2990.90, NULL, 50, 10, NULL, 'h', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 19:36:30.472665+00', '2026-05-24 19:36:30.472665+00');
INSERT INTO public.products VALUES (758, 10, 10, 'Moeusef Gamer RGB', 'moeusef-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGfeP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 01:40:56.059042+00', '2026-05-24 01:40:56.059042+00');
INSERT INTO public.products VALUES (782, 10, NULL, 'Afghani', 'afghani', NULL, NULL, 299.90, NULL, 50, 10, NULL, '6', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 15:24:23.917452+00', '2026-05-24 15:24:23.917452+00');
INSERT INTO public.products VALUES (762, 10, 10, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitatio', 'lorem-ipsum-dolor-sit-amet-consectetur-adipiscing-elit-sed-do-eiusmod-tempor-incididunt-ut-labore-et', NULL, NULL, 99.99, NULL, 50, 10, NULL, 'PROD003', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 02:03:48.687903+00', '2026-05-24 02:03:48.687903+00');
INSERT INTO public.products VALUES (748, 10, 14, 'curso aat_teste_update', 'curso-aat-teste-update', NULL, NULL, 75.00, NULL, 150, 10, NULL, 'PRODtss001', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-23 21:43:02.787612+00', '2026-05-23 21:43:02.787612+00');
INSERT INTO public.products VALUES (779, 10, 10, 'Moeusref Gamer RGB', 'moeusref-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGrfeP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 12:43:10.698862+00', '2026-05-24 12:43:10.698862+00');
INSERT INTO public.products VALUES (780, 10, 10, 'Moeeusref Gamer RGB', 'moeeusref-gamer-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MGerfeP-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 12:48:45.284523+00', '2026-05-24 12:48:45.284523+00');
INSERT INTO public.products VALUES (781, 10, 10, 'O''Kon', 'o-kon', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'p', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 15:22:26.727794+00', '2026-05-24 15:22:26.727794+00');
INSERT INTO public.products VALUES (783, 10, 10, 'Danish Krone', 'danish-krone', NULL, NULL, 299.90, NULL, 50, 10, NULL, '8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 18:24:04.700008+00', '2026-05-24 18:24:04.700008+00');
INSERT INTO public.products VALUES (784, 10, 10, 'Moldovan Leu', 'moldovan-leu', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'g', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 19:01:31.521106+00', '2026-05-24 19:01:31.521106+00');
INSERT INTO public.products VALUES (786, 10, 10, 'Liberian Dollar', 'liberian-dollar', NULL, NULL, 299.90, NULL, 50, 10, NULL, '0', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 19:37:32.105896+00', '2026-05-24 19:37:32.105896+00');
INSERT INTO public.products VALUES (787, 10, 10, 'Uganda Shilling', 'uganda-shilling', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'q', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 19:39:13.420066+00', '2026-05-24 19:39:13.420066+00');
INSERT INTO public.products VALUES (788, 10, 10, 'New Israeli Sheqel', 'new-israeli-sheqel', NULL, NULL, 299.90, NULL, 50, 10, NULL, '5', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 19:42:22.223307+00', '2026-05-24 19:42:22.223307+00');
INSERT INTO public.products VALUES (789, 10, 10, 'Seychelles Rupee', 'seychelles-rupee', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'f', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 19:49:00.575304+00', '2026-05-24 19:49:00.575304+00');
INSERT INTO public.products VALUES (790, 10, 10, 'Convertible Marks', 'convertible-marks', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'a', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 20:00:03.322891+00', '2026-05-24 20:00:03.322891+00');
INSERT INTO public.products VALUES (791, 10, 10, 'Singapore Dollar', 'singapore-dollar', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'd', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 20:03:56.947004+00', '2026-05-24 20:03:56.947004+00');
INSERT INTO public.products VALUES (792, 10, 10, 'European Unit of Account 17(E.U.A.-17)', 'european-unit-of-account-17-e-u-a-17', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'u', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 20:06:13.699949+00', '2026-05-24 20:06:13.699949+00');
INSERT INTO public.products VALUES (793, 10, 10, 'Olson', 'olson', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'b', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 23:42:56.057007+00', '2026-05-24 23:42:56.057007+00');
INSERT INTO public.products VALUES (794, 10, 10, 'Zemlak', 'zemlak', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'r', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 23:44:44.225185+00', '2026-05-24 23:44:44.225185+00');
INSERT INTO public.products VALUES (795, 10, 10, 'Gorczany', 'gorczany', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'n', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 00:10:03.457193+00', '2026-05-25 00:10:03.457193+00');
INSERT INTO public.products VALUES (796, 10, 10, 'Stoltenberg', 'stoltenberg', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'i', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 00:12:27.02683+00', '2026-05-25 00:12:27.02683+00');
INSERT INTO public.products VALUES (797, 10, 10, 'Zieme', 'zieme', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'z', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 00:49:59.145989+00', '2026-05-25 00:49:59.145989+00');
INSERT INTO public.products VALUES (798, 10, 10, 'Russel', 'russel', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'x', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:01:46.977834+00', '2026-05-25 01:01:46.977834+00');
INSERT INTO public.products VALUES (799, 10, 10, 'Weissnat', 'weissnat', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'l', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:13:02.905829+00', '2026-05-25 01:13:02.905829+00');
INSERT INTO public.products VALUES (801, 10, 10, 'Mraz', 'mraz', NULL, NULL, 50.00, NULL, 10, 10, NULL, '9', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:17:50.268711+00', '2026-05-25 01:17:50.268711+00');
INSERT INTO public.products VALUES (802, 10, 10, 'Sporer', 'sporer', NULL, NULL, 50.00, NULL, 10, 10, NULL, '3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:26:13.539615+00', '2026-05-25 01:26:13.539615+00');
INSERT INTO public.products VALUES (803, 10, 10, 'Hand', 'hand', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'w', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:30:01.402698+00', '2026-05-25 01:30:01.402698+00');
INSERT INTO public.products VALUES (804, 10, 10, 'Kiehn', 'kiehn', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-897-t', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:32:41.500039+00', '2026-05-25 01:32:41.500039+00');
INSERT INTO public.products VALUES (805, 10, 10, 'Huel', 'huel', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-617-l', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:32:43.063225+00', '2026-05-25 01:32:43.063225+00');
INSERT INTO public.products VALUES (806, 10, 10, 'Shields', 'shields', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-409-c', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:32:44.227318+00', '2026-05-25 01:32:44.227318+00');
INSERT INTO public.products VALUES (807, 10, 10, 'Hane', 'hane', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-450-o', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:32:45.270887+00', '2026-05-25 01:32:45.270887+00');
INSERT INTO public.products VALUES (808, 10, 10, 'Hagenes', 'hagenes', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-440-a', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:32:50.110358+00', '2026-05-25 01:32:50.110358+00');
INSERT INTO public.products VALUES (809, 10, 10, 'Feest', 'feest', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-630-v', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 01:32:59.801303+00', '2026-05-25 01:32:59.801303+00');
INSERT INTO public.products VALUES (810, 10, 10, 'Gulgowski', 'gulgowski', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-789-y', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 02:12:59.476731+00', '2026-05-25 02:12:59.476731+00');
INSERT INTO public.products VALUES (811, 10, 10, 'Gaylord', 'gaylord', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-917-d', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 02:14:15.517867+00', '2026-05-25 02:14:15.517867+00');
INSERT INTO public.products VALUES (812, 10, 10, 'Rutherford', 'rutherford', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-448-c', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 02:16:40.927007+00', '2026-05-25 02:16:40.927007+00');
INSERT INTO public.products VALUES (813, 10, 10, 'Kuphal', 'kuphal', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-623-3', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 03:07:19.000473+00', '2026-05-25 03:07:19.000473+00');
INSERT INTO public.products VALUES (814, 10, 10, 'Bayer', 'bayer', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-573-r', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 03:09:28.111457+00', '2026-05-25 03:09:28.111457+00');
INSERT INTO public.products VALUES (815, 10, 10, 'Murazik', 'murazik', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-818-8', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-25 03:11:37.336993+00', '2026-05-25 03:11:37.336993+00');
INSERT INTO public.products VALUES (816, 10, 10, 'East Caribbean Dollar', 'east-caribbean-dollar', NULL, NULL, 299.90, NULL, 50, 10, NULL, '2', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-29 11:50:57.22932+00', '2026-05-29 11:50:57.22932+00');
INSERT INTO public.products VALUES (817, 10, 10, 'Kilback', 'kilback', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-490-o', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-30 20:38:29.459707+00', '2026-05-30 20:38:29.459707+00');
INSERT INTO public.products VALUES (818, 10, 10, 'Fisher', 'fisher', NULL, NULL, 50.00, NULL, 10, 10, NULL, 'SKU-511-b', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-30 20:41:52.379345+00', '2026-05-30 20:41:52.379345+00');
INSERT INTO public.products VALUES (820, 11, 11, 'Teaclado RGB', 'teaclado-rgb', NULL, NULL, 259.90, NULL, 50, 10, NULL, 'TEC-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-31 19:24:34.504915+00', '2026-05-31 19:24:34.504915+00');
INSERT INTO public.products VALUES (821, 11, 11, 'Teaclado mecanico RGB', 'teaclado-mecanico-rgb', NULL, NULL, 259.90, NULL, 50, 10, NULL, 'TECMEC-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-31 20:45:02.216702+00', '2026-05-31 20:45:02.216702+00');
INSERT INTO public.products VALUES (824, 10, 10, 'Gabinete aquario', 'gabinete-aquario', NULL, NULL, 1299.90, NULL, 50, 10, NULL, 'Gab-2024', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-01 17:14:41.476409+00', '2026-06-01 17:14:41.476409+00');
INSERT INTO public.products VALUES (760, 10, 190, 'Headset Led 1452', 'headset-led-1452', NULL, NULL, 852.90, NULL, 90, 10, NULL, 'GL13', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-05-24 01:59:48.054509+00', '2026-05-24 01:59:48.054509+00');
INSERT INTO public.products VALUES (825, 4, 10, 'curso postman 2', 'curso-postman-2', NULL, NULL, 70.00, NULL, 234, 10, NULL, 'TESTE1234', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-03 01:33:51.525949+00', '2026-06-03 01:33:51.525949+00');
INSERT INTO public.products VALUES (398, NULL, NULL, 'string', 'string', NULL, NULL, 0.00, NULL, 0, 10, NULL, 'string', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-03-10 12:09:51.65618+00', '2026-03-10 12:09:51.65618+00');
INSERT INTO public.products VALUES (847, 20, 10, 'Mousefi Pade RGB', 'mousefi-pade-rgb', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'MOUUSE-2026', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-24 23:44:21.564629+00', '2026-06-24 23:44:21.564629+00');
INSERT INTO public.products VALUES (853, 20, 10, 'Phone de ouvidos', 'phone-de-ouvidos', NULL, NULL, 45.00, NULL, 50, 10, NULL, 'MCP-2020', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-26 00:41:54.185072+00', '2026-06-26 00:41:54.185072+00');
INSERT INTO public.products VALUES (860, 10, 10, 'Generic Frozen Shoes 597', 'generic-frozen-shoes-597', NULL, NULL, 299.90, NULL, 50, 10, NULL, 'killer', NULL, NULL, true, false, 0.00, 0.00, 0, 0, 0, '2026-06-28 00:25:42.516315+00', '2026-06-28 00:25:42.516315+00');


--
-- TOC entry 4038 (class 0 OID 19608)
-- Dependencies: 390
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4026 (class 0 OID 19473)
-- Dependencies: 378
-- Data for Name: shippers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.shippers VALUES (1, 'Correios', '0800-570-0100', NULL, NULL, 7, NULL, true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.shippers VALUES (2, 'Jadlog', '0800-0256-527', NULL, NULL, 5, NULL, true, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.shippers VALUES (3, 'Total Express', '0800-0800-744', NULL, NULL, 4, NULL, true, '2025-11-22 19:13:30.023236+00');


--
-- TOC entry 4022 (class 0 OID 19416)
-- Dependencies: 374
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.suppliers VALUES (1, 'TechSupply Brasil', 'João Silva', NULL, 'joao@techsupply.com.br', '(11) 3456-7890', NULL, NULL, 'São Paulo', 'SP', NULL, 'Brazil', NULL, 4.80, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (2, 'Livros & Cia', 'Maria Santos', NULL, 'maria@livros.com.br', '(21) 2345-6789', NULL, NULL, 'Rio de Janeiro', 'RJ', NULL, 'Brazil', NULL, 4.50, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (1264, 'Empresa 1778031452164', 'Jewertãrero Silvad', NULL, 'teste_1778031452164@mail.com', '11987654321', '24817780314521', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:32.373368+00');
INSERT INTO public.suppliers VALUES (1265, 'Barros-Silva', 'Maria Alice Braga', NULL, 'lorraine_silva@gmail.com', '11987654321', '92845273590039', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:33.38395+00');
INSERT INTO public.suppliers VALUES (6, 'ModaSul Fornecedora', 'Juliana Lima', NULL, 'juliana@modasul.com', '(51) 3344-7788', NULL, NULL, 'Porto Alegre', 'RS', NULL, 'Brazil', NULL, 4.55, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (7, 'TechStore Supplies', 'Lucas Moreira', NULL, 'lucas@techstore.com', '(62) 9090-8080', NULL, NULL, 'Goiânia', 'GO', NULL, 'Brazil', NULL, 4.75, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (9, 'VesteBem Atacadista', 'Patrícia Gomes', NULL, 'patricia@vestebem.com', '(31) 3232-4545', NULL, NULL, 'Belo Horizonte', 'MG', NULL, 'Brazil', NULL, 4.65, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (10, 'TechLine Components', 'Eduardo Freitas', NULL, 'eduardo@techline.com', '(21) 95555-1212', NULL, NULL, 'Rio de Janeiro', 'RJ', NULL, 'Brazil', NULL, 4.80, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (11, 'MegaLivros Distribuição', 'Ana Beatriz Duarte', NULL, 'ana@megalivros.com', '(19) 98822-5500', NULL, NULL, 'Campinas', 'SP', NULL, 'Brazil', NULL, 4.50, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (12, 'UrbanFashion Group', 'Diego Correia', NULL, 'diego@urbanfashion.com', '(71) 99344-1100', NULL, NULL, 'Salvador', 'BA', NULL, 'Brazil', NULL, 4.70, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (14, 'Editora Atlas', 'Tatiana Moretti', NULL, 'tatiana@atlaseditora.com', '(31) 91234-9988', NULL, NULL, 'Belo Horizonte', 'MG', NULL, 'Brazil', NULL, 4.35, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (15, 'TopWear Distribuidora', 'Roberto Farias', NULL, 'roberto@topwear.com', '(95) 98888-4444', NULL, NULL, 'Boa Vista', 'RR', NULL, 'Brazil', NULL, 4.60, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (16, 'InfoParts Solutions', 'Marcos Oliveira', NULL, 'marcos@infoparts.com', '(61) 98111-7733', NULL, NULL, 'Brasília', 'DF', NULL, 'Brazil', NULL, 4.82, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (18, 'ModaTrend Suppliers', 'Bruno Almeida', NULL, 'bruno@modatrend.com', '(82) 95555-8877', NULL, NULL, 'Maceió', 'AL', NULL, 'Brazil', NULL, 4.72, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (21, 'Tech Solutions Ltda', 'João Silva', NULL, 'joao@techsolutions.com', '(11) 98765-4321', '12345678901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-02-07 20:36:48.024253+00');
INSERT INTO public.suppliers VALUES (8, 'Ulisses TEste', 'João Silva', NULL, 'joaoter@techsolutions.com', '(11) 98765-4321', '12345678901244', NULL, 'Fortaleza', 'SP', NULL, 'Brazil', NULL, 4.30, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (22, 'Empresa Email Longo', 'João Silva', NULL, 'aaaaaa@teste.com', '(11) 98765-4321', '55555555555555', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-02-07 20:38:33.854849+00');
INSERT INTO public.suppliers VALUES (17, 'Tech Solutions Ltdarrrrrrr', 'João Silva', NULL, 'jorrrrao@techsolutions.com', '(11) 98765-4321', '12346678901234', NULL, 'Bauru', 'SP', NULL, 'Brazil', NULL, 4.48, true, NULL, '2025-11-22 19:13:30.023236+00');
INSERT INTO public.suppliers VALUES (38, 'Empresa 1777341325323', 'Jewertãrero Silvad', NULL, 'teste_1777341325323@mail.com', '(11) 98765-4321', '24817773413253', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 01:55:25.908125+00');
INSERT INTO public.suppliers VALUES (25, 'Tedch Solutions Ltda', 'Jodão Silva', NULL, 'jodao@techsolutions.com', '(11) 98765-4321', '12355678901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 00:01:47.476013+00');
INSERT INTO public.suppliers VALUES (26, 'Tedch Solutions Ltda', 'Jodão Silva', NULL, 'jodeao@techsolutions.com', '(11) 98765-4321', '12353678901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 00:03:38.174637+00');
INSERT INTO public.suppliers VALUES (27, 'Teerch Solutionsd Ltda', 'Joãero Silvad', NULL, 'joerado@techsolutions.com', '(11) 98765-4321', '12345473901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 00:10:51.931506+00');
INSERT INTO public.suppliers VALUES (28, 'Teedch Solutions Ltda', 'reerer erere', NULL, 'aebc@gmaiel.com', '(11) 98765-4321', '98745698745698', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 00:11:32.598122+00');
INSERT INTO public.suppliers VALUES (30, 'Teerrtech Solutionsd Ltda', 'Jortãrero Silvad', NULL, 'joertrrado@techsolutions.com', '(11) 98765-4321', '12345653951234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 00:13:53.729663+00');
INSERT INTO public.suppliers VALUES (31, 'Teereewerrtech Solutionsd Ltda', 'Jewertãrero Silvad', NULL, 'joerewewrtrrado@techsolutions.com', '(11) 98765-4321', '12345656661234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 00:14:42.081057+00');
INSERT INTO public.suppliers VALUES (33, 'Teedch 21;32 Solutions Ltda', 'reerer erere', NULL, 'aeb55c@gmaiel.com', '(11) 98765-4321', '98745658745698', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 00:32:44.725585+00');
INSERT INTO public.suppliers VALUES (34, 'Tech Solutionsd Ltda', 'João Silvad', NULL, 'joarrdo@techsolutions.com', '(11) 98765-4321', '12345478901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 01:10:00.945993+00');
INSERT INTO public.suppliers VALUES (36, 'Empresa 1777341210155', 'Jewertãrero Silvad', NULL, 'teste_1777341210155@mail.com', '(11) 98765-4321', '12341777341210', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 01:53:30.751767+00');
INSERT INTO public.suppliers VALUES (37, 'Empresa 1777341310262', 'Jewertãrero Silvad', NULL, 'teste_1777341310262@mail.com', '(11) 98765-4321', '24817773413102', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-28 01:55:10.892181+00');
INSERT INTO public.suppliers VALUES (40, 'Teere5ewerrtech Solutionsd Ltda', 'Jewertãrero Silvad', NULL, 'joerewe5wrtrrado@techsolutions.com', '(11) 98765-4321', '12345656961234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-30 22:52:05.340039+00');
INSERT INTO public.suppliers VALUES (41, 'Empresa 1777589700773', 'Jewertãrero Silvad', NULL, 'teste_1777589700773@mail.com', '(11) 98765-4321', '24817775897007', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-30 22:55:01.244882+00');
INSERT INTO public.suppliers VALUES (42, 'Empresa 1777589704583', 'Jewertãrero Silvad', NULL, 'teste_1777589704583@mail.com', '(11) 98765-4321', '24817775897045', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-04-30 22:55:05.034585+00');
INSERT INTO public.suppliers VALUES (43, 'Empresa 1777598900453', 'Jewertãrero Silvad', NULL, 'teste_1777598900453@mail.com', '(11) 98765-4321', '24817775989004', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 01:28:20.723865+00');
INSERT INTO public.suppliers VALUES (44, 'Tedfceh Solutions Ltda', 'João Silva', NULL, 'jodfaeo@techsolutions.com', '(11) 98765-4321', '12344478901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 01:31:46.059207+00');
INSERT INTO public.suppliers VALUES (45, 'Empresa 1777599282912', 'Jewertãrero Silvad', NULL, 'teste_1777599282912@mail.com', '(11) 98765-4321', '24817775992829', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 01:34:43.182883+00');
INSERT INTO public.suppliers VALUES (46, 'Empresa 1777599358660', 'Jewertãrero Silvad', NULL, 'teste_1777599358660@mail.com', '(11) 98765-4321', '24817775993586', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 01:35:58.87369+00');
INSERT INTO public.suppliers VALUES (47, 'Empresa 1777599380054', 'Jewertãrero Silvad', NULL, 'teste_1777599380054@mail.com', '(11) 98765-4321', '24817775993800', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 01:36:20.224051+00');
INSERT INTO public.suppliers VALUES (48, 'Empresa 1777599384086', 'Jewertãrero Silvad', NULL, 'teste_1777599384086@mail.com', '(11) 98765-4321', '24817775993840', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 01:36:24.231692+00');
INSERT INTO public.suppliers VALUES (49, 'Empresa 1777601026457', 'Jewertãrero Silvad', NULL, 'teste_1777601026457@mail.com', '(11) 98765-4321', '24817776010264', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:03:46.669724+00');
INSERT INTO public.suppliers VALUES (50, 'Empresa 1777601189219', 'Jewertãrero Silvad', NULL, 'teste_1777601189219@mail.com', '(11) 98765-4321', '24817776011892', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:06:29.380616+00');
INSERT INTO public.suppliers VALUES (51, 'Empresa 1777601670528', 'Teste QA', NULL, 'teste_1777601670528@mail.com', '(11) 99999-9999', '12345678177760', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:14:30.736764+00');
INSERT INTO public.suppliers VALUES (52, 'Empresa 1777601696433', 'Teste QA', NULL, 'teste_1777601696433@mail.com', '(11) 99999-9999', '12348177760169', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:14:56.584177+00');
INSERT INTO public.suppliers VALUES (53, 'Empresa 1777601710602', 'Teste QA', NULL, 'teste_1777601710602@mail.com', '(11) 99999-9999', '12817776017106', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:15:10.778863+00');
INSERT INTO public.suppliers VALUES (54, 'Empresa 1777601714117', 'Teste QA', NULL, 'teste_1777601714117@mail.com', '(11) 99999-9999', '12817776017141', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:15:14.250801+00');
INSERT INTO public.suppliers VALUES (55, 'Empresa 1777601717486', 'Teste QA', NULL, 'teste_1777601717486@mail.com', '(11) 99999-9999', '12817776017174', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:15:17.684578+00');
INSERT INTO public.suppliers VALUES (57, 'Empresa 1777602252953', 'Jewertãrero Silvad', NULL, 'teste_1777602252953@mail.com', '(11) 98765-4321', '24817776022529', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:24:13.077977+00');
INSERT INTO public.suppliers VALUES (58, 'Empresa 1777602253987', 'Jewertãrero Silvad', NULL, 'teste_1777602253987@mail.com', '(11) 98765-4321', '24817776022539', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:24:14.118141+00');
INSERT INTO public.suppliers VALUES (59, 'Empresa 1777602464731', 'Teste QA', NULL, 'teste_1777602464731@mail.com', '(11) 99999-9999', '12817776024647', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:27:44.872698+00');
INSERT INTO public.suppliers VALUES (60, 'Empresa 1777602859169', 'Jewertãrero Silvad', NULL, 'teste_1777602859169@mail.com', '(11) 98765-4321', '24817776028591', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:34:19.290207+00');
INSERT INTO public.suppliers VALUES (61, 'Empresa 1777602859344', 'Jewertãrero Silvad', NULL, 'teste_1777602859344@mail.com', '(11) 98765-4321', '24817776028593', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:34:19.454236+00');
INSERT INTO public.suppliers VALUES (62, 'Empresa 1777602859467', 'Teste QA', NULL, 'teste_1777602859467@mail.com', '(11) 99999-9999', '12817776028594', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 02:34:19.566859+00');
INSERT INTO public.suppliers VALUES (63, 'Tech Solutionsggg Ltda', 'João Silvggga', NULL, 'joagggo@techsolutions.com', '(11) 98765-4321', '98745698512548', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 17:43:01.70081+00');
INSERT INTO public.suppliers VALUES (64, 'BookWorld Distribuidoraer', 'Renata Pachecorr', NULL, 'adminrrrr@qatest.com', '(14) 96666-2345', '95555555555599', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 18:00:31.803335+00');
INSERT INTO public.suppliers VALUES (65, 'Techr Solutionsggg Ltda', 'Joãro Silvggga', NULL, 'joaggrgo@techsolutions.com', '(11) 98765-4321', '98795698512548', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 18:37:32.973147+00');
INSERT INTO public.suppliers VALUES (66, 'Distribuidora Nova Era Ltda', 'Carlos Henrique Souza', NULL, 'contato.novaera01@empresa.com', '(11) 91234-0001', '12345678000101', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:34.595374+00');
INSERT INTO public.suppliers VALUES (67, 'Alimentos Bom Sabor SA', 'Mariana Alves Pereira', NULL, 'mariana.bomsabor02@empresa.com', '(21) 92345-0002', '12345678000102', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:35.015946+00');
INSERT INTO public.suppliers VALUES (68, 'Tech Solutions Brasil Ltda', 'Lucas Ferreira Costa', NULL, 'lucas.tech03@empresa.com', '(31) 93456-0003', '12345678000103', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:35.445787+00');
INSERT INTO public.suppliers VALUES (69, 'ConstruMax Engenharia Ltda', 'Fernanda Ribeiro Gomes', NULL, 'fernanda.construmax04@empresa.com', '(41) 94567-0004', '12345678000104', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:35.790773+00');
INSERT INTO public.suppliers VALUES (72, 'Distribuidora Central Oeste', 'Eduardo Teixeira Santos', NULL, 'eduardo.central07@empresa.com', '(62) 97890-0007', '12345678000107', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:36.872808+00');
INSERT INTO public.suppliers VALUES (73, 'Nordeste Bebidas Ltda', 'Juliana Batista Lima', NULL, 'juliana.bebidas08@empresa.com', '(71) 98901-0008', '12345678000108', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:37.24832+00');
INSERT INTO public.suppliers VALUES (74, 'Papelaria Criativa Ltda', 'Rafael Barbosa Rocha', NULL, 'rafael.papelaria09@empresa.com', '(81) 99012-0009', '12345678000109', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:37.585053+00');
INSERT INTO public.suppliers VALUES (75, 'Farmácia Vida Plena', 'Aline Monteiro Dias', NULL, 'aline.farmacia10@empresa.com', '(85) 90123-0010', '12345678000110', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:37.899925+00');
INSERT INTO public.suppliers VALUES (76, 'Auto Peças Motor Forte', 'Bruno Cardoso Vieira', NULL, 'bruno.autpecas11@empresa.com', '(27) 91234-0011', '12345678000111', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:38.2225+00');
INSERT INTO public.suppliers VALUES (77, 'Moveis Planejados Ideal', 'Camila Freitas Lopes', NULL, 'camila.moveis12@empresa.com', '(48) 92345-0012', '12345678000112', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:38.554071+00');
INSERT INTO public.suppliers VALUES (78, 'Importadora Global Trade', 'Diego Pires Fernandes', NULL, 'diego.global13@empresa.com', '(65) 93456-0013', '12345678000113', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:38.872113+00');
INSERT INTO public.suppliers VALUES (79, 'Segurança Total Serviços', 'Vanessa Duarte Melo', NULL, 'vanessa.segurança14@empresa.com', '(92) 94567-0014', '12345678000114', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:39.200655+00');
INSERT INTO public.suppliers VALUES (80, 'Distribuidora Sul Comercial', 'Thiago Moreira Campos', NULL, 'thiago.sul15@empresa.com', '(54) 95678-0015', '12345678000115', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-01 22:30:39.544528+00');
INSERT INTO public.suppliers VALUES (1458, 'Saraiva, Pereira e Oliveira', 'Silas Macedo', NULL, 'yasmin27@live.com', '11987654321', '93569756384227', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:17.391657+00');
INSERT INTO public.suppliers VALUES (84, 'Oliveira Transportes ME', 'João Pedro Oliveira', NULL, 'joao.oliveira@email.com', '(21) 97654-3210', '23456789000181', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:34.371051+00');
INSERT INTO public.suppliers VALUES (85, 'Santos Tecnologia EPP', 'Maria Fernanda Santos', NULL, 'maria.santos@email.com', '(31) 96543-2109', '34567890000172', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:34.512189+00');
INSERT INTO public.suppliers VALUES (86, 'Costa Alimentos Ltda', 'Roberto Carlos Costa', NULL, 'roberto.costa@email.com', '(41) 95432-1098', '45678901000163', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:34.625808+00');
INSERT INTO public.suppliers VALUES (87, 'Ferreira Construtora ME', 'Juliana Ferreira', NULL, 'juliana.ferreira@email.com', '(51) 94321-0987', '56789012000154', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:34.736801+00');
INSERT INTO public.suppliers VALUES (88, 'Alves Consultoria EPP', 'Ricardo Alves', NULL, 'ricardo.alves@email.com', '(61) 93210-9876', '67890123000145', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:34.844009+00');
INSERT INTO public.suppliers VALUES (89, 'Pereira Varejo Ltda', 'Carla Pereira', NULL, 'carla.pereira@email.com', '(71) 92109-8765', '78901234000136', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:34.944715+00');
INSERT INTO public.suppliers VALUES (90, 'Rodrigues Logística ME', 'Fernando Rodrigues', NULL, 'fernando.rodrigues@email.com', '(81) 91098-7654', '89012345000127', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.097741+00');
INSERT INTO public.suppliers VALUES (91, 'Lima Serviços Digitais EPP', 'Patricia Lima', NULL, 'patricia.lima@email.com', '(85) 90987-6543', '90123456000118', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.228901+00');
INSERT INTO public.suppliers VALUES (92, 'Martins Comércio Exterior Ltda', 'Gustavo Martins', NULL, 'gustavo.martins@email.com', '(62) 99876-5432', '01234567000109', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.348224+00');
INSERT INTO public.suppliers VALUES (93, 'Souza Distribuidora ME', 'Larissa Souza', NULL, 'larissa.souza@email.com', '(48) 98765-4321', '11234568000190', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.46429+00');
INSERT INTO public.suppliers VALUES (94, 'Barbosa Importação EPP', 'Rafael Barbosa', NULL, 'rafael.barbosa@email.com', '(27) 97654-3210', '21234569000181', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.574147+00');
INSERT INTO public.suppliers VALUES (95, 'Cardoso Exportação Ltda', 'Beatriz Cardoso', NULL, 'beatriz.cardoso@email.com', '(91) 96543-2109', '31234570000172', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.682317+00');
INSERT INTO public.suppliers VALUES (96, 'Nascimento Agronegócio ME', 'Marcelo Nascimento', NULL, 'marcelo.nascimento@email.com', '(92) 95432-1098', '41234571000163', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.778372+00');
INSERT INTO public.suppliers VALUES (97, 'Araújo Tecnologia EPP', 'Camila Araújo', NULL, 'camila.araujo@email.com', '(84) 94321-0987', '51234572000154', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 00:33:35.887281+00');
INSERT INTO public.suppliers VALUES (98, 'Distribuidoras Nova Era Ltda', 'Carlos Henrique Souza', NULL, 'contatos.novaera01@empresa.com', '(11) 91234-0001', '12345677090101', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:34.257941+00');
INSERT INTO public.suppliers VALUES (99, 'Alimentsos Bom Sabor SA', 'Mariana Alves Pereira', NULL, 'mariasna.bomsabor02@empresa.com', '(21) 92345-0002', '12345678009102', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:34.76257+00');
INSERT INTO public.suppliers VALUES (100, 'Techs Solutions Brasil Ltda', 'Lucas Ferreira Costa', NULL, 'lucass.tech03@empresa.com', '(31) 93456-0003', '12345678009103', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:35.133478+00');
INSERT INTO public.suppliers VALUES (101, 'ConsstruMax Engenharia Ltda', 'Fernanda Ribeiro Gomes', NULL, 'fernandsa.construmax04@empresa.com', '(41) 94567-0004', '12345678900104', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:35.480867+00');
INSERT INTO public.suppliers VALUES (103, 'Logísstica Rápida Express', 'Patrícia Nunes Carvalho', NULL, 'patricisa.logistica06@empresa.com', '(61) 96789-0006', '12345678090106', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:36.114197+00');
INSERT INTO public.suppliers VALUES (104, 'Disstribuidora Central Oeste', 'Eduardo Teixeira Santos', NULL, 'eduardos.central07@empresa.com', '(62) 97890-0007', '12345678090107', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:36.405997+00');
INSERT INTO public.suppliers VALUES (105, 'Norsdeste Bebidas Ltda', 'Juliana Batista Lima', NULL, 'julianas.bebidas08@empresa.com', '(71) 98901-0008', '12345678090108', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:36.71136+00');
INSERT INTO public.suppliers VALUES (106, 'Papselaria Criativa Ltda', 'Rafael Barbosa Rocha', NULL, 'rafaesl.papelaria09@empresa.com', '(81) 99012-0009', '12345679000109', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:37.00219+00');
INSERT INTO public.suppliers VALUES (107, 'Fsarmácia Vida Plena', 'Aline Monteiro Dias', NULL, 'alinse.farmacia10@empresa.com', '(85) 90123-0010', '12345698000110', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:37.295312+00');
INSERT INTO public.suppliers VALUES (108, 'Autos Peças Motor Forte', 'Bruno Cardoso Vieira', NULL, 'brunso.autpecas11@empresa.com', '(27) 91234-0011', '12345679000111', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:37.644413+00');
INSERT INTO public.suppliers VALUES (109, 'Moveiss Planejados Ideal', 'Camila Freitas Lopes', NULL, 'camilsa.moveis12@empresa.com', '(48) 92345-0012', '12345679000112', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:37.975557+00');
INSERT INTO public.suppliers VALUES (102, 'Tecrh Solutions Ltda', 'Jorão Silva', NULL, 'joarro@techsolutions.com', '(11) 98765-4321', '12345678907234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:35.792217+00');
INSERT INTO public.suppliers VALUES (1586, 'Haley LLC', 'Dr. Myrtle Connelly', NULL, 'luna30@hotmail.com', '11987654321', '01779675179771', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-25 02:12:59.855259+00');
INSERT INTO public.suppliers VALUES (110, 'Ismportadora Global Trade', 'Diego Pires Fernandes', NULL, 'diegso.global13@empresa.com', '(65) 93456-0013', '12345698000113', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:38.291404+00');
INSERT INTO public.suppliers VALUES (111, 'Ssegurança Total Serviços', 'Vanessa Duarte Melo', NULL, 'vanessas.segurança14@empresa.com', '(92) 94567-0014', '12345678090114', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:38.595309+00');
INSERT INTO public.suppliers VALUES (112, 'Disstribuidora Sul Comercial', 'Thiago Moreira Campos', NULL, 'thiagos.sul15@empresa.com', '(54) 95678-0015', '12345678900115', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 01:23:38.883851+00');
INSERT INTO public.suppliers VALUES (113, 'Macedo, Santos e Nogueira', 'Maria Clara Barros', NULL, 'mariacecilia62@gmail.com', '1644972805', '46613439932334', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 13:53:50.562022+00');
INSERT INTO public.suppliers VALUES (114, 'Costa LTDA', 'Breno Moreira', NULL, 'antonella_reis71@live.com', '04245113308', '15047602722332', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 13:54:33.151171+00');
INSERT INTO public.suppliers VALUES (115, 'BookWorld Distribuidoraer', 'Renata Pachecor', NULL, 'ardmin@qatest.com', '55219895295', '55555555555559', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 13:57:07.19285+00');
INSERT INTO public.suppliers VALUES (116, 'Batista, Moreira e Franco', 'Célia Martins', NULL, 'anthony92@gmail.com', '77983263289', '00965353824803', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 13:58:39.372311+00');
INSERT INTO public.suppliers VALUES (117, 'Carvalho, Barros e Martins', 'Vicente Macedo Jr.', NULL, 'matheus.pereira41@live.com', '4657686137', '54016117038246', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 13:58:44.702418+00');
INSERT INTO public.suppliers VALUES (118, 'Carvalho-Pereira', 'Ígor Franco', NULL, 'pedrohenrique_saraiva66@bol.com.br', '72962065425', '78573315237545', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 13:58:51.690303+00');
INSERT INTO public.suppliers VALUES (119, 'Batista, Martins e Pereira', 'Gabriel Macedo', NULL, 'felix_xavier84@live.com', '16089414825', '27879349355857', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 13:59:23.808915+00');
INSERT INTO public.suppliers VALUES (121, 'Martins, Albuquerque e Saraiva', 'Frederico Martins', NULL, 'isis_moreira@gmail.com', '4143341832', '10327184165696', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:21:02.338603+00');
INSERT INTO public.suppliers VALUES (122, 'Barros-Costa', 'Isabella Albuquerque', NULL, 'maria83@gmail.com', '36591151492', '62485835518981', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:21:13.673836+00');
INSERT INTO public.suppliers VALUES (124, 'Moreira S.A.', 'Sra. Lara Macedo', NULL, 'alicia.silva8@hotmail.com', '3239554546', '28942469507385', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:23:18.043197+00');
INSERT INTO public.suppliers VALUES (125, 'Melo-Martins', 'Arthur Pereira', NULL, 'mariaclara.batista@hotmail.com', '3528164354', '34856055223472', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:23:46.266668+00');
INSERT INTO public.suppliers VALUES (126, 'Xavier, Oliveira e Saraiva', 'Eloá Silva', NULL, 'natalia15@bol.com.br', '0706298691', '87338667099281', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:23:53.295629+00');
INSERT INTO public.suppliers VALUES (127, 'Batista EIRELI', 'Maria Luiza Costa', NULL, 'heloisa29@gmail.com', '10225313609', '63180136489073', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:23:53.421389+00');
INSERT INTO public.suppliers VALUES (128, 'Saraiva, Santos e Silva', 'Lívia Nogueira', NULL, 'livia48@hotmail.com', '11882781339', '59373466249358', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:23:53.541249+00');
INSERT INTO public.suppliers VALUES (129, 'Pereira-Pereira', 'Elísio Nogueira', NULL, 'ricardo_carvalho@yahoo.com', '3174309386', '18940242966584', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:26:50.678118+00');
INSERT INTO public.suppliers VALUES (130, 'Braga LTDA', 'Carlos Albuquerque Filho', NULL, 'marialuiza43@hotmail.com', '87176095365', '00434799460742', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:56:36.608292+00');
INSERT INTO public.suppliers VALUES (131, 'Souza EIRELI', 'Esther Xavier', NULL, 'marcela94@gmail.com', '7732663165', '84100395894652', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:56:36.783449+00');
INSERT INTO public.suppliers VALUES (132, 'Melo-Oliveira', 'Liz Oliveira', NULL, 'yago65@bol.com.br', '7000879823', '24059970181144', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:56:36.952073+00');
INSERT INTO public.suppliers VALUES (133, 'Batista, Barros e Xavier', 'Noah Xavier', NULL, 'clara.xavier@gmail.com', '10217818672', '82801690790443', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:56:37.161224+00');
INSERT INTO public.suppliers VALUES (134, 'Martins EIRELI', 'Maria Eduarda Franco', NULL, 'alessandra.costa84@bol.com.br', '02993757038', '55988772411767', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:57:05.363954+00');
INSERT INTO public.suppliers VALUES (150, 'Macedo, Franco e Saraiva_1777735360439', 'Lavínia Moreira Filho', NULL, 'deneval38@hotmail.com_1777735360439', '11987654321', '79556580040439', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:40.202908+00');
INSERT INTO public.suppliers VALUES (151, 'Barros-Martins_1777735360439', 'Karla Macedo', NULL, 'deneval_braga@live.com_1777735360439', '11987654321', '16417838020439', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:40.331061+00');
INSERT INTO public.suppliers VALUES (135, 'Carvalho-Nogueira_1777734957980', 'Sr. Raul Pereira', NULL, 'talita76@hotmail.com_1777734957980', '0865959198', '66723274657980', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:15:56.687867+00');
INSERT INTO public.suppliers VALUES (152, 'Nogueira Comércio_1777735360439', 'Sophia Nogueira', NULL, 'murilo69@live.com_1777735360439', '11987654321', '88123209040439', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:40.45136+00');
INSERT INTO public.suppliers VALUES (153, 'Saraiva, Carvalho e Pereira_1777735360439', 'Lorena Barros', NULL, 'fabiano_carvalho@hotmail.com_1777735360439', '11987654321', '05012459430439', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:40.565624+00');
INSERT INTO public.suppliers VALUES (120, 'Barros Comércio4343', 'Sirineu Batista', NULL, 'helena72@bol.com.br_1777734977500', '(21) 98956-5985', '04394997234265', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 14:12:29.103399+00');
INSERT INTO public.suppliers VALUES (136, 'Reis-Santos_1777735159287', 'Carlos Melo', NULL, 'giovanna.xavier@live.com_1777735159287', '6270771949', '47832625489287', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:19:17.876372+00');
INSERT INTO public.suppliers VALUES (137, 'Oliveira e Associados_1777735159287', 'Isadora Braga', NULL, 'maite.costa54@gmail.com_1777735159287', '8444872661', '91358598149287', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:19:17.998366+00');
INSERT INTO public.suppliers VALUES (138, 'Pereira e Associados', 'Esther Xavier', NULL, 'analaura_melo89@bol.com.br', '11987654321', '42446935714736', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:25.219351+00');
INSERT INTO public.suppliers VALUES (139, 'Moraes, Souza e Pereira_1777735354327', 'Alexandre Martins', NULL, 'mariahelena.melo39@live.com_1777735354327', '7342138240', '38390135564327', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:32.930047+00');
INSERT INTO public.suppliers VALUES (140, 'Melo, Xavier e Albuquerque_1777735354327', 'Frederico Batista', NULL, 'lucas_santos67@live.com_1777735354327', '20602310830', '93275810774327', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:33.04791+00');
INSERT INTO public.suppliers VALUES (141, 'Barros-Souza_1777735360439', 'Alessandro Xavier', NULL, 'lucas_moraes@bol.com.br_1777735360439', '11987654321', '21402586750439', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.015474+00');
INSERT INTO public.suppliers VALUES (142, 'Melo, Costa e Silva_1777735360439', 'Márcia Silva Neto', NULL, 'larissa.albuquerque84@hotmail.com_1777735360439', '11987654321', '45174771790439', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.140958+00');
INSERT INTO public.suppliers VALUES (143, 'Moraes e Associados_1777735360439', 'Margarida Costa', NULL, 'marcia14@live.com_1777735360439', '11987654321', '04084427990439', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.337466+00');
INSERT INTO public.suppliers VALUES (144, 'Saraiva-Souza_1777735360439', 'Warley Nogueira', NULL, 'ricardo57@gmail.com_1777735360439', '11987654321', '13778564430439', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.459499+00');
INSERT INTO public.suppliers VALUES (145, 'Santos-Melo_1777735360439', 'Lorena Souza', NULL, 'nubia.martins@hotmail.com_1777735360439', '11987654321', '51910633060439', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.581505+00');
INSERT INTO public.suppliers VALUES (146, 'Costa-Souza_1777735360439', 'Dra. Marina Pereira', NULL, 'gael88@gmail.com_1777735360439', '11987654321', '91469256690439', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.701373+00');
INSERT INTO public.suppliers VALUES (147, 'Saraiva-Saraiva_1777735360439', 'Lorenzo Moreira', NULL, 'sirineu.oliveira29@yahoo.com_1777735360439', '11987654321', '79254601810439', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.817317+00');
INSERT INTO public.suppliers VALUES (148, 'Costa-Albuquerque_1777735360439', 'Heitor Costa', NULL, 'sophia81@bol.com.br_1777735360439', '11987654321', '16466640380439', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:39.944171+00');
INSERT INTO public.suppliers VALUES (149, 'Moreira, Silva e Franco_1777735360439', 'Maria Eduarda Xavier', NULL, 'paula.batista@gmail.com_1777735360439', '11987654321', '06171605700439', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:40.064034+00');
INSERT INTO public.suppliers VALUES (154, 'Reis, Albuquerque e Carvalho_1777735360439', 'Davi Souza', NULL, 'gustavo_barros@gmail.com_1777735360439', '11987654321', '38723416000439', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:40.685501+00');
INSERT INTO public.suppliers VALUES (155, 'Pereira, Barros e Martins_1777735360439', 'Ladislau Batista', NULL, 'deneval4@yahoo.com_1777735360439', '11987654321', '74557844230439', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:22:40.797542+00');
INSERT INTO public.suppliers VALUES (156, 'Barros, Macedo e Moreira_1777735679463', 'Bryan Pereira', NULL, 'salvador_moreira6@yahoo.com_1777735679463', '11987654321', '92970570099463', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:58.137235+00');
INSERT INTO public.suppliers VALUES (157, 'Melo, Silva e Pereira_1777735679463', 'Sra. Ana Laura Saraiva', NULL, 'helena_nogueira@live.com_1777735679463', '11987654321', '84326540589463', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:58.323437+00');
INSERT INTO public.suppliers VALUES (158, 'Oliveira-Pereira_1777735679463', 'Yasmin Nogueira', NULL, 'clara.pereira42@yahoo.com_1777735679463', '11987654321', '59417512049463', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:58.463934+00');
INSERT INTO public.suppliers VALUES (159, 'Silva Comércio_1777735679463', 'Sara Franco', NULL, 'dalila_carvalho@gmail.com_1777735679463', '11987654321', '70288276049463', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:58.617901+00');
INSERT INTO public.suppliers VALUES (160, 'Albuquerque, Franco e Souza_1777735679463', 'Isadora Oliveira', NULL, 'davi.barros@yahoo.com_1777735679463', '11987654321', '06227943859463', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:58.766292+00');
INSERT INTO public.suppliers VALUES (161, 'Melo-Martins_1777735679463', 'Maria Júlia Batista', NULL, 'lara86@yahoo.com_1777735679463', '11987654321', '14476611849463', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:58.917639+00');
INSERT INTO public.suppliers VALUES (162, 'Moreira Comércio_1777735679463', 'Srta. Heloísa Melo', NULL, 'isis56@yahoo.com_1777735679463', '11987654321', '35498828859463', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.058954+00');
INSERT INTO public.suppliers VALUES (163, 'Costa-Batista_1777735679463', 'Alícia Carvalho', NULL, 'marli66@hotmail.com_1777735679463', '11987654321', '93323689699463', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.167858+00');
INSERT INTO public.suppliers VALUES (164, 'Saraiva-Nogueira_1777735679463', 'Gustavo Xavier', NULL, 'janaina.melo@yahoo.com_1777735679463', '11987654321', '42039157719463', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.280694+00');
INSERT INTO public.suppliers VALUES (165, 'Costa LTDA_1777735679463', 'Clara Moraes Jr.', NULL, 'pietro_santos@gmail.com_1777735679463', '11987654321', '51807919189463', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.39086+00');
INSERT INTO public.suppliers VALUES (166, 'Martins, Nogueira e Santos_1777735679463', 'Bruna Saraiva', NULL, 'miguel_albuquerque91@gmail.com_1777735679463', '11987654321', '33215558119463', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.512039+00');
INSERT INTO public.suppliers VALUES (167, 'Carvalho, Santos e Nogueira_1777735679463', 'Marcelo Franco', NULL, 'alice.albuquerque@yahoo.com_1777735679463', '11987654321', '56327103889463', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.627496+00');
INSERT INTO public.suppliers VALUES (168, 'Batista-Albuquerque_1777735679463', 'Marcela Melo', NULL, 'mariana_martins92@gmail.com_1777735679463', '11987654321', '48232488009463', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.744752+00');
INSERT INTO public.suppliers VALUES (169, 'Barros, Moreira e Oliveira_1777735679463', 'Anthony Moraes', NULL, 'mariaalice_pereira@live.com_1777735679463', '11987654321', '37689004229463', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.867804+00');
INSERT INTO public.suppliers VALUES (170, 'Souza-Moreira_1777735679463', 'Fábio Albuquerque', NULL, 'yasmin64@hotmail.com_1777735679463', '11987654321', '93596884569463', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:27:59.97872+00');
INSERT INTO public.suppliers VALUES (171, 'Souza, Santos e Reis_1777735679463', 'Sr. Ladislau Costa', NULL, 'beatriz97@bol.com.br_1777735679463', '11987654321', '71521921219463', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:00.086169+00');
INSERT INTO public.suppliers VALUES (172, 'Xavier, Oliveira e Melo_1777735679463', 'Lívia Costa', NULL, 'frederico93@gmail.com_1777735679463', '11987654321', '19511274729463', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:00.210865+00');
INSERT INTO public.suppliers VALUES (173, 'Moreira Comércio_1777735679463', 'Lorraine Saraiva', NULL, 'julio_oliveira@live.com_1777735679463', '11987654321', '81452231829463', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:00.330964+00');
INSERT INTO public.suppliers VALUES (174, 'Batista S.A._1777735679463', 'Davi Lucca Costa', NULL, 'natalia.carvalho58@yahoo.com_1777735679463', '11987654321', '19002156299463', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:00.44061+00');
INSERT INTO public.suppliers VALUES (175, 'Santos, Silva e Martins_1777735679463', 'Yango Reis', NULL, 'igor.franco31@gmail.com_1777735679463', '11987654321', '15573032049463', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:00.541288+00');
INSERT INTO public.suppliers VALUES (176, 'Braga-Martins_1777735707825', 'Norberto Pereira', NULL, 'warley_pereira70@yahoo.com_1777735707825', '11987654321', '12690187007825', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:26.795027+00');
INSERT INTO public.suppliers VALUES (177, 'Macedo-Moraes_1777735707825', 'Morgana Oliveira', NULL, 'morgana8@live.com_1777735707825', '11987654321', '32542524237825', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:26.921405+00');
INSERT INTO public.suppliers VALUES (178, 'Costa-Santos_1777735707825', 'Dr. Noah Santos', NULL, 'tertuliano_moreira@gmail.com_1777735707825', '11987654321', '19933393017825', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.03074+00');
INSERT INTO public.suppliers VALUES (179, 'Silva-Barros_1777735707825', 'Noah Souza', NULL, 'aline.martins6@bol.com.br_1777735707825', '11987654321', '40151538977825', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.159306+00');
INSERT INTO public.suppliers VALUES (180, 'Braga e Associados_1777735707825', 'Breno Xavier', NULL, 'analuiza.franco@live.com_1777735707825', '11987654321', '55986034057825', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.287078+00');
INSERT INTO public.suppliers VALUES (181, 'Melo, Braga e Costa_1777735707825', 'Bruna Xavier', NULL, 'marli.macedo@live.com_1777735707825', '11987654321', '47602840397825', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.40285+00');
INSERT INTO public.suppliers VALUES (182, 'Martins-Nogueira_1777735707825', 'Sophia Silva', NULL, 'livia.macedo12@live.com_1777735707825', '11987654321', '31137080817825', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.517106+00');
INSERT INTO public.suppliers VALUES (183, 'Souza e Associados_1777735707825', 'Nicolas Batista', NULL, 'beatriz.moreira2@yahoo.com_1777735707825', '11987654321', '04114892397825', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.624175+00');
INSERT INTO public.suppliers VALUES (184, 'Nogueira-Barros_1777735707825', 'Davi Lucca Albuquerque', NULL, 'larissa_souza45@gmail.com_1777735707825', '11987654321', '92658381907825', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.73743+00');
INSERT INTO public.suppliers VALUES (185, 'Martins, Macedo e Nogueira_1777735707825', 'Isadora Oliveira', NULL, 'emanuelly15@bol.com.br_1777735707825', '11987654321', '82923123047825', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.848401+00');
INSERT INTO public.suppliers VALUES (186, 'Batista, Moraes e Nogueira_1777735707825', 'Yago Souza', NULL, 'elisa_santos@yahoo.com_1777735707825', '11987654321', '59596346927825', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:27.952534+00');
INSERT INTO public.suppliers VALUES (187, 'Santos-Braga_1777735707825', 'Melissa Macedo Jr.', NULL, 'sirineu.xavier@gmail.com_1777735707825', '11987654321', '95126934807825', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.069908+00');
INSERT INTO public.suppliers VALUES (188, 'Pereira, Batista e Franco_1777735707825', 'Sr. João Miguel Melo', NULL, 'carlos_santos@bol.com.br_1777735707825', '11987654321', '44331509747825', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.181171+00');
INSERT INTO public.suppliers VALUES (189, 'Oliveira-Pereira_1777735707825', 'Beatriz Albuquerque', NULL, 'leonardo.silva@live.com_1777735707825', '11987654321', '77889494787825', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.28662+00');
INSERT INTO public.suppliers VALUES (190, 'Moreira-Costa_1777735707825', 'Vitor Xavier', NULL, 'bernardo.franco46@live.com_1777735707825', '11987654321', '55959210037825', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.391902+00');
INSERT INTO public.suppliers VALUES (191, 'Silva, Costa e Braga_1777735707825', 'Sra. Valentina Saraiva', NULL, 'juliocesar_batista@yahoo.com_1777735707825', '11987654321', '30382393107825', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.505512+00');
INSERT INTO public.suppliers VALUES (192, 'Braga, Nogueira e Carvalho_1777735707825', 'Enzo Silva', NULL, 'lavinia.santos93@live.com_1777735707825', '11987654321', '03778972937825', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.628518+00');
INSERT INTO public.suppliers VALUES (193, 'Batista-Moreira_1777735707825', 'Lorena Barros', NULL, 'felipe.albuquerque27@yahoo.com_1777735707825', '11987654321', '06611451337825', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.740211+00');
INSERT INTO public.suppliers VALUES (194, 'Xavier-Santos_1777735707825', 'Breno Albuquerque', NULL, 'janaina.saraiva@live.com_1777735707825', '11987654321', '28217000857825', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.851298+00');
INSERT INTO public.suppliers VALUES (195, 'Silva-Souza_1777735707825', 'Maria Alice Saraiva', NULL, 'rafaela_oliveira63@yahoo.com_1777735707825', '11987654321', '31835672197825', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:28:28.959682+00');
INSERT INTO public.suppliers VALUES (196, 'Xavier Comércio_1777736399868', 'Paulo Santos', NULL, 'aline_nogueira@gmail.com_1777736399868', '11987654321', '18222124689868', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:39:58.689256+00');
INSERT INTO public.suppliers VALUES (197, 'Santos, Reis e Pereira_1777736399868', 'Natália Silva', NULL, 'isabela_melo41@gmail.com_1777736399868', '11987654321', '58139287219868', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 15:39:58.944258+00');
INSERT INTO public.suppliers VALUES (198, 'Distribuidora Alfa Minas Ltda', 'João Pedro Lima', NULL, 'alfa01@empresa.com', '11900000001', '10000000000001', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:52.715528+00');
INSERT INTO public.suppliers VALUES (199, 'Beta Comercial Paulista Ltda', 'Ana Carolina Souza', NULL, 'beta02@empresa.com', '11900000002', '10000000000002', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:52.958197+00');
INSERT INTO public.suppliers VALUES (200, 'Gamma Supply Rio Ltda', 'Marcos Vinicius Oliveira', NULL, 'gamma03@empresa.com', '11900000003', '10000000000003', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:53.151191+00');
INSERT INTO public.suppliers VALUES (201, 'Delta Distribuição Sul Ltda', 'Fernanda Alves Costa', NULL, 'delta04@empresa.com', '11900000004', '10000000000004', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:53.300836+00');
INSERT INTO public.suppliers VALUES (202, 'Epsilon Atacadista Ltda', 'Rafael Henrique Santos', NULL, 'epsilon05@empresa.com', '11900000005', '10000000000005', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:53.433634+00');
INSERT INTO public.suppliers VALUES (203, 'Omega Logistica Brasil Ltda', 'Patricia Gomes Lima', NULL, 'omega06@empresa.com', '11900000006', '10000000000006', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:53.553566+00');
INSERT INTO public.suppliers VALUES (204, 'Sigma Distribuidora SC Ltda', 'Bruno Eduardo Martins', NULL, 'sigma07@empresa.com', '11900000007', '10000000000007', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:53.676149+00');
INSERT INTO public.suppliers VALUES (205, 'Zeta Comercio Goiano Ltda', 'Juliana Ribeiro Souza', NULL, 'zeta08@empresa.com', '11900000008', '10000000000008', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:53.808741+00');
INSERT INTO public.suppliers VALUES (206, 'Kappa Suprimentos ES Ltda', 'Thiago Almeida Pereira', NULL, 'kappa09@empresa.com', '11900000009', '10000000000009', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:53.931246+00');
INSERT INTO public.suppliers VALUES (207, 'Lambda Distribuidora DF Ltda', 'Leticia Fernandes Rocha', NULL, 'lambda10@empresa.com', '11900000010', '10000000000010', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:54.063215+00');
INSERT INTO public.suppliers VALUES (209, 'Beta Sul Logistica Ltda', 'Camila Rocha Alves', NULL, 'beta12@empresa.com', '11900000012', '10000000000012', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:54.280251+00');
INSERT INTO public.suppliers VALUES (210, 'Gamma Centro Distribuição Ltda', 'Lucas Ferreira Santos', NULL, 'gamma13@empresa.com', '11900000013', '10000000000013', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:54.387369+00');
INSERT INTO public.suppliers VALUES (211, 'Delta Nordeste Atacado Ltda', 'Isabela Nunes Costa', NULL, 'delta14@empresa.com', '11900000014', '10000000000014', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:54.493256+00');
INSERT INTO public.suppliers VALUES (212, 'Epsilon Sudeste Comercial Ltda', 'Pedro Henrique Martins', NULL, 'epsilon15@empresa.com', '11900000015', '10000000000015', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:15:54.596229+00');
INSERT INTO public.suppliers VALUES (213, 'Distribuidoras Alfa Minas Ltda', 'João Pedro Lima', NULL, 'alfas01@empresa.com', '11900000001', '10000009000001', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:09.98206+00');
INSERT INTO public.suppliers VALUES (214, 'Betas Comercial Paulista Ltda', 'Ana Carolina Souza', NULL, 'betsa02@empresa.com', '11900000002', '10000090000002', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.142057+00');
INSERT INTO public.suppliers VALUES (215, 'Gammas Supply Rio Ltda', 'Marcos Vinicius Oliveira', NULL, 'gamsma03@empresa.com', '11900000003', '10000009000003', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.259396+00');
INSERT INTO public.suppliers VALUES (216, 'Delta sDistribuição Sul Ltda', 'Fernanda Alves Costa', NULL, 'delsta04@empresa.com', '11900000004', '10000900000004', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.382732+00');
INSERT INTO public.suppliers VALUES (217, 'Epsilson Atacadista Ltda', 'Rafael Henrique Santos', NULL, 'epsilson05@empresa.com', '11900000005', '10000090000005', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.482679+00');
INSERT INTO public.suppliers VALUES (218, 'Omegsa Logistica Brasil Ltda', 'Patricia Gomes Lima', NULL, 'omegsa06@empresa.com', '11900000006', '10000009000006', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.585746+00');
INSERT INTO public.suppliers VALUES (219, 'Sigmsa Distribuidora SC Ltda', 'Bruno Eduardo Martins', NULL, 'sigmsa07@empresa.com', '11900000007', '10000090000007', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.693372+00');
INSERT INTO public.suppliers VALUES (220, 'Zetsa Comercio Goiano Ltda', 'Juliana Ribeiro Souza', NULL, 'zetas08@empresa.com', '11900000008', '10000000900008', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.795058+00');
INSERT INTO public.suppliers VALUES (221, 'Kapspa Suprimentos ES Ltda', 'Thiago Almeida Pereira', NULL, 'kappsa09@empresa.com', '11900000009', '10000900000009', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:10.901255+00');
INSERT INTO public.suppliers VALUES (222, 'Lamsbda Distribuidora DF Ltda', 'Leticia Fernandes Rocha', NULL, 'lamsbda10@empresa.com', '11900000010', '10900000000010', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:11.019535+00');
INSERT INTO public.suppliers VALUES (223, 'Alpsha Norte Atacadista Ltda', 'Diego Santos Lima', NULL, 'alphsa11@empresa.com', '11900000011', '10000000090011', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:11.152026+00');
INSERT INTO public.suppliers VALUES (224, 'Betsa Sul Logistica Ltda', 'Camila Rocha Alves', NULL, 'betsa12@empresa.com', '11900000012', '10000000009012', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:11.303271+00');
INSERT INTO public.suppliers VALUES (225, 'Gamsma Centro Distribuição Ltda', 'Lucas Ferreira Santos', NULL, 'gammsa13@empresa.com', '11900000013', '10900000000013', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:11.439741+00');
INSERT INTO public.suppliers VALUES (226, 'Delsta Nordeste Atacado Ltda', 'Isabela Nunes Costa', NULL, 'deltsa14@empresa.com', '11900000014', '10000000900014', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:11.546059+00');
INSERT INTO public.suppliers VALUES (227, 'Epsislon Sudeste Comercial Ltda', 'Pedro Henrique Martins', NULL, 'epssilon15@empresa.com', '11900000015', '10900000000015', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:44:11.645916+00');
INSERT INTO public.suppliers VALUES (228, 'Betads Comercial Paulista Ltda', 'Ana Carolina Souza', NULL, 'bestsa02@empresa.com', '11900000002', '10000790000002', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:45:26.693513+00');
INSERT INTO public.suppliers VALUES (229, 'Gammdas Supply Rio Ltda', 'Marcos Vinicius Oliveira', NULL, 'gamssma03@empresa.com', '11900000003', '10000709000003', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:45:26.807959+00');
INSERT INTO public.suppliers VALUES (230, 'Deltda sDistribuição Sul Ltda', 'Fernanda Alves Costa', NULL, 'delssta04@empresa.com', '11900000004', '10070900000004', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:45:26.933214+00');
INSERT INTO public.suppliers VALUES (231, 'Epsidlson Atacadista Ltda', 'Rafael Henrique Santos', NULL, 'epsilsson05@empresa.com', '11900000005', '10070090000005', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:45:27.049322+00');
INSERT INTO public.suppliers VALUES (232, 'Omegdsa Logistica Brasil Ltda', 'Patricia Gomes Lima', NULL, 'omegssa06@empresa.com', '11900000006', '10000709000006', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 16:45:27.155754+00');
INSERT INTO public.suppliers VALUES (233, 'Distrirbuidoras Alfa Minas Ltda', 'João Pedro Lima', NULL, 'alsfas01@empresa.com', '11900000001', '10000039000001', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.057599+00');
INSERT INTO public.suppliers VALUES (234, 'Betards Comercial Paulista Ltda', 'Ana Carolina Souza', NULL, 'besrtsa02@empresa.com', '11900000002', '10030790000002', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.196334+00');
INSERT INTO public.suppliers VALUES (235, 'Gammrdas Supply Rio Ltda', 'Marcos Vinicius Oliveira', NULL, 'gamssrma03@empresa.com', '11900000003', '10003709000003', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.329412+00');
INSERT INTO public.suppliers VALUES (236, 'Deltdra sDistribuição Sul Ltda', 'Fernanda Alves Costa', NULL, 'delrssta04@empresa.com', '11900000004', '10030900000004', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.446746+00');
INSERT INTO public.suppliers VALUES (237, 'Epsridlson Atacadista Ltda', 'Rafael Henrique Santos', NULL, 'epsilrsson05@empresa.com', '11900000005', '10073090000005', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.577408+00');
INSERT INTO public.suppliers VALUES (238, 'Omegrsa Logistica Brasil Ltda', 'Patricia Gomes Lima', NULL, 'omegssra06@empresa.com', '11900000006', '10000703000006', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.686493+00');
INSERT INTO public.suppliers VALUES (239, 'Sigmra Distribuidora SC Ltda', 'Bruno Eduardo Martins', NULL, 'sigmrssa07@empresa.com', '11900000007', '10000093000007', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.806288+00');
INSERT INTO public.suppliers VALUES (240, 'Zetsra Comercio Goiano Ltda', 'Juliana Ribeiro Souza', NULL, 'zetas0rs8@sempresa.com', '11900000008', '10000000930008', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:26.931965+00');
INSERT INTO public.suppliers VALUES (241, 'Kapsrpa Suprimentos ES Ltda', 'Thiago Almeida Pereira', NULL, 'kappsar09@empresa.com', '11900000009', '10000900003009', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:27.032523+00');
INSERT INTO public.suppliers VALUES (242, 'Lamsrbda Distribuidora DF Ltda', 'Leticia Fernandes Rocha', NULL, 'lamrsbda10@empresa.com', '11900000010', '10900030000010', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:27.161075+00');
INSERT INTO public.suppliers VALUES (243, 'Betrsa Sul Logistica Ltda', 'Camila Rocha Alves', NULL, 'betsar12@empresa.com', '11900000012', '10000000003012', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:27.315135+00');
INSERT INTO public.suppliers VALUES (244, 'Gamrsma Centro Distribuição Ltda', 'Lucas Ferreira Santos', NULL, 'gamrmsa13@empresa.com', '11900000013', '10300000000013', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:27.418811+00');
INSERT INTO public.suppliers VALUES (245, 'Delrsta Nordeste Atacado Ltda', 'Isabela Nunes Costa', NULL, 'deltsa14r@empresa.com', '11900000014', '10000000300014', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:27.521894+00');
INSERT INTO public.suppliers VALUES (246, 'Epsislon Sudeste Comercial Ltda', 'Pedro Henrique Martins', NULL, 'epsrsilon15@empresa.com', '11900000015', '10300000000015', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 17:39:27.634443+00');
INSERT INTO public.suppliers VALUES (247, 'Distrairbuidoras Alfa Minas Ltda', 'João Pedro Lima', NULL, 'alsfaas01@empresa.com', '11900000001', '10000039700001', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:46.715722+00');
INSERT INTO public.suppliers VALUES (248, 'Betaards Comercial Paulista Ltda', 'Ana Carolina Souza', NULL, 'besartsa02@empresa.com', '11900000002', '10030490000002', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:46.860246+00');
INSERT INTO public.suppliers VALUES (249, 'Deltadra sDistribuição Sul Ltda', 'Fernanda Alves Costa', NULL, 'delarssta04@empresa.com', '11900000004', '10030904000004', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:47.083213+00');
INSERT INTO public.suppliers VALUES (250, 'Epsraidlson Atacadista Ltda', 'Rafael Henrique Santos', NULL, 'epsailrsson05@empresa.com', '11900000005', '10073090400005', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:47.236969+00');
INSERT INTO public.suppliers VALUES (251, 'Omegrasa Logistica Brasil Ltda', 'Patricia Gomes Lima', NULL, 'omegassra06@empresa.com', '11900000006', '10000703000406', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:47.356304+00');
INSERT INTO public.suppliers VALUES (252, 'Zetsara Comercio Goiano Ltda', 'Juliana Ribeiro Souza', NULL, 'zetaas0rs8@sempresa.com', '11900000008', '10000000930004', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:47.50576+00');
INSERT INTO public.suppliers VALUES (253, 'Kapsarpa Suprimentos ES Ltda', 'Thiago Almeida Pereira', NULL, 'kappsaar09@empresa.com', '11900000009', '10000900003409', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:47.642101+00');
INSERT INTO public.suppliers VALUES (254, 'Betarsa Sul Logistica Ltda', 'Camila Rocha Alves', NULL, 'betsaar12@empresa.com', '11900000012', '10000000003412', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:47.847766+00');
INSERT INTO public.suppliers VALUES (255, 'Gamrasma Centro Distribuição Ltda', 'Lucas Ferreira Santos', NULL, 'gamrmasa13@empresa.com', '11900000013', '10300400000013', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:47.959552+00');
INSERT INTO public.suppliers VALUES (256, 'Delrasta Nordeste Atacado Ltda', 'Isabela Nunes Costa', NULL, 'deltsa1a4r@empresa.com', '11900000014', '10000000304014', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:48.083366+00');
INSERT INTO public.suppliers VALUES (257, 'Epsiaslon Sudeste Comercial Ltda', 'Pedro Henrique Martins', NULL, 'epsrasilon15@empresa.com', '11900000015', '10304000000015', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:03:48.21231+00');
INSERT INTO public.suppliers VALUES (258, 'Distrayirbuidoras Alfa Minas Ltda', 'João Pedro Lima', NULL, 'alsfyaas01@empresa.com', '11900000001', '10090039700001', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:02.360677+00');
INSERT INTO public.suppliers VALUES (259, 'Betayards Comercial Paulista Ltda', 'Ana Carolina Souza', NULL, 'besyartsa02@empresa.com', '11900000002', '19030490000002', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:02.477064+00');
INSERT INTO public.suppliers VALUES (260, 'Gammraydas Supply Rio Ltda', 'Marcos Vinicius Oliveira', NULL, 'gamsasyrma03@empresa.com', '11900000003', '10093709000003', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:02.592869+00');
INSERT INTO public.suppliers VALUES (261, 'Deltadyra sDistribuição Sul Ltda', 'Fernanda Alves Costa', NULL, 'delaryssta04@empresa.com', '11900000004', '10930904000004', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:02.736104+00');
INSERT INTO public.suppliers VALUES (262, 'Epsryaidlson Atacadista Ltda', 'Rafael Henrique Santos', NULL, 'epsailrysson05@empresa.com', '11900000005', '10973090400005', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:02.857219+00');
INSERT INTO public.suppliers VALUES (263, 'Omegryasa Logistica Brasil Ltda', 'Patricia Gomes Lima', NULL, 'omegassyra06@empresa.com', '11900000006', '10009703000406', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:02.969041+00');
INSERT INTO public.suppliers VALUES (264, 'Zetsyara Comercio Goiano Ltda', 'Juliana Ribeiro Souza', NULL, 'zetaas0rys8@sempresa.com', '11900000008', '10009000930004', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:03.140323+00');
INSERT INTO public.suppliers VALUES (265, 'Kapsayrpa Suprimentos ES Ltda', 'Thiago Almeida Pereira', NULL, 'kappsaayr09@empresa.com', '11900000009', '10009900003409', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:03.251539+00');
INSERT INTO public.suppliers VALUES (266, 'Lamsayrbda Distribuidora DF Ltda', 'Leticia Fernandes Rocha', NULL, 'lamyasbda10@empresa.com', '11900000010', '10990034000000', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:03.363778+00');
INSERT INTO public.suppliers VALUES (268, 'Betarysa Sul Logistica Ltda', 'Camila Rocha Alves', NULL, 'betsaayr12@empresa.com', '11900000012', '10000009003412', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:03.613495+00');
INSERT INTO public.suppliers VALUES (269, 'Gamraysma Centro Distribuição Ltda', 'Lucas Ferreira Santos', NULL, 'gamyrmasa13@empresa.com', '11900000013', '10300900000013', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:03.737621+00');
INSERT INTO public.suppliers VALUES (270, 'Delrasyta Nordeste Atacado Ltda', 'Isabela Nunes Costa', NULL, 'deltsa1ya4r@empresa.com', '11900000014', '10000000309014', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:03.863446+00');
INSERT INTO public.suppliers VALUES (271, 'Epsiasylon Sudeste Comercial Ltda', 'Pedro Henrique Martins', NULL, 'epsrayysilon15@empresa.com', '11900000015', '10304090000015', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 19:07:04.05596+00');
INSERT INTO public.suppliers VALUES (272, 'Reis-Saraiva', 'Júlia Saraiva', NULL, 'bryan_santos63@live.com', '11987654321', '43553831416379', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:45:17.958866+00');
INSERT INTO public.suppliers VALUES (273, 'Empresa 1777765759281', 'Jewertãrero Silvad', NULL, 'teste_1777765759281@mail.com', '11987654321', '24817777657592', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.06071+00');
INSERT INTO public.suppliers VALUES (274, 'Pereira, Souza e Xavier_1777765759278', 'Benício Carvalho Filho', NULL, 'esther.franco@live.com_1777765759278', '11987654321', '78313353679278', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.06071+00');
INSERT INTO public.suppliers VALUES (275, 'Moraes-Santos', 'Sr. Fábio Carvalho', NULL, 'giovanna_carvalho27@yahoo.com', '11987654321', '11440645383142', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.149865+00');
INSERT INTO public.suppliers VALUES (276, 'Xavier Comércio_1777765759278', 'Pedro Nogueira', NULL, 'fabricia_moraes66@gmail.com_1777765759278', '11987654321', '16777844389278', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.192846+00');
INSERT INTO public.suppliers VALUES (277, 'Batista LTDA_1777765759278', 'Roberta Souza', NULL, 'davi.carvalho89@yahoo.com_1777765759278', '11987654321', '11687386439278', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.342346+00');
INSERT INTO public.suppliers VALUES (278, 'Empresa 1777765759660', 'Jewertãrero Silvad', NULL, 'teste_1777765759660@mail.com', '11987654321', '24817777657596', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.451069+00');
INSERT INTO public.suppliers VALUES (279, 'Moraes, Braga e Xavier_1777765759278', 'Dr. Roberto Carvalho', NULL, 'aline42@live.com_1777765759278', '11987654321', '67842603199278', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.472946+00');
INSERT INTO public.suppliers VALUES (280, 'Empresa 1777765759701', 'Teste QA', NULL, 'teste_1777765759701@mail.com', '11999999999', '12817777657597', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.478143+00');
INSERT INTO public.suppliers VALUES (281, 'Macedo, Martins e Souza_1777765759278', 'Ígor Nogueira Jr.', NULL, 'calebe_melo66@yahoo.com_1777765759278', '11987654321', '01881730949278', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.600496+00');
INSERT INTO public.suppliers VALUES (282, 'Barros, Costa e Moraes_1777765759278', 'Maria Júlia Silva', NULL, 'marcos70@live.com_1777765759278', '11987654321', '40158701739278', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.787444+00');
INSERT INTO public.suppliers VALUES (283, 'Braga e Associados_1777765759278', 'Antônio Pereira', NULL, 'joaomiguel48@bol.com.br_1777765759278', '11987654321', '71154261169278', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:18.967571+00');
INSERT INTO public.suppliers VALUES (284, 'Moreira e Associados_1777765759278', 'Sirineu Batista', NULL, 'isadora70@hotmail.com_1777765759278', '11987654321', '90184213989278', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:19.084023+00');
INSERT INTO public.suppliers VALUES (285, 'Barros-Macedo_1777765759278', 'Emanuelly Barros', NULL, 'hugo9@live.com_1777765759278', '11987654321', '18055883529278', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:19.217957+00');
INSERT INTO public.suppliers VALUES (286, 'Albuquerque, Xavier e Nogueira_1777765759278', 'Laura Santos', NULL, 'washington.saraiva@bol.com.br_1777765759278', '11987654321', '70133566499278', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:19.34761+00');
INSERT INTO public.suppliers VALUES (287, 'Moraes-Souza_1777765759278', 'Roberto Franco', NULL, 'arthur.barros@yahoo.com_1777765759278', '11987654321', '78737159439278', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:19.572624+00');
INSERT INTO public.suppliers VALUES (288, 'Batista S.A._1777765759278', 'Ladislau Braga', NULL, 'anajulia.silva97@live.com_1777765759278', '11987654321', '08046330749278', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:19.684571+00');
INSERT INTO public.suppliers VALUES (289, 'Santos, Melo e Silva_1777765759278', 'Ana Luiza Franco', NULL, 'kleber0@gmail.com_1777765759278', '11987654321', '16660687209278', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:19.807848+00');
INSERT INTO public.suppliers VALUES (290, 'Moreira Comércio_1777765759278', 'Pablo Nogueira', NULL, 'gustavo_braga@gmail.com_1777765759278', '11987654321', '42433167699278', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:19.95963+00');
INSERT INTO public.suppliers VALUES (291, 'Carvalho Comércio_1777765759278', 'Sr. Caio Santos', NULL, 'warley.souza7@bol.com.br_1777765759278', '11987654321', '77592562439278', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:20.091717+00');
INSERT INTO public.suppliers VALUES (292, 'Costa EIRELI_1777765759278', 'Esther Santos', NULL, 'analaura_souza@bol.com.br_1777765759278', '11987654321', '20264136869278', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:20.202163+00');
INSERT INTO public.suppliers VALUES (293, 'Batista-Oliveira_1777765759278', 'Ana Laura Costa', NULL, 'joana63@gmail.com_1777765759278', '11987654321', '83007088449278', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:20.31664+00');
INSERT INTO public.suppliers VALUES (294, 'Moraes, Moreira e Batista_1777765759278', 'Matheus Nogueira', NULL, 'tertuliano_moraes@gmail.com_1777765759278', '11987654321', '92832165199278', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:20.422165+00');
INSERT INTO public.suppliers VALUES (295, 'Batista-Xavier_1777765759278', 'Mariana Franco', NULL, 'marli62@bol.com.br_1777765759278', '11987654321', '99817877699278', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:20.530708+00');
INSERT INTO public.suppliers VALUES (296, 'Pereira EIRELI_1777765759278', 'Elísio Braga', NULL, 'ricardo30@bol.com.br_1777765759278', '11987654321', '55671382689278', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:49:20.645643+00');
INSERT INTO public.suppliers VALUES (297, 'Empresa 1777765954540', 'Jewertãrero Silvad', NULL, 'teste_1777765954540@mail.com', '11987654321', '24817777659545', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:33.350646+00');
INSERT INTO public.suppliers VALUES (298, 'Braga EIRELI', 'Miguel Nogueira', NULL, 'leonardo.reis36@gmail.com', '11987654321', '32934778126085', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:33.720642+00');
INSERT INTO public.suppliers VALUES (299, 'Melo LTDA_1777765955292', 'Srta. Joana Santos', NULL, 'enzogabriel_melo@live.com_1777765955292', '11987654321', '44778363235292', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.076369+00');
INSERT INTO public.suppliers VALUES (300, 'Martins-Saraiva_1777765955292', 'Benício Barros', NULL, 'sophia.batista@hotmail.com_1777765955292', '11987654321', '51434422105292', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.203148+00');
INSERT INTO public.suppliers VALUES (304, 'Costa, Moraes e Souza_1777765955292', 'Matheus Barros', NULL, 'maite.pereira@gmail.com_1777765955292', '11987654321', '52739205075292', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.722853+00');
INSERT INTO public.suppliers VALUES (308, 'Macedo Comércio_1777765955292', 'Hélio Xavier', NULL, 'marli.melo90@live.com_1777765955292', '11987654321', '02579912725292', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:35.268857+00');
INSERT INTO public.suppliers VALUES (312, 'Franco, Silva e Martins_1777765955292', 'Pietro Santos', NULL, 'karla_braga25@bol.com.br_1777765955292', '11987654321', '22278235435292', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:35.776696+00');
INSERT INTO public.suppliers VALUES (316, 'Melo-Moreira_1777765955292', 'Júlio César Barros', NULL, 'gustavo.nogueira0@yahoo.com_1777765955292', '11987654321', '66455029815292', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:36.318358+00');
INSERT INTO public.suppliers VALUES (1266, 'Franco, Reis e Barros_1778031453866', 'Mércia Albuquerque', NULL, 'fabiano45@bol.com.br_1778031453866', '11987654321', '46037003403866', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:34.041921+00');
INSERT INTO public.suppliers VALUES (1267, 'Braga, Saraiva e Barros_1778031453866', 'Raul Oliveira', NULL, 'morgana.reis34@bol.com.br_1778031453866', '11987654321', '34217470133866', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:34.335199+00');
INSERT INTO public.suppliers VALUES (1268, 'Costa LTDA_1778031453866', 'Bryan Silva', NULL, 'heitor.silva5@bol.com.br_1778031453866', '11987654321', '38243053703866', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:34.625582+00');
INSERT INTO public.suppliers VALUES (1269, 'Pereira, Martins e Albuquerque_1778031453866', 'Pietro Nogueira', NULL, 'marina37@bol.com.br_1778031453866', '11987654321', '24570616973866', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:34.919411+00');
INSERT INTO public.suppliers VALUES (1270, 'Reis, Carvalho e Reis_1778031453866', 'Lucca Pereira', NULL, 'paula.santos21@bol.com.br_1778031453866', '11987654321', '59669241723866', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:35.205188+00');
INSERT INTO public.suppliers VALUES (1271, 'Moraes Comércio_1778031453866', 'Isis Pereira Neto', NULL, 'davi.silva@bol.com.br_1778031453866', '11987654321', '52422161903866', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:35.487701+00');
INSERT INTO public.suppliers VALUES (1272, 'Carvalho Comércio_1778031453866', 'Srta. Eloá Oliveira', NULL, 'larissa_costa@gmail.com_1778031453866', '11987654321', '51516296243866', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:35.771643+00');
INSERT INTO public.suppliers VALUES (1273, 'Batista-Albuquerque_1778031453866', 'César Franco Neto', NULL, 'isaac97@gmail.com_1778031453866', '11987654321', '68284092403866', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:36.082678+00');
INSERT INTO public.suppliers VALUES (1274, 'Carvalho-Moreira_1778031453866', 'Beatriz Batista Neto', NULL, 'joaomiguel.xavier40@live.com_1778031453866', '11987654321', '38030243083866', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:36.376068+00');
INSERT INTO public.suppliers VALUES (1275, 'Xavier EIRELI_1778031453866', 'Júlia Pereira Neto', NULL, 'marina.macedo57@yahoo.com_1778031453866', '11987654321', '52248455543866', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:36.662444+00');
INSERT INTO public.suppliers VALUES (1276, 'Oliveira, Nogueira e Costa_1778031453866', 'Sirineu Albuquerque', NULL, 'lucca_pereira65@bol.com.br_1778031453866', '11987654321', '67641248423866', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:36.952166+00');
INSERT INTO public.suppliers VALUES (1277, 'Martins S.A._1778031453866', 'Isabelly Moraes', NULL, 'isabella.nogueira@live.com_1778031453866', '11987654321', '06413766363866', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:37.26476+00');
INSERT INTO public.suppliers VALUES (1278, 'Santos LTDA_1778031453866', 'Ana Laura Batista', NULL, 'vitor.oliveira@yahoo.com_1778031453866', '11987654321', '30780433823866', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:37.574214+00');
INSERT INTO public.suppliers VALUES (1279, 'Moreira, Batista e Nogueira_1778031453866', 'Cecília Barros', NULL, 'yango.carvalho5@bol.com.br_1778031453866', '11987654321', '08734728853866', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:37.878068+00');
INSERT INTO public.suppliers VALUES (1280, 'Silva, Carvalho e Oliveira_1778031453866', 'Márcia Santos', NULL, 'celia.franco61@bol.com.br_1778031453866', '11987654321', '72587303383866', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:38.17104+00');
INSERT INTO public.suppliers VALUES (1281, 'Franco e Associados_1778031453866', 'Yango Macedo', NULL, 'samuel40@live.com_1778031453866', '11987654321', '40773685083866', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:38.453215+00');
INSERT INTO public.suppliers VALUES (1282, 'Souza-Saraiva_1778031453866', 'Morgana Barros', NULL, 'meire_santos@yahoo.com_1778031453866', '11987654321', '00649751463866', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:38.744522+00');
INSERT INTO public.suppliers VALUES (1283, 'Costa-Martins_1778031453866', 'Janaína Moraes', NULL, 'mariajulia23@gmail.com_1778031453866', '11987654321', '55680981593866', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:39.03393+00');
INSERT INTO public.suppliers VALUES (1284, 'Silva EIRELI_1778031453866', 'Lavínia Martins', NULL, 'caio34@gmail.com_1778031453866', '11987654321', '33308338433866', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:39.32492+00');
INSERT INTO public.suppliers VALUES (1285, 'Batista, Barros e Braga_1778031453866', 'César Souza', NULL, 'felix61@bol.com.br_1778031453866', '11987654321', '12572206653866', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:39.611539+00');
INSERT INTO public.suppliers VALUES (1286, 'Empresa 1778031465417', 'Jewertãrero Silvad', NULL, 'teste_1778031465417@mail.com', '11987654321', '24817780314654', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:45.611534+00');
INSERT INTO public.suppliers VALUES (1287, 'Empresa 1778031466907', 'Teste QA', NULL, 'teste_1778031466907@mail.com', '11999999999', '12817780314669', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:37:47.081754+00');
INSERT INTO public.suppliers VALUES (1288, 'Empresa 1778031523380', 'Jewertãrero Silvad', NULL, 'teste_1778031523380@mail.com', '11987654321', '24817780315233', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:43.558534+00');
INSERT INTO public.suppliers VALUES (1289, 'Moreira e Associados', 'Sr. Murilo Moreira', NULL, 'benjamin.martins@hotmail.com', '11987654321', '29255482536651', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:44.539521+00');
INSERT INTO public.suppliers VALUES (1290, 'Braga-Santos_1778031524959', 'Yago Franco', NULL, 'igor24@hotmail.com_1778031524959', '11987654321', '83448909734959', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:45.116001+00');
INSERT INTO public.suppliers VALUES (1293, 'Pereira, Batista e Xavier_1778031524959', 'Matheus Pereira', NULL, 'suelen5@live.com_1778031524959', '11987654321', '78471827104959', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:45.942878+00');
INSERT INTO public.suppliers VALUES (1294, 'Martins Comércio_1778031524959', 'Leonardo Batista', NULL, 'analaura.albuquerque@hotmail.com_1778031524959', '11987654321', '91419329304959', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:46.182058+00');
INSERT INTO public.suppliers VALUES (1297, 'Reis-Silva_1778031524959', 'Alexandre Moreira', NULL, 'heitor_costa@live.com_1778031524959', '11987654321', '40316156884959', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:46.946051+00');
INSERT INTO public.suppliers VALUES (1298, 'Saraiva EIRELI_1778031524959', 'Vitor Santos', NULL, 'beatriz20@live.com_1778031524959', '11987654321', '60218498994959', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:47.17879+00');
INSERT INTO public.suppliers VALUES (1301, 'Melo, Reis e Souza_1778031524959', 'Laura Santos', NULL, 'daniel.saraiva90@bol.com.br_1778031524959', '11987654321', '56619162724959', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:47.936229+00');
INSERT INTO public.suppliers VALUES (1302, 'Costa LTDA_1778031524959', 'Guilherme Silva', NULL, 'yasmin_santos@yahoo.com_1778031524959', '11987654321', '11616856684959', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:48.21987+00');
INSERT INTO public.suppliers VALUES (1303, 'Xavier-Costa_1778031524959', 'Heloísa Saraiva', NULL, 'melissa.franco@gmail.com_1778031524959', '11987654321', '80546142544959', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:48.476199+00');
INSERT INTO public.suppliers VALUES (1304, 'Batista, Nogueira e Saraiva_1778031524959', 'Meire Xavier', NULL, 'mariaclara.barros@bol.com.br_1778031524959', '11987654321', '00413611934959', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:48.716733+00');
INSERT INTO public.suppliers VALUES (1305, 'Macedo, Nogueira e Costa_1778031524959', 'Larissa Pereira', NULL, 'danilo_batista@yahoo.com_1778031524959', '11987654321', '76609087114959', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:48.947067+00');
INSERT INTO public.suppliers VALUES (1306, 'Saraiva LTDA_1778031524959', 'Sra. Sophia Saraiva', NULL, 'roberto66@yahoo.com_1778031524959', '11987654321', '14324797614959', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:49.174477+00');
INSERT INTO public.suppliers VALUES (1307, 'Batista-Moreira_1778031524959', 'Sra. Maria Clara Martins', NULL, 'mariacecilia.nogueira@yahoo.com_1778031524959', '11987654321', '75148927374959', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:49.408019+00');
INSERT INTO public.suppliers VALUES (1309, 'Moraes Comércio_1778031524959', 'Henrique Silva Jr.', NULL, 'lucca65@bol.com.br_1778031524959', '11987654321', '18582410614959', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:49.866504+00');
INSERT INTO public.suppliers VALUES (1310, 'Empresa 1778031534480', 'Jewertãrero Silvad', NULL, 'teste_1778031534480@mail.com', '11987654321', '24817780315344', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:54.637457+00');
INSERT INTO public.suppliers VALUES (1313, 'Braga, Xavier e Moreira', 'Ana Clara Souza Filho', NULL, 'julio41@gmail.com', '11987654321', '75091611872563', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:13.784866+00');
INSERT INTO public.suppliers VALUES (1315, 'Braga-Santos_1778031554146', 'Warley Franco', NULL, 'antonio.xavier@bol.com.br_1778031554146', '11987654321', '26900751184146', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:14.532932+00');
INSERT INTO public.suppliers VALUES (1317, 'Santos, Nogueira e Moraes_1778031554146', 'Anthony Silva', NULL, 'esther41@yahoo.com_1778031554146', '11987654321', '19281692024146', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:14.981357+00');
INSERT INTO public.suppliers VALUES (301, 'Macedo-Nogueira_1777765955292', 'Dra. Márcia Moraes', NULL, 'enzogabriel97@gmail.com_1777765955292', '11987654321', '49230089975292', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.330302+00');
INSERT INTO public.suppliers VALUES (302, 'Nogueira, Souza e Macedo_1777765955292', 'Danilo Macedo', NULL, 'esther_costa@bol.com.br_1777765955292', '11987654321', '09609442675292', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.458898+00');
INSERT INTO public.suppliers VALUES (305, 'Costa, Moreira e Franco_1777765955292', 'Carla Xavier', NULL, 'aline56@gmail.com_1777765955292', '11987654321', '64325331805292', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.841902+00');
INSERT INTO public.suppliers VALUES (306, 'Moreira Comércio_1777765955292', 'Paula Melo', NULL, 'morgana_braga54@live.com_1777765955292', '11987654321', '67500091765292', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.981951+00');
INSERT INTO public.suppliers VALUES (309, 'Silva, Oliveira e Reis_1777765955292', 'João Miguel Nogueira', NULL, 'feliciano.moraes@yahoo.com_1777765955292', '11987654321', '06299512075292', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:35.392708+00');
INSERT INTO public.suppliers VALUES (310, 'Barros-Martins_1777765955292', 'Bernardo Martins', NULL, 'sarah56@gmail.com_1777765955292', '11987654321', '07750519665292', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:35.524621+00');
INSERT INTO public.suppliers VALUES (313, 'Martins, Souza e Reis_1777765955292', 'Ana Luiza Barros', NULL, 'marcelo.oliveira31@live.com_1777765955292', '11987654321', '17231604265292', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:35.923543+00');
INSERT INTO public.suppliers VALUES (314, 'Silva Comércio_1777765955292', 'Paula Moreira Neto', NULL, 'pablo.moraes11@gmail.com_1777765955292', '11987654321', '10359036755292', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:36.043197+00');
INSERT INTO public.suppliers VALUES (317, 'Barros Comércio_1777765955292', 'Felipe Franco', NULL, 'vitoria.moreira89@hotmail.com_1777765955292', '11987654321', '61741243875292', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:36.442333+00');
INSERT INTO public.suppliers VALUES (318, 'Martins Comércio_1777765955292', 'Dalila Santos', NULL, 'cecilia_silva@live.com_1777765955292', '11987654321', '04530771245292', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:36.563595+00');
INSERT INTO public.suppliers VALUES (319, 'Empresa 1777765960084', 'Jewertãrero Silvad', NULL, 'teste_1777765960084@mail.com', '11987654321', '24817777659600', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:38.857473+00');
INSERT INTO public.suppliers VALUES (320, 'Empresa 1777765960684', 'Teste QA', NULL, 'teste_1777765960684@mail.com', '11999999999', '12817777659606', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:39.716001+00');
INSERT INTO public.suppliers VALUES (1291, 'Santos EIRELI_1778031524959', 'Leonardo Pereira', NULL, 'morgana_franco10@hotmail.com_1778031524959', '11987654321', '13304158584959', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:45.434061+00');
INSERT INTO public.suppliers VALUES (1292, 'Xavier Comércio_1778031524959', 'Isis Oliveira', NULL, 'lavinia_carvalho@live.com_1778031524959', '11987654321', '90015938954959', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:45.682009+00');
INSERT INTO public.suppliers VALUES (1295, 'Saraiva Comércio_1778031524959', 'Eloá Oliveira', NULL, 'larissa.melo24@gmail.com_1778031524959', '11987654321', '16956262164959', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:46.460616+00');
INSERT INTO public.suppliers VALUES (1296, 'Saraiva S.A._1778031524959', 'Isabel Silva', NULL, 'eduarda.batista@bol.com.br_1778031524959', '11987654321', '26467577184959', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:46.699241+00');
INSERT INTO public.suppliers VALUES (1299, 'Franco, Souza e Silva_1778031524959', 'Enzo Souza', NULL, 'valentina72@hotmail.com_1778031524959', '11987654321', '42860290564959', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:47.447932+00');
INSERT INTO public.suppliers VALUES (1300, 'Batista e Associados_1778031524959', 'Lucca Carvalho', NULL, 'nubia_melo@bol.com.br_1778031524959', '11987654321', '51595107814959', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:47.681579+00');
INSERT INTO public.suppliers VALUES (1308, 'Costa EIRELI_1778031524959', 'Danilo Batista', NULL, 'isabelly.nogueira86@yahoo.com_1778031524959', '11987654321', '20055921094959', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:49.644887+00');
INSERT INTO public.suppliers VALUES (1311, 'Empresa 1778031535690', 'Teste QA', NULL, 'teste_1778031535690@mail.com', '11999999999', '12817780315356', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:38:55.842854+00');
INSERT INTO public.suppliers VALUES (1312, 'Empresa 1778031553000', 'Jewertãrero Silvad', NULL, 'teste_1778031553000@mail.com', '11987654321', '24817780315530', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:13.159571+00');
INSERT INTO public.suppliers VALUES (1314, 'Saraiva, Martins e Nogueira_1778031554146', 'Danilo Souza', NULL, 'marli_moreira53@gmail.com_1778031554146', '11987654321', '10120141124146', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:14.300918+00');
INSERT INTO public.suppliers VALUES (1316, 'Martins, Macedo e Nogueira_1778031554146', 'Karla Macedo', NULL, 'gael93@gmail.com_1778031554146', '11987654321', '10404566054146', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:14.747646+00');
INSERT INTO public.suppliers VALUES (1318, 'Xavier-Silva_1778031554146', 'Ofélia Franco', NULL, 'manuela91@gmail.com_1778031554146', '11987654321', '98516715124146', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:15.204953+00');
INSERT INTO public.suppliers VALUES (1320, 'Oliveira LTDA_1778031554146', 'Liz Albuquerque', NULL, 'eloa15@hotmail.com_1778031554146', '11987654321', '58681167084146', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:15.639947+00');
INSERT INTO public.suppliers VALUES (1322, 'Xavier-Silva_1778031554146', 'Isabel Moraes Jr.', NULL, 'noah.santos@bol.com.br_1778031554146', '11987654321', '05673503944146', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:16.100388+00');
INSERT INTO public.suppliers VALUES (1324, 'Costa, Albuquerque e Macedo_1778031554146', 'Sophia Oliveira', NULL, 'fabricio_martins72@yahoo.com_1778031554146', '11987654321', '86599867414146', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:16.554395+00');
INSERT INTO public.suppliers VALUES (1326, 'Silva, Silva e Braga_1778031554146', 'Alessandro Braga', NULL, 'isaac_melo84@hotmail.com_1778031554146', '11987654321', '68020695234146', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:17.000664+00');
INSERT INTO public.suppliers VALUES (1328, 'Macedo-Santos_1778031554146', 'Frederico Batista', NULL, 'rafaela54@live.com_1778031554146', '11987654321', '61044829864146', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:17.435053+00');
INSERT INTO public.suppliers VALUES (1330, 'Moreira, Barros e Barros_1778031554146', 'Vicente Santos', NULL, 'lorraine70@gmail.com_1778031554146', '11987654321', '29019126084146', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:17.895034+00');
INSERT INTO public.suppliers VALUES (1332, 'Moraes-Saraiva_1778031554146', 'Cauã Saraiva', NULL, 'bernardo96@hotmail.com_1778031554146', '11987654321', '30924393094146', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:18.351692+00');
INSERT INTO public.suppliers VALUES (1334, 'Empresa 1778031562797', 'Jewertãrero Silvad', NULL, 'teste_1778031562797@mail.com', '11987654321', '24817780315627', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:22.965798+00');
INSERT INTO public.suppliers VALUES (1335, 'Empresa 1778031563946', 'Teste QA', NULL, 'teste_1778031563946@mail.com', '11999999999', '12817780315639', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:24.086646+00');
INSERT INTO public.suppliers VALUES (1459, 'Souza, Oliveira e Costa_1778034257968', 'Frederico Martins', NULL, 'marli68@bol.com.br_1778034257968', '11987654321', '43099562197968', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:18.181582+00');
INSERT INTO public.suppliers VALUES (1460, 'Batista-Oliveira_1778034257968', 'Lucca Pereira', NULL, 'helio43@hotmail.com_1778034257968', '11987654321', '78682181177968', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:18.51156+00');
INSERT INTO public.suppliers VALUES (1461, 'Saraiva, Franco e Pereira_1778034257968', 'Beatriz Braga', NULL, 'samuel.silva@bol.com.br_1778034257968', '11987654321', '47482130757968', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:18.834849+00');
INSERT INTO public.suppliers VALUES (1462, 'Moraes-Macedo_1778034257968', 'Dra. Manuela Pereira', NULL, 'isis_xavier@bol.com.br_1778034257968', '11987654321', '81493974317968', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:19.155941+00');
INSERT INTO public.suppliers VALUES (1463, 'Saraiva Comércio_1778034257968', 'Sra. Márcia Carvalho', NULL, 'luiza_franco@gmail.com_1778034257968', '11987654321', '26451657367968', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:19.479924+00');
INSERT INTO public.suppliers VALUES (1464, 'Oliveira, Batista e Reis_1778034257968', 'Joaquim Santos', NULL, 'giovanna_santos@hotmail.com_1778034257968', '11987654321', '07500566227968', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:19.805631+00');
INSERT INTO public.suppliers VALUES (1465, 'Saraiva, Moraes e Souza_1778034257968', 'Benjamin Carvalho', NULL, 'marcelo_silva57@gmail.com_1778034257968', '11987654321', '29473854497968', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:20.135138+00');
INSERT INTO public.suppliers VALUES (1466, 'Melo-Melo_1778034257968', 'Salvador Moreira', NULL, 'eduarda_melo@bol.com.br_1778034257968', '11987654321', '65482051987968', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:20.47207+00');
INSERT INTO public.suppliers VALUES (1467, 'Reis-Reis_1778034257968', 'Helena Batista', NULL, 'janaina20@bol.com.br_1778034257968', '11987654321', '14444114297968', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:20.812545+00');
INSERT INTO public.suppliers VALUES (1468, 'Moraes EIRELI_1778034257968', 'Fabrício Carvalho Neto', NULL, 'paula.souza34@live.com_1778034257968', '11987654321', '39093240157968', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:21.134659+00');
INSERT INTO public.suppliers VALUES (1469, 'Pereira, Melo e Nogueira_1778034257968', 'Sra. Isadora Macedo', NULL, 'julio35@yahoo.com_1778034257968', '11987654321', '63683303447968', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:21.467345+00');
INSERT INTO public.suppliers VALUES (1470, 'Reis, Franco e Moreira_1778034257968', 'Carlos Nogueira', NULL, 'vitor_martins@bol.com.br_1778034257968', '11987654321', '65545114027968', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:21.794691+00');
INSERT INTO public.suppliers VALUES (1471, 'Barros-Braga_1778034257968', 'Liz Martins', NULL, 'morgana_moraes59@bol.com.br_1778034257968', '11987654321', '41484066747968', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:22.135569+00');
INSERT INTO public.suppliers VALUES (303, 'Melo EIRELI_1777765955292', 'Fábio Batista Neto', NULL, 'clara96@gmail.com_1777765955292', '11987654321', '78159666925292', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:34.584588+00');
INSERT INTO public.suppliers VALUES (307, 'Melo, Braga e Melo_1777765955292', 'Maria Alice Franco', NULL, 'felipe_saraiva23@hotmail.com_1777765955292', '11987654321', '05770399825292', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:35.146433+00');
INSERT INTO public.suppliers VALUES (311, 'Nogueira, Saraiva e Martins_1777765955292', 'Dr. Júlio César Melo', NULL, 'alice.franco@live.com_1777765955292', '11987654321', '27533523345292', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:35.657057+00');
INSERT INTO public.suppliers VALUES (315, 'Melo LTDA_1777765955292', 'Davi Lucca Martins', NULL, 'pedro.souza16@gmail.com_1777765955292', '11987654321', '22427098555292', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:52:36.187672+00');
INSERT INTO public.suppliers VALUES (321, 'Empresa 1777766111807', 'Jewertãrero Silvad', NULL, 'teste_1777766111807@mail.com', '11987654321', '24817777661118', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:55:10.662129+00');
INSERT INTO public.suppliers VALUES (322, 'Empresa 1777766113359', 'Jewertãrero Silvad', NULL, 'teste_1777766113359@mail.com', '11987654321', '24817777661133', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:55:12.14087+00');
INSERT INTO public.suppliers VALUES (323, 'Empresa 1777766114008', 'Teste QA', NULL, 'teste_1777766114008@mail.com', '11999999999', '12817777661140', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:55:12.792054+00');
INSERT INTO public.suppliers VALUES (324, 'Empresa 1777766231980', 'Jewertãrero Silvad', NULL, 'teste_1777766231980@mail.com', '11987654321', '24817777662319', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:57:10.769787+00');
INSERT INTO public.suppliers VALUES (325, 'Empresa 1777766232168', 'Jewertãrero Silvad', NULL, 'teste_1777766232168@mail.com', '11987654321', '24817777662321', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:57:10.956077+00');
INSERT INTO public.suppliers VALUES (326, 'Empresa 1777766232316', 'Teste QA', NULL, 'teste_1777766232316@mail.com', '11999999999', '12817777662323', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-02 23:57:11.093028+00');
INSERT INTO public.suppliers VALUES (327, 'Empresa 1777766537577', 'Jewertãrero Silvad', NULL, 'teste_1777766537577@mail.com', '11987654321', '24817777665375', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 00:02:16.442067+00');
INSERT INTO public.suppliers VALUES (328, 'Empresa 1777766537675', 'Jewertãrero Silvad', NULL, 'teste_1777766537675@mail.com', '11987654321', '24817777665376', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 00:02:16.448229+00');
INSERT INTO public.suppliers VALUES (329, 'Empresa 1777766537791', 'Teste QA', NULL, 'teste_1777766537791@mail.com', '11999999999', '12817777665377', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 00:02:16.566427+00');
INSERT INTO public.suppliers VALUES (330, 'Empresa 1777823491998', 'Jewertãrero Silvad', NULL, 'teste_1777823491998@mail.com', '11987654321', '24817778234919', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 15:51:31.711526+00');
INSERT INTO public.suppliers VALUES (331, 'Empresa 1777823492156', 'Jewertãrero Silvad', NULL, 'teste_1777823492156@mail.com', '11987654321', '24817778234921', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 15:51:31.89411+00');
INSERT INTO public.suppliers VALUES (332, 'Empresa 1777823492233', 'Teste QA', NULL, 'teste_1777823492233@mail.com', '11999999999', '12817778234922', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 15:51:31.935924+00');
INSERT INTO public.suppliers VALUES (333, 'Empresa 1777826044487', 'Jewertãrero Silvad', NULL, 'teste_1777826044487@mail.com', '11987654321', '24817778260444', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 16:34:04.142368+00');
INSERT INTO public.suppliers VALUES (334, 'Empresa 1777826044706', 'Jewertãrero Silvad', NULL, 'teste_1777826044706@mail.com', '11987654321', '24817778260447', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 16:34:04.26588+00');
INSERT INTO public.suppliers VALUES (335, 'Empresa 1777826044860', 'Teste QA', NULL, 'teste_1777826044860@mail.com', '11999999999', '12817778260448', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 16:34:04.423705+00');
INSERT INTO public.suppliers VALUES (336, 'Empresa 1777826805726', 'Jewertãrero Silvad', NULL, 'teste_1777826805726@mail.com', '11987654321', '24817778268057', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 16:46:45.250447+00');
INSERT INTO public.suppliers VALUES (337, 'Empresa 1777826805872', 'Jewertãrero Silvad', NULL, 'teste_1777826805872@mail.com', '11987654321', '24817778268058', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 16:46:45.408864+00');
INSERT INTO public.suppliers VALUES (338, 'Empresa 1777826805993', 'Teste QA', NULL, 'teste_1777826805993@mail.com', '11999999999', '12817778268059', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 16:46:45.517651+00');
INSERT INTO public.suppliers VALUES (339, 'Empresa 1777829614437', 'Jewertãrero Silvad', NULL, 'teste_1777829614437@mail.com', '11987654321', '24817778296144', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 17:33:33.917896+00');
INSERT INTO public.suppliers VALUES (340, 'Empresa 1777829774158', 'Jewertãrero Silvad', NULL, 'teste_1777829774158@mail.com', '11987654321', '24817778297741', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 17:36:13.745139+00');
INSERT INTO public.suppliers VALUES (341, 'Empresa 1777830304314', 'Jewertãrero Silvad', NULL, 'teste_1777830304314@mail.com', '11987654321', '24817778303043', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 17:45:03.922235+00');
INSERT INTO public.suppliers VALUES (342, 'Empresa 1777833082303', 'Jewertãrero Silvad', NULL, 'teste_1777833082303@mail.com', '11987654321', '24817778330823', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:31:21.519288+00');
INSERT INTO public.suppliers VALUES (343, 'Empresa 1777833082485', 'Jewertãrero Silvad', NULL, 'teste_1777833082485@mail.com', '11987654321', '24817778330824', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:31:21.661616+00');
INSERT INTO public.suppliers VALUES (344, 'Empresa 1777833082654', 'Teste QA', NULL, 'teste_1777833082654@mail.com', '11999999999', '12817778330826', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:31:21.814055+00');
INSERT INTO public.suppliers VALUES (345, 'Saraiva S.A.', 'Emanuelly Macedo', NULL, 'enzo.souza@gmail.com', '11987654321', '05146859299392', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:32:56.854909+00');
INSERT INTO public.suppliers VALUES (346, 'Santos, Souza e Xavier', 'Miguel Souza Filho', NULL, 'yuri_batista38@live.com', '11987654321', '90564075450289', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:05.452413+00');
INSERT INTO public.suppliers VALUES (347, 'Moraes-Nogueira_1777833213758', 'Davi Lucca Reis', NULL, 'analaura_reis15@gmail.com_1777833213758', '11987654321', '00814069773758', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:32.930803+00');
INSERT INTO public.suppliers VALUES (348, 'Saraiva S.A._1777833213758', 'Emanuelly Macedo', NULL, 'daniel.moraes3@live.com_1777833213758', '11987654321', '05536843253758', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.037765+00');
INSERT INTO public.suppliers VALUES (349, 'Moraes EIRELI_1777833213758', 'Srta. Isabel Macedo', NULL, 'mariana.nogueira10@live.com_1777833213758', '11987654321', '56700803563758', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.144867+00');
INSERT INTO public.suppliers VALUES (350, 'Martins-Saraiva_1777833213758', 'Norberto Braga', NULL, 'julia.reis@yahoo.com_1777833213758', '11987654321', '58292921623758', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.247155+00');
INSERT INTO public.suppliers VALUES (351, 'Nogueira-Albuquerque_1777833213758', 'Sra. Natália Oliveira', NULL, 'bruna50@live.com_1777833213758', '11987654321', '68533876463758', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.35108+00');
INSERT INTO public.suppliers VALUES (352, 'Saraiva-Nogueira_1777833213758', 'Núbia Martins', NULL, 'cecilia74@hotmail.com_1777833213758', '11987654321', '14033357053758', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.452753+00');
INSERT INTO public.suppliers VALUES (353, 'Santos S.A._1777833213758', 'Sra. Maria Alice Franco', NULL, 'yago.braga@live.com_1777833213758', '11987654321', '47618544803758', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.55198+00');
INSERT INTO public.suppliers VALUES (354, 'Costa, Reis e Souza_1777833213758', 'Sra. Fabrícia Xavier', NULL, 'leonardo.moraes31@hotmail.com_1777833213758', '11987654321', '08882250373758', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.66967+00');
INSERT INTO public.suppliers VALUES (355, 'Silva Comércio_1777833213758', 'Sra. Marina Saraiva', NULL, 'mariana.albuquerque@live.com_1777833213758', '11987654321', '00124935793758', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.773693+00');
INSERT INTO public.suppliers VALUES (356, 'Xavier Comércio_1777833213758', 'Srta. Giovanna Franco', NULL, 'mariaclara_albuquerque85@live.com_1777833213758', '11987654321', '73480035333758', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.886498+00');
INSERT INTO public.suppliers VALUES (357, 'Silva, Moreira e Braga_1777833213758', 'Dr. Pablo Silva', NULL, 'fabio_franco@bol.com.br_1777833213758', '11987654321', '73158615333758', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:33.985189+00');
INSERT INTO public.suppliers VALUES (358, 'Braga S.A._1777833213758', 'Esther Costa', NULL, 'margarida.batista@yahoo.com_1777833213758', '11987654321', '55713136933758', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.082671+00');
INSERT INTO public.suppliers VALUES (359, 'Saraiva, Batista e Carvalho_1777833213758', 'Suélen Franco', NULL, 'fabio67@live.com_1777833213758', '11987654321', '51293724543758', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.181657+00');
INSERT INTO public.suppliers VALUES (360, 'Nogueira, Braga e Saraiva_1777833213758', 'Henrique Macedo', NULL, 'esther.braga92@gmail.com_1777833213758', '11987654321', '57180707093758', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.286936+00');
INSERT INTO public.suppliers VALUES (361, 'Costa, Silva e Moraes_1777833213758', 'Sr. Marcos Albuquerque', NULL, 'murilo.saraiva@yahoo.com_1777833213758', '11987654321', '35008286363758', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.390274+00');
INSERT INTO public.suppliers VALUES (362, 'Pereira, Macedo e Batista_1777833213758', 'Dr. Carlos Barros', NULL, 'gabriel.pereira47@live.com_1777833213758', '11987654321', '54437384993758', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.490333+00');
INSERT INTO public.suppliers VALUES (363, 'Saraiva, Souza e Costa_1777833213758', 'Beatriz Reis', NULL, 'lorraine_souza68@live.com_1777833213758', '11987654321', '91603361613758', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.605547+00');
INSERT INTO public.suppliers VALUES (562, 'Empresa 1777848178371', 'Jewertãrero Silvad', NULL, 'teste_1777848178371@mail.com', '11987654321', '24817778481783', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:57.98777+00');
INSERT INTO public.suppliers VALUES (364, 'Xavier, Pereira e Saraiva_1777833213758', 'Lorraine Macedo', NULL, 'mariacecilia88@bol.com.br_1777833213758', '11987654321', '69942581823758', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.709789+00');
INSERT INTO public.suppliers VALUES (366, 'Costa-Franco_1777833213758', 'Luiza Martins', NULL, 'celia_macedo@yahoo.com_1777833213758', '11987654321', '36975311383758', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.930482+00');
INSERT INTO public.suppliers VALUES (1319, 'Santos, Santos e Saraiva_1778031554146', 'Washington Barros', NULL, 'yuri36@gmail.com_1778031554146', '11987654321', '19606479164146', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:15.427301+00');
INSERT INTO public.suppliers VALUES (1321, 'Silva, Braga e Saraiva_1778031554146', 'Isabella Barros', NULL, 'giovanna31@yahoo.com_1778031554146', '11987654321', '84088306554146', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:15.882433+00');
INSERT INTO public.suppliers VALUES (1323, 'Reis, Franco e Martins_1778031554146', 'Isadora Moreira', NULL, 'isabelly_oliveira94@bol.com.br_1778031554146', '11987654321', '23602215194146', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:16.323094+00');
INSERT INTO public.suppliers VALUES (1325, 'Carvalho S.A._1778031554146', 'Isadora Pereira', NULL, 'salvador95@live.com_1778031554146', '11987654321', '56630304374146', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:16.775178+00');
INSERT INTO public.suppliers VALUES (1327, 'Silva, Moreira e Souza_1778031554146', 'Fabrícia Macedo', NULL, 'yago_martins10@gmail.com_1778031554146', '11987654321', '43636296684146', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:17.224125+00');
INSERT INTO public.suppliers VALUES (1329, 'Moreira, Carvalho e Costa_1778031554146', 'Deneval Albuquerque', NULL, 'meire66@live.com_1778031554146', '11987654321', '04212790794146', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:17.67103+00');
INSERT INTO public.suppliers VALUES (1331, 'Macedo, Carvalho e Costa_1778031554146', 'Maria Luiza Braga', NULL, 'pietro_moreira60@live.com_1778031554146', '11987654321', '83558000434146', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:18.106416+00');
INSERT INTO public.suppliers VALUES (1333, 'Barros-Nogueira_1778031554146', 'Lara Oliveira', NULL, 'yasmin83@hotmail.com_1778031554146', '11987654321', '72701378824146', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:39:18.563035+00');
INSERT INTO public.suppliers VALUES (1472, 'Martins e Associados_1778034257968', 'Nicolas Xavier Jr.', NULL, 'theo.santos@bol.com.br_1778034257968', '11987654321', '11403064977968', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:22.473474+00');
INSERT INTO public.suppliers VALUES (1473, 'Moreira-Macedo_1778034257968', 'Hélio Moreira', NULL, 'hugo.batista38@bol.com.br_1778034257968', '11987654321', '15863638577968', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:23.040361+00');
INSERT INTO public.suppliers VALUES (1474, 'Melo e Associados_1778034257968', 'Joana Martins', NULL, 'paula_saraiva@live.com_1778034257968', '11987654321', '49352480647968', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:23.374422+00');
INSERT INTO public.suppliers VALUES (1475, 'Xavier, Oliveira e Macedo_1778034257968', 'Guilherme Pereira', NULL, 'antonella.martins41@gmail.com_1778034257968', '11987654321', '59022131387968', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:23.714368+00');
INSERT INTO public.suppliers VALUES (1476, 'Saraiva-Xavier_1778034257968', 'Natália Oliveira', NULL, 'feliciano.souza26@yahoo.com_1778034257968', '11987654321', '84331357077968', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:24.051305+00');
INSERT INTO public.suppliers VALUES (1477, 'Moreira, Moraes e Carvalho_1778034257968', 'Liz Moreira', NULL, 'larissa77@yahoo.com_1778034257968', '11987654321', '30864047557968', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:24.42932+00');
INSERT INTO public.suppliers VALUES (1478, 'Albuquerque, Pereira e Braga_1778034257968', 'Rebeca Moreira', NULL, 'esther_reis@live.com_1778034257968', '11987654321', '27522119967968', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:24.778435+00');
INSERT INTO public.suppliers VALUES (1479, 'Empresa 1778034270592', 'Jewertãrero Silvad', NULL, 'teste_1778034270592@mail.com', '11987654321', '24817780342705', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:30.808844+00');
INSERT INTO public.suppliers VALUES (1587, 'Schultz Group', 'Silvia Larson', NULL, 'clara.watsica98@gmail.com', '11987654321', '01779675255793', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-25 02:14:15.880793+00');
INSERT INTO public.suppliers VALUES (365, 'Carvalho, Franco e Martins_1777833213758', 'Eduardo Batista Filho', NULL, 'pedrohenrique.moreira@hotmail.com_1777833213758', '11987654321', '24991765413758', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:33:34.831788+00');
INSERT INTO public.suppliers VALUES (367, 'Empresa 1777833255147', 'Teste QA', NULL, 'teste_1777833255147@mail.com', '11999999999', '12817778332551', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:34:14.359543+00');
INSERT INTO public.suppliers VALUES (368, 'Empresa 1777833535191', 'Jewertãrero Silvad', NULL, 'teste_1777833535191@mail.com', '11987654321', '24817778335351', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.307738+00');
INSERT INTO public.suppliers VALUES (369, 'Carvalho LTDA', 'Maria Eduarda Pereira', NULL, 'joaopedro.barros@yahoo.com', '11987654321', '02983791616301', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.321683+00');
INSERT INTO public.suppliers VALUES (370, 'Batista-Melo_1777833535199', 'Raul Souza', NULL, 'norberto.santos@gmail.com_1777833535199', '11987654321', '43511645945199', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.337158+00');
INSERT INTO public.suppliers VALUES (371, 'Martins EIRELI_1777833535199', 'Antônio Martins', NULL, 'kleber_braga@hotmail.com_1777833535199', '11987654321', '05551252385199', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.534251+00');
INSERT INTO public.suppliers VALUES (372, 'Empresa 1777833535443', 'Jewertãrero Silvad', NULL, 'teste_1777833535443@mail.com', '11987654321', '24817778335354', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.61459+00');
INSERT INTO public.suppliers VALUES (373, 'Empresa 1777833535548', 'Teste QA', NULL, 'teste_1777833535548@mail.com', '11999999999', '12817778335355', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.688805+00');
INSERT INTO public.suppliers VALUES (374, 'Moreira e Associados_1777833535199', 'Lívia Moreira', NULL, 'caio_saraiva2@gmail.com_1777833535199', '11987654321', '19974975925199', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.765108+00');
INSERT INTO public.suppliers VALUES (375, 'Batista-Macedo_1777833535199', 'Paula Pereira', NULL, 'joaolucas.silva@yahoo.com_1777833535199', '11987654321', '73695848845199', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:54.891757+00');
INSERT INTO public.suppliers VALUES (376, 'Nogueira, Oliveira e Xavier_1777833535199', 'Lara Albuquerque', NULL, 'heloisa14@yahoo.com_1777833535199', '11987654321', '89160422545199', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:55.032157+00');
INSERT INTO public.suppliers VALUES (377, 'Moraes, Souza e Pereira_1777833535199', 'Sirineu Pereira', NULL, 'analuiza9@live.com_1777833535199', '11987654321', '70336979325199', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:55.266563+00');
INSERT INTO public.suppliers VALUES (378, 'Carvalho, Batista e Braga_1777833535199', 'Melissa Xavier', NULL, 'washington_franco@gmail.com_1777833535199', '11987654321', '54520015145199', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:55.550138+00');
INSERT INTO public.suppliers VALUES (380, 'Oliveira-Moraes_1777833535199', 'Marcela Nogueira', NULL, 'helio23@yahoo.com_1777833535199', '11987654321', '98472777225199', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.021067+00');
INSERT INTO public.suppliers VALUES (381, 'Carvalho Comércio_1777833535199', 'Dr. César Souza', NULL, 'lara29@live.com_1777833535199', '11987654321', '92622000615199', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.12478+00');
INSERT INTO public.suppliers VALUES (382, 'Macedo-Barros_1777833535199', 'Sra. Marli Carvalho', NULL, 'joaomiguel7@hotmail.com_1777833535199', '11987654321', '81901102615199', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.285278+00');
INSERT INTO public.suppliers VALUES (383, 'Costa LTDA_1777833535199', 'Isabel Santos', NULL, 'aline1@gmail.com_1777833535199', '11987654321', '11544474885199', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.379699+00');
INSERT INTO public.suppliers VALUES (384, 'Braga, Oliveira e Souza_1777833535199', 'Srta. Marcela Saraiva', NULL, 'davi.carvalho78@hotmail.com_1777833535199', '11987654321', '97848450605199', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.488612+00');
INSERT INTO public.suppliers VALUES (385, 'Moraes, Reis e Macedo_1777833535199', 'Giovanna Saraiva', NULL, 'alice_pereira@hotmail.com_1777833535199', '11987654321', '95667769325199', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.613625+00');
INSERT INTO public.suppliers VALUES (386, 'Albuquerque-Franco_1777833535199', 'Júlia Albuquerque', NULL, 'isabel.carvalho2@hotmail.com_1777833535199', '11987654321', '77828061805199', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.72002+00');
INSERT INTO public.suppliers VALUES (387, 'Macedo-Moraes_1777833535199', 'Márcia Carvalho', NULL, 'igor82@hotmail.com_1777833535199', '11987654321', '64197596945199', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.824745+00');
INSERT INTO public.suppliers VALUES (388, 'Moreira-Carvalho_1777833535199', 'Ana Laura Moraes', NULL, 'silas83@bol.com.br_1777833535199', '11987654321', '83934561725199', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:56.946097+00');
INSERT INTO public.suppliers VALUES (389, 'Pereira, Nogueira e Santos_1777833535199', 'Rafaela Martins', NULL, 'celia76@yahoo.com_1777833535199', '11987654321', '83341578335199', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:57.058416+00');
INSERT INTO public.suppliers VALUES (390, 'Batista-Santos_1777833535199', 'Noah Saraiva', NULL, 'igor_costa@gmail.com_1777833535199', '11987654321', '89990114635199', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:57.177688+00');
INSERT INTO public.suppliers VALUES (391, 'Santos, Martins e Batista_1777833535199', 'Caio Pereira', NULL, 'isabela.batista@bol.com.br_1777833535199', '11987654321', '52515516045199', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 18:38:57.289897+00');
INSERT INTO public.suppliers VALUES (392, 'Empresa 1777835478826', 'Jewertãrero Silvad', NULL, 'teste_1777835478826@mail.com', '11987654321', '24817778354788', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:17.868991+00');
INSERT INTO public.suppliers VALUES (393, 'Franco-Albuquerque', 'Isabela Reis', NULL, 'vicente3@yahoo.com', '11987654321', '42949569751937', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:17.89225+00');
INSERT INTO public.suppliers VALUES (394, 'Franco, Moraes e Martins_1777835479293', 'Dra. Maria Helena Pereira', NULL, 'dalila.macedo71@bol.com.br_1777835479293', '11987654321', '25155008179293', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:18.413805+00');
INSERT INTO public.suppliers VALUES (395, 'Empresa 1777835479535', 'Jewertãrero Silvad', NULL, 'teste_1777835479535@mail.com', '11987654321', '24817778354795', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:18.582975+00');
INSERT INTO public.suppliers VALUES (396, 'Silva Comércio_1777835479293', 'Gabriel Braga', NULL, 'alessandra.macedo71@hotmail.com_1777835479293', '11987654321', '69563204519293', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:18.631761+00');
INSERT INTO public.suppliers VALUES (397, 'Empresa 1777835479665', 'Teste QA', NULL, 'teste_1777835479665@mail.com', '11999999999', '12817778354796', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:18.696802+00');
INSERT INTO public.suppliers VALUES (398, 'Braga-Reis_1777835479293', 'Fabiano Souza', NULL, 'maria99@gmail.com_1777835479293', '11987654321', '24395584949293', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:18.865869+00');
INSERT INTO public.suppliers VALUES (399, 'Batista LTDA_1777835479293', 'Daniel Moreira', NULL, 'roberto36@live.com_1777835479293', '11987654321', '18320472389293', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:18.992149+00');
INSERT INTO public.suppliers VALUES (400, 'Souza-Santos_1777835479293', 'Sra. Ana Laura Franco', NULL, 'lorena_albuquerque70@live.com_1777835479293', '11987654321', '50847396839293', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:19.215782+00');
INSERT INTO public.suppliers VALUES (401, 'Franco, Nogueira e Nogueira_1777835479293', 'Théo Melo', NULL, 'sara.costa@yahoo.com_1777835479293', '11987654321', '32794598009293', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:19.321518+00');
INSERT INTO public.suppliers VALUES (402, 'Souza-Melo_1777835479293', 'Carla Barros', NULL, 'sirineu5@hotmail.com_1777835479293', '11987654321', '49968417729293', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:19.420391+00');
INSERT INTO public.suppliers VALUES (403, 'Moraes LTDA_1777835479293', 'Joana Batista', NULL, 'hugo59@yahoo.com_1777835479293', '11987654321', '00841986489293', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:19.538708+00');
INSERT INTO public.suppliers VALUES (404, 'Melo-Saraiva_1777835479293', 'Pedro Henrique Albuquerque', NULL, 'anthony_carvalho@hotmail.com_1777835479293', '11987654321', '27218352129293', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:19.64325+00');
INSERT INTO public.suppliers VALUES (405, 'Macedo EIRELI_1777835479293', 'Dalila Batista', NULL, 'ofelia_franco@hotmail.com_1777835479293', '11987654321', '93499774189293', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:19.840095+00');
INSERT INTO public.suppliers VALUES (406, 'Albuquerque-Costa_1777835479293', 'Salvador Carvalho', NULL, 'bernardo73@hotmail.com_1777835479293', '11987654321', '43439708619293', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:19.949286+00');
INSERT INTO public.suppliers VALUES (407, 'Batista-Costa_1777835479293', 'Ricardo Oliveira', NULL, 'marcos45@bol.com.br_1777835479293', '11987654321', '40533386519293', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.139671+00');
INSERT INTO public.suppliers VALUES (408, 'Moraes, Nogueira e Santos_1777835479293', 'Suélen Silva', NULL, 'isabella.reis75@bol.com.br_1777835479293', '11987654321', '48597957749293', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.245552+00');
INSERT INTO public.suppliers VALUES (409, 'Santos EIRELI_1777835479293', 'Fabiano Pereira', NULL, 'gubio.costa@hotmail.com_1777835479293', '11987654321', '19914809319293', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.34647+00');
INSERT INTO public.suppliers VALUES (410, 'Silva e Associados_1777835479293', 'Fabiano Moraes Jr.', NULL, 'frederico.pereira@hotmail.com_1777835479293', '11987654321', '39196876029293', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.466195+00');
INSERT INTO public.suppliers VALUES (411, 'Barros-Batista_1777835479293', 'Warley Xavier', NULL, 'matheus_silva64@live.com_1777835479293', '11987654321', '62425863129293', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.574299+00');
INSERT INTO public.suppliers VALUES (412, 'Oliveira-Albuquerque_1777835479293', 'Morgana Saraiva', NULL, 'enzogabriel78@yahoo.com_1777835479293', '11987654321', '53188717639293', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.696533+00');
INSERT INTO public.suppliers VALUES (414, 'Reis e Associados_1777835479293', 'Gustavo Pereira', NULL, 'bryan68@yahoo.com_1777835479293', '11987654321', '94565768529293', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.951847+00');
INSERT INTO public.suppliers VALUES (1336, 'Macedo-Macedo_1778031858366', 'Sirineu Macedo', NULL, 'dalila66@yahoo.com_1778031858366', '11987654321', '16215284118366', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.033549+00');
INSERT INTO public.suppliers VALUES (1337, 'Empresa 1778031858484', 'Jewertãrero Silvad', NULL, 'teste_1778031858484@mail.com', '11987654321', '24817780318584', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.056671+00');
INSERT INTO public.suppliers VALUES (1339, 'Costa, Pereira e Moraes', 'Lara Barros', NULL, 'carla_carvalho51@hotmail.com', '11987654321', '02799597588830', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.278094+00');
INSERT INTO public.suppliers VALUES (1342, 'Empresa 1778031859050', 'Teste QA', NULL, 'teste_1778031859050@mail.com', '11999999999', '12817780318590', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.628764+00');
INSERT INTO public.suppliers VALUES (1348, 'Martins-Pereira_1778031858366', 'Isaac Carvalho', NULL, 'fabio.moraes@hotmail.com_1778031858366', '11987654321', '74744744898366', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:19.390176+00');
INSERT INTO public.suppliers VALUES (1349, 'Batista, Reis e Macedo_1778031858366', 'Antônio Carvalho', NULL, 'antonella.souza25@hotmail.com_1778031858366', '11987654321', '66616409838366', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:19.510604+00');
INSERT INTO public.suppliers VALUES (1481, 'Empresa 1778035322473', 'Jewertãrero Silvad', NULL, 'teste_1778035322473@mail.com', '11987654321', '24817780353224', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:02.652712+00');
INSERT INTO public.suppliers VALUES (1504, 'Empresa 1778035333836', 'Teste QA', NULL, 'teste_1778035333836@mail.com', '11999999999', '12817780353338', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:13.982159+00');
INSERT INTO public.suppliers VALUES (1588, 'Brakus, Reichel and Nicolas', 'Myrtle Stark', NULL, 'alanna7@yahoo.com', '11987654321', '01779675401175', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-25 02:16:41.144664+00');
INSERT INTO public.suppliers VALUES (413, 'Reis e Associados_1777835479293', 'Paulo Batista', NULL, 'raul34@yahoo.com_1777835479293', '11987654321', '59156688679293', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:20.818277+00');
INSERT INTO public.suppliers VALUES (415, 'Costa-Carvalho_1777835479293', 'Alessandra Pereira', NULL, 'silas40@gmail.com_1777835479293', '11987654321', '94135638909293', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 19:11:21.069166+00');
INSERT INTO public.suppliers VALUES (416, 'Empresa 1777838866642', 'Jewertãrero Silvad', NULL, 'teste_1777838866642@mail.com', '11987654321', '24817778388666', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:46.876279+00');
INSERT INTO public.suppliers VALUES (417, 'Moraes-Martins', 'Frederico Silva Neto', NULL, 'roberto_melo0@bol.com.br', '11987654321', '88149526666513', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:47.45797+00');
INSERT INTO public.suppliers VALUES (418, 'Franco, Braga e Albuquerque_1777838867846', 'Júlia Silva', NULL, 'pedro.nogueira92@bol.com.br_1777838867846', '11987654321', '81228959827846', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:47.996277+00');
INSERT INTO public.suppliers VALUES (419, 'Santos EIRELI_1777838867846', 'Deneval Oliveira', NULL, 'vitor_moreira@bol.com.br_1777838867846', '11987654321', '24010482997846', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:48.307332+00');
INSERT INTO public.suppliers VALUES (420, 'Melo, Moraes e Braga_1777838867846', 'Hugo Moreira Neto', NULL, 'alicia83@yahoo.com_1777838867846', '11987654321', '66326102187846', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:48.544305+00');
INSERT INTO public.suppliers VALUES (421, 'Nogueira-Oliveira_1777838867846', 'Ígor Saraiva', NULL, 'helena.souza0@hotmail.com_1777838867846', '11987654321', '45844612157846', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:48.792096+00');
INSERT INTO public.suppliers VALUES (422, 'Melo e Associados_1777838867846', 'Maria Helena Macedo', NULL, 'marli.souza@live.com_1777838867846', '11987654321', '86284729547846', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:49.018228+00');
INSERT INTO public.suppliers VALUES (423, 'Martins S.A._1777838867846', 'Carlos Nogueira', NULL, 'maria21@bol.com.br_1777838867846', '11987654321', '63320017587846', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:49.259767+00');
INSERT INTO public.suppliers VALUES (424, 'Silva S.A._1777838867846', 'Gúbio Saraiva', NULL, 'bryan_braga@live.com_1777838867846', '11987654321', '53981065977846', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:49.491525+00');
INSERT INTO public.suppliers VALUES (425, 'Carvalho e Associados_1777838867846', 'Roberto Costa', NULL, 'laura_albuquerque47@gmail.com_1777838867846', '11987654321', '94199081777846', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:49.717533+00');
INSERT INTO public.suppliers VALUES (426, 'Albuquerque-Pereira_1777838867846', 'Dra. Margarida Nogueira', NULL, 'breno_moraes@hotmail.com_1777838867846', '11987654321', '29752213537846', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:49.958989+00');
INSERT INTO public.suppliers VALUES (427, 'Moreira, Pereira e Nogueira_1777838867846', 'Srta. Lavínia Moreira', NULL, 'manuela_carvalho19@live.com_1777838867846', '11987654321', '09753484767846', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:50.198562+00');
INSERT INTO public.suppliers VALUES (428, 'Nogueira EIRELI_1777838867846', 'Sr. Ladislau Pereira', NULL, 'sophia69@live.com_1777838867846', '11987654321', '62922449567846', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:50.425371+00');
INSERT INTO public.suppliers VALUES (429, 'Macedo-Pereira_1777838867846', 'Noah Franco', NULL, 'sara40@gmail.com_1777838867846', '11987654321', '03470259747846', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:50.648656+00');
INSERT INTO public.suppliers VALUES (430, 'Pereira, Santos e Costa_1777838867846', 'Cecília Pereira', NULL, 'washington93@bol.com.br_1777838867846', '11987654321', '74336419337846', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:50.863249+00');
INSERT INTO public.suppliers VALUES (431, 'Santos-Barros_1777838867846', 'Isabela Xavier', NULL, 'esther.melo10@bol.com.br_1777838867846', '11987654321', '96047894227846', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:51.082276+00');
INSERT INTO public.suppliers VALUES (432, 'Xavier, Costa e Melo_1777838867846', 'Antônio Batista', NULL, 'isabella_macedo@gmail.com_1777838867846', '11987654321', '44708890537846', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:51.321739+00');
INSERT INTO public.suppliers VALUES (433, 'Moraes, Moreira e Reis_1777838867846', 'Hélio Silva', NULL, 'alice_braga@hotmail.com_1777838867846', '11987654321', '23931791197846', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:51.552653+00');
INSERT INTO public.suppliers VALUES (434, 'Xavier-Franco_1777838867846', 'Frederico Oliveira', NULL, 'mariaclara17@yahoo.com_1777838867846', '11987654321', '23330801257846', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:51.775603+00');
INSERT INTO public.suppliers VALUES (435, 'Carvalho, Costa e Santos_1777838867846', 'Anthony Souza', NULL, 'lara_braga40@gmail.com_1777838867846', '11987654321', '49543510057846', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:52.000532+00');
INSERT INTO public.suppliers VALUES (436, 'Albuquerque, Franco e Santos_1777838867846', 'Anthony Moreira', NULL, 'maite17@yahoo.com_1777838867846', '11987654321', '83313391127846', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:52.220979+00');
INSERT INTO public.suppliers VALUES (438, 'Empresa 1777838874229', 'Jewertãrero Silvad', NULL, 'teste_1777838874229@mail.com', '11987654321', '24817778388742', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:54.606989+00');
INSERT INTO public.suppliers VALUES (439, 'Empresa 1777838875598', 'Teste QA', NULL, 'teste_1777838875598@mail.com', '11999999999', '12817778388755', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:55.745349+00');
INSERT INTO public.suppliers VALUES (440, 'Empresa 1777838877114', 'Teste QA', NULL, 'teste_1777838877114@mail.com', '11999999999', '12817778388771', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:57.2728+00');
INSERT INTO public.suppliers VALUES (441, 'Empresa 1777838878708', 'Teste QA', NULL, 'teste_1777838878708@mail.com', '11999999999', '12817778388787', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 20:07:58.873206+00');
INSERT INTO public.suppliers VALUES (442, 'Costa e Associados', 'César Saraiva', NULL, 'ofelia.barros52@bol.com.br', '11987654321', '76529955113206', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:44.726078+00');
INSERT INTO public.suppliers VALUES (443, 'Empresa 1777846784837', 'Jewertãrero Silvad', NULL, 'teste_1777846784837@mail.com', '11987654321', '24817778467848', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:44.733735+00');
INSERT INTO public.suppliers VALUES (444, 'Silva Comércio_1777846785380', 'Yasmin Barros', NULL, 'isabelly36@yahoo.com_1777846785380', '11987654321', '18642113635380', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:45.067833+00');
INSERT INTO public.suppliers VALUES (445, 'Franco, Barros e Oliveira_1777846785380', 'Sr. Benício Xavier', NULL, 'mariaalice_reis37@bol.com.br_1777846785380', '11987654321', '97894867705380', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:45.189798+00');
INSERT INTO public.suppliers VALUES (446, 'Saraiva-Costa_1777846785380', 'Bernardo Carvalho', NULL, 'dalila.batista81@bol.com.br_1777846785380', '11987654321', '72886058535380', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:45.402378+00');
INSERT INTO public.suppliers VALUES (447, 'Carvalho-Xavier_1777846785380', 'Yango Albuquerque', NULL, 'caio.santos@live.com_1777846785380', '11987654321', '00573371285380', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:45.655367+00');
INSERT INTO public.suppliers VALUES (448, 'Empresa 1777846786014', 'Jewertãrero Silvad', NULL, 'teste_1777846786014@mail.com', '11987654321', '24817778467860', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:45.808731+00');
INSERT INTO public.suppliers VALUES (449, 'Martins-Moraes_1777846785380', 'Norberto Batista', NULL, 'felix24@yahoo.com_1777846785380', '11987654321', '59544631065380', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:45.880026+00');
INSERT INTO public.suppliers VALUES (450, 'Empresa 1777846786194', 'Teste QA', NULL, 'teste_1777846786194@mail.com', '11999999999', '12817778467861', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:45.902246+00');
INSERT INTO public.suppliers VALUES (451, 'Pereira LTDA_1777846785380', 'Morgana Barros', NULL, 'felix.franco38@live.com_1777846785380', '11987654321', '34796887605380', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:46.044044+00');
INSERT INTO public.suppliers VALUES (452, 'Barros-Braga_1777846785380', 'Dra. Isadora Franco', NULL, 'pedro.souza@gmail.com_1777846785380', '11987654321', '00277029065380', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:46.17954+00');
INSERT INTO public.suppliers VALUES (453, 'Albuquerque, Souza e Silva_1777846785380', 'Mércia Martins', NULL, 'marcelo.silva10@yahoo.com_1777846785380', '11987654321', '96778935185380', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:46.353103+00');
INSERT INTO public.suppliers VALUES (454, 'Reis-Silva_1777846785380', 'Bruna Silva', NULL, 'joaquim_barros41@live.com_1777846785380', '11987654321', '23970914135380', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:46.5504+00');
INSERT INTO public.suppliers VALUES (455, 'Barros-Martins_1777846785380', 'Maria Júlia Costa', NULL, 'victor_reis@live.com_1777846785380', '11987654321', '74481992195380', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:46.782429+00');
INSERT INTO public.suppliers VALUES (456, 'Pereira-Xavier_1777846785380', 'Felícia Pereira', NULL, 'mariaeduarda_barros@yahoo.com_1777846785380', '11987654321', '06795728335380', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.042461+00');
INSERT INTO public.suppliers VALUES (457, 'Martins LTDA_1777846785380', 'João Souza', NULL, 'fabricia_moreira@live.com_1777846785380', '11987654321', '67404609205380', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.223232+00');
INSERT INTO public.suppliers VALUES (458, 'Moraes, Moraes e Oliveira_1777846785380', 'João Pedro Carvalho', NULL, 'bruna_pereira@live.com_1777846785380', '11987654321', '65309119625380', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.348802+00');
INSERT INTO public.suppliers VALUES (459, 'Reis Comércio_1777846785380', 'Felícia Batista', NULL, 'rafael.nogueira43@yahoo.com_1777846785380', '11987654321', '81576538545380', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.455508+00');
INSERT INTO public.suppliers VALUES (460, 'Souza-Melo_1777846785380', 'Ladislau Souza', NULL, 'isabela_saraiva58@gmail.com_1777846785380', '11987654321', '86875991445380', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.577607+00');
INSERT INTO public.suppliers VALUES (461, 'Moreira-Reis_1777846785380', 'Roberto Batista', NULL, 'breno_costa63@bol.com.br_1777846785380', '11987654321', '54503458205380', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.686118+00');
INSERT INTO public.suppliers VALUES (462, 'Pereira, Nogueira e Xavier_1777846785380', 'Talita Moraes Filho', NULL, 'nicolas.braga@gmail.com_1777846785380', '11987654321', '00540512935380', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.801093+00');
INSERT INTO public.suppliers VALUES (463, 'Pereira, Saraiva e Xavier_1777846785380', 'Lucca Xavier', NULL, 'lorena_moraes@yahoo.com_1777846785380', '11987654321', '78071373195380', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:47.905609+00');
INSERT INTO public.suppliers VALUES (464, 'Martins e Associados_1777846785380', 'Júlio Carvalho Filho', NULL, 'giovanna_souza@live.com_1777846785380', '11987654321', '33557664235380', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:48.025332+00');
INSERT INTO public.suppliers VALUES (465, 'Moreira-Albuquerque_1777846785380', 'Dra. Aline Nogueira', NULL, 'yango_reis91@bol.com.br_1777846785380', '11987654321', '92990204785380', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:19:48.135024+00');
INSERT INTO public.suppliers VALUES (466, 'Moraes-Reis', 'Júlia Albuquerque', NULL, 'warley_macedo9@hotmail.com', '11987654321', '61132149909689', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:08.517445+00');
INSERT INTO public.suppliers VALUES (467, 'Empresa 1777847108809', 'Jewertãrero Silvad', NULL, 'teste_1777847108809@mail.com', '11987654321', '24817778471088', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:08.617942+00');
INSERT INTO public.suppliers VALUES (468, 'Braga LTDA_1777847108988', 'Larissa Oliveira', NULL, 'warley19@live.com_1777847108988', '11987654321', '73630395578988', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:08.675361+00');
INSERT INTO public.suppliers VALUES (469, 'Macedo, Costa e Moraes_1777847108988', 'Bruna Moraes', NULL, 'frederico1@bol.com.br_1777847108988', '11987654321', '21336473128988', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:08.814672+00');
INSERT INTO public.suppliers VALUES (470, 'Empresa 1777847109163', 'Jewertãrero Silvad', NULL, 'teste_1777847109163@mail.com', '11987654321', '24817778471091', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:08.870083+00');
INSERT INTO public.suppliers VALUES (471, 'Empresa 1777847109331', 'Teste QA', NULL, 'teste_1777847109331@mail.com', '11999999999', '12817778471093', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:09.019781+00');
INSERT INTO public.suppliers VALUES (472, 'Nogueira, Costa e Barros_1777847108988', 'Márcia Nogueira', NULL, 'vitor50@yahoo.com_1777847108988', '11987654321', '04974162008988', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:09.123056+00');
INSERT INTO public.suppliers VALUES (473, 'Pereira S.A._1777847108988', 'Suélen Reis', NULL, 'julia_souza@yahoo.com_1777847108988', '11987654321', '89328260808988', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:09.256519+00');
INSERT INTO public.suppliers VALUES (474, 'Costa, Braga e Franco_1777847108988', 'Nicolas Macedo', NULL, 'karla14@gmail.com_1777847108988', '11987654321', '17029412898988', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:09.455448+00');
INSERT INTO public.suppliers VALUES (475, 'Santos, Saraiva e Moraes_1777847108988', 'Marli Macedo', NULL, 'eloa_saraiva@yahoo.com_1777847108988', '11987654321', '91224230678988', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:09.57968+00');
INSERT INTO public.suppliers VALUES (476, 'Saraiva, Batista e Barros_1777847108988', 'Srta. Antonella Nogueira', NULL, 'elisa63@hotmail.com_1777847108988', '11987654321', '18412929018988', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:09.873351+00');
INSERT INTO public.suppliers VALUES (477, 'Batista-Martins_1777847108988', 'Breno Martins', NULL, 'meire79@live.com_1777847108988', '11987654321', '66998578788988', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:09.996629+00');
INSERT INTO public.suppliers VALUES (478, 'Pereira e Associados_1777847108988', 'César Nogueira Neto', NULL, 'celia.melo@gmail.com_1777847108988', '11987654321', '42907146708988', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.110792+00');
INSERT INTO public.suppliers VALUES (479, 'Albuquerque, Melo e Reis_1777847108988', 'Dra. Alícia Costa', NULL, 'paula.franco@yahoo.com_1777847108988', '11987654321', '47501765468988', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.233985+00');
INSERT INTO public.suppliers VALUES (480, 'Moraes-Silva_1777847108988', 'Davi Lucca Macedo', NULL, 'raul.martins@hotmail.com_1777847108988', '11987654321', '08760645888988', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.354042+00');
INSERT INTO public.suppliers VALUES (481, 'Silva, Nogueira e Souza_1777847108988', 'Dra. Fabrícia Martins', NULL, 'arthur_saraiva@hotmail.com_1777847108988', '11987654321', '27031596838988', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.479544+00');
INSERT INTO public.suppliers VALUES (482, 'Braga-Albuquerque_1777847108988', 'Ana Laura Nogueira', NULL, 'victor.macedo@yahoo.com_1777847108988', '11987654321', '44089973168988', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.592938+00');
INSERT INTO public.suppliers VALUES (483, 'Melo-Costa_1777847108988', 'Natália Moreira', NULL, 'mariaeduarda8@live.com_1777847108988', '11987654321', '07132864918988', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.70957+00');
INSERT INTO public.suppliers VALUES (484, 'Melo, Silva e Macedo_1777847108988', 'Felipe Macedo', NULL, 'joaquim21@yahoo.com_1777847108988', '11987654321', '54988652478988', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.837165+00');
INSERT INTO public.suppliers VALUES (485, 'Moraes S.A._1777847108988', 'Lívia Costa', NULL, 'celia17@yahoo.com_1777847108988', '11987654321', '31226624508988', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:10.952707+00');
INSERT INTO public.suppliers VALUES (486, 'Franco, Moraes e Silva_1777847108988', 'Félix Moraes', NULL, 'nataniel_barros@hotmail.com_1777847108988', '11987654321', '92810914378988', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:11.090236+00');
INSERT INTO public.suppliers VALUES (487, 'Oliveira e Associados_1777847108988', 'Luiza Moraes', NULL, 'henrique31@hotmail.com_1777847108988', '11987654321', '37887231138988', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:11.205321+00');
INSERT INTO public.suppliers VALUES (488, 'Batista, Barros e Pereira_1777847108988', 'Antonella Reis', NULL, 'lorenzo53@bol.com.br_1777847108988', '11987654321', '81182037818988', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:11.35042+00');
INSERT INTO public.suppliers VALUES (489, 'Reis-Xavier_1777847108988', 'Maria Xavier', NULL, 'ladislau50@yahoo.com_1777847108988', '11987654321', '24279407668988', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:25:11.463004+00');
INSERT INTO public.suppliers VALUES (490, 'Empresa 1777847368890', 'Jewertãrero Silvad', NULL, 'teste_1777847368890@mail.com', '11987654321', '24817778473688', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:28.564524+00');
INSERT INTO public.suppliers VALUES (491, 'Pereira-Souza', 'Isabel Macedo', NULL, 'daniel68@live.com', '11987654321', '86678712677715', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:28.588235+00');
INSERT INTO public.suppliers VALUES (492, 'Melo EIRELI_1777847368967', 'Ofélia Souza', NULL, 'vitoria_barros@hotmail.com_1777847368967', '11987654321', '88145282898967', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:28.636843+00');
INSERT INTO public.suppliers VALUES (494, 'Empresa 1777847369256', 'Teste QA', NULL, 'teste_1777847369256@mail.com', '11999999999', '12817778473692', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:28.923987+00');
INSERT INTO public.suppliers VALUES (495, 'Silva e Associados_1777847368967', 'Théo Santos', NULL, 'paula91@gmail.com_1777847368967', '11987654321', '16240127538967', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:28.959145+00');
INSERT INTO public.suppliers VALUES (496, 'Empresa 1777847369303', 'Jewertãrero Silvad', NULL, 'teste_1777847369303@mail.com', '11987654321', '24817778473693', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:28.958663+00');
INSERT INTO public.suppliers VALUES (497, 'Pereira, Saraiva e Carvalho_1777847368967', 'Ana Laura Costa', NULL, 'deneval_saraiva79@hotmail.com_1777847368967', '11987654321', '05814311898967', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:29.175287+00');
INSERT INTO public.suppliers VALUES (498, 'Moraes-Barros_1777847368967', 'Leonardo Souza Filho', NULL, 'gustavo.oliveira@bol.com.br_1777847368967', '11987654321', '43636394768967', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:29.367289+00');
INSERT INTO public.suppliers VALUES (499, 'Xavier, Xavier e Oliveira_1777847368967', 'Esther Costa', NULL, 'emanuelly86@live.com_1777847368967', '11987654321', '45442982558967', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:29.573313+00');
INSERT INTO public.suppliers VALUES (500, 'Souza, Costa e Oliveira_1777847368967', 'Laura Martins', NULL, 'heloisa.nogueira@gmail.com_1777847368967', '11987654321', '10106911478967', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:29.700326+00');
INSERT INTO public.suppliers VALUES (501, 'Silva-Costa_1777847368967', 'Clara Barros', NULL, 'nicolas.macedo12@gmail.com_1777847368967', '11987654321', '33211906558967', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:29.837338+00');
INSERT INTO public.suppliers VALUES (502, 'Reis, Albuquerque e Albuquerque_1777847368967', 'Júlio Franco', NULL, 'margarida_batista@yahoo.com_1777847368967', '11987654321', '81182786458967', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:30.068301+00');
INSERT INTO public.suppliers VALUES (503, 'Moraes, Costa e Braga_1777847368967', 'Isis Moraes', NULL, 'lorenzo_souza79@bol.com.br_1777847368967', '11987654321', '21865060458967', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:30.265057+00');
INSERT INTO public.suppliers VALUES (504, 'Martins-Moraes_1777847368967', 'Sr. Lucca Macedo', NULL, 'hugo.saraiva@yahoo.com_1777847368967', '11987654321', '78538914028967', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:30.39326+00');
INSERT INTO public.suppliers VALUES (505, 'Reis e Associados_1777847368967', 'Margarida Barros', NULL, 'pedrohenrique43@live.com_1777847368967', '11987654321', '30393897088967', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:30.539141+00');
INSERT INTO public.suppliers VALUES (506, 'Melo Comércio_1777847368967', 'Felícia Souza', NULL, 'pietro37@gmail.com_1777847368967', '11987654321', '49899117208967', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:30.668764+00');
INSERT INTO public.suppliers VALUES (508, 'Martins-Franco_1777847368967', 'Norberto Barros', NULL, 'silvia79@bol.com.br_1777847368967', '11987654321', '74726504548967', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:30.926365+00');
INSERT INTO public.suppliers VALUES (510, 'Santos, Franco e Oliveira_1777847368967', 'Ladislau Oliveira', NULL, 'carla.pereira@bol.com.br_1777847368967', '11987654321', '64790966888967', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:31.194096+00');
INSERT INTO public.suppliers VALUES (512, 'Xavier-Barros_1777847368967', 'Pedro Henrique Batista', NULL, 'enzo73@bol.com.br_1777847368967', '11987654321', '23073001858967', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:31.458046+00');
INSERT INTO public.suppliers VALUES (1338, 'Silva e Associados_1778031858366', 'Janaína Martins', NULL, 'sophia55@hotmail.com_1778031858366', '11987654321', '07937414028366', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.26112+00');
INSERT INTO public.suppliers VALUES (1341, 'Empresa 1778031859016', 'Jewertãrero Silvad', NULL, 'teste_1778031859016@mail.com', '11987654321', '24817780318590', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.586651+00');
INSERT INTO public.suppliers VALUES (1343, 'Macedo, Carvalho e Costa_1778031858366', 'Larissa Reis', NULL, 'kleber_franco75@gmail.com_1778031858366', '11987654321', '76648720708366', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.645232+00');
INSERT INTO public.suppliers VALUES (1344, 'Franco S.A._1778031858366', 'Félix Moreira', NULL, 'eduarda.macedo58@yahoo.com_1778031858366', '11987654321', '48555665158366', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.772122+00');
INSERT INTO public.suppliers VALUES (1345, 'Braga-Reis_1778031858366', 'Melissa Martins', NULL, 'hugo.pereira@hotmail.com_1778031858366', '11987654321', '81153887078366', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.979687+00');
INSERT INTO public.suppliers VALUES (1352, 'Braga-Melo_1778031858366', 'Sophia Silva Jr.', NULL, 'noah40@hotmail.com_1778031858366', '11987654321', '23528774018366', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:19.933659+00');
INSERT INTO public.suppliers VALUES (1482, 'Batista, Santos e Moreira', 'Raul Melo', NULL, 'alexandre40@bol.com.br', '11987654321', '52367697854425', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:03.557586+00');
INSERT INTO public.suppliers VALUES (1589, 'Towne Group', 'Michele Von', NULL, 'darrel.torphy@yahoo.com', '11987654321', '01779678568443', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-25 03:09:28.456729+00');
INSERT INTO public.suppliers VALUES (507, 'Oliveira-Moraes_1777847368967', 'Raul Nogueira', NULL, 'joaolucas_moreira@gmail.com_1777847368967', '11987654321', '83182994678967', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:30.791973+00');
INSERT INTO public.suppliers VALUES (509, 'Macedo-Melo_1777847368967', 'Sra. Liz Nogueira', NULL, 'bruna_moraes@bol.com.br_1777847368967', '11987654321', '37320928468967', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:31.050954+00');
INSERT INTO public.suppliers VALUES (511, 'Barros-Macedo_1777847368967', 'Rebeca Souza', NULL, 'emanuel_carvalho30@gmail.com_1777847368967', '11987654321', '70362179798967', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:31.339248+00');
INSERT INTO public.suppliers VALUES (513, 'Santos, Souza e Moraes_1777847368967', 'Elísio Albuquerque', NULL, 'lorraine75@live.com_1777847368967', '11987654321', '46312279788967', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:29:31.581116+00');
INSERT INTO public.suppliers VALUES (514, 'Batista Comércio_1777847465125', 'Vitor Souza', NULL, 'yago.batista72@yahoo.com_1777847465125', '11987654321', '00986941585125', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:04.812048+00');
INSERT INTO public.suppliers VALUES (515, 'Empresa 1777847465150', 'Jewertãrero Silvad', NULL, 'teste_1777847465150@mail.com', '11987654321', '24817778474651', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:04.826021+00');
INSERT INTO public.suppliers VALUES (516, 'Batista S.A.', 'Sra. Ofélia Moraes', NULL, 'vitoria65@yahoo.com', '11987654321', '10751168207418', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:04.877331+00');
INSERT INTO public.suppliers VALUES (517, 'Nogueira e Associados_1777847465125', 'Clara Moraes', NULL, 'bernardo.melo@live.com_1777847465125', '11987654321', '10224631365125', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:04.96256+00');
INSERT INTO public.suppliers VALUES (518, 'Macedo-Santos_1777847465125', 'Dra. Suélen Xavier', NULL, 'julio.souza19@yahoo.com_1777847465125', '11987654321', '44779501605125', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.105022+00');
INSERT INTO public.suppliers VALUES (519, 'Empresa 1777847465511', 'Teste QA', NULL, 'teste_1777847465511@mail.com', '11999999999', '12817778474655', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.183209+00');
INSERT INTO public.suppliers VALUES (520, 'Empresa 1777847465488', 'Jewertãrero Silvad', NULL, 'teste_1777847465488@mail.com', '11987654321', '24817778474654', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.185864+00');
INSERT INTO public.suppliers VALUES (521, 'Xavier-Costa_1777847465125', 'Elisa Carvalho', NULL, 'caio_carvalho73@live.com_1777847465125', '11987654321', '12133135725125', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.23647+00');
INSERT INTO public.suppliers VALUES (522, 'Macedo, Albuquerque e Macedo_1777847465125', 'Lorraine Macedo', NULL, 'salvador78@live.com_1777847465125', '11987654321', '67377840095125', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.378108+00');
INSERT INTO public.suppliers VALUES (523, 'Silva-Santos_1777847465125', 'Isadora Oliveira', NULL, 'clara_xavier26@live.com_1777847465125', '11987654321', '65570659505125', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.576034+00');
INSERT INTO public.suppliers VALUES (524, 'Santos, Barros e Xavier_1777847465125', 'Murilo Barros Jr.', NULL, 'pedro_santos76@yahoo.com_1777847465125', '11987654321', '95721586615125', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.851591+00');
INSERT INTO public.suppliers VALUES (525, 'Pereira S.A._1777847465125', 'Norberto Costa', NULL, 'joana_martins77@hotmail.com_1777847465125', '11987654321', '12980263765125', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:05.993356+00');
INSERT INTO public.suppliers VALUES (526, 'Franco-Melo_1777847465125', 'Antônio Melo', NULL, 'sarah.franco48@hotmail.com_1777847465125', '11987654321', '22407496935125', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:06.207639+00');
INSERT INTO public.suppliers VALUES (527, 'Melo-Moraes_1777847465125', 'Cecília Saraiva', NULL, 'bruna.pereira@yahoo.com_1777847465125', '11987654321', '70302410085125', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:06.334354+00');
INSERT INTO public.suppliers VALUES (528, 'Nogueira Comércio_1777847465125', 'Srta. Sophia Braga', NULL, 'giovanna.oliveira20@gmail.com_1777847465125', '11987654321', '63453371175125', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:06.463887+00');
INSERT INTO public.suppliers VALUES (529, 'Saraiva LTDA_1777847465125', 'Lucca Nogueira Neto', NULL, 'leonardo7@hotmail.com_1777847465125', '11987654321', '30747217035125', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:06.574628+00');
INSERT INTO public.suppliers VALUES (530, 'Braga, Moraes e Oliveira_1777847465125', 'Sr. Kléber Pereira', NULL, 'norberto_oliveira@gmail.com_1777847465125', '11987654321', '47766293015125', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:06.791956+00');
INSERT INTO public.suppliers VALUES (531, 'Martins, Nogueira e Franco_1777847465125', 'Maria Barros Neto', NULL, 'beatriz34@live.com_1777847465125', '11987654321', '89586934775125', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:06.938592+00');
INSERT INTO public.suppliers VALUES (532, 'Batista-Moraes_1777847465125', 'Isabella Oliveira', NULL, 'fabiano.braga@bol.com.br_1777847465125', '11987654321', '75323993885125', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:07.065532+00');
INSERT INTO public.suppliers VALUES (533, 'Costa, Batista e Braga_1777847465125', 'Sarah Macedo', NULL, 'matheus_batista31@live.com_1777847465125', '11987654321', '47181007225125', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:07.1939+00');
INSERT INTO public.suppliers VALUES (534, 'Macedo, Reis e Martins_1777847465125', 'Isis Braga', NULL, 'aline.barros@live.com_1777847465125', '11987654321', '68043784255125', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:07.332128+00');
INSERT INTO public.suppliers VALUES (535, 'Santos, Moreira e Albuquerque_1777847465125', 'Caio Batista', NULL, 'bryan_martins@hotmail.com_1777847465125', '11987654321', '40606498285125', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:07.470217+00');
INSERT INTO public.suppliers VALUES (536, 'Xavier-Pereira_1777847465125', 'Fábio Costa', NULL, 'melissa_carvalho12@yahoo.com_1777847465125', '11987654321', '78123111645125', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:07.59542+00');
INSERT INTO public.suppliers VALUES (537, 'Costa-Martins_1777847465125', 'Félix Macedo', NULL, 'natalia.batista99@hotmail.com_1777847465125', '11987654321', '28209298465125', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:31:07.716936+00');
INSERT INTO public.suppliers VALUES (538, 'Empresa 1777847558323', 'Teste QA', NULL, 'teste_1777847558323@mail.com', '11999999999', '12817778475583', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:32:38.075446+00');
INSERT INTO public.suppliers VALUES (539, 'Empresa 1777847575609', 'Teste QA', NULL, 'teste_1777847575609@mail.com', '11999999999', '12817778475756', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:32:55.280348+00');
INSERT INTO public.suppliers VALUES (540, 'Empresa 1777848173826', 'Jewertãrero Silvad', NULL, 'teste_1777848173826@mail.com', '11987654321', '24817778481738', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:53.524833+00');
INSERT INTO public.suppliers VALUES (541, 'Batista, Batista e Xavier', 'Srta. Natália Silva', NULL, 'theo.oliveira55@hotmail.com', '11987654321', '01743966743830', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:53.873084+00');
INSERT INTO public.suppliers VALUES (542, 'Franco S.A._1777848174554', 'Maria Alice Silva', NULL, 'anaclara_macedo@live.com_1777848174554', '11987654321', '46848503634554', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.171055+00');
INSERT INTO public.suppliers VALUES (543, 'Carvalho LTDA_1777848174554', 'Gúbio Barros Jr.', NULL, 'pietro_martins@yahoo.com_1777848174554', '11987654321', '70575835324554', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.273758+00');
INSERT INTO public.suppliers VALUES (544, 'Costa e Associados_1777848174554', 'Júlia Nogueira', NULL, 'pedro40@hotmail.com_1777848174554', '11987654321', '93367853594554', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.402388+00');
INSERT INTO public.suppliers VALUES (545, 'Franco, Batista e Moraes_1777848174554', 'Fabrícia Saraiva', NULL, 'leonardo.moraes@live.com_1777848174554', '11987654321', '52363000554554', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.511213+00');
INSERT INTO public.suppliers VALUES (546, 'Pereira, Barros e Braga_1777848174554', 'Mércia Nogueira', NULL, 'washington_oliveira@yahoo.com_1777848174554', '11987654321', '90048878814554', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.619681+00');
INSERT INTO public.suppliers VALUES (547, 'Braga e Associados_1777848174554', 'Laura Saraiva', NULL, 'murilo.melo@hotmail.com_1777848174554', '11987654321', '80961152034554', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.74359+00');
INSERT INTO public.suppliers VALUES (548, 'Batista-Souza_1777848174554', 'Heitor Nogueira', NULL, 'fabricio32@yahoo.com_1777848174554', '11987654321', '27922231504554', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.868054+00');
INSERT INTO public.suppliers VALUES (549, 'Xavier, Saraiva e Moraes_1777848174554', 'Laura Macedo', NULL, 'lara80@gmail.com_1777848174554', '11987654321', '54281731454554', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:54.978893+00');
INSERT INTO public.suppliers VALUES (550, 'Melo, Melo e Batista_1777848174554', 'Marcos Santos', NULL, 'isis_moraes@live.com_1777848174554', '11987654321', '84470650734554', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.091406+00');
INSERT INTO public.suppliers VALUES (551, 'Franco, Pereira e Costa_1777848174554', 'Luiza Reis', NULL, 'theo.oliveira@yahoo.com_1777848174554', '11987654321', '80833641304554', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.20194+00');
INSERT INTO public.suppliers VALUES (552, 'Barros EIRELI_1777848174554', 'Isis Moreira', NULL, 'isabel.pereira@live.com_1777848174554', '11987654321', '37234642284554', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.302418+00');
INSERT INTO public.suppliers VALUES (553, 'Nogueira, Moraes e Franco_1777848174554', 'Sophia Souza', NULL, 'alessandro.xavier64@gmail.com_1777848174554', '11987654321', '40444388024554', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.428958+00');
INSERT INTO public.suppliers VALUES (555, 'Melo LTDA_1777848174554', 'Alice Carvalho', NULL, 'nubia.braga35@yahoo.com_1777848174554', '11987654321', '16745523204554', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.661451+00');
INSERT INTO public.suppliers VALUES (556, 'Melo, Batista e Batista_1777848174554', 'Hélio Braga', NULL, 'anajulia59@hotmail.com_1777848174554', '11987654321', '89496103754554', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.775965+00');
INSERT INTO public.suppliers VALUES (558, 'Albuquerque-Pereira_1777848174554', 'Dra. Maitê Melo', NULL, 'meire30@bol.com.br_1777848174554', '11987654321', '30574391004554', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.984479+00');
INSERT INTO public.suppliers VALUES (560, 'Batista e Associados_1777848174554', 'Raul Macedo Jr.', NULL, 'mariaeduarda76@live.com_1777848174554', '11987654321', '68154641974554', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:56.191615+00');
INSERT INTO public.suppliers VALUES (1340, 'Martins, Albuquerque e Albuquerque_1778031858366', 'Beatriz Macedo', NULL, 'julia.souza@bol.com.br_1778031858366', '11987654321', '06048795298366', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:18.382523+00');
INSERT INTO public.suppliers VALUES (1346, 'Souza, Souza e Costa_1778031858366', 'Fabrícia Melo', NULL, 'marcos67@yahoo.com_1778031858366', '11987654321', '89914000198366', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:19.093685+00');
INSERT INTO public.suppliers VALUES (1350, 'Martins, Xavier e Pereira_1778031858366', 'Dr. Elísio Barros', NULL, 'helena26@bol.com.br_1778031858366', '11987654321', '57114349838366', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:19.623104+00');
INSERT INTO public.suppliers VALUES (1351, 'Martins e Associados_1778031858366', 'Fabrícia Melo', NULL, 'davilucca41@bol.com.br_1778031858366', '11987654321', '25710493648366', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:19.828938+00');
INSERT INTO public.suppliers VALUES (1353, 'Souza Comércio_1778031858366', 'Paulo Albuquerque', NULL, 'washington_pereira@hotmail.com_1778031858366', '11987654321', '57509133858366', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:20.055559+00');
INSERT INTO public.suppliers VALUES (1354, 'Melo, Oliveira e Saraiva_1778031858366', 'Washington Nogueira', NULL, 'marcela.santos@bol.com.br_1778031858366', '11987654321', '38638954088366', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:20.239877+00');
INSERT INTO public.suppliers VALUES (1355, 'Macedo-Pereira_1778031858366', 'Liz Moraes', NULL, 'analaura_oliveira@hotmail.com_1778031858366', '11987654321', '65049047748366', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:20.350718+00');
INSERT INTO public.suppliers VALUES (1356, 'Silva-Martins_1778031858366', 'Carla Oliveira', NULL, 'roberto65@gmail.com_1778031858366', '11987654321', '44549091438366', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:20.45837+00');
INSERT INTO public.suppliers VALUES (1357, 'Silva, Batista e Nogueira_1778031858366', 'Beatriz Franco', NULL, 'lorenzo.martins64@live.com_1778031858366', '11987654321', '46588008598366', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:20.576595+00');
INSERT INTO public.suppliers VALUES (1358, 'Reis, Braga e Pereira_1778031858366', 'Noah Batista Filho', NULL, 'mariaalice_pereira@hotmail.com_1778031858366', '11987654321', '44901324468366', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:20.686553+00');
INSERT INTO public.suppliers VALUES (1359, 'Franco LTDA_1778031858366', 'Mariana Macedo', NULL, 'pedro_barros@live.com_1778031858366', '11987654321', '15858044508366', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:44:20.793875+00');
INSERT INTO public.suppliers VALUES (1483, 'Oliveira, Saraiva e Oliveira_1778035323931', 'Enzo Batista', NULL, 'igor49@live.com_1778035323931', '11987654321', '77006648703931', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:04.074224+00');
INSERT INTO public.suppliers VALUES (1484, 'Costa Comércio_1778035323931', 'Gustavo Oliveira', NULL, 'isabela_silva78@hotmail.com_1778035323931', '11987654321', '24330702193931', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:04.308173+00');
INSERT INTO public.suppliers VALUES (1485, 'Saraiva LTDA_1778035323931', 'Isis Xavier', NULL, 'fabiano62@live.com_1778035323931', '11987654321', '17822051773931', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:04.535527+00');
INSERT INTO public.suppliers VALUES (1486, 'Barros Comércio_1778035323931', 'Dr. Théo Moraes', NULL, 'bryan.moraes@yahoo.com_1778035323931', '11987654321', '80551881153931', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:04.752711+00');
INSERT INTO public.suppliers VALUES (1487, 'Franco S.A._1778035323931', 'Salvador Oliveira', NULL, 'lavinia_saraiva9@hotmail.com_1778035323931', '11987654321', '47540831023931', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:04.979666+00');
INSERT INTO public.suppliers VALUES (1488, 'Souza Comércio_1778035323931', 'Isabelly Oliveira', NULL, 'isadora.batista33@yahoo.com_1778035323931', '11987654321', '40629047423931', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:05.19531+00');
INSERT INTO public.suppliers VALUES (1489, 'Moraes-Melo_1778035323931', 'Noah Souza Jr.', NULL, 'juliocesar.braga43@gmail.com_1778035323931', '11987654321', '79326889673931', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:05.405429+00');
INSERT INTO public.suppliers VALUES (1490, 'Souza-Xavier_1778035323931', 'Washington Barros', NULL, 'mariaeduarda63@yahoo.com_1778035323931', '11987654321', '23556727103931', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:05.61295+00');
INSERT INTO public.suppliers VALUES (1491, 'Oliveira-Carvalho_1778035323931', 'Maria Júlia Santos', NULL, 'eloa_reis74@bol.com.br_1778035323931', '11987654321', '68979319563931', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:05.883463+00');
INSERT INTO public.suppliers VALUES (1492, 'Santos Comércio_1778035323931', 'Salvador Saraiva', NULL, 'benicio60@hotmail.com_1778035323931', '11987654321', '01897703283931', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:06.10165+00');
INSERT INTO public.suppliers VALUES (1493, 'Moreira LTDA_1778035323931', 'Clara Moreira', NULL, 'vitor58@live.com_1778035323931', '11987654321', '50355422043931', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:06.318084+00');
INSERT INTO public.suppliers VALUES (1494, 'Souza, Pereira e Albuquerque_1778035323931', 'Yuri Albuquerque', NULL, 'calebe_pereira50@gmail.com_1778035323931', '11987654321', '13462360103931', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:06.546554+00');
INSERT INTO public.suppliers VALUES (1495, 'Barros, Moraes e Saraiva_1778035323931', 'Elísio Melo', NULL, 'elisa_pereira44@hotmail.com_1778035323931', '11987654321', '57705810773931', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:06.767552+00');
INSERT INTO public.suppliers VALUES (1496, 'Costa LTDA_1778035323931', 'Isabelly Santos', NULL, 'felicia.macedo@hotmail.com_1778035323931', '11987654321', '98914206343931', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:06.982058+00');
INSERT INTO public.suppliers VALUES (1497, 'Oliveira-Saraiva_1778035323931', 'Ana Luiza Moreira', NULL, 'luiza.moreira@gmail.com_1778035323931', '11987654321', '98954203683931', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:07.196916+00');
INSERT INTO public.suppliers VALUES (1498, 'Santos-Melo_1778035323931', 'Silas Costa', NULL, 'anthony_pereira6@hotmail.com_1778035323931', '11987654321', '14797461863931', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:07.40671+00');
INSERT INTO public.suppliers VALUES (1499, 'Costa, Saraiva e Saraiva_1778035323931', 'Sra. Ana Luiza Oliveira', NULL, 'livia.batista36@gmail.com_1778035323931', '11987654321', '32864898773931', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:07.620769+00');
INSERT INTO public.suppliers VALUES (1501, 'Xavier EIRELI_1778035323931', 'Emanuelly Santos', NULL, 'warley.oliveira10@gmail.com_1778035323931', '11987654321', '72801757983931', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:08.118672+00');
INSERT INTO public.suppliers VALUES (1502, 'Melo-Nogueira_1778035323931', 'Célia Santos', NULL, 'yango.braga79@bol.com.br_1778035323931', '11987654321', '60582752613931', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:08.330808+00');
INSERT INTO public.suppliers VALUES (1503, 'Empresa 1778035332700', 'Jewertãrero Silvad', NULL, 'teste_1778035332700@mail.com', '11987654321', '24817780353327', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:42:12.875498+00');
INSERT INTO public.suppliers VALUES (1590, 'Kulas - Hansen', 'Neil Prosacco', NULL, 'bennie_gibson@gmail.com', '11987654321', '01779678697630', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-25 03:11:37.632761+00');
INSERT INTO public.suppliers VALUES (557, 'Macedo, Costa e Martins_1777848174554', 'Clara Xavier', NULL, 'joana.franco@bol.com.br_1777848174554', '11987654321', '23432406004554', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:55.880242+00');
INSERT INTO public.suppliers VALUES (559, 'Melo e Associados_1777848174554', 'Mércia Nogueira', NULL, 'maite3@hotmail.com_1777848174554', '11987654321', '95802551474554', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:56.089095+00');
INSERT INTO public.suppliers VALUES (561, 'Silva EIRELI_1777848174554', 'Sra. Janaína Costa', NULL, 'leonardo76@bol.com.br_1777848174554', '11987654321', '05760571034554', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:42:56.29654+00');
INSERT INTO public.suppliers VALUES (563, 'Empresa 1777848251021', 'Jewertãrero Silvad', NULL, 'teste_1777848251021@mail.com', '11987654321', '24817778482510', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:10.720945+00');
INSERT INTO public.suppliers VALUES (564, 'Carvalho, Silva e Macedo', 'João Miguel Braga', NULL, 'isabel.saraiva@gmail.com', '11987654321', '02705389568308', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:11.065445+00');
INSERT INTO public.suppliers VALUES (565, 'Saraiva, Moraes e Costa_1777848251773', 'Lívia Souza', NULL, 'sirineu53@live.com_1777848251773', '11987654321', '31708271031773', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:11.415308+00');
INSERT INTO public.suppliers VALUES (566, 'Xavier S.A._1777848251773', 'Sr. Enzo Franco', NULL, 'vitoria_xavier33@live.com_1777848251773', '11987654321', '41960193911773', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:11.556152+00');
INSERT INTO public.suppliers VALUES (567, 'Batista-Souza_1777848251773', 'Laura Batista', NULL, 'emanuel41@gmail.com_1777848251773', '11987654321', '98947178901773', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:11.682948+00');
INSERT INTO public.suppliers VALUES (568, 'Santos Comércio_1777848251773', 'Noah Macedo', NULL, 'salvador88@yahoo.com_1777848251773', '11987654321', '37579016251773', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:11.812374+00');
INSERT INTO public.suppliers VALUES (569, 'Saraiva-Santos_1777848251773', 'Isis Souza', NULL, 'davi_nogueira79@gmail.com_1777848251773', '11987654321', '96918488151773', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:11.936994+00');
INSERT INTO public.suppliers VALUES (570, 'Reis-Melo_1777848251773', 'Mércia Souza', NULL, 'eloa.pereira31@yahoo.com_1777848251773', '11987654321', '93219247021773', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.046196+00');
INSERT INTO public.suppliers VALUES (571, 'Moreira-Saraiva_1777848251773', 'Maria Cecília Reis', NULL, 'danilo.melo@gmail.com_1777848251773', '11987654321', '77493640011773', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.163559+00');
INSERT INTO public.suppliers VALUES (572, 'Franco, Souza e Moraes_1777848251773', 'Leonardo Silva', NULL, 'emanuelly11@bol.com.br_1777848251773', '11987654321', '38229478641773', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.309553+00');
INSERT INTO public.suppliers VALUES (573, 'Franco S.A._1777848251773', 'Suélen Santos', NULL, 'bernardo_silva4@bol.com.br_1777848251773', '11987654321', '57714082681773', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.438556+00');
INSERT INTO public.suppliers VALUES (574, 'Melo-Melo_1777848251773', 'Benjamin Macedo', NULL, 'alice_xavier49@bol.com.br_1777848251773', '11987654321', '55105771151773', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.56165+00');
INSERT INTO public.suppliers VALUES (575, 'Souza Comércio_1777848251773', 'Mariana Batista', NULL, 'caio_franco@yahoo.com_1777848251773', '11987654321', '30048215521773', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.70085+00');
INSERT INTO public.suppliers VALUES (576, 'Silva, Macedo e Barros_1777848251773', 'Eloá Martins', NULL, 'marcela47@yahoo.com_1777848251773', '11987654321', '11074278471773', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.833642+00');
INSERT INTO public.suppliers VALUES (577, 'Macedo-Silva_1777848251773', 'Paulo Santos Neto', NULL, 'livia.reis81@bol.com.br_1777848251773', '11987654321', '15616281951773', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:12.948942+00');
INSERT INTO public.suppliers VALUES (578, 'Pereira, Oliveira e Pereira_1777848251773', 'Alícia Reis Filho', NULL, 'samuel2@bol.com.br_1777848251773', '11987654321', '20362701621773', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:13.067948+00');
INSERT INTO public.suppliers VALUES (579, 'Melo-Moraes_1777848251773', 'Heloísa Franco', NULL, 'julia.franco@yahoo.com_1777848251773', '11987654321', '43931174911773', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:13.178664+00');
INSERT INTO public.suppliers VALUES (580, 'Silva EIRELI_1777848251773', 'Warley Moraes', NULL, 'henrique41@hotmail.com_1777848251773', '11987654321', '91045278891773', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:13.299303+00');
INSERT INTO public.suppliers VALUES (581, 'Barros S.A._1777848251773', 'Marli Martins', NULL, 'rafael_nogueira@hotmail.com_1777848251773', '11987654321', '22292133291773', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:13.428675+00');
INSERT INTO public.suppliers VALUES (582, 'Silva e Associados_1777848251773', 'Júlia Moreira', NULL, 'pietro_carvalho@yahoo.com_1777848251773', '11987654321', '38429537611773', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:13.555968+00');
INSERT INTO public.suppliers VALUES (583, 'Saraiva, Martins e Martins_1777848251773', 'Morgana Moreira', NULL, 'lorenzo.oliveira@live.com_1777848251773', '11987654321', '95506602941773', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:13.67356+00');
INSERT INTO public.suppliers VALUES (584, 'Franco, Melo e Albuquerque_1777848251773', 'Emanuelly Braga', NULL, 'yago.moreira22@hotmail.com_1777848251773', '11987654321', '51366833751773', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:13.786076+00');
INSERT INTO public.suppliers VALUES (585, 'Empresa 1777848256332', 'Jewertãrero Silvad', NULL, 'teste_1777848256332@mail.com', '11987654321', '24817778482563', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:44:15.943576+00');
INSERT INTO public.suppliers VALUES (586, 'Empresa 1777849106000', 'Jewertãrero Silvad', NULL, 'teste_1777849106000@mail.com', '11987654321', '24817778491060', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:25.581223+00');
INSERT INTO public.suppliers VALUES (587, 'Melo, Martins e Braga_1777849105997', 'Caio Santos', NULL, 'isabela.albuquerque@bol.com.br_1777849105997', '11987654321', '98817268235997', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:25.581739+00');
INSERT INTO public.suppliers VALUES (588, 'Franco-Souza', 'Fabrícia Costa', NULL, 'joaquim7@yahoo.com', '11987654321', '11154979610008', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:25.594971+00');
INSERT INTO public.suppliers VALUES (589, 'Batista-Albuquerque_1777849105997', 'Maria Clara Nogueira', NULL, 'norberto.carvalho5@live.com_1777849105997', '11987654321', '02524971295997', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:25.794289+00');
INSERT INTO public.suppliers VALUES (590, 'Silva-Braga_1777849105997', 'Víctor Albuquerque', NULL, 'esther.braga@yahoo.com_1777849105997', '11987654321', '17672640715997', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:25.914425+00');
INSERT INTO public.suppliers VALUES (591, 'Braga, Costa e Albuquerque_1777849105997', 'Maria Júlia Melo', NULL, 'sophia_pereira0@hotmail.com_1777849105997', '11987654321', '06464386775997', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.030071+00');
INSERT INTO public.suppliers VALUES (592, 'Pereira-Moreira_1777849105997', 'Maria Luiza Silva Jr.', NULL, 'anthony_barros@gmail.com_1777849105997', '11987654321', '82083196045997', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.176394+00');
INSERT INTO public.suppliers VALUES (593, 'Empresa 1777849106660', 'Jewertãrero Silvad', NULL, 'teste_1777849106660@mail.com', '11987654321', '24817778491066', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.219996+00');
INSERT INTO public.suppliers VALUES (594, 'Empresa 1777849106660', 'Teste QA', NULL, 'teste_1777849106660@mail.com', '11999999999', '12817778491066', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.232326+00');
INSERT INTO public.suppliers VALUES (595, 'Nogueira-Barros_1777849105997', 'Eduarda Moraes', NULL, 'marcela.xavier@gmail.com_1777849105997', '11987654321', '94937021315997', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.279497+00');
INSERT INTO public.suppliers VALUES (596, 'Santos, Saraiva e Franco_1777849105997', 'Silas Xavier', NULL, 'marcela96@live.com_1777849105997', '11987654321', '44737249565997', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.475776+00');
INSERT INTO public.suppliers VALUES (597, 'Macedo-Macedo_1777849105997', 'Esther Braga', NULL, 'paula38@live.com_1777849105997', '11987654321', '17520994715997', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.67868+00');
INSERT INTO public.suppliers VALUES (599, 'Oliveira e Associados_1777849105997', 'Lorraine Costa', NULL, 'felix_moreira@yahoo.com_1777849105997', '11987654321', '51659871375997', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:26.98771+00');
INSERT INTO public.suppliers VALUES (600, 'Souza-Nogueira_1777849105997', 'Murilo Nogueira', NULL, 'heloisa62@live.com_1777849105997', '11987654321', '48812047675997', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.165177+00');
INSERT INTO public.suppliers VALUES (601, 'Pereira Comércio_1777849105997', 'Antonella Martins', NULL, 'daniel10@gmail.com_1777849105997', '11987654321', '28540704135997', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.265779+00');
INSERT INTO public.suppliers VALUES (602, 'Souza-Xavier_1777849105997', 'Lucas Albuquerque', NULL, 'marcela.costa56@yahoo.com_1777849105997', '11987654321', '48196600535997', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.368963+00');
INSERT INTO public.suppliers VALUES (603, 'Braga, Silva e Albuquerque_1777849105997', 'Ladislau Moreira', NULL, 'bernardo28@gmail.com_1777849105997', '11987654321', '09454018485997', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.500067+00');
INSERT INTO public.suppliers VALUES (604, 'Martins e Associados_1777849105997', 'Carlos Costa', NULL, 'lorena43@bol.com.br_1777849105997', '11987654321', '61293724765997', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.611262+00');
INSERT INTO public.suppliers VALUES (605, 'Xavier-Macedo_1777849105997', 'Arthur Braga Filho', NULL, 'gustavo_moreira77@live.com_1777849105997', '11987654321', '07022067375997', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.712435+00');
INSERT INTO public.suppliers VALUES (606, 'Souza e Associados_1777849105997', 'Pedro Reis', NULL, 'bruna_moraes@bol.com.br_1777849105997', '11987654321', '18914432855997', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.81102+00');
INSERT INTO public.suppliers VALUES (608, 'Santos EIRELI_1777849105997', 'Roberto Santos', NULL, 'hugo_oliveira13@yahoo.com_1777849105997', '11987654321', '10099878145997', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:28.023426+00');
INSERT INTO public.suppliers VALUES (1360, 'Empresa 1778031907346', 'Teste QA', NULL, 'teste_1778031907346@mail.com', '11999999999', '12817780319073', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:07.01132+00');
INSERT INTO public.suppliers VALUES (1361, 'Empresa 1778031922807', 'Jewertãrero Silvad', NULL, 'teste_1778031922807@mail.com', '11987654321', '24817780319228', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:22.449338+00');
INSERT INTO public.suppliers VALUES (1384, 'Empresa 1778031929019', 'Teste QA', NULL, 'teste_1778031929019@mail.com', '11999999999', '12817780319290', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:28.58736+00');
INSERT INTO public.suppliers VALUES (1505, 'Empresa 1778208178653', 'Jewertãrero Silvad', NULL, 'teste_1778208178653@mail.com', '11987654321', '24817782081786', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:42:59.133269+00');
INSERT INTO public.suppliers VALUES (1506, 'Moraes-Braga', 'Bernardo Reis', NULL, 'juliocesar.nogueira@bol.com.br', '11987654321', '70333424466834', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:00.202429+00');
INSERT INTO public.suppliers VALUES (1507, 'Saraiva-Souza_1778208180704', 'Alexandre Santos', NULL, 'beatriz_braga40@yahoo.com_1778208180704', '11987654321', '14696092880704', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:00.896461+00');
INSERT INTO public.suppliers VALUES (1508, 'Xavier, Moreira e Batista_1778208180704', 'Vicente Souza', NULL, 'joaomiguel_macedo66@yahoo.com_1778208180704', '11987654321', '46431517040704', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:01.205921+00');
INSERT INTO public.suppliers VALUES (1509, 'Nogueira S.A._1778208180704', 'Cauã Pereira', NULL, 'davilucca45@yahoo.com_1778208180704', '11987654321', '69680215800704', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:01.522214+00');
INSERT INTO public.suppliers VALUES (1510, 'Albuquerque, Albuquerque e Albuquerque_1778208180704', 'Bernardo Franco', NULL, 'emanuelly.silva82@gmail.com_1778208180704', '11987654321', '69974043120704', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:01.838992+00');
INSERT INTO public.suppliers VALUES (1511, 'Braga LTDA_1778208180704', 'Lorenzo Moreira', NULL, 'ofelia.silva@hotmail.com_1778208180704', '11987654321', '24011019330704', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:02.153464+00');
INSERT INTO public.suppliers VALUES (1512, 'Carvalho, Santos e Souza_1778208180704', 'Paulo Nogueira', NULL, 'eduardo_martins@bol.com.br_1778208180704', '11987654321', '87333260340704', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:02.462804+00');
INSERT INTO public.suppliers VALUES (1513, 'Martins, Saraiva e Batista_1778208180704', 'Sr. Joaquim Franco', NULL, 'juliocesar.batista@bol.com.br_1778208180704', '11987654321', '59015600130704', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:02.936537+00');
INSERT INTO public.suppliers VALUES (1514, 'Martins-Carvalho_1778208180704', 'Nataniel Batista', NULL, 'yango.reis74@hotmail.com_1778208180704', '11987654321', '52687993730704', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:03.265054+00');
INSERT INTO public.suppliers VALUES (1515, 'Carvalho e Associados_1778208180704', 'Kléber Martins', NULL, 'beatriz_batista11@bol.com.br_1778208180704', '11987654321', '26453695810704', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:03.584589+00');
INSERT INTO public.suppliers VALUES (1516, 'Carvalho-Franco_1778208180704', 'Leonardo Carvalho', NULL, 'mercia.oliveira@live.com_1778208180704', '11987654321', '51927022360704', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:03.891853+00');
INSERT INTO public.suppliers VALUES (1517, 'Pereira, Silva e Albuquerque_1778208180704', 'Júlio César Carvalho Filho', NULL, 'yango.batista38@gmail.com_1778208180704', '11987654321', '44786541330704', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:04.190087+00');
INSERT INTO public.suppliers VALUES (1518, 'Saraiva, Silva e Macedo_1778208180704', 'Paula Oliveira', NULL, 'sophia_reis28@bol.com.br_1778208180704', '11987654321', '17519886940704', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:04.505714+00');
INSERT INTO public.suppliers VALUES (1519, 'Souza, Xavier e Franco_1778208180704', 'Yango Franco', NULL, 'mariana73@live.com_1778208180704', '11987654321', '40948169110704', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:04.952412+00');
INSERT INTO public.suppliers VALUES (1520, 'Albuquerque, Braga e Pereira_1778208180704', 'João Lucas Souza', NULL, 'isabela77@yahoo.com_1778208180704', '11987654321', '36199524720704', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:05.261368+00');
INSERT INTO public.suppliers VALUES (1521, 'Albuquerque-Xavier_1778208180704', 'Eduardo Carvalho Filho', NULL, 'gael_nogueira@hotmail.com_1778208180704', '11987654321', '00992743030704', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:05.559688+00');
INSERT INTO public.suppliers VALUES (1522, 'Melo, Franco e Souza_1778208180704', 'Yango Carvalho', NULL, 'bernardo.santos28@hotmail.com_1778208180704', '11987654321', '14681737710704', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:05.866859+00');
INSERT INTO public.suppliers VALUES (1523, 'Pereira S.A._1778208180704', 'Roberta Nogueira', NULL, 'rafael.souza@hotmail.com_1778208180704', '11987654321', '59177563670704', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:06.17923+00');
INSERT INTO public.suppliers VALUES (1524, 'Braga, Batista e Braga_1778208180704', 'Luiza Carvalho', NULL, 'meire.martins51@bol.com.br_1778208180704', '11987654321', '15709167250704', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:06.479255+00');
INSERT INTO public.suppliers VALUES (1525, 'Macedo-Nogueira_1778208180704', 'Isabelly Santos', NULL, 'bruna_santos@yahoo.com_1778208180704', '11987654321', '29208835080704', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:06.783071+00');
INSERT INTO public.suppliers VALUES (1526, 'Martins, Souza e Costa_1778208180704', 'Norberto Moraes Jr.', NULL, 'carla.macedo@bol.com.br_1778208180704', '11987654321', '97701815110704', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:07.08721+00');
INSERT INTO public.suppliers VALUES (1527, 'Empresa 1778208192675', 'Jewertãrero Silvad', NULL, 'teste_1778208192675@mail.com', '11987654321', '24817782081926', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:12.885461+00');
INSERT INTO public.suppliers VALUES (1528, 'Empresa 1778208194602', 'Teste QA', NULL, 'teste_1778208194602@mail.com', '11999999999', '12817782081946', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 02:43:14.798342+00');
INSERT INTO public.suppliers VALUES (1591, 'Beier, Reichert and Lebsack', 'Daniel Howe', NULL, 'josie_beatty@gmail.com', '11987654321', '01780173510661', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-30 20:38:29.829873+00');
INSERT INTO public.suppliers VALUES (607, 'Saraiva Comércio_1777849105997', 'Gúbio Franco', NULL, 'gustavo_batista32@live.com_1777849105997', '11987654321', '67302114085997', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:27.916532+00');
INSERT INTO public.suppliers VALUES (609, 'Silva-Pereira_1777849105997', 'Murilo Barros', NULL, 'julio63@bol.com.br_1777849105997', '11987654321', '57632218235997', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 22:58:28.124203+00');
INSERT INTO public.suppliers VALUES (610, 'Nogueira, Xavier e Carvalho', 'Emanuelly Nogueira Filho', NULL, 'alicia_braga@gmail.com', '11987654321', '03350783765937', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:47.803151+00');
INSERT INTO public.suppliers VALUES (611, 'Empresa 1777850688279', 'Jewertãrero Silvad', NULL, 'teste_1777850688279@mail.com', '11987654321', '24817778506882', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:47.834569+00');
INSERT INTO public.suppliers VALUES (612, 'Batista, Silva e Melo_1777850688411', 'Isis Melo', NULL, 'roberto19@live.com_1777850688411', '11987654321', '49340141458411', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:47.915064+00');
INSERT INTO public.suppliers VALUES (613, 'Barros, Batista e Carvalho_1777850688411', 'Tertuliano Batista', NULL, 'heitor_nogueira@hotmail.com_1777850688411', '11987654321', '14940489138411', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:48.192771+00');
INSERT INTO public.suppliers VALUES (614, 'Costa, Franco e Moraes_1777850688411', 'Alice Santos', NULL, 'nubia65@live.com_1777850688411', '11987654321', '63245413618411', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:48.309693+00');
INSERT INTO public.suppliers VALUES (615, 'Franco-Melo_1777850688411', 'Sra. Esther Xavier', NULL, 'isis.franco@bol.com.br_1777850688411', '11987654321', '48529878828411', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:48.439684+00');
INSERT INTO public.suppliers VALUES (616, 'Empresa 1777850689146', 'Jewertãrero Silvad', NULL, 'teste_1777850689146@mail.com', '11987654321', '24817778506891', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:48.627315+00');
INSERT INTO public.suppliers VALUES (617, 'Braga, Reis e Barros_1777850688411', 'Bernardo Macedo', NULL, 'felipe62@yahoo.com_1777850688411', '11987654321', '54857763348411', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:48.631451+00');
INSERT INTO public.suppliers VALUES (618, 'Empresa 1777850689260', 'Teste QA', NULL, 'teste_1777850689260@mail.com', '11999999999', '12817778506892', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:48.72761+00');
INSERT INTO public.suppliers VALUES (620, 'Braga S.A._1777850688411', 'Mércia Oliveira', NULL, 'helena55@yahoo.com_1777850688411', '11987654321', '94591848828411', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:48.855354+00');
INSERT INTO public.suppliers VALUES (621, 'Oliveira EIRELI_1777850688411', 'Sra. Ana Júlia Santos', NULL, 'sara.macedo@bol.com.br_1777850688411', '11987654321', '93423928998411', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:49.050177+00');
INSERT INTO public.suppliers VALUES (622, 'Souza-Franco_1777850688411', 'Isadora Nogueira Neto', NULL, 'antonio_moreira@bol.com.br_1777850688411', '11987654321', '86813338348411', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:49.167311+00');
INSERT INTO public.suppliers VALUES (623, 'Macedo, Barros e Franco_1777850688411', 'Sr. Sirineu Batista', NULL, 'joana.batista@yahoo.com_1777850688411', '11987654321', '18550384748411', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:49.306549+00');
INSERT INTO public.suppliers VALUES (624, 'Moreira, Melo e Pereira_1777850688411', 'Enzo Gabriel Costa', NULL, 'janaina_braga@bol.com.br_1777850688411', '11987654321', '21651497948411', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:49.515662+00');
INSERT INTO public.suppliers VALUES (625, 'Melo LTDA_1777850688411', 'Breno Braga Neto', NULL, 'mariahelena88@hotmail.com_1777850688411', '11987654321', '66548033568411', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:49.680613+00');
INSERT INTO public.suppliers VALUES (626, 'Melo-Souza_1777850688411', 'Karla Albuquerque', NULL, 'anthony_souza48@yahoo.com_1777850688411', '11987654321', '85755010948411', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:49.803349+00');
INSERT INTO public.suppliers VALUES (627, 'Souza-Barros_1777850688411', 'Carla Melo', NULL, 'mariacecilia.santos31@bol.com.br_1777850688411', '11987654321', '53960931978411', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:49.915759+00');
INSERT INTO public.suppliers VALUES (628, 'Santos, Saraiva e Pereira_1777850688411', 'Roberta Albuquerque', NULL, 'felicia.moreira@hotmail.com_1777850688411', '11987654321', '85078144268411', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:50.126747+00');
INSERT INTO public.suppliers VALUES (629, 'Oliveira e Associados_1777850688411', 'Caio Moraes', NULL, 'victor70@yahoo.com_1777850688411', '11987654321', '80913230698411', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:50.256669+00');
INSERT INTO public.suppliers VALUES (630, 'Santos-Oliveira_1777850688411', 'Samuel Franco', NULL, 'mariaclara13@gmail.com_1777850688411', '11987654321', '09245870728411', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:50.353564+00');
INSERT INTO public.suppliers VALUES (631, 'Carvalho-Braga_1777850688411', 'Dr. Isaac Braga', NULL, 'felix_carvalho73@hotmail.com_1777850688411', '11987654321', '91607003288411', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:50.520046+00');
INSERT INTO public.suppliers VALUES (632, 'Carvalho S.A._1777850688411', 'Sra. Lorraine Batista', NULL, 'alessandra_reis@hotmail.com_1777850688411', '11987654321', '66387922718411', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:50.699275+00');
INSERT INTO public.suppliers VALUES (633, 'Carvalho Comércio_1777850688411', 'Lucca Braga Filho', NULL, 'murilo_barros@hotmail.com_1777850688411', '11987654321', '66910936628411', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:24:50.908055+00');
INSERT INTO public.suppliers VALUES (634, 'Franco-Oliveira', 'Gúbio Franco', NULL, 'davilucca70@live.com', '11987654321', '45383723644015', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:29.5772+00');
INSERT INTO public.suppliers VALUES (635, 'Empresa 1777850790087', 'Jewertãrero Silvad', NULL, 'teste_1777850790087@mail.com', '11987654321', '24817778507900', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:29.636344+00');
INSERT INTO public.suppliers VALUES (636, 'Silva, Moreira e Oliveira_1777850790548', 'Enzo Moreira', NULL, 'cesar4@yahoo.com_1777850790548', '11987654321', '87998581840548', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.210414+00');
INSERT INTO public.suppliers VALUES (637, 'Empresa 1777850790844', 'Jewertãrero Silvad', NULL, 'teste_1777850790844@mail.com', '11987654321', '24817778507908', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.320929+00');
INSERT INTO public.suppliers VALUES (638, 'Carvalho-Moreira_1777850790548', 'Luiza Silva', NULL, 'davi_moraes@yahoo.com_1777850790548', '11987654321', '54901283660548', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.432722+00');
INSERT INTO public.suppliers VALUES (639, 'Empresa 1777850790907', 'Teste QA', NULL, 'teste_1777850790907@mail.com', '11999999999', '12817778507909', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.461663+00');
INSERT INTO public.suppliers VALUES (640, 'Pereira LTDA_1777850790548', 'Nataniel Costa', NULL, 'miguel.costa@hotmail.com_1777850790548', '11987654321', '85627912910548', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.531253+00');
INSERT INTO public.suppliers VALUES (641, 'Moreira, Silva e Reis_1777850790548', 'Dra. Alícia Franco', NULL, 'lorenzo_carvalho@gmail.com_1777850790548', '11987654321', '21365481550548', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.713043+00');
INSERT INTO public.suppliers VALUES (642, 'Batista, Martins e Silva_1777850790548', 'Karla Albuquerque', NULL, 'lorena.macedo95@live.com_1777850790548', '11987654321', '14600384820548', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.830167+00');
INSERT INTO public.suppliers VALUES (643, 'Souza-Carvalho_1777850790548', 'Sílvia Melo', NULL, 'davi_oliveira22@yahoo.com_1777850790548', '11987654321', '96119915020548', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:30.957474+00');
INSERT INTO public.suppliers VALUES (644, 'Braga S.A._1777850790548', 'Fabrícia Melo', NULL, 'lucas_pereira48@live.com_1777850790548', '11987654321', '46548318540548', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:31.171361+00');
INSERT INTO public.suppliers VALUES (645, 'Braga, Melo e Costa_1777850790548', 'Isabelly Barros', NULL, 'vitor.moreira8@gmail.com_1777850790548', '11987654321', '24376093970548', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:31.291909+00');
INSERT INTO public.suppliers VALUES (646, 'Reis-Reis_1777850790548', 'Bruna Albuquerque', NULL, 'isaac.nogueira@yahoo.com_1777850790548', '11987654321', '89271174940548', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:31.461649+00');
INSERT INTO public.suppliers VALUES (647, 'Carvalho-Pereira_1777850790548', 'Marina Franco', NULL, 'raul_melo@bol.com.br_1777850790548', '11987654321', '34010756480548', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:31.566255+00');
INSERT INTO public.suppliers VALUES (648, 'Costa S.A._1777850790548', 'Dr. Anthony Oliveira', NULL, 'lucca_moraes72@live.com_1777850790548', '11987654321', '70571613610548', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:31.763833+00');
INSERT INTO public.suppliers VALUES (649, 'Xavier LTDA_1777850790548', 'Mariana Costa', NULL, 'igor95@gmail.com_1777850790548', '11987654321', '42021837970548', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:31.887414+00');
INSERT INTO public.suppliers VALUES (650, 'Reis-Reis_1777850790548', 'Lucas Souza', NULL, 'ofelia.costa@gmail.com_1777850790548', '11987654321', '82915805150548', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:31.988199+00');
INSERT INTO public.suppliers VALUES (651, 'Oliveira Comércio_1777850790548', 'Lavínia Reis Filho', NULL, 'fabricia.barros@bol.com.br_1777850790548', '11987654321', '67589289840548', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:32.115511+00');
INSERT INTO public.suppliers VALUES (652, 'Macedo EIRELI_1777850790548', 'Maria Batista', NULL, 'fabricio48@gmail.com_1777850790548', '11987654321', '17894367760548', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:32.228619+00');
INSERT INTO public.suppliers VALUES (653, 'Costa-Nogueira_1777850790548', 'Gustavo Batista', NULL, 'julio78@live.com_1777850790548', '11987654321', '68239992000548', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:32.348161+00');
INSERT INTO public.suppliers VALUES (654, 'Batista, Santos e Carvalho_1777850790548', 'Marcos Xavier Neto', NULL, 'rebeca42@hotmail.com_1777850790548', '11987654321', '84927511320548', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:32.454079+00');
INSERT INTO public.suppliers VALUES (656, 'Reis-Barros_1777850790548', 'Ladislau Albuquerque', NULL, 'anajulia59@gmail.com_1777850790548', '11987654321', '54142893290548', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:32.674378+00');
INSERT INTO public.suppliers VALUES (1362, 'Nogueira-Reis', 'Roberta Barros', NULL, 'eduarda.batista46@hotmail.com', '11987654321', '35339635721014', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:22.770085+00');
INSERT INTO public.suppliers VALUES (1529, 'Empresa 1778256932895', 'Jewertãrero Silvad', NULL, 'teste_1778256932895@mail.com', '11987654321', '24817782569328', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:33.275332+00');
INSERT INTO public.suppliers VALUES (1530, 'Costa Comércio', 'Isaac Moreira', NULL, 'natalia.nogueira@gmail.com', '11987654321', '62093252339788', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:33.654447+00');
INSERT INTO public.suppliers VALUES (1531, 'Martins-Souza_1778256933798', 'Isaac Carvalho', NULL, 'marcela_costa72@gmail.com_1778256933798', '11987654321', '15908775333798', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:33.967496+00');
INSERT INTO public.suppliers VALUES (1532, 'Braga e Associados_1778256933798', 'Elisa Souza', NULL, 'kleber_nogueira@yahoo.com_1778256933798', '11987654321', '18269766703798', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.076166+00');
INSERT INTO public.suppliers VALUES (1533, 'Moreira, Batista e Batista_1778256933798', 'Manuela Albuquerque', NULL, 'roberto_barros81@hotmail.com_1778256933798', '11987654321', '45716043653798', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.238317+00');
INSERT INTO public.suppliers VALUES (1534, 'Moraes, Moraes e Santos_1778256933798', 'Salvador Macedo', NULL, 'joaquim_albuquerque@yahoo.com_1778256933798', '11987654321', '25844504623798', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.352875+00');
INSERT INTO public.suppliers VALUES (1535, 'Reis, Batista e Albuquerque_1778256933798', 'César Oliveira', NULL, 'salvador.barros@hotmail.com_1778256933798', '11987654321', '03360182863798', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.462174+00');
INSERT INTO public.suppliers VALUES (1536, 'Reis Comércio_1778256933798', 'Deneval Reis', NULL, 'alessandra.carvalho@bol.com.br_1778256933798', '11987654321', '92868339343798', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.572604+00');
INSERT INTO public.suppliers VALUES (1537, 'Franco-Santos_1778256933798', 'Dra. Ana Luiza Melo', NULL, 'janaina.carvalho@yahoo.com_1778256933798', '11987654321', '32169356283798', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.685535+00');
INSERT INTO public.suppliers VALUES (1538, 'Macedo-Martins_1778256933798', 'Salvador Moraes', NULL, 'analaura_barros6@bol.com.br_1778256933798', '11987654321', '70886231513798', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.792202+00');
INSERT INTO public.suppliers VALUES (1539, 'Braga-Silva_1778256933798', 'Daniel Martins', NULL, 'ricardo82@yahoo.com_1778256933798', '11987654321', '17395244463798', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:34.90958+00');
INSERT INTO public.suppliers VALUES (1540, 'Saraiva, Macedo e Costa_1778256933798', 'Eloá Moraes', NULL, 'warley.martins61@bol.com.br_1778256933798', '11987654321', '32383851593798', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.014314+00');
INSERT INTO public.suppliers VALUES (1541, 'Pereira, Pereira e Santos_1778256933798', 'Breno Moreira', NULL, 'mariaeduarda95@live.com_1778256933798', '11987654321', '80106477463798', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.124298+00');
INSERT INTO public.suppliers VALUES (1542, 'Macedo S.A._1778256933798', 'Karla Oliveira', NULL, 'miguel_reis42@live.com_1778256933798', '11987654321', '83280441623798', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.258847+00');
INSERT INTO public.suppliers VALUES (1543, 'Albuquerque-Silva_1778256933798', 'Maria Eduarda Barros', NULL, 'tertuliano_carvalho59@gmail.com_1778256933798', '11987654321', '67519909263798', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.395512+00');
INSERT INTO public.suppliers VALUES (1544, 'Silva, Carvalho e Batista_1778256933798', 'Miguel Braga', NULL, 'elisio_santos@yahoo.com_1778256933798', '11987654321', '44798996353798', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.511651+00');
INSERT INTO public.suppliers VALUES (1545, 'Pereira S.A._1778256933798', 'Liz Moraes Neto', NULL, 'marcela20@live.com_1778256933798', '11987654321', '90927081813798', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.617406+00');
INSERT INTO public.suppliers VALUES (1546, 'Saraiva-Franco_1778256933798', 'Lavínia Carvalho', NULL, 'vitor_saraiva96@hotmail.com_1778256933798', '11987654321', '64056365393798', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.727528+00');
INSERT INTO public.suppliers VALUES (1547, 'Santos, Souza e Albuquerque_1778256933798', 'Gustavo Saraiva', NULL, 'dalila79@yahoo.com_1778256933798', '11987654321', '79172162753798', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.839402+00');
INSERT INTO public.suppliers VALUES (1548, 'Franco-Albuquerque_1778256933798', 'Rafael Martins', NULL, 'heitor_santos@gmail.com_1778256933798', '11987654321', '13621334173798', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:35.946302+00');
INSERT INTO public.suppliers VALUES (1549, 'Moreira, Moraes e Santos_1778256933798', 'Washington Martins', NULL, 'marcia_silva4@live.com_1778256933798', '11987654321', '00614732023798', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:36.05634+00');
INSERT INTO public.suppliers VALUES (1550, 'Saraiva, Souza e Franco_1778256933798', 'Henrique Carvalho', NULL, 'vicente46@gmail.com_1778256933798', '11987654321', '55973407633798', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:36.171833+00');
INSERT INTO public.suppliers VALUES (1551, 'Empresa 1778256938172', 'Jewertãrero Silvad', NULL, 'teste_1778256938172@mail.com', '11987654321', '24817782569381', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:38.352927+00');
INSERT INTO public.suppliers VALUES (1552, 'Empresa 1778256938793', 'Teste QA', NULL, 'teste_1778256938793@mail.com', '11999999999', '12817782569387', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-08 16:15:38.942785+00');
INSERT INTO public.suppliers VALUES (1592, 'Tecnologia Inovadora S.A._1778901234567', 'Ricardo Souza', NULL, 'ricardo.souza@tecinovadora.com.br_1778901234567', '(11) 98765-4321', '12345678000199', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-06 13:26:32.98616+00');
INSERT INTO public.suppliers VALUES (657, 'Oliveira LTDA_1777850790548', 'Célia Oliveira', NULL, 'fabiano.carvalho@yahoo.com_1777850790548', '11987654321', '25216966690548', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:26:32.783044+00');
INSERT INTO public.suppliers VALUES (658, 'Empresa 1777850898955', 'Jewertãrero Silvad', NULL, 'teste_1777850898955@mail.com', '11987654321', '24817778508989', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:18.413266+00');
INSERT INTO public.suppliers VALUES (659, 'Macedo S.A._1777850899054', 'Marcela Costa', NULL, 'yago51@hotmail.com_1777850899054', '11987654321', '27255903799054', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:18.511562+00');
INSERT INTO public.suppliers VALUES (660, 'Oliveira LTDA_1777850899054', 'Melissa Batista', NULL, 'guilherme2@bol.com.br_1777850899054', '11987654321', '57069908379054', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:18.783115+00');
INSERT INTO public.suppliers VALUES (661, 'Melo-Franco_1777850899054', 'Fabrícia Carvalho Jr.', NULL, 'juliocesar98@hotmail.com_1777850899054', '11987654321', '74351633819054', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:19.007923+00');
INSERT INTO public.suppliers VALUES (662, 'Martins-Batista', 'Lavínia Oliveira', NULL, 'meire40@bol.com.br', '11987654321', '68096222724337', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:19.147014+00');
INSERT INTO public.suppliers VALUES (663, 'Xavier EIRELI_1777850899054', 'Samuel Carvalho', NULL, 'pietro94@yahoo.com_1777850899054', '11987654321', '45778077119054', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:19.218206+00');
INSERT INTO public.suppliers VALUES (664, 'Empresa 1777850899753', 'Jewertãrero Silvad', NULL, 'teste_1777850899753@mail.com', '11987654321', '24817778508997', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:19.220661+00');
INSERT INTO public.suppliers VALUES (665, 'Empresa 1777850899975', 'Teste QA', NULL, 'teste_1777850899975@mail.com', '11999999999', '12817778508999', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:19.439009+00');
INSERT INTO public.suppliers VALUES (666, 'Nogueira EIRELI_1777850899054', 'Eduardo Macedo Neto', NULL, 'anajulia.oliveira@bol.com.br_1777850899054', '11987654321', '62442325319054', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:19.445797+00');
INSERT INTO public.suppliers VALUES (667, 'Braga Comércio_1777850899054', 'Warley Nogueira', NULL, 'helena.albuquerque@yahoo.com_1777850899054', '11987654321', '16916247919054', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:19.737553+00');
INSERT INTO public.suppliers VALUES (668, 'Melo, Saraiva e Silva_1777850899054', 'Bernardo Albuquerque', NULL, 'luiza_melo69@gmail.com_1777850899054', '11987654321', '83961730169054', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.036767+00');
INSERT INTO public.suppliers VALUES (669, 'Oliveira e Associados_1777850899054', 'Carlos Batista', NULL, 'emanuelly_xavier64@gmail.com_1777850899054', '11987654321', '19697587439054', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.172282+00');
INSERT INTO public.suppliers VALUES (670, 'Melo S.A._1777850899054', 'Davi Lucca Barros', NULL, 'beatriz_batista@live.com_1777850899054', '11987654321', '27958275499054', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.288602+00');
INSERT INTO public.suppliers VALUES (671, 'Oliveira Comércio_1777850899054', 'Heloísa Batista', NULL, 'clara.saraiva@gmail.com_1777850899054', '11987654321', '41370063519054', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.403709+00');
INSERT INTO public.suppliers VALUES (672, 'Albuquerque, Moraes e Batista_1777850899054', 'Marina Melo', NULL, 'livia.silva@yahoo.com_1777850899054', '11987654321', '86448935269054', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.513014+00');
INSERT INTO public.suppliers VALUES (673, 'Moreira e Associados_1777850899054', 'Maria Cecília Moraes Jr.', NULL, 'maite.albuquerque@live.com_1777850899054', '11987654321', '20699668679054', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.623792+00');
INSERT INTO public.suppliers VALUES (674, 'Souza, Moraes e Macedo_1777850899054', 'Célia Costa', NULL, 'isadora.xavier@yahoo.com_1777850899054', '11987654321', '39748516499054', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.871163+00');
INSERT INTO public.suppliers VALUES (675, 'Martins-Barros_1777850899054', 'Eduarda Pereira', NULL, 'isis_silva@yahoo.com_1777850899054', '11987654321', '93286583779054', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:20.998049+00');
INSERT INTO public.suppliers VALUES (676, 'Batista, Braga e Xavier_1777850899054', 'Ígor Souza', NULL, 'anajulia_braga35@yahoo.com_1777850899054', '11987654321', '77033072999054', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:21.10263+00');
INSERT INTO public.suppliers VALUES (677, 'Martins-Pereira_1777850899054', 'Enzo Batista', NULL, 'julio19@yahoo.com_1777850899054', '11987654321', '09774380579054', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:21.228228+00');
INSERT INTO public.suppliers VALUES (678, 'Reis-Oliveira_1777850899054', 'Ana Clara Pereira', NULL, 'cesar85@bol.com.br_1777850899054', '11987654321', '42351473549054', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:21.342222+00');
INSERT INTO public.suppliers VALUES (679, 'Oliveira e Associados_1777850899054', 'Elisa Barros', NULL, 'antonella_moraes83@bol.com.br_1777850899054', '11987654321', '74113056579054', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:21.474185+00');
INSERT INTO public.suppliers VALUES (680, 'Braga S.A._1777850899054', 'Lavínia Franco', NULL, 'julia2@live.com_1777850899054', '11987654321', '27392753119054', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:21.590852+00');
INSERT INTO public.suppliers VALUES (681, 'Souza, Souza e Martins_1777850899054', 'Sr. Pietro Moraes', NULL, 'yuri_oliveira@bol.com.br_1777850899054', '11987654321', '78440246349054', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:28:21.705704+00');
INSERT INTO public.suppliers VALUES (682, 'Empresa 1777851158740', 'Jewertãrero Silvad', NULL, 'teste_1777851158740@mail.com', '11987654321', '24817778511587', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:38.979329+00');
INSERT INTO public.suppliers VALUES (683, 'Santos, Franco e Nogueira', 'Ladislau Carvalho', NULL, 'cecilia_reis@gmail.com', '11987654321', '43777043416767', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:39.540908+00');
INSERT INTO public.suppliers VALUES (684, 'Oliveira, Martins e Macedo_1777851159931', 'Marcela Reis', NULL, 'washington_pereira@hotmail.com_1777851159931', '11987654321', '99993150209931', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:40.084432+00');
INSERT INTO public.suppliers VALUES (685, 'Costa-Braga_1777851159931', 'Júlia Braga', NULL, 'lavinia_albuquerque1@hotmail.com_1777851159931', '11987654321', '22968239439931', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:40.315473+00');
INSERT INTO public.suppliers VALUES (686, 'Braga, Albuquerque e Moreira_1777851159931', 'Aline Macedo', NULL, 'eloa.melo93@bol.com.br_1777851159931', '11987654321', '82359031519931', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:40.547237+00');
INSERT INTO public.suppliers VALUES (687, 'Batista S.A._1777851159931', 'Maria Júlia Silva', NULL, 'danilo_batista80@live.com_1777851159931', '11987654321', '46934540809931', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:40.792413+00');
INSERT INTO public.suppliers VALUES (688, 'Braga Comércio_1777851159931', 'Lavínia Costa', NULL, 'mercia.albuquerque74@hotmail.com_1777851159931', '11987654321', '61975530169931', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:41.067023+00');
INSERT INTO public.suppliers VALUES (689, 'Santos, Albuquerque e Oliveira_1777851159931', 'Emanuelly Saraiva', NULL, 'alessandra20@hotmail.com_1777851159931', '11987654321', '13395805679931', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:41.29959+00');
INSERT INTO public.suppliers VALUES (690, 'Saraiva-Saraiva_1777851159931', 'Fabiano Santos', NULL, 'esther_albuquerque48@yahoo.com_1777851159931', '11987654321', '46913946819931', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:41.533612+00');
INSERT INTO public.suppliers VALUES (691, 'Pereira-Moraes_1777851159931', 'Maria Clara Xavier', NULL, 'ladislau_batista80@live.com_1777851159931', '11987654321', '32117215089931', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:41.759907+00');
INSERT INTO public.suppliers VALUES (692, 'Batista-Martins_1777851159931', 'Sarah Oliveira', NULL, 'yago_xavier@gmail.com_1777851159931', '11987654321', '49091029779931', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:41.983095+00');
INSERT INTO public.suppliers VALUES (693, 'Oliveira-Batista_1777851159931', 'Théo Albuquerque', NULL, 'alicia.costa70@gmail.com_1777851159931', '11987654321', '99196377409931', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:42.218289+00');
INSERT INTO public.suppliers VALUES (694, 'Braga-Albuquerque_1777851159931', 'Maria Alice Reis', NULL, 'gael.nogueira@bol.com.br_1777851159931', '11987654321', '28763600879931', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:42.454735+00');
INSERT INTO public.suppliers VALUES (695, 'Reis, Silva e Moraes_1777851159931', 'Dra. Clara Pereira', NULL, 'lucca0@live.com_1777851159931', '11987654321', '80496920199931', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:42.68959+00');
INSERT INTO public.suppliers VALUES (696, 'Saraiva, Santos e Franco_1777851159931', 'Júlio César Santos', NULL, 'fabio.carvalho7@gmail.com_1777851159931', '11987654321', '62673212379931', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:42.931935+00');
INSERT INTO public.suppliers VALUES (697, 'Franco-Santos_1777851159931', 'Roberta Costa', NULL, 'lara51@gmail.com_1777851159931', '11987654321', '25490730789931', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:43.164211+00');
INSERT INTO public.suppliers VALUES (698, 'Saraiva-Santos_1777851159931', 'Lavínia Souza', NULL, 'paulo.reis@bol.com.br_1777851159931', '11987654321', '03286497909931', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:43.394136+00');
INSERT INTO public.suppliers VALUES (699, 'Xavier e Associados_1777851159931', 'Vitória Costa', NULL, 'mariana.albuquerque@yahoo.com_1777851159931', '11987654321', '99009944129931', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:43.62139+00');
INSERT INTO public.suppliers VALUES (700, 'Xavier-Nogueira_1777851159931', 'Fábio Costa', NULL, 'nubia.barros62@live.com_1777851159931', '11987654321', '38957108319931', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:43.848359+00');
INSERT INTO public.suppliers VALUES (701, 'Saraiva, Moraes e Pereira_1777851159931', 'Théo Costa', NULL, 'nubia_carvalho10@yahoo.com_1777851159931', '11987654321', '53755969819931', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:44.077485+00');
INSERT INTO public.suppliers VALUES (702, 'Moraes S.A._1777851159931', 'Sara Reis Filho', NULL, 'valentina.silva@bol.com.br_1777851159931', '11987654321', '09078156379931', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:44.312902+00');
INSERT INTO public.suppliers VALUES (704, 'Empresa 1777851168879', 'Jewertãrero Silvad', NULL, 'teste_1777851168879@mail.com', '11987654321', '24817778511688', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:49.04646+00');
INSERT INTO public.suppliers VALUES (705, 'Empresa 1777851173346', 'Teste QA', NULL, 'teste_1777851173346@mail.com', '11999999999', '12817778511733', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:53.552155+00');
INSERT INTO public.suppliers VALUES (706, 'Empresa 1777851174903', 'Teste QA', NULL, 'teste_1777851174903@mail.com', '11999999999', '12817778511749', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:55.058992+00');
INSERT INTO public.suppliers VALUES (707, 'Empresa 1777851176421', 'Teste QA', NULL, 'teste_1777851176421@mail.com', '11999999999', '12817778511764', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:56.588093+00');
INSERT INTO public.suppliers VALUES (1363, 'Pereira, Moreira e Xavier_1778031923831', 'Emanuelly Santos', NULL, 'antonio.albuquerque52@gmail.com_1778031923831', '11987654321', '28642476223831', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:23.408477+00');
INSERT INTO public.suppliers VALUES (1364, 'Albuquerque, Oliveira e Costa_1778031923831', 'Isabel Souza', NULL, 'clara.moreira@live.com_1778031923831', '11987654321', '02734167193831', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:23.527592+00');
INSERT INTO public.suppliers VALUES (1365, 'Moreira, Albuquerque e Oliveira_1778031923831', 'Felícia Melo', NULL, 'joao.oliveira37@bol.com.br_1778031923831', '11987654321', '40726081883831', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:23.652276+00');
INSERT INTO public.suppliers VALUES (1366, 'Melo, Pereira e Pereira_1778031923831', 'Isadora Batista', NULL, 'eduarda.souza@live.com_1778031923831', '11987654321', '87297168423831', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:23.784972+00');
INSERT INTO public.suppliers VALUES (1367, 'Franco Comércio_1778031923831', 'Roberta Moraes', NULL, 'maria_reis53@yahoo.com_1778031923831', '11987654321', '15350220703831', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:23.898707+00');
INSERT INTO public.suppliers VALUES (1368, 'Batista, Albuquerque e Braga_1778031923831', 'Warley Costa', NULL, 'antonella46@yahoo.com_1778031923831', '11987654321', '24925837323831', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.018443+00');
INSERT INTO public.suppliers VALUES (1369, 'Saraiva, Moreira e Oliveira_1778031923831', 'João Costa', NULL, 'roberta82@live.com_1778031923831', '11987654321', '10909313223831', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.138461+00');
INSERT INTO public.suppliers VALUES (1370, 'Pereira-Braga_1778031923831', 'Rebeca Batista Neto', NULL, 'isaac_franco67@yahoo.com_1778031923831', '11987654321', '78756231183831', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.258269+00');
INSERT INTO public.suppliers VALUES (1371, 'Macedo, Reis e Carvalho_1778031923831', 'Pietro Costa Jr.', NULL, 'beatriz6@bol.com.br_1778031923831', '11987654321', '26149576573831', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.443333+00');
INSERT INTO public.suppliers VALUES (1372, 'Pereira, Saraiva e Santos_1778031923831', 'Samuel Reis', NULL, 'benicio_reis@live.com_1778031923831', '11987654321', '27444554723831', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.570899+00');
INSERT INTO public.suppliers VALUES (1373, 'Franco-Silva_1778031923831', 'Benjamin Xavier Filho', NULL, 'juliocesar.franco@live.com_1778031923831', '11987654321', '13977535083831', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.685739+00');
INSERT INTO public.suppliers VALUES (1374, 'Carvalho-Franco_1778031923831', 'Janaína Costa', NULL, 'manuela_nogueira@yahoo.com_1778031923831', '11987654321', '36499597273831', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.793768+00');
INSERT INTO public.suppliers VALUES (1375, 'Franco-Saraiva_1778031923831', 'Vitor Batista', NULL, 'bryan_reis@gmail.com_1778031923831', '11987654321', '97171406863831', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:24.900899+00');
INSERT INTO public.suppliers VALUES (1376, 'Franco-Santos_1778031923831', 'Sílvia Carvalho', NULL, 'sarah.oliveira@bol.com.br_1778031923831', '11987654321', '82540205823831', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:25.018878+00');
INSERT INTO public.suppliers VALUES (1377, 'Silva e Associados_1778031923831', 'Pablo Pereira', NULL, 'felicia.melo59@live.com_1778031923831', '11987654321', '30764313503831', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:25.156576+00');
INSERT INTO public.suppliers VALUES (1378, 'Xavier, Macedo e Pereira_1778031923831', 'Sílvia Franco Neto', NULL, 'analaura.barros33@hotmail.com_1778031923831', '11987654321', '65826942143831', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:25.30368+00');
INSERT INTO public.suppliers VALUES (1379, 'Albuquerque-Santos_1778031923831', 'Breno Melo', NULL, 'davi.barros@gmail.com_1778031923831', '11987654321', '73482124333831', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:25.41394+00');
INSERT INTO public.suppliers VALUES (1380, 'Souza e Associados_1778031923831', 'Margarida Oliveira Jr.', NULL, 'anthony46@live.com_1778031923831', '11987654321', '73293745833831', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:25.530302+00');
INSERT INTO public.suppliers VALUES (1381, 'Saraiva S.A._1778031923831', 'Mércia Saraiva', NULL, 'felix_barros@bol.com.br_1778031923831', '11987654321', '42997844823831', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:25.658327+00');
INSERT INTO public.suppliers VALUES (1382, 'Silva LTDA_1778031923831', 'Nataniel Souza', NULL, 'mariacecilia_macedo@yahoo.com_1778031923831', '11987654321', '69779638773831', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:25.783172+00');
INSERT INTO public.suppliers VALUES (1383, 'Empresa 1778031928422', 'Jewertãrero Silvad', NULL, 'teste_1778031928422@mail.com', '11987654321', '24817780319284', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:45:27.992671+00');
INSERT INTO public.suppliers VALUES (1554, 'Empresa 1778723947927', 'Jewertãrero Silvad', NULL, 'teste_1778723947927@mail.com', '11987654321', '24817787239479', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.111021+00');
INSERT INTO public.suppliers VALUES (1562, 'Melo, Melo e Moraes_1778723947851', 'Maitê Oliveira', NULL, 'giovanna96@bol.com.br_1778723947851', '11987654321', '11208548007851', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.996041+00');
INSERT INTO public.suppliers VALUES (703, 'Nogueira-Saraiva_1777851159931', 'Beatriz Souza', NULL, 'bruna_carvalho@gmail.com_1777851159931', '11987654321', '40349534719931', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:32:44.552011+00');
INSERT INTO public.suppliers VALUES (708, 'Empresa 1777851252853', 'Jewertãrero Silvad', NULL, 'teste_1777851252853@mail.com', '11987654321', '24817778512528', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:13.030336+00');
INSERT INTO public.suppliers VALUES (709, 'Braga S.A.', 'Sara Silva', NULL, 'samuel_batista89@yahoo.com', '11987654321', '21330579157122', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:13.592377+00');
INSERT INTO public.suppliers VALUES (710, 'Batista S.A._1777851253974', 'Manuela Pereira', NULL, 'lorena_silva58@bol.com.br_1777851253974', '11987654321', '19316506263974', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:14.121754+00');
INSERT INTO public.suppliers VALUES (711, 'Albuquerque, Batista e Martins_1777851253974', 'Heitor Franco', NULL, 'ricardo.silva@yahoo.com_1777851253974', '11987654321', '21696552463974', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:14.356599+00');
INSERT INTO public.suppliers VALUES (712, 'Melo-Moreira_1777851253974', 'Manuela Moreira Neto', NULL, 'salvador.moreira97@bol.com.br_1777851253974', '11987654321', '41515386653974', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:14.595459+00');
INSERT INTO public.suppliers VALUES (713, 'Macedo-Franco_1777851253974', 'Alícia Oliveira', NULL, 'nubia28@bol.com.br_1777851253974', '11987654321', '33612260413974', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:14.864294+00');
INSERT INTO public.suppliers VALUES (714, 'Melo e Associados_1777851253974', 'Célia Martins', NULL, 'maite.silva70@yahoo.com_1777851253974', '11987654321', '70203030963974', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:15.125162+00');
INSERT INTO public.suppliers VALUES (715, 'Saraiva-Pereira_1777851253974', 'Heloísa Reis', NULL, 'mariahelena_martins@gmail.com_1777851253974', '11987654321', '75139525843974', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:15.367871+00');
INSERT INTO public.suppliers VALUES (716, 'Silva, Albuquerque e Santos_1777851253974', 'Sophia Saraiva', NULL, 'joaquim.carvalho27@bol.com.br_1777851253974', '11987654321', '32380852453974', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:15.594758+00');
INSERT INTO public.suppliers VALUES (717, 'Saraiva EIRELI_1777851253974', 'Bernardo Carvalho', NULL, 'anthony_pereira@hotmail.com_1777851253974', '11987654321', '26605194393974', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:15.816176+00');
INSERT INTO public.suppliers VALUES (718, 'Franco, Moreira e Xavier_1777851253974', 'Gael Albuquerque', NULL, 'vitoria.melo63@bol.com.br_1777851253974', '11987654321', '63193558403974', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:16.075709+00');
INSERT INTO public.suppliers VALUES (719, 'Oliveira, Albuquerque e Oliveira_1777851253974', 'Gael Oliveira Neto', NULL, 'alicia74@hotmail.com_1777851253974', '11987654321', '53759417663974', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:16.335293+00');
INSERT INTO public.suppliers VALUES (720, 'Franco-Melo_1777851253974', 'Alessandro Moraes', NULL, 'melissa.costa28@gmail.com_1777851253974', '11987654321', '64470766493974', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:16.57494+00');
INSERT INTO public.suppliers VALUES (721, 'Souza-Carvalho_1777851253974', 'Félix Silva', NULL, 'felix_reis56@bol.com.br_1777851253974', '11987654321', '28736662943974', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:16.841915+00');
INSERT INTO public.suppliers VALUES (722, 'Moraes EIRELI_1777851253974', 'Alessandro Pereira', NULL, 'marialuiza54@gmail.com_1777851253974', '11987654321', '43216285803974', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:17.067662+00');
INSERT INTO public.suppliers VALUES (723, 'Santos S.A._1777851253974', 'Marcela Braga Filho', NULL, 'yuri_saraiva@live.com_1777851253974', '11987654321', '32839456223974', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:17.306464+00');
INSERT INTO public.suppliers VALUES (724, 'Costa-Barros_1777851253974', 'Calebe Albuquerque', NULL, 'vitoria51@yahoo.com_1777851253974', '11987654321', '25851090233974', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:17.533475+00');
INSERT INTO public.suppliers VALUES (726, 'Saraiva S.A._1777851253974', 'Sara Martins', NULL, 'tertuliano_martins@live.com_1777851253974', '11987654321', '62775536653974', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:17.985976+00');
INSERT INTO public.suppliers VALUES (727, 'Carvalho, Reis e Nogueira_1777851253974', 'Carlos Martins', NULL, 'melissa_barros44@gmail.com_1777851253974', '11987654321', '23297288253974', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:18.20844+00');
INSERT INTO public.suppliers VALUES (728, 'Macedo, Nogueira e Braga_1777851253974', 'Alessandro Oliveira', NULL, 'yango85@bol.com.br_1777851253974', '11987654321', '94408664013974', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:18.442299+00');
INSERT INTO public.suppliers VALUES (729, 'Costa-Reis_1777851253974', 'Maria Júlia Silva', NULL, 'emanuel_costa47@live.com_1777851253974', '11987654321', '12504114643974', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:18.675582+00');
INSERT INTO public.suppliers VALUES (730, 'Empresa 1777851262919', 'Jewertãrero Silvad', NULL, 'teste_1777851262919@mail.com', '11987654321', '24817778512629', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:23.128162+00');
INSERT INTO public.suppliers VALUES (731, 'Empresa 1777851267647', 'Teste QA', NULL, 'teste_1777851267647@mail.com', '11999999999', '12817778512676', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:27.839662+00');
INSERT INTO public.suppliers VALUES (732, 'Empresa 1777851269239', 'Teste QA', NULL, 'teste_1777851269239@mail.com', '11999999999', '12817778512692', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:29.394014+00');
INSERT INTO public.suppliers VALUES (733, 'Empresa 1777851270820', 'Teste QA', NULL, 'teste_1777851270820@mail.com', '11999999999', '12817778512708', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-03 23:34:30.971275+00');
INSERT INTO public.suppliers VALUES (734, 'Empresa 1777853534964', 'Jewertãrero Silvad', NULL, 'teste_1777853534964@mail.com', '11987654321', '24817778535349', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:14.325634+00');
INSERT INTO public.suppliers VALUES (735, 'Santos, Martins e Santos', 'Dr. Alexandre Martins', NULL, 'valentina7@hotmail.com', '11987654321', '99376333005905', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:14.68876+00');
INSERT INTO public.suppliers VALUES (736, 'Saraiva-Franco_1777853535688', 'Célia Batista', NULL, 'emanuel.braga53@bol.com.br_1777853535688', '11987654321', '77024546835688', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.005419+00');
INSERT INTO public.suppliers VALUES (737, 'Macedo-Barros_1777853535688', 'Carlos Moreira', NULL, 'noah.saraiva62@yahoo.com_1777853535688', '11987654321', '68446912205688', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.131538+00');
INSERT INTO public.suppliers VALUES (738, 'Santos Comércio_1777853535688', 'Lorenzo Franco', NULL, 'sara73@bol.com.br_1777853535688', '11987654321', '10461184295688', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.252159+00');
INSERT INTO public.suppliers VALUES (739, 'Oliveira, Franco e Albuquerque_1777853535688', 'Júlia Albuquerque', NULL, 'pietro46@live.com_1777853535688', '11987654321', '63879066635688', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.369614+00');
INSERT INTO public.suppliers VALUES (740, 'Xavier S.A._1777853535688', 'Gustavo Santos', NULL, 'danilo.souza37@bol.com.br_1777853535688', '11987654321', '15151347605688', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.493579+00');
INSERT INTO public.suppliers VALUES (741, 'Santos, Batista e Costa_1777853535688', 'Joaquim Xavier Neto', NULL, 'gubio_batista27@yahoo.com_1777853535688', '11987654321', '60013517875688', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.614878+00');
INSERT INTO public.suppliers VALUES (742, 'Batista, Souza e Reis_1777853535688', 'Marli Costa Filho', NULL, 'felix.oliveira@bol.com.br_1777853535688', '11987654321', '64946356385688', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.798201+00');
INSERT INTO public.suppliers VALUES (743, 'Silva e Associados_1777853535688', 'Sr. Matheus Barros', NULL, 'gubio.souza10@hotmail.com_1777853535688', '11987654321', '91588742945688', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:15.917209+00');
INSERT INTO public.suppliers VALUES (744, 'Xavier, Carvalho e Pereira_1777853535688', 'Lucca Braga', NULL, 'mariaeduarda_pereira@yahoo.com_1777853535688', '11987654321', '54557977735688', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.031103+00');
INSERT INTO public.suppliers VALUES (745, 'Nogueira, Nogueira e Oliveira_1777853535688', 'Sr. Víctor Nogueira', NULL, 'janaina52@gmail.com_1777853535688', '11987654321', '89185248125688', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.165554+00');
INSERT INTO public.suppliers VALUES (746, 'Macedo, Macedo e Martins_1777853535688', 'Norberto Silva', NULL, 'sirineu_silva64@bol.com.br_1777853535688', '11987654321', '15604198675688', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.286482+00');
INSERT INTO public.suppliers VALUES (747, 'Carvalho-Albuquerque_1777853535688', 'Júlio Moreira', NULL, 'anaclara3@gmail.com_1777853535688', '11987654321', '61734742305688', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.430181+00');
INSERT INTO public.suppliers VALUES (748, 'Oliveira, Reis e Reis_1777853535688', 'Isabel Melo Neto', NULL, 'isabel.moreira@gmail.com_1777853535688', '11987654321', '15422889315688', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.550327+00');
INSERT INTO public.suppliers VALUES (749, 'Nogueira e Associados_1777853535688', 'Rafael Batista', NULL, 'mariahelena_xavier@bol.com.br_1777853535688', '11987654321', '70441247515688', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.681811+00');
INSERT INTO public.suppliers VALUES (750, 'Costa-Nogueira_1777853535688', 'Pedro Henrique Saraiva Jr.', NULL, 'felix_carvalho17@yahoo.com_1777853535688', '11987654321', '10703930845688', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.799124+00');
INSERT INTO public.suppliers VALUES (751, 'Moreira, Moreira e Silva_1777853535688', 'Talita Silva', NULL, 'ladislau9@bol.com.br_1777853535688', '11987654321', '72756532045688', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:16.91727+00');
INSERT INTO public.suppliers VALUES (752, 'Pereira LTDA_1777853535688', 'Lívia Braga', NULL, 'heloisa.santos85@hotmail.com_1777853535688', '11987654321', '80096131415688', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:17.035681+00');
INSERT INTO public.suppliers VALUES (753, 'Saraiva, Saraiva e Oliveira_1777853535688', 'Yuri Nogueira Filho', NULL, 'talita_nogueira61@gmail.com_1777853535688', '11987654321', '89477642195688', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:17.155012+00');
INSERT INTO public.suppliers VALUES (754, 'Saraiva e Associados_1777853535688', 'Marcela Moreira', NULL, 'anthony_barros15@bol.com.br_1777853535688', '11987654321', '62868385195688', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:17.265978+00');
INSERT INTO public.suppliers VALUES (755, 'Braga, Xavier e Souza_1777853535688', 'Sra. Maria Júlia Reis', NULL, 'ricardo.santos@bol.com.br_1777853535688', '11987654321', '83118720105688', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:17.3915+00');
INSERT INTO public.suppliers VALUES (756, 'Empresa 1777853541052', 'Jewertãrero Silvad', NULL, 'teste_1777853541052@mail.com', '11987654321', '24817778535410', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:12:20.368857+00');
INSERT INTO public.suppliers VALUES (757, 'Empresa 1777853581867', 'Jewertãrero Silvad', NULL, 'teste_1777853581867@mail.com', '11987654321', '24817778535818', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.213796+00');
INSERT INTO public.suppliers VALUES (758, 'Pereira Comércio_1777853581925', 'Manuela Braga', NULL, 'salvador.franco47@bol.com.br_1777853581925', '11987654321', '16286665761925', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.236771+00');
INSERT INTO public.suppliers VALUES (759, 'Melo S.A.', 'Víctor Albuquerque', NULL, 'isabella_albuquerque84@bol.com.br', '11987654321', '62480360313278', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.295931+00');
INSERT INTO public.suppliers VALUES (760, 'Costa, Barros e Reis_1777853581925', 'Gustavo Martins', NULL, 'janaina_macedo7@bol.com.br_1777853581925', '11987654321', '14523767691925', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.464749+00');
INSERT INTO public.suppliers VALUES (761, 'Moreira-Santos_1777853581925', 'Ana Laura Oliveira', NULL, 'mariaalice.reis@hotmail.com_1777853581925', '11987654321', '63284006091925', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.720034+00');
INSERT INTO public.suppliers VALUES (762, 'Nogueira-Xavier_1777853581925', 'Dr. Marcelo Martins', NULL, 'vitoria_costa36@live.com_1777853581925', '11987654321', '64298959161925', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.839437+00');
INSERT INTO public.suppliers VALUES (763, 'Melo-Franco_1777853581925', 'Eduardo Saraiva', NULL, 'eduarda.xavier58@hotmail.com_1777853581925', '11987654321', '27193934251925', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.963512+00');
INSERT INTO public.suppliers VALUES (764, 'Empresa 1777853582582', 'Jewertãrero Silvad', NULL, 'teste_1777853582582@mail.com', '11987654321', '24817778535825', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.971703+00');
INSERT INTO public.suppliers VALUES (765, 'Empresa 1777853582600', 'Teste QA', NULL, 'teste_1777853582600@mail.com', '11999999999', '12817778535826', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:01.974544+00');
INSERT INTO public.suppliers VALUES (766, 'Nogueira, Nogueira e Melo_1777853581925', 'Emanuel Costa', NULL, 'ofelia_oliveira67@gmail.com_1777853581925', '11987654321', '56610181781925', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:02.120206+00');
INSERT INTO public.suppliers VALUES (767, 'Carvalho, Melo e Martins_1777853581925', 'Marcela Santos', NULL, 'alicia_moraes1@yahoo.com_1777853581925', '11987654321', '41236040131925', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:02.284791+00');
INSERT INTO public.suppliers VALUES (768, 'Reis EIRELI_1777853581925', 'Aline Oliveira', NULL, 'pedro_saraiva10@live.com_1777853581925', '11987654321', '60908812091925', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:02.488216+00');
INSERT INTO public.suppliers VALUES (769, 'Carvalho EIRELI_1777853581925', 'Isis Melo Neto', NULL, 'helena.nogueira@bol.com.br_1777853581925', '11987654321', '68706337081925', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:02.614838+00');
INSERT INTO public.suppliers VALUES (770, 'Barros-Oliveira_1777853581925', 'Isis Xavier Neto', NULL, 'isabela.melo@live.com_1777853581925', '11987654321', '38012754171925', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:02.771885+00');
INSERT INTO public.suppliers VALUES (771, 'Moreira-Batista_1777853581925', 'Ladislau Melo Filho', NULL, 'isis64@yahoo.com_1777853581925', '11987654321', '21797989051925', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:03.031049+00');
INSERT INTO public.suppliers VALUES (772, 'Xavier, Souza e Costa_1777853581925', 'Dr. Henrique Santos', NULL, 'emanuelly.batista8@yahoo.com_1777853581925', '11987654321', '20616040061925', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:03.25649+00');
INSERT INTO public.suppliers VALUES (773, 'Xavier LTDA_1777853581925', 'Heloísa Carvalho Neto', NULL, 'theo_martins@bol.com.br_1777853581925', '11987654321', '15183206721925', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:03.378755+00');
INSERT INTO public.suppliers VALUES (774, 'Saraiva-Souza_1777853581925', 'Rafael Batista', NULL, 'davi34@hotmail.com_1777853581925', '11987654321', '81510524921925', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:03.510731+00');
INSERT INTO public.suppliers VALUES (775, 'Xavier S.A._1777853581925', 'Calebe Saraiva', NULL, 'pedro_costa@bol.com.br_1777853581925', '11987654321', '60641554441925', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:03.635659+00');
INSERT INTO public.suppliers VALUES (776, 'Santos S.A._1777853581925', 'Clara Xavier', NULL, 'bernardo_braga21@hotmail.com_1777853581925', '11987654321', '86393570211925', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:03.789981+00');
INSERT INTO public.suppliers VALUES (777, 'Melo S.A._1777853581925', 'Dr. Pietro Batista', NULL, 'murilo_reis@hotmail.com_1777853581925', '11987654321', '18881159041925', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:03.898756+00');
INSERT INTO public.suppliers VALUES (778, 'Souza S.A._1777853581925', 'Eloá Macedo Neto', NULL, 'helio.franco@gmail.com_1777853581925', '11987654321', '62395792091925', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:04.007756+00');
INSERT INTO public.suppliers VALUES (779, 'Oliveira, Melo e Saraiva_1777853581925', 'Ricardo Moreira', NULL, 'leonardo71@live.com_1777853581925', '11987654321', '67614274591925', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:04.122758+00');
INSERT INTO public.suppliers VALUES (780, 'Braga-Carvalho_1777853581925', 'Gabriel Carvalho', NULL, 'kleber_melo@gmail.com_1777853581925', '11987654321', '00462125771925', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:13:04.225441+00');
INSERT INTO public.suppliers VALUES (781, 'Saraiva Comércio_1777853739560', 'Dra. Eduarda Carvalho', NULL, 'marcela_oliveira36@live.com_1777853739560', '11987654321', '05590676519560', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:38.879026+00');
INSERT INTO public.suppliers VALUES (783, 'Empresa 1777853739562', 'Jewertãrero Silvad', NULL, 'teste_1777853739562@mail.com', '11987654321', '24817778537395', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:38.90307+00');
INSERT INTO public.suppliers VALUES (784, 'Pereira, Barros e Batista_1777853739560', 'Margarida Saraiva', NULL, 'victor_santos@hotmail.com_1777853739560', '11987654321', '86679386779560', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.113836+00');
INSERT INTO public.suppliers VALUES (785, 'Saraiva e Associados_1777853739560', 'Sophia Albuquerque Neto', NULL, 'heitor.carvalho@live.com_1777853739560', '11987654321', '08466688699560', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.226215+00');
INSERT INTO public.suppliers VALUES (786, 'Barros LTDA_1777853739560', 'Fabrícia Melo', NULL, 'lavinia66@bol.com.br_1777853739560', '11987654321', '89066319369560', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.343325+00');
INSERT INTO public.suppliers VALUES (787, 'Pereira, Albuquerque e Nogueira_1777853739560', 'Pablo Costa', NULL, 'marina69@live.com_1777853739560', '11987654321', '14105711139560', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.450735+00');
INSERT INTO public.suppliers VALUES (788, 'Empresa 1777853740152', 'Jewertãrero Silvad', NULL, 'teste_1777853740152@mail.com', '11987654321', '24817778537401', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.527243+00');
INSERT INTO public.suppliers VALUES (789, 'Batista, Santos e Moreira_1777853739560', 'Elisa Xavier', NULL, 'gabriel_pereira@bol.com.br_1777853739560', '11987654321', '25016346689560', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.578692+00');
INSERT INTO public.suppliers VALUES (790, 'Empresa 1777853740280', 'Teste QA', NULL, 'teste_1777853740280@mail.com', '11999999999', '12817778537402', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.578033+00');
INSERT INTO public.suppliers VALUES (791, 'Moreira S.A._1777853739560', 'Dr. Joaquim Reis', NULL, 'margarida68@hotmail.com_1777853739560', '11987654321', '53323543699560', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.688467+00');
INSERT INTO public.suppliers VALUES (792, 'Carvalho, Nogueira e Franco_1777853739560', 'Bruna Moreira', NULL, 'roberta_silva@hotmail.com_1777853739560', '11987654321', '92270564499560', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:39.794868+00');
INSERT INTO public.suppliers VALUES (793, 'Silva-Macedo_1777853739560', 'Alexandre Xavier', NULL, 'norberto_martins12@live.com_1777853739560', '11987654321', '97837360249560', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:40.008485+00');
INSERT INTO public.suppliers VALUES (794, 'Pereira LTDA_1777853739560', 'Dr. Lucas Moreira', NULL, 'elisa95@hotmail.com_1777853739560', '11987654321', '83620040179560', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:40.125078+00');
INSERT INTO public.suppliers VALUES (795, 'Barros-Nogueira_1777853739560', 'Sra. Maria Eduarda Melo', NULL, 'marina.melo@gmail.com_1777853739560', '11987654321', '86375280509560', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:40.241796+00');
INSERT INTO public.suppliers VALUES (796, 'Moreira-Macedo_1777853739560', 'Alícia Carvalho', NULL, 'matheus_franco54@live.com_1777853739560', '11987654321', '79549920999560', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:40.368613+00');
INSERT INTO public.suppliers VALUES (797, 'Batista, Martins e Souza_1777853739560', 'Daniel Melo', NULL, 'lucas18@yahoo.com_1777853739560', '11987654321', '08868960039560', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:40.493656+00');
INSERT INTO public.suppliers VALUES (799, 'Melo-Oliveira_1777853739560', 'Sr. Felipe Melo', NULL, 'margarida38@bol.com.br_1777853739560', '11987654321', '96371452799560', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:40.85404+00');
INSERT INTO public.suppliers VALUES (801, 'Nogueira-Souza_1777853739560', 'Elísio Albuquerque', NULL, 'mercia70@yahoo.com_1777853739560', '11987654321', '86088739539560', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:41.072018+00');
INSERT INTO public.suppliers VALUES (803, 'Albuquerque-Silva_1777853739560', 'Dra. Cecília Carvalho', NULL, 'ricardo97@yahoo.com_1777853739560', '11987654321', '16444467529560', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:41.292577+00');
INSERT INTO public.suppliers VALUES (1385, 'Empresa 1778032099018', 'Jewertãrero Silvad', NULL, 'teste_1778032099018@mail.com', '11987654321', '24817780320990', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:19.380759+00');
INSERT INTO public.suppliers VALUES (1408, 'Empresa 1778032110029', 'Teste QA', NULL, 'teste_1778032110029@mail.com', '11999999999', '12817780321100', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:30.180131+00');
INSERT INTO public.suppliers VALUES (1553, 'Oliveira-Reis', 'Kléber Franco', NULL, 'joaolucas9@live.com', '11987654321', '65010904078939', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.091878+00');
INSERT INTO public.suppliers VALUES (1564, 'Pereira-Franco_1778723947851', 'Ana Laura Oliveira', NULL, 'joao.batista74@yahoo.com_1778723947851', '11987654321', '69163496697851', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:07.311433+00');
INSERT INTO public.suppliers VALUES (1568, 'Albuquerque, Moraes e Xavier_1778723947851', 'Fábio Oliveira', NULL, 'henrique68@gmail.com_1778723947851', '11987654321', '50200374707851', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:07.882717+00');
INSERT INTO public.suppliers VALUES (1570, 'Batista-Santos_1778723947851', 'Leonardo Carvalho', NULL, 'guilherme.santos@hotmail.com_1778723947851', '11987654321', '64891379977851', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:08.123652+00');
INSERT INTO public.suppliers VALUES (1572, 'Xavier, Martins e Costa_1778723947851', 'Nicolas Costa', NULL, 'morgana_nogueira27@hotmail.com_1778723947851', '11987654321', '84108161717851', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:08.37665+00');
INSERT INTO public.suppliers VALUES (1576, 'Santos-Carvalho_1778723947851', 'Yango Xavier', NULL, 'fabricia.martins6@gmail.com_1778723947851', '11987654321', '39020764587851', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:08.873372+00');
INSERT INTO public.suppliers VALUES (1594, 'New Solutions TLDDA da vida sei lá', 'João Silva', NULL, 'joao@techsolutionsseila.com', '11987654321', '12388878901777', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-06 18:39:59.546341+00');
INSERT INTO public.suppliers VALUES (800, 'Xavier LTDA_1777853739560', 'Hugo Melo', NULL, 'livia_xavier93@bol.com.br_1777853739560', '11987654321', '85346087649560', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:40.963344+00');
INSERT INTO public.suppliers VALUES (802, 'Carvalho-Saraiva_1777853739560', 'Rafaela Pereira', NULL, 'julia.batista71@gmail.com_1777853739560', '11987654321', '37984102779560', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:41.174175+00');
INSERT INTO public.suppliers VALUES (804, 'Santos S.A._1777853739560', 'Sara Silva', NULL, 'rebeca_batista81@bol.com.br_1777853739560', '11987654321', '87948669849560', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:15:41.399519+00');
INSERT INTO public.suppliers VALUES (805, 'Empresa 1777853823317', 'Jewertãrero Silvad', NULL, 'teste_1777853823317@mail.com', '11987654321', '24817778538233', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:02.66417+00');
INSERT INTO public.suppliers VALUES (806, 'Braga-Moreira_1777853823444', 'Gabriel Moreira', NULL, 'marcos.moraes43@hotmail.com_1777853823444', '11987654321', '22905931853444', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:02.756539+00');
INSERT INTO public.suppliers VALUES (807, 'Martins, Silva e Moreira', 'Lívia Reis', NULL, 'manuela37@hotmail.com', '11987654321', '26672205150065', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:02.882566+00');
INSERT INTO public.suppliers VALUES (808, 'Carvalho, Xavier e Silva_1777853823444', 'Luiza Moreira', NULL, 'mariaalice.franco69@hotmail.com_1777853823444', '11987654321', '41612898603444', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:03.174261+00');
INSERT INTO public.suppliers VALUES (809, 'Oliveira-Macedo_1777853823444', 'Maria Cecília Albuquerque', NULL, 'hugo.pereira66@yahoo.com_1777853823444', '11987654321', '83203378943444', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:03.590333+00');
INSERT INTO public.suppliers VALUES (810, 'Empresa 1777853824361', 'Jewertãrero Silvad', NULL, 'teste_1777853824361@mail.com', '11987654321', '24817778538243', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:03.66185+00');
INSERT INTO public.suppliers VALUES (811, 'Empresa 1777853824367', 'Teste QA', NULL, 'teste_1777853824367@mail.com', '11999999999', '12817778538243', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:03.679492+00');
INSERT INTO public.suppliers VALUES (812, 'Barros e Associados_1777853823444', 'João Franco', NULL, 'paulo.souza33@gmail.com_1777853823444', '11987654321', '90464634903444', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:03.827975+00');
INSERT INTO public.suppliers VALUES (813, 'Barros, Saraiva e Moraes_1777853823444', 'Sra. Maria Helena Silva', NULL, 'ladislau.nogueira@live.com_1777853823444', '11987654321', '63231619773444', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:03.951784+00');
INSERT INTO public.suppliers VALUES (814, 'Costa LTDA_1777853823444', 'Anthony Moreira', NULL, 'fabiano24@gmail.com_1777853823444', '11987654321', '00873594163444', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:04.089434+00');
INSERT INTO public.suppliers VALUES (816, 'Souza, Oliveira e Moraes_1777853823444', 'Daniel Saraiva', NULL, 'isabela_reis47@gmail.com_1777853823444', '11987654321', '33856704873444', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:04.80493+00');
INSERT INTO public.suppliers VALUES (817, 'Martins S.A._1777853823444', 'Sra. Maitê Moreira', NULL, 'alessandra71@live.com_1777853823444', '11987654321', '45809852493444', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:04.929443+00');
INSERT INTO public.suppliers VALUES (818, 'Xavier S.A._1777853823444', 'Larissa Souza', NULL, 'anaclara_santos83@hotmail.com_1777853823444', '11987654321', '15651625523444', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.074695+00');
INSERT INTO public.suppliers VALUES (819, 'Pereira-Braga_1777853823444', 'Giovanna Santos', NULL, 'salvador.costa@gmail.com_1777853823444', '11987654321', '86223563143444', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.18975+00');
INSERT INTO public.suppliers VALUES (820, 'Martins Comércio_1777853823444', 'Marcelo Saraiva', NULL, 'isaac.martins@bol.com.br_1777853823444', '11987654321', '77038055473444', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.297884+00');
INSERT INTO public.suppliers VALUES (821, 'Costa LTDA_1777853823444', 'Meire Santos Neto', NULL, 'arthur.costa23@bol.com.br_1777853823444', '11987654321', '34027404423444', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.412924+00');
INSERT INTO public.suppliers VALUES (822, 'Moreira, Reis e Pereira_1777853823444', 'Maria Alice Barros', NULL, 'calebe.batista36@yahoo.com_1777853823444', '11987654321', '12424240283444', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.542741+00');
INSERT INTO public.suppliers VALUES (823, 'Reis Comércio_1777853823444', 'Alícia Barros', NULL, 'pedrohenrique48@live.com_1777853823444', '11987654321', '53872206853444', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.655846+00');
INSERT INTO public.suppliers VALUES (824, 'Silva, Barros e Silva_1777853823444', 'Sr. Matheus Oliveira', NULL, 'mariahelena.silva@bol.com.br_1777853823444', '11987654321', '14571061183444', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.786959+00');
INSERT INTO public.suppliers VALUES (825, 'Franco-Costa_1777853823444', 'Roberta Franco', NULL, 'antonella_franco@hotmail.com_1777853823444', '11987654321', '25070728343444', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:05.904247+00');
INSERT INTO public.suppliers VALUES (826, 'Silva-Nogueira_1777853823444', 'Benício Reis', NULL, 'isabelly_nogueira29@hotmail.com_1777853823444', '11987654321', '02072460583444', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:06.011799+00');
INSERT INTO public.suppliers VALUES (827, 'Carvalho Comércio_1777853823444', 'Pietro Xavier', NULL, 'mariacecilia9@gmail.com_1777853823444', '11987654321', '72251900003444', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:06.139621+00');
INSERT INTO public.suppliers VALUES (828, 'Moreira-Costa_1777853823444', 'Emanuelly Franco', NULL, 'fabiano.silva77@yahoo.com_1777853823444', '11987654321', '09576487823444', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:17:06.253618+00');
INSERT INTO public.suppliers VALUES (829, 'Empresa 1777853919399', 'Teste QA', NULL, 'teste_1777853919399@mail.com', '11999999999', '12817778539193', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:18:38.744711+00');
INSERT INTO public.suppliers VALUES (830, 'Empresa 1777853941686', 'Jewertãrero Silvad', NULL, 'teste_1777853941686@mail.com', '11987654321', '24817778539416', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.026643+00');
INSERT INTO public.suppliers VALUES (831, 'Nogueira, Santos e Moreira', 'Sr. Ígor Carvalho', NULL, 'joaopedro88@live.com', '11987654321', '26839620774790', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.11197+00');
INSERT INTO public.suppliers VALUES (833, 'Reis, Reis e Pereira_1777853941833', 'Davi Braga', NULL, 'felicia.melo@bol.com.br_1777853941833', '11987654321', '73516738631833', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.442519+00');
INSERT INTO public.suppliers VALUES (834, 'Souza, Melo e Silva_1777853941833', 'Ana Laura Costa', NULL, 'margarida80@gmail.com_1777853941833', '11987654321', '05871374021833', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.561676+00');
INSERT INTO public.suppliers VALUES (835, 'Souza LTDA_1777853941833', 'Dr. Pablo Moraes', NULL, 'laura_franco@live.com_1777853941833', '11987654321', '71652336171833', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.774279+00');
INSERT INTO public.suppliers VALUES (836, 'Empresa 1777853942507', 'Teste QA', NULL, 'teste_1777853942507@mail.com', '11999999999', '12817778539425', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.822371+00');
INSERT INTO public.suppliers VALUES (837, 'Costa Comércio_1777853941833', 'Matheus Albuquerque', NULL, 'alessandra_moraes@gmail.com_1777853941833', '11987654321', '38807319991833', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.89157+00');
INSERT INTO public.suppliers VALUES (838, 'Empresa 1777853942602', 'Jewertãrero Silvad', NULL, 'teste_1777853942602@mail.com', '11987654321', '24817778539426', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:01.908061+00');
INSERT INTO public.suppliers VALUES (839, 'Saraiva S.A._1777853941833', 'Maria Alice Saraiva Neto', NULL, 'aline9@gmail.com_1777853941833', '11987654321', '17853680131833', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:02.072677+00');
INSERT INTO public.suppliers VALUES (840, 'Martins, Xavier e Nogueira_1777853941833', 'Davi Braga', NULL, 'pedrohenrique_albuquerque61@gmail.com_1777853941833', '11987654321', '22064331711833', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:02.274143+00');
INSERT INTO public.suppliers VALUES (841, 'Moraes-Souza_1777853941833', 'Talita Carvalho', NULL, 'fabiano48@hotmail.com_1777853941833', '11987654321', '43765168911833', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:02.51058+00');
INSERT INTO public.suppliers VALUES (842, 'Oliveira e Associados_1777853941833', 'Talita Braga', NULL, 'ladislau_souza99@gmail.com_1777853941833', '11987654321', '76555919401833', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:02.75724+00');
INSERT INTO public.suppliers VALUES (843, 'Santos, Souza e Moreira_1777853941833', 'Morgana Oliveira', NULL, 'lucas_moreira@yahoo.com_1777853941833', '11987654321', '99496984911833', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:02.925416+00');
INSERT INTO public.suppliers VALUES (844, 'Moreira S.A._1777853941833', 'Margarida Martins Neto', NULL, 'silas_silva74@live.com_1777853941833', '11987654321', '48513287351833', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:03.040478+00');
INSERT INTO public.suppliers VALUES (845, 'Reis-Moreira_1777853941833', 'Maria Helena Martins', NULL, 'alexandre35@yahoo.com_1777853941833', '11987654321', '54836200211833', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:03.154475+00');
INSERT INTO public.suppliers VALUES (848, 'Reis, Barros e Braga_1777853941833', 'Lorena Barros Jr.', NULL, 'lorena.moraes97@bol.com.br_1777853941833', '11987654321', '37296458731833', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:03.472404+00');
INSERT INTO public.suppliers VALUES (850, 'Martins, Barros e Santos_1777853941833', 'Cecília Batista', NULL, 'juliocesar45@bol.com.br_1777853941833', '11987654321', '66958771191833', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:03.712584+00');
INSERT INTO public.suppliers VALUES (852, 'Franco-Xavier_1777853941833', 'Paulo Saraiva', NULL, 'lucas.braga26@yahoo.com_1777853941833', '11987654321', '97516378651833', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:03.925381+00');
INSERT INTO public.suppliers VALUES (1386, 'Souza, Saraiva e Barros', 'Rafaela Moreira', NULL, 'luiza65@hotmail.com', '11987654321', '69316697135898', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:19.885278+00');
INSERT INTO public.suppliers VALUES (1555, 'Moreira, Melo e Melo_1778723947851', 'Lívia Souza', NULL, 'tertuliano.costa@bol.com.br_1778723947851', '11987654321', '09781163157851', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.114893+00');
INSERT INTO public.suppliers VALUES (1556, 'Melo-Moreira_1778723947851', 'Vicente Moreira', NULL, 'heitor.martins@gmail.com_1778723947851', '11987654321', '11409079507851', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.400106+00');
INSERT INTO public.suppliers VALUES (1559, 'Empresa 1778723948682', 'Teste QA', NULL, 'teste_1778723948682@mail.com', '11999999999', '12817787239486', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.699497+00');
INSERT INTO public.suppliers VALUES (1563, 'Santos e Associados_1778723947851', 'Giovanna Franco', NULL, 'isabel12@yahoo.com_1778723947851', '11987654321', '04663285317851', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:07.116973+00');
INSERT INTO public.suppliers VALUES (1565, 'Reis-Oliveira_1778723947851', 'Maria Luiza Moraes', NULL, 'gael87@hotmail.com_1778723947851', '11987654321', '97365122937851', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:07.445851+00');
INSERT INTO public.suppliers VALUES (1566, 'Souza S.A._1778723947851', 'Dr. Yango Martins', NULL, 'nubia.moreira29@bol.com.br_1778723947851', '11987654321', '84662016707851', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:07.633736+00');
INSERT INTO public.suppliers VALUES (1567, 'Franco-Xavier_1778723947851', 'Emanuel Barros', NULL, 'isabel.moraes94@bol.com.br_1778723947851', '11987654321', '46731017817851', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:07.76362+00');
INSERT INTO public.suppliers VALUES (1569, 'Moreira Comércio_1778723947851', 'Marli Santos', NULL, 'anaclara.costa@hotmail.com_1778723947851', '11987654321', '70758634457851', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:08.012053+00');
INSERT INTO public.suppliers VALUES (1571, 'Barros, Santos e Carvalho_1778723947851', 'Ricardo Franco', NULL, 'guilherme.moraes@yahoo.com_1778723947851', '11987654321', '14205525377851', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:08.246679+00');
INSERT INTO public.suppliers VALUES (1573, 'Macedo S.A._1778723947851', 'Fabrícia Franco', NULL, 'beatriz.albuquerque76@live.com_1778723947851', '11987654321', '30146292307851', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:08.503546+00');
INSERT INTO public.suppliers VALUES (1575, 'Oliveira Comércio_1778723947851', 'Laura Macedo', NULL, 'nicolas.oliveira40@gmail.com_1778723947851', '11987654321', '62328791797851', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:08.750129+00');
INSERT INTO public.suppliers VALUES (1595, 'Tecdh Solutions Ltda', 'Joãod Silva', NULL, 'joao@techsolutionds.com', '11987655321', '12345678901232', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-08 11:37:06.518733+00');
INSERT INTO public.suppliers VALUES (849, 'Nogueira-Martins_1777853941833', 'Hélio Franco', NULL, 'alessandra_macedo23@bol.com.br_1777853941833', '11987654321', '47245314681833', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:03.601913+00');
INSERT INTO public.suppliers VALUES (851, 'Barros-Braga_1777853941833', 'Tertuliano Pereira', NULL, 'alessandra.reis@yahoo.com_1777853941833', '11987654321', '98047431481833', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:03.816975+00');
INSERT INTO public.suppliers VALUES (853, 'Santos, Costa e Saraiva_1777853941833', 'Calebe Albuquerque', NULL, 'natalia_santos@live.com_1777853941833', '11987654321', '21036018931833', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:19:04.084186+00');
INSERT INTO public.suppliers VALUES (854, 'Empresa 1777854024636', 'Jewertãrero Silvad', NULL, 'teste_1777854024636@mail.com', '11987654321', '24817778540246', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:23.91844+00');
INSERT INTO public.suppliers VALUES (855, 'Pereira S.A._1777854024751', 'Miguel Saraiva', NULL, 'sara.xavier63@yahoo.com_1777854024751', '11987654321', '27372313144751', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.052852+00');
INSERT INTO public.suppliers VALUES (856, 'Santos-Braga', 'Isabela Silva', NULL, 'miguel16@live.com', '11987654321', '24020766088407', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.089488+00');
INSERT INTO public.suppliers VALUES (857, 'Nogueira-Nogueira_1777854024751', 'Rafael Martins', NULL, 'silas32@live.com_1777854024751', '11987654321', '20686044644751', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.191372+00');
INSERT INTO public.suppliers VALUES (858, 'Oliveira S.A._1777854024751', 'Júlia Franco', NULL, 'julia_albuquerque@bol.com.br_1777854024751', '11987654321', '40009721594751', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.404046+00');
INSERT INTO public.suppliers VALUES (859, 'Martins, Santos e Barros_1777854024751', 'Dra. Roberta Moraes', NULL, 'joaquim_moreira@yahoo.com_1777854024751', '11987654321', '71714185834751', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.508075+00');
INSERT INTO public.suppliers VALUES (860, 'Empresa 1777854025266', 'Jewertãrero Silvad', NULL, 'teste_1777854025266@mail.com', '11987654321', '24817778540252', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.533094+00');
INSERT INTO public.suppliers VALUES (861, 'Moraes-Franco_1777854024751', 'Mércia Moreira', NULL, 'pedro.reis@yahoo.com_1777854024751', '11987654321', '30836326784751', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.672452+00');
INSERT INTO public.suppliers VALUES (862, 'Empresa 1777854025479', 'Teste QA', NULL, 'teste_1777854025479@mail.com', '11999999999', '12817778540254', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.817286+00');
INSERT INTO public.suppliers VALUES (863, 'Oliveira, Franco e Batista_1777854024751', 'Anthony Moreira', NULL, 'marialuiza_martins94@live.com_1777854024751', '11987654321', '87748627874751', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:24.89994+00');
INSERT INTO public.suppliers VALUES (864, 'Melo LTDA_1777854024751', 'Larissa Braga', NULL, 'roberta_xavier62@gmail.com_1777854024751', '11987654321', '92163245844751', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:25.072611+00');
INSERT INTO public.suppliers VALUES (865, 'Silva, Moraes e Santos_1777854024751', 'Gustavo Souza', NULL, 'leonardo.carvalho69@live.com_1777854024751', '11987654321', '37177577824751', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:25.179779+00');
INSERT INTO public.suppliers VALUES (866, 'Souza e Associados_1777854024751', 'Deneval Carvalho Jr.', NULL, 'isabel_oliveira@live.com_1777854024751', '11987654321', '67875752364751', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:25.269793+00');
INSERT INTO public.suppliers VALUES (867, 'Barros S.A._1777854024751', 'Víctor Santos Filho', NULL, 'analaura_xavier@live.com_1777854024751', '11987654321', '37819782124751', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:25.536245+00');
INSERT INTO public.suppliers VALUES (868, 'Oliveira Comércio_1777854024751', 'Eloá Costa', NULL, 'suelen.franco@yahoo.com_1777854024751', '11987654321', '49292932034751', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:25.754909+00');
INSERT INTO public.suppliers VALUES (869, 'Braga S.A._1777854024751', 'Laura Saraiva', NULL, 'bryan41@yahoo.com_1777854024751', '11987654321', '61171780154751', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:25.884198+00');
INSERT INTO public.suppliers VALUES (870, 'Macedo-Costa_1777854024751', 'Rafael Nogueira', NULL, 'maite_moreira14@bol.com.br_1777854024751', '11987654321', '33120169384751', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.029751+00');
INSERT INTO public.suppliers VALUES (871, 'Souza, Costa e Melo_1777854024751', 'Mércia Carvalho', NULL, 'livia.oliveira30@hotmail.com_1777854024751', '11987654321', '78065562864751', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.146524+00');
INSERT INTO public.suppliers VALUES (872, 'Souza-Nogueira_1777854024751', 'Márcia Moreira', NULL, 'larissa_costa86@bol.com.br_1777854024751', '11987654321', '76001147654751', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.247473+00');
INSERT INTO public.suppliers VALUES (873, 'Braga-Batista_1777854024751', 'Mércia Martins Filho', NULL, 'washington.franco@gmail.com_1777854024751', '11987654321', '99137789284751', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.34799+00');
INSERT INTO public.suppliers VALUES (874, 'Costa-Martins_1777854024751', 'Isabela Albuquerque Neto', NULL, 'gustavo_braga@hotmail.com_1777854024751', '11987654321', '06453265924751', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.452356+00');
INSERT INTO public.suppliers VALUES (875, 'Batista LTDA_1777854024751', 'Valentina Moraes', NULL, 'maria.macedo@bol.com.br_1777854024751', '11987654321', '45959295224751', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.586457+00');
INSERT INTO public.suppliers VALUES (876, 'Macedo-Martins_1777854024751', 'Sarah Nogueira', NULL, 'valentina56@bol.com.br_1777854024751', '11987654321', '18264591244751', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.719864+00');
INSERT INTO public.suppliers VALUES (877, 'Oliveira, Nogueira e Albuquerque_1777854024751', 'Nataniel Saraiva', NULL, 'giovanna_saraiva99@live.com_1777854024751', '11987654321', '85066865654751', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:20:26.858081+00');
INSERT INTO public.suppliers VALUES (878, 'Empresa 1777854211458', 'Jewertãrero Silvad', NULL, 'teste_1777854211458@mail.com', '11987654321', '24817778542114', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:30.837608+00');
INSERT INTO public.suppliers VALUES (879, 'Barros, Pereira e Carvalho_1777854211565', 'Larissa Batista', NULL, 'isadora74@hotmail.com_1777854211565', '11987654321', '12077723101565', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:30.875047+00');
INSERT INTO public.suppliers VALUES (880, 'Albuquerque, Franco e Moraes', 'Liz Reis', NULL, 'pablo.martins70@hotmail.com', '11987654321', '96360766218869', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:30.874834+00');
INSERT INTO public.suppliers VALUES (881, 'Costa-Melo_1777854211565', 'Pietro Albuquerque', NULL, 'enzo_moreira28@bol.com.br_1777854211565', '11987654321', '47095447371565', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:30.996468+00');
INSERT INTO public.suppliers VALUES (882, 'Reis-Oliveira_1777854211565', 'Marli Souza', NULL, 'ofelia99@bol.com.br_1777854211565', '11987654321', '58699399481565', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.181774+00');
INSERT INTO public.suppliers VALUES (883, 'Santos, Franco e Batista_1777854211565', 'Calebe Moraes', NULL, 'mariana.moraes@hotmail.com_1777854211565', '11987654321', '21489922691565', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.37671+00');
INSERT INTO public.suppliers VALUES (884, 'Empresa 1777854212125', 'Jewertãrero Silvad', NULL, 'teste_1777854212125@mail.com', '11987654321', '24817778542121', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.45339+00');
INSERT INTO public.suppliers VALUES (885, 'Carvalho-Santos_1777854211565', 'Yuri Oliveira', NULL, 'alicia.silva@yahoo.com_1777854211565', '11987654321', '62299970611565', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.491316+00');
INSERT INTO public.suppliers VALUES (886, 'Empresa 1777854212254', 'Teste QA', NULL, 'teste_1777854212254@mail.com', '11999999999', '12817778542122', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.510364+00');
INSERT INTO public.suppliers VALUES (887, 'Costa-Oliveira_1777854211565', 'Márcia Martins', NULL, 'leonardo_macedo28@live.com_1777854211565', '11987654321', '36067803031565', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.592967+00');
INSERT INTO public.suppliers VALUES (888, 'Batista, Pereira e Xavier_1777854211565', 'Heitor Souza', NULL, 'igor.souza@yahoo.com_1777854211565', '11987654321', '65398064051565', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.712486+00');
INSERT INTO public.suppliers VALUES (889, 'Costa-Albuquerque_1777854211565', 'João Miguel Xavier', NULL, 'mariajulia.albuquerque48@gmail.com_1777854211565', '11987654321', '75490294271565', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:31.857753+00');
INSERT INTO public.suppliers VALUES (890, 'Melo-Franco_1777854211565', 'Sílvia Xavier Filho', NULL, 'warley.moreira7@live.com_1777854211565', '11987654321', '93977371881565', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:32.050521+00');
INSERT INTO public.suppliers VALUES (891, 'Macedo, Saraiva e Oliveira_1777854211565', 'Sophia Oliveira Neto', NULL, 'felicia.batista49@gmail.com_1777854211565', '11987654321', '02115182671565', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:32.168031+00');
INSERT INTO public.suppliers VALUES (893, 'Nogueira Comércio_1777854211565', 'Júlio Silva Jr.', NULL, 'giovanna.batista@hotmail.com_1777854211565', '11987654321', '81304537231565', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:32.630597+00');
INSERT INTO public.suppliers VALUES (894, 'Costa LTDA_1777854211565', 'Sr. Isaac Moraes', NULL, 'dalila37@live.com_1777854211565', '11987654321', '27564599981565', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:32.745162+00');
INSERT INTO public.suppliers VALUES (895, 'Nogueira-Macedo_1777854211565', 'Alexandre Silva', NULL, 'norberto.barros@gmail.com_1777854211565', '11987654321', '67820977201565', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:32.877774+00');
INSERT INTO public.suppliers VALUES (896, 'Martins, Xavier e Saraiva_1777854211565', 'Helena Carvalho', NULL, 'marcos_santos85@yahoo.com_1777854211565', '11987654321', '77489604931565', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:33.078618+00');
INSERT INTO public.suppliers VALUES (897, 'Barros, Saraiva e Reis_1777854211565', 'Ana Laura Pereira Neto', NULL, 'davi41@gmail.com_1777854211565', '11987654321', '37743151741565', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:33.205687+00');
INSERT INTO public.suppliers VALUES (899, 'Nogueira, Barros e Pereira_1777854211565', 'Manuela Reis', NULL, 'victor_batista94@bol.com.br_1777854211565', '11987654321', '68723011751565', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:33.437544+00');
INSERT INTO public.suppliers VALUES (901, 'Oliveira EIRELI_1777854211565', 'Fábio Reis', NULL, 'suelen50@hotmail.com_1777854211565', '11987654321', '75267998601565', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:33.678263+00');
INSERT INTO public.suppliers VALUES (1387, 'Santos-Reis_1778032100269', 'Maria Eduarda Xavier Neto', NULL, 'maria77@gmail.com_1778032100269', '11987654321', '26642836490269', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:20.441921+00');
INSERT INTO public.suppliers VALUES (1388, 'Costa S.A._1778032100269', 'Rebeca Silva Neto', NULL, 'dalila_carvalho@hotmail.com_1778032100269', '11987654321', '99032555100269', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:20.652273+00');
INSERT INTO public.suppliers VALUES (1389, 'Santos, Silva e Martins_1778032100269', 'Srta. Alice Costa', NULL, 'rafael49@live.com_1778032100269', '11987654321', '85832599560269', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:20.879342+00');
INSERT INTO public.suppliers VALUES (1390, 'Xavier-Martins_1778032100269', 'Laura Melo', NULL, 'marialuiza.braga@live.com_1778032100269', '11987654321', '78772406370269', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:21.082753+00');
INSERT INTO public.suppliers VALUES (1391, 'Albuquerque, Macedo e Moraes_1778032100269', 'Ígor Macedo', NULL, 'melissa_macedo@bol.com.br_1778032100269', '11987654321', '09234184550269', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:21.287957+00');
INSERT INTO public.suppliers VALUES (1392, 'Santos, Melo e Pereira_1778032100269', 'Pedro Albuquerque Jr.', NULL, 'henrique91@gmail.com_1778032100269', '11987654321', '95589728270269', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:21.562691+00');
INSERT INTO public.suppliers VALUES (1393, 'Costa EIRELI_1778032100269', 'Benjamin Reis', NULL, 'kleber.nogueira@live.com_1778032100269', '11987654321', '18237606370269', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:21.836891+00');
INSERT INTO public.suppliers VALUES (1394, 'Santos Comércio_1778032100269', 'João Pedro Batista', NULL, 'margarida5@yahoo.com_1778032100269', '11987654321', '00998077260269', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:22.0724+00');
INSERT INTO public.suppliers VALUES (1395, 'Barros-Oliveira_1778032100269', 'Isabel Martins', NULL, 'fabiano23@yahoo.com_1778032100269', '11987654321', '74961906010269', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:22.278965+00');
INSERT INTO public.suppliers VALUES (1396, 'Costa-Souza_1778032100269', 'Emanuel Franco Jr.', NULL, 'alice_braga@live.com_1778032100269', '11987654321', '99011390940269', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:22.500734+00');
INSERT INTO public.suppliers VALUES (1397, 'Barros, Nogueira e Xavier_1778032100269', 'Alexandre Barros', NULL, 'giovanna.xavier@hotmail.com_1778032100269', '11987654321', '76948923360269', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:22.709303+00');
INSERT INTO public.suppliers VALUES (1398, 'Albuquerque-Souza_1778032100269', 'Pablo Martins', NULL, 'manuela_costa@live.com_1778032100269', '11987654321', '74774638130269', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:22.917232+00');
INSERT INTO public.suppliers VALUES (1399, 'Franco, Souza e Oliveira_1778032100269', 'Paula Souza', NULL, 'meire_moreira@gmail.com_1778032100269', '11987654321', '09907727160269', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:23.135922+00');
INSERT INTO public.suppliers VALUES (1400, 'Albuquerque-Reis_1778032100269', 'Lara Reis', NULL, 'caua_souza92@yahoo.com_1778032100269', '11987654321', '50320390590269', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:23.347888+00');
INSERT INTO public.suppliers VALUES (1401, 'Xavier e Associados_1778032100269', 'Yago Pereira', NULL, 'joaomiguel_pereira32@hotmail.com_1778032100269', '11987654321', '63130011940269', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:23.565108+00');
INSERT INTO public.suppliers VALUES (1402, 'Souza-Albuquerque_1778032100269', 'Lorraine Franco', NULL, 'joaomiguel.pereira@hotmail.com_1778032100269', '11987654321', '67369149830269', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:23.777806+00');
INSERT INTO public.suppliers VALUES (1403, 'Batista-Santos_1778032100269', 'Lívia Souza Filho', NULL, 'sarah_moraes74@hotmail.com_1778032100269', '11987654321', '32388298510269', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:24.001436+00');
INSERT INTO public.suppliers VALUES (1404, 'Souza-Oliveira_1778032100269', 'Calebe Xavier', NULL, 'eloa66@bol.com.br_1778032100269', '11987654321', '91712898690269', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:24.228734+00');
INSERT INTO public.suppliers VALUES (1405, 'Franco-Silva_1778032100269', 'Danilo Xavier', NULL, 'talita_souza@gmail.com_1778032100269', '11987654321', '55847630350269', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:24.442142+00');
INSERT INTO public.suppliers VALUES (1406, 'Franco, Macedo e Macedo_1778032100269', 'Arthur Xavier', NULL, 'margarida_barros50@yahoo.com_1778032100269', '11987654321', '26934406080269', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:24.647343+00');
INSERT INTO public.suppliers VALUES (1407, 'Empresa 1778032108524', 'Jewertãrero Silvad', NULL, 'teste_1778032108524@mail.com', '11987654321', '24817780321085', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:48:28.927136+00');
INSERT INTO public.suppliers VALUES (1557, 'Nogueira LTDA_1778723947851', 'Sr. César Carvalho', NULL, 'karla7@live.com_1778723947851', '11987654321', '52618878197851', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.521967+00');
INSERT INTO public.suppliers VALUES (1558, 'Santos, Souza e Reis_1778723947851', 'Felícia Nogueira', NULL, 'roberto.melo@hotmail.com_1778723947851', '11987654321', '30765415167851', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.688407+00');
INSERT INTO public.suppliers VALUES (1596, 'Tech Solutions Ltda', 'Antônio Marques', NULL, 'antonio@techsolutions.com', '11987651111', '12345678901233', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-10 19:49:29.589613+00');
INSERT INTO public.suppliers VALUES (898, 'Braga, Martins e Reis_1777854211565', 'Norberto Martins', NULL, 'mariana_silva@hotmail.com_1777854211565', '11987654321', '39686699891565', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:33.323287+00');
INSERT INTO public.suppliers VALUES (900, 'Xavier, Franco e Pereira_1777854211565', 'Ofélia Batista', NULL, 'guilherme.nogueira42@live.com_1777854211565', '11987654321', '75748384051565', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:23:33.557809+00');
INSERT INTO public.suppliers VALUES (902, 'Empresa 1777854263534', 'Jewertãrero Silvad', NULL, 'teste_1777854263534@mail.com', '11987654321', '24817778542635', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:22.827285+00');
INSERT INTO public.suppliers VALUES (903, 'Barros e Associados', 'Marina Oliveira', NULL, 'nubia_costa@yahoo.com', '11987654321', '93785741384739', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:22.837267+00');
INSERT INTO public.suppliers VALUES (904, 'Silva S.A._1777854263655', 'Marli Pereira', NULL, 'igor.silva41@hotmail.com_1777854263655', '11987654321', '48018387233655', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:22.991101+00');
INSERT INTO public.suppliers VALUES (905, 'Barros, Braga e Nogueira_1777854263655', 'Yago Saraiva', NULL, 'samuel.nogueira58@gmail.com_1777854263655', '11987654321', '46623867003655', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.125564+00');
INSERT INTO public.suppliers VALUES (906, 'Santos, Souza e Moreira_1777854263655', 'Ofélia Martins Filho', NULL, 'leonardo.albuquerque@yahoo.com_1777854263655', '11987654321', '11377553853655', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.256222+00');
INSERT INTO public.suppliers VALUES (907, 'Santos-Pereira_1777854263655', 'Dra. Lavínia Pereira', NULL, 'gustavo_oliveira70@yahoo.com_1777854263655', '11987654321', '21411498313655', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.38164+00');
INSERT INTO public.suppliers VALUES (908, 'Braga Comércio_1777854263655', 'João Miguel Souza', NULL, 'pedrohenrique_carvalho0@gmail.com_1777854263655', '11987654321', '90403141823655', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.502108+00');
INSERT INTO public.suppliers VALUES (909, 'Oliveira, Xavier e Silva_1777854263655', 'Ana Clara Moraes', NULL, 'murilo_carvalho64@hotmail.com_1777854263655', '11987654321', '51335343243655', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.630559+00');
INSERT INTO public.suppliers VALUES (910, 'Empresa 1777854264198', 'Jewertãrero Silvad', NULL, 'teste_1777854264198@mail.com', '11987654321', '24817778542641', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.652529+00');
INSERT INTO public.suppliers VALUES (911, 'Empresa 1777854264286', 'Teste QA', NULL, 'teste_1777854264286@mail.com', '11999999999', '12817778542642', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.67921+00');
INSERT INTO public.suppliers VALUES (912, 'Carvalho Comércio_1777854263655', 'Nicolas Reis Jr.', NULL, 'bruna.saraiva14@hotmail.com_1777854263655', '11987654321', '21863500353655', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:23.855577+00');
INSERT INTO public.suppliers VALUES (913, 'Moreira-Braga_1777854263655', 'Beatriz Batista', NULL, 'natalia.batista@hotmail.com_1777854263655', '11987654321', '83737445403655', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:24.141591+00');
INSERT INTO public.suppliers VALUES (914, 'Souza, Albuquerque e Barros_1777854263655', 'Srta. Melissa Santos', NULL, 'salvador.moreira62@yahoo.com_1777854263655', '11987654321', '46125556043655', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:24.3257+00');
INSERT INTO public.suppliers VALUES (915, 'Braga EIRELI_1777854263655', 'Marcela Moreira', NULL, 'isabella3@live.com_1777854263655', '11987654321', '29429564353655', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:24.511967+00');
INSERT INTO public.suppliers VALUES (916, 'Macedo LTDA_1777854263655', 'Pietro Barros', NULL, 'joana.souza73@hotmail.com_1777854263655', '11987654321', '69210420543655', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:24.684775+00');
INSERT INTO public.suppliers VALUES (917, 'Braga, Martins e Franco_1777854263655', 'Maria Júlia Oliveira', NULL, 'yasmin.albuquerque@live.com_1777854263655', '11987654321', '18374153853655', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:24.803845+00');
INSERT INTO public.suppliers VALUES (918, 'Silva, Xavier e Braga_1777854263655', 'Fábio Martins', NULL, 'mariacecilia96@bol.com.br_1777854263655', '11987654321', '50541886533655', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:24.926063+00');
INSERT INTO public.suppliers VALUES (919, 'Saraiva, Moraes e Braga_1777854263655', 'Danilo Nogueira', NULL, 'marina24@bol.com.br_1777854263655', '11987654321', '63434975093655', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:25.086496+00');
INSERT INTO public.suppliers VALUES (920, 'Batista-Santos_1777854263655', 'Alessandro Xavier', NULL, 'noah_barros62@bol.com.br_1777854263655', '11987654321', '27755443393655', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:25.233328+00');
INSERT INTO public.suppliers VALUES (921, 'Barros-Albuquerque_1777854263655', 'Helena Batista', NULL, 'laura.batista89@hotmail.com_1777854263655', '11987654321', '43766730853655', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:25.390037+00');
INSERT INTO public.suppliers VALUES (922, 'Silva, Reis e Moraes_1777854263655', 'Sr. Gúbio Silva', NULL, 'natalia_costa59@hotmail.com_1777854263655', '11987654321', '71759853413655', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:25.523873+00');
INSERT INTO public.suppliers VALUES (923, 'Franco, Pereira e Costa_1777854263655', 'Dr. Lorenzo Costa', NULL, 'sara.saraiva@bol.com.br_1777854263655', '11987654321', '05138865203655', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:25.666862+00');
INSERT INTO public.suppliers VALUES (924, 'Franco-Silva_1777854263655', 'Sra. Núbia Macedo', NULL, 'maria23@gmail.com_1777854263655', '11987654321', '18793830563655', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:25.794263+00');
INSERT INTO public.suppliers VALUES (925, 'Oliveira e Associados_1777854263655', 'Sr. Yuri Albuquerque', NULL, 'pedro87@hotmail.com_1777854263655', '11987654321', '80359425883655', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:24:25.913875+00');
INSERT INTO public.suppliers VALUES (926, 'Empresa 1777855576385', 'Teste QA', NULL, 'teste_1777855576385@mail.com', '11999999999', '12817778555763', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:15.768154+00');
INSERT INTO public.suppliers VALUES (927, 'Empresa 1777855620003', 'Jewertãrero Silvad', NULL, 'teste_1777855620003@mail.com', '11987654321', '24817778556200', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.237178+00');
INSERT INTO public.suppliers VALUES (928, 'Costa LTDA', 'Noah Nogueira', NULL, 'isabelly.santos43@bol.com.br', '11987654321', '74276367256176', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.241514+00');
INSERT INTO public.suppliers VALUES (929, 'Melo, Oliveira e Pereira_1777855620001', 'Beatriz Costa', NULL, 'natalia_batista@yahoo.com_1777855620001', '11987654321', '40355689440001', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.258487+00');
INSERT INTO public.suppliers VALUES (930, 'Albuquerque-Oliveira_1777855620001', 'Lorenzo Costa', NULL, 'davi.melo@live.com_1777855620001', '11987654321', '48977760460001', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.383229+00');
INSERT INTO public.suppliers VALUES (931, 'Macedo, Moraes e Carvalho_1777855620001', 'Raul Franco', NULL, 'kleber64@yahoo.com_1777855620001', '11987654321', '47686063580001', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.507627+00');
INSERT INTO public.suppliers VALUES (932, 'Oliveira Comércio_1777855620001', 'Raul Albuquerque', NULL, 'noah_reis46@bol.com.br_1777855620001', '11987654321', '14412999980001', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.639365+00');
INSERT INTO public.suppliers VALUES (933, 'Nogueira, Melo e Saraiva_1777855620001', 'Ricardo Saraiva', NULL, 'analuiza.macedo@bol.com.br_1777855620001', '11987654321', '78665346280001', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.770305+00');
INSERT INTO public.suppliers VALUES (934, 'Empresa 1777855620640', 'Jewertãrero Silvad', NULL, 'teste_1777855620640@mail.com', '11987654321', '24817778556206', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.915166+00');
INSERT INTO public.suppliers VALUES (935, 'Franco e Associados_1777855620001', 'Sara Franco', NULL, 'luiza87@live.com_1777855620001', '11987654321', '56356096570001', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.952092+00');
INSERT INTO public.suppliers VALUES (936, 'Empresa 1777855620783', 'Teste QA', NULL, 'teste_1777855620783@mail.com', '11999999999', '12817778556207', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:46:59.974664+00');
INSERT INTO public.suppliers VALUES (937, 'Oliveira-Santos_1777855620001', 'Núbia Braga', NULL, 'eloa.xavier@live.com_1777855620001', '11987654321', '36881832970001', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:00.151404+00');
INSERT INTO public.suppliers VALUES (938, 'Santos, Pereira e Barros_1777855620001', 'Fábio Costa', NULL, 'isabella4@gmail.com_1777855620001', '11987654321', '86629681450001', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:00.309927+00');
INSERT INTO public.suppliers VALUES (939, 'Pereira-Pereira_1777855620001', 'Dra. Maria Luiza Albuquerque', NULL, 'mariahelena_reis68@hotmail.com_1777855620001', '11987654321', '17911897700001', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:00.528622+00');
INSERT INTO public.suppliers VALUES (940, 'Macedo, Barros e Saraiva_1777855620001', 'Ana Luiza Reis Neto', NULL, 'mercia0@bol.com.br_1777855620001', '11987654321', '55355541890001', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:00.662659+00');
INSERT INTO public.suppliers VALUES (941, 'Barros, Souza e Macedo_1777855620001', 'Srta. Talita Silva', NULL, 'cecilia_nogueira11@yahoo.com_1777855620001', '11987654321', '54988028680001', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:00.790857+00');
INSERT INTO public.suppliers VALUES (942, 'Franco e Associados_1777855620001', 'Feliciano Carvalho', NULL, 'gustavo_batista44@yahoo.com_1777855620001', '11987654321', '81682349000001', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:00.919174+00');
INSERT INTO public.suppliers VALUES (943, 'Batista-Santos_1777855620001', 'Bernardo Silva', NULL, 'celia_albuquerque64@hotmail.com_1777855620001', '11987654321', '79588223480001', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.03046+00');
INSERT INTO public.suppliers VALUES (944, 'Braga, Souza e Albuquerque_1777855620001', 'Liz Batista', NULL, 'aline.batista92@live.com_1777855620001', '11987654321', '41697733060001', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.14822+00');
INSERT INTO public.suppliers VALUES (945, 'Barros, Melo e Saraiva_1777855620001', 'Yuri Franco', NULL, 'marcia.silva38@yahoo.com_1777855620001', '11987654321', '56267780690001', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.270807+00');
INSERT INTO public.suppliers VALUES (947, 'Reis EIRELI_1777855620001', 'Mércia Reis', NULL, 'felicia.carvalho@yahoo.com_1777855620001', '11987654321', '73353123090001', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.52899+00');
INSERT INTO public.suppliers VALUES (949, 'Braga, Saraiva e Silva_1777855620001', 'Warley Melo', NULL, 'lucca72@hotmail.com_1777855620001', '11987654321', '05073966200001', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.81319+00');
INSERT INTO public.suppliers VALUES (1409, 'Empresa 1778032676189', 'Jewertãrero Silvad', NULL, 'teste_1778032676189@mail.com', '11987654321', '24817780326761', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:56.413349+00');
INSERT INTO public.suppliers VALUES (1432, 'Empresa 1778032691573', 'Teste QA', NULL, 'teste_1778032691573@mail.com', '11999999999', '12817780326915', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:11.769404+00');
INSERT INTO public.suppliers VALUES (1560, 'Empresa 1778723948604', 'Jewertãrero Silvad', NULL, 'teste_1778723948604@mail.com', '11987654321', '24817787239486', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.726536+00');
INSERT INTO public.suppliers VALUES (1561, 'Braga, Souza e Albuquerque_1778723947851', 'Esther Martins', NULL, 'marialuiza.saraiva@yahoo.com_1778723947851', '11987654321', '58324818527851', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-14 01:59:06.809234+00');
INSERT INTO public.suppliers VALUES (1597, 'Tech Solutions Ltda', 'Pedro Silva', NULL, 'pedro@techsolutions.com', '11987654321', '12345678901235', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-10 20:03:07.85418+00');
INSERT INTO public.suppliers VALUES (946, 'Santos-Souza_1777855620001', 'César Souza', NULL, 'julio79@hotmail.com_1777855620001', '11987654321', '10200169830001', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.401016+00');
INSERT INTO public.suppliers VALUES (948, 'Albuquerque, Souza e Santos_1777855620001', 'Srta. Isabella Moreira', NULL, 'alice5@yahoo.com_1777855620001', '11987654321', '83128892720001', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.684404+00');
INSERT INTO public.suppliers VALUES (950, 'Batista LTDA_1777855620001', 'Yuri Albuquerque', NULL, 'sirineu12@hotmail.com_1777855620001', '11987654321', '46161544910001', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:01.951751+00');
INSERT INTO public.suppliers VALUES (951, 'Silva e Associados', 'Talita Saraiva', NULL, 'isabela47@hotmail.com', '11987654321', '65555897194419', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:43.464251+00');
INSERT INTO public.suppliers VALUES (952, 'Empresa 1777855664309', 'Jewertãrero Silvad', NULL, 'teste_1777855664309@mail.com', '11987654321', '24817778556643', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:43.509865+00');
INSERT INTO public.suppliers VALUES (953, 'Batista, Saraiva e Franco_1777855664319', 'Raul Oliveira', NULL, 'lara.pereira53@yahoo.com_1777855664319', '11987654321', '60570952474319', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:43.521667+00');
INSERT INTO public.suppliers VALUES (954, 'Batista-Melo_1777855664319', 'Vitor Carvalho', NULL, 'giovanna.macedo59@bol.com.br_1777855664319', '11987654321', '74924174024319', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:43.728253+00');
INSERT INTO public.suppliers VALUES (955, 'Moraes-Saraiva_1777855664319', 'Sr. Tertuliano Pereira', NULL, 'rafaela53@live.com_1777855664319', '11987654321', '68007869444319', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:43.877864+00');
INSERT INTO public.suppliers VALUES (956, 'Braga LTDA_1777855664319', 'Matheus Martins', NULL, 'roberta64@live.com_1777855664319', '11987654321', '66407753234319', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:43.991272+00');
INSERT INTO public.suppliers VALUES (957, 'Empresa 1777855664874', 'Jewertãrero Silvad', NULL, 'teste_1777855664874@mail.com', '11987654321', '24817778556648', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:44.047464+00');
INSERT INTO public.suppliers VALUES (958, 'Moraes-Saraiva_1777855664319', 'Srta. Marina Oliveira', NULL, 'beatriz66@yahoo.com_1777855664319', '11987654321', '08617212214319', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:44.227332+00');
INSERT INTO public.suppliers VALUES (959, 'Empresa 1777855665063', 'Teste QA', NULL, 'teste_1777855665063@mail.com', '11999999999', '12817778556650', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:44.326831+00');
INSERT INTO public.suppliers VALUES (960, 'Moreira, Santos e Reis_1777855664319', 'Júlio César Nogueira', NULL, 'daniel_moraes@bol.com.br_1777855664319', '11987654321', '27748594924319', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:44.465557+00');
INSERT INTO public.suppliers VALUES (961, 'Reis, Souza e Pereira_1777855664319', 'Gustavo Silva Neto', NULL, 'antonio.franco@gmail.com_1777855664319', '11987654321', '25133942594319', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:44.791561+00');
INSERT INTO public.suppliers VALUES (962, 'Barros-Saraiva_1777855664319', 'Joana Carvalho', NULL, 'gustavo.santos@live.com_1777855664319', '11987654321', '99675068784319', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:45.011639+00');
INSERT INTO public.suppliers VALUES (963, 'Pereira EIRELI_1777855664319', 'Lucas Oliveira Jr.', NULL, 'carlos27@gmail.com_1777855664319', '11987654321', '72440548924319', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:45.351589+00');
INSERT INTO public.suppliers VALUES (964, 'Nogueira, Costa e Saraiva_1777855664319', 'Maria Alice Batista', NULL, 'joaomiguel.silva80@bol.com.br_1777855664319', '11987654321', '34445514424319', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:45.47154+00');
INSERT INTO public.suppliers VALUES (965, 'Costa Comércio_1777855664319', 'Lucas Souza', NULL, 'helio29@bol.com.br_1777855664319', '11987654321', '66461480794319', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:45.600725+00');
INSERT INTO public.suppliers VALUES (966, 'Braga, Martins e Costa_1777855664319', 'Maitê Santos Filho', NULL, 'lucca_batista@yahoo.com_1777855664319', '11987654321', '97496458244319', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:45.716259+00');
INSERT INTO public.suppliers VALUES (967, 'Melo, Moreira e Souza_1777855664319', 'Morgana Braga', NULL, 'deneval_macedo@live.com_1777855664319', '11987654321', '97909635914319', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:45.842846+00');
INSERT INTO public.suppliers VALUES (968, 'Albuquerque, Carvalho e Xavier_1777855664319', 'Fabrício Reis', NULL, 'mariajulia.barros@gmail.com_1777855664319', '11987654321', '39296792194319', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:45.948282+00');
INSERT INTO public.suppliers VALUES (969, 'Santos-Reis_1777855664319', 'Suélen Barros Neto', NULL, 'fabio96@live.com_1777855664319', '11987654321', '52120536654319', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:46.07214+00');
INSERT INTO public.suppliers VALUES (970, 'Franco e Associados_1777855664319', 'Suélen Souza', NULL, 'elisa.souza@hotmail.com_1777855664319', '11987654321', '28341160034319', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:46.174001+00');
INSERT INTO public.suppliers VALUES (971, 'Batista, Costa e Santos_1777855664319', 'Tertuliano Moraes', NULL, 'nataniel_costa@live.com_1777855664319', '11987654321', '73474662304319', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:46.276878+00');
INSERT INTO public.suppliers VALUES (972, 'Batista-Saraiva_1777855664319', 'Bruna Oliveira', NULL, 'aline0@live.com_1777855664319', '11987654321', '64106938454319', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:46.385539+00');
INSERT INTO public.suppliers VALUES (973, 'Saraiva, Souza e Macedo_1777855664319', 'Noah Moreira', NULL, 'murilo11@hotmail.com_1777855664319', '11987654321', '79966738774319', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:46.490795+00');
INSERT INTO public.suppliers VALUES (974, 'Silva LTDA_1777855664319', 'Srta. Vitória Moraes', NULL, 'pietro.barros@bol.com.br_1777855664319', '11987654321', '40199258994319', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:47:46.59589+00');
INSERT INTO public.suppliers VALUES (975, 'Empresa 1777855999480', 'Jewertãrero Silvad', NULL, 'teste_1777855999480@mail.com', '11987654321', '24817778559994', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:19.646362+00');
INSERT INTO public.suppliers VALUES (976, 'Moraes, Martins e Nogueira', 'Marcos Oliveira', NULL, 'samuel.braga7@yahoo.com', '11987654321', '91519433496611', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:20.241328+00');
INSERT INTO public.suppliers VALUES (977, 'Moreira, Braga e Pereira_1777856000647', 'Felipe Batista', NULL, 'vitoria_nogueira@bol.com.br_1777856000647', '11987654321', '87751632140647', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:20.801129+00');
INSERT INTO public.suppliers VALUES (978, 'Souza-Carvalho_1777856000647', 'Cecília Pereira', NULL, 'deneval.reis31@bol.com.br_1777856000647', '11987654321', '37400010800647', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:21.03504+00');
INSERT INTO public.suppliers VALUES (979, 'Silva, Carvalho e Moreira_1777856000647', 'Isadora Nogueira', NULL, 'sophia70@gmail.com_1777856000647', '11987654321', '53059435760647', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:21.273526+00');
INSERT INTO public.suppliers VALUES (980, 'Oliveira, Moraes e Reis_1777856000647', 'Enzo Costa Filho', NULL, 'alice.batista69@gmail.com_1777856000647', '11987654321', '30865347530647', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:21.514012+00');
INSERT INTO public.suppliers VALUES (981, 'Souza-Albuquerque_1777856000647', 'Júlio Oliveira Neto', NULL, 'celia73@gmail.com_1777856000647', '11987654321', '03337767170647', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:21.75193+00');
INSERT INTO public.suppliers VALUES (982, 'Moraes, Pereira e Reis_1777856000647', 'Marcos Moraes', NULL, 'celia_pereira91@yahoo.com_1777856000647', '11987654321', '28517808890647', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:22.018933+00');
INSERT INTO public.suppliers VALUES (983, 'Macedo, Nogueira e Reis_1777856000647', 'Eduarda Franco', NULL, 'mariana36@yahoo.com_1777856000647', '11987654321', '81510827720647', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:22.263952+00');
INSERT INTO public.suppliers VALUES (984, 'Franco S.A._1777856000647', 'Núbia Albuquerque', NULL, 'celia.xavier93@hotmail.com_1777856000647', '11987654321', '04597479560647', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:22.508799+00');
INSERT INTO public.suppliers VALUES (985, 'Reis-Braga_1777856000647', 'Sr. Gúbio Silva', NULL, 'helena64@live.com_1777856000647', '11987654321', '68697762050647', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:22.755943+00');
INSERT INTO public.suppliers VALUES (986, 'Xavier S.A._1777856000647', 'Dr. Danilo Moraes', NULL, 'lavinia35@live.com_1777856000647', '11987654321', '65197125230647', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:23.04017+00');
INSERT INTO public.suppliers VALUES (987, 'Costa-Melo_1777856000647', 'Gustavo Costa', NULL, 'marli_nogueira67@yahoo.com_1777856000647', '11987654321', '65528751800647', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:23.283339+00');
INSERT INTO public.suppliers VALUES (988, 'Braga, Saraiva e Pereira_1777856000647', 'Rafaela Saraiva', NULL, 'gubio.carvalho27@bol.com.br_1777856000647', '11987654321', '61280846770647', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:23.803177+00');
INSERT INTO public.suppliers VALUES (989, 'Santos, Santos e Barros_1777856000647', 'Frederico Batista', NULL, 'laura61@bol.com.br_1777856000647', '11987654321', '64986595510647', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:24.104279+00');
INSERT INTO public.suppliers VALUES (990, 'Costa, Santos e Melo_1777856000647', 'Maria Clara Martins', NULL, 'marcelo.barros11@live.com_1777856000647', '11987654321', '67530003230647', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:24.342528+00');
INSERT INTO public.suppliers VALUES (991, 'Melo, Reis e Santos_1777856000647', 'Carlos Silva', NULL, 'morgana_oliveira@yahoo.com_1777856000647', '11987654321', '16300726680647', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:24.594221+00');
INSERT INTO public.suppliers VALUES (992, 'Costa-Melo_1777856000647', 'Miguel Moreira', NULL, 'enzogabriel.xavier11@yahoo.com_1777856000647', '11987654321', '38052510070647', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:24.869779+00');
INSERT INTO public.suppliers VALUES (993, 'Santos LTDA_1777856000647', 'Carlos Martins', NULL, 'vitoria_souza@live.com_1777856000647', '11987654321', '00836509600647', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:25.107889+00');
INSERT INTO public.suppliers VALUES (994, 'Franco LTDA_1777856000647', 'Suélen Silva', NULL, 'henrique.pereira@gmail.com_1777856000647', '11987654321', '64076052370647', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:25.337656+00');
INSERT INTO public.suppliers VALUES (996, 'Souza-Nogueira_1777856000647', 'Rebeca Moreira', NULL, 'pablo.braga@hotmail.com_1777856000647', '11987654321', '28810965340647', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:25.814329+00');
INSERT INTO public.suppliers VALUES (1410, 'Moraes-Albuquerque', 'Lorenzo Santos', NULL, 'joaquim18@live.com', '11987654321', '83238974604338', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:57.430086+00');
INSERT INTO public.suppliers VALUES (1577, 'Tecth Solutions Ltda', 'João Silva', NULL, 'joaro@techsolutions.com', '11987654321', '12395678901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-17 19:42:37.31686+00');
INSERT INTO public.suppliers VALUES (1598, 'Shanahan Inc', 'Doris Wiegand', NULL, 'flavio_jerde93@gmail.com', '11987654321', '02345678901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-23 19:10:14.621034+00');
INSERT INTO public.suppliers VALUES (1599, 'Rempel - Marquardt', 'Amy Kautzer', NULL, 'axel.roberts@gmail.com', '11987654321', '02345678901204', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-23 19:10:32.761141+00');
INSERT INTO public.suppliers VALUES (995, 'Moreira, Macedo e Albuquerque_1777856000647', 'Eloá Nogueira', NULL, 'maria_franco1@live.com_1777856000647', '11987654321', '64764731350647', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:25.573976+00');
INSERT INTO public.suppliers VALUES (997, 'Empresa 1777856010353', 'Jewertãrero Silvad', NULL, 'teste_1777856010353@mail.com', '11987654321', '24817778560103', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:30.514682+00');
INSERT INTO public.suppliers VALUES (1411, 'Carvalho-Santos_1778032677931', 'Marcos Carvalho', NULL, 'guilherme_martins56@yahoo.com_1778032677931', '11987654321', '21379383527931', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:58.11071+00');
INSERT INTO public.suppliers VALUES (1412, 'Silva-Santos_1778032677931', 'Célia Albuquerque', NULL, 'enzogabriel60@hotmail.com_1778032677931', '11987654321', '32000458017931', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:58.443194+00');
INSERT INTO public.suppliers VALUES (1413, 'Reis S.A._1778032677931', 'Sílvia Souza', NULL, 'lorenzo.xavier92@hotmail.com_1778032677931', '11987654321', '83632796067931', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:58.756235+00');
INSERT INTO public.suppliers VALUES (1414, 'Saraiva-Souza_1778032677931', 'Isabel Reis', NULL, 'elisio11@hotmail.com_1778032677931', '11987654321', '46545760687931', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:59.058767+00');
INSERT INTO public.suppliers VALUES (1415, 'Braga-Franco_1778032677931', 'Sr. Leonardo Saraiva', NULL, 'theo53@live.com_1778032677931', '11987654321', '25475727187931', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:59.371293+00');
INSERT INTO public.suppliers VALUES (1416, 'Martins EIRELI_1778032677931', 'Márcia Barros', NULL, 'isabella.melo@live.com_1778032677931', '11987654321', '00263704237931', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:59.671326+00');
INSERT INTO public.suppliers VALUES (1417, 'Nogueira, Santos e Batista_1778032677931', 'Washington Barros', NULL, 'alicia.souza70@live.com_1778032677931', '11987654321', '16078642397931', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:57:59.97842+00');
INSERT INTO public.suppliers VALUES (1418, 'Saraiva-Souza_1778032677931', 'Ígor Oliveira', NULL, 'antonio_oliveira47@hotmail.com_1778032677931', '11987654321', '73989912677931', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:00.284003+00');
INSERT INTO public.suppliers VALUES (1419, 'Braga-Martins_1778032677931', 'Srta. Maria Luiza Martins', NULL, 'alexandre47@gmail.com_1778032677931', '11987654321', '88567670627931', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:00.58684+00');
INSERT INTO public.suppliers VALUES (1420, 'Martins-Carvalho_1778032677931', 'Antonella Pereira', NULL, 'helio57@gmail.com_1778032677931', '11987654321', '66726020677931', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:00.891859+00');
INSERT INTO public.suppliers VALUES (1421, 'Silva, Santos e Nogueira_1778032677931', 'Maria Luiza Macedo', NULL, 'isabel19@bol.com.br_1778032677931', '11987654321', '87253301207931', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:01.190968+00');
INSERT INTO public.suppliers VALUES (1422, 'Pereira, Moraes e Saraiva_1778032677931', 'Carla Pereira', NULL, 'rafaela6@gmail.com_1778032677931', '11987654321', '89905220677931', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:01.503798+00');
INSERT INTO public.suppliers VALUES (1423, 'Macedo e Associados_1778032677931', 'Elisa Souza', NULL, 'washington_costa74@hotmail.com_1778032677931', '11987654321', '00170053107931', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:01.803197+00');
INSERT INTO public.suppliers VALUES (1424, 'Macedo S.A._1778032677931', 'Maria Luiza Oliveira', NULL, 'marcela_martins@live.com_1778032677931', '11987654321', '45340015997931', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:02.296534+00');
INSERT INTO public.suppliers VALUES (1425, 'Santos S.A._1778032677931', 'Isabel Xavier Filho', NULL, 'gael.moreira48@gmail.com_1778032677931', '11987654321', '67733953987931', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:02.599091+00');
INSERT INTO public.suppliers VALUES (1426, 'Nogueira S.A._1778032677931', 'Davi Santos', NULL, 'rafaela_batista@bol.com.br_1778032677931', '11987654321', '69139002577931', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:02.91215+00');
INSERT INTO public.suppliers VALUES (1427, 'Moraes Comércio_1778032677931', 'Rebeca Reis', NULL, 'vitor6@gmail.com_1778032677931', '11987654321', '50574850477931', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:03.225721+00');
INSERT INTO public.suppliers VALUES (1428, 'Reis-Pereira_1778032677931', 'Noah Carvalho', NULL, 'hugo.souza46@live.com_1778032677931', '11987654321', '10397467047931', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:03.540238+00');
INSERT INTO public.suppliers VALUES (1430, 'Reis-Moreira_1778032677931', 'Salvador Moreira', NULL, 'isabelly68@gmail.com_1778032677931', '11987654321', '75533695897931', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:04.148849+00');
INSERT INTO public.suppliers VALUES (1431, 'Empresa 1778032689638', 'Jewertãrero Silvad', NULL, 'teste_1778032689638@mail.com', '11987654321', '24817780326896', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:58:09.84423+00');
INSERT INTO public.suppliers VALUES (1578, 'Tech Soleutions Ltda', 'João Sielva', NULL, 'joeao@techsolutions.com', '11987654321', '12345677901234', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-21 00:11:00.502577+00');
INSERT INTO public.suppliers VALUES (1600, 'Nova Era Tecnologia S.A.', 'Maria Souza', NULL, 'contato@novaeratec.com', '11912345678', '98765432100019', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-24 15:47:18.331153+00');
INSERT INTO public.suppliers VALUES (998, 'Empresa 1777856011636', 'Teste QA', NULL, 'teste_1777856011636@mail.com', '11999999999', '12817778560116', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 00:53:31.789003+00');
INSERT INTO public.suppliers VALUES (999, 'Empresa 1777860238086', 'Jewertãrero Silvad', NULL, 'teste_1777860238086@mail.com', '11987654321', '24817778602380', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:03:58.441562+00');
INSERT INTO public.suppliers VALUES (1000, 'Melo LTDA', 'Luiza Saraiva', NULL, 'livia.reis@bol.com.br', '11987654321', '61430139509604', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:03:59.123382+00');
INSERT INTO public.suppliers VALUES (1001, 'Pereira EIRELI_1777860239612', 'Marcela Pereira', NULL, 'raul_nogueira@gmail.com_1777860239612', '11987654321', '21485804249612', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:03:59.781746+00');
INSERT INTO public.suppliers VALUES (1002, 'Costa-Santos_1777860239612', 'Alícia Nogueira', NULL, 'marcos.macedo76@gmail.com_1777860239612', '11987654321', '72289537289612', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:00.071593+00');
INSERT INTO public.suppliers VALUES (1003, 'Barros Comércio_1777860239612', 'Frederico Macedo', NULL, 'marialuiza.moraes60@bol.com.br_1777860239612', '11987654321', '55262090969612', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:00.368052+00');
INSERT INTO public.suppliers VALUES (1004, 'Franco, Albuquerque e Saraiva_1777860239612', 'Ladislau Braga', NULL, 'elisa.souza@hotmail.com_1777860239612', '11987654321', '84772667599612', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:00.674453+00');
INSERT INTO public.suppliers VALUES (1005, 'Melo-Franco_1777860239612', 'Marli Carvalho', NULL, 'marina10@yahoo.com_1777860239612', '11987654321', '74085806679612', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:00.978737+00');
INSERT INTO public.suppliers VALUES (1006, 'Franco-Pereira_1777860239612', 'Tertuliano Braga', NULL, 'larissa.saraiva53@hotmail.com_1777860239612', '11987654321', '63284042359612', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:01.271169+00');
INSERT INTO public.suppliers VALUES (1007, 'Silva, Silva e Braga_1777860239612', 'Elisa Xavier', NULL, 'guilherme9@hotmail.com_1777860239612', '11987654321', '05255047309612', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:01.56701+00');
INSERT INTO public.suppliers VALUES (1008, 'Costa e Associados_1777860239612', 'Emanuel Nogueira', NULL, 'rafaela_franco@gmail.com_1777860239612', '11987654321', '73404707529612', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:01.869874+00');
INSERT INTO public.suppliers VALUES (1009, 'Franco, Costa e Batista_1777860239612', 'Guilherme Saraiva', NULL, 'helena_costa@live.com_1777860239612', '11987654321', '49014343559612', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:02.165734+00');
INSERT INTO public.suppliers VALUES (1010, 'Saraiva, Santos e Silva_1777860239612', 'Víctor Costa', NULL, 'giovanna_moreira38@live.com_1777860239612', '11987654321', '90040679679612', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:02.452561+00');
INSERT INTO public.suppliers VALUES (1011, 'Nogueira Comércio_1777860239612', 'Heitor Melo', NULL, 'luiza.reis81@hotmail.com_1777860239612', '11987654321', '84629458179612', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:02.750141+00');
INSERT INTO public.suppliers VALUES (1012, 'Moreira, Nogueira e Costa_1777860239612', 'Elísio Barros Filho', NULL, 'dalila_melo@bol.com.br_1777860239612', '11987654321', '82299931189612', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:03.06026+00');
INSERT INTO public.suppliers VALUES (1013, 'Braga, Macedo e Pereira_1777860239612', 'Rafael Carvalho', NULL, 'mariahelena39@gmail.com_1777860239612', '11987654321', '87812325249612', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:03.380119+00');
INSERT INTO public.suppliers VALUES (1014, 'Souza-Pereira_1777860239612', 'Vitória Costa', NULL, 'miguel68@bol.com.br_1777860239612', '11987654321', '06066375129612', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:04.051139+00');
INSERT INTO public.suppliers VALUES (1015, 'Souza e Associados_1777860239612', 'Murilo Oliveira', NULL, 'isaac94@bol.com.br_1777860239612', '11987654321', '70898568269612', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:04.345513+00');
INSERT INTO public.suppliers VALUES (1016, 'Macedo, Melo e Melo_1777860239612', 'Samuel Silva Filho', NULL, 'mariahelena74@gmail.com_1777860239612', '11987654321', '28539744079612', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:04.655131+00');
INSERT INTO public.suppliers VALUES (1017, 'Barros, Martins e Moreira_1777860239612', 'Maitê Martins', NULL, 'paula_xavier79@yahoo.com_1777860239612', '11987654321', '47408914629612', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:04.969339+00');
INSERT INTO public.suppliers VALUES (1018, 'Martins, Barros e Moreira_1777860239612', 'Pablo Moraes', NULL, 'nicolas.costa@hotmail.com_1777860239612', '11987654321', '69152253029612', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:05.278441+00');
INSERT INTO public.suppliers VALUES (1019, 'Oliveira-Franco_1777860239612', 'Janaína Melo', NULL, 'feliciano_barros50@live.com_1777860239612', '11987654321', '09720890329612', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:05.58946+00');
INSERT INTO public.suppliers VALUES (1020, 'Braga EIRELI_1777860239612', 'Marcela Costa', NULL, 'roberto_reis21@live.com_1777860239612', '11987654321', '84519512119612', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:05.887496+00');
INSERT INTO public.suppliers VALUES (1021, 'Empresa 1777860251380', 'Jewertãrero Silvad', NULL, 'teste_1777860251380@mail.com', '11987654321', '24817778602513', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:11.581454+00');
INSERT INTO public.suppliers VALUES (1022, 'Empresa 1777860252931', 'Teste QA', NULL, 'teste_1777860252931@mail.com', '11999999999', '12817778602529', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:04:13.113334+00');
INSERT INTO public.suppliers VALUES (1023, 'Empresa 1777860521936', 'Teste QA', NULL, 'teste_1777860521936@mail.com', '11999999999', '12817778605219', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:08:40.865651+00');
INSERT INTO public.suppliers VALUES (1024, 'Empresa 1777860688405', 'Jewertãrero Silvad', NULL, 'teste_1777860688405@mail.com', '11987654321', '24817778606884', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:28.573562+00');
INSERT INTO public.suppliers VALUES (1025, 'Costa Comércio', 'João Miguel Moraes', NULL, 'nicolas.franco36@hotmail.com', '11987654321', '04303153717611', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:29.090291+00');
INSERT INTO public.suppliers VALUES (1026, 'Souza Comércio_1777860689475', 'Eduardo Franco', NULL, 'marli62@live.com_1777860689475', '11987654321', '97391765989475', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:29.621624+00');
INSERT INTO public.suppliers VALUES (1027, 'Pereira, Saraiva e Saraiva_1777860689475', 'Isaac Reis', NULL, 'vitor22@bol.com.br_1777860689475', '11987654321', '67650201379475', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:29.844542+00');
INSERT INTO public.suppliers VALUES (1028, 'Xavier Comércio_1777860689475', 'Mércia Silva Neto', NULL, 'lorena.saraiva15@yahoo.com_1777860689475', '11987654321', '78662398869475', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:30.059062+00');
INSERT INTO public.suppliers VALUES (1029, 'Xavier, Melo e Xavier_1777860689475', 'Dra. Natália Saraiva', NULL, 'celia14@bol.com.br_1777860689475', '11987654321', '80228444599475', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:30.275921+00');
INSERT INTO public.suppliers VALUES (1030, 'Melo-Barros_1777860689475', 'Lívia Martins', NULL, 'helena.barros88@bol.com.br_1777860689475', '11987654321', '39757868359475', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:30.503864+00');
INSERT INTO public.suppliers VALUES (1031, 'Moreira-Xavier_1777860689475', 'Miguel Xavier', NULL, 'felipe.silva@gmail.com_1777860689475', '11987654321', '24764665739475', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:30.758836+00');
INSERT INTO public.suppliers VALUES (1032, 'Saraiva e Associados_1777860689475', 'Antônio Reis', NULL, 'heloisa_braga75@hotmail.com_1777860689475', '11987654321', '22640338069475', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:30.989087+00');
INSERT INTO public.suppliers VALUES (1033, 'Martins, Melo e Reis_1777860689475', 'Dr. Salvador Xavier', NULL, 'ricardo77@live.com_1777860689475', '11987654321', '71287122279475', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:31.258523+00');
INSERT INTO public.suppliers VALUES (1034, 'Reis S.A._1777860689475', 'Maria Helena Nogueira', NULL, 'mariacecilia_saraiva@gmail.com_1777860689475', '11987654321', '26766372339475', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:31.545191+00');
INSERT INTO public.suppliers VALUES (1036, 'Albuquerque, Melo e Santos_1777860689475', 'Ana Laura Costa', NULL, 'analuiza3@bol.com.br_1777860689475', '11987654321', '27816628649475', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:32.343623+00');
INSERT INTO public.suppliers VALUES (1037, 'Saraiva e Associados_1777860689475', 'Maria Luiza Albuquerque', NULL, 'benjamin_barros@hotmail.com_1777860689475', '11987654321', '07010805069475', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:32.56896+00');
INSERT INTO public.suppliers VALUES (1038, 'Nogueira-Nogueira_1777860689475', 'Antônio Albuquerque', NULL, 'nicolas87@yahoo.com_1777860689475', '11987654321', '54621355699475', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:32.787741+00');
INSERT INTO public.suppliers VALUES (1039, 'Carvalho-Macedo_1777860689475', 'Giovanna Souza', NULL, 'laura_saraiva37@hotmail.com_1777860689475', '11987654321', '19808811769475', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:33.037905+00');
INSERT INTO public.suppliers VALUES (1040, 'Moreira EIRELI_1777860689475', 'Arthur Moraes Jr.', NULL, 'beatriz77@yahoo.com_1777860689475', '11987654321', '01227896159475', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:33.303933+00');
INSERT INTO public.suppliers VALUES (1041, 'Pereira, Nogueira e Santos_1777860689475', 'Lucca Franco', NULL, 'frederico.martins@live.com_1777860689475', '11987654321', '06074826999475', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:33.523597+00');
INSERT INTO public.suppliers VALUES (1042, 'Barros S.A._1777860689475', 'Ana Luiza Moraes', NULL, 'cecilia_costa84@live.com_1777860689475', '11987654321', '73891208649475', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:33.750026+00');
INSERT INTO public.suppliers VALUES (1043, 'Souza, Xavier e Souza_1777860689475', 'Núbia Melo', NULL, 'mariaalice91@live.com_1777860689475', '11987654321', '89203453849475', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:33.966397+00');
INSERT INTO public.suppliers VALUES (1044, 'Xavier, Souza e Santos_1777860689475', 'Joaquim Costa', NULL, 'larissa_franco@yahoo.com_1777860689475', '11987654321', '98196683279475', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:34.176917+00');
INSERT INTO public.suppliers VALUES (1045, 'Moraes EIRELI_1777860689475', 'Calebe Costa', NULL, 'fabio5@gmail.com_1777860689475', '11987654321', '81335422479475', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:34.40449+00');
INSERT INTO public.suppliers VALUES (1046, 'Empresa 1777860698603', 'Jewertãrero Silvad', NULL, 'teste_1777860698603@mail.com', '11987654321', '24817778606986', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:38.760307+00');
INSERT INTO public.suppliers VALUES (1047, 'Empresa 1777860699805', 'Teste QA', NULL, 'teste_1777860699805@mail.com', '11999999999', '12817778606998', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:11:39.944456+00');
INSERT INTO public.suppliers VALUES (1048, 'Xavier-Franco', 'Elísio Batista', NULL, 'calebe_silva71@hotmail.com', '11987654321', '58854018127990', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:33.331035+00');
INSERT INTO public.suppliers VALUES (1049, 'Macedo S.A._1777860754576', 'César Batista Filho', NULL, 'bruna48@bol.com.br_1777860754576', '11987654321', '65914775434576', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:33.558035+00');
INSERT INTO public.suppliers VALUES (1050, 'Empresa 1777860754424', 'Jewertãrero Silvad', NULL, 'teste_1777860754424@mail.com', '11987654321', '24817778607544', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:33.571413+00');
INSERT INTO public.suppliers VALUES (1051, 'Oliveira S.A._1777860754576', 'Helena Saraiva', NULL, 'alessandro43@bol.com.br_1777860754576', '11987654321', '33195656174576', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:33.874981+00');
INSERT INTO public.suppliers VALUES (1052, 'Silva-Silva_1777860754576', 'Gúbio Pereira Filho', NULL, 'lucas54@hotmail.com_1777860754576', '11987654321', '10680775884576', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.015869+00');
INSERT INTO public.suppliers VALUES (1053, 'Empresa 1777860755203', 'Teste QA', NULL, 'teste_1777860755203@mail.com', '11999999999', '12817778607552', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.09739+00');
INSERT INTO public.suppliers VALUES (1054, 'Martins, Nogueira e Albuquerque_1777860754576', 'Rafaela Xavier', NULL, 'gustavo.reis@gmail.com_1777860754576', '11987654321', '44147446314576', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.116247+00');
INSERT INTO public.suppliers VALUES (1055, 'Empresa 1777860755082', 'Jewertãrero Silvad', NULL, 'teste_1777860755082@mail.com', '11987654321', '24817778607550', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.217286+00');
INSERT INTO public.suppliers VALUES (1056, 'Pereira-Santos_1777860754576', 'Maria Cecília Barros', NULL, 'miguel.moraes62@bol.com.br_1777860754576', '11987654321', '81884413314576', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.297682+00');
INSERT INTO public.suppliers VALUES (1057, 'Barros Comércio_1777860754576', 'Maitê Saraiva', NULL, 'davi.pereira@live.com_1777860754576', '11987654321', '59766454824576', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.461082+00');
INSERT INTO public.suppliers VALUES (1058, 'Nogueira S.A._1777860754576', 'Larissa Oliveira', NULL, 'esther_costa@hotmail.com_1777860754576', '11987654321', '20603292584576', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.569046+00');
INSERT INTO public.suppliers VALUES (1059, 'Xavier-Costa_1777860754576', 'Lavínia Moreira', NULL, 'ricardo.batista@bol.com.br_1777860754576', '11987654321', '69075756504576', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:34.782698+00');
INSERT INTO public.suppliers VALUES (1060, 'Costa-Barros_1777860754576', 'Yasmin Macedo Jr.', NULL, 'carla36@bol.com.br_1777860754576', '11987654321', '10526548184576', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:35.083287+00');
INSERT INTO public.suppliers VALUES (1061, 'Batista LTDA_1777860754576', 'Enzo Saraiva', NULL, 'talita_souza@live.com_1777860754576', '11987654321', '52526112034576', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:35.196193+00');
INSERT INTO public.suppliers VALUES (1063, 'Braga EIRELI_1777860754576', 'Lorraine Saraiva', NULL, 'samuel.moraes@yahoo.com_1777860754576', '11987654321', '77847020394576', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:35.424905+00');
INSERT INTO public.suppliers VALUES (1064, 'Nogueira, Costa e Costa_1777860754576', 'Marcelo Saraiva', NULL, 'marialuiza7@yahoo.com_1777860754576', '11987654321', '32273964374576', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:35.549937+00');
INSERT INTO public.suppliers VALUES (1065, 'Souza-Xavier_1777860754576', 'Dr. Daniel Moreira', NULL, 'anajulia.martins@bol.com.br_1777860754576', '11987654321', '90326823204576', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:35.658444+00');
INSERT INTO public.suppliers VALUES (1066, 'Franco Comércio_1777860754576', 'Salvador Reis', NULL, 'roberta3@live.com_1777860754576', '11987654321', '16649808244576', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:35.771864+00');
INSERT INTO public.suppliers VALUES (1067, 'Braga, Carvalho e Braga_1777860754576', 'Joaquim Silva', NULL, 'daniel_batista@hotmail.com_1777860754576', '11987654321', '52513524524576', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:35.889179+00');
INSERT INTO public.suppliers VALUES (1068, 'Oliveira-Martins_1777860754576', 'Gael Pereira', NULL, 'margarida.costa32@live.com_1777860754576', '11987654321', '20040592004576', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:36.00767+00');
INSERT INTO public.suppliers VALUES (1069, 'Oliveira-Braga_1777860754576', 'Roberta Saraiva', NULL, 'pedrohenrique.moraes81@hotmail.com_1777860754576', '11987654321', '82587484434576', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:36.135608+00');
INSERT INTO public.suppliers VALUES (1070, 'Moreira-Franco_1777860754576', 'Roberto Braga', NULL, 'kleber_moraes21@live.com_1777860754576', '11987654321', '75202513204576', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:36.255737+00');
INSERT INTO public.suppliers VALUES (1071, 'Reis-Moraes_1777860754576', 'Sr. Anthony Batista', NULL, 'sophia27@gmail.com_1777860754576', '11987654321', '91463265134576', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:12:36.375749+00');
INSERT INTO public.suppliers VALUES (1072, 'Empresa 1777861793463', 'Jewertãrero Silvad', NULL, 'teste_1777861793463@mail.com', '11987654321', '24817778617934', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:53.64286+00');
INSERT INTO public.suppliers VALUES (1073, 'Moraes EIRELI', 'Sra. Janaína Saraiva', NULL, 'arthur_silva55@yahoo.com', '11987654321', '99440237522211', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:54.23207+00');
INSERT INTO public.suppliers VALUES (1074, 'Reis, Moraes e Pereira_1777861794659', 'Félix Saraiva', NULL, 'norberto.silva@live.com_1777861794659', '11987654321', '60865481534659', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:54.8097+00');
INSERT INTO public.suppliers VALUES (1075, 'Oliveira-Moreira_1777861794659', 'Isabella Melo', NULL, 'analaura_pereira@hotmail.com_1777861794659', '11987654321', '85760135484659', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:55.057485+00');
INSERT INTO public.suppliers VALUES (1076, 'Braga-Nogueira_1777861794659', 'Margarida Souza', NULL, 'helio_albuquerque@bol.com.br_1777861794659', '11987654321', '87421100734659', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:55.290432+00');
INSERT INTO public.suppliers VALUES (1077, 'Silva-Oliveira_1777861794659', 'Fábio Saraiva', NULL, 'emanuelly18@hotmail.com_1777861794659', '11987654321', '79995504544659', NULL, NULL, 'PI', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:55.535434+00');
INSERT INTO public.suppliers VALUES (1078, 'Franco-Silva_1777861794659', 'Félix Carvalho', NULL, 'juliocesar.braga@live.com_1777861794659', '11987654321', '25193116634659', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:55.771388+00');
INSERT INTO public.suppliers VALUES (1079, 'Silva, Barros e Oliveira_1777861794659', 'Carla Braga', NULL, 'joana.pereira48@gmail.com_1777861794659', '11987654321', '96622340154659', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:56.03576+00');
INSERT INTO public.suppliers VALUES (1080, 'Melo EIRELI_1777861794659', 'Ana Luiza Macedo', NULL, 'manuela.melo@live.com_1777861794659', '11987654321', '67837594734659', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:56.269905+00');
INSERT INTO public.suppliers VALUES (1081, 'Braga S.A._1777861794659', 'Isabel Silva', NULL, 'julia_santos37@gmail.com_1777861794659', '11987654321', '78663714054659', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:56.536008+00');
INSERT INTO public.suppliers VALUES (1082, 'Carvalho-Xavier_1777861794659', 'Paula Saraiva', NULL, 'ofelia.barros@live.com_1777861794659', '11987654321', '58609324594659', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:56.770038+00');
INSERT INTO public.suppliers VALUES (1083, 'Silva e Associados_1777861794659', 'Rafaela Batista Filho', NULL, 'caio.franco@hotmail.com_1777861794659', '11987654321', '37486094244659', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:57.005524+00');
INSERT INTO public.suppliers VALUES (1084, 'Pereira Comércio_1777861794659', 'Gúbio Saraiva', NULL, 'mariaalice_pereira@yahoo.com_1777861794659', '11987654321', '73199195744659', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:57.245755+00');
INSERT INTO public.suppliers VALUES (1085, 'Costa-Macedo_1777861794659', 'Marcos Nogueira', NULL, 'suelen_oliveira@bol.com.br_1777861794659', '11987654321', '01910368744659', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:57.484388+00');
INSERT INTO public.suppliers VALUES (1086, 'Silva-Moreira_1777861794659', 'Antonella Martins', NULL, 'anajulia.martins@hotmail.com_1777861794659', '11987654321', '22557749544659', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:57.737164+00');
INSERT INTO public.suppliers VALUES (1087, 'Pereira, Souza e Pereira_1777861794659', 'Sirineu Melo', NULL, 'janaina59@gmail.com_1777861794659', '11987654321', '08369319004659', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:57.97488+00');
INSERT INTO public.suppliers VALUES (1088, 'Macedo S.A._1777861794659', 'Núbia Pereira', NULL, 'benicio_pereira5@hotmail.com_1777861794659', '11987654321', '84788095914659', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:58.21795+00');
INSERT INTO public.suppliers VALUES (1089, 'Oliveira-Franco_1777861794659', 'Ladislau Saraiva', NULL, 'davilucca36@hotmail.com_1777861794659', '11987654321', '32490634914659', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:58.463064+00');
INSERT INTO public.suppliers VALUES (1090, 'Braga, Albuquerque e Pereira_1777861794659', 'Warley Reis', NULL, 'theo_batista@gmail.com_1777861794659', '11987654321', '91669736144659', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:58.945843+00');
INSERT INTO public.suppliers VALUES (1091, 'Macedo EIRELI_1777861794659', 'Dr. Marcelo Oliveira', NULL, 'rebeca46@yahoo.com_1777861794659', '11987654321', '77337954964659', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:59.181618+00');
INSERT INTO public.suppliers VALUES (1092, 'Oliveira LTDA_1777861794659', 'Miguel Saraiva', NULL, 'clara_xavier46@yahoo.com_1777861794659', '11987654321', '76730694114659', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:59.424896+00');
INSERT INTO public.suppliers VALUES (1093, 'Barros e Associados_1777861794659', 'Isabela Batista', NULL, 'felicia_costa@yahoo.com_1777861794659', '11987654321', '53509909634659', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:29:59.666453+00');
INSERT INTO public.suppliers VALUES (1094, 'Empresa 1777861804360', 'Jewertãrero Silvad', NULL, 'teste_1777861804360@mail.com', '11987654321', '24817778618043', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:30:04.518626+00');
INSERT INTO public.suppliers VALUES (1433, 'Empresa 1778032856115', 'Jewertãrero Silvad', NULL, 'teste_1778032856115@mail.com', '11987654321', '24817780328561', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:56.313151+00');
INSERT INTO public.suppliers VALUES (1456, 'Empresa 1778032871542', 'Teste QA', NULL, 'teste_1778032871542@mail.com', '11999999999', '12817780328715', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:11.738933+00');
INSERT INTO public.suppliers VALUES (1579, 'Roob, Kertzmann and Parker', 'Patrick Boehm', NULL, 'bernhard.kub37@yahoo.com', '11987654321', '12659854874745', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-21 00:17:07.831309+00');
INSERT INTO public.suppliers VALUES (1601, 'Grady, Terry and Luettgen', 'Margarita Osinski', NULL, 'sabrina.schultz@hotmail.com', '11987654321', '01782434179470', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-26 00:36:19.70986+00');
INSERT INTO public.suppliers VALUES (1095, 'Empresa 1777861805589', 'Teste QA', NULL, 'teste_1777861805589@mail.com', '11999999999', '12817778618055', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:30:05.737091+00');
INSERT INTO public.suppliers VALUES (1096, 'Empresa 1777862368456', 'Jewertãrero Silvad', NULL, 'teste_1777862368456@mail.com', '11987654321', '24817778623684', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:28.670115+00');
INSERT INTO public.suppliers VALUES (1097, 'Carvalho, Oliveira e Reis', 'Sr. Rafael Saraiva', NULL, 'cecilia_pereira76@yahoo.com', '11987654321', '59784102396446', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:29.20545+00');
INSERT INTO public.suppliers VALUES (1098, 'Albuquerque-Silva_1777862369690', 'Srta. Ana Luiza Barros', NULL, 'joaomiguel91@yahoo.com_1777862369690', '11987654321', '85348871239690', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:29.839886+00');
INSERT INTO public.suppliers VALUES (1099, 'Melo Comércio_1777862369690', 'Frederico Barros', NULL, 'eduarda_souza70@gmail.com_1777862369690', '11987654321', '86436700929690', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:30.066117+00');
INSERT INTO public.suppliers VALUES (1100, 'Franco-Albuquerque_1777862369690', 'Esther Moreira', NULL, 'analaura_xavier20@live.com_1777862369690', '11987654321', '56596266679690', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:30.288004+00');
INSERT INTO public.suppliers VALUES (1101, 'Nogueira EIRELI_1777862369690', 'Morgana Pereira Neto', NULL, 'antonio.oliveira@bol.com.br_1777862369690', '11987654321', '36217377409690', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:30.506403+00');
INSERT INTO public.suppliers VALUES (1102, 'Moraes LTDA_1777862369690', 'Enzo Pereira', NULL, 'livia_silva79@gmail.com_1777862369690', '11987654321', '52291514119690', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:30.821697+00');
INSERT INTO public.suppliers VALUES (1103, 'Saraiva-Barros_1777862369690', 'Norberto Barros', NULL, 'paula_reis@bol.com.br_1777862369690', '11987654321', '20509050289690', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:31.034861+00');
INSERT INTO public.suppliers VALUES (1104, 'Nogueira-Souza_1777862369690', 'Marli Reis Jr.', NULL, 'giovanna45@gmail.com_1777862369690', '11987654321', '13215829749690', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:31.261082+00');
INSERT INTO public.suppliers VALUES (1105, 'Nogueira-Saraiva_1777862369690', 'Lorena Costa', NULL, 'felipe94@hotmail.com_1777862369690', '11987654321', '72240760579690', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:31.470395+00');
INSERT INTO public.suppliers VALUES (1106, 'Oliveira-Moraes_1777862369690', 'Gustavo Albuquerque Filho', NULL, 'analaura_santos@hotmail.com_1777862369690', '11987654321', '19546102839690', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:31.683757+00');
INSERT INTO public.suppliers VALUES (1107, 'Martins e Associados_1777862369690', 'Dra. Maria Eduarda Nogueira', NULL, 'larissa_moreira@gmail.com_1777862369690', '11987654321', '49311158949690', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:31.892694+00');
INSERT INTO public.suppliers VALUES (1108, 'Albuquerque, Saraiva e Albuquerque_1777862369690', 'Isadora Moreira', NULL, 'rafaela_macedo94@gmail.com_1777862369690', '11987654321', '15131227979690', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:32.104008+00');
INSERT INTO public.suppliers VALUES (1109, 'Moreira, Reis e Santos_1777862369690', 'Roberto Barros', NULL, 'janaina_souza75@yahoo.com_1777862369690', '11987654321', '88893250489690', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:32.326946+00');
INSERT INTO public.suppliers VALUES (1110, 'Reis-Batista_1777862369690', 'Emanuelly Oliveira', NULL, 'mariahelena97@hotmail.com_1777862369690', '11987654321', '16487240689690', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:32.536669+00');
INSERT INTO public.suppliers VALUES (1111, 'Costa LTDA_1777862369690', 'Isaac Nogueira', NULL, 'larissa.reis@live.com_1777862369690', '11987654321', '59246259659690', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:32.742912+00');
INSERT INTO public.suppliers VALUES (1112, 'Macedo, Nogueira e Pereira_1777862369690', 'Samuel Braga', NULL, 'dalila10@live.com_1777862369690', '11987654321', '72542026079690', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:32.956317+00');
INSERT INTO public.suppliers VALUES (1113, 'Franco Comércio_1777862369690', 'Washington Martins', NULL, 'gael_souza43@gmail.com_1777862369690', '11987654321', '53040473899690', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:33.172041+00');
INSERT INTO public.suppliers VALUES (1114, 'Martins, Moraes e Moreira_1777862369690', 'Eduarda Silva', NULL, 'roberto_reis@live.com_1777862369690', '11987654321', '17496524449690', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:33.384992+00');
INSERT INTO public.suppliers VALUES (1115, 'Albuquerque, Batista e Costa_1777862369690', 'Lorena Braga', NULL, 'analuiza14@hotmail.com_1777862369690', '11987654321', '68662361439690', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:33.601049+00');
INSERT INTO public.suppliers VALUES (1116, 'Silva-Carvalho_1777862369690', 'Sr. Lorenzo Melo', NULL, 'laura.franco@gmail.com_1777862369690', '11987654321', '45656077289690', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:33.824063+00');
INSERT INTO public.suppliers VALUES (1117, 'Moreira-Melo_1777862369690', 'Yango Carvalho', NULL, 'fabiano_moraes@yahoo.com_1777862369690', '11987654321', '80029022379690', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:34.061154+00');
INSERT INTO public.suppliers VALUES (1118, 'Empresa 1777862378114', 'Jewertãrero Silvad', NULL, 'teste_1777862378114@mail.com', '11987654321', '24817778623781', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:38.276739+00');
INSERT INTO public.suppliers VALUES (1119, 'Empresa 1777862379272', 'Teste QA', NULL, 'teste_1777862379272@mail.com', '11999999999', '12817778623792', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:39:39.418657+00');
INSERT INTO public.suppliers VALUES (1120, 'Empresa 1777862694277', 'Jewertãrero Silvad', NULL, 'teste_1777862694277@mail.com', '11987654321', '24817778626942', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:54.440178+00');
INSERT INTO public.suppliers VALUES (1121, 'Carvalho-Saraiva', 'Eduarda Saraiva', NULL, 'anajulia.santos@bol.com.br', '11987654321', '06283799739358', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:55.120688+00');
INSERT INTO public.suppliers VALUES (1122, 'Oliveira S.A._1777862695518', 'Isabel Batista', NULL, 'paulo89@gmail.com_1777862695518', '11987654321', '46843601615518', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:55.669566+00');
INSERT INTO public.suppliers VALUES (1123, 'Reis-Costa_1777862695518', 'Fábio Braga', NULL, 'samuel_santos@bol.com.br_1777862695518', '11987654321', '05743401425518', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:55.910788+00');
INSERT INTO public.suppliers VALUES (1124, 'Reis, Moreira e Melo_1777862695518', 'Fábio Macedo', NULL, 'julia_costa@gmail.com_1777862695518', '11987654321', '52389746065518', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:56.177594+00');
INSERT INTO public.suppliers VALUES (1125, 'Costa, Moraes e Barros_1777862695518', 'Isabella Pereira', NULL, 'larissa14@bol.com.br_1777862695518', '11987654321', '86430582905518', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:56.399002+00');
INSERT INTO public.suppliers VALUES (1126, 'Xavier, Nogueira e Pereira_1777862695518', 'Ricardo Nogueira', NULL, 'bryan58@yahoo.com_1777862695518', '11987654321', '35851712315518', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:56.619388+00');
INSERT INTO public.suppliers VALUES (1128, 'Souza, Batista e Moraes_1777862695518', 'Calebe Macedo', NULL, 'meire_braga@bol.com.br_1777862695518', '11987654321', '78474028645518', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:57.072925+00');
INSERT INTO public.suppliers VALUES (1129, 'Batista-Santos_1777862695518', 'Morgana Reis', NULL, 'alessandra_batista53@yahoo.com_1777862695518', '11987654321', '15655537845518', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:57.298263+00');
INSERT INTO public.suppliers VALUES (1130, 'Xavier-Albuquerque_1777862695518', 'Emanuelly Moreira', NULL, 'gustavo.xavier4@live.com_1777862695518', '11987654321', '26883861985518', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:57.53081+00');
INSERT INTO public.suppliers VALUES (1131, 'Braga, Melo e Macedo_1777862695518', 'Helena Carvalho', NULL, 'heloisa_carvalho@live.com_1777862695518', '11987654321', '03588557445518', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:57.757803+00');
INSERT INTO public.suppliers VALUES (1132, 'Macedo e Associados_1777862695518', 'Dra. Clara Moreira', NULL, 'celia.franco@yahoo.com_1777862695518', '11987654321', '28106792645518', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:58.07537+00');
INSERT INTO public.suppliers VALUES (1133, 'Macedo e Associados_1777862695518', 'Yuri Oliveira', NULL, 'pedro_macedo9@gmail.com_1777862695518', '11987654321', '41788786385518', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:58.305211+00');
INSERT INTO public.suppliers VALUES (1134, 'Saraiva LTDA_1777862695518', 'Dr. Leonardo Batista', NULL, 'sara89@hotmail.com_1777862695518', '11987654321', '51876905535518', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:58.527629+00');
INSERT INTO public.suppliers VALUES (1135, 'Nogueira EIRELI_1777862695518', 'Heloísa Oliveira', NULL, 'isaac_braga18@hotmail.com_1777862695518', '11987654321', '80107936505518', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:58.77483+00');
INSERT INTO public.suppliers VALUES (1136, 'Carvalho S.A._1777862695518', 'Júlio Macedo', NULL, 'pedrohenrique41@live.com_1777862695518', '11987654321', '14161539915518', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:59.002329+00');
INSERT INTO public.suppliers VALUES (1137, 'Moraes LTDA_1777862695518', 'Clara Xavier', NULL, 'marcos.albuquerque94@yahoo.com_1777862695518', '11987654321', '91442631395518', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:59.224106+00');
INSERT INTO public.suppliers VALUES (1138, 'Souza-Carvalho_1777862695518', 'Pedro Henrique Macedo', NULL, 'silas48@gmail.com_1777862695518', '11987654321', '61894013395518', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:59.461295+00');
INSERT INTO public.suppliers VALUES (1139, 'Moreira-Saraiva_1777862695518', 'Heloísa Martins', NULL, 'pedro29@hotmail.com_1777862695518', '11987654321', '29742798075518', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:59.700705+00');
INSERT INTO public.suppliers VALUES (1140, 'Silva, Saraiva e Carvalho_1777862695518', 'Alessandro Franco', NULL, 'cecilia_souza@yahoo.com_1777862695518', '11987654321', '69659150125518', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:44:59.946517+00');
INSERT INTO public.suppliers VALUES (1141, 'Franco-Nogueira_1777862695518', 'Luiza Oliveira', NULL, 'igor33@hotmail.com_1777862695518', '11987654321', '35013311725518', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:45:00.196506+00');
INSERT INTO public.suppliers VALUES (1142, 'Empresa 1777862704855', 'Jewertãrero Silvad', NULL, 'teste_1777862704855@mail.com', '11987654321', '24817778627048', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:45:05.01024+00');
INSERT INTO public.suppliers VALUES (1434, 'Franco, Moraes e Albuquerque', 'Maitê Costa Filho', NULL, 'lucas_albuquerque89@live.com', '11987654321', '43969655006068', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:57.041775+00');
INSERT INTO public.suppliers VALUES (1580, 'Hahn Inc', 'Mrs. Christie Ritchie', NULL, 'anais_daniel99@hotmail.com', '11987654321', '00265985874745', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-21 00:18:15.420984+00');
INSERT INTO public.suppliers VALUES (1581, 'Sporer - Schulist', 'Carlos Mills', NULL, 'amelie.gaylord14@yahoo.com', '11987654321', '09265985874745', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-21 00:18:24.248994+00');
INSERT INTO public.suppliers VALUES (1582, 'Bogisich, Ward and Leuschke', 'Carrie Price', NULL, 'conrad_oconnell@yahoo.com', '11987654321', '09265785874745', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-21 00:18:32.483875+00');
INSERT INTO public.suppliers VALUES (1602, 'Heller - Bradtke', 'Glenn O''Hara MD', NULL, 'ari53@hotmail.com', '11987654321', '01782434210048', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-26 00:36:50.396473+00');
INSERT INTO public.suppliers VALUES (1603, 'Kertzmann, Breitenberg and Rowe', 'Josh Hettinger', NULL, 'eloise.purdy12@hotmail.com', '11987654321', '01782434220154', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-26 00:37:00.376114+00');
INSERT INTO public.suppliers VALUES (1143, 'Empresa 1777862706155', 'Teste QA', NULL, 'teste_1777862706155@mail.com', '11999999999', '12817778627061', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:45:06.29786+00');
INSERT INTO public.suppliers VALUES (1144, 'Empresa 1777862964847', 'Jewertãrero Silvad', NULL, 'teste_1777862964847@mail.com', '11987654321', '24817778629648', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:25.032911+00');
INSERT INTO public.suppliers VALUES (1145, 'Melo, Braga e Silva', 'Fábio Braga', NULL, 'mariana61@bol.com.br', '11987654321', '10707272259959', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:25.721199+00');
INSERT INTO public.suppliers VALUES (1146, 'Barros-Reis_1777862966229', 'Larissa Nogueira', NULL, 'antonio_melo64@gmail.com_1777862966229', '11987654321', '75703254466229', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:26.399134+00');
INSERT INTO public.suppliers VALUES (1147, 'Albuquerque, Silva e Xavier_1777862966229', 'Meire Franco', NULL, 'rebeca74@yahoo.com_1777862966229', '11987654321', '77902304886229', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:26.687063+00');
INSERT INTO public.suppliers VALUES (1148, 'Melo, Pereira e Nogueira_1777862966229', 'Laura Moraes', NULL, 'victor54@live.com_1777862966229', '11987654321', '39748518736229', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:27.007685+00');
INSERT INTO public.suppliers VALUES (1149, 'Costa-Souza_1777862966229', 'Isabelly Barros', NULL, 'yango48@yahoo.com_1777862966229', '11987654321', '92153197236229', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:27.30489+00');
INSERT INTO public.suppliers VALUES (1150, 'Xavier LTDA_1777862966229', 'Clara Nogueira', NULL, 'mariajulia.barros92@yahoo.com_1777862966229', '11987654321', '34512503536229', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:27.600617+00');
INSERT INTO public.suppliers VALUES (1151, 'Reis LTDA_1777862966229', 'Lucca Oliveira', NULL, 'yago_costa85@bol.com.br_1777862966229', '11987654321', '68903598086229', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:28.253935+00');
INSERT INTO public.suppliers VALUES (1152, 'Pereira-Barros_1777862966229', 'Júlio Franco', NULL, 'joaolucas_moreira56@live.com_1777862966229', '11987654321', '06282788586229', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:28.540292+00');
INSERT INTO public.suppliers VALUES (1153, 'Franco LTDA_1777862966229', 'Eloá Moraes', NULL, 'enzo28@gmail.com_1777862966229', '11987654321', '25644812826229', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:28.828358+00');
INSERT INTO public.suppliers VALUES (1154, 'Xavier-Moraes_1777862966229', 'Hugo Albuquerque', NULL, 'deneval.melo57@bol.com.br_1777862966229', '11987654321', '09918681386229', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:29.123332+00');
INSERT INTO public.suppliers VALUES (1155, 'Pereira LTDA_1777862966229', 'Feliciano Moraes', NULL, 'helio18@hotmail.com_1777862966229', '11987654321', '55153887996229', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:29.444643+00');
INSERT INTO public.suppliers VALUES (1156, 'Moraes EIRELI_1777862966229', 'Dr. Murilo Saraiva', NULL, 'felicia77@live.com_1777862966229', '11987654321', '06865263646229', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:29.73276+00');
INSERT INTO public.suppliers VALUES (1157, 'Nogueira, Melo e Franco_1777862966229', 'Salvador Batista', NULL, 'tertuliano.nogueira@yahoo.com_1777862966229', '11987654321', '35933573236229', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:30.030122+00');
INSERT INTO public.suppliers VALUES (1158, 'Oliveira-Melo_1777862966229', 'Dr. Vitor Reis', NULL, 'emanuel.macedo@hotmail.com_1777862966229', '11987654321', '55992953976229', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:30.322647+00');
INSERT INTO public.suppliers VALUES (1159, 'Macedo, Macedo e Reis_1777862966229', 'Lorena Barros', NULL, 'alice82@bol.com.br_1777862966229', '11987654321', '53495476856229', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:30.611969+00');
INSERT INTO public.suppliers VALUES (1160, 'Pereira Comércio_1777862966229', 'Aline Braga', NULL, 'lavinia.batista@yahoo.com_1777862966229', '11987654321', '31781654776229', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:30.903679+00');
INSERT INTO public.suppliers VALUES (1161, 'Braga, Silva e Xavier_1777862966229', 'Lucca Saraiva', NULL, 'antonio.franco72@hotmail.com_1777862966229', '11987654321', '72283561546229', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:31.192607+00');
INSERT INTO public.suppliers VALUES (1162, 'Macedo-Martins_1777862966229', 'Maria Alice Moraes', NULL, 'rafael39@live.com_1777862966229', '11987654321', '70003085536229', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:31.507792+00');
INSERT INTO public.suppliers VALUES (1163, 'Silva, Martins e Santos_1777862966229', 'Ana Laura Albuquerque', NULL, 'janaina_reis50@bol.com.br_1777862966229', '11987654321', '35093302716229', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:31.790864+00');
INSERT INTO public.suppliers VALUES (1164, 'Santos Comércio_1777862966229', 'Danilo Xavier', NULL, 'norberto53@gmail.com_1777862966229', '11987654321', '09903484966229', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:32.089441+00');
INSERT INTO public.suppliers VALUES (1165, 'Batista, Barros e Oliveira_1777862966229', 'João Miguel Braga', NULL, 'nubia20@yahoo.com_1777862966229', '11987654321', '18951962966229', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:32.380474+00');
INSERT INTO public.suppliers VALUES (1166, 'Empresa 1777862978261', 'Jewertãrero Silvad', NULL, 'teste_1777862978261@mail.com', '11987654321', '24817778629782', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:38.471075+00');
INSERT INTO public.suppliers VALUES (1167, 'Empresa 1777862979821', 'Teste QA', NULL, 'teste_1777862979821@mail.com', '11999999999', '12817778629798', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:49:39.996994+00');
INSERT INTO public.suppliers VALUES (1168, 'Empresa 1777863282088', 'Jewertãrero Silvad', NULL, 'teste_1777863282088@mail.com', '11987654321', '24817778632820', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:42.235036+00');
INSERT INTO public.suppliers VALUES (1169, 'Souza e Associados', 'Guilherme Moraes', NULL, 'joaopedro.franco22@hotmail.com', '11987654321', '45097456212882', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:42.755539+00');
INSERT INTO public.suppliers VALUES (1170, 'Macedo-Pereira_1777863283155', 'Dra. Antonella Santos', NULL, 'pablo.souza49@hotmail.com_1777863283155', '11987654321', '71067858983155', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:43.287886+00');
INSERT INTO public.suppliers VALUES (1171, 'Batista S.A._1777863283155', 'Lorraine Oliveira Filho', NULL, 'gael_saraiva@yahoo.com_1777863283155', '11987654321', '15623652473155', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:43.498451+00');
INSERT INTO public.suppliers VALUES (1172, 'Barros EIRELI_1777863283155', 'Lorena Batista', NULL, 'davi.costa29@bol.com.br_1777863283155', '11987654321', '39116022403155', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:43.714009+00');
INSERT INTO public.suppliers VALUES (1174, 'Nogueira e Associados_1777863283155', 'Dr. Eduardo Oliveira', NULL, 'isabelly43@bol.com.br_1777863283155', '11987654321', '01801521933155', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:44.131885+00');
INSERT INTO public.suppliers VALUES (1175, 'Braga-Saraiva_1777863283155', 'Bernardo Oliveira', NULL, 'gabriel28@hotmail.com_1777863283155', '11987654321', '63057345353155', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:44.340359+00');
INSERT INTO public.suppliers VALUES (1176, 'Melo, Pereira e Braga_1777863283155', 'Roberta Batista', NULL, 'heitor.reis@hotmail.com_1777863283155', '11987654321', '04007625043155', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:44.542342+00');
INSERT INTO public.suppliers VALUES (1177, 'Martins e Associados_1777863283155', 'Fabiano Xavier', NULL, 'heitor.albuquerque@hotmail.com_1777863283155', '11987654321', '55645502113155', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:44.747565+00');
INSERT INTO public.suppliers VALUES (1178, 'Oliveira, Moreira e Barros_1777863283155', 'Vitória Oliveira', NULL, 'morgana.franco@live.com_1777863283155', '11987654321', '61856621523155', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:44.961782+00');
INSERT INTO public.suppliers VALUES (1179, 'Barros, Pereira e Souza_1777863283155', 'Benício Moraes', NULL, 'pedro_carvalho@yahoo.com_1777863283155', '11987654321', '90716447603155', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:45.202106+00');
INSERT INTO public.suppliers VALUES (1180, 'Xavier, Albuquerque e Barros_1777863283155', 'Lorraine Barros', NULL, 'arthur_carvalho@bol.com.br_1777863283155', '11987654321', '21019365673155', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:45.736927+00');
INSERT INTO public.suppliers VALUES (1181, 'Saraiva-Braga_1777863283155', 'Dra. Isadora Silva', NULL, 'paulo93@bol.com.br_1777863283155', '11987654321', '23167050663155', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:45.968486+00');
INSERT INTO public.suppliers VALUES (1182, 'Xavier EIRELI_1777863283155', 'Tertuliano Nogueira', NULL, 'valentina77@yahoo.com_1777863283155', '11987654321', '41052939093155', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:46.186398+00');
INSERT INTO public.suppliers VALUES (1183, 'Carvalho, Barros e Moreira_1777863283155', 'Pedro Henrique Moraes', NULL, 'marli93@gmail.com_1777863283155', '11987654321', '99053081723155', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:46.401465+00');
INSERT INTO public.suppliers VALUES (1184, 'Barros Comércio_1777863283155', 'Carlos Nogueira', NULL, 'bryan_barros89@yahoo.com_1777863283155', '11987654321', '01975418613155', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:46.608761+00');
INSERT INTO public.suppliers VALUES (1185, 'Batista, Moraes e Pereira_1777863283155', 'Júlio César Barros', NULL, 'alexandre.batista16@bol.com.br_1777863283155', '11987654321', '08183061733155', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:46.824094+00');
INSERT INTO public.suppliers VALUES (1186, 'Braga-Souza_1777863283155', 'Yango Pereira Neto', NULL, 'sarah96@live.com_1777863283155', '11987654321', '85675836473155', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:47.02555+00');
INSERT INTO public.suppliers VALUES (1187, 'Santos, Silva e Macedo_1777863283155', 'Alice Barros', NULL, 'cecilia_souza@bol.com.br_1777863283155', '11987654321', '95619660983155', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:47.25793+00');
INSERT INTO public.suppliers VALUES (1188, 'Melo, Barros e Silva_1777863283155', 'Núbia Silva', NULL, 'isabella.reis@gmail.com_1777863283155', '11987654321', '67018500793155', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:47.471215+00');
INSERT INTO public.suppliers VALUES (1189, 'Braga, Martins e Souza_1777863283155', 'Pedro Henrique Moreira', NULL, 'bryan.batista20@bol.com.br_1777863283155', '11987654321', '43933789803155', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:47.686334+00');
INSERT INTO public.suppliers VALUES (1190, 'Empresa 1777863291695', 'Jewertãrero Silvad', NULL, 'teste_1777863291695@mail.com', '11987654321', '24817778632916', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:51.860326+00');
INSERT INTO public.suppliers VALUES (1435, 'Santos, Moraes e Carvalho_1778032857566', 'Alice Barros', NULL, 'raul_martins@yahoo.com_1778032857566', '11987654321', '11202926427566', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:57.762891+00');
INSERT INTO public.suppliers VALUES (1436, 'Saraiva, Pereira e Souza_1778032857566', 'Bruna Macedo', NULL, 'natalia30@gmail.com_1778032857566', '11987654321', '83094677707566', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:58.086486+00');
INSERT INTO public.suppliers VALUES (1437, 'Santos LTDA_1778032857566', 'Heitor Saraiva Filho', NULL, 'paula_moraes@bol.com.br_1778032857566', '11987654321', '03719847227566', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:58.402001+00');
INSERT INTO public.suppliers VALUES (1438, 'Costa Comércio_1778032857566', 'Maria Alice Macedo', NULL, 'manuela20@gmail.com_1778032857566', '11987654321', '12448258067566', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:58.830997+00');
INSERT INTO public.suppliers VALUES (1439, 'Costa, Macedo e Macedo_1778032857566', 'João Pedro Oliveira', NULL, 'raul3@live.com_1778032857566', '11987654321', '71667941377566', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:59.153331+00');
INSERT INTO public.suppliers VALUES (1440, 'Oliveira Comércio_1778032857566', 'Vitória Martins', NULL, 'morgana79@hotmail.com_1778032857566', '11987654321', '10159108047566', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:59.485586+00');
INSERT INTO public.suppliers VALUES (1441, 'Carvalho-Santos_1778032857566', 'Anthony Silva', NULL, 'benicio_nogueira24@gmail.com_1778032857566', '11987654321', '03331797327566', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:00:59.79541+00');
INSERT INTO public.suppliers VALUES (1442, 'Moraes-Martins_1778032857566', 'Matheus Moreira', NULL, 'marcelo_albuquerque30@gmail.com_1778032857566', '11987654321', '85961334017566', NULL, NULL, 'TO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:00.128403+00');
INSERT INTO public.suppliers VALUES (1443, 'Braga e Associados_1778032857566', 'Maria Helena Moraes', NULL, 'anthony24@gmail.com_1778032857566', '11987654321', '44532325927566', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:00.442838+00');
INSERT INTO public.suppliers VALUES (1444, 'Nogueira, Costa e Pereira_1778032857566', 'Marcelo Santos', NULL, 'emanuelly.souza@bol.com.br_1778032857566', '11987654321', '36674930157566', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:00.750265+00');
INSERT INTO public.suppliers VALUES (1445, 'Saraiva Comércio_1778032857566', 'Núbia Carvalho', NULL, 'dalila21@hotmail.com_1778032857566', '11987654321', '05096513597566', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:01.291016+00');
INSERT INTO public.suppliers VALUES (1446, 'Moreira e Associados_1778032857566', 'Théo Carvalho', NULL, 'paula.carvalho@bol.com.br_1778032857566', '11987654321', '41186869487566', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:01.608905+00');
INSERT INTO public.suppliers VALUES (1447, 'Batista-Carvalho_1778032857566', 'Isis Santos', NULL, 'giovanna_braga@live.com_1778032857566', '11987654321', '83396812747566', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:01.927027+00');
INSERT INTO public.suppliers VALUES (1448, 'Xavier e Associados_1778032857566', 'Gael Martins', NULL, 'dalila.saraiva@yahoo.com_1778032857566', '11987654321', '61024013227566', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:02.236922+00');
INSERT INTO public.suppliers VALUES (1449, 'Santos EIRELI_1778032857566', 'Feliciano Braga', NULL, 'joao13@gmail.com_1778032857566', '11987654321', '39995313517566', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:02.546603+00');
INSERT INTO public.suppliers VALUES (1450, 'Albuquerque, Carvalho e Martins_1778032857566', 'Janaína Franco', NULL, 'mariaeduarda_carvalho@yahoo.com_1778032857566', '11987654321', '71019977747566', NULL, NULL, 'RN', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:02.860705+00');
INSERT INTO public.suppliers VALUES (1451, 'Martins Comércio_1778032857566', 'Sirineu Braga', NULL, 'marina72@hotmail.com_1778032857566', '11987654321', '22019626127566', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:03.176493+00');
INSERT INTO public.suppliers VALUES (1452, 'Barros-Xavier_1778032857566', 'Ana Laura Xavier', NULL, 'lorena_carvalho57@live.com_1778032857566', '11987654321', '36655989067566', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:03.489629+00');
INSERT INTO public.suppliers VALUES (1453, 'Nogueira EIRELI_1778032857566', 'Kléber Batista', NULL, 'alice.batista53@gmail.com_1778032857566', '11987654321', '54596239287566', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:03.806263+00');
INSERT INTO public.suppliers VALUES (1454, 'Barros, Moraes e Martins_1778032857566', 'Eloá Moraes', NULL, 'matheus.franco55@bol.com.br_1778032857566', '11987654321', '41692922167566', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:04.144512+00');
INSERT INTO public.suppliers VALUES (1455, 'Empresa 1778032869903', 'Jewertãrero Silvad', NULL, 'teste_1778032869903@mail.com', '11987654321', '24817780328699', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:01:10.123953+00');
INSERT INTO public.suppliers VALUES (1583, 'Schimmel Group', 'Rosalie Boyer', NULL, 'clementina_stracke@yahoo.com', '11987654321', '09265785374745', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-21 00:44:27.699605+00');
INSERT INTO public.suppliers VALUES (1604, 'Prohaska Inc', 'Warren Ortiz', NULL, 'kale49@hotmail.com', '11987654321', '01782434627739', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-06-26 00:43:47.950894+00');
INSERT INTO public.suppliers VALUES (1191, 'Empresa 1777863292841', 'Teste QA', NULL, 'teste_1777863292841@mail.com', '11999999999', '12817778632928', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-04 02:54:52.981858+00');
INSERT INTO public.suppliers VALUES (1192, 'Empresa 1778030350442', 'Jewertãrero Silvad', NULL, 'teste_1778030350442@mail.com', '11987654321', '24817780303504', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:10.897911+00');
INSERT INTO public.suppliers VALUES (1193, 'Pereira e Associados', 'Karla Costa', NULL, 'alexandre.franco78@hotmail.com', '11987654321', '75448877734432', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:11.588301+00');
INSERT INTO public.suppliers VALUES (1194, 'Xavier S.A._1778030352064', 'Ana Júlia Franco Jr.', NULL, 'leonardo.martins81@gmail.com_1778030352064', '11987654321', '91881487162064', NULL, NULL, 'MA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:12.248222+00');
INSERT INTO public.suppliers VALUES (1195, 'Barros-Martins_1778030352064', 'Enzo Santos', NULL, 'calebe33@live.com_1778030352064', '11987654321', '21711065012064', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:12.543217+00');
INSERT INTO public.suppliers VALUES (1196, 'Oliveira-Reis_1778030352064', 'Isaac Carvalho', NULL, 'margarida_xavier86@live.com_1778030352064', '11987654321', '98361805892064', NULL, NULL, 'AC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:12.85108+00');
INSERT INTO public.suppliers VALUES (1198, 'Costa S.A._1778030352064', 'Bryan Silva', NULL, 'pietro.pereira@hotmail.com_1778030352064', '11987654321', '26286933832064', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:13.47049+00');
INSERT INTO public.suppliers VALUES (1199, 'Santos, Nogueira e Moreira_1778030352064', 'Morgana Reis', NULL, 'nicolas17@yahoo.com_1778030352064', '11987654321', '29028358212064', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:13.766258+00');
INSERT INTO public.suppliers VALUES (1200, 'Nogueira Comércio_1778030352064', 'Karla Costa', NULL, 'salvador2@hotmail.com_1778030352064', '11987654321', '99933880942064', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:14.060771+00');
INSERT INTO public.suppliers VALUES (1201, 'Pereira LTDA_1778030352064', 'Murilo Silva Jr.', NULL, 'mariana74@live.com_1778030352064', '11987654321', '07759321452064', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:14.400703+00');
INSERT INTO public.suppliers VALUES (1202, 'Reis EIRELI_1778030352064', 'Enzo Oliveira', NULL, 'joao46@yahoo.com_1778030352064', '11987654321', '91078662602064', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:14.69097+00');
INSERT INTO public.suppliers VALUES (1203, 'Carvalho, Barros e Albuquerque_1778030352064', 'Maria Alice Oliveira', NULL, 'isabella69@live.com_1778030352064', '11987654321', '24122810372064', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:14.986587+00');
INSERT INTO public.suppliers VALUES (1204, 'Costa-Nogueira_1778030352064', 'Caio Carvalho', NULL, 'meire23@live.com_1778030352064', '11987654321', '71548462622064', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:15.31015+00');
INSERT INTO public.suppliers VALUES (1205, 'Costa LTDA_1778030352064', 'Sara Batista', NULL, 'yuri33@yahoo.com_1778030352064', '11987654321', '30833471592064', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:15.614554+00');
INSERT INTO public.suppliers VALUES (1206, 'Albuquerque-Xavier_1778030352064', 'Antonella Pereira', NULL, 'fabiano_oliveira@yahoo.com_1778030352064', '11987654321', '82554732042064', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:15.926214+00');
INSERT INTO public.suppliers VALUES (1207, 'Moreira e Associados_1778030352064', 'Carla Martins', NULL, 'joaopedro_saraiva52@gmail.com_1778030352064', '11987654321', '70337665722064', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:16.225281+00');
INSERT INTO public.suppliers VALUES (1208, 'Barros, Oliveira e Souza_1778030352064', 'Margarida Braga', NULL, 'marli58@live.com_1778030352064', '11987654321', '45181659192064', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:16.520205+00');
INSERT INTO public.suppliers VALUES (1209, 'Moraes EIRELI_1778030352064', 'Davi Lucca Saraiva', NULL, 'enzogabriel.nogueira46@hotmail.com_1778030352064', '11987654321', '63120185402064', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:16.81767+00');
INSERT INTO public.suppliers VALUES (1210, 'Nogueira, Melo e Albuquerque_1778030352064', 'Dra. Larissa Costa', NULL, 'lara6@bol.com.br_1778030352064', '11987654321', '99227092822064', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:17.109368+00');
INSERT INTO public.suppliers VALUES (1211, 'Franco Comércio_1778030352064', 'Felícia Saraiva', NULL, 'morgana.silva@hotmail.com_1778030352064', '11987654321', '26326158362064', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:17.405937+00');
INSERT INTO public.suppliers VALUES (1212, 'Xavier-Batista_1778030352064', 'Srta. Melissa Moreira', NULL, 'joaquim.saraiva@live.com_1778030352064', '11987654321', '58819694242064', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:17.708141+00');
INSERT INTO public.suppliers VALUES (1213, 'Oliveira, Costa e Souza_1778030352064', 'Hélio Souza', NULL, 'sara_pereira11@bol.com.br_1778030352064', '11987654321', '86573769302064', NULL, NULL, 'RR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:18.00445+00');
INSERT INTO public.suppliers VALUES (1214, 'Empresa 1778030363139', 'Jewertãrero Silvad', NULL, 'teste_1778030363139@mail.com', '11987654321', '24817780303631', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:23.735579+00');
INSERT INTO public.suppliers VALUES (1215, 'Empresa 1778030365382', 'Teste QA', NULL, 'teste_1778030365382@mail.com', '11999999999', '12817780303653', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:19:25.581756+00');
INSERT INTO public.suppliers VALUES (1216, 'Empresa 1778030749977', 'Jewertãrero Silvad', NULL, 'teste_1778030749977@mail.com', '11987654321', '24817780307499', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:50.182619+00');
INSERT INTO public.suppliers VALUES (1217, 'Macedo-Franco', 'Maitê Franco', NULL, 'vitoria.xavier1@yahoo.com', '11987654321', '65660373848900', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:51.218109+00');
INSERT INTO public.suppliers VALUES (1218, 'Braga, Costa e Nogueira_1778030751679', 'Bruna Moreira', NULL, 'roberto50@bol.com.br_1778030751679', '11987654321', '39718480481679', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:51.85437+00');
INSERT INTO public.suppliers VALUES (1219, 'Albuquerque-Martins_1778030751679', 'Mércia Carvalho', NULL, 'mariahelena.moreira24@bol.com.br_1778030751679', '11987654321', '49267072391679', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:52.13964+00');
INSERT INTO public.suppliers VALUES (1220, 'Franco-Oliveira_1778030751679', 'Valentina Xavier', NULL, 'gael18@hotmail.com_1778030751679', '11987654321', '47026598411679', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:52.451007+00');
INSERT INTO public.suppliers VALUES (1221, 'Santos, Carvalho e Albuquerque_1778030751679', 'Meire Silva', NULL, 'alicia_moraes@live.com_1778030751679', '11987654321', '81010455911679', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:52.783109+00');
INSERT INTO public.suppliers VALUES (1222, 'Nogueira Comércio_1778030751679', 'Beatriz Macedo', NULL, 'gubio.reis@live.com_1778030751679', '11987654321', '23541346131679', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:53.076235+00');
INSERT INTO public.suppliers VALUES (1223, 'Carvalho-Oliveira_1778030751679', 'Yasmin Albuquerque', NULL, 'roberta88@yahoo.com_1778030751679', '11987654321', '78738473911679', NULL, NULL, 'GO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:53.388195+00');
INSERT INTO public.suppliers VALUES (1224, 'Martins-Costa_1778030751679', 'Suélen Macedo', NULL, 'julio99@yahoo.com_1778030751679', '11987654321', '90568858591679', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:53.681384+00');
INSERT INTO public.suppliers VALUES (1225, 'Reis-Saraiva_1778030751679', 'Théo Braga', NULL, 'mariaclara_santos38@bol.com.br_1778030751679', '11987654321', '98180864491679', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:53.970284+00');
INSERT INTO public.suppliers VALUES (1226, 'Albuquerque, Batista e Macedo_1778030751679', 'Ana Clara Moreira', NULL, 'marcela51@yahoo.com_1778030751679', '11987654321', '70942311941679', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:54.29872+00');
INSERT INTO public.suppliers VALUES (1227, 'Xavier-Reis_1778030751679', 'Tertuliano Carvalho', NULL, 'enzogabriel.franco86@gmail.com_1778030751679', '11987654321', '14648235091679', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:54.59118+00');
INSERT INTO public.suppliers VALUES (1228, 'Xavier Comércio_1778030751679', 'Kléber Barros', NULL, 'livia13@gmail.com_1778030751679', '11987654321', '12291561741679', NULL, NULL, 'PA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:54.875959+00');
INSERT INTO public.suppliers VALUES (1229, 'Martins, Braga e Santos_1778030751679', 'Fábio Barros', NULL, 'paulo.reis69@hotmail.com_1778030751679', '11987654321', '51005996281679', NULL, NULL, 'AL', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:55.157588+00');
INSERT INTO public.suppliers VALUES (1230, 'Souza EIRELI_1778030751679', 'Júlio Oliveira', NULL, 'bernardo_pereira@yahoo.com_1778030751679', '11987654321', '09103776761679', NULL, NULL, 'SE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:55.437999+00');
INSERT INTO public.suppliers VALUES (1231, 'Oliveira-Costa_1778030751679', 'Alessandra Martins', NULL, 'julio81@bol.com.br_1778030751679', '11987654321', '43149836401679', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:56.107864+00');
INSERT INTO public.suppliers VALUES (1232, 'Santos EIRELI_1778030751679', 'Fábio Albuquerque', NULL, 'suelen_macedo51@hotmail.com_1778030751679', '11987654321', '55940296611679', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:56.411635+00');
INSERT INTO public.suppliers VALUES (1233, 'Moreira-Franco_1778030751679', 'Rebeca Batista', NULL, 'laura8@yahoo.com_1778030751679', '11987654321', '04605241901679', NULL, NULL, 'AP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:56.709111+00');
INSERT INTO public.suppliers VALUES (1234, 'Oliveira, Barros e Batista_1778030751679', 'Eloá Carvalho Filho', NULL, 'cecilia45@bol.com.br_1778030751679', '11987654321', '65677648381679', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:56.98438+00');
INSERT INTO public.suppliers VALUES (1235, 'Saraiva, Oliveira e Nogueira_1778030751679', 'Marina Barros', NULL, 'benjamin.souza@hotmail.com_1778030751679', '11987654321', '27559823441679', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:57.267993+00');
INSERT INTO public.suppliers VALUES (1236, 'Franco, Nogueira e Moraes_1778030751679', 'Sara Carvalho', NULL, 'meire.carvalho@hotmail.com_1778030751679', '11987654321', '95007081611679', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:57.556496+00');
INSERT INTO public.suppliers VALUES (1237, 'Saraiva, Saraiva e Braga_1778030751679', 'Ana Júlia Nogueira', NULL, 'carlos.albuquerque@hotmail.com_1778030751679', '11987654321', '15958947681679', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:25:57.851611+00');
INSERT INTO public.suppliers VALUES (1238, 'Empresa 1778030763764', 'Jewertãrero Silvad', NULL, 'teste_1778030763764@mail.com', '11987654321', '24817780307637', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:26:03.954954+00');
INSERT INTO public.suppliers VALUES (1239, 'Empresa 1778030765236', 'Teste QA', NULL, 'teste_1778030765236@mail.com', '11999999999', '12817780307652', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:26:05.413929+00');
INSERT INTO public.suppliers VALUES (1240, 'Empresa 1778031305121', 'Jewertãrero Silvad', NULL, 'teste_1778031305121@mail.com', '11987654321', '24817780313051', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:05.369465+00');
INSERT INTO public.suppliers VALUES (1241, 'Pereira-Albuquerque', 'Clara Martins', NULL, 'mariajulia.santos83@bol.com.br', '11987654321', '80449434395024', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:06.215964+00');
INSERT INTO public.suppliers VALUES (1242, 'Barros-Batista_1778031306692', 'Alessandra Moreira Filho', NULL, 'calebe.moraes@gmail.com_1778031306692', '11987654321', '79216832096692', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:06.864061+00');
INSERT INTO public.suppliers VALUES (1243, 'Costa-Melo_1778031306692', 'Eloá Franco', NULL, 'yasmin_franco93@hotmail.com_1778031306692', '11987654321', '42659448256692', NULL, NULL, 'ES', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:07.161136+00');
INSERT INTO public.suppliers VALUES (1244, 'Melo-Reis_1778031306692', 'Yasmin Albuquerque', NULL, 'maria.albuquerque@gmail.com_1778031306692', '11987654321', '05690549196692', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:07.458286+00');
INSERT INTO public.suppliers VALUES (1245, 'Oliveira-Carvalho_1778031306692', 'Lucca Oliveira Neto', NULL, 'marialuiza_macedo87@hotmail.com_1778031306692', '11987654321', '16741198426692', NULL, NULL, 'SC', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:07.763086+00');
INSERT INTO public.suppliers VALUES (1246, 'Franco, Carvalho e Costa_1778031306692', 'Marli Pereira', NULL, 'sarah44@bol.com.br_1778031306692', '11987654321', '21483764166692', NULL, NULL, 'MT', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:08.058214+00');
INSERT INTO public.suppliers VALUES (1247, 'Souza-Batista_1778031306692', 'Gabriel Oliveira', NULL, 'calebe49@bol.com.br_1778031306692', '11987654321', '34409212136692', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:08.351297+00');
INSERT INTO public.suppliers VALUES (1248, 'Albuquerque, Franco e Costa_1778031306692', 'Maria Cecília Batista', NULL, 'calebe_albuquerque@bol.com.br_1778031306692', '11987654321', '85686183376692', NULL, NULL, 'RS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:08.641892+00');
INSERT INTO public.suppliers VALUES (1249, 'Martins-Oliveira_1778031306692', 'Hugo Braga', NULL, 'fabio_souza36@bol.com.br_1778031306692', '11987654321', '83048946936692', NULL, NULL, 'PR', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:08.933795+00');
INSERT INTO public.suppliers VALUES (1250, 'Santos, Pereira e Barros_1778031306692', 'Caio Macedo', NULL, 'anthony_xavier@yahoo.com_1778031306692', '11987654321', '55821809036692', NULL, NULL, 'PE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:09.215021+00');
INSERT INTO public.suppliers VALUES (1251, 'Moreira Comércio_1778031306692', 'Raul Franco Neto', NULL, 'esther.batista47@yahoo.com_1778031306692', '11987654321', '81438827646692', NULL, NULL, 'RJ', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:09.492232+00');
INSERT INTO public.suppliers VALUES (1252, 'Pereira-Costa_1778031306692', 'Bryan Braga', NULL, 'breno.albuquerque@bol.com.br_1778031306692', '11987654321', '69484281996692', NULL, NULL, 'CE', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:09.790143+00');
INSERT INTO public.suppliers VALUES (1253, 'Oliveira Comércio_1778031306692', 'Júlia Moreira', NULL, 'fabricia_reis53@bol.com.br_1778031306692', '11987654321', '44396588006692', NULL, NULL, 'MS', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:10.08449+00');
INSERT INTO public.suppliers VALUES (1254, 'Nogueira-Martins_1778031306692', 'Célia Braga', NULL, 'beatriz.souza@bol.com.br_1778031306692', '11987654321', '70029419146692', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:10.399976+00');
INSERT INTO public.suppliers VALUES (1255, 'Barros, Albuquerque e Barros_1778031306692', 'João Lucas Xavier', NULL, 'gubio.pereira24@bol.com.br_1778031306692', '11987654321', '79488982706692', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:10.686872+00');
INSERT INTO public.suppliers VALUES (1256, 'Martins Comércio_1778031306692', 'Natália Carvalho', NULL, 'murilo.braga@hotmail.com_1778031306692', '11987654321', '81883913566692', NULL, NULL, 'DF', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:10.996491+00');
INSERT INTO public.suppliers VALUES (1257, 'Oliveira, Franco e Moreira_1778031306692', 'Larissa Costa', NULL, 'yango.melo@bol.com.br_1778031306692', '11987654321', '20892679786692', NULL, NULL, 'AM', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:11.29886+00');
INSERT INTO public.suppliers VALUES (1258, 'Batista, Martins e Nogueira_1778031306692', 'Bernardo Moreira', NULL, 'anajulia_martins@hotmail.com_1778031306692', '11987654321', '49881506976692', NULL, NULL, 'MG', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:11.594438+00');
INSERT INTO public.suppliers VALUES (1259, 'Souza-Braga_1778031306692', 'Carlos Saraiva', NULL, 'mariaeduarda78@gmail.com_1778031306692', '11987654321', '65730182596692', NULL, NULL, 'PB', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:11.884974+00');
INSERT INTO public.suppliers VALUES (1260, 'Franco S.A._1778031306692', 'Alícia Xavier', NULL, 'rebeca_braga96@yahoo.com_1778031306692', '11987654321', '93205719666692', NULL, NULL, 'RO', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:12.173868+00');
INSERT INTO public.suppliers VALUES (1261, 'Carvalho-Oliveira_1778031306692', 'Dra. Felícia Pereira', NULL, 'pietro70@live.com_1778031306692', '11987654321', '77992464226692', NULL, NULL, 'BA', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:12.464275+00');
INSERT INTO public.suppliers VALUES (1262, 'Empresa 1778031317640', 'Jewertãrero Silvad', NULL, 'teste_1778031317640@mail.com', '11987654321', '24817780313176', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:17.825994+00');
INSERT INTO public.suppliers VALUES (1263, 'Empresa 1778031319152', 'Teste QA', NULL, 'teste_1778031319152@mail.com', '11999999999', '12817780313191', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 01:35:19.334091+00');
INSERT INTO public.suppliers VALUES (1457, 'Empresa 1778034256358', 'Jewertãrero Silvad', NULL, 'teste_1778034256358@mail.com', '11987654321', '24817780342563', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:16.610099+00');
INSERT INTO public.suppliers VALUES (1480, 'Empresa 1778034272404', 'Teste QA', NULL, 'teste_1778034272404@mail.com', '11999999999', '12817780342724', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-06 02:24:32.619671+00');
INSERT INTO public.suppliers VALUES (1584, 'Christiansen, Ziemann and Stamm', 'Sylvia Kozey', NULL, 'adan38@gmail.com', '11987654321', '01779672866765', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-25 01:34:26.826358+00');
INSERT INTO public.suppliers VALUES (1585, 'Veum Inc', 'Alyssa Crooks', NULL, 'shea.walsh51@hotmail.com', '11987654321', '01779672867980', NULL, NULL, 'SP', NULL, 'Brazil', NULL, 0.00, true, NULL, '2026-05-25 01:34:28.002851+00');


--
-- TOC entry 4014 (class 0 OID 19336)
-- Dependencies: 366
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES ('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'joao.silva@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'João Silva', NULL, '(11) 99876-5432', NULL, NULL, true, 'customer', 'QATEST2025', NULL, true, NULL, '2025-11-22 19:13:30.023236+00', '2025-11-22 19:13:30.023236+00');
INSERT INTO public.users VALUES ('5efbb6a1-3c2e-4f71-8939-a1bcb5e5e7d4', 'maria.santos@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Maria Santos', NULL, '(21) 98765-4321', NULL, NULL, true, 'customer', 'QATEST2025', NULL, true, NULL, '2025-11-22 19:13:30.023236+00', '2025-11-22 19:13:30.023236+00');
INSERT INTO public.users VALUES ('5bd86580-4d13-41c5-9597-567cb579a1fa', 'test44e1244346t@test.com', '$2a$12$jGcwb1GZYThBYR5R1w/JJeH/O9.9UUk6L7bhmSx9by0s..TIweCOW', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-31 00:16:18.219183+00', '2026-01-31 00:16:18.219183+00');
INSERT INTO public.users VALUES ('3e71bd1a-2cdf-4d10-a2c2-c602af55c25f', 'alun5o12@test.com', '$2a$12$NZhEq8.lKzGVJr.VwtyVEO3k4gTA.99.pmZSbdsi4wxme.kd.HDMK', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-31 17:08:26.433472+00', '2026-01-31 17:08:26.433472+00');
INSERT INTO public.users VALUES ('419eb463-da4d-469a-95fa-27283279490e', 'test4e1244346t@test.com', '$2a$12$ieCL.L50oKLRo.YqzFI2MePh4jYPSe2/c6NjIohUpuX7hfgrR.GO2', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 11:39:45.030886+00', '2026-01-30 11:39:45.030886+00');
INSERT INTO public.users VALUES ('ceb5b92f-8921-4bcd-9ccb-e023d74b774f', 'mane@qatest.com', '$2a$12$/yP0irq64io6cuXwEW0hsOdCad1cAtasxefQeB1ZNag6EEJyvJBn.', 'Carlos Mane', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-02-16 13:44:05.95+00', false, NULL, '2026-02-16 13:30:18.212405+00', '2026-02-16 13:30:18.212405+00');
INSERT INTO public.users VALUES ('e3cf4301-9ba6-4d82-90c8-cfc81054a202', 'aluno10@test.com', '$2a$12$dZJY9MBdWP.xhxXvOpDhyeNSFTYnOUlyEft36Clli8WxVWXZsBPJe', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-01-31 18:54:05.608+00', false, NULL, '2026-01-31 18:52:49.675663+00', '2026-01-31 18:52:49.675663+00');
INSERT INTO public.users VALUES ('54c6b7ff-a298-4c66-862a-d1a9066f4b98', 'eumesmo2@gmail.com', '$2a$12$vj6DbCAXcCSu0BEsGpeHsepCq4M3edBYJbDJMI7I9dI1HAH9dKeQ.', 'eumesmomesmodulo', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-01-31 02:26:59.619+00', false, NULL, '2026-01-31 02:17:55.104868+00', '2026-01-31 02:17:55.104868+00');
INSERT INTO public.users VALUES ('60972209-626e-4ed6-b567-6000795f7f56', 'sanor@gmail.com', '$2a$12$NRBiYtPq8/F3WQguHcoks.DJwdrXeZ7ghZ.u7cHa5Vq0IuN6DtE5.', 'melo dos santos', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-31 02:11:21.977654+00', '2026-01-31 02:11:21.977654+00');
INSERT INTO public.users VALUES ('14d8954b-5594-4bf1-b9c0-6a6ed9b06f7c', 'eumesmo@gmail.com', '$2a$12$IClQhHuEm077/i.3/9ou6eO/cnn6bE4KwWyN5wZ30TZ.YuRbVkn/m', 'Eu mesmo', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-31 02:13:25.616176+00', '2026-01-31 02:13:25.616176+00');
INSERT INTO public.users VALUES ('92da188a-9da7-4530-a2e4-685e85f197db', 'aluno@test.com', '$2a$12$EBW9vqADJ0zAhF1jlzmqv.LyJQeAYZFhIK7jvVjwb98yXb9a7HV8S', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 01:10:32.510125+00', '2026-01-28 01:10:32.510125+00');
INSERT INTO public.users VALUES ('3406ecb3-5f1c-4709-a48c-2e9c1e0f202b', 'aluno1@test.com', '$2a$12$exV5CG.ZVRTcy2G39PnEZeBmYxXjuYbxZ63ogXG.9oGb7.YRtb7ze', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 01:30:39.94399+00', '2026-01-28 01:30:39.94399+00');
INSERT INTO public.users VALUES ('fb94a992-8231-42fa-bd8f-fc72db971b27', 'aluno12@test.com', '$2a$12$2mbEECDeCu2dS4jZXJSEYeHbTZIWw4aBuWZogx3RJueNLRnzvtf/S', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 01:38:02.190271+00', '2026-01-28 01:38:02.190271+00');
INSERT INTO public.users VALUES ('c25c8ff7-1880-4397-a1cf-959aa4130c11', 'aluno9@test.com', '$2a$12$YQFn/uyB6JXxO9S3Tjfjq.rBefVuwQGrmN4aPlB/JcWVV30epfaUW', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 02:04:24.200436+00', '2026-01-28 02:04:24.200436+00');
INSERT INTO public.users VALUES ('a5582ae5-935b-429c-a86b-b7a62ea68ce0', 'alun2o@test.com', '$2a$12$xJ63I1TqdZqgl2ndQ50QP.8P8BEsojYj9az5W6DOTcb4JCk2V76Yy', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 02:46:19.954612+00', '2026-01-28 02:46:19.954612+00');
INSERT INTO public.users VALUES ('74f4a2ce-4082-42a5-a269-a26799c6880a', 'aluno6@test.com', '$2a$12$F30pnUi7dZhJjzFmBNb3teQ45LnfLqCWvjcxpzy7UyA.udTWrGbHC', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 11:27:06.210272+00', '2026-01-28 11:27:06.210272+00');
INSERT INTO public.users VALUES ('1bb96e53-3fb1-4a25-b2e0-3a49b63c0d51', 'aluno66@test.com', '$2a$12$uTsp7X/GP040bgPha/EyeuPgFnj6klb/lEbv9gzfDfHsUtBZcUZ9m', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 11:37:22.4548+00', '2026-01-28 11:37:22.4548+00');
INSERT INTO public.users VALUES ('8cce08d0-4db7-4985-92e0-f33aae878b8b', 'aluno686@test.com', '$2a$12$bdy.cfI8N6Ous9iAWPRs9uBGjcHdRWAdcbwTF/zcTHWF2.3kv76d.', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-28 11:40:36.665074+00', '2026-01-28 11:40:36.665074+00');
INSERT INTO public.users VALUES ('45e6f730-cc81-4e12-b636-54e1e5b3f084', 'alu3no@test.com', '$2a$12$Ey58HvzbDNReEbACv8yFJu0n3l/Gpf5IzI8vfDSffD8m0Vlks.x62', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-31 01:03:49.163264+00', '2026-01-31 01:03:49.163264+00');
INSERT INTO public.users VALUES ('0e3c45e3-65e7-4b73-9ab5-0ade2c7bae7c', 'maria@gmail.com', '$2a$12$8WM/3jWZVcvYTW4u4UbsSurq72ZfStwKk8zkjl/QLmC35hiq9RxEa', 'Maria Carla', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 17:56:54.226749+00', '2026-02-22 17:56:54.226749+00');
INSERT INTO public.users VALUES ('460af039-c892-4d72-bd78-88f4fcc589b3', 'aluno32@test.com', '$2a$12$XEp18R74O4JVfgVXNraBN.J.N1.Yl8BhsiFi77fvwvoQ/QYqNlPru', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 01:49:33.737184+00', '2026-01-30 01:49:33.737184+00');
INSERT INTO public.users VALUES ('2f6e98e0-b611-4fe5-891c-9cf86ee57f6c', 'aluno632@test.com', '$2a$12$kvzGyZ1gqFFRh4oDU/MRGOsFHQ9iapbIvQm1rMUncgwX5.bYEa6o2', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 02:26:15.814048+00', '2026-01-30 02:26:15.814048+00');
INSERT INTO public.users VALUES ('f61d3c2e-6f01-4413-bd86-eb7d156cea66', 'al6uno632@test.com', '$2a$12$fJ.BmFEFxoZjgFjyTK.K8eja4hCiTTO9OBPHKI0FDszUO4Ohln0si', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 02:28:31.816674+00', '2026-01-30 02:28:31.816674+00');
INSERT INTO public.users VALUES ('a4c7fcbc-791b-4072-94b9-fa05c3d9023b', 'al6uno6632@test.com', '$2a$12$ZV/WVXvFmO0RGxxqYsB57uoGHTmU.VN4itqplRZMR3wV7fB7pQL7e', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 02:29:55.686455+00', '2026-01-30 02:29:55.686455+00');
INSERT INTO public.users VALUES ('c42bd499-8cce-4ec0-a758-fab5c5060813', 'al6uno36632@test.com', '$2a$12$OBc8HlBVucPCbdiaUi.X4er97jMolKd1DEWsdFukVXbIEsPNh7Iaq', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 02:33:22.452943+00', '2026-01-30 02:33:22.452943+00');
INSERT INTO public.users VALUES ('00223c6a-0b94-4c02-9290-a460750a1986', 'al6un6o36632@test.com', '$2a$12$0bqKD9bzBKR54SVFlJWwreT3fOqCE4XN6pgtf6hphgn32uevBcP2K', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 02:35:46.823061+00', '2026-01-30 02:35:46.823061+00');
INSERT INTO public.users VALUES ('78353850-41e5-4474-82a7-a579446d545e', 'al6u6n66o36632@test.com', '$2a$12$eTeoS/GBLpQwzthp8DiIVeShCVEMy8h/iG.rK5gjEkMNY0ISUCglS', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 02:43:15.587349+00', '2026-01-30 02:43:15.587349+00');
INSERT INTO public.users VALUES ('802ee9a8-f6de-412e-bef8-15a1539191af', 'al6u6rn66o36632@test.com', '$2a$12$E44LflQhjiEShMCabfSAXenpBsSSzeEXKlEiaX4rIaiVLcnHQxwMK', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 10:42:04.920026+00', '2026-01-30 10:42:04.920026+00');
INSERT INTO public.users VALUES ('6912a832-3be3-432e-8fe6-dc1fd1345e06', 'al6u6rrn66o36632@test.com', '$2a$12$GjLL81YQP4aOSwwmWKW1q.gN.U3wjspAfjHBDZDL1MZiNFhvsCe4y', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 10:49:48.897808+00', '2026-01-30 10:49:48.897808+00');
INSERT INTO public.users VALUES ('bf920f41-b5fc-43f6-a285-d84f1c7ecf74', 'alun6o@test.com', '$2a$12$PQxc2K4DUU.yIlr5WlBE0.NIXG4xQejS9z2m2wes/RifoH2C7h11K', 'Aluno Teste jud', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-07 14:44:40.511793+00', '2026-02-07 14:44:40.511793+00');
INSERT INTO public.users VALUES ('9a1928b4-ad81-4d60-aa98-b00487b078ea', 'al63u6rrn66o36632@test.com', '$2a$12$NATCgtdBZtTQLjaPmnwQYeuGUmlDaJt9LBtsGeMGgVyiyNTLssKe.', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 10:55:16.934111+00', '2026-01-30 10:55:16.934111+00');
INSERT INTO public.users VALUES ('c4613751-2954-4d3a-8128-0c8eb713e9fc', 'teste12346t@test.com', '$2a$12$xM6IRSS29MqnPB1pmb7pj.X8drzlRAUvkmb.ZsjimrWo9gQFw25zS', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 11:02:31.338774+00', '2026-01-30 11:02:31.338774+00');
INSERT INTO public.users VALUES ('ce4ee330-7ea8-43e4-be14-24c619999cea', 'teste124346t@test.com', '$2a$12$B6VhkG/lAy4Azb6.nIltGOdPiTgHfhqZjRDnJ/yBqvc6a5Wj8dx4q', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 11:09:53.21702+00', '2026-01-30 11:09:53.21702+00');
INSERT INTO public.users VALUES ('4b081335-c981-4efb-b8eb-21c88c8b99bf', 'test4e124346t@test.com', '$2a$12$dJuHFsmLj4l3KVqrxLZdpeAwKLUsOSOZndVsQjgKZ828jedQ6Lvv.', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-01-30 11:15:56.152487+00', '2026-01-30 11:15:56.152487+00');
INSERT INTO public.users VALUES ('dadc53b3-6ba7-4c93-8da4-358b7c5d7761', 'marcola@gmail.com', '$2a$12$YicEhFeO5OoGFydMR2kaWuJMWOiAOZAgxrxLDvhe4XpYNsd9Yl6w6', 'marcola marc', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-02-16 17:10:21.803+00', false, NULL, '2026-02-16 17:06:54.156735+00', '2026-02-16 17:06:54.156735+00');
INSERT INTO public.users VALUES ('8f2eaf5b-b7a8-4c5d-bf3f-aa1cae8f59d7', 'manemane@gmail.com', '$2a$12$DjtEoysHK6oX72wTpJJEbO4BVOr.nwa/9BzoQI/Oauz2cM/PqRudW', 'manmnmn rerer rere', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-02-20 21:14:33.443+00', false, NULL, '2026-02-20 21:14:12.127042+00', '2026-02-20 21:14:12.127042+00');
INSERT INTO public.users VALUES ('2ef6cd61-5684-43e1-a2be-952cd97b86f8', 'admin2@qatest.com', '$2a$12$8Mwdj/.lciASDn2xGRmqaOwOQQ40kR8jTjU8BQkpGPFNcw77.isDu', 'erwer rwerwerwe', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-16 13:40:19.662833+00', '2026-02-16 13:40:19.662833+00');
INSERT INTO public.users VALUES ('db422e25-b9e7-4d3e-91b7-3894c4202055', 'aluno3@test.com', '$2a$12$amuBgE4FsBttncKaXaBzSuTEGigGxXXXWglLLPWZz3W2am4WvGWJW', 'Aluno Teste Ytrd', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-07 18:08:33.0916+00', '2026-02-07 18:08:33.0916+00');
INSERT INTO public.users VALUES ('00243469-2a60-4c0c-80a5-477045772e6c', 'mane2@qatest.com', '$2a$12$UkG4/jEnzwrPSABZRQLePed7GvDbHa.IgwmF3x7D/B.GRXPahJM8O', 'Carlos Mane', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-16 13:43:49.523627+00', '2026-02-16 13:43:49.523627+00');
INSERT INTO public.users VALUES ('50ba5acd-2fac-485a-bfa2-bd236d85fc4b', 'mane@gmail.com', '$2a$12$cSsRiFYZvCXqU.BIdkqQA.D.VORa5hSDaaROyAiKDibB.lDUyvV.G', 'manezim', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-20 21:10:01.383451+00', '2026-02-20 21:10:01.383451+00');
INSERT INTO public.users VALUES ('9d7c158a-077c-4739-9d05-024449e505d3', 'maria2@gmail.com', '$2a$12$L3FbnSkMwyTG4.Do31LLn.kE.TAmd3U7buP7E8/q6pYpB6iuwNRLe', 'Maria Carla', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 17:57:57.913742+00', '2026-02-22 17:57:57.913742+00');
INSERT INTO public.users VALUES ('7c2b0c69-2523-4f8c-97cb-9c9ca0b62666', 'werwer@ggfdg.com', '$2a$12$gmDkk9RgFJ1PbDJ23NsbrukB5ZE80Y1Y0/5s/WAdD0Y1mGkWONQGa', 'rwerwr rwer', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 18:08:55.170843+00', '2026-02-22 18:08:55.170843+00');
INSERT INTO public.users VALUES ('49393615-1e62-4bc4-97c6-afe5a0a5f5b7', 'joao@gmail.com', '$2a$12$wU8Ouzv18dLh4KdPTiFRn.aTg0a3tO8pXyexEvA9P6CuZPQopI5x6', 'Joaoao oaooo', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 18:11:57.139128+00', '2026-02-22 18:11:57.139128+00');
INSERT INTO public.users VALUES ('0d7f4780-0b68-4faa-8c08-46f89da3160b', 'marial42@gmail.com', '$2a$12$58nz7IWWJ1X9auXkLmaXeu/ByNj94N5G8I6Lt1fY6jTLrj8vvF/2W', 'Maria Joseo', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 18:16:07.767823+00', '2026-02-22 18:16:07.767823+00');
INSERT INTO public.users VALUES ('baaf3404-9b09-4ab9-bb1f-ac2f904d7df6', 'marialu42@gmail.com', '$2a$12$.N4/g7jFdYGP4JI5A/bwjuI7LYRaRccLH8.conzkCvQwBVVy9.ngW', 'Maria Joseo', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 18:16:28.416151+00', '2026-02-22 18:16:28.416151+00');
INSERT INTO public.users VALUES ('2961a5a6-42dc-4dc0-a1a4-2e8c852a45e4', 'teste@gmail.com', '$2a$12$6K4nZNWhflxlOtgbwKyiT.8ogBTWY7jtnCFxOrQ86iB0ES1Xx0ESC', 'Everton Ulissses', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 19:30:55.48083+00', '2026-02-22 19:30:55.48083+00');
INSERT INTO public.users VALUES ('2de8b427-4a49-4bb3-86cb-3fd0a1c7e216', 'novoteste@gmail.com', '$2a$12$U1.MI9OIKG.HInCYdGSyROf1ZfQ1MdPNMQIfUZDJV7CbE3/pO68ym', 'Evertoo Ulisses', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 20:13:02.725955+00', '2026-02-22 20:13:02.725955+00');
INSERT INTO public.users VALUES ('4f31bfb9-0424-41a8-8ec5-5872933c3c09', 'mauro@gmail.com', '$2a$12$rZ98LXvXtzwmqB6pSipDrOI.e/.HZbNFTNr4IfJf3ul0GjUmVtJ9i', 'Mauro Cid', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 20:37:56.490034+00', '2026-02-22 20:37:56.490034+00');
INSERT INTO public.users VALUES ('a4ca25c5-30dc-44be-990e-643ee6ad598f', 'mariajulia@gmail.com', '$2a$12$1lytpafwLAhWKnjAhcAS5egpWFfZg0TCDRTkK/O9tCkwP0bWDbXV.', 'Maria Julia Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 20:47:05.199222+00', '2026-02-22 20:47:05.199222+00');
INSERT INTO public.users VALUES ('d2c2b16a-bc05-4d41-a9bc-366547f548df', 'marirajulia@gmail.com', '$2a$12$WNKG2ASq7y7yjPLH/gR8geuxz2VJms3MNz/au6s85RRLvtt5AAdW2', 'Maria Juliar Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 20:47:50.142039+00', '2026-02-22 20:47:50.142039+00');
INSERT INTO public.users VALUES ('cca61f86-1e3e-486c-942d-4bbfda822890', 'marirajulian@gmail.com', '$2a$12$9l0irts154glMhGiY0CRI.uZyJuetW4gTVDnfcJka44MY3OgwqGuq', 'Maria Juliana Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 22:31:48.30061+00', '2026-02-22 22:31:48.30061+00');
INSERT INTO public.users VALUES ('02fcdaff-4e96-43d2-8e0e-e17eed11afd3', 'marirajeuliane@gmail.com', '$2a$12$fxb5A3X7LSbUYg9uxGLcluDLkNuptkUuC3kbJpHt935eDaZw7/JCS', 'Mariae Julianae Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 22:37:32.834383+00', '2026-02-22 22:37:32.834383+00');
INSERT INTO public.users VALUES ('c959212b-51fa-4d7d-904d-9207fd2d3f07', 'marirrabjeuliane@gmail.com', '$2a$12$eywBcP7rLWS65tMPxRj.bee01NdvaWICrvRvxoUBe6kTjb86QofEu', 'Mariaerb Julianae Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 23:06:02.342199+00', '2026-02-22 23:06:02.342199+00');
INSERT INTO public.users VALUES ('959bf80d-c7c5-416c-bddd-4e74ab5665f9', 'marireeuliane@gmail.com', '$2a$12$EquWdn/YN54XIZccvjMlM.O8.J3yZDnzIcG5fUoKTblfFjGtEvwhG', 'Marianae Julianae Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 23:13:55.790689+00', '2026-02-22 23:13:55.790689+00');
INSERT INTO public.users VALUES ('d12d3fdb-9600-4413-95ba-280affd333cf', 'marireetuliane@gmail.com', '$2a$12$nzJAPKOsc5tO.7PrhuOjQOFRDCswtorPzaPCqca7wJqL/7eb/IBJm', 'Marianate Julianae Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-22 23:14:40.347587+00', '2026-02-22 23:14:40.347587+00');
INSERT INTO public.users VALUES ('112edd49-5034-4700-a764-4699ed42e078', 'marirgfgeetuliane@gmail.com', '$2a$12$l8TzM4Vdw0lXGzCUZfu3GeIa6hfr6lAQhla4nmWUUUtuWoO6m0Ce2', 'fgfdf gdfgfg', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-23 00:57:45.142065+00', '2026-02-23 00:57:45.142065+00');
INSERT INTO public.users VALUES ('17b7c0f8-e1a2-40f6-a2f4-7508a885d3db', 'marireeetuliane@gmail.com', '$2a$12$DmviCP6gwnXWoOaHPbakI.htyVgRfkP5eLtiqNlRk6oIM3jnBpQXa', 'Marieanate Julianae Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-23 01:16:22.643522+00', '2026-02-23 01:16:22.643522+00');
INSERT INTO public.users VALUES ('0d0390e4-741a-4045-a721-2c6d8c6768d3', 'test1771809446549819@exemplo.com', '$2a$12$v5qa.P0I1siur4DHGc13me.uHVVw5JzqmR6nNL0.002VDa1q/ALTy', 'João Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-23 01:17:27.324427+00', '2026-02-23 01:17:27.324427+00');
INSERT INTO public.users VALUES ('c896f78d-f9d7-4fa3-9356-58e7d87178cb', 'test1771809449021811@exemplo.com', '$2a$12$swkfBhXsNR9bPxEQwFFnpuhtaMBpsNFo7/SJ96D2IuTuBHTGrJiNG', 'dfsdf fs', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-23 01:17:37.984128+00', '2026-02-23 01:17:37.984128+00');
INSERT INTO public.users VALUES ('d8432a7e-3ad6-47c4-9953-f0e0b10e74ce', 'test1771809491960406@exemplo.com', '$2a$12$pk/MnBmj4cxvCWpgVv6/6.q3.2xkNesSwVFCwuu4hMsZKc0IiHkXy', 'Nome Válido', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-23 01:18:12.878133+00', '2026-02-23 01:18:12.878133+00');
INSERT INTO public.users VALUES ('343592b4-21a5-48f3-9daa-49b35b1a4998', 'marireeeutuliane@gmail.com', '$2a$12$Bg6mRsLaq80zQicIGm8BVugdSmDbWkwy.F5R8xU/RBvMa1j519cPS', 'Marieanaute Julianae Car', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-24 01:38:11.010639+00', '2026-02-24 01:38:11.010639+00');
INSERT INTO public.users VALUES ('a445f049-83fd-495f-8602-2ec10f86a6d5', 'joaeo.silva@test.com', '$2a$12$sunQVBJVHQmiEF1efbQxNOylo31/twpO8A7VHxP7ULeB1A2rgThsK', 'Jeoão Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-25 16:15:44.42375+00', '2026-02-25 16:15:44.42375+00');
INSERT INTO public.users VALUES ('508a55d9-cabf-4c5b-8ec0-83085a352cbb', 'joareo.3silva@test.com', '$2a$12$UQZwnbnR6SjsVRmDW/Va1O2N1asrMMFeJfHVkNgDG4nUoIOJob8Ce', 'Jeoão Silvar', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-25 16:16:58.18708+00', '2026-02-25 16:16:58.18708+00');
INSERT INTO public.users VALUES ('d103a1f4-3978-4ac7-b549-8ab9f8f9105f', 'joareo.silva@test.com', '$2a$12$9RSN3/Hy8M4UAE26ohNR4OuxOQ9kz9zygOZJiF4rPF/F69g4H5Syq', 'Jeoãro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-25 16:18:20.79036+00', '2026-02-25 16:18:20.79036+00');
INSERT INTO public.users VALUES ('70659708-64c9-440c-b29c-0dc615f99ef6', 'joaereo.silva@test.com', '$2a$12$fQ23sfP9K3pYZj9RI1BJlO9ZizIN3H5z5CHJduQ08uTRkXFGoinHO', 'Jeeoãro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-25 16:19:45.889791+00', '2026-02-25 16:19:45.889791+00');
INSERT INTO public.users VALUES ('c6867afd-f874-4a6f-892d-2e60bf4b8f14', 'joaererreo.silva@test.com', '$2a$12$D2dDgYFt85oCdRx6H4y2tOvzQTSSfV7sFzzaKi9fO5fqsdDnTn7Rm', 'Jeeereoãro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-25 16:23:35.696936+00', '2026-02-25 16:23:35.696936+00');
INSERT INTO public.users VALUES ('539694ba-a0d4-4407-a4bc-bb68dba0e43c', 'joaerrerreo.silva@test.com', '$2a$12$BFe50bX3H1o/oiqHbCbsCemODKOlUpOXZc7nlmYLUf0k8CV55i4Oi', 'Jeeerreoãro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-02-26 01:27:59.562974+00', '2026-02-26 01:27:59.562974+00');
INSERT INTO public.users VALUES ('84dd179b-a039-4ee1-9451-a025ae232feb', 'joaerretrreo.silva@test.com', '$2a$12$6kPNo6ndF81DEYPitHtbPuFRgPPTyHVgRr3rlrT3GY/WootyvIHIq', 'Jeeerreoãro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-06 11:08:26.644784+00', '2026-03-06 11:08:26.644784+00');
INSERT INTO public.users VALUES ('14d2413f-5b78-4c0a-a556-2cb0aa9e9964', 'joaerrtetrreo.silva@test.com', '$2a$12$WKiIFf6rRBcuyPrYC.vkw.d3XKTUDfMQzbVaehNZFrZgWYbPoC0vu', 'Jeeerreoãro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-06 11:08:46.773908+00', '2026-03-06 11:08:46.773908+00');
INSERT INTO public.users VALUES ('d7314db8-d180-42b7-86c3-d55486d59a54', 'henrietta.bins29@gmail.com', '$2a$12$BeYHQkd2PPbID.gJys8Ewu41TjrXDs1oy3aTGleEaMS7fY5h9Akei', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-10 12:09:15.65046+00', '2026-03-10 12:09:15.65046+00');
INSERT INTO public.users VALUES ('de4e8ba5-4052-4bc5-a050-e6b6a24f3ae7', 'jill_buckridge@yahoo.com', '$2a$12$A8plRJ/Zff0nzJxWHe9i9OQ1iHlDa7KlBexvCu0S1a8h8ZMYVg/Hu', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-10 12:07:56.795791+00', '2026-03-10 12:07:56.795791+00');
INSERT INTO public.users VALUES ('57f8375d-1f45-460d-b5cb-bc9c7eebb836', 'rachael85@gmail.com', '$2a$12$BnuzjDBprhS.4Ww5uipd9eMc27B1cCf8UFU.n6WjPCwo0GHuDmyHq', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:35:14.442765+00', '2026-03-09 00:35:14.442765+00');
INSERT INTO public.users VALUES ('6d6d90f9-399e-44c8-8f68-76a47df8b396', 'kamilateixeira98@gmail.com', '$2a$12$C0hCcE13OhrS1vABL4CA9OguhrmRJfEekEgKRxi/G.tk1mCN5pzvu', 'Kamila Gonçalves', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-06-08 14:00:32.551+00', false, NULL, '2026-06-08 14:00:12.27232+00', '2026-06-08 14:00:12.27232+00');
INSERT INTO public.users VALUES ('a8ff2da4-1d86-4841-a62d-ebdb381f5d27', 'alunesuno2@test.com', '$2a$12$/3ZDziF0tylBhTjf1AL4ouYOTzjWM0EFdlgyPgArUzsVGImfkqQOS', 'Supermega Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-06-08 17:06:20.682+00', false, NULL, '2026-06-06 12:49:31.522365+00', '2026-06-06 12:49:31.522365+00');
INSERT INTO public.users VALUES ('054ce55b-81c7-46ad-bb65-e61858ca4331', 'thiagoapi@test.com', '$2a$12$Idz4.WmnX3icQ7g733gV7OIY6hY7Twp4qUvTr01hC6WIngwnC.AEm', 'Thiago Api', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-06-24 18:21:04.419+00', false, NULL, '2026-06-24 17:52:55.125213+00', '2026-06-24 17:52:55.125213+00');
INSERT INTO public.users VALUES ('93d5a677-da3a-4582-a892-72b90f9d4276', 'alunoo@test.com', '$2a$12$9QN2p7XNDMjiKoBoRlF7UeEesjRbSFvtCClgdYkTGHyI/e37dUfxq', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-10 19:48:17.275879+00', '2026-06-10 19:48:17.275879+00');
INSERT INTO public.users VALUES ('bb991384-68a5-483a-a204-1b8928e5567f', 'alunno@test.com', '$2a$12$4Z2/rkxCikDswUeCTY0lbeDUtZuuhrpU8Jv679OXmimuCbM1TEjWq', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-10 20:34:39.697501+00', '2026-06-10 20:34:39.697501+00');
INSERT INTO public.users VALUES ('e3064e52-e792-42ed-aff3-a000e3988cab', 'dimitri.ziemann55@gmail.com', '$2a$12$IpUBgIiN81PSClWQNj/xUeQG9oUGy77GRAJdVGGD7IMOByH5csiu.', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:51:54.129961+00', '2026-03-09 00:51:54.129961+00');
INSERT INTO public.users VALUES ('3c7b0d80-59b1-43eb-b37c-4b72fb891138', 'kerluke@qatest.com', '$2a$12$U0CYUDKH1Ziv.2AdLJtP/eatZRlL52Al8LfVb9XNlzGhXQQHbj9RC', 'Streich', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:30:03.638629+00', '2026-06-26 20:30:03.638629+00');
INSERT INTO public.users VALUES ('c5cd2bdc-afb1-4073-ac10-f2107e01698d', 'bogisich@qatest.com', '$2a$12$UEpJzgWro5mjVLQFVjrnWOgZWUibsE6ysgtx1KbMFPockxylSzqpu', 'Boehm', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:32:15.79234+00', '2026-06-26 20:32:15.79234+00');
INSERT INTO public.users VALUES ('7415db27-3c67-4d87-b13a-6775c1675f2c', 'alunoqa@test.com', '$2a$12$D.kRBic3RTirC.8qgUS6iucApjJPt5ayTWvzlyUYXCqVBisTrF0gO', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-07 17:21:45.825007+00', '2026-06-07 17:21:45.825007+00');
INSERT INTO public.users VALUES ('cac2b280-7c92-424e-9264-e1eeb5b5b941', 'david.fritsch89@hotmail.com', '$2a$12$JwqKUlo6OoZPs.VWrN6e5.T3ZP8Zdnt8bCyPB/jkNTMqENnaasZp2', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 01:02:07.302788+00', '2026-03-09 01:02:07.302788+00');
INSERT INTO public.users VALUES ('c6e818ba-160c-4cbb-96bd-f271e908cd40', 'ada_dickens38@yahoo.com', '$2a$12$jFMYltg94dqfzmM4BxjTzuNkw5wTgGLdpLvP2HhkM6z7M9HpfP.9q', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 01:10:13.08175+00', '2026-03-09 01:10:13.08175+00');
INSERT INTO public.users VALUES ('80770b91-988c-43a0-b575-88141612b36f', 'alunes@test.com', '$2a$12$CaDS91sig5x7fNi9h/QCAOKtbKq0fFJif9tBE2bXTz7AAu0jztjNm', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-06 12:20:41.852071+00', '2026-06-06 12:20:41.852071+00');
INSERT INTO public.users VALUES ('1d3a9d8b-4574-419d-ab9e-c3d7161388b6', 'alunesuno@test.com', '$2a$12$e/bZkMAaNYhd.PbuD.UUq.o6caHW9MfKhgRtwyJrJ/o1Z7ek4myrG', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-06 12:23:53.1729+00', '2026-06-06 12:23:53.1729+00');
INSERT INTO public.users VALUES ('c96877af-437e-4661-8ca4-be4572860e4f', 'julianoqa@teste.com', '$2a$12$MViqcow8S5BZ3GTnmI/86es0BWxx6fqgyGUc8CqwAcgXAt/yIT4Oa', 'Juliano Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-24 21:01:10.226421+00', '2026-06-24 21:01:10.226421+00');
INSERT INTO public.users VALUES ('f53b5546-4c55-4b3f-98ee-e26fcd454971', 'pedroteste@gmail.com', '$2a$12$9pbiyj4cntE12m6yrSgLGOfDYUsvvslvIGhSjUPG44EUbSu/qB6q.', 'pedro carrara', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-12 14:13:46.12387+00', '2026-06-12 14:13:46.12387+00');
INSERT INTO public.users VALUES ('1441b0b4-24f3-4a1d-8008-0c214c9da5d6', 'jovani.bailey@yahoo.com', '$2a$12$eOXK2nNNFdYlpc50jHjLyutwoHQiAwcxkmPqkDk3RZ9SOwzjxTkeO', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 01:11:52.830903+00', '2026-03-09 01:11:52.830903+00');
INSERT INTO public.users VALUES ('7fd639bd-1479-4a08-ad11-76f60a77152a', 'mamie.bechtelar@gmail.com', '$2a$12$SrGI.Z5EHfXVFmvCoQzv8uBGS83Cf9/k6yzqWRCViHVLWzrzp9Nl2', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:51:59.790401+00', '2026-03-09 00:51:59.790401+00');
INSERT INTO public.users VALUES ('147172d3-82d0-4188-b30f-a07296b89db1', 'stella.ortiz@gmail.com', '$2a$12$L/Sddl2xF2Q6WrgZc3OZHeL/Qlm8CcsUH4L712yvG/g9e4lCn8T0y', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:26:23.43622+00', '2026-03-09 00:26:23.43622+00');
INSERT INTO public.users VALUES ('3d124c83-8870-47b0-9c6e-00b8ba1387fd', 'aaron.lynch53@yahoo.com', '$2a$12$3cxTYCU8VFGCJOXrNgGsx.DCEiMg1u1hMjd3AoK750.z3BXREu/za', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-21 18:26:50.156009+00', '2026-03-21 18:26:50.156009+00');
INSERT INTO public.users VALUES ('a74969ed-3aed-48a8-99c7-626dad106cb9', 'aluno.testador@test.com', '$2a$12$HuzrOue/bvm03qneb8vWRuO9I9jedPQeDtyVvqGVwPEq3SykzCGDe', 'Aluno Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-03 17:51:55.460083+00', '2026-06-03 17:51:55.460083+00');
INSERT INTO public.users VALUES ('9d3a5a10-56c8-4c81-8ae3-c5280ad5b434', 'joaerreroreo.silva@test.com', '$2a$12$/fixaoWPm0rJPjiUXP4RxuKIigThi18XTj4jjB7u0/hCbUk9ddBx.', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:20:12.229022+00', '2026-03-09 00:20:12.229022+00');
INSERT INTO public.users VALUES ('63690475-45ff-4c83-a53e-30fcad16968c', 'ana001@test.com', '$2a$12$PZbk1kvUyulg6jNGXP2eb.rCxVN262GCC5O4hFAqFaterfazKKF3O', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:20:48.411382+00', '2026-03-09 00:20:48.411382+00');
INSERT INTO public.users VALUES ('7c8f5992-a9d8-47de-92ed-2add98a4b3e2', 'ana32@yahoo.com', '$2a$12$A7AHD.IhkphYSDy9wsElauOKcnVHaR1NnwbFueU1oJzalWrzVkM3W', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:23:11.833649+00', '2026-03-09 00:23:11.833649+00');
INSERT INTO public.users VALUES ('1956973d-4af8-4ff6-b28c-500384a227bf', 'heather.lesch@hotmail.com', '$2a$12$idFFXZHUK5bNXx55Lz.sOeesje8tlfUDndTnuNHCUqxkaQpcxYUkm', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:23:19.798789+00', '2026-03-09 00:23:19.798789+00');
INSERT INTO public.users VALUES ('c7a73cf9-b8e5-49a2-beeb-841756c67a87', 'schultz@qatest.com', '$2a$12$.kCc/zSEMbtTsNvJuLBy0urgUELV37M0dLyGhYT3KIvTnYM4UmjXu', 'Brown', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:34:25.519997+00', '2026-06-26 20:34:25.519997+00');
INSERT INTO public.users VALUES ('e7a3c020-c1dc-4eac-b710-37478ae86a91', 'randolph.mcclure@hotmail.com', '$2a$12$10N3tfr7PtWJRtXjYcWzLuR/jIhXhQe5rL1VpZ281zgmzblcWrdTa', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-21 18:26:54.0185+00', '2026-03-21 18:26:54.0185+00');
INSERT INTO public.users VALUES ('94e75f20-9b44-42de-a6e5-bc4c699b36ac', 'super.email.teste.demais@test.com', '$2a$12$kpa7nD8Mq6NwwbLMqANhMunO27os7TUJPmgBirDfMhqqEWKL5HfXS', 'Supermega Teste', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-06-06 12:42:15.607+00', false, NULL, '2026-06-06 12:33:20.015708+00', '2026-06-06 12:33:20.015708+00');
INSERT INTO public.users VALUES ('5de76cbc-00e6-4e27-a4b0-28fcdfc6ed65', 'myrtle.bergnaum40@yahoo.com', '$2a$12$H5T.X5.I3u2SjDc4GZMqduF6JgcRq8k98w0xlY4M0VKa9S5InMh9i', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:25:22.795858+00', '2026-03-09 00:25:22.795858+00');
INSERT INTO public.users VALUES ('ccc95ace-fc92-49e0-96f9-617382e6a23c', 'bria_schneider@hotmail.com', '$2a$12$E1bzCUgcl80n1BBlvk6cHuT5is3WfFBKBY12F5FwmOLY2hNSjjbIe', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:35:56.976024+00', '2026-03-09 00:35:56.976024+00');
INSERT INTO public.users VALUES ('4c1f394a-4a76-4b24-8665-8c1378cfbfbf', 'shanon_mayert51@gmail.com', '$2a$12$5me8i8R5/JvrP6Ni2KN2QeVlhdWr0Rkp0DkCA7PgN4prea/3F9OVW', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-09 00:53:06.642989+00', '2026-03-09 00:53:06.642989+00');
INSERT INTO public.users VALUES ('c6fd8713-8c08-40e8-906b-7b833300630c', 'goyette@qatest.com', '$2a$12$BHUKIf7WicSb14drh05K9OyuEiltoQYbVd3tdj/WJhtntMqtAvW0S', 'Kautzer', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:34:43.09902+00', '2026-06-26 20:34:43.09902+00');
INSERT INTO public.users VALUES ('dd6fb06f-d1c8-4da1-8c98-d6c36dec7589', 'aaliyah_cummings@gmail.com', '$2a$12$wBq4mi60gJGac.oqoejj0OJsfK.dO4y2JJRcPkFKsk9vbf5aCEK7S', 'Jaro Silva', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-03-21 18:21:27.430858+00', '2026-03-21 18:21:27.430858+00');
INSERT INTO public.users VALUES ('085a1264-f1fb-40d8-a8c3-35270cfca200', 'victorfelipe@gmail.com', '$2a$12$1pLg2L88873/Z5bv/2XxUu9IhSMjSprzzujk9nTlVaX3fjbQ6Xh4y', 'Victor Felipe', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-06-19 22:16:43.087+00', false, NULL, '2026-06-19 18:00:31.248763+00', '2026-06-19 18:00:31.248763+00');
INSERT INTO public.users VALUES ('08268361-cae6-4f9b-8d29-e7bc4227439e', 'ravenaqa@gmail.com', '$2a$12$BSq6pbWigjuhMx/R9cbf1ekBI9gdoXSCx4opfJiNmkAN7TFLasa/a', 'Ravena QA', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-06-24 00:21:06.756+00', false, NULL, '2026-06-24 00:20:41.621422+00', '2026-06-24 00:20:41.621422+00');
INSERT INTO public.users VALUES ('4f1f28a8-43c7-45d8-be15-93725ebbd1fc', 'hegmann@test.com', '$2a$12$ioj/UcBRU6.LJoEpg.6PmepUrquvPSnzZMrT1crAJRtR8xp6Gqz/O', 'Stracke', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:07:51.087473+00', '2026-06-26 20:07:51.087473+00');
INSERT INTO public.users VALUES ('cb70ac57-6845-474a-8e50-576c69869d03', 'ruecker@test.com', '$2a$12$.sLwyiQrGZfxvaVv7xlTeO1lavG//4XXd8NWfBwUbOKxHkZXNn7du', 'Crooks', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:37:04.992203+00', '2026-06-26 20:37:04.992203+00');
INSERT INTO public.users VALUES ('548fe332-08ad-4d11-8b58-bc32ff200f74', 'harber@test.com', '$2a$12$mjw4rSOqOBwwQWrfQi.kEOsitAzQi1Cx2y1u8axl9dlzQ7iF194zq', 'Waelchi', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:09:12.968633+00', '2026-06-26 20:09:12.968633+00');
INSERT INTO public.users VALUES ('3d056e33-6450-430a-bda1-368670cf3f9b', 'kassulke@test.com', '$2a$12$viQHOp4TObfyFy/2dGk9WeM.lmQ16ySewZWUmvZ16nUFUOqz.24Fy', 'Schinner', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:17:02.118702+00', '2026-06-26 20:17:02.118702+00');
INSERT INTO public.users VALUES ('595846e9-e5dc-480a-a645-a8aa33146263', 'nikolaus@test.com', '$2a$12$uyqQANd7Xrg2SLDSLF0fau//Meo6VOq9XBSlMFuOY848Vu7qvGgt6', 'Cruickshank', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:17:44.498288+00', '2026-06-26 20:17:44.498288+00');
INSERT INTO public.users VALUES ('1398082e-4510-4e46-8bf0-c3f4f4e0101d', 'wehner@test.com', '$2a$12$icJO6XcIHTpy15as9QUjCu7Lpi9Dv3kDIWf6m291RXN8XO1VFH70e', 'Hauck', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:19:02.780573+00', '2026-06-26 20:19:02.780573+00');
INSERT INTO public.users VALUES ('b094cbb9-31a0-4b36-a268-37d37c5bb045', 'white@qatest.com', '$2a$12$eA0WOaFPuT6gOl5AtGxJseWWk0zW6C8cdqKzwRMkhLZkvMYIYuOym', 'Mosciski', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:37:21.121804+00', '2026-06-26 20:37:21.121804+00');
INSERT INTO public.users VALUES ('672ce23d-e1d2-47b8-a22e-6eff71514414', 'weber@test.com', '$2a$12$sMrihSi7f0RwFA9obeOEkO9IJjRF2VlCVjPUGuzMscwqCkg5e/8gO', 'Conroy', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:40:35.863775+00', '2026-06-26 20:40:35.863775+00');
INSERT INTO public.users VALUES ('9b9383d4-8e51-4d67-b046-0546b73ebf72', 'medhurst@test.com', '$2a$12$onGdtPXzZl9bHcNj4BBiEOm3XeiwN8Z8uggQTtvJPoGA1y/c4QvlG', 'Wilkinson', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:11:19.701603+00', '2026-06-28 19:11:19.701603+00');
INSERT INTO public.users VALUES ('982cf195-f4d2-422a-874a-da7873a0c4c1', 'abernathy@qatest.com', '$2a$12$adGHZxHcRWZAGU1SgB852.zJ/wu9MELRCJ1g/y3OlNXxrGlHxrqhS', 'Kohler', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:11:21.510464+00', '2026-06-28 19:11:21.510464+00');
INSERT INTO public.users VALUES ('9da5f690-ac7b-4502-b8d9-eb7a140f752d', 'yundt@qatest.com', '$2a$12$mCVU1h4/fnocXspZLQm9Pev.Mw795cEqMEqjR2gmvi9qQpNZEYXeC', 'Jacobs', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:30:28.285772+00', '2026-06-28 19:30:28.285772+00');
INSERT INTO public.users VALUES ('3e6633c8-6742-4cde-b711-c3872b82c31f', 'donnelly@test.com', '$2a$12$cMRiaGszRUm.pjVQeoEDF.1RkoHXemB.r04NXo3dCkqZBWRC8PRMK', 'Collier', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:57:31.337759+00', '2026-06-26 20:57:31.337759+00');
INSERT INTO public.users VALUES ('b2fb40fd-be17-4f18-a97e-b813c71c1735', 'ziemann@test.com', '$2a$12$X9Hh6g39eyoPauwjKFxlneUkNUzxKwvhBSr24gbRoMZjSWFSpcWc6', 'King', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-26 20:58:09.033916+00', '2026-06-26 20:58:09.033916+00');
INSERT INTO public.users VALUES ('f813bc89-b2f7-4840-9c79-bc2673bc2577', 'dare@test.com', '$2a$12$pxM4mU7iFq8FDGfmEYHHc.Mu3JhlLzVx5WiZ42vajj3E/lvpZjm.a', 'Hermiston', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:13:38.051996+00', '2026-06-28 19:13:38.051996+00');
INSERT INTO public.users VALUES ('f16cf582-0fa6-411e-a431-8e34a7ea2e08', 'lakin@qatest.com', '$2a$12$LGdYbYjVcUrmQtSJBrNc0.JfEDhM..hQaxH8yP9k/OWdDK.QM/9xK', 'Wilkinson', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:13:39.639792+00', '2026-06-28 19:13:39.639792+00');
INSERT INTO public.users VALUES ('be0f0f9e-0fed-4f8f-8f11-975689525ef5', 'kuvalis@test.com', '$2a$12$jGdsnAHKDKsESogtIbBaGuYbohyipFqnrXJW7b9Z70sTg7xZyqqqG', 'Grady', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:14:15.60135+00', '2026-06-28 19:14:15.60135+00');
INSERT INTO public.users VALUES ('68444d34-1bb0-49e9-9d47-7f29550790c9', 'ritchie@qatest.com', '$2a$12$26puc9EMwE7fP.nIvIkCv.Fb37atPzsdFm8KamCj/t04bDRmEK6bG', 'Beer', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:14:17.2051+00', '2026-06-28 19:14:17.2051+00');
INSERT INTO public.users VALUES ('4505cfd1-0600-4f27-8f0d-b023d3d07611', 'bode@test.com', '$2a$12$PlE./.cZVK9C5LSEV1LDMe3/Q8FlkZQrBrVMuerJwzaY6T.pj2Iuu', 'Ankunding', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:15:10.444004+00', '2026-06-28 19:15:10.444004+00');
INSERT INTO public.users VALUES ('bd8b3cea-08fd-4eea-88a5-ceafc5bf7860', 'hirthe@qatest.com', '$2a$12$g3Vwe/ZlGRenY9Ak.33QPuowQbyAp4fClX3WGd2xHRR44LcEXmVqq', 'Thompson', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:15:12.049861+00', '2026-06-28 19:15:12.049861+00');
INSERT INTO public.users VALUES ('f5e7a031-12fb-42ba-9fd6-4c4e7f07fadd', 'opal@test.com', '$2a$12$razQRfeUnfOMLk3rIBQ.ieDeZI3B.HO/nPfmkFf5UiSFaAoqyi5gW', 'Juston', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:48:29.450587+00', '2026-06-28 19:48:29.450587+00');
INSERT INTO public.users VALUES ('1572c6fb-3044-4adf-8f86-66165802c7e3', 'paucek@test.com', '$2a$12$W4/cgmPJZcw32suhSfxjuOFU0/OzQ3sFiCWsDpsSfZNBee5vrDK0i', 'Reinger', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:16:53.77727+00', '2026-06-28 19:16:53.77727+00');
INSERT INTO public.users VALUES ('de7f07b9-9377-469c-9bd2-0ab6e73ae603', 'runte@qatest.com', '$2a$12$pfaLx1qA2GjIyPjnHHcgHOgq18VRNPMA4flM93.2Ys//pQMLx17cq', 'Aufderhar', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:16:55.299733+00', '2026-06-28 19:16:55.299733+00');
INSERT INTO public.users VALUES ('66979529-124a-4fb1-83cf-397e1092ec14', 'conn@qatest.com', '$2a$12$xvANlfeyIu3nou8/2gKF..gYWqXgpgNriyG1oeTs3C5qbl1KrnfLe', 'Brekke', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:48:31.43301+00', '2026-06-28 19:48:31.43301+00');
INSERT INTO public.users VALUES ('058bd0c6-c4da-4291-92ed-d5c64657d46d', 'mcglynn@test.com', '$2a$12$StshwDfFOanso.nS28UWGe/J4zxBZqCRTE324EmSsdLaIoMYT8wJC', 'Prosacco', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:17:48.334084+00', '2026-06-28 19:17:48.334084+00');
INSERT INTO public.users VALUES ('bfdb4ecd-ba66-43ea-b129-7c8adfa51a66', 'fay@qatest.com', '$2a$12$Qe/TUv0eNmClS/DYLUdAfuXhnK.3hRisKt1xGFWbL9T/XFNsqEs7u', 'Herzog', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:17:49.786841+00', '2026-06-28 19:17:49.786841+00');
INSERT INTO public.users VALUES ('880c1658-db2b-460b-92bc-c432e1a4e6c6', 'victor@test.com', '$2a$12$tzhuhmgTBCDqBFrz1RfxU.4MOURoKKoWaEAt8rNmOCDkEJckmb2te', 'Klocko', NULL, NULL, NULL, NULL, true, 'customer', NULL, '2026-06-28 19:48:33.14+00', false, NULL, '2026-06-26 20:40:28.124047+00', '2026-06-26 20:40:28.124047+00');
INSERT INTO public.users VALUES ('8e499f96-5a8f-4752-b16f-00122ff3a585', 'brigitte@test.com', '$2a$12$mJkHIudx9AwHG8R.UAVsruvjABHxQqTR2lvC.elqT.vtSpp6C/1PO', 'Dan', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 20:37:56.7445+00', '2026-06-28 20:37:56.7445+00');
INSERT INTO public.users VALUES ('55a63f05-517b-400e-ad83-ce7ec032482e', 'schroeder@qatest.com', '$2a$12$xNX03bRk9tiHLkWFy9ubWuwU8zociwUQpO42.TeCI1V227LtLWUnW', 'Bednar', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 20:37:58.326608+00', '2026-06-28 20:37:58.326608+00');
INSERT INTO public.users VALUES ('36fef32a-a8c1-475d-a0b5-d0ea19d2e620', 'vonrueden@test.com', '$2a$12$bbKMDRQgatT6w/aLd6JVtuWJhQuctCuy3gEEnb3ClT5qydfFvvrWG', 'Watsica', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:23:53.185453+00', '2026-06-28 19:23:53.185453+00');
INSERT INTO public.users VALUES ('9d0c8d32-033f-4428-9ac1-11ed33d82c2a', 'cummerata@qatest.com', '$2a$12$XqB1yUcg4C1BHavVDhXE0.y6TJE6h/labgSw7mT.7BhIvPqoUSpHm', 'Price', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:23:54.82487+00', '2026-06-28 19:23:54.82487+00');
INSERT INTO public.users VALUES ('c66af127-57c7-4131-8ac1-5fa7ee2a0bc6', 'jodie@test.com', '$2a$12$yh9HAxyFtg0ULt/vyQVN5OjDiRXaofUSBc65Mtr6l8M2JNJ4HNigy', 'Dwight', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 20:38:15.706806+00', '2026-06-28 20:38:15.706806+00');
INSERT INTO public.users VALUES ('a98ec705-d96d-46e3-a60f-92caa87b6690', 'okuneva@test.com', '$2a$12$mLKpkvKzh4joYft3lgDSoOTiFZ/Ybb7iuuxKcQqltQ6iUlWrByReG', 'Howell', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:24:21.833601+00', '2026-06-28 19:24:21.833601+00');
INSERT INTO public.users VALUES ('7f84242d-e307-4d88-b132-498334383899', 'durgan@qatest.com', '$2a$12$O4AZBjsvCwmTrR1U8mN8QeZr183LvDXQpeDQ1AXk0bg4X7g22GXR6', 'Ernser', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:24:23.373359+00', '2026-06-28 19:24:23.373359+00');
INSERT INTO public.users VALUES ('1808ef02-8057-4c13-91b7-b28c623b35be', 'labadie@qatest.com', '$2a$12$GEVIJsDvtU3lHlQIIkDfQeuHoshgHol86n5pCBSf5tyxSQVYIO4Bu', 'Grant', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 20:38:17.19954+00', '2026-06-28 20:38:17.19954+00');
INSERT INTO public.users VALUES ('756cba57-3261-478b-acc3-995cf671bf03', 'bartoletti@test.com', '$2a$12$XogqJ4H22cENoiYWbXAcxOOA/VaGKLRisGNQbv5qrvdxlcVVhaa3e', 'Durgan', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:26:29.695832+00', '2026-06-28 19:26:29.695832+00');
INSERT INTO public.users VALUES ('4599d193-fd7c-41f4-9f70-b46c90c75b80', 'murazik@qatest.com', '$2a$12$YagyAimKKYfqQELX62iTzup9SIme.IL8gwZA9mQP7UJVrvwWBUblq', 'Lockman', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:26:31.261469+00', '2026-06-28 19:26:31.261469+00');
INSERT INTO public.users VALUES ('53d4806d-9b96-417a-bfaa-0b92abbe1493', 'kat@teste.com', '$2a$12$VPjHNq9.EskHAHoB8p.8nu2OeXAFZjYGpk7PCNaY9Ao8KqsRjCGpO', 'Kathleen Miranda', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 01:34:25.197045+00', '2026-06-28 01:34:25.197045+00');
INSERT INTO public.users VALUES ('ebca0723-3b51-4209-adcc-958ff292cb27', 'nigel@test.com', '$2a$12$HVI0a0v6QKm/zPE91FH6Sewbxzv7T1EMJU.LR8zYe2bAfJNl2Oj.i', 'Kristoffer', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 22:05:35.613655+00', '2026-06-28 22:05:35.613655+00');
INSERT INTO public.users VALUES ('84c06424-b316-47d7-856a-7ebb00fa0be6', 'corwin@test.com', '$2a$12$a/kNTDHIhJCg1hRPeBu6feXeIfRDdcVo1CR.v9aHcUauo9O0aes4C', 'Koss', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:28:38.95473+00', '2026-06-28 19:28:38.95473+00');
INSERT INTO public.users VALUES ('1dfed4b6-4040-498c-a78e-4ca5596d2123', 'welch@qatest.com', '$2a$12$JcgpD4Nyph8hSSJaUifIDOS0IN0amaEih4fsBZZuW2DzeLbChfyNy', 'Kozey', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:28:40.588868+00', '2026-06-28 19:28:40.588868+00');
INSERT INTO public.users VALUES ('a19aca54-0432-434b-ae06-88053db55382', 'goodwin@test.com', '$2a$12$JLRDxjJWcy9ncHABwAQBPeEVEmO2pirPN.Ng7xttCj0TUSO4n41gu', 'Padberg', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:28:59.10029+00', '2026-06-28 19:28:59.10029+00');
INSERT INTO public.users VALUES ('26457ddf-49b4-4035-bbb1-a23c92cf5c7e', 'boyer@qatest.com', '$2a$12$km5O12wilRCpyxQxH3K63eSXva/9e1dphPRX.PMNdQ.5i5AIQuiga', 'Beahan', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:29:00.775794+00', '2026-06-28 19:29:00.775794+00');
INSERT INTO public.users VALUES ('9a98ee38-14dd-418f-b5ef-414c38abea03', 'admin@qatest.com', '$2b$10$NeeTcnOEIkAEsvnsuSrT4eIaRZ1DP5D6vSB2ZjuCGUdoxVm07Xb1a', 'Admin QA', NULL, '(11) 98765-4321', NULL, NULL, true, 'admin', 'QATEST2025', '2026-06-29 22:53:11.515+00', true, NULL, '2025-11-22 19:13:30.023236+00', '2025-11-22 19:13:30.023236+00');
INSERT INTO public.users VALUES ('3b083dd4-adcb-4d89-85ad-c8cc657c35be', 'lea@test.com', '$2a$12$3TXba8LVTgE6GS9/KoFf8OKg8Ldta1o0BTtINstFeOeSBpY43LDFS', 'Delia', NULL, NULL, NULL, NULL, true, 'customer', NULL, NULL, false, NULL, '2026-06-28 19:30:26.742373+00', '2026-06-28 19:30:26.742373+00');


--
-- TOC entry 4040 (class 0 OID 19639)
-- Dependencies: 392
-- Data for Name: wishlists; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4065 (class 0 OID 0)
-- Dependencies: 369
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.addresses_id_seq', 3, true);


--
-- TOC entry 4066 (class 0 OID 0)
-- Dependencies: 393
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 13, true);


--
-- TOC entry 4067 (class 0 OID 0)
-- Dependencies: 371
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 643, true);


--
-- TOC entry 4068 (class 0 OID 0)
-- Dependencies: 379
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.coupons_id_seq', 3, true);


--
-- TOC entry 4069 (class 0 OID 0)
-- Dependencies: 367
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employees_id_seq', 1, false);


--
-- TOC entry 4070 (class 0 OID 0)
-- Dependencies: 397
-- Name: keepalive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.keepalive_id_seq', 80, true);


--
-- TOC entry 4071 (class 0 OID 0)
-- Dependencies: 385
-- Name: order_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_history_id_seq', 1, false);


--
-- TOC entry 4072 (class 0 OID 0)
-- Dependencies: 383
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 8, true);


--
-- TOC entry 4073 (class 0 OID 0)
-- Dependencies: 381
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 6, true);


--
-- TOC entry 4074 (class 0 OID 0)
-- Dependencies: 387
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 3, true);


--
-- TOC entry 4075 (class 0 OID 0)
-- Dependencies: 375
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 861, true);


--
-- TOC entry 4076 (class 0 OID 0)
-- Dependencies: 389
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reviews_id_seq', 3, true);


--
-- TOC entry 4077 (class 0 OID 0)
-- Dependencies: 377
-- Name: shippers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.shippers_id_seq', 3, true);


--
-- TOC entry 4078 (class 0 OID 0)
-- Dependencies: 373
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 1604, true);


--
-- TOC entry 4079 (class 0 OID 0)
-- Dependencies: 391
-- Name: wishlists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wishlists_id_seq', 3, true);


--
-- TOC entry 3769 (class 2606 OID 19393)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 3825 (class 2606 OID 19669)
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3827 (class 2606 OID 19671)
-- Name: cart_items cart_items_user_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_user_id_product_id_key UNIQUE (user_id, product_id);


--
-- TOC entry 3772 (class 2606 OID 19411)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 3774 (class 2606 OID 19413)
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- TOC entry 3794 (class 2606 OID 19497)
-- Name: coupons coupons_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT coupons_code_key UNIQUE (code);


--
-- TOC entry 3796 (class 2606 OID 19495)
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT coupons_pkey PRIMARY KEY (id);


--
-- TOC entry 3764 (class 2606 OID 19368)
-- Name: employees employees_employee_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_employee_code_key UNIQUE (employee_code);


--
-- TOC entry 3766 (class 2606 OID 19366)
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- TOC entry 3831 (class 2606 OID 48517)
-- Name: keepalive keepalive_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keepalive
    ADD CONSTRAINT keepalive_pkey PRIMARY KEY (id);


--
-- TOC entry 3811 (class 2606 OID 19575)
-- Name: order_history order_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_pkey PRIMARY KEY (id);


--
-- TOC entry 3808 (class 2606 OID 19553)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3802 (class 2606 OID 19515)
-- Name: orders orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_order_number_key UNIQUE (order_number);


--
-- TOC entry 3804 (class 2606 OID 19513)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 3814 (class 2606 OID 19600)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 3786 (class 2606 OID 19453)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 3788 (class 2606 OID 19457)
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- TOC entry 3790 (class 2606 OID 19455)
-- Name: products products_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_slug_key UNIQUE (slug);


--
-- TOC entry 3818 (class 2606 OID 19620)
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 3792 (class 2606 OID 19482)
-- Name: shippers shippers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shippers
    ADD CONSTRAINT shippers_pkey PRIMARY KEY (id);


--
-- TOC entry 3778 (class 2606 OID 19429)
-- Name: suppliers suppliers_cnpj_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_cnpj_key UNIQUE (cnpj);


--
-- TOC entry 3780 (class 2606 OID 19427)
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- TOC entry 3758 (class 2606 OID 19353)
-- Name: users users_cpf_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_cpf_key UNIQUE (cpf);


--
-- TOC entry 3760 (class 2606 OID 19351)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3762 (class 2606 OID 19349)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3821 (class 2606 OID 19647)
-- Name: wishlists wishlists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_pkey PRIMARY KEY (id);


--
-- TOC entry 3823 (class 2606 OID 19649)
-- Name: wishlists wishlists_user_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_product_id_key UNIQUE (user_id, product_id);


--
-- TOC entry 3770 (class 1259 OID 19399)
-- Name: idx_addresses_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_addresses_user ON public.addresses USING btree (user_id);


--
-- TOC entry 3828 (class 1259 OID 19683)
-- Name: idx_cart_items_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cart_items_product ON public.cart_items USING btree (product_id);


--
-- TOC entry 3829 (class 1259 OID 19682)
-- Name: idx_cart_items_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cart_items_user ON public.cart_items USING btree (user_id);


--
-- TOC entry 3775 (class 1259 OID 19414)
-- Name: idx_categories_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_categories_slug ON public.categories USING btree (slug);


--
-- TOC entry 3797 (class 1259 OID 19498)
-- Name: idx_coupons_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_coupons_code ON public.coupons USING btree (code);


--
-- TOC entry 3767 (class 1259 OID 19379)
-- Name: idx_employees_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_employees_user ON public.employees USING btree (user_id);


--
-- TOC entry 3809 (class 1259 OID 19586)
-- Name: idx_order_history_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_history_order ON public.order_history USING btree (order_id);


--
-- TOC entry 3805 (class 1259 OID 19564)
-- Name: idx_order_items_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_items_order ON public.order_items USING btree (order_id);


--
-- TOC entry 3806 (class 1259 OID 19565)
-- Name: idx_order_items_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_items_product ON public.order_items USING btree (product_id);


--
-- TOC entry 3798 (class 1259 OID 19543)
-- Name: idx_orders_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_number ON public.orders USING btree (order_number);


--
-- TOC entry 3799 (class 1259 OID 19542)
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_status ON public.orders USING btree (status);


--
-- TOC entry 3800 (class 1259 OID 19541)
-- Name: idx_orders_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_user ON public.orders USING btree (user_id);


--
-- TOC entry 3812 (class 1259 OID 19606)
-- Name: idx_payments_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_order ON public.payments USING btree (order_id);


--
-- TOC entry 3781 (class 1259 OID 19468)
-- Name: idx_products_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_category ON public.products USING btree (category_id);


--
-- TOC entry 3782 (class 1259 OID 19470)
-- Name: idx_products_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_sku ON public.products USING btree (sku);


--
-- TOC entry 3783 (class 1259 OID 19471)
-- Name: idx_products_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_slug ON public.products USING btree (slug);


--
-- TOC entry 3784 (class 1259 OID 19469)
-- Name: idx_products_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_supplier ON public.products USING btree (supplier_id);


--
-- TOC entry 3815 (class 1259 OID 19636)
-- Name: idx_reviews_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_product ON public.reviews USING btree (product_id);


--
-- TOC entry 3816 (class 1259 OID 19637)
-- Name: idx_reviews_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_user ON public.reviews USING btree (user_id);


--
-- TOC entry 3776 (class 1259 OID 19430)
-- Name: idx_suppliers_cnpj; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_suppliers_cnpj ON public.suppliers USING btree (cnpj);


--
-- TOC entry 3755 (class 1259 OID 19355)
-- Name: idx_users_cpf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_cpf ON public.users USING btree (cpf);


--
-- TOC entry 3756 (class 1259 OID 19354)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 3819 (class 1259 OID 19660)
-- Name: idx_wishlists_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wishlists_user ON public.wishlists USING btree (user_id);


--
-- TOC entry 3834 (class 2606 OID 19394)
-- Name: addresses addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3852 (class 2606 OID 19677)
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 3853 (class 2606 OID 19672)
-- Name: cart_items cart_items_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3832 (class 2606 OID 19374)
-- Name: employees employees_reports_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_reports_to_fkey FOREIGN KEY (reports_to) REFERENCES public.employees(id);


--
-- TOC entry 3833 (class 2606 OID 19369)
-- Name: employees employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3844 (class 2606 OID 19581)
-- Name: order_history order_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- TOC entry 3845 (class 2606 OID 19576)
-- Name: order_history order_history_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 3842 (class 2606 OID 19554)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 3843 (class 2606 OID 19559)
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 3837 (class 2606 OID 19536)
-- Name: orders orders_billing_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_billing_address_id_fkey FOREIGN KEY (billing_address_id) REFERENCES public.addresses(id);


--
-- TOC entry 3838 (class 2606 OID 19521)
-- Name: orders orders_coupon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_coupon_id_fkey FOREIGN KEY (coupon_id) REFERENCES public.coupons(id);


--
-- TOC entry 3839 (class 2606 OID 19526)
-- Name: orders orders_shipper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_shipper_id_fkey FOREIGN KEY (shipper_id) REFERENCES public.shippers(id);


--
-- TOC entry 3840 (class 2606 OID 19531)
-- Name: orders orders_shipping_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_shipping_address_id_fkey FOREIGN KEY (shipping_address_id) REFERENCES public.addresses(id);


--
-- TOC entry 3841 (class 2606 OID 19516)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3846 (class 2606 OID 19601)
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 3835 (class 2606 OID 19458)
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- TOC entry 3836 (class 2606 OID 19463)
-- Name: products products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- TOC entry 3847 (class 2606 OID 19631)
-- Name: reviews reviews_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- TOC entry 3848 (class 2606 OID 19621)
-- Name: reviews reviews_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 3849 (class 2606 OID 19626)
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3850 (class 2606 OID 19655)
-- Name: wishlists wishlists_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 3851 (class 2606 OID 19650)
-- Name: wishlists wishlists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4009 (class 3256 OID 26557)
-- Name: products Cadastrar_produtos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Cadastrar_produtos" ON public.products FOR INSERT WITH CHECK (true);


--
-- TOC entry 4011 (class 3256 OID 26560)
-- Name: products Editar Produtos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Editar Produtos" ON public.products FOR DELETE USING (true);


--
-- TOC entry 4010 (class 3256 OID 26558)
-- Name: products Excluir Produtos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Excluir Produtos" ON public.products FOR DELETE TO authenticated USING (true);


--
-- TOC entry 4008 (class 3256 OID 26556)
-- Name: products Listar_Produtos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Listar_Produtos" ON public.products FOR SELECT USING (true);


--
-- TOC entry 4012 (class 3256 OID 49652)
-- Name: keepalive allow_keepalive_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_keepalive_insert ON public.keepalive FOR INSERT TO service_role WITH CHECK (true);


--
-- TOC entry 4006 (class 0 OID 19662)
-- Dependencies: 394
-- Name: cart_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4007 (class 0 OID 48513)
-- Dependencies: 396
-- Name: keepalive; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.keepalive ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4005 (class 0 OID 19545)
-- Dependencies: 384
-- Name: order_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4004 (class 0 OID 19500)
-- Dependencies: 382
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4002 (class 0 OID 19432)
-- Dependencies: 376
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4003 (class 0 OID 19473)
-- Dependencies: 378
-- Name: shippers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.shippers ENABLE ROW LEVEL SECURITY;

-- Completed on 2026-06-30 08:50:51

--
-- PostgreSQL database dump complete
--

\unrestrict p2OU1l1nkDYlvrUIcvxyeZiSnPoHjsTHd3Jbc957XdB7JLP0STZCoXdt1xMZ9es

