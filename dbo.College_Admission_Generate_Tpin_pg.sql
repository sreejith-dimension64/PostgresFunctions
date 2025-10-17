CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Generate_Tpin"(
    p_MI_Id BIGINT,
    p_AMCST_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCST_DOB VARCHAR;
    v_i BIGINT;
    v_n BIGINT;
    v_Generatetpin VARCHAR(100);
    v_Dob VARCHAR(100);
    v_Dob_New VARCHAR(100);
    v_scount INT;
    v_j BIGINT;
    v_AMCST_Id_New BIGINT;
    v_AMCST_Id_Loop BIGINT;
    rec_outer RECORD;
    rec_inner RECORD;
BEGIN
    IF p_AMCST_Id > 0 THEN
        v_i := 1;
        v_j := 0;

        DROP TABLE IF EXISTS generatetpno_Clg_New;
        CREATE TEMP TABLE generatetpno_Clg_New (
            "AMCST_Id" BIGINT,
            "Dob" VARCHAR(20),
            "Generatetpin" VARCHAR(30)
        );

        FOR rec_outer IN (
            SELECT dob, scount 
            FROM (
                SELECT DISTINCT (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)
                ) AS Dob,
                COUNT(*) AS scount 
                FROM "CLG"."Adm_Master_College_Student"
                WHERE "MI_Id" = p_MI_Id AND "AMCST_Id" = p_AMCST_Id AND "AMCST_TPINNO" IS NULL
                GROUP BY (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)
                )
                HAVING COUNT(*) >= 1
            ) AS new 
            ORDER BY scount DESC
        ) LOOP
            v_Dob := rec_outer.dob;
            v_scount := rec_outer.scount;

            SELECT CAST(SUBSTRING(CAST(MAX(CAST("AMCST_TPINNO" AS BIGINT)) AS VARCHAR), 7, 9) AS BIGINT)
            INTO v_j
            FROM "CLG"."Adm_Master_College_Student"
            WHERE "mi_id" = p_MI_Id AND 
            (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)) = v_Dob
            GROUP BY (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END));

            IF (COALESCE(v_j, 0) > 1) THEN
                v_i := v_j + 1;
            END IF;

            FOR rec_inner IN (
                SELECT DISTINCT "AMCST_Id",
                (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)) AS Dob
                FROM "CLG"."Adm_Master_College_Student"
                WHERE "mi_id" = p_MI_Id AND "AMCST_Id" = p_AMCST_Id AND "AMCST_TPINNO" IS NULL AND
                (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)) = v_Dob
            ) LOOP
                v_AMCST_Id_Loop := rec_inner."AMCST_Id";
                v_Dob_New := rec_inner.Dob;

                v_Generatetpin := v_Dob_New || REPEAT('0', 3 - LENGTH(CAST(v_i AS VARCHAR))) || CAST(v_i AS VARCHAR(10));

                INSERT INTO generatetpno_Clg_New VALUES(v_AMCST_Id_Loop, v_Dob_New, v_Generatetpin);

                v_i := v_i + 1;
            END LOOP;

            v_i := 1;
        END LOOP;

        UPDATE "CLG"."Adm_Master_College_Student" B 
        SET "AMCST_TPINNO" = A."Generatetpin" 
        FROM generatetpno_Clg_New A 
        WHERE A."AMCST_Id" = B."AMCST_Id" AND B."MI_Id" = p_MI_Id;

    ELSE
        v_i := 1;
        v_j := 0;

        DROP TABLE IF EXISTS generatetpno_Clg_New;
        CREATE TEMP TABLE generatetpno_Clg_New (
            "AMCST_Id" BIGINT,
            "Dob" VARCHAR(20),
            "Generatetpin" VARCHAR(30)
        );

        FOR rec_outer IN (
            SELECT dob, scount 
            FROM (
                SELECT DISTINCT (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)
                ) AS Dob,
                COUNT(*) AS scount 
                FROM "CLG"."Adm_Master_College_Student"
                WHERE "MI_Id" = p_MI_Id AND "AMCST_TPINNO" IS NULL
                GROUP BY (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)
                )
                HAVING COUNT(*) >= 1
            ) AS new 
            ORDER BY scount DESC
        ) LOOP
            v_Dob := rec_outer.dob;
            v_scount := rec_outer.scount;

            SELECT CAST(SUBSTRING(CAST(MAX(CAST("AMCST_TPINNO" AS BIGINT)) AS VARCHAR), 7, 9) AS BIGINT)
            INTO v_j
            FROM "CLG"."Adm_Master_College_Student"
            WHERE "mi_id" = p_MI_Id AND 
            (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)) = v_Dob
            GROUP BY (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END));

            IF (COALESCE(v_j, 0) > 1) THEN
                v_i := v_j + 1;
            END IF;

            FOR rec_inner IN (
                SELECT DISTINCT "AMCST_Id",
                (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)) AS Dob
                FROM "CLG"."Adm_Master_College_Student"
                WHERE "mi_id" = p_MI_Id AND "AMCST_TPINNO" IS NULL AND
                (SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS VARCHAR(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS VARCHAR(10)) END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10))
                        ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS VARCHAR(10)) END)) = v_Dob
            ) LOOP
                v_AMCST_Id_Loop := rec_inner."AMCST_Id";
                v_Dob_New := rec_inner.Dob;

                v_Generatetpin := v_Dob_New || REPEAT('0', 3 - LENGTH(CAST(v_i AS VARCHAR))) || CAST(v_i AS VARCHAR(10));

                INSERT INTO generatetpno_Clg_New VALUES(v_AMCST_Id_Loop, v_Dob_New, v_Generatetpin);

                v_i := v_i + 1;
            END LOOP;

            v_i := 1;
        END LOOP;

        UPDATE "CLG"."Adm_Master_College_Student" B 
        SET "AMCST_TPINNO" = A."Generatetpin" 
        FROM generatetpno_Clg_New A 
        WHERE A."AMCST_Id" = B."AMCST_Id" AND B."MI_Id" = p_MI_Id;

    END IF;

    RETURN;
END;
$$;