CREATE OR REPLACE FUNCTION "dbo"."Exam_Malda_Promotion_IX_Details"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_FLAG" TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "admno" TEXT,
    "rollno" BIGINT,
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
    "EYCES_SubjectOrder" INT,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MarksDisplayFlg" INT,
    "EYCES_GradeDisplayFlg" INT,
    "EMPS_MaxMarks" DECIMAL(18,2),
    "EMPS_MinMarks" DECIMAL(18,2),
    "ESG_Id" BIGINT,
    "ESG_SubjectGroupName" TEXT,
    "EMPSG_GroupName" TEXT,
    "EMPSG_DisplayName" TEXT,
    "EMPSG_Order" INT,
    "EMPSG_Id" BIGINT,
    "ESTMPPSG_GroupMaxMarks" DECIMAL(18,2),
    "ESTMPPSG_GroupObtMarks" DECIMAL(18,2),
    "EMPS_SubjOrder" INT,
    "EMPS_AppToResultFlg" BOOLEAN,
    "ESTMPPSG_GroupObtGrade" TEXT,
    "grporder" INT,
    "GroupClassHighest" DECIMAL(18,2),
    "GroupSectionHighest" DECIMAL(18,2),
    "PER" DECIMAL(18,2),
    "GroupClassMaxHighest" DECIMAL(18,2),
    "GroupSectionMaxHighest" DECIMAL(18,2),
    "GroupClassMaxPer" DECIMAL(18,2),
    "GroupSectionMaxPer" DECIMAL(18,2),
    "GroupClassMaxGrade" TEXT,
    "GroupSectionMaxGrade" TEXT,
    "EME_Id" BIGINT,
    "ESTMP_TotalMaxMarks" DECIMAL(18,2),
    "ESTMP_TotalObtMarks" DECIMAL(18,2),
    "ESTMP_Percentage" DECIMAL(18,2),
    "ESTMP_SectionRank" INT,
    "ESTMP_ClassRank" INT,
    "ESTMP_Result" TEXT,
    "TOTALPRESENTDAYS" DECIMAL(18,2),
    "TOTALWORKINGDAYS" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_EMCA_Id" BIGINT;
    "v_EYC_Id" BIGINT;
    "v_EMGR_Id" BIGINT;
    "v_EMGR_FLAG" TEXT;
    "v_ROWCOUNT" BIGINT;
    "v_ESG_Id" BIGINT;
    "v_ESG_GroupName" TEXT;
    "v_AMST_IdFL" BIGINT;
    "v_EME_Id" BIGINT;
    "v_GROUPNAME" TEXT;
    "v_EYCE_AttendanceFromDate" TIMESTAMP;
    "v_EYCE_AttendanceToDate" TIMESTAMP;
    "v_gradename" TEXT;
    "v_PER" DECIMAL(18,2);
BEGIN

    SELECT DISTINCT "EMCA_Id" INTO "v_EMCA_Id" 
    FROM "EXM"."Exm_Category_Class" 
    WHERE "ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
    AND "ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
    AND "ASMS_Id" = "p_ASMS_Id"::BIGINT 
    AND "MI_Id" = "p_MI_Id"::BIGINT 
    AND "ECAC_ActiveFlag" = TRUE
    LIMIT 1;

    SELECT DISTINCT "EYC_Id" INTO "v_EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
    AND "MI_Id" = "p_MI_Id"::BIGINT 
    AND "EMCA_Id" = "v_EMCA_Id" 
    AND "EYC_ActiveFlg" = TRUE
    LIMIT 1;

    IF "p_FLAG" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT A."AMST_Id",
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName" = '' THEN '' ELSE A."AMST_FirstName" END || 
             CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
             CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END)::TEXT AS "studentname",
            A."AMST_AdmNo"::TEXT AS "admno",
            B."AMAY_RollNo" AS "rollno",
            D."ASMCL_ClassName"::TEXT AS "classname",
            E."ASMC_SectionName"::TEXT AS "sectionname",
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName" = '' THEN '' ELSE A."AMST_FatherName" END || 
             CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname" = '' THEN '' ELSE ' ' || A."AMST_FatherSurname" END)::TEXT AS "fathername",
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName" = '' THEN '' ELSE A."AMST_MotherName" END || 
             CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname" = '' THEN '' ELSE ' ' || A."AMST_MotherSurname" END)::TEXT AS "mothername",
            TO_CHAR(A."amst_dob", 'DD/MM/YYYY')::TEXT AS "dob",
            A."AMST_MobileNo"::TEXT AS "mobileno",
            (CASE WHEN A."AMST_PerStreet" IS NULL OR A."AMST_PerStreet" = '' THEN '' ELSE A."AMST_PerStreet" END || 
             CASE WHEN A."AMST_PerArea" IS NULL OR A."AMST_PerArea" = '' THEN '' ELSE ',' || A."AMST_PerArea" END || 
             CASE WHEN A."AMST_PerCity" IS NULL OR A."AMST_PerCity" = '' THEN '' ELSE ',' || A."AMST_PerCity" END || 
             CASE WHEN A."AMST_PerAdd3" IS NULL OR A."AMST_PerAdd3" = '' THEN '' ELSE ',' || A."AMST_PerAdd3" END)::TEXT AS "address",
            A."AMST_Photoname"::TEXT AS "photoname",
            NULL::BIGINT, NULL::TEXT, NULL::INT, NULL::BOOLEAN, NULL::INT, NULL::INT, NULL::DECIMAL, NULL::DECIMAL, NULL::BIGINT, NULL::TEXT,
            NULL::TEXT, NULL::TEXT, NULL::INT, NULL::BIGINT, NULL::DECIMAL, NULL::DECIMAL, NULL::INT, NULL::BOOLEAN, NULL::TEXT, NULL::INT,
            NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::TEXT, NULL::TEXT,
            NULL::BIGINT, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::INT, NULL::INT, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL
        FROM "Adm_M_Student" A
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        LEFT JOIN "IVRM_Master_COUNTRY" F ON F."IVRMMC_Id" = A."AMST_PerCOUNTry"
        LEFT JOIN "IVRM_Master_State" G ON G."IVRMMC_Id" = F."IVRMMC_Id" AND G."IVRMMS_Id" = A."AMST_PerState"
        WHERE A."MI_Id" = "p_MI_Id"::BIGINT 
        AND B."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
        AND B."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
        AND B."ASMS_Id" = "p_ASMS_Id"::BIGINT
        AND B."AMAY_ActiveFlag" = TRUE 
        AND A."AMST_SOL" = 'S' 
        AND A."AMST_ActiveFlag" = TRUE
        ORDER BY B."AMAY_RollNo";

    ELSIF "p_FLAG" = '2' THEN
        RETURN QUERY
        SELECT NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            "a"."ISMS_Id",
            "a"."ISMS_SubjectName",
            "a"."EYCES_SubjectOrder",
            "a"."EYCES_AplResultFlg",
            "a"."EYCES_MarksDisplayFlg",
            "a"."EYCES_GradeDisplayFlg",
            "a"."EMPS_MaxMarks",
            "a"."EMPS_MinMarks",
            "a"."ESG_Id",
            "a"."ESG_SubjectGroupName",
            NULL::TEXT, NULL::TEXT, NULL::INT, NULL::BIGINT, NULL::DECIMAL, NULL::DECIMAL, NULL::INT, NULL::BOOLEAN, NULL::TEXT, NULL::INT,
            NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::TEXT, NULL::TEXT,
            NULL::BIGINT, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::INT, NULL::INT, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL
        FROM (
            SELECT DISTINCT A."AMST_Id",
                B."ISMS_Id",
                B."ISMS_SubjectName",
                L."EMPS_SubjOrder" AS "EYCES_SubjectOrder",
                L."EMPS_AppToResultFlg" AS "EYCES_AplResultFlg",
                0 AS "EYCES_MarksDisplayFlg",
                0 AS "EYCES_GradeDisplayFlg",
                L."EMPS_MaxMarks",
                L."EMPS_MinMarks",
                CASE WHEN (SELECT SG."ESG_Id" FROM "Exm"."Exm_Subject_Group" SG 
                           INNER JOIN "Exm"."Exm_Subject_Group_Subjects" SGS ON SGS."ESG_Id" = SG."ESG_Id" 
                           AND SGS."ISMS_Id" = B."ISMS_Id" AND SGS."ESGS_ActiveFlag" = TRUE 
                           AND SG."EMCA_Id" = I."EMCA_Id" AND SG."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                           AND SG."ESG_ActiveFlag" = TRUE AND SG."MI_Id" = "p_MI_Id"::BIGINT 
                           AND SG."ESG_ExamPromotionFlag" = 'PE' LIMIT 1) IS NULL 
                     THEN B."ISMS_Id" + 1000 
                     ELSE (SELECT SG."ESG_Id" FROM "Exm"."Exm_Subject_Group" SG 
                           INNER JOIN "Exm"."Exm_Subject_Group_Subjects" SGS ON SGS."ESG_Id" = SG."ESG_Id" 
                           AND SGS."ISMS_Id" = B."ISMS_Id" AND SGS."ESGS_ActiveFlag" = TRUE 
                           AND SG."EMCA_Id" = I."EMCA_Id" AND SG."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                           AND SG."ESG_ActiveFlag" = TRUE AND SG."MI_Id" = "p_MI_Id"::BIGINT 
                           AND SG."ESG_ExamPromotionFlag" = 'PE' LIMIT 1) 
                END AS "ESG_Id",
                CASE WHEN (SELECT SG."ESG_SubjectGroupName" FROM "Exm"."Exm_Subject_Group" SG 
                           INNER JOIN "Exm"."Exm_Subject_Group_Subjects" SGS ON SGS."ESG_Id" = SG."ESG_Id" 
                           AND SGS."ISMS_Id" = B."ISMS_Id" AND SGS."ESGS_ActiveFlag" = TRUE 
                           AND SG."EMCA_Id" = I."EMCA_Id" AND SG."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                           AND SG."ESG_ActiveFlag" = TRUE AND SG."MI_Id" = "p_MI_Id"::BIGINT 
                           AND SG."ESG_ExamPromotionFlag" = 'PE' LIMIT 1) IS NULL 
                     THEN B."ISMS_SubjectName" 
                     ELSE (SELECT SG."ESG_SubjectGroupName" FROM "Exm"."Exm_Subject_Group" SG 
                           INNER JOIN "Exm"."Exm_Subject_Group_Subjects" SGS ON SGS."ESG_Id" = SG."ESG_Id" 
                           AND SGS."ISMS_Id" = B."ISMS_Id" AND SGS."ESGS_ActiveFlag" = TRUE 
                           AND SG."EMCA_Id" = I."EMCA_Id" AND SG."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                           AND SG."ESG_ActiveFlag" = TRUE AND SG."MI_Id" = "p_MI_Id"::BIGINT 
                           AND SG."ESG_ExamPromotionFlag" = 'PE' LIMIT 1) 
                END AS "ESG_SubjectGroupName"
            FROM "EXM"."Exm_Studentwise_Subjects" A
            INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
            INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
            INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" 
                AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = TRUE 
                AND H."ASMCL_Id" = "p_ASMCL_Id"::BIGINT AND H."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                AND H."ASMS_Id" = "p_ASMS_Id"::BIGINT
            INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
            INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" 
                AND J."ASMAY_Id" = "p_ASMAY_Id"::BIGINT AND J."EYC_ActiveFlg" = TRUE
            INNER JOIN "EXM"."Exm_M_Promotion" K ON K."EYC_Id" = J."EYC_Id" AND K."EMP_ActiveFlag" = TRUE 
                AND K."MI_Id" = "p_MI_Id"::BIGINT
            INNER JOIN "EXM"."Exm_M_Promotion_Subjects" L ON L."EMP_Id" = K."EMP_Id" AND L."ISMS_Id" = B."ISMS_Id"
            WHERE C."ASMAY_Id" = "p_ASMAY_Id"::BIGINT AND A."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                AND A."ASMCL_Id" = "p_ASMCL_Id"::BIGINT AND C."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
                AND A."ASMS_Id" = "p_ASMS_Id"::BIGINT AND C."ASMS_Id" = "p_ASMS_Id"::BIGINT
                AND A."ESTSU_ActiveFlg" = TRUE AND B."ISMS_ActiveFlag" = TRUE
            ORDER BY L."EMPS_SubjOrder"
        ) "a"
        ORDER BY "a"."EYCES_SubjectOrder";

    ELSIF "p_FLAG" = '3' THEN
        RETURN QUERY
        SELECT NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::BIGINT, NULL::TEXT, NULL::INT, NULL::BOOLEAN, NULL::INT, NULL::INT, NULL::DECIMAL, NULL::DECIMAL, NULL::BIGINT, NULL::TEXT,
            A."EMPSG_GroupName",
            A."EMPSG_DisplayName",
            A."EMPSG_Order",
            NULL::BIGINT, NULL::DECIMAL, NULL::DECIMAL, NULL::INT, NULL::BOOLEAN, NULL::TEXT, NULL::INT,
            NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::TEXT, NULL::TEXT,
            NULL::BIGINT, NULL::DECIMAL, NULL::DECIMAL, NULL::DECIMAL, NULL::INT, NULL::INT, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL
        FROM "Exm"."Exm_M_Prom_Subj_Group" A
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMPS_Id" = B."EMPS_Id" 
            AND A."EMPSG_ActiveFlag" = TRUE AND B."EMPS_ActiveFlag" = TRUE
        INNER JOIN "Exm"."Exm_M_Promotion" C ON C."EMP_Id" = B."EMP_Id" AND C."EMP_ActiveFlag" = TRUE
        INNER JOIN "EXM"."Exm_Yearly_Category" D ON D."EYC_Id" = C."EYC_Id" 
            AND D."EYC_ActiveFlg" = TRUE AND D."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        INNER JOIN "EXM"."Exm_Category_Class" E ON E."EMCA_Id" = D."EMCA_Id" AND E."ECAC_ActiveFlag" = TRUE
        WHERE E."ASMAY_Id" = "p_ASMAY_Id"::BIGINT AND E."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND E."ASMS_Id" = "p_ASMS_Id"::BIGINT AND E."MI_Id" = "p_MI_Id"::BIGINT
        ORDER BY A."EMPSG_Order";

    ELSIF "p_FLAG" = '4' THEN
        DROP TABLE IF EXISTS "Malda_Temp_Term_Report_IX_Details";
        DROP TABLE IF EXISTS "groupClassHighest_Temp";
        DROP TABLE IF EXISTS "groupSectionHighest_Temp";

        SELECT DISTINCT "EMGR_Id" INTO "v_EMGR_Id" 
        FROM "Exm"."Exm_M_Promotion" 
        WHERE "EYC_Id" = "v_EYC_Id" AND "EMP_ActiveFlag" = TRUE AND "MI_Id" = "p_MI_Id"::BIGINT
        LIMIT 1;

        SELECT "EMGR_MarksPerFlag" INTO "v_EMGR_FLAG" 
        FROM "Exm"."Exm_Master_Grade" 
        WHERE "MI_Id" = "p_MI_Id"::BIGINT AND "EMGR_Id" = "v_EMGR_Id" AND "EMGR_ActiveFlag" = TRUE
        LIMIT 1;

        CREATE TEMP TABLE "Malda_Temp_Term_Report_IX_Details" AS
        SELECT * FROM (
            SELECT DISTINCT MPS."AMST_Id", MPS."ISMS_Id", MS."ISMS_SubjectName", MSG."EMPSG_Id", MSG."EMPSG_GroupName",
                SG."ESTMPPSG_GroupMaxMarks", SG."ESTMPPSG_GroupObtMarks", PS."EMPS_SubjOrder", PS."EMPS_AppToResultFlg",
                SG."ESTMPPSG_GroupObtGrade", MSG."EMPSG_Order" AS "grporder"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" 
                AND MSG."EMPSG_ActiveFlag" = TRUE
            INNER JOIN "IVRM_Master_Subjects" MS ON MS."ISMS_Id" = MPS."ISMS_Id"
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" PS ON PS."EMPS_Id" = MSG."EMPS_Id" 
                AND MS."ISMS_Id" = PS."ISMS_Id" AND PS."EMPS_ActiveFlag" = TRUE
            INNER JOIN "Exm"."Exm_M_Promotion" MP ON MP."EMP_Id" = PS."EMP_Id" 
                AND MP."EMP_ActiveFlag" = TRUE AND MP."EYC_Id" = "v_EYC_Id"
            WHERE MPS."ASMAY_Id" = "p_ASMAY_Id"::BIGINT AND MPS."MI_Id" = "p_MI_Id"::BIGINT 
                AND MPS."ASMCL_Id" = "p_ASMCL_Id"::BIGINT AND MPS."ASMS_Id" = "p_ASMS_Id"::BIGINT
            ORDER BY PS."EMPS_SubjOrder"

            UNION

            SELECT DISTINCT MPS."AMST_Id", MPS."ISMS_Id", MS."ISMS_SubjectName", 90001 AS "EMPSG_Id", 
                'Final Avg'::TEXT AS "EMPSG_GroupName", MPS."ESTMPPS_MaxMarks" AS "ESTMPPSG_GroupMaxMarks",
                MPS."ESTMPPS_ObtainedMarks" AS "ESTMPPSG_GroupObtMarks", PS."EMPS_SubjOrder", PS."EMPS_AppToResultFlg",
                MPS."ESTMPPS_ObtainedGrade" AS "ESTMPPSG_GroupObtGrade", 1001 AS "grporder"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" 
                AND MSG."EMPSG_ActiveFlag" = TRUE
            INNER JOIN "IVRM_Master_Subjects" MS ON MS."ISMS_Id" = MPS."ISMS_Id"
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" PS ON PS."EMPS_Id" = MSG."EMPS_Id" 
                AND MS."ISMS_Id" = PS."ISMS_Id" AND PS."EMPS_ActiveFlag" = TRUE
            INNER JOIN "Exm"."Exm_M_Promotion" MP ON MP."EMP_Id" = PS."EMP_Id" 
                AND MP."EMP_ActiveFlag" = TRUE AND MP."EYC_Id" = "v_EYC_Id"
            WHERE MPS."ASMAY_Id" = "p_ASMAY_Id"::BIGINT AND MPS."MI_Id" = "p_MI_Id"::BIGINT 
                AND MPS."ASMCL_Id" = "p_ASMCL_Id"::BIGINT AND MPS."ASMS_Id" = "p_ASMS_Id"::BIGINT
            ORDER BY PS."EMPS_SubjOrder"
        ) AS t
        ORDER BY "EMPS_SubjOrder", "grporder";

        ALTER TABLE "Malda_Temp_Term_Report_IX_Details" 
        ADD COLUMN "GroupClassHighest" DECIMAL(18,2),
        ADD COLUMN "GroupSectionHighest" DECIMAL(18,2),
        ADD COLUMN "PER" DECIMAL(18,2),
        ADD COLUMN "GroupClassMaxHighest" DECIMAL(18,2),
        ADD COLUMN "GroupSectionMaxHighest" DECIMAL(18,2),
        ADD COLUMN "GroupClassMaxPer" DECIMAL(18,2),
        ADD COLUMN "GroupSectionMaxPer" DECIMAL(18,2),
        ADD COLUMN "GroupClassMaxGrade" TEXT,
        ADD COLUMN "GroupSectionMaxGrade" TEXT;

        CREATE TEMP TABLE "groupSectionHighest_Temp" AS
        SELECT DISTINCT PS."ASMCL_Id", PS."ASMS_Id", PS."ISMS_Id", PSG."EMPSG_Id",
            MAX(PSG."ESTMPPSG_GroupObtMarks") AS "GroupSectionObtMarks",
            MAX(PSG."ESTMPPSG_GroupMaxMarks") AS "GroupSectionMaxMarks",
            ROUND(CAST((MAX(PSG."ESTMPPSG_GroupObtMarks") * 100 / MAX(PSG."ESTMPPSG_GroupMaxMarks")) AS DECIMAL(18,2)), 2) AS "GroupSectionPer",
            CASE 
                WHEN "v_EMGR_FLAG" = 'M' THEN 
                    (SELECT "EMGD_Name" FROM "Exm"."Exm_Master_Grade_Details" 
                     WHERE MAX(PSG."ESTMPPSG_GroupObtMarks") BETWEEN "EMGD_From" AND "EMGD_To" 
                     AND "EMGR_Id" = "v_EMGR_Id" AND "EMGD_ActiveFlag" = TRUE LIMIT 1)
                ELSE 
                    (SELECT "EMGD_Name" FROM "Exm"."Exm_Master_Grade_Details" 
                     WHERE ROUND(CAST((MAX(PSG."ESTMPPSG_GroupObtMarks") * 100 / MAX(PSG."ESTMPPSG_GroupMaxMarks")) AS DECIMAL(18,2)), 2) 
                     BETWEEN "EMGD_From" AND "EMGD_To" 
                     AND "EMGR_Id" = "v_EMGR_Id" AND "EMGD_ActiveFlag" = TRUE LIMIT 1)
            END AS "EMGD_Name_SectionMax"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" PS
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" PSG ON PS."ESTMPPS_Id" = PSG."ESTMPPS_Id"
        WHERE PS."MI_Id" = "p_MI_Id"::BIGINT AND PS."asmay_id" = "p_ASMAY_Id"::BIGINT 
            AND PS."ASMCL_Id" = "p_ASMCL_Id"::BIGINT AND PS."ASMS_Id" = "p_ASMS_Id"::BIGINT
        GROUP BY PS."ASMCL_Id", PS."ASMS_Id", PS."