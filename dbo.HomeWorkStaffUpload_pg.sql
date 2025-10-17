CREATE OR REPLACE FUNCTION "dbo"."HomeWorkStaffUpload"(
    "MI_Id" VARCHAR(100),
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" TEXT,
    "FromDate" VARCHAR(10),
    "ToDate" VARCHAR(10)
)
RETURNS TABLE(
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "IHWUPL_FileName" VARCHAR,
    "UpdatedBy" TEXT,
    "UpdatedDate" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Sqldynamic" TEXT;
BEGIN
    "Sqldynamic" := 'SELECT "ASMCL_ClassName","ASMC_SectionName","IHWUPL_FileName",COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "UpdatedBy",CAST("IHWUPL_Date" AS DATE) AS "UpdatedDate"
FROM "IVRM_HomeWork" "HW"
INNER JOIN "IVRM_HomeWork_Upload" "HWU" ON "HW"."IHW_Id"="HWU"."IHW_Id"
INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id"="HWU"."AMST_Id" AND "AMS"."AMST_ActiveFlag"=1 AND "AMS"."AMST_SOL"=''S''
INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id"="AMS"."AMST_Id" AND "ASYS"."AMAY_ActiveFlag"=1  
INNER JOIN "Adm_School_M_Class" "ASMCL" ON "ASMCL"."ASMCL_Id"="HW"."ASMCL_Id"
INNER JOIN "Adm_School_M_section" "ASMS" ON "ASMS"."ASMS_Id"="HW"."ASMS_Id"
WHERE "HW"."MI_Id"=' || "MI_Id" || ' AND "HW"."asmay_id"=' || "ASMAY_Id" || ' AND "HW"."ASMCL_Id"=' || "ASMCL_Id" || ' AND "HW"."IHW_ActiveFlag"=1 AND "HWU"."IHWUPL_ActiveFlag"=1 AND "IHWUPL_ActiveFlag"=1
AND CAST("HWU"."IHWUPL_Date" AS DATE) BETWEEN ''' || "FromDate" || ''' AND ''' || "ToDate" || '''';

    RETURN QUERY EXECUTE "Sqldynamic";
END;
$$;