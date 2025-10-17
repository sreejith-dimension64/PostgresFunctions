CREATE OR REPLACE FUNCTION "dbo"."asn_tpin"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "amst" bigint;
    "amst_dob" bigint;
    "amst_tpin_cnt" varchar(100);
    "amst_tpin_a" bigint;
    "dob_" varchar(100);
    "dob_compare" varchar(100);
    "dob_1" varchar(100);
    "NewEmpID" VARCHAR(25);
    "Id" INT;
    "PreFix" VARCHAR(10);
    rec1 RECORD;
    rec2 RECORD;
BEGIN
    FOR rec1 IN (
        SELECT "dob" 
        FROM (
            SELECT DISTINCT (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) 
                END) +
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                END)
            ) AS "dob",
            COUNT(*) AS "scount" 
            FROM "adm_m_student"
            WHERE "mi_id" = 6 
            GROUP BY (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) 
                END) +
                (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                END)
            )
            HAVING COUNT(*) >= 1
        ) AS new 
        ORDER BY "scount" DESC
    ) LOOP
        "dob_" := rec1."dob";
        "amst_tpin_a" := 0;
        
        FOR rec2 IN (
            SELECT "dob", "AMST_Id" 
            FROM (
                SELECT DISTINCT (
                    SUBSTRING(CAST(EXTRACT(YEAR FROM "AMST_DOB") AS varchar(10)), 3, 4) +
                    (CASE WHEN EXTRACT(MONTH FROM "AMST_DOB") BETWEEN 0 AND 9 
                        THEN '0' || CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10))
                        ELSE CAST(EXTRACT(MONTH FROM "AMST_DOB") AS varchar(10)) 
                    END) +
                    (CASE WHEN EXTRACT(DAY FROM "AMST_DOB") BETWEEN 0 AND 9
                        THEN '0' || CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                        ELSE CAST(EXTRACT(DAY FROM "AMST_DOB") AS varchar(10)) 
                    END)
                ) AS "dob", 
                "AMST_Id"
                FROM "adm_m_student"
                WHERE "mi_id" = 6 
            ) AS new 
            WHERE "dob" = "dob_"
        ) LOOP
            "dob_1" := rec2."dob";
            "amst" := rec2."AMST_Id";
            
            IF "amst_tpin_a" = 1 THEN
                SELECT COALESCE(MAX(SUBSTRING("AMST_Tpin", 7, 9)::INT), 0) + 1 
                INTO "Id"
                FROM "Adm_M_Student" 
                WHERE "MI_Id" = 6;
            ELSE
                "Id" := 1;
                "amst_tpin_a" := 1;
            END IF;
            
            "PreFix" := "dob_1";
            "NewEmpID" := "PreFix" || RIGHT('000' || CAST("Id" AS VARCHAR(7)), 3);
            
            UPDATE "Adm_M_Student" 
            SET "AMST_Tpin" = "NewEmpID" 
            WHERE "MI_Id" = 6 AND "AMST_Id" = "amst";
        END LOOP;
    END LOOP;
END;
$$;