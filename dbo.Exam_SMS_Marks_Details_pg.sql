CREATE OR REPLACE FUNCTION "dbo"."Exam_SMS_Marks_Details"(
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_MI_Id TEXT,
    p_EME_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "NAME" TEXT,
    "EXAM" TEXT,
    "MARKS" TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS schoolstudent;

    IF p_ASMS_Id != '0' THEN
    
        DROP TABLE IF EXISTS schoolstudent;

        CREATE TEMP TABLE schoolstudent AS
        SELECT DISTINCT 
            a."AMST_Id",
            (COALESCE(b."AMST_FirstName",' ') || ' ' || COALESCE(b."AMST_MiddleName",'') || ' ' || COALESCE(b."AMST_LastName",'')) as "AMST_Name",
            b."AMST_AdmNo",
            b."AMST_emailId",
            b."AMST_MobileNo",
            (h."ISMS_SubjectName" || ': ' || CAST(c."ESTMPS_ObtainedMarks" as VARCHAR(50)) || '/' || CAST(c."ESTMPS_MaxMarks" as VARCHAR(50))) as "MarksDetails",
            (h."ISMS_SubjectName" || ': ' || c."ESTMPS_ObtainedGrade") as "GradeDetails",
            i."EME_ExamName",
            ('Total: ' || CAST(d."ESTMP_TotalObtMarks" as VARCHAR(50)) || '/' || CAST(d."ESTMP_TotalMaxMarks" as VARCHAR(50))) as "TotalMarks",
            ('TotalGrade: ' || d."ESTMP_TotalGrade") as "TotalGrade",
            (h."ISMS_SubjectName" || ': ' || c."ESTMPS_PassFailFlg" || '/' || CAST(c."ESTMPS_MaxMarks" as VARCHAR(50))) as result,
            c."ESTMPS_PassFailFlg"
        FROM "Adm_School_Y_Student" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" c ON c."AMST_Id" = a."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" d ON d."AMST_Id" = a."AMST_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = a."ASMCL_Id" AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = a."ASMS_Id" AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMS_Id" = d."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = a."ASMAY_Id" AND g."ASMAY_Id" = c."ASMAY_Id" AND g."ASMAY_Id" = d."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" h ON h."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" i ON i."EME_Id" = c."EME_Id" AND i."EME_Id" = d."EME_Id"
        WHERE b."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND c."EME_Id" = p_EME_Id 
            AND a."ASMCL_Id" = p_ASMCL_Id 
            AND a."ASMS_Id" = p_ASMS_Id 
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND c."ASMCL_Id" = p_ASMCL_Id 
            AND c."ASMS_Id" = p_ASMS_Id
            AND d."ASMAY_Id" = p_ASMAY_Id 
            AND d."EME_Id" = p_EME_Id 
            AND d."ASMCL_Id" = p_ASMCL_Id 
            AND d."ASMS_Id" = p_ASMS_Id 
            AND d."AMST_Id" = p_AMST_Id;

        RETURN QUERY
        SELECT 
            B."AMST_Name" as "NAME",
            B."EME_ExamName" as "EXAM",
            (STRING_AGG(DISTINCT A."MarksDetails", ', ' ORDER BY A."MarksDetails") || ' ' || 
             STRING_AGG(DISTINCT A."TotalMarks", ', ' ORDER BY A."TotalMarks")) AS "MARKS"
        FROM (SELECT DISTINCT "AMST_Name", "EME_ExamName" FROM schoolstudent) B
        LEFT JOIN schoolstudent A ON A."AMST_Name" = B."AMST_Name" AND A."EME_ExamName" = B."EME_ExamName"
        GROUP BY B."AMST_Name", B."EME_ExamName";

    ELSE
    
        DROP TABLE IF EXISTS schoolstudent;

        CREATE TEMP TABLE schoolstudent AS
        SELECT DISTINCT 
            a."AMST_Id",
            (COALESCE(b."AMST_FirstName",' ') || ' ' || COALESCE(b."AMST_MiddleName",'') || ' ' || COALESCE(b."AMST_LastName",'')) as "AMST_Name",
            b."AMST_AdmNo",
            b."AMST_emailId",
            b."AMST_MobileNo",
            (h."ISMS_SubjectName" || ': ' || CAST(c."ESTMPS_ObtainedMarks" as VARCHAR(50)) || '/' || CAST(c."ESTMPS_MaxMarks" as VARCHAR(50))) as "MarksDetails",
            (h."ISMS_SubjectName" || ': ' || c."ESTMPS_ObtainedGrade") as "GradeDetails",
            i."EME_ExamName",
            ('Total: ' || CAST(d."ESTMP_TotalObtMarks" as VARCHAR(50)) || '/' || CAST(d."ESTMP_TotalMaxMarks" as VARCHAR(50))) as "TotalMarks",
            ('TotalGrade: ' || d."ESTMP_TotalGrade") as "TotalGrade",
            (h."ISMS_SubjectName" || ': ' || c."ESTMPS_PassFailFlg" || '/' || CAST(c."ESTMPS_MaxMarks" as VARCHAR(50))) as result,
            c."ESTMPS_PassFailFlg"
        FROM "Adm_School_Y_Student" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" c ON c."AMST_Id" = a."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" d ON d."AMST_Id" = a."AMST_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = a."ASMCL_Id" AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = a."ASMS_Id" AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMS_Id" = d."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = a."ASMAY_Id" AND g."ASMAY_Id" = c."ASMAY_Id" AND g."ASMAY_Id" = d."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" h ON h."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" i ON i."EME_Id" = c."EME_Id" AND i."EME_Id" = d."EME_Id"
        WHERE b."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND c."EME_Id" = p_EME_Id 
            AND a."ASMCL_Id" = p_ASMCL_Id 
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND c."ASMCL_Id" = p_ASMCL_Id
            AND d."ASMAY_Id" = p_ASMAY_Id 
            AND d."EME_Id" = p_EME_Id 
            AND d."ASMCL_Id" = p_ASMCL_Id 
            AND d."AMST_Id" = p_AMST_Id;

        RETURN QUERY
        SELECT 
            B."AMST_Name" as "NAME",
            B."EME_ExamName" as "EXAM",
            (STRING_AGG(DISTINCT A."MarksDetails", ', ' ORDER BY A."MarksDetails") || ' ' || 
             STRING_AGG(DISTINCT A."TotalMarks", ', ' ORDER BY A."TotalMarks")) AS "MARKS"
        FROM (SELECT DISTINCT "AMST_Name", "EME_ExamName" FROM schoolstudent) B
        LEFT JOIN schoolstudent A ON A."AMST_Name" = B."AMST_Name" AND A."EME_ExamName" = B."EME_ExamName"
        GROUP BY B."AMST_Name", B."EME_ExamName";

    END IF;

    DROP TABLE IF EXISTS schoolstudent;
    
    RETURN;
END;
$$;