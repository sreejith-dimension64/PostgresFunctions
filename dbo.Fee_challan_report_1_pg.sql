CREATE OR REPLACE FUNCTION "dbo"."Fee_challan_report_1" (
    "mi_id" TEXT,
    "Asmay_Id" TEXT,
    "asmcl_id" TEXT,
    "amsc_id" TEXT,
    "fromdate" TEXT,
    "todate" TEXT,
    "type" TEXT
)
RETURNS SETOF REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    "str1" TEXT;
    "query" TEXT;
    ref REFCURSOR;
BEGIN
    IF ("asmcl_id" != '0') AND ("amsc_id" != '0') THEN
        "str1" := 'AND ("dbo"."Adm_School_M_Section"."ASMS_Id" = ' || "amsc_id" || ') AND 
("dbo"."Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || ')';
    ELSIF ("asmcl_id" != '0') AND ("amsc_id" = '0') THEN
        "str1" := ' AND ("dbo"."Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || ')';
    ELSE
        "str1" := ' ';
    END IF;

    IF "type" = '1' THEN
        "query" := 'SELECT COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '' '') AS "Name", 
"dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Y_Payment"."FYP_Receipt_No", 
"dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash", "dbo"."Fee_Y_Payment"."FYP_Tot_Amount", "AMAY_RollNo", "dbo"."Fee_Y_Payment"."FYP_ChallanNo"
FROM "dbo"."Fee_Y_Payment" INNER JOIN
"dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" INNER JOIN
"dbo"."Adm_M_Student" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON 
"dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
WHERE ("dbo"."Fee_Y_Payment"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || "Asmay_Id" || ') AND "dbo"."Fee_Y_Payment"."FYP_Date"::date BETWEEN TO_DATE(''' || "fromdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "todate" || ''', ''DD/MM/YYYY'') AND ("FYP_ChallanNo" IS NOT NULL AND "FYP_ChallanNo" != '' '') AND "FYP_OnlineChallanStatusFlag" = ''Sucessfull'' ' || "str1" || ' AND ("dbo"."Adm_School_Y_Student"."ASMAY_ID" = ' || "Asmay_Id" || ') ORDER BY "ASMCL_ClassName", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName"';
    ELSE
        "query" := 'SELECT COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '' '') AS "Name", 
"dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Y_Payment"."FYP_ChallanNo", 
"dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash", "dbo"."Fee_Y_Payment"."FYP_Tot_Amount", "AMAY_RollNo"
FROM "dbo"."Fee_Y_Payment" INNER JOIN
"dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" INNER JOIN
"dbo"."Adm_M_Student" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON 
"dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
WHERE ("dbo"."Fee_Y_Payment"."MI_Id" = ' || "mi_id" || ') AND "dbo"."Fee_Y_Payment"."DOE"::date BETWEEN TO_DATE(''' || "fromdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "todate" || ''', ''DD/MM/YYYY'') AND ("FYP_ChallanNo" IS NOT NULL AND "FYP_ChallanNo" != '' '') AND "FYP_OnlineChallanStatusFlag" = ''Payment Initiated'' ' || "str1" || ' AND ("dbo"."Adm_School_Y_Student"."ASMAY_ID" = ' || "Asmay_Id" || ') ORDER BY "ASMCL_ClassName", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName"';
    END IF;

    OPEN ref FOR EXECUTE "query";
    RETURN NEXT ref;
END;
$$;