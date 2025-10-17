CREATE OR REPLACE FUNCTION "dbo"."CountryStateWiseStudentList" (
    "ASMAY_ID" VARCHAR(50),
    "country_Id" VARCHAR(50),
    "state_Id" VARCHAR(50),
    "mi_id" VARCHAR(50),
    "type" TEXT
)
RETURNS TABLE (
    "Amst_LastName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "flag_type" TEXT;
BEGIN
    IF ("type" = 'country') THEN
        "flag_type" := 'and a."AMST_PerCountry" = ' || "country_Id" || '';
    ELSIF ("type" = 'state') THEN
        "flag_type" := 'and a."AMST_PerState" = ' || "state_Id" || '';
    END IF;

    IF ("type" = 'country') THEN
        "query" := 'select COALESCE(a."AMST_FirstName", '''') || '' '' || COALESCE(a."AMST_MiddleName", '''') || '' '' || COALESCE(a."Amst_LastName", '''') as "Amst_LastName", a."AMST_AdmNo", a."AMST_RegistrationNo" 
from "Adm_M_Student" a inner join "adm_school_y_student" b on a."amst_id" = b."amst_id"
inner join "IVRM_Master_Country" c on a."AMST_PerCountry" = c."IVRMMC_Id"
where b."AMAY_ActiveFlag" = 1 and b."asmay_id" = ' || "ASMAY_ID" || ' and a."MI_Id" = ' || "mi_id" || ' ' || "flag_type" || '';
    ELSIF ("type" = 'state') THEN
        "query" := 'select COALESCE(a."AMST_FirstName", '''') || '' '' || COALESCE(a."AMST_MiddleName", '''') || '' '' || COALESCE(a."Amst_LastName", '''') as "Amst_LastName", a."AMST_AdmNo", a."AMST_RegistrationNo" 
from "Adm_M_Student" a 
inner join "ivrm_master_state" b on a."AMST_PerState" = b."IVRMMS_Id"
inner join "Adm_School_Y_Student" d on a."AMST_Id" = d."AMST_Id" 
where d."AMAY_ActiveFlag" = 1 and d."asmay_id" = ' || "ASMAY_ID" || ' and a."MI_Id" = ' || "mi_id" || ' ' || "flag_type" || '';
    END IF;

    RETURN QUERY EXECUTE "query";
END;
$$;