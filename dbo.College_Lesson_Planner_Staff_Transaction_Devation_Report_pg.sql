CREATE OR REPLACE FUNCTION "dbo"."College_Lesson_Planner_Staff_Transaction_Devation_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_HRME_Id TEXT,
    p_Flag TEXT
)
RETURNS TABLE(
    isms_id INTEGER,
    datediffcount INTEGER,
    allocateddate VARCHAR(10),
    takendate VARCHAR(10),
    topicname VARCHAR,
    staffname TEXT,
    subjectname TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_Flag = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."ISMS_Id" AS isms_id,
            (a."LPLPC_CTDate"::DATE - a."LPLPC_LPDate"::DATE) AS datediffcount,
            TO_CHAR(a."LPLPC_LPDate", 'DD/MM/YYYY') AS allocateddate,
            TO_CHAR(a."LPLPC_CTDate", 'DD/MM/YYYY') AS takendate,
            b."LPMT_TopicName" AS topicname,
            (COALESCE(i."HRME_EmployeeFirstName", '') || ' ' || COALESCE(i."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(i."HRME_EmployeeLastName", '')) AS staffname,
            NULL::TEXT AS subjectname
        FROM "clg"."LP_LessonPlanner_College" a
        INNER JOIN "LP_Master_Topic" b ON a."LPMT_Id" = b."LPMT_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id"
        INNER JOIN "HR_Master_Employee" i ON i."HRME_Id" = a."HRME_Id"
        INNER JOIN "LP_Master_MainTopic" j ON j."LPMMT_Id" = b."LPMMT_Id" 
            AND j."ISMS_Id" = a."ISMS_Id" 
            AND j."ISMS_Id" = d."ISMS_Id"
        WHERE a."ASMAY_Id"::TEXT = p_ASMAY_Id 
            AND a."AMCO_Id"::TEXT = p_AMCO_Id 
            AND a."AMB_Id"::TEXT = p_AMB_Id 
            AND a."ACMS_Id"::TEXT = p_ACMS_Id 
            AND a."AMSE_Id"::TEXT = p_AMSE_Id
            AND a."HRME_Id"::TEXT = p_HRME_Id 
            AND a."MI_Id"::TEXT = p_MI_Id 
            AND a."LPLPC_ActiveFlag" = true 
            AND b."LPMT_ActiveFlag" = true 
            AND d."ISMS_ActiveFlag" = true
            AND a."LPLPC_ClassTakenFlg" = true;
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            a."ISMS_Id" AS isms_id,
            NULL::INTEGER AS datediffcount,
            NULL::VARCHAR(10) AS allocateddate,
            NULL::VARCHAR(10) AS takendate,
            NULL::VARCHAR AS topicname,
            (COALESCE(i."HRME_EmployeeFirstName", '') || ' ' || COALESCE(i."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(i."HRME_EmployeeLastName", '')) AS staffname,
            (COALESCE(d."ISMS_SubjectName", '') || ' : ' || COALESCE(d."ISMS_SubjectCode", '')) AS subjectname
        FROM "clg"."LP_LessonPlanner_College" a
        INNER JOIN "LP_Master_Topic" b ON a."LPMT_Id" = b."LPMT_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id"
        INNER JOIN "HR_Master_Employee" i ON i."HRME_Id" = a."HRME_Id"
        INNER JOIN "LP_Master_MainTopic" j ON j."LPMMT_Id" = b."LPMMT_Id" 
            AND j."ISMS_Id" = a."ISMS_Id" 
            AND j."ISMS_Id" = d."ISMS_Id"
        WHERE a."ASMAY_Id"::TEXT = p_ASMAY_Id 
            AND a."AMCO_Id"::TEXT = p_AMCO_Id 
            AND a."AMB_Id"::TEXT = p_AMB_Id 
            AND a."ACMS_Id"::TEXT = p_ACMS_Id 
            AND a."AMSE_Id"::TEXT = p_AMSE_Id
            AND a."HRME_Id"::TEXT = p_HRME_Id 
            AND a."MI_Id"::TEXT = p_MI_Id 
            AND a."LPLPC_ActiveFlag" = true 
            AND b."LPMT_ActiveFlag" = true 
            AND d."ISMS_ActiveFlag" = true
            AND a."LPLPC_ClassTakenFlg" = true;
    END IF;

    RETURN;
END;
$$;