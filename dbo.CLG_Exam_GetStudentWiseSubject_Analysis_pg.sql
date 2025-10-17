CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_GetStudentWiseSubject_Analysis"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id text,
    p_AMSE_Id bigint,
    p_ACMS_Id bigint,
    p_EME_Id bigint,
    p_ACST_Id bigint,
    p_ACSS_Id bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "countTotalStudents" bigint,
    "TotalStudents" text,
    "ECYSES_SubjectOrder" integer,
    "ISMS_SubjectName" text,
    "EmployeeName" text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_ECYS_Id INT;
    v_ECYSE_Id BIGINT;
    v_ACST_Id bigint;
    v_ACSS_Id bigint;
BEGIN
    DROP TABLE IF EXISTS temp_TotalStudents;
    DROP TABLE IF EXISTS temp_PassedTotalStudents;

    v_ACST_Id := p_ACST_Id;
    v_ACSS_Id := p_ACSS_Id;

    SELECT "ACST_Id" INTO v_ACST_Id 
    FROM "clg"."Adm_College_SchemeType" 
    WHERE "MI_Id" = p_MI_Id;
    
    SELECT "ACSS_Id" INTO v_ACSS_Id 
    FROM "clg"."Adm_College_SubjectScheme" 
    WHERE "MI_Id" = p_MI_Id;

    SELECT DISTINCT "ECYS_Id" INTO v_ECYS_Id 
    FROM "clg"."Exm_Col_Yearly_Scheme" 
    WHERE "MI_Id" = p_MI_Id 
        AND "AMCO_Id" = p_AMCO_Id
        AND "AMSE_Id" = p_AMSE_Id 
        AND "ACSS_Id" = v_ACSS_Id 
        AND "ACST_Id" = v_ACST_Id
        AND "ECYS_ActiveFlag" = true 
        AND "AMB_Id" IN (SELECT unnest(string_to_array(p_AMB_Id, ',')))
    LIMIT 1;

    SELECT DISTINCT "ECYSE_Id" INTO v_ECYSE_Id 
    FROM "clg"."Exm_Col_Yearly_Scheme_Exams" 
    WHERE "ECYS_Id" = v_ECYS_Id 
        AND "AMCO_Id" = p_AMCO_Id
        AND "AMSE_Id" = p_AMSE_Id 
        AND "ACSS_Id" = v_ACSS_Id 
        AND "ACST_Id" = v_ACST_Id
        AND "EME_Id" = p_EME_Id
        AND "AMB_Id" IN (SELECT unnest(string_to_array(p_AMB_Id, ',')))
    LIMIT 1;

    CREATE TEMP TABLE temp_TotalStudents AS
    SELECT DISTINCT 
        a."ISMS_Id",
        COUNT(a."AMCST_Id") as countTotalStudents,
        'TotalStudents' as TotalStudents,
        "CEYCES"."ECYSES_SubjectOrder",
        D."ISMS_SubjectName",
        CONCAT(COALESCE(hr."HRME_EmployeeFirstName", ''), ' ', COALESCE(hr."HRME_EmployeeMiddleName", ''), '', COALESCE(hr."HRME_EmployeeLastName", '')) as EmployeeName
    FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSES_AplResultFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    INNER JOIN "ivrm_master_subjects" d 
        ON d."ISMS_Id" = a."ISMS_Id" 
        AND D."ISMS_Id" = "CEYCES"."ISMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_Details" aldu 
        ON aldu."ISMS_Id" = a."ISMS_Id" 
        AND "CEYCES"."ISMS_Id" = aldu."ISMS_Id" 
        AND aldu."AMCO_Id" = a."AMCO_Id"
        AND aldu."AMSE_Id" = a."AMSE_Id" 
        AND aldu."AMB_Id" = a."AMB_Id" 
        AND aldu."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_User" alu 
        ON alu."ACALU_Id" = aldu."ACALU_Id" 
        AND alu."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "HR_Master_Employee" hr 
        ON hr."HRME_Id" = alu."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."AMB_Id" IN (SELECT unnest(string_to_array(p_AMB_Id, ',')))
    GROUP BY "CEYCES"."ECYSES_SubjectOrder", a."ISMS_Id", D."ISMS_SubjectName", 
        hr."HRME_EmployeeFirstName", hr."HRME_EmployeeMiddleName", hr."HRME_EmployeeLastName";

    CREATE TEMP TABLE temp_PassedTotalStudents AS
    SELECT DISTINCT 
        a."ISMS_Id",
        COUNT(a."AMCST_Id") as countPassedTotalStudents,
        'PassedStudents' as PassedStudents,
        "CEYCES"."ECYSES_SubjectOrder",
        D."ISMS_SubjectName",
        CONCAT(COALESCE(hr."HRME_EmployeeFirstName", ''), ' ', COALESCE(hr."HRME_EmployeeMiddleName", ''), '', COALESCE(hr."HRME_EmployeeLastName", '')) as EmployeeName
    FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    INNER JOIN "ivrm_master_subjects" d 
        ON d."ISMS_Id" = a."ISMS_Id" 
        AND D."ISMS_Id" = "CEYCES"."ISMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_Details" aldu 
        ON aldu."ISMS_Id" = a."ISMS_Id" 
        AND "CEYCES"."ISMS_Id" = aldu."ISMS_Id" 
        AND aldu."AMCO_Id" = a."AMCO_Id"
        AND aldu."AMSE_Id" = a."AMSE_Id" 
        AND aldu."AMB_Id" = a."AMB_Id" 
        AND aldu."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_User" alu 
        ON alu."ACALU_Id" = aldu."ACALU_Id" 
        AND alu."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "HR_Master_Employee" hr 
        ON hr."HRME_Id" = alu."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" = 'Pass' 
        AND a."AMB_Id" IN (SELECT unnest(string_to_array(p_AMB_Id, ',')))
    GROUP BY "CEYCES"."ECYSES_SubjectOrder", a."ISMS_Id", D."ISMS_SubjectName", 
        hr."HRME_EmployeeFirstName", hr."HRME_EmployeeMiddleName", hr."HRME_EmployeeLastName";

    RETURN QUERY
    SELECT DISTINCT 
        tt."ISMS_Id",
        tt.countTotalStudents,
        tt.TotalStudents,
        tt."ECYSES_SubjectOrder",
        tt."ISMS_SubjectName",
        tt.EmployeeName
    FROM temp_TotalStudents tt

    UNION

    SELECT DISTINCT 
        a."ISMS_Id",
        COUNT(a."AMCST_Id") as AppearedTotalStudents,
        'AppearedStudents' as AppearedStudents,
        "CEYCES"."ECYSES_SubjectOrder",
        D."ISMS_SubjectName",
        CONCAT(COALESCE(hr."HRME_EmployeeFirstName", ''), ' ', COALESCE(hr."HRME_EmployeeMiddleName", ''), '', COALESCE(hr."HRME_EmployeeLastName", '')) as EmployeeName
    FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    INNER JOIN "ivrm_master_subjects" d 
        ON d."ISMS_Id" = a."ISMS_Id" 
        AND D."ISMS_Id" = "CEYCES"."ISMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_Details" aldu 
        ON aldu."ISMS_Id" = a."ISMS_Id" 
        AND "CEYCES"."ISMS_Id" = aldu."ISMS_Id" 
        AND aldu."AMCO_Id" = a."AMCO_Id"
        AND aldu."AMSE_Id" = a."AMSE_Id" 
        AND aldu."AMB_Id" = a."AMB_Id" 
        AND aldu."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_User" alu 
        ON alu."ACALU_Id" = aldu."ACALU_Id" 
        AND alu."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "HR_Master_Employee" hr 
        ON hr."HRME_Id" = alu."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" <> 'AB' 
        AND a."AMB_Id" IN (SELECT unnest(string_to_array(p_AMB_Id, ',')))
    GROUP BY "CEYCES"."ECYSES_SubjectOrder", a."ISMS_Id", D."ISMS_SubjectName", 
        hr."HRME_EmployeeFirstName", hr."HRME_EmployeeMiddleName", hr."HRME_EmployeeLastName"

    UNION

    SELECT DISTINCT 
        a."ISMS_Id",
        COUNT(a."AMCST_Id") as AbsentTotalStudents,
        'AbsentStudents' as AbsentStudents,
        "CEYCES"."ECYSES_SubjectOrder",
        D."ISMS_SubjectName",
        CONCAT(COALESCE(hr."HRME_EmployeeFirstName", ''), ' ', COALESCE(hr."HRME_EmployeeMiddleName", ''), '', COALESCE(hr."HRME_EmployeeLastName", '')) as EmployeeName
    FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    INNER JOIN "ivrm_master_subjects" d 
        ON d."ISMS_Id" = a."ISMS_Id" 
        AND D."ISMS_Id" = "CEYCES"."ISMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_Details" aldu 
        ON aldu."ISMS_Id" = a."ISMS_Id" 
        AND "CEYCES"."ISMS_Id" = aldu."ISMS_Id" 
        AND aldu."AMCO_Id" = a."AMCO_Id"
        AND aldu."AMSE_Id" = a."AMSE_Id" 
        AND aldu."AMB_Id" = a."AMB_Id" 
        AND aldu."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_User" alu 
        ON alu."ACALU_Id" = aldu."ACALU_Id" 
        AND alu."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "HR_Master_Employee" hr 
        ON hr."HRME_Id" = alu."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" = 'AB' 
        AND a."AMB_Id" IN (SELECT unnest(string_to_array(p_AMB_Id, ',')))
    GROUP BY "CEYCES"."ECYSES_SubjectOrder", a."ISMS_Id", D."ISMS_SubjectName", 
        hr."HRME_EmployeeFirstName", hr."HRME_EmployeeMiddleName", hr."HRME_EmployeeLastName"

    UNION

    SELECT DISTINCT 
        a."ISMS_Id",
        COUNT(a."AMCST_Id") as FailedTotalStudents,
        'FailedStudents' as FailedStudents,
        "CEYCES"."ECYSES_SubjectOrder",
        D."ISMS_SubjectName",
        CONCAT(COALESCE(hr."HRME_EmployeeFirstName", ''), ' ', COALESCE(hr."HRME_EmployeeMiddleName", ''), '', COALESCE(hr."HRME_EmployeeLastName", '')) as EmployeeName
    FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    INNER JOIN "ivrm_master_subjects" d 
        ON d."ISMS_Id" = a."ISMS_Id" 
        AND D."ISMS_Id" = "CEYCES"."ISMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_Details" aldu 
        ON aldu."ISMS_Id" = a."ISMS_Id" 
        AND "CEYCES"."ISMS_Id" = aldu."ISMS_Id" 
        AND aldu."AMCO_Id" = a."AMCO_Id"
        AND aldu."AMSE_Id" = a."AMSE_Id" 
        AND aldu."AMB_Id" = a."AMB_Id" 
        AND aldu."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "clg"."Adm_College_Atten_Login_User" alu 
        ON alu."ACALU_Id" = aldu."ACALU_Id" 
        AND alu."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "HR_Master_Employee" hr 
        ON hr."HRME_Id" = alu."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" = 'Fail' 
        AND a."AMB_Id" IN (SELECT unnest(string_to_array(p_AMB_Id, ',')))
    GROUP BY "CEYCES"."ECYSES_SubjectOrder", a."ISMS_Id", D."ISMS_SubjectName", 
        hr."HRME_EmployeeFirstName", hr."HRME_EmployeeMiddleName", hr."HRME_EmployeeLastName"

    UNION

    SELECT 
        pt."ISMS_Id",
        pt.countPassedTotalStudents,
        pt.PassedStudents,
        pt."ECYSES_SubjectOrder",
        pt."ISMS_SubjectName",
        pt.EmployeeName
    FROM temp_PassedTotalStudents pt

    UNION

    SELECT DISTINCT 
        aa."ISMS_Id",
        ROUND((CAST(bb.countPassedTotalStudents AS decimal(18,1)) / aa.countTotalStudents) * 100, 0) as TotalPercentage,
        'Percentage' as Percentage,
        aa."ECYSES_SubjectOrder",
        aa."ISMS_SubjectName",
        aa.EmployeeName
    FROM temp_TotalStudents aa 
    INNER JOIN temp_PassedTotalStudents bb ON aa."ISMS_Id" = bb."ISMS_Id"

    ORDER BY "ECYSES_SubjectOrder";

    DROP TABLE IF EXISTS temp_TotalStudents;
    DROP TABLE IF EXISTS temp_PassedTotalStudents;

END;
$$;