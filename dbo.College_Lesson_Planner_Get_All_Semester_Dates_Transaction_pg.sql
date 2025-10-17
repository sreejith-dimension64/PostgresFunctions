CREATE OR REPLACE FUNCTION "dbo"."College_Lesson_Planner_Get_All_Semester_Dates_Transaction"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_HRME_Id TEXT
)
RETURNS TABLE(
    alldates TIMESTAMP,
    topicname VARCHAR,
    lpcswa_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."LPCSWA_AllocatedDate" AS alldates,
        b."LPMT_TopicName" AS topicname,
        a."LPCSWA_Id" AS lpcswa_id
    FROM 
        "Clg"."Exm_Lesson_Planner_Staff_Work_Allocation" a
        INNER JOIN "exm"."Lesson_Planner_Master_Topic" b ON a."LPMT_Id" = b."LPMT_Id"
    WHERE 
        a."MI_Id" = p_MI_Id
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id
        AND a."AMB_Id" = p_AMB_Id
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id
        AND a."HRME_Id" = p_HRME_Id
        AND a."LPCSWA_Flag" = 0
        AND a."LPCSWA_AllocatedDate" <= CURRENT_TIMESTAMP;
END;
$$;