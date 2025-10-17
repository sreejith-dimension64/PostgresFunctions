CREATE OR REPLACE FUNCTION "dbo"."Admission_Generate_Tpin"(p_MI_Id BIGINT, p_AMST_Id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_Dob VARCHAR(10);
    v_i BIGINT;
    v_n BIGINT;
    v_Generatetpin VARCHAR(100);
    v_AMST_Id BIGINT;
    v_Dob VARCHAR(100);
    v_Dob_New VARCHAR(100);
    v_scount INT;
    v_j BIGINT;
    rec_outer RECORD;
    rec_inner RECORD;
BEGIN
    IF p_AMST_Id > 0 THEN
        v_i := 1;
        v_j := 0;

        DROP TABLE IF EXISTS generatetpno_New;
        CREATE TEMP TABLE generatetpno_New ("AMST_Id" BIGINT, "Dob" VARCHAR(20), "Generatetpin" VARCHAR(30));

        FOR rec_outer IN
            SELECT dob, scount 
            FROM (
                SELECT DISTINCT (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                ) AS Dob,
                COUNT(*) AS scount 
                FROM "adm_m_student"
                WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = p_AMST_Id AND "AMST_Tpin" IS NULL
                GROUP BY (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                )
                HAVING COUNT(*) >= 1
            ) AS new 
            ORDER BY scount DESC
        LOOP
            v_Dob := rec_outer.dob;
            v_scount := rec_outer.scount;

            SELECT CAST(SUBSTRING(CAST(MAX(CAST("AMST_tpin" AS BIGINT)) AS TEXT), 7, 9) AS BIGINT)
            INTO v_j
            FROM "adm_m_student"
            WHERE "mi_id" = p_MI_Id AND 
            (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
            ) = v_Dob
            GROUP BY (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
            );

            IF (COALESCE(v_j, 0) > 1) THEN
                v_i := v_j + 1;
            END IF;

            FOR rec_inner IN
                SELECT DISTINCT "AMST_Id", (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                ) AS Dob
                FROM "adm_m_student"
                WHERE "mi_id" = p_MI_Id AND "AMST_Id" = p_AMST_Id AND "AMST_Tpin" IS NULL AND
                (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                ) = v_Dob
            LOOP
                v_AMST_Id := rec_inner."AMST_Id";
                v_Dob_New := rec_inner.Dob;

                v_Generatetpin := v_Dob_New || REPEAT('0', 3 - LENGTH(CAST(v_i AS VARCHAR(10)))) || CAST(v_i AS VARCHAR(10));

                INSERT INTO generatetpno_New VALUES(v_AMST_Id, v_Dob_New, v_Generatetpin);

                v_i := v_i + 1;
            END LOOP;

            v_i := 1;
        END LOOP;

        UPDATE "Adm_M_Student" B 
        SET "AMST_Tpin" = A."Generatetpin" 
        FROM generatetpno_New A 
        WHERE A."AMST_Id" = B."AMST_Id" AND B."MI_Id" = p_MI_Id;

    ELSE
        v_i := 1;
        v_j := 0;

        DROP TABLE IF EXISTS generatetpno_New;
        CREATE TEMP TABLE generatetpno_New ("AMST_Id" BIGINT, "Dob" VARCHAR(20), "Generatetpin" VARCHAR(30));

        FOR rec_outer IN
            SELECT dob, scount 
            FROM (
                SELECT DISTINCT (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                ) AS Dob,
                COUNT(*) AS scount 
                FROM "adm_m_student"
                WHERE "MI_Id" = p_MI_Id AND "AMST_Tpin" IS NULL
                GROUP BY (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                )
                HAVING COUNT(*) >= 1
            ) AS new 
            ORDER BY scount DESC
        LOOP
            v_Dob := rec_outer.dob;
            v_scount := rec_outer.scount;

            SELECT CAST(SUBSTRING(CAST(MAX(CAST("AMST_tpin" AS BIGINT)) AS TEXT), 7, 9) AS BIGINT)
            INTO v_j
            FROM "adm_m_student"
            WHERE "mi_id" = p_MI_Id AND 
            (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
            ) = v_Dob
            GROUP BY (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                      THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                      ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
            );

            IF (COALESCE(v_j, 0) > 1) THEN
                v_i := v_j + 1;
            END IF;

            FOR rec_inner IN
                SELECT DISTINCT "AMST_Id", (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                ) AS Dob
                FROM "adm_m_student"
                WHERE "mi_id" = p_MI_Id AND "AMST_Tpin" IS NULL AND
                (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9 
                          THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10))
                          ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS VARCHAR(10)) END)
                ) = v_Dob
            LOOP
                v_AMST_Id := rec_inner."AMST_Id";
                v_Dob_New := rec_inner.Dob;

                v_Generatetpin := v_Dob_New || REPEAT('0', 3 - LENGTH(CAST(v_i AS VARCHAR(10)))) || CAST(v_i AS VARCHAR(10));

                INSERT INTO generatetpno_New VALUES(v_AMST_Id, v_Dob_New, v_Generatetpin);

                v_i := v_i + 1;
            END LOOP;

            v_i := 1;
        END LOOP;

        UPDATE "Adm_M_Student" B 
        SET "AMST_Tpin" = A."Generatetpin" 
        FROM generatetpno_New A 
        WHERE A."AMST_Id" = B."AMST_Id" AND B."MI_Id" = p_MI_Id;

    END IF;

    RETURN;
END;
$$;