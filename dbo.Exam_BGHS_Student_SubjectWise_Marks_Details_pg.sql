CREATE OR REPLACE FUNCTION "dbo"."Exam_BGHS_Student_SubjectWise_Marks_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT,
    p_FLAG TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "admno" TEXT,
    "rollno" TEXT,
    "classname" TEXT,
    "sectionname" TEXT,
    "fathername" TEXT,
    "mothername" TEXT,
    "dob" TEXT,
    "mobileno" TEXT,
    "address" TEXT,
    "photoname" TEXT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "EYCES_SubjectOrder" BIGINT,
    "EYCES_AplResultFlg" BIGINT,
    "ESG_Id" BIGINT,
    "ESG_SubjectGroupName" TEXT,
    "ESG_CompulsoryFlag" TEXT,
    "TOTALWORKINGDAYS" BIGINT,
    "PRESENTDAYS" BIGINT,
    "ATTENDANCEPERCENTAGE" NUMERIC,
    "termid" BIGINT,
    "termname" TEXT,
    "subjectid" BIGINT,
    "subjectname" TEXT,
    "examid" BIGINT,
    "examname" TEXT,
    "maxmiummarks" NUMERIC,
    "marksobtained" NUMERIC,
    "grade" TEXT,
    "apptoresult" BOOLEAN,
    "resultflag" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_Id_New TEXT;
    v_AMST_Admno TEXT;
    v_EMCA_Id BIGINT;
    v_EYC_Id BIGINT;
    v_ISMS_Id_New TEXT;
    v_ISMS_SubjectName TEXT;
    v_EYCES_SubjectOrder BIGINT;
    v_EYCES_AplResultFlg BIGINT;
    v_ECT_Id BIGINT;
    v_ECT_TermName TEXT;
    v_EMGR_Id INT;
    v_GRADE_TYPE TEXT;
    v_EME_Id BIGINT;
    v_EME_ExamName TEXT;
    v_EME_ExamOrder INT;
    v_ECTEX_RoundOffReqFlg BOOLEAN;
    v_ECTEX_MarksPercentValue NUMERIC(18,2);
    v_ECTEX_MarksPerFlag VARCHAR(10);
    v_ECTEX_ConversionReqFlg BOOLEAN;
    v_TERM_MAX_MARKS NUMERIC(18,2);
    v_TERM_OBTAINED_MARKS NUMERIC(18,2);
    v_TERM_PERCENTAGE NUMERIC(18,2);
    v_TERM_GRADE TEXT;
    v_ESTMPS_ObtainedMarks NUMERIC(18,2);
    v_ESTMPS_MaxMarks NUMERIC(18,2);
    v_ESTMPS_PassFailFlg TEXT;
    v_MaxMarks NUMERIC(18,2);
    v_SUBJECTWISEPER NUMERIC(18,2);
    v_ROW_COUNT INT;
    v_EXAM_GRADE TEXT;
    v_PERMARKS NUMERIC(18,2);
    v_ECT_Id_Total_NEW BIGINT;
    v_ECT_TermName_Total TEXT;
    v_ECT_TermStartDate_New TIMESTAMP;
    v_ECT_TermEndDate_New TIMESTAMP;
    v_ECT_Marks_New NUMERIC(18,2);
    v_EMGR_Id_Total_NEW INT;
    v_GRADE_TYPE_TOTAL TEXT;
    v_MARKSOBTAINEDTOTAL NUMERIC(18,2);
    v_MAXIMARKSTOTAL NUMERIC(18,2);
    v_PERCENTAGETOTAL NUMERIC(18,2);
    v_TOTALAMSTID BIGINT;
    v_TOTALEMEID BIGINT;
    v_TOTALEXAMNAME TEXT;
    v_TOTALGRADE TEXT;
    v_ROUNDOFF BOOLEAN;
    rec_student RECORD;
    rec_subject RECORD;
    rec_term RECORD;
    rec_exam RECORD;
    rec_term_total RECORD;
    rec_total_exam RECORD;
BEGIN

    /* ********************* GET STUDENT DETAILS ************* */
    IF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT DISTINCT A."AMST_Id",
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName"='' THEN '' ELSE A."AMST_FirstName" END || 
            CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName"='' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
            CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName"='' THEN '' ELSE ' ' || A."AMST_LastName" END) AS studentname,
            A."AMST_AdmNo" AS admno,
            B."AMAY_RollNo" AS rollno,
            D."ASMCL_ClassName" AS classname,
            E."ASMC_SectionName" AS sectionname,
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName"='' THEN '' ELSE A."AMST_FatherName" END || 
            CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname"='' THEN '' ELSE ' ' || A."AMST_FatherSurname" END) AS fathername,
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName"='' THEN '' ELSE A."AMST_MotherName" END || 
            CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname"='' THEN '' ELSE ' ' || A."AMST_MotherSurname" END) AS mothername,
            TO_CHAR(A."amst_dob", 'DD/MM/YYYY') AS dob,
            A."AMST_MobileNo" AS mobileno,
            (CASE WHEN A."AMST_PerStreet" IS NULL OR A."AMST_PerStreet"='' THEN '' ELSE A."AMST_PerStreet" END || 
            CASE WHEN A."AMST_PerArea" IS NULL OR A."AMST_PerArea"='' THEN '' ELSE ',' || A."AMST_PerArea" END || 
            CASE WHEN A."AMST_PerCity" IS NULL OR A."AMST_PerCity"='' THEN '' ELSE ',' || A."AMST_PerCity" END || 
            CASE WHEN A."AMST_PerAdd3" IS NULL OR A."AMST_PerAdd3"='' THEN '' ELSE ',' || A."AMST_PerAdd3" END) AS address,
            A."AMST_Photoname" AS photoname,
            NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::TEXT, NULL::TEXT,
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::TEXT,
            NULL::BIGINT, NULL::TEXT, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::TEXT
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id"=B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id"=B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id"=B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id"=B."ASMS_Id"
        LEFT JOIN "IVRM_Master_COUNTry" F ON F."IVRMMC_Id"=A."AMST_PerCOUNTry"
        LEFT JOIN "IVRM_Master_State" G ON G."IVRMMC_Id"=F."IVRMMC_Id" AND G."IVRMMS_Id"=A."AMST_PerState"
        WHERE A."MI_Id"=p_MI_Id::BIGINT AND B."ASMAY_Id"=p_ASMAY_Id::BIGINT AND B."ASMCL_Id"=p_ASMCL_Id::BIGINT 
        AND B."ASMS_Id"=p_ASMS_Id::BIGINT
        AND B."AMAY_ActiveFlag"=1 AND A."AMST_SOL"='S' AND A."AMST_ActiveFlag"=1
        ORDER BY rollno;

    /* ****** GET THE STUDENT WISE SUBJECT LIST ********* */
    ELSIF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            a."AMST_Id", a."ISMS_Id", a."ISMS_SubjectName", a."EYCES_SubjectOrder", a."EYCES_AplResultFlg",
            CASE WHEN a."ESG_Id" IS NULL THEN a."ISMS_Id" ELSE a."ESG_Id" END AS "ESG_Id",
            CASE WHEN a."ESG_SubjectGroupName" IS NULL THEN a."ISMS_SubjectName" ELSE a."ESG_SubjectGroupName" END AS "ESG_SubjectGroupName",
            CASE WHEN a."ESG_CompulsoryFlag" IS NULL THEN 'N' ELSE a."ESG_CompulsoryFlag" END AS "ESG_CompulsoryFlag",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::TEXT,
            NULL::BIGINT, NULL::TEXT, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::TEXT
        FROM (
            SELECT DISTINCT A."AMST_Id", B."ISMS_Id", B."ISMS_SubjectName", m."EYCES_SubjectOrder", M."EYCES_AplResultFlg",
            (SELECT SG."ESG_Id" FROM "Exm"."Exm_Subject_Group" SG 
             INNER JOIN "Exm"."Exm_Subject_Group_Subjects" SGS ON SGS."ESG_Id"=SG."ESG_Id" AND SGS."ISMS_Id"=B."ISMS_Id"
             AND SGS."ESGS_ActiveFlag"=1 AND SG."EMCA_Id"=I."EMCA_Id" AND SG."ASMAY_Id"=p_ASMAY_Id::BIGINT 
             AND SG."ESG_ActiveFlag"=1 AND SG."MI_Id"=p_MI_Id::BIGINT AND SG."ESG_ExamPromotionFlag"='PE' LIMIT 1) AS "ESG_Id",
            (SELECT SG."ESG_SubjectGroupName" FROM "Exm"."Exm_Subject_Group" SG 
             INNER JOIN "Exm"."Exm_Subject_Group_Subjects" SGS ON SGS."ESG_Id"=SG."ESG_Id" AND SGS."ISMS_Id"=B."ISMS_Id"
             AND SGS."ESGS_ActiveFlag"=1 AND SG."EMCA_Id"=I."EMCA_Id" AND SG."ASMAY_Id"=p_ASMAY_Id::BIGINT 
             AND SG."ESG_ActiveFlag"=1 AND SG."MI_Id"=p_MI_Id::BIGINT AND SG."ESG_ExamPromotionFlag"='PE' LIMIT 1) AS "ESG_SubjectGroupName",
            (SELECT SG."ESG_CompulsoryFlag" FROM "Exm"."Exm_Subject_Group" SG 
             INNER JOIN "Exm"."Exm_Subject_Group_Subjects" SGS ON SGS."ESG_Id"=SG."ESG_Id" AND SGS."ISMS_Id"=B."ISMS_Id"
             AND SGS."ESGS_ActiveFlag"=1 AND SG."EMCA_Id"=I."EMCA_Id" AND SG."ASMAY_Id"=p_ASMAY_Id::BIGINT 
             AND SG."ESG_ActiveFlag"=1 AND SG."MI_Id"=p_MI_Id::BIGINT AND SG."ESG_ExamPromotionFlag"='PE' LIMIT 1) AS "ESG_CompulsoryFlag"
            FROM "EXM"."Exm_Studentwise_Subjects" A 
            INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id"=B."ISMS_Id"
            INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id"=A."AMST_Id"
            INNER JOIN "Adm_M_Student" D ON D."AMST_Id"=C."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id"=C."ASMAY_Id" AND E."ASMAY_Id"=A."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id"=C."ASMCL_Id" AND F."ASMCL_Id"=A."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id"=C."ASMS_Id" AND G."ASMS_Id"=A."ASMS_Id"
            INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id"=E."ASMAY_Id" AND H."ASMCL_Id"=F."ASMCL_Id" 
            AND H."ASMS_Id"=G."ASMS_Id" AND H."ECAC_ActiveFlag"=1
            AND H."ASMCL_Id"=p_ASMCL_Id::BIGINT AND H."ASMAY_Id"=p_ASMAY_Id::BIGINT AND H."ASMS_Id"=p_ASMS_Id::BIGINT
            INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id"=H."EMCA_Id"
            INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id"=E."ASMAY_Id" AND J."EMCA_Id"=I."EMCA_Id" 
            AND J."ASMAY_Id"=p_ASMAY_Id::BIGINT AND J."EYC_ActiveFlg"=1
            INNER JOIN "EXM"."Exm_Yearly_Category_Exams" K ON K."EYC_Id"=J."EYC_Id" AND K."EYCE_ActiveFlg"=1
            INNER JOIN "EXM"."Exm_Master_Exam" L ON L."EME_Id"=K."EME_Id"
            INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id"=K."EYCE_Id" AND M."ISMS_Id"=B."ISMS_Id" 
            AND M."EYCES_ActiveFlg"=1
            WHERE C."ASMAY_Id"=p_ASMAY_Id::BIGINT AND A."ASMAY_Id"=p_ASMAY_Id::BIGINT
            AND A."ASMCL_Id"=p_ASMCL_Id::BIGINT AND C."ASMCL_Id"=p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id"=p_ASMS_Id::BIGINT AND C."ASMS_Id"=p_ASMS_Id::BIGINT
            AND A."ESTSU_ActiveFlg"=1 AND B."ISMS_ActiveFlag"=1
            ORDER BY "EYCES_SubjectOrder" LIMIT 100
        ) a
        ORDER BY a."EYCES_SubjectOrder";

    ELSIF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::TEXT, NULL::TEXT,
            SUM(A."ASA_ClassHeld") AS "TOTALWORKINGDAYS",
            SUM(A."ASA_Class_Attended") AS "PRESENTDAYS",
            CAST(SUM(A."ASA_Class_Attended") * 100.0 / NULLIF(SUM(A."ASA_ClassHeld"), 0) AS NUMERIC(18,2)) AS "ATTENDANCEPERCENTAGE",
            B."AMST_Id",
            NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::NUMERIC, NULL::NUMERIC,
            NULL::TEXT, NULL::BOOLEAN, NULL::TEXT
        FROM "Adm_Student_Attendance" A 
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id"=B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id"=B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id"=B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id"=C."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id"=C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id"=C."ASMS_Id"
        WHERE A."ASMAY_Id"=p_ASMAY_Id::BIGINT AND A."ASMCL_Id"=p_ASMCL_Id::BIGINT AND A."ASMS_Id"=p_ASMS_Id::BIGINT 
        AND A."ASA_Activeflag"=1 AND A."MI_Id"=p_MI_Id::BIGINT
        AND C."ASMAY_Id"=p_ASMAY_Id::BIGINT AND C."ASMCL_Id"=p_ASMCL_Id::BIGINT AND C."ASMS_Id"=p_ASMS_Id::BIGINT 
        AND C."AMAY_ActiveFlag"=1 AND D."AMST_SOL"='S' AND D."AMST_ActiveFlag"=1
        GROUP BY B."AMST_Id";

    ELSIF p_FLAG = '4' THEN

        DROP TABLE IF EXISTS "BGHS_Temp_Term_iX_Report_Details";

        CREATE TEMP TABLE "BGHS_Temp_Term_iX_Report_Details" (
            "AMST_Id" BIGINT,
            "termid" BIGINT,
            "termname" TEXT,
            "subjectid" BIGINT,
            "subjectname" TEXT,
            "examid" BIGINT,
            "examname" TEXT,
            "maxmiummarks" NUMERIC(18,2),
            "marksobtained" NUMERIC(18,2),
            "grade" TEXT,
            "apptoresult" BOOLEAN,
            "resultflag" TEXT
        );

        SELECT DISTINCT "EMCA_Id" INTO v_EMCA_Id 
        FROM "EXM"."Exm_Category_Class" 
        WHERE "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "ASMCL_Id"=p_ASMCL_Id::BIGINT 
        AND "ASMS_Id"=p_ASMS_Id::BIGINT AND "MI_Id"=p_MI_Id::BIGINT AND "ECAC_ActiveFlag"=1;

        SELECT DISTINCT "EYC_Id" INTO v_EYC_Id 
        FROM "Exm"."Exm_Yearly_Category" 
        WHERE "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "MI_Id"=p_MI_Id::BIGINT AND "EMCA_Id"=v_EMCA_Id AND "EYC_ActiveFlg"=1;

        /* GET STUDENT DETAILS CURSOR */
        FOR rec_student IN
            SELECT DISTINCT A."AMST_Id"
            FROM "Adm_M_Student" A 
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id"=B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id"=B."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id"=B."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id"=B."ASMS_Id"
            WHERE A."MI_Id"=p_MI_Id::BIGINT AND B."ASMAY_Id"=p_ASMAY_Id::BIGINT 
            AND B."ASMCL_Id"=p_ASMCL_Id::BIGINT AND B."ASMS_Id"=p_ASMS_Id::BIGINT
            AND B."AMAY_ActiveFlag"=1 AND A."AMST_SOL"='S' AND A."AMST_ActiveFlag"=1
        LOOP
            v_AMST_Id_New := rec_student."AMST_Id"::TEXT;

            /* GET STUDENT SUBJECT WISE DETAILS */
            FOR rec_subject IN
                SELECT DISTINCT B."ISMS_Id", B."ISMS_SubjectName", m."EYCES_SubjectOrder", M."EYCES_AplResultFlg"
                FROM "EXM"."Exm_Studentwise_Subjects" A 
                INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id"=B."ISMS_Id"
                INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id"=A."AMST_Id"
                INNER JOIN "Adm_M_Student" D ON D."AMST_Id"=C."AMST_Id"
                INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id"=C."ASMAY_Id" AND E."ASMAY_Id"=A."ASMAY_Id"
                INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id"=C."ASMCL_Id" AND F."ASMCL_Id"=A."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id"=C."ASMS_Id" AND G."ASMS_Id"=A."ASMS_Id"
                INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id"=E."ASMAY_Id" AND H."ASMCL_Id"=F."ASMCL_Id" 
                AND H."ASMS_Id"=G."ASMS_Id" AND H."ECAC_ActiveFlag"=1
                AND H."ASMCL_Id"=p_ASMCL_Id::BIGINT AND H."ASMAY_Id"=p_ASMAY_Id::BIGINT AND H."ASMS_Id"=p_ASMS_Id::BIGINT
                INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id"=H."EMCA_Id"
                INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id"=E."ASMAY_Id" AND J."EMCA_Id"=I."EMCA_Id" 
                AND J."ASMAY_Id"=p_ASMAY_Id::BIGINT AND J."EYC_ActiveFlg"=1
                INNER JOIN "EXM"."Exm_Yearly_Category_Exams" K ON K."EYC_Id"=J."EYC_Id" AND K."EYCE_ActiveFlg"=1
                INNER JOIN "EXM"."Exm_Master_Exam" L ON L."EME_Id"=K."EME_Id"
                INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id"=K."EYCE_Id" AND M."ISMS_Id"=B."ISMS_Id" 
                AND M."EYCES_ActiveFlg"=1
                WHERE C."ASMAY_Id"=p_ASMAY_Id::BIGINT AND A."ASMAY_Id"=p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id"=p_ASMCL_Id::BIGINT AND C."ASMCL_Id"=p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id"=p_ASMS_Id::BIGINT AND C."ASMS_Id"=p_ASMS_Id::BIGINT
                AND A."ESTSU_ActiveFlg"=1 AND B."ISMS_ActiveFlag"=1 
                AND A."AMST_Id"=v_AMST_Id_New::BIGINT AND C."AMST_Id"=v_AMST_Id_New::BIGINT
                ORDER BY "EYCES_SubjectOrder"
            LOOP
                v_ISMS_Id_New := rec_subject."ISMS_Id"::TEXT;
                v_ISMS_SubjectName := rec_subject."ISMS_SubjectName";
                v_EYCES_SubjectOrder := rec_subject."EYCES_SubjectOrder";
                v_EYCES_AplResultFlg := rec_subject."EYCES_AplResultFlg";

                /* GET TERM DETAILS */
                FOR rec_term IN
                    SELECT "ECT_Id", "ECT_TermName", "EMGR_Id" 
                    FROM "Exm"."Exm_CCE_TERMS" 
                    WHERE "MI_Id"=p_MI_Id::BIGINT AND "ASMAY_Id"=p_ASMAY_Id::BIGINT 
                    AND "EMCA_Id"=v_EMCA_Id AND "ECT_ActiveFlag"=1
                LOOP
                    v_ECT_Id := rec_term."ECT_Id";
                    v_ECT_TermName := rec_term."ECT_TermName";
                    v_EMGR_Id := rec_term."EMGR_Id";

                    SELECT "EMGR_MarksPerFlag" INTO v_GRADE_TYPE 
                    FROM "Exm"."Exm_Master_Grade" 
                    WHERE "MI_Id"=p_MI_Id::BIGINT AND "EMGR_Id"=v_EMGR_Id;

                    v_TERM_OBTAINED_MARKS := 0;
                    v_TERM_MAX_MARKS := 0;
                    v_TERM_GRADE := '0';

                    /* GET TERM WISE EXAM DETAILS */
                    FOR rec_exam IN
                        SELECT B."EME_Id", C."EME_ExamName", C."EME_ExamOrder", B."ECTEX_RoundOffReqFlg",
                               B."ECTEX_MarksPercentValue", B."ECTEX_MarksPerFlag", B."ECTEX_ConversionReqFlg"
                        FROM "Exm"."Exm_CCE_TERMS" A 
                        INNER JOIN "Exm"."EXM_CCE_TERMS_Exams" B ON A."ECT_Id"=B."ECT_Id"
                        INNER JOIN "Exm"."Exm_Master_Exam" C ON C."EME_Id"=B."EME_Id"
                        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" D ON D."EME_Id"=C."EME_Id" AND D."EYCE_ActiveFlg"=1
                        INNER JOIN "Exm"."Exm_Yearly_Category" E ON E."EYC_Id"=D."EYC_Id" 
                        AND E."ASMAY_Id"=p_ASMAY_Id::BIGINT AND E."EYC_ActiveFlg"=1
                        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" F ON F."EYCE_Id"=D."EYCE_Id" 
                        AND F."EYCES_ActiveFlg"=1 AND F."ISMS_Id"=v_ISMS_Id_New::BIGINT
                        WHERE B."ECT_Id"=v_ECT_Id AND B."ECTEX_ActiveFlag"=1 AND A."ASMAY_Id"=p_ASMAY_Id::BIGINT 
                        AND A."MI_Id"=p_MI_Id::BIGINT AND C."EME_ActiveFlag"=1 
                        AND E."EMCA_Id"=v_EMCA_Id AND A."EMCA_Id"=v_EMCA_Id
                    LOOP
                        v_EME_Id := rec_exam."EME_Id";
                        v_EME_ExamName := rec_exam."EME_ExamName";
                        v_EME_ExamOrder := rec_exam."EME_ExamOrder";
                        v_ECTEX_