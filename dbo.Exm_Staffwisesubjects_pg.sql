CREATE OR REPLACE FUNCTION "dbo"."Exm_Staffwisesubjects"(
    "MI_ID" VARCHAR(100), 
    "ASMAY_ID" VARCHAR(100),
    "Login_Id" VARCHAR(100)
)
RETURNS TABLE(
    "ISMS_SubjectName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN 

    RETURN QUERY
    SELECT DISTINCT c."ISMS_SubjectName"
    FROM "Exm"."Exm_Login_Privilege" a
    INNER JOIN "Exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
    INNER JOIN "IVRM_Master_Subjects" c ON c."ISMS_Id" = b."ISMS_Id"
    INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."Login_Id" 
    WHERE a."MI_Id" = "MI_ID" 
        AND a."ASMAY_Id" = "ASMAY_ID" 
        AND a."Login_Id" = "Login_Id";

END;
$$;