CREATE OR REPLACE FUNCTION "dbo"."Exam_Student_SubjectWise_Marks_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_EME_Id TEXT,
    p_FLAG TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "TotalMaxMarks" DECIMAL(18,2),
    "TotalObtMarks" DECIMAL(18,2),
    "FinalTotMarksPer" DECIMAL(18,2),
    "ObtainedGrade" VARCHAR(50),
    "ObtainedGradeRemarks" TEXT,
    "Classheld" DECIMAL(18,2),
    "Class_Attended" DECIMAL(18,2),
    "classteachername" TEXT,
    "TotalSubMaxMarks" DECIMAL(18,2),
    "TotalSubObtMarks" DECIMAL(18,2),
    "FinalTotSubMarksPer" DECIMAL(18,2),
    "ObtainedGradeSub" VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Dynamic TEXT;
    v_AMST_Id BIGINT;
    v_EMGR_Id BIGINT;
    v_ISMS_Id BIGINT;
    v_TotalMaxMarks DECIMAL(18,2);
    v_TotalObtMarks DECIMAL(18,2);
    v_FinalTotMarks DECIMAL(18,2);
    v_FinalTotMarksPer DECIMAL(18,2);
    v_ObtainedGrade VARCHAR(50);
    v_ObtainedGradeRemarks TEXT;
    v_EME_IdG INT;
    v_AttendanceFromDate DATE;
    v_AttendanceToDate DATE;
    v_classheld DECIMAL(18,2);
    v_Class_Attended DECIMAL(18,2);
    v_Dynamic1 TEXT;
    v_classteacher TEXT;
    rec_student RECORD;
    rec_student_indi RECORD;
BEGIN

    DROP TABLE IF EXISTS "Exam_ReportTemp";

    v_Dynamic1 := 'CREATE TEMP TABLE "Exam_ReportTemp" AS 
    SELECT "EME_Id" FROM "Exm"."Exm_Master_Exam" 
    WHERE "MI_Id" = ' || p_MI_Id || ' AND "EME_ActiveFlag" = true AND "EME_Id" IN(' || p_EME_Id || ') 
    ORDER BY "EME_ExamOrder" DESC LIMIT 1';

    EXECUTE v_Dynamic1;

    SELECT "EME_Id" INTO v_EME_IdG FROM "Exam_ReportTemp";

    IF p_FLAG = '1' THEN
    
        DROP TABLE IF EXISTS "Students_MultipleExamsMarks_Temp";
        DROP TABLE IF EXISTS "Students_MultipleExamsMarks_Final_Temp";

        CREATE TEMP TABLE "Students_MultipleExamsMarks_Final_Temp"(
            "AMST_Id" BIGINT,
            "TotalMaxMarks" DECIMAL(18,2),
            "TotalObtMarks" DECIMAL(18,2),
            "FinalTotMarksPer" DECIMAL(18,2),
            "ObtainedGrade" VARCHAR(50),
            "ObtainedGradeRemarks" TEXT,
            "Classheld" DECIMAL(18,2),
            "Class_Attended" DECIMAL(18,2),
            "classteachername" TEXT
        );

        v_Dynamic := 'CREATE TEMP TABLE "Students_MultipleExamsMarks_Temp" AS 
        SELECT DISTINCT "AMST_Id", SUM("ESTMP_TotalMaxMarks") AS "TotalMaxMarks", SUM("ESTMP_TotalObtMarks") AS "TotalObtMarks"
        FROM "Exm"."Exm_Student_Marks_Process" esmp
        WHERE "MI_Id" = ' || p_MI_Id || ' AND "ASMAY_Id" = ' || p_ASMAY_Id || ' AND esmp."ASMCL_Id" = ' || p_ASMCL_Id || ' 
        AND "ASMS_Id" = ' || p_ASMS_Id || ' AND "EME_Id" IN(' || p_EME_Id || ')  
        GROUP BY "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id"';

        EXECUTE v_Dynamic;

        FOR rec_student IN 
            SELECT DISTINCT "AMST_Id", "TotalMaxMarks", "TotalObtMarks" FROM "Students_MultipleExamsMarks_Temp"
        LOOP
            v_AMST_Id := rec_student."AMST_Id";
            v_TotalMaxMarks := rec_student."TotalMaxMarks";
            v_TotalObtMarks := rec_student."TotalObtMarks";

            SELECT "EYCE"."EMGR_Id", "EYCE"."EYCE_AttendanceFromDate"::DATE, "EYCE"."EYCE_AttendanceToDate"::DATE
            INTO v_EMGR_Id, v_AttendanceFromDate, v_AttendanceToDate
            FROM "Exm"."Exm_Category_Class" AS "ECC" 
            INNER JOIN "Exm"."Exm_Yearly_Category" AS "EYC" ON "EYC"."MI_Id" = p_MI_Id::BIGINT AND "EYC"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id" 
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id" 
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
            WHERE "EYCE"."EME_Id" = v_EME_IdG AND "ECC"."MI_Id" = p_MI_Id::BIGINT AND "ECC"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "ECC"."ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ECC"."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND "ECC"."ECAC_ActiveFlag" = true AND "EYC"."EYC_ActiveFlg" = true 
                AND "EYCE"."EYCE_ActiveFlg" = true AND "EYC"."ASMAY_Id" = p_ASMAY_Id::BIGINT;

            v_FinalTotMarksPer := ROUND((v_TotalObtMarks / NULLIF(v_TotalMaxMarks, 0) * 100)::NUMERIC, 2);

            SELECT SUM("asa_classheld") INTO v_classheld 
            FROM "Adm_Student_Attendance" p  
            WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT
                AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT AND "ASA_Activeflag" = true  
                AND ((p."ASA_FromDate"::DATE BETWEEN v_AttendanceFromDate AND v_AttendanceToDate) 
                    OR (p."ASA_ToDate"::DATE BETWEEN v_AttendanceFromDate AND v_AttendanceToDate));

            SELECT SUM("ASA_Class_Attended") INTO v_Class_Attended 
            FROM "Adm_Student_Attendance_Students" q, "Adm_Student_Attendance" AS p
            WHERE p."ASA_Id" = q."ASA_Id" AND "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "ASA_Activeflag" = true AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND "ASMS_Id" = p_ASMS_Id::BIGINT AND q."AMST_Id" = v_AMST_Id 
                AND ((p."ASA_FromDate"::DATE BETWEEN v_AttendanceFromDate AND v_AttendanceToDate) 
                    OR (p."ASA_ToDate"::DATE BETWEEN v_AttendanceFromDate AND v_AttendanceToDate));

            SELECT "EMGD_Name", "EMGD_Remarks" INTO v_ObtainedGrade, v_ObtainedGradeRemarks 
            FROM "Exm"."Exm_Master_Grade_Details"  
            WHERE ((v_FinalTotMarksPer::DECIMAL) BETWEEN "EMGD_From" AND "EMGD_To") AND "EMGR_Id" = v_EMGR_Id;

            INSERT INTO "Students_MultipleExamsMarks_Final_Temp" 
            VALUES(v_AMST_Id, v_TotalMaxMarks, v_TotalObtMarks, v_FinalTotMarksPer, v_ObtainedGrade, 
                   v_ObtainedGradeRemarks, v_classheld, v_Class_Attended, '');

        END LOOP;

        SELECT (COALESCE(b."HRME_EmployeeFirstName", '') || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || 
                COALESCE(b."HRME_EmployeeLastName", ''))
        INTO v_classteacher
        FROM "IVRM_Master_ClassTeacher" a 
        INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id" 
        WHERE a."MI_Id" = p_MI_Id::BIGINT AND a."ASMAY_Id" = p_ASMAY_Id::BIGINT
            AND a."ASMCL_Id" = p_ASMCL_Id::BIGINT AND a."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND a."IMCT_ActiveFlag" = true AND b."HRME_ActiveFlag" = true AND b."HRME_LeftFlag" = false
        LIMIT 1;

        UPDATE "Students_MultipleExamsMarks_Final_Temp" SET "classteachername" = v_classteacher;

        RETURN QUERY 
        SELECT "AMST_Id", NULL::BIGINT, "TotalMaxMarks", "TotalObtMarks", "FinalTotMarksPer", 
               "ObtainedGrade", "ObtainedGradeRemarks", "Classheld", "Class_Attended", "classteachername",
               NULL::DECIMAL(18,2), NULL::DECIMAL(18,2), NULL::DECIMAL(18,2), NULL::VARCHAR(50)
        FROM "Students_MultipleExamsMarks_Final_Temp";

    ELSIF p_FLAG = '2' THEN

        DROP TABLE IF EXISTS "Students_MultipleExamsMarks_Indi_Temp";
        DROP TABLE IF EXISTS "Students_MultipleExamsMarks_Final_Indi_Temp";

        CREATE TEMP TABLE "Students_MultipleExamsMarks_Final_Indi_Temp"(
            "AMST_Id" BIGINT,
            "ISMS_Id" BIGINT,
            "TotalSubMaxMarks" DECIMAL(18,2),
            "TotalSubObtMarks" DECIMAL(18,2),
            "FinalTotSubMarksPer" DECIMAL(18,2),
            "ObtainedGradeSub" VARCHAR(50)
        );

        v_Dynamic := 'CREATE TEMP TABLE "Students_MultipleExamsMarks_Indi_Temp" AS 
        SELECT DISTINCT "AMST_Id", "ISMS_Id", SUM("ESTMPS_MaxMarks") AS "TotalMaxMarks", SUM("ESTMPS_ObtainedMarks") AS "TotalObtMarks"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" esmp
        WHERE "MI_Id" = ' || p_MI_Id || ' AND "ASMAY_Id" = ' || p_ASMAY_Id || ' AND esmp."ASMCL_Id" = ' || p_ASMCL_Id || ' 
        AND "ASMS_Id" = ' || p_ASMS_Id || ' AND "EME_Id" IN(' || p_EME_Id || ')  
        GROUP BY "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ISMS_Id"';

        EXECUTE v_Dynamic;

        FOR rec_student_indi IN 
            SELECT DISTINCT "AMST_Id", "ISMS_Id", "TotalMaxMarks", "TotalObtMarks" FROM "Students_MultipleExamsMarks_Indi_Temp"
        LOOP
            v_AMST_Id := rec_student_indi."AMST_Id";
            v_ISMS_Id := rec_student_indi."ISMS_Id";
            v_TotalMaxMarks := rec_student_indi."TotalMaxMarks";
            v_TotalObtMarks := rec_student_indi."TotalObtMarks";

            SELECT "EYCE"."EMGR_Id", "EYCE"."EYCE_AttendanceFromDate"::DATE, "EYCE"."EYCE_AttendanceToDate"::DATE
            INTO v_EMGR_Id, v_AttendanceFromDate, v_AttendanceToDate
            FROM "Exm"."Exm_Category_Class" AS "ECC" 
            INNER JOIN "Exm"."Exm_Yearly_Category" AS "EYC" ON "EYC"."MI_Id" = p_MI_Id::BIGINT AND "EYC"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id" 
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id" 
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
            WHERE "EYCE"."EME_Id" = v_EME_IdG AND "ECC"."MI_Id" = p_MI_Id::BIGINT AND "ECC"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "ECC"."ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ECC"."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND "ECC"."ECAC_ActiveFlag" = true AND "EYC"."EYC_ActiveFlg" = true 
                AND "EYCE"."EYCE_ActiveFlg" = true AND "EYC"."ASMAY_Id" = p_ASMAY_Id::BIGINT;

            v_FinalTotMarksPer := ROUND((v_TotalObtMarks / NULLIF(v_TotalMaxMarks, 0) * 100)::NUMERIC, 2);

            SELECT "EMGD_Name" INTO v_ObtainedGrade 
            FROM "Exm"."Exm_Master_Grade_Details"  
            WHERE ((v_FinalTotMarksPer::DECIMAL) BETWEEN "EMGD_From" AND "EMGD_To") AND "EMGR_Id" = v_EMGR_Id;

            INSERT INTO "Students_MultipleExamsMarks_Final_Indi_Temp" 
            VALUES(v_AMST_Id, v_ISMS_Id, v_TotalMaxMarks, v_TotalObtMarks, v_FinalTotMarksPer, v_ObtainedGrade);

        END LOOP;

        RETURN QUERY 
        SELECT "AMST_Id", "ISMS_Id", NULL::DECIMAL(18,2), NULL::DECIMAL(18,2), NULL::DECIMAL(18,2), 
               NULL::VARCHAR(50), NULL::TEXT, NULL::DECIMAL(18,2), NULL::DECIMAL(18,2), NULL::TEXT,
               "TotalSubMaxMarks", "TotalSubObtMarks", "FinalTotSubMarksPer", "ObtainedGradeSub"
        FROM "Students_MultipleExamsMarks_Final_Indi_Temp";

    END IF;

    RETURN;

END;
$$;