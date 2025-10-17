CREATE OR REPLACE FUNCTION "dbo"."getgroupdetails_Old" (
    p_MI_Id bigint,
    p_EYC_Id bigint,
    p_type TEXT
)
RETURNS TABLE (
    "empG_DistplayName" VARCHAR,
    "empG_GroupName" VARCHAR,
    "empsG_Order" INTEGER,
    "emE_Id" bigint,
    "emE_ExamName" VARCHAR,
    "emE_ExamOrder" INTEGER,
    "emE_ExamCode" VARCHAR,
    "empsgE_ForMaxMarkrs" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_type = 'getgroupdetails' THEN
        RETURN QUERY
        SELECT DISTINCT 
            c."EMPSG_DisplayName"::VARCHAR as "empG_DistplayName",
            c."EMPSG_GroupName"::VARCHAR as "empG_GroupName",
            c."EMPSG_Order"::INTEGER as "empsG_Order",
            NULL::bigint as "emE_Id",
            NULL::VARCHAR as "emE_ExamName",
            NULL::INTEGER as "emE_ExamOrder",
            NULL::VARCHAR as "emE_ExamCode",
            NULL::BOOLEAN as "empsgE_ForMaxMarkrs"
        FROM "Exm"."Exm_M_Promotion" a
        INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" c ON b."EMPS_Id" = c."EMPS_Id"
        WHERE a."EMP_ActiveFlag" = 1 
            AND a."MI_Id" = p_MI_Id 
            AND b."EMPS_ActiveFlag" = 1 
            AND a."EYC_Id" = p_EYC_Id
            AND c."EMPSG_ActiveFlag" = 1
        ORDER BY "empsG_Order";
        
    ELSIF p_type = 'getgroupexamdetails' THEN
        RETURN QUERY
        SELECT DISTINCT 
            c."EMPSG_GroupName"::VARCHAR as "empG_DistplayName",
            c."EMPSG_GroupName"::VARCHAR as "empG_GroupName",
            NULL::INTEGER as "empsG_Order",
            d."EME_Id"::bigint as "emE_Id",
            e."EME_ExamName"::VARCHAR as "emE_ExamName",
            e."EME_ExamOrder"::INTEGER as "emE_ExamOrder",
            e."EME_ExamCode"::VARCHAR as "emE_ExamCode",
            d."EMPSGE_ForMaxMarkrs"::BOOLEAN as "empsgE_ForMaxMarkrs"
        FROM "Exm"."Exm_M_Promotion" a
        INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" c ON b."EMPS_Id" = c."EMPS_Id"
        INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON c."EMPSG_Id" = d."EMPSG_Id"
        INNER JOIN "exm"."Exm_Master_Exam" e ON d."EME_Id" = e."EME_Id"
        WHERE a."EMP_ActiveFlag" = 1 
            AND a."MI_Id" = p_MI_Id 
            AND b."EMPS_ActiveFlag" = 1 
            AND a."EYC_Id" = p_EYC_Id
            AND c."EMPSG_ActiveFlag" = 1 
            AND d."EMPSGE_ActiveFlg" = 1
        ORDER BY "emE_ExamOrder";
    END IF;
END;
$$;