CREATE OR REPLACE FUNCTION "dbo"."Exam_BBHS_Student_SubjectWise_Details_New"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT,
    p_AMST_Id TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
BEGIN
    
    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT
        AND "ECAC_ActiveFlag" = 1
    LIMIT 1;
    
    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1
    LIMIT 1;
    
    IF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id",
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName" = '' THEN '' ELSE A."AMST_FirstName" END ||
            CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
            CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END)::TEXT AS studentname,
            A."AMST_AdmNo"::TEXT AS admno,
            B."AMAY_RollNo"::TEXT AS rollno,
            D."ASMCL_ClassName"::TEXT AS classname,
            E."ASMC_SectionName"::TEXT AS sectionname,
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName" = '' THEN '' ELSE A."AMST_FatherName" END ||
            CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname" = '' THEN '' ELSE ' ' || A."AMST_FatherSurname" END)::TEXT AS fathername,
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName" = '' THEN '' ELSE A."AMST_MotherName" END ||
            CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname" = '' THEN '' ELSE ' ' || A."AMST_MotherSurname" END)::TEXT AS mothername,
            TO_CHAR(A."amst_dob", 'DD/MM/YYYY')::TEXT AS dob,
            A."AMST_MobileNo"::TEXT AS mobileno,
            MP."ESTMPP_TotalObtMarks" AS TotalMarks,
            MP."ESTMPP_Percentage" AS TotalPercentage,
            MP."ESTMPP_TotalGrade"::TEXT,
            A."AMST_Photoname"::TEXT
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        LEFT JOIN "Exm"."Exm_Student_MP_Promotion" MP ON MP."AMST_Id" = B."AMST_Id" 
            AND MP."ASMAY_Id" = B."ASMAY_Id" 
            AND MP."ASMCL_Id" = B."ASMCL_Id" 
            AND MP."ASMS_Id" = B."ASMS_Id"
        WHERE A."MI_Id" = p_MI_Id::BIGINT 
            AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND B."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND B."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND B."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[]);
            
    ELSIF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT DISTINCT 
            MPS."AMST_Id",
            MPS."ISMS_Id",
            MS."ISMS_SubjectName"::TEXT,
            PS."EMPS_SubjOrder" AS grporder,
            PS."EMPS_AppToResultFlg",
            MPS."ESTMPPS_ObtainedMarks",
            MPS."ESTMPPS_ObtainedGrade"::TEXT,
            MPS."ESTMPPS_Remarks"::TEXT,
            (SELECT "EYCES_MarksDisplayFlg" 
             FROM "EXM"."Exm_Yrly_Cat_Exams_Subwise" a
             INNER JOIN "exm"."Exm_Yearly_Category_Exams" b ON a."EYCE_Id" = b."EYCE_Id" 
                AND b."EYC_Id" = v_EYC_Id
             WHERE a."ISMS_Id" = MPS."ISMS_Id"
             LIMIT 1) AS EYCES_MarksDisplayFlg,
            (SELECT "EYCES_GradeDisplayFlg" 
             FROM "EXM"."Exm_Yrly_Cat_Exams_Subwise" 
             WHERE "ISMS_Id" = MPS."ISMS_Id"
             LIMIT 1) AS EYCES_GradeDisplayFlg
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" 
            AND MSG."EMPSG_ActiveFlag" = 1
        INNER JOIN "IVRM_Master_Subjects" MS ON MS."ISMS_Id" = MPS."ISMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" PS ON PS."EMPS_Id" = MSG."EMPS_Id" 
            AND MS."ISMS_Id" = PS."ISMS_Id" 
            AND PS."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" MP ON MP."EMP_Id" = PS."EMP_Id" 
            AND MP."EMP_ActiveFlag" = 1 
            AND MP."EYC_Id" = v_EYC_Id
        WHERE MPS."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND MPS."MI_Id" = p_MI_Id::BIGINT 
            AND MPS."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND MPS."ASMS_Id" = p_ASMS_Id::BIGINT
            AND MPS."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[])
        ORDER BY MPS."AMST_Id", grporder;
        
    ELSIF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT 
            SUM(A."ASA_ClassHeld") AS TOTALWORKINGDAYS,
            SUM(A."ASA_Class_Attended") AS PRESENTDAYS,
            ROUND((SUM(A."ASA_Class_Attended")::DECIMAL * 100 / NULLIF(SUM(A."ASA_ClassHeld"), 0))::NUMERIC, 2) AS ATTENDANCEPERCENTAGE,
            B."AMST_Id"
        FROM "Adm_Student_Attendance" A 
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id"
        WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND A."ASA_Activeflag" = 1 
            AND A."MI_Id" = p_MI_Id::BIGINT
            AND C."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND C."ASMS_Id" = p_ASMS_Id::BIGINT
            AND C."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[])
        GROUP BY B."AMST_Id";
        
    ELSIF p_FLAG = '4' THEN
        RETURN QUERY
        SELECT * FROM (
            SELECT 
                E."EME_Id",
                MSG."EMPSG_GroupName"::TEXT,
                MSG."EMPSG_DisplayName"::TEXT,
                G."AMST_Id",
                SUM(E."ESTMPPSGE_ExamConvertedMarks") AS ObtainedMarks,
                SUM(D."EMPSGE_ForMaxMarkrs") AS TotalMarks,
                ROUND((SUM(E."ESTMPPSGE_ExamConvertedMarks")::DECIMAL * 100 / NULLIF(SUM(D."EMPSGE_ForMaxMarkrs"), 0))::NUMERIC, 2) AS TotalPercentage,
                Fn."ESTMP_TotalGrade"::TEXT AS EMGD_Name
            FROM "Exm"."Exm_M_Promotion" A
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id" = B."EMP_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id" = B."EMPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
            INNER JOIN "EXM"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" E ON E."EME_Id" = D."EME_Id"
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" F ON F."EMPSG_Id" = C."EMPSG_Id" 
                AND F."ESTMPPSG_Id" = E."ESTMPPSG_Id" 
                AND F."EMPSG_Id" = C."EMPSG_Id"
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" G ON G."ESTMPPS_Id" = F."ESTMPPS_Id" 
                AND B."ISMS_Id" = G."ISMS_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" 
                AND H."EME_Id" = E."EME_Id" 
                AND H."MI_Id" = G."MI_Id" 
                AND H."MI_Id" = p_MI_Id::BIGINT
            INNER JOIN "Exm"."Exm_Student_MP_Promotion" I ON I."ASMAY_Id" = G."ASMAY_Id" 
                AND I."ASMCL_Id" = G."ASMCL_Id" 
                AND I."ASMS_Id" = G."ASMS_Id" 
                AND I."AMST_Id" = G."AMST_Id"
            INNER JOIN "EXM"."Exm_Student_Marks_Process" Fn ON Fn."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND Fn."ASMS_Id" = p_ASMS_Id::BIGINT
                AND Fn."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND G."AMST_Id" = Fn."AMST_Id" 
                AND Fn."EME_Id" = H."EME_Id" 
                AND Fn."EME_Id" = E."EME_Id"
            WHERE G."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND G."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND G."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND I."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND I."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND I."ASMS_Id" = p_ASMS_Id::BIGINT
                AND B."EMPS_AppToResultFlg" = 1 
                AND A."EYC_Id" = v_EYC_Id 
                AND H."EME_ActiveFlag" = 1
                AND I."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[])
            GROUP BY E."EME_Id", MSG."EMPSG_GroupName", MSG."EMPSG_DisplayName", G."AMST_Id", A."EMGR_Id", Fn."ESTMP_TotalGrade"
            
            UNION
            
            SELECT 
                9800000::BIGINT AS EME_Id,
                F."EMPSG_GroupName"::TEXT,
                F."EMPSG_DisplayName"::TEXT,
                C."AMST_Id",
                SUM(B."ESTMPPSG_GroupObtMarks") AS ObtainedMarks,
                SUM(B."ESTMPPSG_GroupMaxMarks") AS TotalMarks,
                ROUND((SUM(B."ESTMPPSG_GroupObtMarks")::DECIMAL * 100 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0))::NUMERIC, 2) AS TotalPercentage,
                (SELECT L."EMGD_Name"::TEXT
                 FROM "Exm"."Exm_Master_Grade_Details" AS L
                 WHERE ((SUM(B."ESTMPPSG_GroupObtMarks")::DECIMAL * 100 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                        BETWEEN L."EMGD_From" AND L."EMGD_To" AND L."EMGR_Id" = H."EMGR_Id")
                    OR ((SUM(B."ESTMPPSG_GroupObtMarks")::DECIMAL * 100 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                        BETWEEN L."EMGD_To" AND L."EMGD_From" AND L."EMGR_Id" = H."EMGR_Id")
                 LIMIT 1) AS EMGD_Name
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" C ON C."ESTMPPS_Id" = B."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" F ON F."EMPSG_Id" = B."EMPSG_Id" 
                AND F."EMPSG_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" G ON G."EMPS_Id" = F."EMPS_Id" 
                AND G."EMPS_AppToResultFlg" = 1 
                AND G."EMPS_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion" H ON H."EMP_Id" = G."EMP_Id" 
                AND H."EMP_ActiveFlag" = 1 
                AND H."EYC_Id" = v_EYC_Id
            WHERE C."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND C."ASMS_Id" = p_ASMS_Id::BIGINT
                AND C."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[])
            GROUP BY F."EMPSG_GroupName", F."EMPSG_DisplayName", C."AMST_Id", H."EMGR_Id"
            
            UNION
            
            SELECT 
                9800001::BIGINT AS EME_Id,
                F."EMPSG_GroupName"::TEXT,
                F."EMPSG_DisplayName"::TEXT,
                C."AMST_Id",
                SUM(B."ESTMPPSG_GroupObtMarks") AS ObtainedMarks,
                SUM(B."ESTMPPSG_GroupMaxMarks") AS TotalMarks,
                ROUND((SUM(B."ESTMPPSG_GroupObtMarks")::DECIMAL * 100 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0))::NUMERIC, 2) AS TotalPercentage,
                (SELECT L."EMGD_Name"::TEXT
                 FROM "Exm"."Exm_Master_Grade_Details" AS L
                 WHERE ((SUM(B."ESTMPPSG_GroupObtMarks")::DECIMAL * 100 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                        BETWEEN L."EMGD_From" AND L."EMGD_To" AND L."EMGR_Id" = H."EMGR_Id")
                    OR ((SUM(B."ESTMPPSG_GroupObtMarks")::DECIMAL * 100 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                        BETWEEN L."EMGD_To" AND L."EMGD_From" AND L."EMGR_Id" = H."EMGR_Id")
                 LIMIT 1) AS EMGD_Name
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" C ON C."ESTMPPS_Id" = B."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" F ON F."EMPSG_Id" = B."EMPSG_Id" 
                AND F."EMPSG_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" G ON G."EMPS_Id" = F."EMPS_Id" 
                AND G."EMPS_AppToResultFlg" = 1 
                AND G."EMPS_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion" H ON H."EMP_Id" = G."EMP_Id" 
                AND H."EMP_ActiveFlag" = 1 
                AND H."EYC_Id" = v_EYC_Id
            WHERE C."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND C."ASMS_Id" = p_ASMS_Id::BIGINT
                AND C."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[])
            GROUP BY F."EMPSG_GroupName", F."EMPSG_DisplayName", C."AMST_Id", H."EMGR_Id"
        ) AS D 
        ORDER BY "AMST_Id";
        
    ELSIF p_FLAG = '5' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."ECT_Id",
            B."ECS_SkillName"::TEXT,
            C."ECSA_SkillArea"::TEXT,
            A."ECSA_Id",
            C."ECSA_SkillOrder",
            A."ECST_Score",
            L."EMGD_Name"::TEXT,
            A."AMST_Id",
            A."ECS_Id",
            D."ECT_TermName"::TEXT
        FROM "Exm"."Exm_CCE_SKILLS_Transaction" A 
        INNER JOIN "Exm"."Exm_CCE_SKILLS" B ON A."ECS_Id" = B."ECS_Id"
        INNER JOIN "Exm"."Exm_CCE_SKILLS_AREA" C ON C."ECSA_Id" = A."ECSA_Id"
        INNER JOIN "Exm"."Exm_CCE_TERMS" D ON D."ECT_ID" = A."ECT_Id"
        INNER JOIN "Adm_School_Y_Student" E ON E."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" F ON F."AMST_Id" = E."AMST_Id"
        INNER JOIN "Adm_School_M_Class" G ON G."ASMCL_ID" = E."ASMCL_Id" 
            AND G."ASMCL_ID" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" H ON H."ASMS_Id" = E."ASMS_Id" 
            AND H."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" I ON I."ASMAY_Id" = E."ASMAY_Id" 
            AND I."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Exm"."Exm_CCE_SKILLS_AREA_Mapping" J ON J."ECS_Id" = B."ECS_Id" 
            AND J."ECSA_Id" = C."ECSA_Id"
        INNER JOIN "Exm"."Exm_Master_Grade" K ON K."EMGR_Id" = J."EMGR_Id" 
            AND K."EMGR_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Master_Grade_Details" L ON L."EMGR_Id" = K."EMGR_Id" 
            AND L."EMGD_ActiveFlag" = 1
        INNER JOIN "NDS_Temp_StudentDetails_Amstids" NDC ON NDC."AMST_Id" = A."AMST_Id"
        WHERE E."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND E."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND E."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT
            AND D."EMCA_Id" = v_EMCA_Id 
            AND D."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND D."ECT_ActiveFlag" = 1 
            AND (A."ECST_Score" BETWEEN L."EMGD_From" AND L."EMGD_To")
            AND A."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[]);
            
    ELSIF p_FLAG = '6' THEN
        RETURN QUERY
        SELECT 
            A."ECT_Id",
            B."ECACT_SkillName"::TEXT,
            C."ECACTA_SkillArea"::TEXT,
            C."ECACTA_SkillOrder",
            A."ECSACTT_Score"::TEXT,
            L."EMGD_Name"::TEXT,
            A."AMST_Id",
            A."EME_Id",
            A."ECACT_Id",
            C."ECACTA_Id"
        FROM "Exm"."Exm_CCE_Activities_Transaction" A 
        INNER JOIN "Exm"."Exm_CCE_Activities" B ON A."ECACT_Id" = B."ECACT_Id"
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA" C ON C."ECACTA_Id" = A."ECACTA_Id"
        INNER JOIN "Exm"."Exm_CCE_TERMS" D ON D."ECT_ID" = A."ECT_Id"
        INNER JOIN "Adm_School_Y_Student" E ON E."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" F ON F."AMST_Id" = E."AMST_Id"
        INNER JOIN "Adm_School_M_Class" G ON G."ASMCL_ID" = E."ASMCL_Id" 
            AND G."ASMCL_ID" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" H ON H."ASMS_Id" = E."ASMS_Id" 
            AND H."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" I ON I."ASMAY_Id" = E."ASMAY_Id" 
            AND I."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA_Mapping" J ON J."ECACT_Id" = B."ECACT_Id" 
            AND J."ECACTA_Id" = C."ECACTA_Id"
        INNER JOIN "Exm"."Exm_Master_Grade" K ON K."EMGR_Id" = J."EMGR_Id" 
            AND K."EMGR_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Master_Grade_Details" L ON L."EMGR_Id" = K."EMGR_Id" 
            AND L."EMGD_ActiveFlag" = 1
        WHERE E."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND E."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND E."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT
            AND D."EMCA_Id" = v_EMCA_Id 
            AND D."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND D."ECT_ActiveFlag" = 1
            AND (
                (A."ECSACTT_Score" ~ '[^0-9]' AND A."ECSACTT_Score" = L."EMGD_Name")
                OR
                (A."ECSACTT_Score" !~ '[^0-9]' 
                 AND A."ECSACTT_Score" ~ '^[0-9]+$'
                 AND (
                     (A."ECSACTT_Score"::INTEGER BETWEEN L."EMGD_From" AND L."EMGD_To")
                     OR (A."ECSACTT_Score"::INTEGER BETWEEN L."EMGD_To" AND L."EMGD_From")
                 )
                )
            )
            AND A."AMST_Id" = ANY(STRING_TO_ARRAY(p_AMST_Id, ',')::BIGINT[])
        ORDER BY C."ECACTA_SkillOrder";
        
    END