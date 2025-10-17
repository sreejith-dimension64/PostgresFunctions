CREATE OR REPLACE FUNCTION "Exam_DisplaynameGroupnamedetails"(
    p_MI_ID BIGINT,
    p_EYC_ID BIGINT,
    p_flag BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMS_Id BIGINT,
    p_EMPSG_ID BIGINT
)
RETURNS TABLE(
    "EMPSG_DisplayName" VARCHAR,
    "EMPSG_Order" INTEGER,
    "EMPSG_GroupName" VARCHAR,
    "EMPSG_Id" BIGINT,
    "EME_ID" BIGINT,
    "EME_ExamName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF(p_flag = 1) THEN
        RETURN QUERY
        SELECT c."EMPSG_DisplayName", c."EMPSG_Order", c."EMPSG_GroupName", c."EMPSG_Id",
               NULL::BIGINT AS "EME_ID", NULL::VARCHAR AS "EME_ExamName"
        FROM "Exm"."Exm_M_Promotion" a    
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id"     
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" c ON b."EMPS_Id" = c."EMPS_Id"    
        WHERE a."EMP_ActiveFlag" = 1 AND b."EMPS_ActiveFlag" = 1 AND c."EMPSG_ActiveFlag" = 1 
        AND a."EYC_ID" = p_EYC_ID    
        AND a."MI_Id" = p_MI_ID;

    ELSIF(p_flag = 2) THEN
        RETURN QUERY
        SELECT DISTINCT NULL::VARCHAR AS "EMPSG_DisplayName", NULL::INTEGER AS "EMPSG_Order", 
               NULL::VARCHAR AS "EMPSG_GroupName", NULL::BIGINT AS "EMPSG_Id",
               H."EME_ID", H."EME_ExamName"    
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A     
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"    
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"    
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"    
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"    
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"    
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"    
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"    
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"    
        WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id AND A."ASMCL_Id" = p_ASMCL_Id 
        AND A."ASMS_Id" = p_ASMS_Id    
        AND F."EYC_Id" = p_EYC_Id AND C."EMPSG_ID" = p_EMPSG_ID;

    END IF;

    RETURN;

END;
$$;