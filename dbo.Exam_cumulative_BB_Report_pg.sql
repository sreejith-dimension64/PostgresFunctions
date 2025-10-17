CREATE OR REPLACE FUNCTION "dbo"."Exam_cumulative_BB_Report"(
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_MI_Id bigint,
    p_EME_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" text,
    "AMST_MiddleName" text,
    "AMST_LastName" text,
    "AMST_DOB" timestamp,
    "AMAY_RollNo" bigint,
    "AMST_AdmNo" text,
    "AMST_RegistrationNo" text,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" text,
    "ISMS_SubjectCode" text,
    "EYCES_AplResultFlg" boolean,
    "EYCES_MaxMarks" numeric,
    "EYCES_MinMarks" numeric,
    "EMGR_Id" bigint,
    "ESTMPS_MaxMarks" numeric,
    "ESTMPS_ClassAverage" numeric,
    "ESTMPS_SectionAverage" numeric,
    "ESTMPS_ClassHighest" numeric,
    "ESTMPS_SectionHighest" numeric,
    "ESTMPS_ObtainedMarks" numeric,
    "ESTMPS_ObtainedGrade" text,
    "ESTMPS_PassFailFlg" text,
    "EME_ExamName" text,
    "ASMCL_ClassName" text,
    "ASMC_SectionName" text,
    "ASA_ClassHeld" numeric,
    "ASA_Class_Attended" numeric,
    "EMGD_Remarks" text,
    "ESTMP_TotalObtMarks" numeric,
    "ESTMP_Percentage" numeric,
    "ESTMP_TotalGrade" text,
    "ESTMP_ClassRank" numeric,
    "ESTMP_SectionRank" numeric,
    "ESTMP_TotalGradeRemark" text,
    "ESTMP_Result" text,
    "ESTMP_TotalMaxMarks" numeric,
    "MI_name" text,
    "EYCES_SubjectOrder" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    SET LOCAL TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    RETURN QUERY
    SELECT DISTINCT 
        f."AMST_Id",
        f."AMST_FirstName",
        f."AMST_MiddleName",
        f."AMST_LastName",
        f."AMST_DOB",
        h."AMAY_RollNo",
        f."AMST_AdmNo",
        f."AMST_RegistrationNo",
        m."ISMS_Id",
        d."ISMS_SubjectName",
        d."ISMS_SubjectCode",
        m."EYCES_AplResultFlg",
        m."EYCES_MaxMarks",
        m."EYCES_MinMarks",
        m."EMGR_Id",
        COALESCE(a."ESTMPS_MaxMarks", 0) as "ESTMPS_MaxMarks",
        COALESCE(a."ESTMPS_ClassAverage", 0) as "ESTMPS_ClassAverage",
        COALESCE(a."ESTMPS_SectionAverage", 0) as "ESTMPS_SectionAverage",
        ROUND(COALESCE(a."ESTMPS_ClassHighest", 0), 0) as "ESTMPS_ClassHighest",
        ROUND(COALESCE(a."ESTMPS_SectionHighest", 0), 0) as "ESTMPS_SectionHighest",
        COALESCE(a."ESTMPS_ObtainedMarks", 1000) as "ESTMPS_ObtainedMarks",
        a."ESTMPS_ObtainedGrade",
        a."ESTMPS_PassFailFlg",
        c."EME_ExamName",
        b."ASMCL_ClassName",
        e."ASMC_SectionName",
        (SELECT SUM(p2."asa_classheld") 
         FROM "Adm_Student_Attendance" p2  
         WHERE p2."mi_id" = p_MI_Id 
           AND p2."ASMAY_Id" = p_ASMAY_Id
           AND p2."ASMCL_Id" = p_ASMCL_Id 
           AND p2."ASMS_Id" = p_ASMS_Id 
           AND p2."ASA_Activeflag" = true  
           AND ((p2."ASA_FromDate" BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate") 
                OR (p2."ASA_ToDate" BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))
        ) AS "ASA_ClassHeld",
        (SELECT SUM(q2."ASA_Class_Attended") 
         FROM "Adm_Student_Attendance_Students" q2, "Adm_Student_Attendance" AS p2
         WHERE p2."ASA_Id" = q2."ASA_Id" 
           AND p2."mi_id" = p_MI_Id 
           AND p2."ASMAY_Id" = p_ASMAY_Id 
           AND p2."ASA_Activeflag" = true 
           AND p2."ASMCL_Id" = p_ASMCL_Id 
           AND p2."ASMS_Id" = p_ASMS_Id 
           AND q2."AMST_Id" = f."AMST_Id" 
           AND ((p2."ASA_FromDate" BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate") 
                OR (p2."ASA_ToDate" BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))
        ) AS "ASA_Class_Attended",
        r."EMGD_Remarks",
        COALESCE(s."ESTMP_TotalObtMarks", 0) as "ESTMP_TotalObtMarks",
        COALESCE(s."ESTMP_Percentage", 0) as "ESTMP_Percentage",
        s."ESTMP_TotalGrade",
        COALESCE(s."ESTMP_ClassRank", 0) as "ESTMP_ClassRank",
        COALESCE(s."ESTMP_SectionRank", 0) as "ESTMP_SectionRank",
        t."EMGD_Remarks" as "ESTMP_TotalGradeRemark",
        s."ESTMP_Result" as "ESTMP_Result",
        COALESCE(s."ESTMP_TotalMaxMarks", 0) as "ESTMP_TotalMaxMarks",
        w."MI_name",
        m."EYCES_SubjectOrder"
    FROM "Adm_M_Student" AS f         
    INNER JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
        AND f."AMST_ActiveFlag" IN (0, 1) 
        AND f."AMST_SOL" IN ('S', 'L') 
        AND h."AMAY_ActiveFlag" IN (1, 0) 
        AND h."ASMAY_Id" = p_ASMAY_Id 
        AND h."ASMCL_Id" = p_ASMCL_Id 
        AND h."ASMS_Id" = p_ASMS_Id        
    INNER JOIN "Exm"."Exm_Category_Class" AS j ON j."ASMAY_Id" = p_ASMAY_Id 
        AND j."ASMCL_Id" = p_ASMCL_Id 
        AND j."ASMS_Id" = p_ASMS_Id 
        AND j."MI_Id" = p_MI_Id
    INNER JOIN "Exm"."Exm_Yearly_Category" AS k ON j."EMCA_Id" = k."EMCA_Id" 
        AND k."ASMAY_Id" = p_ASMAY_Id 
        AND k."MI_Id" = p_MI_Id
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS l ON l."EYC_Id" = k."EYC_Id" 
        AND l."EME_Id" = p_EME_Id 
    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS m ON m."EYCE_Id" = l."EYCE_Id" 
        AND m."EYCES_ActiveFlg" = true 
        AND m."EYCES_AplResultFlg" = true
    LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process" AS s ON f."AMST_Id" = s."AMST_Id"  
        AND s."ASMCL_Id" = p_ASMCL_Id  
        AND s."ASMS_Id" = p_ASMS_Id 
        AND s."ASMAY_Id" = p_ASMAY_Id 
        AND s."MI_Id" = p_MI_Id 
        AND s."EME_Id" = p_EME_Id
    LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS a ON m."ISMS_Id" = a."ISMS_Id" 
        AND f."AMST_Id" = a."AMST_Id" 
        AND a."ASMCL_Id" = p_ASMCL_Id  
        AND a."ASMS_Id" = p_ASMS_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."MI_Id" = p_MI_Id 
        AND a."EME_Id" = p_EME_Id
    INNER JOIN "IVRM_Master_Subjects" AS d ON m."ISMS_Id" = d."ISMS_Id"  
        AND d."MI_Id" = p_MI_Id   
    INNER JOIN "Adm_School_M_Class" AS b ON h."ASMCL_Id" = b."ASMCL_Id" 
        AND b."MI_Id" = p_MI_Id
    INNER JOIN "Master_Institution" AS w ON w."mi_id" = p_MI_Id
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS r ON m."emgr_id" = r."emgr_id" 
        AND a."ESTMPS_ObtainedGrade" = r."EMGD_Name"
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS t ON l."emgr_id" = t."emgr_id" 
        AND s."ESTMP_TotalGrade" = t."EMGD_Name"
    INNER JOIN "Exm"."Exm_Master_Exam" AS c ON l."EME_Id" = c."EME_Id" 
        AND c."MI_Id" = p_MI_Id                             
    INNER JOIN "Adm_School_M_Section" AS e ON h."ASMS_Id" = e."ASMS_Id" 
        AND e."MI_Id" = p_MI_Id 
    GROUP BY f."AMST_Id", f."AMST_FirstName", f."AMST_MiddleName", f."AMST_LastName", 
             f."AMST_DOB", h."AMAY_RollNo", f."AMST_AdmNo", f."AMST_RegistrationNo", 
             m."ISMS_Id", d."ISMS_SubjectName", d."ISMS_SubjectCode", m."EYCES_AplResultFlg", 
             m."EYCES_MaxMarks", m."EYCES_MinMarks", m."EMGR_Id", a."ESTMPS_MaxMarks", 
             a."ESTMPS_ClassAverage", a."ESTMPS_SectionAverage", a."ESTMPS_ClassHighest", 
             a."ESTMPS_SectionHighest", a."ESTMPS_ObtainedMarks", a."ESTMPS_ObtainedGrade", 
             a."ESTMPS_PassFailFlg", c."EME_ExamName", b."ASMCL_ClassName", e."ASMC_SectionName", 
             r."EMGD_Remarks", s."ESTMP_TotalObtMarks", s."ESTMP_Percentage", s."ESTMP_TotalGrade", 
             s."ESTMP_ClassRank", s."ESTMP_SectionRank", t."EMGD_Remarks", s."ESTMP_TotalMaxMarks", 
             w."MI_name", m."EYCES_SubjectOrder", l."EYCE_AttendanceFromDate", 
             l."EYCE_AttendanceToDate", s."ESTMP_Result"
    ORDER BY h."AMAY_RollNo", m."EYCES_SubjectOrder" ASC;
    
    SET LOCAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    RETURN;
END;
$$;