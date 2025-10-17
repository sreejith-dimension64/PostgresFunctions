CREATE OR REPLACE FUNCTION "dbo"."Admission_YearLoss_Report"(
    "Asmayid" TEXT,
    "allorind" TEXT,
    "asmclid" TEXT,
    "asmcid" TEXT,
    "tableparam" TEXT,
    "mid" TEXT
)
RETURNS TABLE (
    result_data TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlText" TEXT;
    "previous_yearid" TEXT;
    "orderid" TEXT;
BEGIN
    
    SELECT "ASMAY_Id", "ASMAY_Order" 
    INTO "previous_yearid", "orderid"
    FROM "Adm_School_M_Academic_Year"
    WHERE "ASMAY_Id" < "Asmayid"
    GROUP BY "ASMAY_Id", "ASMAY_Order"
    ORDER BY "ASMAY_Order" DESC
    LIMIT 1;
    
    IF "allorind" = 'all' THEN
        
        "sqlText" := 'SELECT DISTINCT ' || "tableparam" || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" 
ON "Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "dbo"."Adm_M_Category" ON "dbo"."Adm_M_Category"."amc_id" = "dbo"."Adm_M_Student"."AMC_Id" 
INNER JOIN "dbo"."IVRM_Master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' AND "Adm_School_M_Academic_Year"."MI_Id" = ' || "mid" || ' 
AND "Adm_School_Y_Student"."AMST_Id" NOT IN (
    SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
    FROM "ADM_M_STUDENT" 
    INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID" 
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
    WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "previous_yearid" || ')';
        
    ELSIF "allorind" = 'indi' THEN
        
        "sqlText" := 'SELECT DISTINCT ' || "tableparam" || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" 
ON "Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "dbo"."Adm_M_Category" ON "dbo"."Adm_M_Category"."amc_id" = "dbo"."Adm_M_Student"."AMC_Id" 
INNER JOIN "dbo"."IVRM_Master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' 
AND "Adm_School_M_Academic_Year"."MI_Id" = ' || "mid" || ' 
AND "Adm_School_Y_Student"."ASMS_Id" = ' || "asmcid" || ' 
AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "asmclid" || ' 
AND "Adm_School_Y_Student"."AMST_Id" NOT IN (
    SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
    FROM "ADM_M_STUDENT" 
    INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID" 
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
    WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "previous_yearid" || ')';
        
    END IF;
    
    RETURN QUERY EXECUTE "sqlText";
    
END;
$$;