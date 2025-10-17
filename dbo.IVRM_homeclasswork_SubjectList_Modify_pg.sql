CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeclasswork_SubjectList_Modify"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_Type varchar(20),
    p_UserId bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_Type = 'HomeWork' THEN
        RETURN QUERY
        SELECT DISTINCT B."ISMS_Id", C."ISMS_SubjectName"
        FROM "Exm"."Exm_Login_Privilege" A 
        INNER JOIN "Exm"."Exm_Login_Privilege_Subjects" B ON A."ELP_Id" = B."ELP_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "IVRM_Staff_User_Login" D ON D."IVRMSTAUL_Id" = A."Login_Id"
        WHERE A."MI_Id" = p_MI_Id 
        AND A."ASMAY_Id" = p_ASMAY_Id 
        AND B."ASMCL_Id" = p_ASMCL_Id 
        AND B."ASMS_Id" = p_ASMS_Id 
        AND B."ELPS_ActiveFlg" = 1
        AND D."Id" = p_UserId;
        
    ELSIF p_Type = 'ClassWork' THEN
        RETURN QUERY
        SELECT DISTINCT B."ISMS_Id", C."ISMS_SubjectName"
        FROM "Exm"."Exm_Login_Privilege" A 
        INNER JOIN "Exm"."Exm_Login_Privilege_Subjects" B ON A."ELP_Id" = B."ELP_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "IVRM_Staff_User_Login" D ON D."IVRMSTAUL_Id" = A."Login_Id"
        WHERE A."MI_Id" = p_MI_Id 
        AND A."ASMAY_Id" = p_ASMAY_Id 
        AND B."ASMCL_Id" = p_ASMCL_Id 
        AND B."ASMS_Id" = p_ASMS_Id 
        AND B."ELPS_ActiveFlg" = 1
        AND D."Id" = p_UserId;
        
    END IF;
    
    RETURN;
END;
$$;