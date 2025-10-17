CREATE OR REPLACE FUNCTION "Exm_Students_SkillsActivities_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_ECSA_Id TEXT,
    p_ECT_Id TEXT,
    p_ECACTA_Id TEXT,
    p_ECACT_Id TEXT,
    p_EME_Id TEXT,
    p_flag VARCHAR(20),
    p_exam_termwise_flag VARCHAR(20),
    p_ECS_Id TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "StudentName" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMAY_RollNo" TEXT,
    col5 INTEGER,
    col6 TEXT,
    col7 INTEGER,
    col8 INTEGER,
    col9 NUMERIC,
    col10 INTEGER,
    col11 TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_flag = 'Skills') THEN
    
        IF (p_exam_termwise_flag = 'ExamWise') THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                n."AMST_Id",
                CONCAT(COALESCE(m."AMST_FirstName",''),' ',COALESCE(m."AMST_MiddleName",''),' ',COALESCE(m."AMST_LastName",'')) AS "StudentName",
                m."AMST_RegistrationNo",
                n."AMAY_RollNo",
                COALESCE(o."ECS_Id",0) AS "ECS_Id",
                p."ECSA_SkillArea",
                COALESCE(o."EMGR_Id",0) AS "EMGR_Id",
                p."ECSA_SkillOrder",
                COALESCE(o."ECST_Score",0) AS "ECST_Score",
                COALESCE(o."ECST_Id",0) AS "ECST_Id",
                CASE WHEN (o."ECST_Score" IS NULL OR o."ECST_Score" = 0) THEN 'False'
                     ELSE 'True' 
                END AS "ECST_ActiveFlag"
            FROM "Adm_M_Student" m
            INNER JOIN "Adm_School_Y_Student" n ON m."AMST_Id" = n."AMST_Id" 
                AND m."AMST_SOL" = 's' 
                AND m."AMST_ActiveFlag" = 1 
                AND n."AMAY_ActiveFlag" = 1
            LEFT JOIN "exm"."Exm_CCE_SKILLS_Transaction" o ON o."AMST_Id" = n."AMST_Id" 
                AND n."ASMAY_Id" = o."ASMAY_Id" 
                AND o."ASMS_Id" = n."ASMS_Id"
                AND o."ECSA_Id" = ANY(STRING_TO_ARRAY(p_ECSA_Id, ',')::INTEGER[])
                AND o."EME_Id" = p_EME_Id::INTEGER
            LEFT JOIN "exm"."Exm_CCE_SKILLS_AREA" p ON p."ECSA_Id" = o."ECSA_Id"
            WHERE m."MI_Id" = p_MI_Id::INTEGER 
                AND n."ASMAY_Id" = p_ASMAY_Id::INTEGER 
                AND n."ASMCL_Id" = p_ASMCL_Id::INTEGER 
                AND n."ASMS_Id" = p_ASMS_Id::INTEGER
            ORDER BY n."AMAY_RollNo";
            
        ELSE
        
            RETURN QUERY
            SELECT DISTINCT 
                n."AMST_Id",
                CONCAT(COALESCE(m."AMST_FirstName",''),' ',COALESCE(m."AMST_MiddleName",''),' ',COALESCE(m."AMST_LastName",'')) AS "StudentName",
                m."AMST_RegistrationNo",
                n."AMAY_RollNo",
                COALESCE(o."ECSA_Id",0) AS "ECSA_Id",
                p."ECSA_SkillArea",
                COALESCE(o."EMGR_Id",0) AS "EMGR_Id",
                p."ECSA_SkillOrder",
                COALESCE(o."ECST_Score",0) AS "ECST_Score",
                COALESCE(o."ECST_Id",0) AS "ECST_Id",
                CASE WHEN (o."ECST_Score" IS NULL OR o."ECST_Score" = 0) THEN 'False'
                     ELSE 'True' 
                END AS "ECST_ActiveFlag"
            FROM "Adm_M_Student" m
            INNER JOIN "Adm_School_Y_Student" n ON m."AMST_Id" = n."AMST_Id" 
                AND m."AMST_SOL" = 's' 
                AND m."AMST_ActiveFlag" = 1 
                AND n."AMAY_ActiveFlag" = 1
            LEFT JOIN "exm"."Exm_CCE_SKILLS_Transaction" o ON o."AMST_Id" = n."AMST_Id" 
                AND n."ASMAY_Id" = o."ASMAY_Id" 
                AND o."ASMS_Id" = n."ASMS_Id"
                AND o."ECSA_Id" = ANY(STRING_TO_ARRAY(p_ECSA_Id, ',')::INTEGER[])
                AND o."ECT_Id" = p_ECT_Id::INTEGER
                AND o."ECS_Id" = p_ECS_Id::INTEGER
            LEFT JOIN "exm"."Exm_CCE_SKILLS_AREA" p ON p."ECSA_Id" = o."ECSA_Id"
            WHERE m."MI_Id" = p_MI_Id::INTEGER 
                AND n."ASMAY_Id" = p_ASMAY_Id::INTEGER 
                AND n."ASMCL_Id" = p_ASMCL_Id::INTEGER 
                AND n."ASMS_Id" = p_ASMS_Id::INTEGER
            ORDER BY n."AMAY_RollNo";
            
        END IF;
        
    ELSIF (p_flag = 'Activities') THEN
    
        IF (p_exam_termwise_flag = 'ExamWise') THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                n."AMST_Id",
                CONCAT(COALESCE(m."AMST_FirstName",''),' ',COALESCE(m."AMST_MiddleName",''),' ',COALESCE(m."AMST_LastName",'')) AS "StudentName",
                m."AMST_RegistrationNo",
                n."AMAY_RollNo",
                COALESCE(o."ECACT_Id",0) AS "ECACT_Id",
                q."ECACTA_SkillArea",
                COALESCE(o."EMGR_Id",0) AS "EMGR_Id",
                q."ECACTA_SkillOrder",
                COALESCE(o."ECSACTT_Score",0) AS "ECSACTT_Score",
                COALESCE(o."ECSACTT_Id",0) AS "ECSACTT_Id",
                CASE WHEN (o."ECSACTT_Score" IS NULL OR o."ECSACTT_Score" = 0) THEN 'False'
                     ELSE 'True' 
                END AS "ECSACTT_ActiveFlag"
            FROM "Adm_M_Student" m
            INNER JOIN "Adm_School_Y_Student" n ON m."AMST_Id" = n."AMST_Id" 
                AND m."AMST_SOL" = 's' 
                AND m."AMST_ActiveFlag" = 1 
                AND n."AMAY_ActiveFlag" = 1
            LEFT JOIN "exm"."Exm_CCE_Activities_Transaction" o ON o."AMST_Id" = n."AMST_Id" 
                AND o."ASMAY_Id" = n."ASMAY_Id" 
                AND o."ASMCL_Id" = n."ASMCL_Id" 
                AND o."ASMS_Id" = n."ASMS_Id"
                AND o."ECACTA_Id" = ANY(STRING_TO_ARRAY(p_ECACTA_Id, ',')::INTEGER[])
                AND o."ECACT_Id" = p_ECACT_Id::INTEGER
                AND o."EME_Id" = p_EME_Id::INTEGER
            LEFT JOIN "exm"."Exm_CCE_Activities" p ON p."ECACT_Id" = o."ECACT_Id"
            LEFT JOIN "exm"."Exm_CCE_Activities_AREA" q ON q."ECACTA_Id" = o."ECACTA_Id"
            WHERE m."MI_Id" = p_MI_Id::INTEGER 
                AND n."ASMAY_Id" = p_ASMAY_Id::INTEGER 
                AND n."ASMCL_Id" = p_ASMCL_Id::INTEGER 
                AND n."ASMS_Id" = p_ASMS_Id::INTEGER
            ORDER BY n."AMAY_RollNo";
            
        ELSE
        
            RETURN QUERY
            SELECT DISTINCT 
                n."AMST_Id",
                CONCAT(COALESCE(m."AMST_FirstName",''),' ',COALESCE(m."AMST_MiddleName",''),' ',COALESCE(m."AMST_LastName",'')) AS "StudentName",
                m."AMST_RegistrationNo",
                n."AMAY_RollNo",
                COALESCE(o."ECACT_Id",0) AS "ECACT_Id",
                q."ECACTA_SkillArea",
                COALESCE(o."EMGR_Id",0) AS "EMGR_Id",
                q."ECACTA_SkillOrder",
                COALESCE(o."ECSACTT_Score",0) AS "ECSACTT_Score",
                COALESCE(o."ECSACTT_Id",0) AS "ECSACTT_Id",
                CASE WHEN (o."ECSACTT_Score" IS NULL OR o."ECSACTT_Score" = 0) THEN 'False'
                     ELSE 'True' 
                END AS "ECSACTT_ActiveFlag"
            FROM "Adm_M_Student" m
            INNER JOIN "Adm_School_Y_Student" n ON m."AMST_Id" = n."AMST_Id" 
                AND m."AMST_SOL" = 's' 
                AND m."AMST_ActiveFlag" = 1 
                AND n."AMAY_ActiveFlag" = 1
            LEFT JOIN "exm"."Exm_CCE_Activities_Transaction" o ON o."AMST_Id" = n."AMST_Id" 
                AND o."ASMAY_Id" = n."ASMAY_Id" 
                AND o."ASMCL_Id" = n."ASMCL_Id" 
                AND o."ASMS_Id" = n."ASMS_Id"
                AND o."ECACTA_Id" = ANY(STRING_TO_ARRAY(p_ECACTA_Id, ',')::INTEGER[])
                AND o."ECACT_Id" = p_ECACT_Id::INTEGER
                AND o."ECT_Id" = p_ECT_Id::INTEGER
            LEFT JOIN "exm"."Exm_CCE_Activities" p ON p."ECACT_Id" = o."ECACT_Id"
            LEFT JOIN "exm"."Exm_CCE_Activities_AREA" q ON q."ECACTA_Id" = o."ECACTA_Id"
            WHERE m."MI_Id" = p_MI_Id::INTEGER 
                AND n."ASMAY_Id" = p_ASMAY_Id::INTEGER 
                AND n."ASMCL_Id" = p_ASMCL_Id::INTEGER 
                AND n."ASMS_Id" = p_ASMS_Id::INTEGER
            ORDER BY n."AMAY_RollNo";
            
        END IF;
        
    END IF;

END;
$$;