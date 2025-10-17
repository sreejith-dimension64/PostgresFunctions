CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_Section"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@HRME_Id" bigint,
    "@roleflg" varchar(50)
)
RETURNS TABLE(
    "asmS_Id" bigint,
    "asmC_SectionName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@roleflg" = 'HOD' THEN
    
        RETURN QUERY
        SELECT DISTINCT c."ASMS_Id" as "asmS_Id", c."ASMC_SectionName" as "asmC_SectionName"
        FROM "IVRM_HOD_Class" a
        INNER JOIN "Adm_School_Y_Student" b ON a."ASMCL_Id" = b."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" c ON c."ASMS_Id" = b."ASMS_Id"
        INNER JOIN "IVRM_HOD" d ON a."IHOD_Id" = d."IHOD_Id"
        WHERE b."ASMAY_Id" = "@ASMAY_Id"
            AND d."HRME_Id" = "@HRME_Id"
            AND c."MI_Id" = "@MI_Id"
            AND c."ASMC_ActiveFlag" = 1
            AND b."ASMCL_Id" = "@ASMCL_Id";
    
    ELSIF "@roleflg" = 'Staff' THEN
    
        RETURN QUERY
        SELECT b."ASMS_Id" as "asmS_Id", b."ASMC_SectionName" as "asmC_SectionName"
        FROM "IVRM_Master_ClassTeacher" a
        INNER JOIN "Adm_School_M_Section" b ON a."ASMS_Id" = b."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON a."ASMCL_Id" = d."ASMCL_Id"
        WHERE a."ASMAY_Id" = "@ASMAY_Id"
            AND a."ASMCL_Id" = "@ASMCL_Id"
            AND a."HRME_Id" = "@HRME_Id"
            AND a."IMCT_ActiveFlag" = 1
            AND b."ASMC_ActiveFlag" = 1;
    
    END IF;

    RETURN;

END;
$$;