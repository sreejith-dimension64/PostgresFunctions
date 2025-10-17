CREATE OR REPLACE FUNCTION "dbo"."Exam_Subject_Subsubject_Subexam_Report"(
    "@MI_Id" TEXT, 
    "@ASMAY_Id" TEXT, 
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT, 
    "@EME_Id" TEXT,
    "@Flag" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "AMST_AdmNo" TEXT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "ESTMPS_MaxMarks" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_ObtainedGrade" TEXT,
    "EMSE_SubExamName" TEXT,
    "EMSS_SubSubjectName" TEXT,
    "subsubjectmarks" NUMERIC,
    "subsubjectgrade" TEXT,
    "gradedisplay" BOOLEAN,
    "marksdisplay" BOOLEAN,
    "ISMS_OrderFlag" INTEGER,
    "EMSE_SubExamOrder" INTEGER,
    "EMSS_Order" INTEGER,
    "passfailflag" TEXT,
    "EYCES_SubExamFlg" BOOLEAN,
    "EYCES_SubSubjectFlg" BOOLEAN,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_GradeDisplayFlg" BOOLEAN,
    "EYCES_MarksDisplayFlg" BOOLEAN,
    "EYCESSS_GradesFlg" BOOLEAN,
    "EYCESSS_MarksFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ISMS_Id_NEW" BIGINT;
    "v_EYCES_SubExamFlg_NEW" BOOLEAN;
    "v_EYCES_SubSubjectFlg_NEW" BOOLEAN;
    "v_EMCA_Id" BIGINT;
    "v_EYC_Id" BIGINT;
    "v_SubExamFlg" BOOLEAN;
    "v_SubSubjectFlg" BOOLEAN;
    "v_ISMS_Id" INTEGER;
    "v_ISMS_SubjectName" TEXT;
    "v_EYCES_SubjectOrder" INTEGER;
    "v_EYCES_GRADEDISPLAYFLG" BOOLEAN;
    "v_EYCES_MARKSDISPLAYFLG" BOOLEAN;
    "v_EYCES_SubExamFlg" BOOLEAN;
    "v_EYCES_SubSubjectFlg" BOOLEAN;
    "v_EMSE_SubExamName" TEXT;
    "v_EMSS_SubSubjectName" TEXT;
    "v_EMSE_SubExamOrder" INTEGER;
    "v_EMSS_ORDER" INTEGER;
    "v_EYCESSS_GradesFlg" BOOLEAN;
    "v_EYCESSS_MarksFlg" BOOLEAN;
BEGIN

    IF "@Flag" = '1' THEN
    
        DROP TABLE IF EXISTS "TEMP_STUDENTWISE_SUBJECTLIST_MARKS";
        
        CREATE TEMP TABLE "TEMP_STUDENTWISE_SUBJECTLIST_MARKS" AS
        SELECT 
            "AMST_Id", 
            "studentname",
            "AMST_AdmNo",
            "ISMS_Id", 
            "ISMS_SubjectName", 
            "ESTMPS_MaxMarks", 
            "ESTMPS_ObtainedMarks", 
            "ESTMPS_ObtainedGrade", 
            "EMSE_SubExamName",
            "EMSS_SubSubjectName",
            "subsubjectmarks",
            "subsubjectgrade",
            "gradedisplay",
            "marksdisplay",
            "ISMS_OrderFlag", 
            "EMSE_SubExamOrder", 
            "EMSS_Order",
            "passfailflag",
            "EYCES_SubExamFlg",
            "EYCES_SubSubjectFlg"
        FROM (
            SELECT DISTINCT 
                a."AMST_Id", 
                (COALESCE("AMST_FirstName",'') || ' ' || COALESCE("AMST_MiddleName",'') || ' ' || COALESCE("AMST_LastName",'')) AS "studentname",
                "AMST_AdmNo", 
                p."ISMS_Id",
                "ISMS_SubjectName", 
                "ESTMPS_MaxMarks", 
                "ESTMPS_ObtainedMarks", 
                "ESTMPS_ObtainedGrade", 
                COALESCE(j."EMSE_SubExamName",'') AS "EMSE_SubExamName",
                COALESCE(k."EMSS_SubSubjectName",'') AS "EMSS_SubSubjectName",
                i."ESTMPSSS_ObtainedMarks" AS "subsubjectmarks",
                i."ESTMPSSS_ObtainedGrade" AS "subsubjectgrade",
                "EYCES_GradeDisplayFlg" AS "gradedisplay",
                "EYCES_MarksDisplayFlg" AS "marksdisplay",
                "ISMS_OrderFlag", 
                "EMSE_SubExamOrder", 
                "EMSS_Order",
                i."ESTMPSSS_PassFailFlg" AS "passfailflag",
                p."EYCES_SubExamFlg",
                p."EYCES_SubSubjectFlg"
            FROM "Adm_School_Y_Student" a 
            INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
            INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "exm"."Exm_Studentwise_Subjects" f ON c."ASMCL_Id" = f."ASMCL_Id" AND d."ASMS_Id" = f."ASMS_Id" AND e."ASMAY_Id" = f."ASMAY_Id" AND f."AMST_Id" = a."AMST_Id"
            INNER JOIN "exm"."Exm_Student_Marks_Process" g ON c."ASMCL_Id" = g."ASMCL_Id" AND d."ASMS_Id" = g."ASMS_Id" AND e."ASMAY_Id" = g."ASMAY_Id" AND g."AMST_Id" = a."AMST_Id"
            INNER JOIN "exm"."Exm_Student_Marks_Process_Subjectwise" h ON c."ASMCL_Id" = h."ASMCL_Id" AND d."ASMS_Id" = h."ASMS_Id" AND e."ASMAY_Id" = h."ASMAY_Id" AND h."AMST_Id" = a."AMST_Id"
            LEFT JOIN "exm"."Exm_Student_Marks_Pro_Sub_SubSubject" i ON i."ESTMPS_Id" = h."ESTMPS_Id"
            LEFT JOIN "exm"."Exm_Master_SubExam" j ON j."EMSE_Id" = i."EMSE_Id"
            LEFT JOIN "exm"."Exm_Master_SubSubject" k ON k."EMSS_Id" = i."EMSS_Id"
            INNER JOIN "IVRM_Master_Subjects" l ON l."ISMS_Id" = h."ISMS_Id" AND f."ISMS_Id" = l."ISMS_Id"
            INNER JOIN "exm"."Exm_Master_Exam" m ON m."EME_Id" = h."EME_Id" AND m."EME_Id" = g."EME_Id"
            INNER JOIN "exm"."Exm_Yearly_Category" n ON n."ASMAY_Id" = e."ASMAY_Id" AND n."ASMAY_Id"::TEXT = "@ASMAY_Id"
            INNER JOIN "exm"."Exm_Master_Category" n1 ON n1."EMCA_Id" = n."EMCA_Id"
            INNER JOIN "exm"."Exm_Category_Class" n2 ON n2."EMCA_Id" = n1."EMCA_Id" AND n2."ASMAY_Id"::TEXT = "@ASMAY_Id" AND n2."ASMCL_Id"::TEXT = "@ASMCL_Id" 
                AND n2."ASMS_Id"::TEXT = "@ASMS_Id" AND n2."ECAC_ActiveFlag" = TRUE
            INNER JOIN "exm"."Exm_Yearly_Category_Exams" o ON o."EYC_Id" = n."EYC_Id" AND m."EME_Id" = o."EME_Id" AND o."EME_Id"::TEXT = "@EME_Id" 
                AND o."EYCE_ActiveFlg" = TRUE
            INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" p ON p."EYCE_Id" = o."EYCE_Id" AND p."ISMS_Id" = l."ISMS_Id" AND p."EYCES_ActiveFlg" = TRUE
            LEFT JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" r ON r."EYCES_Id" = p."EYCES_Id" AND r."EYCESSS_ActiveFlg" = TRUE 
                AND (j."EMSE_Id" = r."EMSE_Id" OR k."EMSS_Id" = r."EMSS_Id")
            WHERE a."ASMAY_Id"::TEXT = "@ASMAY_Id" AND a."ASMCL_Id"::TEXT = "@ASMCL_Id" AND a."ASMS_Id"::TEXT = "@ASMS_Id" 
                AND f."ASMAY_Id"::TEXT = "@ASMAY_Id" AND f."ASMCL_Id"::TEXT = "@ASMCL_Id" AND f."ASMS_Id"::TEXT = "@ASMS_Id"
                AND h."ASMAY_Id"::TEXT = "@ASMAY_Id" AND h."ASMCL_Id"::TEXT = "@ASMCL_Id" AND h."ASMS_Id"::TEXT = "@ASMS_Id" 
                AND g."ASMAY_Id"::TEXT = "@ASMAY_Id" AND g."ASMCL_Id"::TEXT = "@ASMCL_Id" AND g."ASMS_Id"::TEXT = "@ASMS_Id"
                AND h."EME_Id"::TEXT = "@EME_Id" AND g."EME_Id"::TEXT = "@EME_Id"
                AND p."EYCES_ActiveFlg" = TRUE AND (p."EYCES_SubExamFlg" = TRUE OR p."EYCES_SubSubjectFlg" = TRUE)
                
            UNION
            
            SELECT DISTINCT 
                a."AMST_Id", 
                (COALESCE("AMST_FirstName",'') || ' ' || COALESCE("AMST_MiddleName",'') || ' ' || COALESCE("AMST_LastName",'')) AS "studentname",
                "AMST_AdmNo", 
                p."ISMS_Id",
                "ISMS_SubjectName", 
                "ESTMPS_MaxMarks", 
                "ESTMPS_ObtainedMarks", 
                "ESTMPS_ObtainedGrade",
                '' AS "EMSE_SubExamName",
                '' AS "EMSS_SubSubjectName",
                "ESTMPS_ObtainedMarks" AS "subsubjectmarks",
                "ESTMPS_ObtainedGrade" AS "subsubjectgrade",
                "EYCES_GradeDisplayFlg" AS "gradedisplay",
                "EYCES_MarksDisplayFlg" AS "marksdisplay",
                "ISMS_OrderFlag", 
                1000 AS "EMSE_SubExamOrder", 
                1000 AS "EMSS_Order",
                "ESTMPS_PassFailFlg" AS "passfailflag",
                p."EYCES_SubExamFlg",
                p."EYCES_SubSubjectFlg"
            FROM "Adm_School_Y_Student" a 
            INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
            INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "exm"."Exm_Studentwise_Subjects" f ON c."ASMCL_Id" = f."ASMCL_Id" AND d."ASMS_Id" = f."ASMS_Id" AND e."ASMAY_Id" = f."ASMAY_Id" 
                AND f."AMST_Id" = a."AMST_Id"
            INNER JOIN "exm"."Exm_Student_Marks_Process" g ON c."ASMCL_Id" = g."ASMCL_Id" AND d."ASMS_Id" = g."ASMS_Id" AND e."ASMAY_Id" = g."ASMAY_Id" 
                AND g."AMST_Id" = a."AMST_Id"
            INNER JOIN "exm"."Exm_Student_Marks_Process_Subjectwise" h ON c."ASMCL_Id" = h."ASMCL_Id" AND d."ASMS_Id" = h."ASMS_Id" 
                AND e."ASMAY_Id" = h."ASMAY_Id" AND h."AMST_Id" = a."AMST_Id"
            INNER JOIN "IVRM_Master_Subjects" l ON l."ISMS_Id" = h."ISMS_Id" AND f."ISMS_Id" = l."ISMS_Id"
            INNER JOIN "exm"."Exm_Master_Exam" m ON m."EME_Id" = h."EME_Id" AND m."EME_Id" = g."EME_Id"
            INNER JOIN "exm"."Exm_Yearly_Category" n ON n."ASMAY_Id" = e."ASMAY_Id" AND n."ASMAY_Id"::TEXT = "@ASMAY_Id"
            INNER JOIN "exm"."Exm_Master_Category" n1 ON n1."EMCA_Id" = n."EMCA_Id"
            INNER JOIN "exm"."Exm_Category_Class" n2 ON n2."EMCA_Id" = n1."EMCA_Id" AND n2."ASMAY_Id"::TEXT = "@ASMAY_Id" AND n2."ASMCL_Id"::TEXT = "@ASMCL_Id" 
                AND n2."ASMS_Id"::TEXT = "@ASMS_Id" AND n2."ECAC_ActiveFlag" = TRUE
            INNER JOIN "exm"."Exm_Yearly_Category_Exams" o ON o."EYC_Id" = n."EYC_Id" AND m."EME_Id" = o."EME_Id" AND o."EME_Id"::TEXT = "@EME_Id" 
                AND o."EYCE_ActiveFlg" = TRUE
            INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" p ON p."EYCE_Id" = o."EYCE_Id" AND p."ISMS_Id" = l."ISMS_Id" AND p."EYCES_ActiveFlg" = TRUE
            WHERE a."ASMAY_Id"::TEXT = "@ASMAY_Id" AND a."ASMCL_Id"::TEXT = "@ASMCL_Id" AND a."ASMS_Id"::TEXT = "@ASMS_Id" 
                AND f."ASMAY_Id"::TEXT = "@ASMAY_Id" AND f."ASMCL_Id"::TEXT = "@ASMCL_Id" AND f."ASMS_Id"::TEXT = "@ASMS_Id"
                AND h."ASMAY_Id"::TEXT = "@ASMAY_Id" AND h."ASMCL_Id"::TEXT = "@ASMCL_Id" AND h."ASMS_Id"::TEXT = "@ASMS_Id" 
                AND g."ASMAY_Id"::TEXT = "@ASMAY_Id" AND g."ASMCL_Id"::TEXT = "@ASMCL_Id" AND g."ASMS_Id"::TEXT = "@ASMS_Id"
                AND h."EME_Id"::TEXT = "@EME_Id" AND g."EME_Id"::TEXT = "@EME_Id" AND p."EYCES_ActiveFlg" = TRUE
        ) n   
        ORDER BY "studentname", "ISMS_OrderFlag", "EMSE_SubExamOrder", "EMSS_Order";

        FOR "v_ISMS_Id_NEW", "v_EYCES_SubExamFlg_NEW", "v_EYCES_SubSubjectFlg_NEW" IN
            SELECT DISTINCT "ISMS_Id", "EYCES_SubExamFlg", "EYCES_SubSubjectFlg" 
            FROM "TEMP_STUDENTWISE_SUBJECTLIST_MARKS"
        LOOP
            IF "v_EYCES_SubExamFlg_NEW" = TRUE AND "v_EYCES_SubSubjectFlg_NEW" = TRUE THEN
                UPDATE "TEMP_STUDENTWISE_SUBJECTLIST_MARKS" 
                SET "EMSE_SubExamName" = 'Total' 
                WHERE "ISMS_Id" = "v_ISMS_Id_NEW" AND "EMSE_SubExamName" = '';
            ELSIF "v_EYCES_SubExamFlg_NEW" = TRUE AND "v_EYCES_SubSubjectFlg_NEW" = FALSE THEN
                UPDATE "TEMP_STUDENTWISE_SUBJECTLIST_MARKS" 
                SET "EMSE_SubExamName" = 'Total' 
                WHERE "ISMS_Id" = "v_ISMS_Id_NEW" AND "EMSE_SubExamName" = '';
            ELSIF "v_EYCES_SubExamFlg_NEW" = FALSE AND "v_EYCES_SubSubjectFlg_NEW" = TRUE THEN
                UPDATE "TEMP_STUDENTWISE_SUBJECTLIST_MARKS" 
                SET "EMSS_SubSubjectName" = 'Total' 
                WHERE "ISMS_Id" = "v_ISMS_Id_NEW" AND "EMSS_SubSubjectName" = '';
            ELSIF "v_EYCES_SubExamFlg_NEW" = FALSE AND "v_EYCES_SubSubjectFlg_NEW" = FALSE THEN
                UPDATE "TEMP_STUDENTWISE_SUBJECTLIST_MARKS" 
                SET "EMSS_SubSubjectName" = 'Total' 
                WHERE "ISMS_Id" = "v_ISMS_Id_NEW" AND "EMSS_SubSubjectName" = '';
            END IF;
        END LOOP;

        RETURN QUERY 
        SELECT 
            t."AMST_Id",
            t."studentname",
            t."AMST_AdmNo",
            t."ISMS_Id",
            t."ISMS_SubjectName",
            t."ESTMPS_MaxMarks",
            t."ESTMPS_ObtainedMarks",
            t."ESTMPS_ObtainedGrade",
            t."EMSE_SubExamName",
            t."EMSS_SubSubjectName",
            t."subsubjectmarks",
            t."subsubjectgrade",
            t."gradedisplay",
            t."marksdisplay",
            t."ISMS_OrderFlag",
            t."EMSE_SubExamOrder",
            t."EMSS_Order",
            t."passfailflag",
            t."EYCES_SubExamFlg",
            t."EYCES_SubSubjectFlg",
            NULL::INTEGER,
            NULL::BOOLEAN,
            NULL::BOOLEAN,
            NULL::BOOLEAN,
            NULL::BOOLEAN
        FROM "TEMP_STUDENTWISE_SUBJECTLIST_MARKS" t
        ORDER BY t."studentname", t."ISMS_OrderFlag", t."EMSE_SubExamOrder", t."EMSS_Order";

    ELSIF "@Flag" = '2' THEN
    
        RETURN QUERY
        SELECT 
            NULL::BIGINT,
            NULL::TEXT,
            NULL::TEXT,
            c."ISMS_Id",
            "ISMS_SubjectName",
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::TEXT,
            NULL::TEXT,
            NULL::TEXT,
            NULL::NUMERIC,
            NULL::TEXT,
            c."EYCES_GradeDisplayFlg",
            c."EYCES_MarksDisplayFlg",
            "ISMS_OrderFlag",
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::TEXT,
            NULL::BOOLEAN,
            NULL::BOOLEAN,
            NULL::INTEGER,
            NULL::BOOLEAN,
            NULL::BOOLEAN,
            NULL::BOOLEAN,
            NULL::BOOLEAN
        FROM "exm"."Exm_Yearly_Category" a 
        INNER JOIN "exm"."Exm_Yearly_Category_Exams" b ON a."EYC_Id" = b."EYC_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" c ON c."EYCE_Id" = b."EYCE_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "exm"."Exm_Category_Class" e ON e."EMCA_Id" = a."EMCA_Id"
        INNER JOIN "exm"."Exm_Studentwise_Subjects" f ON f."ASMAY_Id" = a."ASMAY_Id" AND f."ISMS_Id" = d."ISMS_Id"
        WHERE e."ASMAY_Id"::TEXT = "@ASMAY_Id" AND e."ASMCL_Id"::TEXT = "@ASMCL_Id" AND e."ASMS_Id"::TEXT = "@ASMS_Id" 
            AND b."EME_Id"::TEXT = "@EME_Id" AND e."ECAC_ActiveFlag" = TRUE
            AND d."ISMS_ActiveFlag" = TRUE AND c."EYCES_ActiveFlg" = TRUE AND a."EYC_ActiveFlg" = TRUE AND b."EYCE_ActiveFlg" = TRUE
            AND f."ASMAY_Id"::TEXT = "@ASMAY_Id" AND f."ASMCL_Id"::TEXT = "@ASMCL_Id" AND f."ASMS_Id"::TEXT = "@ASMS_Id" AND f."ESTSU_ActiveFlg" = TRUE
        ORDER BY "ISMS_OrderFlag";

    ELSIF "@Flag" = '3' THEN
    
        SELECT "EMCA_Id" INTO "v_EMCA_Id"
        FROM "exm"."Exm_Category_Class"  
        WHERE "MI_Id"::TEXT = "@MI_Id" AND "ASMAY_Id"::TEXT = "@ASMAY_Id" AND "ASMCL_Id"::TEXT = "@ASMCL_Id" 
            AND "ASMS_Id"::TEXT = "@ASMS_Id" AND "ECAC_ActiveFlag" = TRUE;
            
        SELECT "EYC_Id" INTO "v_EYC_Id"
        FROM "exm"."Exm_Yearly_Category" 
        WHERE "MI_Id"::TEXT = "@MI_Id" AND "ASMAY_Id"::TEXT = "@ASMAY_Id" AND "EMCA_Id" = "v_EMCA_Id" AND "EYC_ActiveFlg" = TRUE;
        
        SELECT "EYCE_SubExamFlg", "EYCE_SubSubjectFlg" INTO "v_SubExamFlg", "v_SubSubjectFlg"
        FROM "exm"."Exm_Yearly_Category_Exams" 
        WHERE "EYCE_ActiveFlg" = TRUE AND "EYC_Id" = "v_EYC_Id" AND "EME_Id"::TEXT = "@EME_Id";

        DROP TABLE IF EXISTS "TEMP_SUBSUBJECT_SUBEXAM_SUBJECTLIST";
        
        CREATE TEMP TABLE "TEMP_SUBSUBJECT_SUBEXAM_SUBJECTLIST" (
            "ISMS_Id" BIGINT, 
            "ISMS_SubjectName" TEXT, 
            "EYCES_SubjectOrder" INT, 
            "EMSE_SubExamName" TEXT, 
            "EMSS_SubSubjectName" TEXT, 
            "EMSE_SubExamOrder" INT,
            "EMSS_Order" INT,
            "EYCES_GradeDisplayFlg" BOOLEAN,
            "EYCES_MarksDisplayFlg" BOOLEAN
        );

        FOR "v_ISMS_Id", "v_ISMS_SubjectName", "v_EYCES_SubjectOrder", "v_EYCES_GRADEDISPLAYFLG", 
            "v_EYCES_MARKSDISPLAYFLG", "v_EYCES_SubExamFlg", "v_EYCES_SubSubjectFlg" IN
            SELECT DISTINCT 
                C."ISMS_Id", 
                "ISMS_SubjectName", 
                "EYCES_SubjectOrder", 
                C."EYCES_GradeDisplayFlg",
                C."EYCES_MarksDisplayFlg",
                C."EYCES_SubExamFlg",
                C."EYCES_SubSubjectFlg"
            FROM "exm"."Exm_Yearly_Category" A 
            INNER JOIN "exm"."Exm_Yearly_Category_Exams" B ON A."EYC_Id" = B."EYC_Id" AND A."ASMAY_Id"::TEXT = "@ASMAY_Id"
            INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" C ON C."EYCE_Id" = B."EYCE_Id" 
            INNER JOIN "IVRM_Master_Subjects" D ON D."ISMS_Id" = C."ISMS_Id"
            INNER JOIN "exm"."Exm_Category_Class" E ON E."EMCA_Id" = A."EMCA_Id"
            INNER JOIN "exm"."Exm_Master_Category" G ON G."EMCA_Id" = E."EMCA_Id" AND G."EMCA_ActiveFlag" = TRUE
            INNER JOIN "exm"."Exm_Studentwise_Subjects" F ON F."ASMAY_Id" = A."ASMAY_Id" AND F."ISMS_Id" = D."ISMS_Id"
            WHERE E."ASMAY_Id"::TEXT = "@ASMAY_Id" AND E."ASMCL_Id"::TEXT = "@ASMCL_Id" AND E."ASMS_Id"::TEXT = "@ASMS_Id" 
                AND B."EME_Id"::TEXT = "@EME_Id" AND E."ECAC_ActiveFlag" = TRUE
                AND D."ISMS_ActiveFlag" = TRUE AND C."EYCES_ActiveFlg" = TRUE AND A."EYC_ActiveFlg" = TRUE AND B."EYCE_ActiveFlg" = TRUE
                AND F."ASMAY_Id"::TEXT = "@ASMAY_Id" AND F."ASMCL_Id"::TEXT = "@ASMCL_Id" AND F."ASMS_Id"::TEXT = "@ASMS_Id" 
                AND F."ESTSU_ActiveFlg" = TRUE AND B."EYCE_ActiveFlg" = TRUE
                AND A."EYC_ActiveFlg" = TRUE AND C."EYCES_ActiveFlg" = TRUE 
            ORDER BY "EYCES_SubjectOrder"
        LOOP
            IF "v_EYCES_SubExamFlg" = TRUE OR "v_EYCES_SubSubjectFlg" = TRUE THEN
            
                FOR "v_EMSE_SubExamName", "v_EMSS_SubSubjectName", "v_EMSE_SubExamOrder", "v_EMSS_ORDER", 
                    "v_EYCESSS_GradesFlg", "v_EYCESSS_MarksFlg" IN
                    SELECT DISTINCT 
                        COALESCE(J."EMSE_SubExamName",'') AS "EMSE_SubExamName",
                        COALESCE(K."EMSS_SubSubjectName",'') AS "EMSS_SubSubjectName", 
                        COALESCE(J."EMSE_SubExamOrder",0) AS "EMSE_SubExamOrder", 
                        COALESCE(K."EMSS_Order",0) AS "EMSS_Order", 
                        G."EYCESSS_GradesFlg", 
                        G."EYCESSS_MarksFlg"
                    FROM "exm"."Exm_Yearly_Category" A 
                    INNER JOIN "exm"."Exm_Yearly_Category_Exams" B ON A."EYC_Id" = B."EYC_Id" AND A."ASMAY_Id"::TEXT = "@ASMAY_Id"
                    INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" C ON C."EYCE_Id" = B."EYCE_Id"
                    INNER JOIN "IVRM_Master_Subjects" D ON D."ISMS_Id" = C."ISMS_Id"
                    INNER JOIN "exm"."Exm_Category_Class" E ON E."EMCA_Id" = A."EMCA_Id"
                    INNER JOIN "exm"."Exm_Studentwise_Subjects" F ON F."ASMAY_Id" = A."ASMAY_Id" AND F."ISMS_Id" = D."ISMS_I