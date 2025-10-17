CREATE OR REPLACE FUNCTION "dbo"."Exm_Multiple_Exam_Cumulative_Report_SMS"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_EMGR_Id" TEXT,
    "p_EME_Id" TEXT,
    "p_FLAG" TEXT
)
RETURNS TABLE(
    "AMST_ID" BIGINT,
    "AMST_Firstname" TEXT,
    "AMST_AdmNo" TEXT,
    "ISMS_Id" BIGINT,
    "SMS" TEXT,
    "AMST_MobileNo" TEXT,
    "AMST_emailId" TEXT,
    "Percentage" NUMERIC(18,2),
    "SMS_Marks" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_STUDENTNAME" TEXT;
    "v_AMST_Id_New" BIGINT;
    "v_AMST_AdmNo" TEXT;
    "v_AMST_RegistrationNo" TEXT;
    "v_AMAY_RollNo" TEXT;
    "v_ASMAY_Year" TEXT;
    "v_ASMCL_ClassName" TEXT;
    "v_ASMC_SectionName" TEXT;
    "v_ASMCL_Id_New" BIGINT;
    "v_ASMS_Id_New" BIGINT;
    "v_ASMAY_Id_New" BIGINT;
    "v_ISMS_Id" BIGINT;
    "v_ISMS_SubjectName" TEXT;
    "v_EYCES_SubjectOrder" TEXT;
    "v_EYCES_AplResultFlg" INTEGER;
    "v_EYCES_MaxMarks" NUMERIC(18,2);
    "v_SUBJECT_PERCENTAGE" NUMERIC(18,2);
    "v_MARKS_OBTAINED" NUMERIC(18,2);
    "v_MAX_MARKS" NUMERIC(18,2);
    "v_EMGR_GRADENAME" TEXT;
    "v_FINAL_PERCENTAGE" NUMERIC(18,2);
    "v_FINAL_MARKS_OBTAINED" NUMERIC(18,2);
    "v_FINAL_MAX_MARKS" NUMERIC(18,2);
    "v_FINAL_GRADENAME" TEXT;
    "v_SQLQUERY" TEXT;
    "student_rec" RECORD;
    "subject_rec" RECORD;
BEGIN

    IF "p_FLAG" = '1' THEN
    
        DROP TABLE IF EXISTS "STUDENTMARKSLIST";
        DROP TABLE IF EXISTS "STUDENT_MULTIPLE_EXAM_WISE_CUMULATIVE_REPORT";
        
        CREATE TEMP TABLE "STUDENT_MULTIPLE_EXAM_WISE_CUMULATIVE_REPORT" (
            "AMST_Id" BIGINT,
            "STUDENTNAME" TEXT,
            "ADMNO" TEXT,
            "REGNO" TEXT,
            "CLASSNAME" TEXT,
            "SECTIONNAME" TEXT,
            "YEARNAME" TEXT,
            "ROLLNO" TEXT,
            "ISMS_Id" BIGINT,
            "SUBJECTNAME" TEXT,
            "MARKSOBTAINED" NUMERIC(18,2),
            "MAXMARKS" NUMERIC(18,2),
            "PERCENTAGE" NUMERIC(18,2),
            "GRADE" TEXT,
            "ASMCL_Id" BIGINT,
            "ASMS_Id" BIGINT,
            "ASMAY_Id" BIGINT
        );
        
        FOR "student_rec" IN
            SELECT DISTINCT A."AMST_Id",
                (COALESCE(B."AMST_FirstName", '') || ' ' || COALESCE(B."AMST_MiddleName", '') || ' ' || COALESCE(B."AMST_LastName", '')) AS "STUDENTNAME",
                C."ASMAY_Year",
                D."ASMCL_ClassName",
                E."ASMC_SectionName",
                B."AMST_AdmNo",
                B."AMST_RegistrationNo",
                A."AMAY_RollNo",
                A."ASMCL_Id",
                A."ASMS_Id",
                A."ASMAY_Id"
            FROM "Adm_School_Y_Student" A
            INNER JOIN "Adm_M_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = A."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = A."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = A."ASMS_Id"
            WHERE A."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                AND A."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
                AND A."ASMS_Id" = "p_ASMS_Id"::BIGINT
                AND B."MI_Id" = "p_MI_Id"::BIGINT
        LOOP
            "v_AMST_Id_New" := "student_rec"."AMST_Id";
            "v_STUDENTNAME" := "student_rec"."STUDENTNAME";
            "v_ASMAY_Year" := "student_rec"."ASMAY_Year";
            "v_ASMCL_ClassName" := "student_rec"."ASMCL_ClassName";
            "v_ASMC_SectionName" := "student_rec"."ASMC_SectionName";
            "v_AMST_AdmNo" := "student_rec"."AMST_AdmNo";
            "v_AMST_RegistrationNo" := "student_rec"."AMST_RegistrationNo";
            "v_AMAY_RollNo" := "student_rec"."AMAY_RollNo";
            "v_ASMCL_Id_New" := "student_rec"."ASMCL_Id";
            "v_ASMS_Id_New" := "student_rec"."ASMS_Id";
            "v_ASMAY_Id_New" := "student_rec"."ASMAY_Id";
            
            FOR "subject_rec" IN
                SELECT DISTINCT B."ISMS_Id",
                    B."ISMS_SubjectName",
                    0 AS "EYCES_SubjectOrder",
                    M."EYCES_AplResultFlg"
                FROM "EXM"."Exm_Studentwise_Subjects" A
                INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
                INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
                INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
                INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
                INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
                INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id"
                    AND H."ASMCL_Id" = F."ASMCL_Id"
                    AND H."ASMS_Id" = G."ASMS_Id"
                    AND H."ECAC_ActiveFlag" = 1
                    AND H."ASMCL_Id" = "v_ASMCL_Id_New"
                    AND H."ASMAY_Id" = "v_ASMAY_Id_New"
                    AND H."ASMS_Id" = "v_ASMS_Id_New"
                INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
                INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id"
                    AND J."EMCA_Id" = I."EMCA_Id"
                    AND J."ASMAY_Id" = "v_ASMAY_Id_New"
                INNER JOIN "EXM"."Exm_Yearly_Category_Exams" K ON K."EYC_Id" = J."EYC_Id" AND K."EYCE_ActiveFlg" = 1
                INNER JOIN "EXM"."Exm_Master_Exam" L ON L."EME_Id" = K."EME_Id"
                INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id" = K."EYCE_Id"
                    AND M."ISMS_Id" = B."ISMS_Id"
                    AND M."EYCES_ActiveFlg" = 1
                WHERE A."AMST_Id" = "v_AMST_Id_New"
                    AND C."AMST_Id" = "v_AMST_Id_New"
                    AND C."ASMAY_Id" = "v_ASMAY_Id_New"
                    AND A."ASMAY_Id" = "v_ASMAY_Id_New"
                    AND A."ASMCL_Id" = "v_ASMCL_Id_New"
                    AND C."ASMCL_Id" = "v_ASMCL_Id_New"
                    AND A."ASMS_Id" = "v_ASMS_Id_New"
                    AND C."ASMS_Id" = "v_ASMS_Id_New"
                    AND A."ESTSU_ActiveFlg" = 1
                    AND B."ISMS_ActiveFlag" = 1
                    AND M."EYCES_AplResultFlg" = 1
            LOOP
                "v_ISMS_Id" := "subject_rec"."ISMS_Id";
                "v_ISMS_SubjectName" := "subject_rec"."ISMS_SubjectName";
                "v_EYCES_SubjectOrder" := "subject_rec"."EYCES_SubjectOrder"::TEXT;
                "v_EYCES_AplResultFlg" := "subject_rec"."EYCES_AplResultFlg";
                
                DROP TABLE IF EXISTS "STUDENTMARKSLIST";
                
                "v_SQLQUERY" := 'CREATE TEMP TABLE "STUDENTMARKSLIST" AS ' ||
                    'SELECT SUM("ESTMPS_ObtainedMarks") AS "MARKSOBTAINED", ' ||
                    'SUM("ESTMPS_MaxMarks") AS "MAXMARKS", ' ||
                    '"AMST_Id", "ISMS_Id" ' ||
                    'FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" ' ||
                    'WHERE "AMST_Id" = ' || "v_AMST_Id_New"::TEXT ||
                    ' AND "ASMAY_Id" = ' || "v_ASMAY_Id_New"::TEXT ||
                    ' AND "ASMCL_Id" = ' || "v_ASMCL_Id_New"::TEXT ||
                    ' AND "ASMS_Id" = ' || "v_ASMS_Id_New"::TEXT ||
                    ' AND "ISMS_Id" = ' || "v_ISMS_Id"::TEXT ||
                    ' AND "MI_Id" = ' || "p_MI_Id"::TEXT ||
                    ' AND "EME_Id" IN (' || "p_EME_Id" || ') ' ||
                    'GROUP BY "AMST_Id", "ISMS_Id"';
                
                EXECUTE "v_SQLQUERY";
                
                "v_SUBJECT_PERCENTAGE" := 0;
                "v_MARKS_OBTAINED" := 0;
                "v_MAX_MARKS" := 0;
                
                SELECT "MARKSOBTAINED", "MAXMARKS"
                INTO "v_MARKS_OBTAINED", "v_MAX_MARKS"
                FROM "STUDENTMARKSLIST"
                WHERE "AMST_Id" = "v_AMST_Id_New" AND "ISMS_Id" = "v_ISMS_Id";
                
                IF "v_MAX_MARKS" IS NOT NULL AND "v_MAX_MARKS" != 0 THEN
                    "v_SUBJECT_PERCENTAGE" := ROUND(("v_MARKS_OBTAINED" * 100 / NULLIF("v_MAX_MARKS", 0))::NUMERIC, 2);
                END IF;
                
                "v_EMGR_GRADENAME" := '';
                
                SELECT "EMGD_Name"
                INTO "v_EMGR_GRADENAME"
                FROM "Exm"."Exm_Master_Grade_Details" A
                INNER JOIN "Exm"."Exm_Master_Grade" B ON A."EMGR_Id" = B."EMGR_Id"
                WHERE A."EMGR_Id" = "p_EMGR_Id"::BIGINT
                    AND B."MI_Id" = "p_MI_Id"::BIGINT
                    AND ("v_SUBJECT_PERCENTAGE" BETWEEN A."EMGD_From" AND A."EMGD_To");
                
                INSERT INTO "STUDENT_MULTIPLE_EXAM_WISE_CUMULATIVE_REPORT" (
                    "AMST_Id", "STUDENTNAME", "ADMNO", "REGNO", "CLASSNAME", "SECTIONNAME",
                    "YEARNAME", "ROLLNO", "ISMS_Id", "SUBJECTNAME", "MARKSOBTAINED",
                    "MAXMARKS", "PERCENTAGE", "GRADE", "ASMCL_Id", "ASMS_Id", "ASMAY_Id"
                ) VALUES (
                    "v_AMST_Id_New", "v_STUDENTNAME", "v_AMST_AdmNo", "v_AMST_RegistrationNo",
                    "v_ASMCL_ClassName", "v_ASMC_SectionName", "v_ASMAY_Year", "v_AMAY_RollNo",
                    "v_ISMS_Id", "v_ISMS_SubjectName", "v_MARKS_OBTAINED", "v_MAX_MARKS",
                    "v_SUBJECT_PERCENTAGE", "v_EMGR_GRADENAME", "v_ASMCL_Id_New",
                    "v_ASMS_Id_New", "v_ASMAY_Id_New"
                );
                
            END LOOP;
            
            "v_FINAL_PERCENTAGE" := 0;
            "v_FINAL_MARKS_OBTAINED" := 0;
            "v_FINAL_MAX_MARKS" := 0;
            
            SELECT SUM("MARKSOBTAINED"), SUM("MAXMARKS")
            INTO "v_FINAL_MARKS_OBTAINED", "v_FINAL_MAX_MARKS"
            FROM "STUDENT_MULTIPLE_EXAM_WISE_CUMULATIVE_REPORT"
            WHERE "AMST_Id" = "v_AMST_Id_New";
            
            IF "v_FINAL_MAX_MARKS" IS NOT NULL AND "v_FINAL_MAX_MARKS" != 0 THEN
                "v_FINAL_PERCENTAGE" := ROUND(("v_FINAL_MARKS_OBTAINED" * 100 / NULLIF("v_FINAL_MAX_MARKS", 0))::NUMERIC, 2);
            END IF;
            
            "v_FINAL_GRADENAME" := '';
            
            SELECT "EMGD_Name"
            INTO "v_FINAL_GRADENAME"
            FROM "Exm"."Exm_Master_Grade_Details" A
            INNER JOIN "Exm"."Exm_Master_Grade" B ON A."EMGR_Id" = B."EMGR_Id"
            WHERE A."EMGR_Id" = "p_EMGR_Id"::BIGINT
                AND B."MI_Id" = "p_MI_Id"::BIGINT
                AND ("v_FINAL_PERCENTAGE" BETWEEN A."EMGD_From" AND A."EMGD_To");
            
            INSERT INTO "STUDENT_MULTIPLE_EXAM_WISE_CUMULATIVE_REPORT" (
                "AMST_Id", "STUDENTNAME", "ADMNO", "REGNO", "CLASSNAME", "SECTIONNAME",
                "YEARNAME", "ROLLNO", "ISMS_Id", "SUBJECTNAME", "MARKSOBTAINED",
                "MAXMARKS", "PERCENTAGE", "GRADE", "ASMCL_Id", "ASMS_Id", "ASMAY_Id"
            ) VALUES (
                "v_AMST_Id_New", "v_STUDENTNAME", "v_AMST_AdmNo", "v_AMST_RegistrationNo",
                "v_ASMCL_ClassName", "v_ASMC_SectionName", "v_ASMAY_Year", "v_AMAY_RollNo",
                1000000, 'TotalFinalMarks', "v_FINAL_MARKS_OBTAINED", "v_FINAL_MAX_MARKS",
                "v_FINAL_PERCENTAGE", "v_FINAL_GRADENAME", "v_ASMCL_Id_New",
                "v_ASMS_Id_New", "v_ASMAY_Id_New"
            );
            
            INSERT INTO "STUDENT_MULTIPLE_EXAM_WISE_CUMULATIVE_REPORT" (
                "AMST_Id", "STUDENTNAME", "ADMNO", "REGNO", "CLASSNAME", "SECTIONNAME",
                "YEARNAME", "ROLLNO", "ISMS_Id", "SUBJECTNAME", "MARKSOBTAINED",
                "MAXMARKS", "PERCENTAGE", "GRADE", "ASMCL_Id", "ASMS_Id", "ASMAY_Id"
            ) VALUES (
                "v_AMST_Id_New", "v_STUDENTNAME", "v_AMST_AdmNo", "v_AMST_RegistrationNo",
                "v_ASMCL_ClassName", "v_ASMC_SectionName", "v_ASMAY_Year", "v_AMAY_RollNo",
                10000001, 'TotalGrade', "v_FINAL_MARKS_OBTAINED", "v_FINAL_MAX_MARKS",
                "v_FINAL_PERCENTAGE", "v_FINAL_GRADENAME", "v_ASMCL_Id_New",
                "v_ASMS_Id_New", "v_ASMAY_Id_New"
            );
            
        END LOOP;
        
        RETURN QUERY
        SELECT 
            a."AMST_Id" AS "AMST_ID",
            a."STUDENTNAME" AS "AMST_Firstname",
            a."ADMNO" AS "AMST_AdmNo",
            a."ISMS_Id",
            CONCAT(a."SUBJECTNAME", ':', a."GRADE") AS "SMS",
            b."AMST_MobileNo",
            b."AMST_emailId",
            a."PERCENTAGE" AS "Percentage",
            CONCAT(a."SUBJECTNAME", ':', a."MARKSOBTAINED", '/', a."MAXMARKS") AS "SMS_Marks"
        FROM "STUDENT_MULTIPLE_EXAM_WISE_CUMULATIVE_REPORT" a
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
        WHERE a."ISMS_Id" != 1000000
        ORDER BY a."STUDENTNAME";
        
    ELSIF "p_FLAG" = '2' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            E."ISMS_Id",
            F."ISMS_SubjectName"::TEXT AS "AMST_Firstname",
            NULL::TEXT AS "AMST_AdmNo",
            NULL::BIGINT,
            NULL::TEXT AS "SMS",
            NULL::TEXT AS "AMST_MobileNo",
            NULL::TEXT AS "AMST_emailId",
            f."ISMS_OrderFlag"::NUMERIC(18,2) AS "Percentage",
            NULL::TEXT AS "SMS_Marks"
        FROM "Exm"."Exm_Category_Class" A
        INNER JOIN "Exm"."Exm_Master_Category" B ON A."EMCA_Id" = B."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" C ON C."EMCA_Id" = B."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" D ON D."EYC_Id" = C."EYC_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" E ON E."EYCE_Id" = D."EYCE_Id"
        INNER JOIN "IVRM_Master_Subjects" F ON F."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Studentwise_Subjects" G ON G."ISMS_Id" = F."ISMS_Id"
            AND G."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND G."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
            AND G."ASMS_Id" = "p_ASMS_Id"::BIGINT
        WHERE A."MI_Id" = "p_MI_Id"::BIGINT
            AND A."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND A."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
            AND A."ASMS_Id" = "p_ASMS_Id"::BIGINT
            AND C."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND C."EYC_ActiveFlg" = 1
            AND A."ECAC_ActiveFlag" = 1
            AND D."EYCE_ActiveFlg" = 1
            AND E."EYCES_ActiveFlg" = 1
            AND E."EYCES_AplResultFlg" = 1
        ORDER BY f."ISMS_OrderFlag";
        
    END IF;
    
END;
$$;