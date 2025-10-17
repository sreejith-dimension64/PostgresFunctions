CREATE OR REPLACE FUNCTION "dbo"."Adm_Students_NotPromoted_CACY"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "StudentName" text,
    "AMST_AdmNo" character varying,
    "AMST_RegistrationNo" character varying
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_PACY_Id bigint;
BEGIN
    SELECT "ASMAY_Id" INTO v_PACY_Id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id 
    AND "ASMAY_Order" = (
        SELECT "ASMAY_Order" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id
    ) - 1;

    RETURN QUERY
    SELECT c."AMST_Id",
           (COALESCE(c."AMST_FirstName", '') || ' ' || COALESCE(c."AMST_MiddleName", '') || ' ' || COALESCE(c."AMST_LastName", '')) AS "StudentName",
           c."AMST_AdmNo",
           c."AMST_RegistrationNo"
    FROM (
        SELECT DISTINCT b."AMST_Id" 
        FROM "adm_M_student" a 
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        WHERE b."ASMAY_Id" = v_PACY_Id 
        AND a."MI_Id" = p_MI_Id

        EXCEPT

        SELECT DISTINCT b."AMST_Id" 
        FROM "adm_M_student" a 
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        WHERE b."ASMAY_Id" = p_ASMAY_Id 
        AND a."MI_Id" = p_MI_Id
    ) AS d 
    INNER JOIN "Adm_M_Student" c ON d."AMST_Id" = c."AMST_Id" 
    AND c."AMST_SOL" = 'S' 
    AND c."MI_Id" = p_MI_Id;

    RETURN;
END;
$$;