CREATE OR REPLACE FUNCTION "dbo"."BIS_EXAM_GET_STUDENT_DETAILS_MODIFY"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "admno" VARCHAR,
    "rollno" INTEGER,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "fathername" TEXT,
    "mothername" TEXT,
    "dob" VARCHAR,
    "mobileno" VARCHAR,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "grporder" INTEGER,
    "EMPS_AppToResultFlg" BOOLEAN,
    "TOTALWORKINGDAYS" NUMERIC,
    "PRESENTDAYS" NUMERIC,
    "ATTENDANCEPERCENTAGE" NUMERIC,
    "ECT_Id" BIGINT,
    "ECS_SkillName" VARCHAR,
    "ECSA_SkillArea" VARCHAR,
    "ECSA_SkillOrder" INTEGER,
    "ECST_Score" NUMERIC,
    "EMGD_Name" VARCHAR,
    "ECACT_SkillName" VARCHAR,
    "ECACTA_SkillArea" VARCHAR,
    "ECACTA_SkillOrder" INTEGER,
    "ECSACTT_Score" NUMERIC
)
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
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1;

    /* STUDENT DETAILS */
    IF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id",
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName" = '' THEN '' ELSE A."AMST_FirstName" END ||   
             CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||  
             CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END)::TEXT,
            A."AMST_AdmNo",
            B."AMAY_RollNo",
            D."ASMCL_ClassName",
            E."ASMC_SectionName",
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName" = '' THEN '' ELSE A."AMST_FatherName" END ||   
             CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname" = '' THEN '' ELSE ' ' || A."AMST_FatherSurname" END)::TEXT,
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName" = '' THEN '' ELSE A."AMST_MotherName" END ||   
             CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname" = '' THEN '' ELSE ' ' || A."AMST_MotherSurname" END)::TEXT,
            TO_CHAR(A."amst_dob", 'DD/MM/YYYY')::VARCHAR,
            A."AMST_MobileNo",
            NULL::BIGINT, NULL::VARCHAR, NULL::INTEGER, NULL::BOOLEAN,
            NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        WHERE A."MI_Id" = p_MI_Id::BIGINT 
            AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND B."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND B."ASMS_Id" = p_ASMS_Id::BIGINT;

    /* STUDENT WISE SUBJECT DETAILS */
    ELSIF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT DISTINCT 
            MPS."AMST_Id",
            NULL::TEXT, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::TEXT, NULL::VARCHAR, NULL::VARCHAR,
            MPS."ISMS_Id",
            MS."ISMS_SubjectName",
            PS."EMPS_SubjOrder",
            PS."EMPS_AppToResultFlg",
            NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id" 
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" AND MSG."EMPSG_ActiveFlag" = 1
        INNER JOIN "IVRM_Master_Subjects" MS ON MS."ISMS_Id" = MPS."ISMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" PS ON PS."EMPS_Id" = MSG."EMPS_Id" AND MS."ISMS_Id" = PS."ISMS_Id" AND PS."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" MP ON MP."EMP_Id" = PS."EMP_Id" AND MP."EMP_ActiveFlag" = 1 AND MP."EYC_Id" = v_EYC_Id
        WHERE MPS."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND MPS."MI_Id" = p_MI_Id::BIGINT 
            AND MPS."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND MPS."ASMS_Id" = p_ASMS_Id::BIGINT
        ORDER BY MPS."AMST_Id", PS."EMPS_SubjOrder";

    /* STUDENT WISE ATTENDANCE */
    ELSIF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT 
            B."AMST_Id",
            NULL::TEXT, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::TEXT, NULL::VARCHAR, NULL::VARCHAR,
            NULL::BIGINT, NULL::VARCHAR, NULL::INTEGER, NULL::BOOLEAN,
            SUM(A."ASA_ClassHeld"),
            SUM(A."ASA_Class_Attended"),
            ROUND((SUM(A."ASA_Class_Attended") * 100.0 / NULLIF(SUM(A."ASA_ClassHeld"), 0))::NUMERIC, 2),
            NULL::BIGINT, NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC
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

    /* ****** SKILLS ****** */
    ELSIF p_FLAG = '4' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id",
            NULL::TEXT, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::TEXT, NULL::VARCHAR, NULL::VARCHAR,
            NULL::BIGINT, NULL::VARCHAR, NULL::INTEGER, NULL::BOOLEAN,
            NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            A."ECT_Id",
            B."ECS_SkillName",
            C."ECSA_SkillArea",
            C."ECSA_SkillOrder",
            A."ECST_Score",
            L."EMGD_Name",
            NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC
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
        ORDER BY C."ECSA_SkillOrder";

    /* ****** ACTIVITES LIST ********* */
    ELSIF p_FLAG = '5' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id",
            NULL::TEXT, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::TEXT, NULL::VARCHAR, NULL::VARCHAR,
            NULL::BIGINT, NULL::VARCHAR, NULL::INTEGER, NULL::BOOLEAN,
            NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            A."ECT_Id",
            NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::NUMERIC, L."EMGD_Name",
            B."ECACT_SkillName",
            C."ECACTA_SkillArea",
            C."ECACTA_SkillOrder",
            A."ECSACTT_Score"
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
        ORDER BY C."ECACTA_SkillOrder";

    END IF;

    RETURN;

END;
$$;