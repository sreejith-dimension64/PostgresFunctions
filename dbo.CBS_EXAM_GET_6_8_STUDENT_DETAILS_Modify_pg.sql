CREATE OR REPLACE FUNCTION "dbo"."CBS_EXAM_GET_6_8_STUDENT_DETAILS_Modify"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT,
    p_AMST_Id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
    v_SQLQUERY TEXT;
BEGIN

    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1;

    DROP TABLE IF EXISTS "NDS_Temp_StudentDetails_Amstids";
    DROP TABLE IF EXISTS "CBSE_MarksTemp_StudentDetails";

    v_SQLQUERY := 'CREATE TEMP TABLE "NDS_Temp_StudentDetails_Amstids" AS 
                   SELECT DISTINCT "AMST_Id" 
                   FROM "ADM_M_STUDENT" 
                   WHERE "AMST_Id" IN(' || p_AMST_Id || ') 
                   AND "MI_Id" = ' || p_MI_Id;
    
    EXECUTE v_SQLQUERY;

    /* STUDENT DETAILS */
    IF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMST_Id",
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName" = '' THEN '' ELSE A."AMST_FirstName" END ||
             CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
             CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END) AS studentname,
            A."AMST_AdmNo" AS admno,
            B."AMAY_RollNo" AS rollno,
            D."ASMCL_ClassName" AS classname,
            E."ASMC_SectionName" AS sectionname,
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName" = '' THEN '' ELSE A."AMST_FatherName" END ||
             CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname" = '' THEN '' ELSE ' ' || A."AMST_FatherSurname" END) AS fathername,
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName" = '' THEN '' ELSE A."AMST_MotherName" END ||
             CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname" = '' THEN '' ELSE ' ' || A."AMST_MotherSurname" END) AS mothername,
            TO_CHAR(A."amst_dob", 'DD/MM/YYYY') AS dob,
            A."AMST_MobileNo" AS mobileno,
            COALESCE(A."AMST_Photoname", 'https://hutchingspreadmission.blob.core.windows.net/files/Student.jpg') AS "AMST_Photoname"
        FROM "Adm_M_Student" A
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        WHERE A."MI_Id" = p_MI_Id::BIGINT 
            AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND B."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND B."ASMS_Id" = p_ASMS_Id::BIGINT
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids");
    END IF;

    /* STUDENT WISE SUBJECT DETAILS */
    IF p_FLAG = '2' THEN
        CREATE TEMP TABLE "CBSE_MarksTemp_StudentDetails" AS
        SELECT DISTINCT 
            MPS."AMST_Id",
            MPS."ISMS_Id",
            MS."ISMS_SubjectName",
            PS."EMPS_SubjOrder" AS grporder,
            PS."EMPS_AppToResultFlg",
            ((SUM(SG."ESTMPPSG_GroupObtMarks") / 2)) AS "ESTMPPSG_GroupObtMarks",
            (SELECT "EMGD_Name" FROM "EXM"."Exm_Master_Grade_Details" WHERE "EMGD_Id" = MPS."EMGD_Id") AS "ESTMPPSG_GroupObtGrade",
            MRK."GropuFlag",
            MRK."colspan",
            ((SUM(SG."ESTMPPSG_GroupObtMarks") / 4)) AS "YeralyGroupObtMarks"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" AND MSG."EMPSG_ActiveFlag" = 1
        INNER JOIN "IVRM_Master_Subjects" MS ON MS."ISMS_Id" = MPS."ISMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" PS ON PS."EMPS_Id" = MSG."EMPS_Id" 
            AND MS."ISMS_Id" = PS."ISMS_Id" 
            AND PS."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" MP ON MP."EMP_Id" = PS."EMP_Id" 
            AND MP."EMP_ActiveFlag" = 1 
            AND MP."EYC_Id" = v_EYC_Id
        INNER JOIN "MARKS_Temp_StudentDetails" MRK ON MRK."AMST_Id" = MPS."AMST_Id" 
            AND MRK."ISMS_Id" = MPS."ISMS_Id" 
            AND MRK."EME_Id" = 9800000
        WHERE MPS."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND MPS."MI_Id" = p_MI_Id::BIGINT 
            AND MPS."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND MPS."ASMS_Id" = p_ASMS_Id::BIGINT
            AND MPS."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        GROUP BY MPS."AMST_Id", MPS."ISMS_Id", MS."ISMS_SubjectName", PS."EMPS_SubjOrder", 
                 PS."EMPS_AppToResultFlg", MPS."EMGD_Id", MRK."GropuFlag", MRK."ISMS_Id", MRK."colspan"
        ORDER BY MPS."AMST_Id", grporder;

        RETURN QUERY
        SELECT * FROM "CBSE_MarksTemp_StudentDetails" ORDER BY "AMST_Id", grporder;
    END IF;

    /* STUDENT WISE ATTENDANCE */
    IF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT 
            SUM(A."ASA_ClassHeld") AS "TOTALWORKINGDAYS",
            SUM(A."ASA_Class_Attended") AS "PRESENTDAYS",
            CAST(SUM(A."ASA_Class_Attended") * 100.0 / SUM(A."ASA_ClassHeld") AS DECIMAL(18,2)) AS "ATTENDANCEPERCENTAGE",
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
        GROUP BY B."AMST_Id";
    END IF;

    /* ****** SKILLS ****** */
    IF p_FLAG = '4' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."ECT_Id",
            B."ECS_SkillName",
            C."ECSA_SkillArea",
            C."ECSA_SkillOrder",
            A."ECST_Score",
            L."EMGD_Name",
            A."AMST_Id"
        FROM "Exm"."Exm_CCE_SKILLS_Transaction" A
        INNER JOIN "Exm"."Exm_CCE_SKILLS" B ON A."ECS_Id" = B."ECS_Id"
        INNER JOIN "Exm"."Exm_CCE_SKILLS_AREA" C ON C."ECSA_Id" = A."ECSA_Id"
        INNER JOIN "Exm"."Exm_CCE_TERMS" D ON D."ECT_ID" = A."ECT_Id"
        INNER JOIN "Adm_School_Y_Student" E ON E."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" F ON F."AMST_Id" = E."AMST_Id"
        INNER JOIN "Adm_School_M_Class" G ON G."ASMCL_ID" = E."ASMCL_Id" AND G."ASMCL_ID" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" H ON H."ASMS_Id" = E."ASMS_Id" AND H."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" I ON I."ASMAY_Id" = E."ASMAY_Id" AND I."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Exm"."Exm_CCE_SKILLS_AREA_Mapping" J ON J."ECS_Id" = B."ECS_Id" AND J."ECSA_Id" = C."ECSA_Id"
        INNER JOIN "Exm"."Exm_Master_Grade" K ON K."EMGR_Id" = J."EMGR_Id" AND K."EMGR_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Master_Grade_Details" L ON L."EMGR_Id" = K."EMGR_Id" AND L."EMGD_ActiveFlag" = 1
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
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        ORDER BY C."ECSA_SkillOrder";
    END IF;

    /* ****** ACTIVITES LIST ********* */
    IF p_FLAG = '5' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."ECT_Id",
            B."ECACT_SkillName",
            C."ECACTA_SkillArea",
            C."ECACTA_SkillOrder",
            A."ECSACTT_Score",
            L."EMGD_Name",
            A."AMST_Id"
        FROM "Exm"."Exm_CCE_Activities_Transaction" A
        INNER JOIN "Exm"."Exm_CCE_Activities" B ON A."ECACT_Id" = B."ECACT_Id"
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA" C ON C."ECACTA_Id" = A."ECACTA_Id"
        INNER JOIN "Exm"."Exm_CCE_TERMS" D ON D."ECT_ID" = A."ECT_Id"
        INNER JOIN "Adm_School_Y_Student" E ON E."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" F ON F."AMST_Id" = E."AMST_Id"
        INNER JOIN "Adm_School_M_Class" G ON G."ASMCL_ID" = E."ASMCL_Id" AND G."ASMCL_ID" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" H ON H."ASMS_Id" = E."ASMS_Id" AND H."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" I ON I."ASMAY_Id" = E."ASMAY_Id" AND I."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA_Mapping" J ON J."ECACT_Id" = B."ECACT_Id" AND J."ECACTA_Id" = C."ECACTA_Id"
        INNER JOIN "Exm"."Exm_Master_Grade" K ON K."EMGR_Id" = J."EMGR_Id" AND K."EMGR_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Master_Grade_Details" L ON L."EMGR_Id" = K."EMGR_Id" AND L."EMGD_ActiveFlag" = 1
        WHERE E."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND E."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND E."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT
            AND D."EMCA_Id" = v_EMCA_Id 
            AND D."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND D."ECT_ActiveFlag" = 1 
            AND (A."ECSACTT_Score" BETWEEN L."EMGD_From" AND L."EMGD_To")
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        ORDER BY C."ECACTA_SkillOrder";
    END IF;

    IF p_FLAG = '6' THEN
        RETURN QUERY
        SELECT 
            "AMST_Id",
            SUM("ESTMPPSG_GroupObtMarks") AS "Overall_GroupObtMarks"
        FROM (
            SELECT DISTINCT 
                MPS."AMST_Id",
                MPS."ISMS_Id",
                MS."ISMS_SubjectName",
                PS."EMPS_SubjOrder" AS grporder,
                PS."EMPS_AppToResultFlg",
                ROUND((SUM(SG."ESTMPPSG_GroupObtMarks") / 2), 0) AS "ESTMPPSG_GroupObtMarks",
                (SELECT "EMGD_Name" FROM "EXM"."Exm_Master_Grade_Details" WHERE "EMGD_Id" = MPS."EMGD_Id") AS "ESTMPPSG_GroupObtGrade"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" AND MSG."EMPSG_ActiveFlag" = 1
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
                AND MPS."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
            GROUP BY MPS."AMST_Id", MPS."ISMS_Id", MS."ISMS_SubjectName", PS."EMPS_SubjOrder", 
                     PS."EMPS_AppToResultFlg", MPS."EMGD_Id"
        ) A 
        GROUP BY "AMST_Id" 
        ORDER BY "AMST_Id";
    END IF;

END;
$$;