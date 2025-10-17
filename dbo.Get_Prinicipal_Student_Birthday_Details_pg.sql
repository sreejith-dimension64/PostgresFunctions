CREATE OR REPLACE FUNCTION "dbo"."Get_Prinicipal_Student_Birthday_Details"(p_MI_Id BIGINT)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ClassName" VARCHAR,
    "SectionName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMAY_Id BIGINT;
BEGIN

    SELECT "ASMAY_Id" INTO v_ASMAY_Id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id 
    AND "Is_Active" = 1 
    AND (CURRENT_DATE BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date");

    RETURN QUERY
    SELECT DISTINCT A."AMST_Id",
        (COALESCE(A."AMST_FirstName", '') || ' ' || COALESCE(A."AMST_MiddleName", '') || ' ' || COALESCE(A."AMST_LastName", '')) AS "StudentName",
        A."AMST_AdmNo",
        D."ASMCL_ClassName" AS "ClassName",
        E."ASMC_SectionName" AS "SectionName"
    FROM "Adm_M_Student" A 
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
    WHERE A."AMST_SOL" = 'S' 
    AND A."AMST_ActiveFlag" = 1 
    AND B."AMAY_ActiveFlag" = 1 
    AND A."MI_Id" = p_MI_Id 
    AND B."ASMAY_Id" = v_ASMAY_Id;

    RETURN;

END;
$$;