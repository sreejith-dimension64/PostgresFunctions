CREATE OR REPLACE FUNCTION "dbo"."College_Lesson_Planner_Staff_Transaction_Report"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMCO_Id" TEXT,
    "AMB_Id" TEXT,
    "AMSE_Id" TEXT,
    "ACMS_Id" TEXT,
    "HRME_Id" TEXT,
    "Flag" TEXT
)
RETURNS TABLE(
    "isms_id" BIGINT,
    "allocateddate" VARCHAR,
    "topicname" VARCHAR,
    "subjectname" VARCHAR,
    "staffname" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF "Flag" = '1' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            a."ISMS_Id" AS "isms_id",
            TO_CHAR(a."LPLPC_LPDate", 'DD/MM/YYYY') AS "allocateddate",
            b."LPMT_TopicName" AS "topicname",
            NULL::VARCHAR AS "subjectname",
            (COALESCE(i."HRME_EmployeeFirstName", '') || ' ' || COALESCE(i."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(i."HRME_EmployeeLastName", '')) AS "staffname"
        FROM "CLG"."LP_LessonPlanner_College" a
        INNER JOIN "LP_Master_Topic" b ON a."LPMT_Id" = b."LPMT_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id"
        INNER JOIN "HR_Master_Employee" i ON i."HRME_Id" = a."HRME_Id"
        INNER JOIN "LP_Master_MainTopic" j ON j."LPMMT_Id" = b."LPMMT_Id" AND j."ISMS_Id" = a."ISMS_Id" AND j."ISMS_Id" = d."ISMS_Id"
        WHERE a."ASMAY_Id"::TEXT = "ASMAY_Id" 
            AND a."AMCO_Id"::TEXT = "AMCO_Id" 
            AND a."AMB_Id"::TEXT = "AMB_Id" 
            AND a."ACMS_Id"::TEXT = "ACMS_Id" 
            AND a."AMSE_Id"::TEXT = "AMSE_Id"
            AND a."HRME_Id"::TEXT = "HRME_Id" 
            AND a."MI_Id"::TEXT = "MI_Id" 
            AND a."LPLPC_ActiveFlag" = true 
            AND b."LPMT_ActiveFlag" = true 
            AND d."ISMS_ActiveFlag" = true;
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT 
            a."ISMS_Id" AS "isms_id",
            NULL::VARCHAR AS "allocateddate",
            NULL::VARCHAR AS "topicname",
            (COALESCE(d."ISMS_SubjectName", '') || ' : ' || COALESCE(d."ISMS_SubjectCode", '')) AS "subjectname",
            (COALESCE(i."HRME_EmployeeFirstName", '') || ' ' || COALESCE(i."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(i."HRME_EmployeeLastName", '')) AS "staffname"
        FROM "clg"."LP_LessonPlanner_College" a
        INNER JOIN "LP_Master_Topic" b ON a."LPMT_Id" = b."LPMT_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id"
        INNER JOIN "HR_Master_Employee" i ON i."HRME_Id" = a."HRME_Id"
        INNER JOIN "LP_Master_MainTopic" j ON j."LPMMT_Id" = b."LPMMT_Id" AND j."ISMS_Id" = a."ISMS_Id" AND j."ISMS_Id" = d."ISMS_Id"
        WHERE a."ASMAY_Id"::TEXT = "ASMAY_Id" 
            AND a."AMCO_Id"::TEXT = "AMCO_Id" 
            AND a."AMB_Id"::TEXT = "AMB_Id" 
            AND a."ACMS_Id"::TEXT = "ACMS_Id" 
            AND a."AMSE_Id"::TEXT = "AMSE_Id"
            AND a."HRME_Id"::TEXT = "HRME_Id" 
            AND a."MI_Id"::TEXT = "MI_Id" 
            AND a."LPLPC_ActiveFlag" = true 
            AND b."LPMT_ActiveFlag" = true 
            AND d."ISMS_ActiveFlag" = true;
    
    END IF;

    RETURN;

END;
$$;