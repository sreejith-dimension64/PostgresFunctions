CREATE OR REPLACE FUNCTION "Exm"."EXM_SUB_SUBJECT_MARKS"(
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_MI_Id bigint,
    p_EME_Id bigint,
    p_AMST_Id TEXT,
    p_Flag TEXT
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "ISMS_Id" bigint,
    "ESTMPSSS_ObtainedMarks" numeric,
    "ESTMPSSS_ObtainedGrade" varchar,
    "ESTMPSSS_MaxMarks" numeric,
    "ESTMPSSS_PassFailFlg" varchar,
    "EMSS_SubSubjectName" varchar,
    "EMSS_Id" bigint,
    "EMSE_Id" bigint,
    "Overall" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMCA_Id BIGINT;
    v_EYC_Id BIGINT;
BEGIN
    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id   
        AND "ECAC_ActiveFlag" = 1
    LIMIT 1;
    
    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1
    LIMIT 1;
    
    IF p_Flag = '1' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id",
            A."ISMS_Id", 
            B."ESTMPSSS_ObtainedMarks",
            B."ESTMPSSS_ObtainedGrade",
            B."ESTMPSSS_MaxMarks",
            B."ESTMPSSS_PassFailFlg",
            CASE  
                WHEN C."EMSS_SubSubjectName" IS NULL THEN D."EMSE_SubExamName" 
                ELSE C."EMSS_SubSubjectName" 
            END AS "EMSS_SubSubjectName", 
            CASE  
                WHEN C."EMSS_Id" IS NULL THEN D."EMSE_Id" 
                ELSE C."EMSS_Id" 
            END AS "EMSS_Id",
            COALESCE(D."EMSE_Id", 0::bigint) AS "EMSE_Id",
            NULL::varchar AS "Overall"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
        INNER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" B ON A."ESTMPS_Id" = B."ESTMPS_Id" 
        LEFT JOIN "Exm"."Exm_Master_SubSubject" C ON C."EMSS_Id" = B."EMSS_Id"
        LEFT JOIN "Exm"."Exm_Master_SubExam" D ON B."EMSE_Id" = D."EMSE_Id"
        WHERE A."EME_Id" = p_EME_Id 
            AND A."ASMAY_Id" = p_ASMAY_Id  
            AND A."ASMCL_Id" = p_ASMCL_Id 
            AND A."ASMS_Id" = p_ASMS_Id 
            AND A."AMST_Id"::text = ANY(string_to_array(p_AMST_Id, ','));
    END IF;
    
    IF p_Flag = '2' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id",
            0::bigint AS "ISMS_Id",
            SUM(B."ESTMPSSS_ObtainedMarks") AS "ESTMPSSS_ObtainedMarks",
            NULL::varchar AS "ESTMPSSS_ObtainedGrade",
            SUM(B."ESTMPSSS_MaxMarks") AS "ESTMPSSS_MaxMarks",
            NULL::varchar AS "ESTMPSSS_PassFailFlg",
            NULL::varchar AS "EMSS_SubSubjectName",
            COALESCE(B."EMSS_Id", 0::bigint) AS "EMSS_Id",
            COALESCE(B."EMSE_Id", 0::bigint) AS "EMSE_Id",
            'Overall'::varchar AS "Overall"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
        INNER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" B ON A."ESTMPS_Id" = B."ESTMPS_Id" 
        INNER JOIN "Exm"."Exm_Yearly_Category" exc ON exc."ASMAY_Id" = A."ASMAY_Id" 
            AND A."ASMAY_Id" = p_ASMAY_Id 
            AND exc."EYC_ActiveFlg" = 1 
            AND exc."EMCA_Id" = v_EMCA_Id
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" eyc ON eyc."EYC_Id" = exc."EYC_Id" 
            AND eyc."EME_Id" = p_EME_Id  
            AND eyc."EYCE_ActiveFlg" = 1 
            AND eyc."EYC_Id" = v_EYC_Id
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" Eyck ON eyc."EYCE_Id" = Eyck."EYCE_Id"   
            AND Eyck."EYCES_ActiveFlg" = 1 
            AND Eyck."ISMS_Id" = A."ISMS_Id"
        WHERE A."EME_Id" = p_EME_Id 
            AND A."ASMAY_Id" = p_ASMAY_Id  
            AND A."ASMCL_Id" = p_ASMCL_Id 
            AND A."ASMS_Id" = p_ASMS_Id
            AND A."AMST_Id"::text = ANY(string_to_array(p_AMST_Id, ','))
        GROUP BY A."AMST_Id", B."EMSE_Id", B."EMSS_Id"
        
        UNION 
        
        SELECT 
            A."AMST_Id",
            0::bigint AS "ISMS_Id",
            SUM(B."ESTMPSSS_ObtainedMarks") AS "ESTMPSSS_ObtainedMarks",
            NULL::varchar AS "ESTMPSSS_ObtainedGrade",
            SUM(B."ESTMPSSS_MaxMarks") AS "ESTMPSSS_MaxMarks",
            NULL::varchar AS "ESTMPSSS_PassFailFlg",
            NULL::varchar AS "EMSS_SubSubjectName",
            COALESCE(B."EMSS_Id", 0::bigint) AS "EMSS_Id",
            COALESCE(B."EMSE_Id", 0::bigint) AS "EMSE_Id",
            'Total'::varchar AS "Overall"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
        INNER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" B ON A."ESTMPS_Id" = B."ESTMPS_Id" 
        INNER JOIN "Exm"."Exm_Yearly_Category" exc ON exc."ASMAY_Id" = A."ASMAY_Id" 
            AND A."ASMAY_Id" = p_ASMAY_Id 
            AND exc."EYC_ActiveFlg" = 1 
            AND exc."EMCA_Id" = v_EMCA_Id
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" eyc ON eyc."EYC_Id" = exc."EYC_Id" 
            AND eyc."EME_Id" = p_EME_Id  
            AND eyc."EYCE_ActiveFlg" = 1 
            AND eyc."EYC_Id" = v_EYC_Id
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" Eyck ON eyc."EYCE_Id" = Eyck."EYCE_Id"   
            AND Eyck."EYCES_ActiveFlg" = 1 
            AND Eyck."ISMS_Id" = A."ISMS_Id"
        WHERE A."EME_Id" = p_EME_Id 
            AND A."ASMAY_Id" = p_ASMAY_Id  
            AND A."ASMCL_Id" = p_ASMCL_Id 
            AND A."ASMS_Id" = p_ASMS_Id 
            AND Eyck."EYCES_AplResultFlg" = 1
            AND A."AMST_Id"::text = ANY(string_to_array(p_AMST_Id, ','))
        GROUP BY A."AMST_Id", B."EMSE_Id", B."EMSS_Id"
        
        UNION
        
        SELECT 
            A."AMST_Id",
            0::bigint AS "ISMS_Id",
            SUM(A."ESTMPS_ObtainedMarks") AS "ESTMPSSS_ObtainedMarks",
            NULL::varchar AS "ESTMPSSS_ObtainedGrade",
            SUM(A."ESTMPS_MaxMarks") AS "ESTMPSSS_MaxMarks",
            NULL::varchar AS "ESTMPSSS_PassFailFlg",
            NULL::varchar AS "EMSS_SubSubjectName",
            0::bigint AS "EMSS_Id",
            0::bigint AS "EMSE_Id",
            'SubTotal'::varchar AS "Overall"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
        INNER JOIN "Exm"."Exm_Yearly_Category" exc ON exc."ASMAY_Id" = A."ASMAY_Id" 
            AND A."ASMAY_Id" = p_ASMAY_Id 
            AND exc."EYC_ActiveFlg" = 1 
            AND exc."EMCA_Id" = v_EMCA_Id
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" eyc ON eyc."EYC_Id" = exc."EYC_Id" 
            AND eyc."EME_Id" = p_EME_Id  
            AND eyc."EYCE_ActiveFlg" = 1 
            AND eyc."EYC_Id" = v_EYC_Id
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" Eyck ON eyc."EYCE_Id" = Eyck."EYCE_Id"   
            AND Eyck."EYCES_ActiveFlg" = 1 
            AND Eyck."ISMS_Id" = A."ISMS_Id"
        WHERE A."EME_Id" = p_EME_Id 
            AND A."ASMAY_Id" = p_ASMAY_Id  
            AND A."ASMCL_Id" = p_ASMCL_Id 
            AND A."ASMS_Id" = p_ASMS_Id  
            AND Eyck."EYCES_AplResultFlg" = 0
            AND A."AMST_Id"::text = ANY(string_to_array(p_AMST_Id, ','))
        GROUP BY A."AMST_Id";
    END IF;
    
    RETURN;
END;
$$;