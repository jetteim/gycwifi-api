--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: social_provider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE social_provider AS ENUM (
    'password',
    'google_oauth2',
    'vk',
    'facebook',
    'twitter',
    'instagram',
    'odnoklassniki'
);


--
-- Name: amocrmexport(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION amocrmexport(userid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$declare
        amocrm varchar := e'﻿Email, Name, Phone
';
        line varchar;
        users cursor for select role_cd = 3 as isadmin from users where id = userid;
        isadmin boolean;
        clients cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name,coalesce(phone_number,'') as phone from clients join social_accounts on clients.id = social_accounts.client_id where not (clients.phone_number is null and social_accounts.email is null);
        clients_filtered cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name,coalesce(phone_number,'') as phone from clients join social_accounts on clients.id = social_accounts.client_id where not (clients.phone_number is null and social_accounts.email is null) and social_accounts.id in (select social_account_id from social_logs where location_id in (select id from locations where user_id = userid));
      begin
        open users; fetch users into isadmin;
        if isadmin then
          for client in clients loop
      	    line = format('%s, %s, %s',client.email,client.name,client.phone);
            --raise notice 'result=%', line;
      	    amocrm = amocrm || line || e'
';
      	  end loop;
        else
          for client in clients_filtered loop
      	    line = format('%s, %s, %s',client.email,client.name,client.phone);
            --raise notice 'result=%', line;
      	    amocrm = amocrm || line || e'
';
      	  end loop;
        end if;
        return amocrm;
      end;$$;


--
-- Name: clients_page(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION clients_page(userid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$declare
        clients_page varchar;
        line varchar;
        users cursor for select role_cd = 3 as isadmin from users where id = userid; isadmin boolean;
        clients cursor for select distinct id, phone_number from clients where not phone_number is null;
        clients_filtered cursor for select distinct clients.id, clients.phone_number from clients join social_accounts on clients.id = social_accounts.client_id where not (clients.phone_number is null) and social_accounts.id in (select social_account_id from social_logs where location_id in (select id from locations where user_id = userid));
        clientid integer;
        client_updated cursor for select max(updated_at) from social_accounts where client_id = clientid; updatedat timestamp;
        social_accounts_image cursor for select image from social_accounts where client_id = clientid and not image is null order by updated_at desc LIMIT 1; clientimage varchar;
        social_accounts_username cursor for select username from social_accounts where client_id = clientid and not username is null order by updated_at desc LIMIT 1; clientusername varchar;
        social_accounts_email cursor for select email from social_accounts where client_id = clientid and not email is null order by updated_at desc LIMIT 1; clientemail varchar;
        social_accounts_gender cursor for select gender from social_accounts where client_id = clientid and not gender is null order by updated_at desc LIMIT 1; clientgender varchar;
        social_accounts_provider cursor for select provider from social_accounts where client_id = clientid and not provider is null order by updated_at desc LIMIT 1; clientprovider varchar;
        social_accounts_profile cursor for select profile from social_accounts where client_id = clientid and not profile is null order by updated_at desc LIMIT 1; clientprofile varchar;
        social_accounts_visits cursor for select count(id) as visits from social_logs where social_account_id in (select id from social_accounts where client_id = clientid); clientvisits integer; visits integer;
        social_accounts_visits_30 cursor for select count(id) as visits30 from social_logs where social_account_id in (select id from social_accounts where client_id = clientid) and created_at > current_date - interval '30 days'; clientvisits30 integer; visits30 integer;

      begin
	    open users; fetch users into isadmin;close users;
	    clients_page = '';
        if isadmin then
          for client in clients loop
      	    execute pg_sleep(0.01);
      	    clientid = client.id;
      	    select image into clientimage from social_accounts where client_id = clientid and not image is null order by updated_at desc LIMIT 1;
      	    select max(updated_at) into updatedat from social_accounts where client_id = clientid;
      	    select username into clientusername from social_accounts where client_id = clientid and not username is null order by updated_at desc LIMIT 1;
            select email into clientemail from social_accounts where client_id = clientid and not email is null order by updated_at desc LIMIT 1;
            select gender into clientgender from social_accounts where client_id = clientid and not gender is null order by updated_at desc LIMIT 1;
            select provider into clientprovider from social_accounts where client_id = clientid and not provider is null order by updated_at desc LIMIT 1;
            select profile into clientprofile from social_accounts where client_id = clientid and not profile is null order by updated_at desc LIMIT 1;
            select count(id) into visits from social_logs where social_account_id in (select id from social_accounts where client_id = clientid);
            select count(id) into visits30 from social_logs where social_account_id in (select id from social_accounts where client_id = clientid) and created_at > current_date - interval '30 days';
            line = format('{"image": "%s", "phone_number": "%s", "email": "%s", "username": "%s", "visits": "%s", "visits30": "%s", "updated_at": "%s", "gender": "%s", "provider": "%s", "profile": "%s"}',
              clientimage,
              client.phone_number,
              clientemail,
              clientusername,
              to_char(visits, '00000'),
              to_char(visits30, '00000'),
              updatedat::date,
              clientgender,
              clientprovider,
              clientprofile
            );
            --raise notice 'line=%', line;
            clients_page = clients_page || line || ', ';
            --raise notice 'result=%', clients_page;
      	  end loop;
        else
          for client in clients_filtered loop
      	    execute pg_sleep(0.01);
            clientid = client.id;
      	    select image into clientimage from social_accounts where client_id = clientid and not image is null order by updated_at desc LIMIT 1;
      	    select max(updated_at) into updatedat from social_accounts where client_id = clientid;
      	    select username into clientusername from social_accounts where client_id = clientid and not username is null order by updated_at desc LIMIT 1;
            select email into clientemail from social_accounts where client_id = clientid and not email is null order by updated_at desc LIMIT 1;
            select gender into clientgender from social_accounts where client_id = clientid and not gender is null order by updated_at desc LIMIT 1;
            select provider into clientprovider from social_accounts where client_id = clientid and not provider is null order by updated_at desc LIMIT 1;
            select profile into clientprofile from social_accounts where client_id = clientid and not profile is null order by updated_at desc LIMIT 1;
            select count(id) into visits from social_logs where social_account_id in (select id from social_accounts where client_id = clientid);
            select count(id) into visits30 from social_logs where social_account_id in (select id from social_accounts where client_id = clientid) and created_at > current_date - interval '30 days';
            line = format('{"image": "%s", "phone_number": "%s", "email": "%s", "username": "%s", "visits": "%s", "visits30": "%s", "updated_at": "%s", "gender": "%s", "provider": "%s", "profile": "%s"}',
              clientimage,
              client.phone_number,
              clientemail,
              clientusername,
              to_char(visits, '00000'),
              to_char(visits30, '00000'),
              updatedat::date,
              clientgender,
              clientprovider,
              clientprofile
            );
            --raise notice 'line=%', line;
            clients_page = clients_page || line || ', ';
            --raise notice 'result=%', clients_page;
      	  end loop;
        end if;
        return clients_page;
      end;$$;


--
-- Name: date_round(timestamp with time zone, interval); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION date_round(base_date timestamp with time zone, round_interval interval) RETURNS timestamp with time zone
    LANGUAGE sql STABLE
    AS $_$
SELECT TO_TIMESTAMP((EXTRACT(epoch FROM $1)::INTEGER + EXTRACT(epoch FROM $2)::INTEGER / 2)
                / EXTRACT(epoch FROM $2)::INTEGER * EXTRACT(epoch FROM $2)::INTEGER)
$_$;


--
-- Name: mailchimpexport(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION mailchimpexport(userid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$declare
        mailchimp varchar := e'﻿Email, Name
';
        line varchar;
        users cursor for select role_cd = 3 as isadmin from users where id = userid;
        isadmin boolean;
        social_accounts cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name from social_accounts where not (social_accounts.email is null);
        social_accounts_filtered cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name from social_accounts where not (social_accounts.email is null) and social_accounts.id in (select social_account_id from social_logs where location_id in (select id from locations where user_id = userid));
      begin
        open users; fetch users into isadmin;
        if isadmin then
          for client in social_accounts loop
      	    line = format('%s, %s',client.email,client.name);
            --raise notice 'result=%', line;
      	    mailchimp = mailchimp || line || e'
';
      	  end loop;
        else
          for client in social_accounts_filtered loop
      	    line = format('%s, %s',client.email,client.name);
            --raise notice 'result=%', line;
      	    mailchimp = mailchimp || line || e'
';
      	  end loop;
        end if;
        return mailchimp;
      end;$$;


--
-- Name: refresh_statistics(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION refresh_statistics(userid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$declare
      fusers cursor for select id from users;
      viewname varchar;
    begin
    	execute 'refresh materialized view CONCURRENTLY clients_pages';
    	return '';
    end;$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agent_payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_payment_methods (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agent_payment_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_payment_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_payment_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_payment_methods_id_seq OWNED BY agent_payment_methods.id;


--
-- Name: agent_reward_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_reward_statuses (
    id integer NOT NULL,
    code character varying NOT NULL,
    agent_reward_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agent_reward_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_reward_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_reward_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_reward_statuses_id_seq OWNED BY agent_reward_statuses.id;


--
-- Name: agent_rewards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_rewards (
    id integer NOT NULL,
    agent_id integer NOT NULL,
    order_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agent_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_rewards_id_seq OWNED BY agent_rewards.id;


--
-- Name: agents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agents (
    id integer NOT NULL,
    user_id integer NOT NULL,
    agent_payment_method_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agents_id_seq OWNED BY agents.id;


--
-- Name: answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE answers (
    id integer NOT NULL,
    title character varying,
    question_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    custom boolean DEFAULT false
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE attempts (
    id integer NOT NULL,
    client_id integer,
    answer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    custom_answer character varying,
    interview_uuid integer
);


--
-- Name: attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attempts_id_seq OWNED BY attempts.id;


--
-- Name: auth_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE auth_logs (
    id integer NOT NULL,
    username character varying,
    password character varying,
    timeout integer,
    client_device_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    voucher_id integer
);


--
-- Name: auth_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE auth_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE auth_logs_id_seq OWNED BY auth_logs.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bans (
    id integer NOT NULL,
    until_date timestamp without time zone,
    location_id integer,
    client_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bans_id_seq OWNED BY bans.id;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE brands (
    id integer NOT NULL,
    title character varying DEFAULT 'GYC Free WiFi'::character varying NOT NULL,
    logo character varying DEFAULT '/images/logo.png'::character varying,
    bg_color character varying DEFAULT '#0e1a35'::character varying,
    background character varying DEFAULT '/images/default_background.png'::character varying,
    redirect_url character varying DEFAULT 'https://gycwifi.com'::character varying,
    auth_expiration_time integer DEFAULT 3600 NOT NULL,
    category_id integer NOT NULL,
    promo_text text DEFAULT 'Sample promo text'::text,
    slug character varying NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sms_auth boolean,
    template character varying DEFAULT 'default'::character varying,
    public boolean DEFAULT false,
    layout_id integer DEFAULT 1
);


--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brands_id_seq OWNED BY brands.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    title_en character varying,
    title_ru character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: client_accounting_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_accounting_logs (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    acctsessionid character varying,
    acctuniqueid character varying,
    username character varying,
    groupname character varying,
    realm character varying,
    nasipaddress character varying,
    nasportid character varying,
    nasporttype character varying,
    acctstarttime timestamp without time zone,
    acctstoptime timestamp without time zone,
    acctsessiontime bigint,
    acctauthentic character varying,
    connectinfo_start character varying,
    connectinfo_stop character varying,
    acctinputoctets bigint,
    acctoutputoctets bigint,
    calledstationid character varying,
    callingstationid character varying,
    acctterminatecause character varying,
    servicetype character varying,
    xascendsessionsvrkey character varying,
    framedprotocol character varying,
    framedipaddress character varying,
    acctstartdelay integer,
    acctstopdelay integer
);


--
-- Name: client_accounting_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_accounting_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_accounting_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_accounting_logs_id_seq OWNED BY client_accounting_logs.id;


--
-- Name: client_counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_counters (
    id integer NOT NULL,
    client_id integer,
    location_id integer,
    counter integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: client_counters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_counters_id_seq OWNED BY client_counters.id;


--
-- Name: client_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_devices (
    id integer NOT NULL,
    mac character varying,
    platform_os character varying,
    platform_product character varying,
    client_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: client_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_devices_id_seq OWNED BY client_devices.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE clients (
    id integer NOT NULL,
    phone_number character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: social_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE social_accounts (
    id integer NOT NULL,
    provider social_provider,
    uid character varying,
    vaucher character varying,
    username character varying,
    image character varying,
    profile character varying,
    email character varying,
    gender character varying,
    location character varying,
    bdate_day integer,
    bdate_month integer,
    bdate_year integer,
    client_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: social_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE social_logs (
    id integer NOT NULL,
    social_account_id integer,
    provider character varying,
    location_id integer,
    router_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: client_visits; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW client_visits AS
 SELECT social_logs.location_id,
    clients.id AS client_id,
    clients.phone_number,
    count(social_accounts.client_id) AS visits,
    max(social_logs.updated_at) AS updated_at
   FROM ((social_logs
     JOIN social_accounts ON ((social_logs.social_account_id = social_accounts.id)))
     JOIN clients ON ((social_accounts.client_id = clients.id)))
  WHERE (NOT (clients.phone_number IS NULL))
  GROUP BY social_logs.location_id, clients.id, clients.phone_number;


--
-- Name: clients_accounting; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW clients_accounting AS
 SELECT client_accounting_logs.callingstationid AS mac,
    client_accounting_logs.username,
    client_accounting_logs.nasipaddress AS ip_name,
    client_accounting_logs.created_at,
    client_accounting_logs.acctstoptime AS last_seen,
    sum(client_accounting_logs.acctsessiontime) AS total_time,
    sum(client_accounting_logs.acctinputoctets) AS outgoing_bytes,
    sum(client_accounting_logs.acctoutputoctets) AS incoming_bytes
   FROM client_accounting_logs
  GROUP BY client_accounting_logs.callingstationid, client_accounting_logs.username, client_accounting_logs.nasipaddress, client_accounting_logs.created_at, client_accounting_logs.acctstoptime;


--
-- Name: clients_accounting_data; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW clients_accounting_data AS
 SELECT client_accounting_logs.callingstationid AS mac,
    client_accounting_logs.username,
    client_accounting_logs.nasipaddress AS ip_name,
    client_accounting_logs.created_at,
    client_accounting_logs.acctstoptime AS last_seen,
    sum(client_accounting_logs.acctsessiontime) AS total_time,
    sum(client_accounting_logs.acctinputoctets) AS outgoing_bytes,
    sum(client_accounting_logs.acctoutputoctets) AS incoming_bytes
   FROM client_accounting_logs
  GROUP BY client_accounting_logs.callingstationid, client_accounting_logs.username, client_accounting_logs.nasipaddress, client_accounting_logs.created_at, client_accounting_logs.acctstoptime;


--
-- Name: clients_accounting_report; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW clients_accounting_report AS
 SELECT clients_accounting.mac,
    clients_accounting.ip_name,
    max(clients_accounting.created_at) AS last_login,
    max(clients_accounting.last_seen) AS last_logout,
    sum(clients_accounting.total_time) AS total_time,
    sum(clients_accounting.outgoing_bytes) AS outgoing_bytes,
    sum(clients_accounting.incoming_bytes) AS incoming_bytes
   FROM clients_accounting
  GROUP BY clients_accounting.mac, clients_accounting.ip_name;


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clients_id_seq OWNED BY clients.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    avatar character varying DEFAULT '/images/avatars/default.jpg'::character varying,
    type character varying DEFAULT 'FreeUser'::character varying NOT NULL,
    tour boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lang character varying DEFAULT 'ru'::character varying,
    sms_count integer,
    user_id integer DEFAULT 274,
    expiration timestamp without time zone DEFAULT '2017-06-05 06:29:47.639813'::timestamp without time zone,
    promo_code_id integer
);


--
-- Name: clients_pages; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW clients_pages AS
 SELECT users.id,
    users.id AS user_id,
    clients_page(users.id) AS clients_page
   FROM users
  WITH NO DATA;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: device_auth_pendings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE device_auth_pendings (
    id integer NOT NULL,
    mac character varying,
    phone character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sms_code character varying
);


--
-- Name: device_auth_pending_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE device_auth_pending_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device_auth_pending_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE device_auth_pending_id_seq OWNED BY device_auth_pendings.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friendly_id_slugs (
    id integer NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: layouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE layouts (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    local_path character varying
);


--
-- Name: layouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE layouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: layouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE layouts_id_seq OWNED BY layouts.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE locations (
    id integer NOT NULL,
    title character varying NOT NULL,
    phone character varying,
    address character varying,
    url character varying DEFAULT 'https://gycwifi.com'::character varying,
    ssid character varying NOT NULL,
    staff_ssid character varying,
    staff_ssid_pass character varying,
    redirect_url character varying DEFAULT 'https://gycwifi.com'::character varying NOT NULL,
    wlan character varying DEFAULT '1M'::character varying NOT NULL,
    wan character varying DEFAULT '5M'::character varying NOT NULL,
    auth_expiration_time integer DEFAULT 3600 NOT NULL,
    promo_text text DEFAULT 'Спасибо за то, что заглянули к нам!'::text NOT NULL,
    logo character varying DEFAULT '/images/logo.png'::character varying,
    bg_color character varying DEFAULT '#0e1a35'::character varying,
    background character varying DEFAULT '/images/default_background.png'::character varying,
    password boolean DEFAULT false NOT NULL,
    twitter boolean DEFAULT false NOT NULL,
    google boolean DEFAULT false NOT NULL,
    vk boolean DEFAULT false NOT NULL,
    insta boolean DEFAULT false NOT NULL,
    facebook boolean DEFAULT false NOT NULL,
    slug character varying NOT NULL,
    brand_id integer NOT NULL,
    category_id integer DEFAULT 24 NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    poll_id integer,
    promo_type character varying DEFAULT 'text'::character varying,
    last_page_content character varying DEFAULT 'text'::character varying NOT NULL,
    sms_auth boolean,
    sms_count integer,
    voucher boolean DEFAULT true
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: login_menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE login_menu_items (
    id integer NOT NULL,
    url character varying,
    title_ru character varying,
    title_en character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    location_id integer
);


--
-- Name: login_menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE login_menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: login_menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE login_menu_items_id_seq OWNED BY login_menu_items.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE notifications (
    id integer NOT NULL,
    sent_at timestamp without time zone,
    router_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    location_id integer,
    poll_id integer,
    title character varying,
    details character varying,
    seen boolean DEFAULT false,
    tour_last_run timestamp without time zone,
    silence boolean DEFAULT false,
    favorite boolean DEFAULT false
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: opinions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE opinions (
    id integer NOT NULL,
    style character varying,
    message text,
    location character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: opinions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE opinions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opinions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE opinions_id_seq OWNED BY opinions.id;


--
-- Name: order_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE order_products (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    price numeric(8,2) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: order_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE order_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE order_products_id_seq OWNED BY order_products.id;


--
-- Name: order_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE order_statuses (
    id integer NOT NULL,
    code_cd integer NOT NULL,
    order_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: order_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE order_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE order_statuses_id_seq OWNED BY order_statuses.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE orders (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pages (
    id integer NOT NULL,
    title character varying,
    content text,
    category character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: polls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE polls (
    id integer NOT NULL,
    title character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    run_once boolean DEFAULT true
);


--
-- Name: polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE polls_id_seq OWNED BY polls.id;


--
-- Name: post_auth_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_auth_logs (
    id integer NOT NULL,
    username character varying,
    passsword character varying,
    reply character varying,
    calledstationid character varying,
    callingstationid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_auth_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_auth_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_auth_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_auth_logs_id_seq OWNED BY post_auth_logs.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE products (
    id integer NOT NULL,
    name character varying,
    description text,
    price integer,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: promo_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE promo_codes (
    id integer NOT NULL,
    code character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    agent_id integer
);


--
-- Name: promo_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE promo_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promo_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE promo_codes_id_seq OWNED BY promo_codes.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE questions (
    id integer NOT NULL,
    title character varying,
    question_type character varying,
    poll_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questions_id_seq OWNED BY questions.id;


--
-- Name: routers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE routers (
    id integer NOT NULL,
    serial character varying,
    comment character varying,
    first_dns_server character varying DEFAULT '8.8.8.8'::character varying,
    second_dns_server character varying DEFAULT '8.8.4.4'::character varying,
    common_name character varying,
    ip_name character varying,
    router_local_ip character varying DEFAULT '192.168.88.1'::character varying,
    disable_service_access boolean DEFAULT true,
    split_networks boolean DEFAULT true,
    isolate_wlan boolean DEFAULT true,
    block_service_ports boolean DEFAULT true,
    admin_ethernet_port character varying DEFAULT 'ether5'::character varying,
    router_admin_ip character varying DEFAULT '192.168.10.1'::character varying,
    admin_password character varying DEFAULT 'admin'::character varying,
    radius_secret character varying,
    ssl_certificate text,
    ssl_key text,
    radius_db_nas_id character varying,
    status boolean,
    location_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    config_type character varying,
    hotspot_interface character varying,
    hotspot_address character varying
);


--
-- Name: routers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE routers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE routers_id_seq OWNED BY routers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: sms_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sms_logs (
    id integer NOT NULL,
    sms_code character varying,
    sent_at timestamp without time zone,
    status_cd integer,
    client_device_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    location_id integer
);


--
-- Name: sms_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sms_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sms_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sms_logs_id_seq OWNED BY sms_logs.id;


--
-- Name: social_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE social_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE social_accounts_id_seq OWNED BY social_accounts.id;


--
-- Name: social_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE social_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE social_logs_id_seq OWNED BY social_logs.id;


--
-- Name: traffic_data; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW traffic_data AS
 SELECT client_accounting_logs.callingstationid AS mac,
    client_accounting_logs.username,
    client_accounting_logs.nasipaddress AS ip_name,
    client_accounting_logs.created_at,
    client_accounting_logs.acctstoptime AS last_seen,
    sum(client_accounting_logs.acctsessiontime) AS total_time,
    sum(client_accounting_logs.acctinputoctets) AS outgoing_bytes,
    sum(client_accounting_logs.acctoutputoctets) AS incoming_bytes
   FROM client_accounting_logs
  WHERE (NOT (client_accounting_logs.connectinfo_stop IS NULL))
  GROUP BY client_accounting_logs.callingstationid, client_accounting_logs.username, client_accounting_logs.nasipaddress, client_accounting_logs.created_at, client_accounting_logs.acctstoptime;


--
-- Name: traffic_report; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW traffic_report AS
 SELECT traffic_data.mac,
    traffic_data.ip_name,
    max(traffic_data.created_at) AS last_login,
    max(traffic_data.last_seen) AS last_logout,
    sum(traffic_data.total_time) AS total_time,
    sum(traffic_data.outgoing_bytes) AS outgoing_bytes,
    sum(traffic_data.incoming_bytes) AS incoming_bytes
   FROM traffic_data
  GROUP BY traffic_data.mac, traffic_data.ip_name;


--
-- Name: traffic_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW traffic_reports AS
 SELECT traffic_data.mac,
    traffic_data.ip_name,
    max(traffic_data.created_at) AS last_login,
    max(traffic_data.last_seen) AS last_logout,
    sum(traffic_data.total_time) AS total_time,
    sum(traffic_data.outgoing_bytes) AS outgoing_bytes,
    sum(traffic_data.incoming_bytes) AS incoming_bytes
   FROM traffic_data
  GROUP BY traffic_data.mac, traffic_data.ip_name;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vips (
    id integer NOT NULL,
    phone character varying,
    location_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vips_id_seq OWNED BY vips.id;


--
-- Name: vouchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vouchers (
    id integer NOT NULL,
    location_id integer,
    password character varying,
    expiration timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_id integer,
    duration integer DEFAULT 0
);


--
-- Name: vouchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vouchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vouchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vouchers_id_seq OWNED BY vouchers.id;


--
-- Name: agent_payment_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_payment_methods ALTER COLUMN id SET DEFAULT nextval('agent_payment_methods_id_seq'::regclass);


--
-- Name: agent_reward_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_reward_statuses ALTER COLUMN id SET DEFAULT nextval('agent_reward_statuses_id_seq'::regclass);


--
-- Name: agent_rewards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_rewards ALTER COLUMN id SET DEFAULT nextval('agent_rewards_id_seq'::regclass);


--
-- Name: agents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agents ALTER COLUMN id SET DEFAULT nextval('agents_id_seq'::regclass);


--
-- Name: answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attempts ALTER COLUMN id SET DEFAULT nextval('attempts_id_seq'::regclass);


--
-- Name: auth_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_logs ALTER COLUMN id SET DEFAULT nextval('auth_logs_id_seq'::regclass);


--
-- Name: bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bans ALTER COLUMN id SET DEFAULT nextval('bans_id_seq'::regclass);


--
-- Name: brands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands ALTER COLUMN id SET DEFAULT nextval('brands_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: client_accounting_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_accounting_logs ALTER COLUMN id SET DEFAULT nextval('client_accounting_logs_id_seq'::regclass);


--
-- Name: client_counters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_counters ALTER COLUMN id SET DEFAULT nextval('client_counters_id_seq'::regclass);


--
-- Name: client_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_devices ALTER COLUMN id SET DEFAULT nextval('client_devices_id_seq'::regclass);


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clients ALTER COLUMN id SET DEFAULT nextval('clients_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: device_auth_pendings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY device_auth_pendings ALTER COLUMN id SET DEFAULT nextval('device_auth_pending_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: layouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY layouts ALTER COLUMN id SET DEFAULT nextval('layouts_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: login_menu_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY login_menu_items ALTER COLUMN id SET DEFAULT nextval('login_menu_items_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: opinions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY opinions ALTER COLUMN id SET DEFAULT nextval('opinions_id_seq'::regclass);


--
-- Name: order_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_products ALTER COLUMN id SET DEFAULT nextval('order_products_id_seq'::regclass);


--
-- Name: order_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_statuses ALTER COLUMN id SET DEFAULT nextval('order_statuses_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: polls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY polls ALTER COLUMN id SET DEFAULT nextval('polls_id_seq'::regclass);


--
-- Name: post_auth_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_auth_logs ALTER COLUMN id SET DEFAULT nextval('post_auth_logs_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: promo_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY promo_codes ALTER COLUMN id SET DEFAULT nextval('promo_codes_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


--
-- Name: routers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY routers ALTER COLUMN id SET DEFAULT nextval('routers_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: sms_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sms_logs ALTER COLUMN id SET DEFAULT nextval('sms_logs_id_seq'::regclass);


--
-- Name: social_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_accounts ALTER COLUMN id SET DEFAULT nextval('social_accounts_id_seq'::regclass);


--
-- Name: social_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_logs ALTER COLUMN id SET DEFAULT nextval('social_logs_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: vips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vips ALTER COLUMN id SET DEFAULT nextval('vips_id_seq'::regclass);


--
-- Name: vouchers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers ALTER COLUMN id SET DEFAULT nextval('vouchers_id_seq'::regclass);


--
-- Name: agent_payment_methods agent_payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_payment_methods
    ADD CONSTRAINT agent_payment_methods_pkey PRIMARY KEY (id);


--
-- Name: agent_reward_statuses agent_reward_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_reward_statuses
    ADD CONSTRAINT agent_reward_statuses_pkey PRIMARY KEY (id);


--
-- Name: agent_rewards agent_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_rewards
    ADD CONSTRAINT agent_rewards_pkey PRIMARY KEY (id);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- Name: answers answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: attempts attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attempts
    ADD CONSTRAINT attempts_pkey PRIMARY KEY (id);


--
-- Name: auth_logs auth_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_logs
    ADD CONSTRAINT auth_logs_pkey PRIMARY KEY (id);


--
-- Name: bans bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: client_accounting_logs client_accounting_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_accounting_logs
    ADD CONSTRAINT client_accounting_logs_pkey PRIMARY KEY (id);


--
-- Name: client_counters client_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_counters
    ADD CONSTRAINT client_counters_pkey PRIMARY KEY (id);


--
-- Name: client_devices client_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_devices
    ADD CONSTRAINT client_devices_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: device_auth_pendings device_auth_pending_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY device_auth_pendings
    ADD CONSTRAINT device_auth_pending_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: layouts layouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY layouts
    ADD CONSTRAINT layouts_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: login_menu_items login_menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY login_menu_items
    ADD CONSTRAINT login_menu_items_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: opinions opinions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opinions
    ADD CONSTRAINT opinions_pkey PRIMARY KEY (id);


--
-- Name: order_products order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_products
    ADD CONSTRAINT order_products_pkey PRIMARY KEY (id);


--
-- Name: order_statuses order_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_statuses
    ADD CONSTRAINT order_statuses_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: post_auth_logs post_auth_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_auth_logs
    ADD CONSTRAINT post_auth_logs_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: promo_codes promo_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY promo_codes
    ADD CONSTRAINT promo_codes_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: routers routers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY routers
    ADD CONSTRAINT routers_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sms_logs sms_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sms_logs
    ADD CONSTRAINT sms_logs_pkey PRIMARY KEY (id);


--
-- Name: social_accounts social_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_accounts
    ADD CONSTRAINT social_accounts_pkey PRIMARY KEY (id);


--
-- Name: social_logs social_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_logs
    ADD CONSTRAINT social_logs_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vips vips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vips
    ADD CONSTRAINT vips_pkey PRIMARY KEY (id);


--
-- Name: vouchers vouchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT vouchers_pkey PRIMARY KEY (id);


--
-- Name: clients_pages_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX clients_pages_id ON clients_pages USING btree (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: delayed_jobs_queue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_queue ON delayed_jobs USING btree (queue);


--
-- Name: index_agent_reward_statuses_on_agent_reward_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_reward_statuses_on_agent_reward_id ON agent_reward_statuses USING btree (agent_reward_id);


--
-- Name: index_agent_rewards_on_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_rewards_on_agent_id ON agent_rewards USING btree (agent_id);


--
-- Name: index_agent_rewards_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_rewards_on_order_id ON agent_rewards USING btree (order_id);


--
-- Name: index_agents_on_agent_payment_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agents_on_agent_payment_method_id ON agents USING btree (agent_payment_method_id);


--
-- Name: index_agents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agents_on_user_id ON agents USING btree (user_id);


--
-- Name: index_answers_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answers_on_question_id ON answers USING btree (question_id);


--
-- Name: index_attempts_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attempts_on_answer_id ON attempts USING btree (answer_id);


--
-- Name: index_attempts_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attempts_on_client_id ON attempts USING btree (client_id);


--
-- Name: index_auth_logs_on_cleint_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_logs_on_cleint_device_id ON auth_logs USING btree (client_device_id);


--
-- Name: index_auth_logs_on_password; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_logs_on_password ON auth_logs USING btree (password);


--
-- Name: index_auth_logs_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_logs_on_username ON auth_logs USING btree (username);


--
-- Name: index_auth_logs_on_voucher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_logs_on_voucher_id ON auth_logs USING btree (voucher_id);


--
-- Name: index_bans_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_client_id ON bans USING btree (client_id);


--
-- Name: index_bans_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_location_id ON bans USING btree (location_id);


--
-- Name: index_brands_on_layout_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_brands_on_layout_id ON brands USING btree (layout_id);


--
-- Name: index_brands_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_brands_on_slug ON brands USING btree (slug);


--
-- Name: index_brands_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_brands_on_user_id ON brands USING btree (user_id);


--
-- Name: index_client_accounting_logs_on_acctstarttime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_acctstarttime ON client_accounting_logs USING btree (acctstarttime);


--
-- Name: index_client_accounting_logs_on_acctstoptime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_acctstoptime ON client_accounting_logs USING btree (acctstoptime);


--
-- Name: index_client_accounting_logs_on_calledstationid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_calledstationid ON client_accounting_logs USING btree (calledstationid);


--
-- Name: index_client_accounting_logs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_created_at ON client_accounting_logs USING btree (created_at);


--
-- Name: index_client_accounting_logs_on_nasipaddress; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_nasipaddress ON client_accounting_logs USING btree (nasipaddress);


--
-- Name: index_client_accounting_logs_on_nasportid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_nasportid ON client_accounting_logs USING btree (nasportid);


--
-- Name: index_client_accounting_logs_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_updated_at ON client_accounting_logs USING btree (updated_at);


--
-- Name: index_client_accounting_logs_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_accounting_logs_on_username ON client_accounting_logs USING btree (username);


--
-- Name: index_client_counters_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_counters_on_client_id ON client_counters USING btree (client_id);


--
-- Name: index_client_counters_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_counters_on_created_at ON client_counters USING btree (created_at);


--
-- Name: index_client_counters_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_counters_on_location_id ON client_counters USING btree (location_id);


--
-- Name: index_client_counters_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_counters_on_updated_at ON client_counters USING btree (updated_at);


--
-- Name: index_client_devices_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_devices_on_client_id ON client_devices USING btree (client_id);


--
-- Name: index_client_devices_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_devices_on_created_at ON client_devices USING btree (created_at);


--
-- Name: index_client_devices_on_mac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_devices_on_mac ON client_devices USING btree (mac);


--
-- Name: index_client_devices_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_devices_on_updated_at ON client_devices USING btree (updated_at);


--
-- Name: index_clients_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_created_at ON clients USING btree (created_at);


--
-- Name: index_clients_on_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_clients_on_phone_number ON clients USING btree (phone_number);


--
-- Name: index_clients_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_updated_at ON clients USING btree (updated_at);


--
-- Name: index_device_auth_pending_on_mac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_device_auth_pending_on_mac ON device_auth_pendings USING btree (mac);


--
-- Name: index_device_auth_pending_on_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_device_auth_pending_on_phone ON device_auth_pendings USING btree (phone);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_locations_on_brand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_brand_id ON locations USING btree (brand_id);


--
-- Name: index_locations_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_category_id ON locations USING btree (category_id);


--
-- Name: index_locations_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_created_at ON locations USING btree (created_at);


--
-- Name: index_locations_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_updated_at ON locations USING btree (updated_at);


--
-- Name: index_locations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_user_id ON locations USING btree (user_id);


--
-- Name: index_login_menu_items_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_login_menu_items_on_location_id ON login_menu_items USING btree (location_id);


--
-- Name: index_notifications_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_location_id ON notifications USING btree (location_id);


--
-- Name: index_notifications_on_poll_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_poll_id ON notifications USING btree (poll_id);


--
-- Name: index_notifications_on_router_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_router_id ON notifications USING btree (router_id);


--
-- Name: index_notifications_on_sent_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_sent_at ON notifications USING btree (sent_at);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id ON notifications USING btree (user_id);


--
-- Name: index_opinions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opinions_on_user_id ON opinions USING btree (user_id);


--
-- Name: index_order_products_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_products_on_order_id ON order_products USING btree (order_id);


--
-- Name: index_order_products_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_products_on_product_id ON order_products USING btree (product_id);


--
-- Name: index_order_statuses_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_statuses_on_order_id ON order_statuses USING btree (order_id);


--
-- Name: index_orders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_user_id ON orders USING btree (user_id);


--
-- Name: index_polls_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_polls_on_user_id ON polls USING btree (user_id);


--
-- Name: index_post_auth_logs_on_callingstationid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_auth_logs_on_callingstationid ON post_auth_logs USING btree (callingstationid);


--
-- Name: index_post_auth_logs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_auth_logs_on_created_at ON post_auth_logs USING btree (created_at);


--
-- Name: index_post_auth_logs_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_auth_logs_on_updated_at ON post_auth_logs USING btree (updated_at);


--
-- Name: index_post_auth_logs_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_auth_logs_on_username ON post_auth_logs USING btree (username);


--
-- Name: index_questions_on_poll_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_on_poll_id ON questions USING btree (poll_id);


--
-- Name: index_routers_on_common_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routers_on_common_name ON routers USING btree (common_name);


--
-- Name: index_routers_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routers_on_created_at ON routers USING btree (created_at);


--
-- Name: index_routers_on_ip_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routers_on_ip_name ON routers USING btree (ip_name);


--
-- Name: index_routers_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routers_on_location_id ON routers USING btree (location_id);


--
-- Name: index_routers_on_serial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routers_on_serial ON routers USING btree (serial);


--
-- Name: index_routers_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routers_on_updated_at ON routers USING btree (updated_at);


--
-- Name: index_routers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routers_on_user_id ON routers USING btree (user_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_sms_logs_on_client_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_logs_on_client_device_id ON sms_logs USING btree (client_device_id);


--
-- Name: index_sms_logs_on_sent_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_logs_on_sent_at ON sms_logs USING btree (sent_at);


--
-- Name: index_sms_logs_on_status_cd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_logs_on_status_cd ON sms_logs USING btree (status_cd);


--
-- Name: index_social_accounts_on_bdate_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_bdate_day ON social_accounts USING btree (bdate_day);


--
-- Name: index_social_accounts_on_bdate_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_bdate_month ON social_accounts USING btree (bdate_month);


--
-- Name: index_social_accounts_on_bdate_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_bdate_year ON social_accounts USING btree (bdate_year);


--
-- Name: index_social_accounts_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_client_id ON social_accounts USING btree (client_id);


--
-- Name: index_social_accounts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_created_at ON social_accounts USING btree (created_at);


--
-- Name: index_social_accounts_on_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_provider ON social_accounts USING btree (provider);


--
-- Name: index_social_accounts_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_updated_at ON social_accounts USING btree (updated_at);


--
-- Name: index_social_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_accounts_on_user_id ON social_accounts USING btree (user_id);


--
-- Name: index_social_logs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_logs_on_created_at ON social_logs USING btree (created_at);


--
-- Name: index_social_logs_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_logs_on_location_id ON social_logs USING btree (location_id);


--
-- Name: index_social_logs_on_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_logs_on_provider ON social_logs USING btree (provider);


--
-- Name: index_social_logs_on_router_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_logs_on_router_id ON social_logs USING btree (router_id);


--
-- Name: index_social_logs_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_social_logs_on_updated_at ON social_logs USING btree (updated_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_type ON users USING btree (type);


--
-- Name: index_users_on_username_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username_and_email ON users USING btree (username, email);


--
-- Name: index_vips_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vips_on_location_id ON vips USING btree (location_id);


--
-- Name: index_vouchers_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_client_id ON vouchers USING btree (client_id);


--
-- Name: index_vouchers_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_location_id ON vouchers USING btree (location_id);


--
-- Name: index_vouchers_on_password; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_password ON vouchers USING btree (password);


--
-- Name: order_statuses fk_rails_159fd1d59f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_statuses
    ADD CONSTRAINT fk_rails_159fd1d59f FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: agent_reward_statuses fk_rails_792f2c86f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_reward_statuses
    ADD CONSTRAINT fk_rails_792f2c86f9 FOREIGN KEY (agent_reward_id) REFERENCES agent_rewards(id);


--
-- Name: order_products fk_rails_96c0709f78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_products
    ADD CONSTRAINT fk_rails_96c0709f78 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: agents fk_rails_9756cfd519; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agents
    ADD CONSTRAINT fk_rails_9756cfd519 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: agent_rewards fk_rails_ab4f9ae2f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_rewards
    ADD CONSTRAINT fk_rails_ab4f9ae2f9 FOREIGN KEY (agent_id) REFERENCES agents(id);


--
-- Name: agents fk_rails_beb1087cc0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agents
    ADD CONSTRAINT fk_rails_beb1087cc0 FOREIGN KEY (agent_payment_method_id) REFERENCES agent_payment_methods(id);


--
-- Name: agent_rewards fk_rails_cb2ac89cc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_rewards
    ADD CONSTRAINT fk_rails_cb2ac89cc8 FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: order_products fk_rails_f40b8ccee4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_products
    ADD CONSTRAINT fk_rails_f40b8ccee4 FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: orders fk_rails_f868b47f6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_f868b47f6a FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160926092822'),
('20160926142836'),
('20160926155533'),
('20160929160301'),
('20160929160550'),
('20160929161120'),
('20160929163109'),
('20160929163901'),
('20160929165358'),
('20160929165908'),
('20161004104338'),
('20161004104651'),
('20161004104838'),
('20161004105123'),
('20161011122349'),
('20161110123047'),
('20161220144846'),
('20170123100047'),
('20170126142520'),
('20170208135746'),
('20170213171728'),
('20170216145128'),
('20170216161028'),
('20170301145358'),
('20170301151611'),
('20170316131938'),
('20170316162452'),
('20170317125549'),
('20170329111107'),
('20170329115451'),
('20170330777777'),
('20170330888888'),
('20170331094954'),
('20170403132230'),
('20170409094954'),
('20170409194954'),
('20170411081120'),
('20170411153752'),
('20170413141506'),
('20170416160301'),
('20170416180301'),
('20170416190301'),
('20170416190302'),
('20170416230302'),
('20170417170302'),
('20170421130302'),
('20170421140302'),
('20170421144402'),
('20170421234402'),
('20170511151502'),
('20170511151503'),
('20170516134211'),
('20170522155935'),
('20170523085435'),
('20170523104605'),
('20170523110629'),
('20170523122441'),
('20170525122441'),
('20170527155935'),
('20170530155935'),
('20170530230056'),
('20170531030056'),
('20170531070056'),
('20170531155935'),
('20170601135935'),
('20170605092935'),
('20170605113935'),
('20170605223935'),
('20170606083935'),
('20170606112608'),
('20170622044132'),
('20170622154132'),
('20170622154432'),
('20170622160732'),
('20170627160732'),
('20170630090732'),
('20170704090732'),
('20170706090732'),
('20170706160732'),
('20170711074255'),
('20170712134124'),
('20170724143200'),
('20170724145605'),
('20170801091505'),
('20170801091636'),
('20170801131707'),
('20170801135133'),
('20170801145945'),
('20170801152325'),
('20170802075001'),
('20170802094728'),
('20170804093342'),
('20170816204056');



