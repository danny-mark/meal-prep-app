
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."diary_entries" (
    "id" bigint NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "date" "date" NOT NULL,
    "contents" "json" NOT NULL,
    "type" "text" NOT NULL,
    "favorite_meal_id" bigint
);

ALTER TABLE "public"."diary_entries" OWNER TO "postgres";

ALTER TABLE "public"."diary_entries" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."diary_entries_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."favorite_meals" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "contents" "json" NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "last_used_at" timestamp with time zone
);

ALTER TABLE "public"."favorite_meals" OWNER TO "postgres";

ALTER TABLE "public"."favorite_meals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."favorite_meals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."food_items" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "macros" "json" NOT NULL,
    "is_favorite" boolean DEFAULT false NOT NULL,
    "last_used_at" timestamp with time zone,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "note" "text",
    "category" "text",
    "name" "text" DEFAULT ''::"text" NOT NULL
);

ALTER TABLE "public"."food_items" OWNER TO "postgres";

ALTER TABLE "public"."food_items" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."food_items_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."targets" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "type" "text" DEFAULT 'daily'::"text" NOT NULL,
    "macros" "json" NOT NULL
);

ALTER TABLE "public"."targets" OWNER TO "postgres";

ALTER TABLE "public"."targets" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."targets_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE ONLY "public"."diary_entries"
    ADD CONSTRAINT "diary_entriess_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."favorite_meals"
    ADD CONSTRAINT "favorite_meals_name_key" UNIQUE ("name");

ALTER TABLE ONLY "public"."favorite_meals"
    ADD CONSTRAINT "favorite_meals_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."food_items"
    ADD CONSTRAINT "food_item_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."food_items"
    ADD CONSTRAINT "food_items_name_key" UNIQUE ("name");

ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."diary_entries"
    ADD CONSTRAINT "diary_entries_favorite_meal_id_fkey" FOREIGN KEY ("favorite_meal_id") REFERENCES "public"."favorite_meals"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."diary_entries"
    ADD CONSTRAINT "diary_entries_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."favorite_meals"
    ADD CONSTRAINT "favorite_meals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."food_items"
    ADD CONSTRAINT "food_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

CREATE POLICY "Enable all for users based on user_id" ON "public"."diary_entries" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

CREATE POLICY "Enable all for users based on user_id" ON "public"."favorite_meals" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

CREATE POLICY "Enable all for users based on user_id" ON "public"."food_items" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

CREATE POLICY "Enable all for users based on user_id" ON "public"."targets" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

ALTER TABLE "public"."diary_entries" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."favorite_meals" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."food_items" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."targets" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON TABLE "public"."diary_entries" TO "anon";
GRANT ALL ON TABLE "public"."diary_entries" TO "authenticated";
GRANT ALL ON TABLE "public"."diary_entries" TO "service_role";

GRANT ALL ON SEQUENCE "public"."diary_entries_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."diary_entries_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."diary_entries_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."favorite_meals" TO "anon";
GRANT ALL ON TABLE "public"."favorite_meals" TO "authenticated";
GRANT ALL ON TABLE "public"."favorite_meals" TO "service_role";

GRANT ALL ON SEQUENCE "public"."favorite_meals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."favorite_meals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."favorite_meals_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."food_items" TO "anon";
GRANT ALL ON TABLE "public"."food_items" TO "authenticated";
GRANT ALL ON TABLE "public"."food_items" TO "service_role";

GRANT ALL ON SEQUENCE "public"."food_items_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."food_items_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."food_items_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."targets" TO "anon";
GRANT ALL ON TABLE "public"."targets" TO "authenticated";
GRANT ALL ON TABLE "public"."targets" TO "service_role";

GRANT ALL ON SEQUENCE "public"."targets_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."targets_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."targets_id_seq" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;