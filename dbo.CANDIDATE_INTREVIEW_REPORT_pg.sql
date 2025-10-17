CREATE OR REPLACE FUNCTION "dbo"."CANDIDATE_INTREVIEW_REPORT"(
    p_type TEXT,
    p_round TEXT,
    p_grade TEXT,
    p_MI_Id BIGINT,
    p_fromdate VARCHAR(10),
    p_todate VARCHAR(10)
)
RETURNS TABLE(
    "hrcisC_Id" BIGINT,
    "hrcD_Id" BIGINT,
    "hrcD_FullName" TEXT,
    "hrcD_FirstName" TEXT,
    "hrcD_MiddleName" TEXT,
    "hrcD_LastName" TEXT,
    "hrcisC_InterviewRounds" TEXT,
    "hrcisC_InterviewDateTime" TIMESTAMP,
    "hrcisC_InterviewVenue" TEXT,
    "hrcisC_Interviewer" BIGINT,
    "hrmE_EmployeeFirstName" TEXT,
    "hrmE_EmployeeMiddleName" TEXT,
    "hrmE_EmployeeLastName" TEXT,
    "hrcisC_NotifyEmail" TEXT,
    "hrcisC_NotifySMS" TEXT,
    "hrcis_InterviewFeedBack" TEXT,
    "hrcis_CandidateStatus" TEXT,
    "hrcmG_GradeName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_extra TEXT;
BEGIN
    IF p_round = '0' THEN
        IF p_type != 'All' THEN
            IF p_grade != '0' OR p_grade != '0' THEN
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND B."HRCISC_Status" = p_type 
                    AND A."MI_Id" = p_MI_Id 
                    AND G."HRCMG_Id"::TEXT = p_grade;
            ELSE
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND B."HRCISC_Status" = p_type 
                    AND A."MI_Id" = p_MI_Id;
            END IF;
        ELSE
            IF p_grade != '0' OR p_grade != '0' THEN
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND A."MI_Id" = p_MI_Id 
                    AND G."HRCMG_Id"::TEXT = p_grade;
            ELSE
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND A."MI_Id" = p_MI_Id;
            END IF;
        END IF;
    ELSE
        IF p_type != 'All' THEN
            IF p_grade != '0' OR p_grade != '0' THEN
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND B."HRCISC_Status" = p_type 
                    AND B."HRCISC_InterviewRounds" = p_round 
                    AND A."MI_Id" = p_MI_Id 
                    AND G."HRCMG_Id"::TEXT = p_grade;
            ELSE
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND B."HRCISC_Status" = p_type 
                    AND B."HRCISC_InterviewRounds" = p_round 
                    AND A."MI_Id" = p_MI_Id;
            END IF;
        ELSE
            IF p_grade != '0' OR p_grade != '0' THEN
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND B."HRCISC_InterviewRounds" = p_round 
                    AND A."MI_Id" = p_MI_Id 
                    AND G."HRCMG_Id"::TEXT = p_grade;
            ELSE
                RETURN QUERY
                SELECT 
                    B."HRCISC_Id",
                    A."HRCD_Id",
                    (CASE WHEN A."HRCD_FirstName" IS NULL OR A."HRCD_FirstName" = '' THEN '' ELSE A."HRCD_FirstName" END ||
                     CASE WHEN A."HRCD_MiddleName" IS NULL OR A."HRCD_MiddleName" = '' OR A."HRCD_MiddleName" = '0' THEN '' ELSE ' ' || A."HRCD_MiddleName" END ||
                     CASE WHEN A."HRCD_LastName" IS NULL OR A."HRCD_LastName" = '' OR A."HRCD_LastName" = '0' THEN '' ELSE ' ' || A."HRCD_LastName" END)::TEXT,
                    A."HRCD_FirstName",
                    A."HRCD_MiddleName",
                    A."HRCD_LastName",
                    B."HRCISC_InterviewRounds",
                    B."HRCISC_InterviewDateTime",
                    B."HRCISC_InterviewVenue",
                    B."HRCISC_Interviewer",
                    D."HRME_EmployeeFirstName",
                    D."HRME_EmployeeMiddleName",
                    D."HRME_EmployeeLastName",
                    B."HRCISC_NotifyEmail",
                    B."HRCISC_NotifySMS",
                    G."HRCIS_InterviewFeedBack",
                    G."HRCIS_CandidateStatus",
                    H."HRCMG_GradeName"
                FROM "HR_Candidate_Details" A
                INNER JOIN "HR_Candidate_InterviewSchedule" B ON A."HRCD_Id" = B."HRCD_Id"
                INNER JOIN "IVRM_Staff_User_Login" C ON C."Id" = B."HRCISC_Interviewer"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = C."Emp_Code"
                INNER JOIN "Master_Institution" E ON E."MI_Id" = A."MI_Id"
                INNER JOIN "HR_Master_Jobs" F ON F."HRMJ_Id" = A."HRMJ_Id"
                INNER JOIN "HR_Candidate_InterviewStatus" G ON A."HRCD_Id" = G."HRCD_Id" AND B."HRCISC_Interviewer" = G."IVRMUL_Id"
                LEFT JOIN "HR_Candidate_Master_Grade" H ON H."HRCMG_Id" = G."HRCMG_Id"
                WHERE B."HRCISC_InterviewDateTime" >= p_fromdate::TIMESTAMP 
                    AND B."HRCISC_InterviewDateTime" <= p_todate::TIMESTAMP 
                    AND B."HRCISC_InterviewRounds" = p_round 
                    AND A."MI_Id" = p_MI_Id;
            END IF;
        END IF;
    END IF;

    RETURN;
END;
$$;