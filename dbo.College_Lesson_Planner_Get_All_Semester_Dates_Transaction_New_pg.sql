CREATE OR REPLACE FUNCTION "dbo"."College_Lesson_Planner_Get_All_Semester_Dates_Transaction_New"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_HRME_Id TEXT,
    p_ISMS_Id TEXT
)
RETURNS TABLE(
    alldates TIMESTAMP,
    topicname VARCHAR,
    lplpC_Id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        a."LPLPC_LPDate" AS alldates, 
        c."LPMT_TopicName" AS topicname, 
        a."LPLPC_Id" AS lplpC_Id 
    FROM "CLG"."LP_LessonPlanner_College" a 
    INNER JOIN "IVRM_Master_Subjects" b ON a."ISMS_Id" = b."ISMS_Id"
    INNER JOIN "LP_Master_Topic" c ON c."LPMT_Id" = a."LPMT_Id"
    INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "CLG"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" i ON i."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "LP_Master_MainTopic" h ON h."ISMS_Id" = a."ISMS_Id" 
        AND h."ISMS_Id" = b."ISMS_Id" 
        AND h."LPMMT_Id" = c."LPMMT_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMB_Id" = p_AMB_Id 
        AND a."AMSE_Id" = p_AMSE_Id 
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."HRME_Id" = p_HRME_Id 
        AND a."ISMS_Id" = p_ISMS_Id 
        AND a."LPLPC_ClassTakenFlg" = 0 
        AND a."LPLPC_LPDate" <= CURRENT_TIMESTAMP;

END;
$$;