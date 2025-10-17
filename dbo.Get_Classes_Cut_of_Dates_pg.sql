CREATE OR REPLACE FUNCTION "dbo"."Get_Classes_Cut_of_Dates" (
    "p_mi_id" INT,
    "p_DOB" VARCHAR(10)
)
RETURNS TABLE (
    "ASMCL_Id" INT,
    "ASMCL_ClassName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_asmcl_id" INT;
    "v_min_D" INT;
    "v_min_M" INT;
    "v_min_Y" INT;
    "v_max_D" INT;
    "v_max_M" INT;
    "v_max_Y" INT;
    "v_Cut_of_Date" TIMESTAMP;
    "v_D" VARCHAR(10);
    "v_M" VARCHAR(10);
    "v_Y" VARCHAR(10);
    "v_D1" VARCHAR(10);
    "v_M1" VARCHAR(10);
    "v_Y1" VARCHAR(10);
    "v_min_date" VARCHAR(10);
    "v_max_date" VARCHAR(10);
    "v_min_date1" TIMESTAMP;
    "v_max_date1" TIMESTAMP;
    "v_values" INT;
    "v_values123" INT;
    "v_min_date123" VARCHAR(10);
    "v_DOB_timestamp" TIMESTAMP;
BEGIN
    CREATE TEMP TABLE "Student_main_Temp" (
        "asmcl_id_in" INT
    ) ON COMMIT DROP;

    SELECT "ASMAY_Cut_Of_Date" INTO "v_Cut_of_Date" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_mi_id";

    "v_DOB_timestamp" := TO_TIMESTAMP("p_DOB", 'DD-MM-YYYY');

    FOR "v_asmcl_id", "v_min_D", "v_min_M", "v_min_Y", "v_max_D", "v_max_M", "v_max_Y" IN
        SELECT "ASMCL_Id", "ASMCL_MinAgeDays", "ASMCL_MinAgeMonth", "ASMCL_MinAgeYear", 
               "ASMCL_MaxAgeDays", "ASMCL_MaxAgeMonth", "ASMCL_MaxAgeYear" 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = "p_mi_id"
    LOOP
        SELECT EXTRACT(DAY FROM ("v_Cut_of_Date" - ("v_min_D" || ' days')::INTERVAL))::VARCHAR INTO "v_D";
        SELECT EXTRACT(MONTH FROM ("v_Cut_of_Date" - ("v_min_M" || ' months')::INTERVAL))::VARCHAR INTO "v_M";
        SELECT EXTRACT(YEAR FROM ("v_Cut_of_Date" - ("v_min_Y" || ' years')::INTERVAL))::VARCHAR INTO "v_Y";

        SELECT EXTRACT(DAY FROM ("v_Cut_of_Date" - ("v_max_D" || ' days')::INTERVAL))::VARCHAR INTO "v_D1";
        SELECT EXTRACT(MONTH FROM ("v_Cut_of_Date" - ("v_max_M" || ' months')::INTERVAL))::VARCHAR INTO "v_M1";
        SELECT EXTRACT(YEAR FROM ("v_Cut_of_Date" - ("v_max_Y" || ' years')::INTERVAL))::VARCHAR INTO "v_Y1";

        "v_min_date" := "v_D" || '-' || "v_M" || '-' || "v_Y";
        "v_max_date" := "v_D1" || '-' || "v_M1" || '-' || "v_Y1";

        "v_min_date1" := TO_TIMESTAMP("v_min_date", 'DD-MM-YYYY');
        "v_max_date1" := TO_TIMESTAMP("v_max_date", 'DD-MM-YYYY');

        CREATE TEMP TABLE "StudentTemp" (
            "class_loop6" TIMESTAMP,
            "class_loop7" TIMESTAMP
        ) ON COMMIT DROP;

        INSERT INTO "StudentTemp" VALUES ("v_min_date1", "v_max_date1");

        SELECT COUNT(*) INTO "v_values" 
        FROM "StudentTemp" 
        WHERE "v_DOB_timestamp" BETWEEN "class_loop6" AND "class_loop7";

        IF "v_values" > 0 THEN
            INSERT INTO "Student_main_Temp" VALUES ("v_asmcl_id");
        END IF;

        DROP TABLE "StudentTemp";
    END LOOP;

    RETURN QUERY
    SELECT a."ASMCL_Id", a."ASMCL_ClassName"
    FROM "Adm_School_M_Class" a
    WHERE a."MI_Id" = "p_mi_id" 
    AND a."ASMCL_Id" IN (SELECT "asmcl_id_in" FROM "Student_main_Temp");

    DROP TABLE "Student_main_Temp";

    RETURN;
END;
$$;