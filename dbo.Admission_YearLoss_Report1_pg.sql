CREATE OR REPLACE FUNCTION "dbo"."Admission_YearLoss_Report1"(
    "Asmayid" TEXT,
    "allorind" TEXT,
    "asmclid" TEXT,
    "asmcid" TEXT,
    "tableparam" VARCHAR(5000),
    "mid" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlText" TEXT;
    "previous_yearid" TEXT;
    "orderid" TEXT;
BEGIN
    SELECT "ASMAY_Id", "ASMAY_Order" 
    INTO "previous_yearid", "orderid"
    FROM (
        SELECT MAX("ASMAY_Id") AS "ASMAY_Id", "ASMAY_Order"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Id" < "Asmayid"
        GROUP BY "ASMAY_Id", "ASMAY_Order"
        ORDER BY "ASMAY_Order" DESC
        LIMIT 1
    ) subq;

    IF "allorind" = 'all' THEN
        "sqlText" := 'SELECT ' || "tableparam" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id" 
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."AMAY_Id"
            WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' 
            AND "Adm_School_Y_Student"."AMST_Id" IN (
                SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
                FROM "ADM_M_STUDENT" 
                INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID" 
                WHERE "AMAY_Id" = ' || "previous_yearid" || '
            )';
    ELSE
        "sqlText" := 'SELECT ' || "tableparam" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id" 
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."AMAY_Id"
            WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' 
            AND "Adm_School_Y_Student"."AMST_Id" IN (
                SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
                FROM "ADM_M_STUDENT" 
                INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID" 
                WHERE "AMAY_Id" = ' || "previous_yearid" || ' 
                AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "asmcid" || ' 
                AND "Adm_School_Y_Student"."ASMS_ID" = ' || "asmcid" || '
            )';
    END IF;

    RETURN QUERY EXECUTE "sqlText";
END;
$$;