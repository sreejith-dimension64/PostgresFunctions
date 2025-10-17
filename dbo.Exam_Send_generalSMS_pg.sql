CREATE OR REPLACE FUNCTION "dbo"."Exam_Send_generalSMS"(
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_MI_Id bigint,
    p_EME_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_Name" text,
    "AMST_AdmNo" text,
    "AMST_emailId" text,
    "AMST_MobileNo" text,
    "MarksDetails" text,
    "GradeDetails" text,
    "TotalMarks" text,
    "TotalGrade" text,
    "result" text,
    "ESTMPS_PassFailFlg" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_ASMS_Id = 0 THEN
        RETURN QUERY
        SELECT DISTINCT 
            "AMS"."AMST_Id",
            (COALESCE("AMS"."AMST_FirstName", ' ') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '')) as "AMST_Name",
            "AMS"."AMST_AdmNo",
            "AMS"."AMST_emailId",
            "AMS"."AMST_MobileNo",
            ("IMS"."ISMS_SubjectName" || ': ' || CAST("ESMPS"."ESTMPS_ObtainedMarks" as varchar(50)) || '/' || CAST("ESMPS"."ESTMPS_MaxMarks" as varchar(50))) as "MarksDetails",
            ("IMS"."ISMS_SubjectName" || ': ' || "ESMPS"."ESTMPS_ObtainedGrade") as "GradeDetails",
            ('Total: ' || CAST("ESMP"."ESTMP_TotalObtMarks" as varchar(50)) || '/' || CAST("ESMP"."ESTMP_TotalMaxMarks" as varchar(50))) as "TotalMarks",
            ('TotalGrade: ' || "ESMP"."ESTMP_TotalGrade") as "TotalGrade",
            ("IMS"."ISMS_SubjectName" || ': ' || "ESMPS"."ESTMPS_PassFailFlg" || '/' || CAST("ESMPS"."ESTMPS_MaxMarks" as varchar(50))) as "result",
            "ESMPS"."ESTMPS_PassFailFlg"
        FROM "ADM_M_STUDENT" "AMS" 
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY"
            ON "AMS"."ASMAY_Id" = "ASMAY"."ASMAY_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" 
            ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
            AND "AMS"."AMST_ActiveFlag" = 1 
            AND "AMS"."AMST_SOL" = 'S' 
            AND "ASYS"."AMAY_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
            ON "ESMPS"."AMST_Id" = "AMS"."AMST_Id" 
            AND "ASMAY"."ASMAY_Id" = "ESMPS"."ASMAY_Id"
            AND "ESMPS"."MI_Id" = "AMS"."MI_Id"
        INNER JOIN "IVRM_Master_subjects" "IMS" 
            ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" "ESMP" 
            ON "ESMP"."AMST_Id" = "AMS"."AMST_Id" 
            AND "ASMAY"."ASMAY_Id" = "ESMP"."ASMAY_Id"
            AND "ESMP"."MI_Id" = "AMS"."MI_Id" 
            AND "ESMPS"."EME_Id" = "ESMP"."EME_Id"  
            AND "ESMPS"."ASMCl_Id" = "ESMP"."ASMCL_Id"
        WHERE "ESMPS"."MI_Id" = p_MI_Id 
            AND "ESMPS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ESMPS"."EME_Id" = p_EME_Id 
            AND "ESMPS"."ASMCL_Id" = p_ASMCL_Id;
    ELSIF p_ASMS_Id > 0 THEN
        RETURN QUERY
        SELECT DISTINCT 
            "AMS"."AMST_Id",
            (COALESCE("AMS"."AMST_FirstName", ' ') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '')) as "AMST_Name",
            "AMS"."AMST_AdmNo",
            "AMS"."AMST_emailId",
            "AMS"."AMST_MobileNo",
            ("IMS"."ISMS_SubjectName" || ': ' || CAST("ESMPS"."ESTMPS_ObtainedMarks" as varchar(50)) || '/' || CAST("ESMPS"."ESTMPS_MaxMarks" as varchar(50))) as "MarksDetails",
            ("IMS"."ISMS_SubjectName" || ': ' || "ESMPS"."ESTMPS_ObtainedGrade") as "GradeDetails",
            ('Total: ' || CAST("ESMP"."ESTMP_TotalObtMarks" as varchar(50)) || '/' || CAST("ESMP"."ESTMP_TotalMaxMarks" as varchar(50))) as "TotalMarks",
            ('TotalGrade: ' || "ESMP"."ESTMP_TotalGrade") as "TotalGrade",
            ("IMS"."ISMS_SubjectName" || ': ' || "ESMPS"."ESTMPS_PassFailFlg" || '/' || CAST("ESMPS"."ESTMPS_MaxMarks" as varchar(50))) as "result",
            "ESMPS"."ESTMPS_PassFailFlg"
        FROM "ADM_M_STUDENT" "AMS" 
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY"
            ON "AMS"."ASMAY_Id" = "ASMAY"."ASMAY_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" 
            ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
            AND "AMS"."AMST_ActiveFlag" = 1 
            AND "AMS"."AMST_SOL" = 'S' 
            AND "ASYS"."AMAY_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
            ON "ESMPS"."AMST_Id" = "AMS"."AMST_Id" 
            AND "ASMAY"."ASMAY_Id" = "ESMPS"."ASMAY_Id"
            AND "ESMPS"."MI_Id" = "AMS"."MI_Id"
        INNER JOIN "IVRM_Master_subjects" "IMS" 
            ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" "ESMP" 
            ON "ESMP"."AMST_Id" = "AMS"."AMST_Id" 
            AND "ASMAY"."ASMAY_Id" = "ESMP"."ASMAY_Id"
            AND "ESMP"."MI_Id" = "AMS"."MI_Id" 
            AND "ESMPS"."EME_Id" = "ESMP"."EME_Id"  
            AND "ESMPS"."ASMCl_Id" = "ESMP"."ASMCL_Id" 
            AND "ESMPS"."ASMS_Id" = "ESMP"."ASMS_Id"
        WHERE "ESMPS"."MI_Id" = p_MI_Id 
            AND "ESMPS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ESMPS"."EME_Id" = p_EME_Id 
            AND "ESMPS"."ASMCL_Id" = p_ASMCL_Id 
            AND "ESMPS"."ASMS_Id" = p_ASMS_Id;
    END IF;
END;
$$;