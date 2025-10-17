CREATE OR REPLACE FUNCTION "dbo"."GET_LOGIN_STUDENT_SIBLINGS"(
    p_AMST_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "STDNAME" text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_Id_NEW bigint;
BEGIN
    SELECT "AMST_Id" INTO v_AMST_Id_NEW 
    FROM "Adm_Master_Student_SiblingsDetails" 
    WHERE "AMSTS_Siblings_AMST_ID" = p_AMST_Id;

    RETURN QUERY
    SELECT DISTINCT 
        A."AMST_Id",
        (COALESCE(A."AMST_FirstName", ' ') || ' ' || COALESCE(A."AMST_MiddleName", ' ') || ' ' || COALESCE(A."AMST_LastName", ' '))::text AS "STDNAME"
    FROM "adm_M_student" AS A
    INNER JOIN "Adm_Master_Student_SiblingsDetails" AS B ON A."AMST_Id" = B."AMSTS_Siblings_AMST_ID"
    WHERE B."AMST_Id" = v_AMST_Id_NEW;
END;
$$;