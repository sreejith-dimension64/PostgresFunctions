CREATE OR REPLACE FUNCTION "dbo"."Exam_get_BB_Exam_Details_Simple"(
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_MI_Id bigint,
    p_EME_Id bigint,
    p_from date,
    p_to date
)
RETURNS TABLE(
    "ESTMPS_ObtainedMarks" numeric,
    "ESTMPS_ObtainedGrade" varchar,
    "ESTMPS_PassFailFlg" varchar,
    "EME_ExamName" varchar,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "AMST_Id" bigint,
    "AMST_FirstName" text,
    "AMST_DOB" timestamp,
    "AMAY_RollNo" varchar,
    "AMST_AdmNo" varchar,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar,
    "ESTMPS_MaxMarks" numeric,
    "ESTMPS_ClassAverage" numeric,
    "ESTMPS_SectionAverage" numeric,
    "ESTMPS_ClassHighest" numeric,
    "ESTMPS_SectionHighest" numeric,
    "ISMS_SubjectCode" varchar,
    "EYCES_AplResultFlg" boolean,
    "EYCES_MaxMarks" numeric,
    "EYCES_MinMarks" numeric,
    "EMGR_Id" bigint,
    "graderemark" text,
    "ESTMP_TotalObtMarks" numeric,
    "ESTMP_Percentage" numeric,
    "ESTMP_TotalGrade" varchar,
    "ESTMP_ClassRank" integer,
    "ESTMP_SectionRank" integer,
    "ESTMP_TotalGradeRemark" text,
    "ESTMP_TotalMaxMarks" numeric,
    "EYCES_SubjectOrder" integer,
    "EYCES_MarksDisplayFlg" boolean,
    "EYCES_GradeDisplayFlg" boolean,
    "ESTMP_Result" varchar,
    "classheld" bigint,
    "classatt" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."ESTMPS_ObtainedMarks",
        a."ESTMPS_ObtainedGrade",
        a."ESTMPS_PassFailFlg",
        c."EME_ExamName",
        b."ASMCL_ClassName",
        e."ASMC_SectionName",
        f."AMST_Id",
        (f."AMST_FirstName" || f."AMST_MiddleName" || f."AMST_MiddleName" || f."AMST_LastName")::text AS "AMST_FirstName",
        f."AMST_DOB",
        h."AMAY_RollNo",
        f."AMST_AdmNo",
        d."ISMS_Id",
        d."ISMS_SubjectName",
        a."ESTMPS_MaxMarks",
        a."ESTMPS_ClassAverage",
        a."ESTMPS_SectionAverage",
        a."ESTMPS_ClassHighest",
        a."ESTMPS_SectionHighest",
        d."ISMS_SubjectCode",
        l."EYCES_AplResultFlg",
        l."EYCES_MaxMarks",
        l."EYCES_MinMarks",
        l."EMGR_Id",
        n."EMGD_Remarks" AS "graderemark",
        g."ESTMP_TotalObtMarks",
        g."ESTMP_Percentage",
        g."ESTMP_TotalGrade",
        g."ESTMP_ClassRank",
        g."ESTMP_SectionRank",
        (SELECT "EMGD_Remarks" 
         FROM "Exm"."Exm_Master_Grade_Details" 
         WHERE "EMGR_Id" = k."EMGR_Id" 
         AND "EMGD_Name" = g."ESTMP_TotalGrade") AS "ESTMP_TotalGradeRemark",
        g."ESTMP_TotalMaxMarks",
        l."EYCES_SubjectOrder",
        l."EYCES_MarksDisplayFlg",
        l."EYCES_GradeDisplayFlg",
        g."ESTMP_Result",
        (SELECT COALESCE(SUM("ASA_ClassHeld"), 0) 
         FROM "Adm_Student_Attendance" 
         WHERE "MI_Id" = p_MI_Id 
         AND "ASMAY_Id" = p_ASMAY_Id 
         AND "ASMCL_Id" = p_ASMCL_Id 
         AND "ASMS_Id" = p_ASMS_Id 
         AND (("ASA_FromDate" BETWEEN p_from AND p_to) 
              OR ("ASA_ToDate" BETWEEN p_from AND p_to)))::bigint AS "classheld",
        (SELECT COALESCE(SUM("ASA_Class_Attended"), 0) 
         FROM "Adm_Student_Attendance_Students" 
         WHERE "ASA_Id" IN (
             SELECT DISTINCT "ASA_Id" 
             FROM "Adm_Student_Attendance" 
             WHERE "MI_Id" = p_MI_Id 
             AND "ASMAY_Id" = p_ASMAY_Id 
             AND "ASMCL_Id" = p_ASMCL_Id 
             AND "ASMS_Id" = p_ASMS_Id 
             AND "ASA_Activeflag" = true 
             AND (("ASA_FromDate" BETWEEN p_from AND p_to) 
                  OR ("ASA_ToDate" BETWEEN p_from AND p_to))
         ) 
         AND "AMST_Id" = f."AMST_Id")::bigint AS "classatt"
    FROM 
        "Exm"."Exm_Student_Marks_Process_Subjectwise" a
        INNER JOIN "adm_school_m_class" b ON a."ASMCL_Id" = b."ASMCL_Id"
        INNER JOIN "Exm"."Exm_master_Exam" c ON a."EME_Id" = c."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON a."ISMS_Id" = d."ISMS_Id"
        INNER JOIN "adm_School_M_Section" e ON a."ASMS_Id" = e."ASMS_Id"
        INNER JOIN "Adm_M_Student" f ON a."AMST_Id" = f."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" g ON g."MI_Id" = a."MI_Id" 
            AND g."ASMAY_Id" = a."ASMAY_Id" 
            AND g."ASMCL_Id" = a."ASMCL_Id" 
            AND g."ASMS_Id" = a."ASMS_Id" 
            AND g."EME_Id" = a."EME_Id" 
            AND g."AMST_Id" = a."AMST_Id"
        INNER JOIN "adm_School_Y_Student" h ON h."AMST_Id" = a."AMST_Id"
        INNER JOIN "Exm"."Exm_Category_Class" i ON i."MI_Id" = a."MI_Id" 
            AND i."ASMAY_Id" = a."ASMAY_Id" 
            AND i."ASMCL_Id" = a."ASMCL_Id" 
            AND i."ASMS_Id" = a."ASMS_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" j ON j."MI_Id" = a."MI_Id" 
            AND j."ASMAY_Id" = a."ASMAY_Id" 
            AND j."EMCA_Id" = i."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" k ON k."EYC_Id" = j."EYC_Id" 
            AND k."EME_Id" = a."EME_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" l ON l."EYCE_Id" = k."EYCE_Id" 
            AND l."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Grade" m ON m."MI_Id" = a."MI_Id" 
            AND m."EMGR_Id" = l."EMGR_Id"
        INNER JOIN "Exm"."Exm_Master_Grade_Details" n ON n."EMGR_Id" = m."EMGR_Id" 
            AND n."EMGD_Name" = a."ESTMPS_ObtainedGrade"
    WHERE 
        a."ASMCL_Id" = p_ASMCL_Id 
        AND a."ASMS_Id" = p_ASMS_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."MI_Id" = p_MI_Id 
        AND a."EME_Id" = p_EME_Id 
        AND h."ASMAY_Id" = p_ASMAY_Id 
        AND h."ASMCL_Id" = p_ASMCL_Id 
        AND h."ASMS_Id" = p_ASMS_Id
    ORDER BY 
        f."AMST_Id", 
        l."EYCES_SubjectOrder" ASC;
        
    RETURN;
END;
$$;