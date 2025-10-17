CREATE OR REPLACE FUNCTION "CLG"."HL_GetStudent_List"(
    p_MI_Id bigint,
    p_Type text
)
RETURNS TABLE(
    "StudentName" text,
    "StudentId" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF(p_Type='School') THEN
    
        RETURN QUERY
        SELECT 
            CAST(NULL AS text) AS "StudentName",
            CAST(NULL AS bigint) AS "StudentId"
        FROM "CLG"."adm_master_college_student"
        WHERE FALSE;
        
    ELSE
    
        RETURN QUERY
        SELECT 
            COALESCE(a."AMCST_FirstName",'')||' '||COALESCE(a."AMCST_MiddleName",'')||' '||COALESCE(a."AMCST_LastName",'') AS "StudentName",
            a."AMCST_Id" AS "StudentId"
        FROM "CLG"."adm_master_college_student" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id"=b."AMCST_Id"
        WHERE a."MI_Id"=p_MI_Id 
            AND b."ACYST_ActiveFlag"=1 
            AND a."AMCST_ActiveFlag"=1 
            AND a."AMCST_SOL"='S';
    
    END IF;

END;
$$;