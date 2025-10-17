CREATE OR REPLACE FUNCTION "dbo"."BIS_EXAM_GET_STUDENT_DETAILS"(
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
    v_FROMDATE TIMESTAMP;
    v_TODATE TIMESTAMP;
    v_ECT_Id INTEGER;
    v_ECT_TermName VARCHAR;
    v_ECT_Id_NEW BIGINT;
    v_ECT_TermStartDate TIMESTAMP;
    v_ECT_TermEndDate TIMESTAMP;
    v_ECT_Marks DECIMAL(18,2);
    rec RECORD;
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
            A."AMST_Photoname",
            A."amsT_PerPincode",
            A."amst_dob",
            COALESCE(A."AMST_PerStreet", ' ') AS "AMST_PerStreet",
            COALESCE(A."AMST_PerArea", ' ') AS "AMST_PerArea",
            COALESCE(A."AMST_PerCity", ' ') AS "AMST_PerCity",
            COALESCE(MS."ivrmms_name", ' ') AS "ivrmms_name",
            COALESCE(MC."IVRMMC_CountryName", ' ') AS "IVRMMC_CountryName",
            C."ASMAY_Year",
            TRIM(BOTH ',' FROM 
                COALESCE(',' || NULLIF(A."AMST_PerStreet", ''), '') || 
                COALESCE(',' || NULLIF(A."AMST_PerArea", ''), '') ||
                COALESCE(',' || NULLIF(A."AMST_PerCity", ''), '')
            ) AS addressd1
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        LEFT OUTER JOIN "IVRM_Master_Country" MC ON MC."IVRMMC_Id" = A."AMST_PerCountry"
        LEFT OUTER JOIN "IVRM_Master_State" MS ON A."AMST_PerState" = MS."IVRMMS_Id" AND MC."IVRMMC_Id" = MS."IVRMMC_Id"
        WHERE A."MI_Id" = p_MI_Id::BIGINT 
            AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND B."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND B."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND A."AMST_Id" = p_AMST_Id::BIGINT;

    /* STUDENT WISE SUBJECT DETAILS */
    ELSIF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT DISTINCT 
            MPS."AMST_Id",
            MPS."ISMS_Id",
            MS."ISMS_SubjectName",
            PS."EMPS_SubjOrder" AS grporder,
            PS."EMPS_AppToResultFlg"
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
            AND MPS."AMST_Id" = p_AMST_Id::BIGINT
        ORDER BY MPS."AMST_Id", grporder;

    /* STUDENT WISE ATTENDANCE */
    ELSIF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT 
            SUM(A."ASA_ClassHeld") AS TOTALWORKINGDAYS,
            SUM(A."ASA_Class_Attended") AS PRESENTDAYS,
            CAST(SUM(A."ASA_Class_Attended") * 100.0 / NULLIF(SUM(A."ASA_ClassHeld"), 0) AS DECIMAL(18,2)) AS ATTENDANCEPERCENTAGE,
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
            AND B."AMST_Id" = p_AMST_Id::BIGINT
        GROUP BY B."AMST_Id";

    /* ****** SKILLS ****** */
    ELSIF p_FLAG = '4' THEN
        RETURN QUERY
        SELECT 
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
            AND A."AMST_Id" = p_AMST_Id::BIGINT
        ORDER BY C."ECSA_SkillOrder";

    /* ****** ACTIVITES LIST ********* */
    ELSIF p_FLAG = '5' THEN
        RETURN QUERY
        SELECT 
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
            AND A."AMST_Id" = p_AMST_Id::BIGINT
        ORDER BY C."ECACTA_SkillOrder";

    /* TERM WISE ATTEDNACE */
    ELSIF p_FLAG = '6' THEN
        DROP TABLE IF EXISTS "NDS_Temp_Term_Report_ATTENDANCE_Details";
        
        CREATE TEMP TABLE "NDS_Temp_Term_Report_ATTENDANCE_Details" (
            "AMST_Id" BIGINT,
            "TOTALWORKINGDAYS" DECIMAL(18,2),
            "PRESENTDAYS" DECIMAL(18,2),
            "ECT_Id" INTEGER
        );

        FOR rec IN 
            SELECT "ECT_TermStartDate", "ECT_TermEndDate", "ECT_Id" 
            FROM "Exm"."Exm_CCE_TERMS" 
            WHERE "MI_Id" = p_MI_Id::BIGINT 
                AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "EMCA_Id" = v_EMCA_Id 
                AND "ECT_ActiveFlag" = 1
        LOOP
            v_FROMDATE := rec."ECT_TermStartDate";
            v_TODATE := rec."ECT_TermEndDate";
            v_ECT_Id := rec."ECT_Id";

            INSERT INTO "NDS_Temp_Term_Report_ATTENDANCE_Details" ("AMST_Id", "TOTALWORKINGDAYS", "PRESENTDAYS", "ECT_Id")
            SELECT 
                B."AMST_Id",
                SUM(A."ASA_ClassHeld") AS TOTALWORKINGDAYS,
                SUM(A."ASA_Class_Attended") AS PRESENTDAYS,
                v_ECT_Id
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
                AND C."AMAY_ActiveFlag" = 1 
                AND D."AMST_SOL" = 'S' 
                AND D."AMST_ActiveFlag" = 1
                AND (A."ASA_FromDate" BETWEEN v_FROMDATE AND v_TODATE) 
                AND B."AMST_Id" = p_AMST_Id::BIGINT
            GROUP BY B."AMST_Id";
        END LOOP;

        RETURN QUERY
        SELECT * FROM "NDS_Temp_Term_Report_ATTENDANCE_Details";

    ELSIF p_FLAG = '7' THEN
        DROP TABLE IF EXISTS "NDS_Temp_Term_Report_Sports_Details_New";
        
        CREATE TEMP TABLE "NDS_Temp_Term_Report_Sports_Details_New" (
            "AMST_Id" BIGINT,
            "SPCCSHW_Height" DECIMAL(18,2),
            "SPCCSHW_Weight" DECIMAL(18,2),
            "ECT_Id" INTEGER,
            "SPCCSHW_AsOnDate" TIMESTAMP
        );

        FOR rec IN 
            SELECT "ECT_Id", "ECT_TermName", "ECT_TermStartDate", "ECT_TermEndDate" 
            FROM "Exm"."Exm_CCE_TERMS" 
            WHERE "MI_Id" = p_MI_Id::BIGINT 
                AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "EMCA_Id" = v_EMCA_Id 
                AND "ECT_ActiveFlag" = 1
        LOOP
            v_ECT_Id_NEW := rec."ECT_Id";
            v_ECT_TermName := rec."ECT_TermName";
            v_ECT_TermStartDate := rec."ECT_TermStartDate";
            v_ECT_TermEndDate := rec."ECT_TermEndDate";

            INSERT INTO "NDS_Temp_Term_Report_Sports_Details_New" ("AMST_Id", "SPCCSHW_Height", "SPCCSHW_Weight", "ECT_Id", "SPCCSHW_AsOnDate")
            SELECT DISTINCT 
                A."AMST_Id",
                A."SPCCSHW_Height",
                A."SPCCSHW_Weight",
                H."ECT_Id",
                A."SPCCSHW_AsOnDate"
            FROM "SPC"."SPCC_Student_HeightWeight" A 
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_M_Student" C ON C."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id" = A."ASMAY_Id" AND D."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id" = A."ASMCL_Id" AND E."ASMCL_Id" = B."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id" = A."ASMS_Id" AND F."ASMS_Id" = B."ASMS_Id"
            INNER JOIN "Exm"."Exm_Category_Class" G ON G."ASMAY_Id" = D."ASMAY_Id" AND E."ASMCL_Id" = G."ASMCL_Id" AND F."ASMS_Id" = G."ASMS_Id" AND G."ECAC_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_CCE_TERMS" H ON H."EMCA_Id" = G."EMCA_Id" AND H."ECT_ActiveFlag" = 1
            WHERE A."MI_Id" = p_MI_Id::BIGINT 
                AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND A."AMST_Id" = p_AMST_Id::BIGINT
                AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND B."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND B."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND B."AMST_Id" = p_AMST_Id::BIGINT
                AND G."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND G."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND G."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND H."ECT_Id" = v_ECT_Id_NEW
                AND A."SPCCMHW_ActiveFlag" = 1
                AND (A."SPCCSHW_AsOnDate" BETWEEN v_ECT_TermStartDate AND v_ECT_TermEndDate)
            ORDER BY A."SPCCSHW_AsOnDate" DESC
            LIMIT 1;
        END LOOP;

        RETURN QUERY
        SELECT * FROM "NDS_Temp_Term_Report_Sports_Details_New";

    END IF;

END;
$$;