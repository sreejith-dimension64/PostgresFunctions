CREATE OR REPLACE FUNCTION "dbo"."Exam_Wise_Promotion_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@EME_Id" TEXT,
    "@FLAG" TEXT
)
RETURNS TABLE(
    "STUDENTNAME" TEXT,
    "ISMS_SubjectName" VARCHAR,
    "ESTMPS_MaxMarks" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ISMS_OrderFlag" INTEGER,
    "ESTMPS_ObtainedGrade" VARCHAR,
    "COUNTGRADE" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@FLAG" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            (COALESCE("AMST_FirstName", '') || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", '') || ' : ' || COALESCE("AMST_AdmNo", ''))::TEXT AS "STUDENTNAME",
            "H"."ISMS_SubjectName",
            "F"."ESTMPS_MaxMarks",
            MAX("F"."ESTMPS_ObtainedMarks") AS "ESTMPS_ObtainedMarks",
            "H"."ISMS_OrderFlag",
            NULL::VARCHAR AS "ESTMPS_ObtainedGrade",
            NULL::BIGINT AS "COUNTGRADE"
        FROM "Adm_School_Y_Student" "A"
        INNER JOIN "Adm_M_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id" = "A"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "F" ON "F"."AMST_Id" = "A"."AMST_Id" AND "F"."ASMAY_Id" = "C"."ASMAY_Id" AND "D"."ASMCL_Id" = "F"."ASMCL_Id" AND "E"."ASMS_Id" = "F"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "G" ON "G"."EME_Id" = "F"."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" "H" ON "H"."ISMS_Id" = "F"."ISMS_Id"
        WHERE "A"."ASMAY_Id" = "@ASMAY_Id" 
            AND "A"."ASMCL_Id" = "@ASMCL_Id" 
            AND "A"."ASMS_Id" = "@ASMS_Id" 
            AND "F"."ASMAY_Id" = "@ASMAY_Id" 
            AND "F"."ASMCL_Id" = "@ASMCL_Id" 
            AND "F"."ASMS_Id" = "@ASMS_Id" 
            AND "F"."EME_Id" = "@EME_Id"
            AND "F"."ESTMPS_ObtainedMarks" = "F"."ESTMPS_SectionHighest"
        GROUP BY "B"."AMST_FirstName", "B"."AMST_MiddleName", "B"."AMST_LastName", "B"."AMST_AdmNo", "H"."ISMS_SubjectName", "F"."ESTMPS_MaxMarks", "H"."ISMS_OrderFlag"
        ORDER BY "H"."ISMS_OrderFlag", "STUDENTNAME";

    ELSIF "@FLAG" = '2' THEN
        RETURN QUERY
        SELECT 
            NULL::TEXT AS "STUDENTNAME",
            NULL::VARCHAR AS "ISMS_SubjectName",
            NULL::NUMERIC AS "ESTMPS_MaxMarks",
            NULL::NUMERIC AS "ESTMPS_ObtainedMarks",
            NULL::INTEGER AS "ISMS_OrderFlag",
            "F"."ESTMPS_ObtainedGrade",
            COUNT("F"."ESTMPS_ObtainedGrade") AS "COUNTGRADE"
        FROM "Adm_School_Y_Student" "A"
        INNER JOIN "Adm_M_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id" = "A"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "F" ON "F"."AMST_Id" = "A"."AMST_Id" AND "F"."ASMAY_Id" = "C"."ASMAY_Id" AND "D"."ASMCL_Id" = "F"."ASMCL_Id" AND "E"."ASMS_Id" = "F"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "G" ON "G"."EME_Id" = "F"."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" "H" ON "H"."ISMS_Id" = "F"."ISMS_Id"
        WHERE "A"."ASMAY_Id" = "@ASMAY_Id" 
            AND "A"."ASMCL_Id" = "@ASMCL_Id" 
            AND "A"."ASMS_Id" = "@ASMS_Id" 
            AND "F"."ASMAY_Id" = "@ASMAY_Id" 
            AND "F"."ASMCL_Id" = "@ASMCL_Id" 
            AND "F"."ASMS_Id" = "@ASMS_Id" 
            AND "F"."EME_Id" = "@EME_Id"
        GROUP BY "F"."ESTMPS_ObtainedGrade";

    END IF;

    RETURN;
END;
$$;