CREATE OR REPLACE FUNCTION "dbo"."FeeStudentTest" (
    p_name VARCHAR(100)
)
RETURNS TABLE (
    "AMST_Id" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "Name" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "FMT_Id" INTEGER,
    "FMT_Name" VARCHAR,
    "Balance" NUMERIC,
    "paid" NUMERIC,
    "Total" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlquery TEXT;
    v_name VARCHAR(100);
BEGIN
    v_name := REPLACE(p_name, ',', ''',''');
    
    v_sqlquery := 
    ';WITH cte AS
    (
        SELECT DISTINCT "Adm_M_Student"."AMST_Id",
               "Adm_M_Student"."AMST_AdmNo",
               (COALESCE("Adm_M_Student"."AMST_FirstName", '' '') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')) AS "Name",
               "Adm_School_M_Class"."ASMCL_ClassName",
               "Adm_School_M_Section"."ASMC_SectionName",
               "Fee_Master_Terms"."FMT_Id",
               "Fee_Master_Terms"."FMT_Name",
               SUM("Fee_Student_Status"."FSS_ToBePaid") AS "Balance",
               SUM("Fee_Student_Status"."FSS_PaidAmount") AS "paid",
               SUM("Fee_Student_Status"."FSS_NetAmount") AS "Total"
        FROM "Fee_Master_Terms_FeeHeads"
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms_FeeHeads"."FMT_Id" = "Fee_Master_Terms"."FMT_Id"
        INNER JOIN "Adm_M_Student" 
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "Fee_Master_Group"
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
        ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
        ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
        WHERE ("Adm_School_Y_Student"."asmay_id" = 1) 
          AND ("Fee_Student_Status"."MI_Id" = 6) 
          AND ("Fee_Master_Terms"."fmt_id" IN (5,6,7)) 
          AND ("Adm_School_M_Class"."ASMCL_Id" = 29)
          AND ("Fee_Student_Status"."FMG_Id" NOT IN (27, 30, 31, 32)) 
          AND ("Fee_Student_Status"."FSS_ToBePaid" > 0)
          AND ("Fee_Student_Status"."FMH_Id" != 100) 
          AND ("Adm_M_Student"."AMST_SOL" = ''S'') 
          AND ("Adm_M_Student"."AMST_ActiveFlag" = ''1'') 
          AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" = ''1'')
        GROUP BY "Adm_M_Student"."amst_id",
                 "Adm_M_Student"."AMST_AdmNo",
                 "Adm_M_Student"."AMST_Id",
                 "AMST_FirstName",
                 "AMST_MiddleName",
                 "AMST_LastName",
                 "Adm_School_M_Class"."ASMCL_ClassName",
                 "Adm_School_M_Section"."ASMC_SectionName",
                 "Fee_Master_Terms"."FMT_Id",
                 "Fee_Master_Terms"."FMT_Name"
        HAVING (SUM("Fee_Student_Status"."FSS_PaidAmount") = ''0'')
    )
    SELECT * FROM cte WHERE "name" IN (''' || v_name || ''') ORDER BY "amst_id"';
    
    RETURN QUERY EXECUTE v_sqlquery;
END;
$$;