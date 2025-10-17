CREATE OR REPLACE FUNCTION "dbo"."GenerateTpinno_New"(p_MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_i bigint;
    v_n bigint;
    v_Generatetpin varchar(100);
    v_AMST_Id bigint;
    v_Dob varchar(100);
    v_Dob_New varchar(100);
    v_scount int;
    v_j bigint;
    rec_outer RECORD;
    rec_inner RECORD;
BEGIN
    v_i := 1;
    v_j := 0;

    DROP TABLE IF EXISTS "generatetpno_New";
    
    CREATE TEMP TABLE "generatetpno_New" (
        "AMST_Id" bigint,
        "Dob" varchar(20),
        "Generatetpin" varchar(30)
    );

    FOR rec_outer IN
        SELECT dob, scount 
        FROM (
            SELECT DISTINCT 
                (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) ||
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) END) ||
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) END)) AS Dob,
                COUNT(*) AS scount 
            FROM "adm_m_student"  
            WHERE "MI_Id" = p_MI_Id AND "AMST_Tpin" IS NULL
            GROUP BY (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) ||
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) END) ||
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) END))
            HAVING COUNT(*) >= 1
        ) AS new_subquery 
        ORDER BY scount DESC
    LOOP
        v_Dob := rec_outer.dob;
        v_scount := rec_outer.scount;

        SELECT CAST(SUBSTRING(CAST(MAX(CAST("AMST_tpin" AS bigint)) AS varchar), 7, 9) AS bigint)
        INTO v_j
        FROM "adm_m_student" 
        WHERE "mi_id" = p_MI_Id 
        AND (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) ||
            (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) END) ||
            (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) END)) = v_Dob
        GROUP BY (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) ||
            (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) 
                ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) END) ||
            (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) END));

        IF (COALESCE(v_j, 0) > 1) THEN
            v_i := v_j + 1;
        END IF;

        FOR rec_inner IN
            SELECT DISTINCT "AMST_Id",
                (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) ||
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) END) ||
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) END)) AS Dob
            FROM "adm_m_student"  
            WHERE "mi_id" = p_MI_Id AND "AMST_Tpin" IS NULL 
            AND (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) ||
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) END) ||
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) END)) = v_Dob
        LOOP
            v_AMST_Id := rec_inner."AMST_Id";
            v_Dob_New := rec_inner.Dob;

            v_Generatetpin := v_Dob_New || REPEAT('0', 3 - LENGTH(v_i::varchar)) || v_i::varchar;

            INSERT INTO "generatetpno_New" VALUES(v_AMST_Id, v_Dob_New, v_Generatetpin);

            v_i := v_i + 1;
        END LOOP;

        v_i := 1;
    END LOOP;

    UPDATE "Adm_M_Student" B 
    SET "AMST_Tpin" = A."Generatetpin"
    FROM "generatetpno_New" A 
    WHERE A."AMST_Id" = B."AMST_Id" 
    AND B."MI_Id" = p_MI_Id;

    RETURN;
END;
$$;