CREATE OR REPLACE FUNCTION "dbo"."Cut_of_dates_get" (
    p_DOB TIMESTAMP
)
RETURNS TABLE (
    "ASMCL_Id" INT,
    "MI_Id" INT,
    "ASMCL_MinAgeDays" INT,
    "ASMCL_MinAgeMonth" INT,
    "ASMCL_MinAgeYear" INT,
    "ASMCL_MaxAgeDays" INT,
    "ASMCL_MaxAgeMonth" INT,
    "ASMCL_MaxAgeYear" INT,
    "ASMCL_Order" INT,
    "ASMCL_ClassName" VARCHAR,
    "ASMCL_ClassCode" VARCHAR,
    "ASMCL_MaxCapacity" INT,
    "ASMCL_ActiveFlag" BOOLEAN,
    "CreatedDate" TIMESTAMP,
    "UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_asmcl_id INT;
    v_min_D INT;
    v_min_M INT;
    v_min_Y INT;
    v_max_D INT;
    v_max_M INT;
    v_max_Y INT;
    v_Cut_of_Date TIMESTAMP;
    v_D VARCHAR(10);
    v_M VARCHAR(10);
    v_Y VARCHAR(10);
    v_D1 VARCHAR(10);
    v_M1 VARCHAR(10);
    v_Y1 VARCHAR(10);
    v_min_date VARCHAR(10);
    v_max_date VARCHAR(10);
    v_min_date1 TIMESTAMP;
    v_max_date1 TIMESTAMP;
    v_values INT;
    v_values123 INT;
    v_min_date123 TIMESTAMP;
    class_loop_rec RECORD;
BEGIN
    v_min_date123 := TO_TIMESTAMP('01-06-2014', 'DD-MM-YYYY');

    CREATE TEMP TABLE "Student_main_Temp" (
        "asmcl_id_in" INT
    ) ON COMMIT DROP;

    SELECT "ASMAY_Cut_Of_Date" INTO v_Cut_of_Date 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = 4;

    FOR class_loop_rec IN 
        SELECT "ASMCL_Id", "ASMCL_MinAgeDays", "ASMCL_MinAgeMonth", "ASMCL_MinAgeYear",
               "ASMCL_MaxAgeDays", "ASMCL_MaxAgeMonth", "ASMCL_MaxAgeYear"
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = 4
        LIMIT 1
    LOOP
        v_asmcl_id := class_loop_rec."ASMCL_Id";
        v_min_D := class_loop_rec."ASMCL_MinAgeDays";
        v_min_M := class_loop_rec."ASMCL_MinAgeMonth";
        v_min_Y := class_loop_rec."ASMCL_MinAgeYear";
        v_max_D := class_loop_rec."ASMCL_MaxAgeDays";
        v_max_M := class_loop_rec."ASMCL_MaxAgeMonth";
        v_max_Y := class_loop_rec."ASMCL_MaxAgeYear";

        SELECT EXTRACT(DAY FROM (v_Cut_of_Date - (v_min_D || ' days')::INTERVAL))::VARCHAR INTO v_D;
        SELECT EXTRACT(MONTH FROM (v_Cut_of_Date - (v_min_M || ' months')::INTERVAL))::VARCHAR INTO v_M;
        SELECT EXTRACT(YEAR FROM (v_Cut_of_Date - (v_min_Y || ' years')::INTERVAL))::VARCHAR INTO v_Y;

        SELECT EXTRACT(DAY FROM (v_Cut_of_Date + (v_max_D || ' days')::INTERVAL))::VARCHAR INTO v_D1;
        SELECT EXTRACT(MONTH FROM (v_Cut_of_Date + (v_max_M || ' months')::INTERVAL))::VARCHAR INTO v_M1;
        SELECT EXTRACT(YEAR FROM (v_Cut_of_Date + (v_max_Y || ' years')::INTERVAL))::VARCHAR INTO v_Y1;

        v_min_date := v_D || '-' || v_M || '-' || v_Y;
        v_max_date := v_D1 || '-' || v_M1 || '-' || v_Y1;

        v_min_date1 := TO_TIMESTAMP(v_min_date, 'DD-MM-YYYY');
        v_max_date1 := TO_TIMESTAMP(v_max_date, 'DD-MM-YYYY');

        CREATE TEMP TABLE "StudentTemp" (
            "class_loop6" TIMESTAMP,
            "class_loop7" TIMESTAMP
        ) ON COMMIT DROP;

        INSERT INTO "StudentTemp" VALUES (v_min_date1, v_max_date1);

        SELECT COUNT(*) INTO v_values 
        FROM "StudentTemp" 
        WHERE v_min_date123 BETWEEN "class_loop6" AND "class_loop7";

        IF v_values > 0 THEN
            INSERT INTO "Student_main_Temp" VALUES (v_asmcl_id);
        END IF;

        DROP TABLE "StudentTemp";

    END LOOP;

    RETURN QUERY
    SELECT * 
    FROM "Adm_School_M_Class" 
    WHERE "MI_Id" = 4 
    AND "ASMCL_Id" IN (SELECT "asmcl_id_in" FROM "Student_main_Temp");

    DROP TABLE "Student_main_Temp";

    RETURN;
END;
$$;