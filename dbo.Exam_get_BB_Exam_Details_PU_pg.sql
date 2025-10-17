CREATE OR REPLACE FUNCTION "dbo"."Exam_get_BB_Exam_Details_PU"(
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_MI_Id bigint,
    p_EME_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" varchar,
    "AMST_MiddleName" varchar,
    "AMST_LastName" varchar,
    "AMST_DOB" timestamp,
    "AMAY_RollNo" varchar,
    "AMST_AdmNo" varchar,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar,
    "ISMS_SubjectCode" varchar,
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
    "ESTMPS_ObtainedGrade" varchar,
    "ESTMPS_PassFailFlg" varchar,
    "EME_ExamName" varchar,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "ESTMPSSS_ObtainedMarks" numeric,
    "EMSE_SubExamName" varchar,
    "EMSE_SubExamOrder" integer,
    "ASA_ClassHeld" numeric,
    "ASA_Class_Attended" numeric,
    "EMGD_Remarks" varchar,
    "EYCES_AplResultFlg2" boolean,
    "ESTMP_TotalObtMarks" numeric,
    "ESTMP_Percentage" numeric,
    "ESTMP_TotalGrade" varchar,
    "ESTMP_ClassRank" integer,
    "ESTMP_SectionRank" integer,
    "ESTMP_TotalGradeRemark" varchar,
    "ESTMP_TotalMaxMarks" numeric,
    "MI_name" varchar,
    "EYCES_SubjectOrder" integer,
    "EYCES_MarksDisplayFlg" boolean,
    "EYCES_GradeDisplayFlg" boolean,
    "ESTMP_Result" varchar,
    "AMST_RegistrationNo" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    RETURN QUERY
    SELECT DISTINCT 
        f."AMST_Id",
        f."AMST_FirstName",
        f."AMST_MiddleName",
        f."AMST_LastName",
        f."AMST_DOB",
        h."AMAY_RollNo",
        f."AMST_AdmNo",
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
        COALESCE(a."ESTMPS_ObtainedMarks", 0) as "ESTMPS_ObtainedMarks",
        a."ESTMPS_ObtainedGrade",
        a."ESTMPS_PassFailFlg",
        c."EME_ExamName",
        b."ASMCL_ClassName",
        e."ASMC_SectionName",
        COALESCE(subuj."ESTMPSSS_ObtainedMarks", 0) as "ESTMPSSS_ObtainedMarks",
        COALESCE(msubsuj."EMSE_SubExamName", '') as "EMSE_SubExamName",
        msubsuj."EMSE_SubExamOrder",
        (SELECT sum(asa_classheld) 
         FROM "Adm_Student_Attendance" p  
         WHERE mi_id = p_MI_Id 
           AND "ASMAY_Id" = p_ASMAY_Id
           AND "ASMCL_Id" = p_ASMCL_Id 
           AND "ASMS_Id" = p_ASMS_Id 
           AND "ASA_Activeflag" = 1  
           AND ((p."ASA_FromDate"::timestamp BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate") 
                OR (p."ASA_ToDate"::timestamp BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))
        ) AS "ASA_ClassHeld",
        (SELECT sum("ASA_Class_Attended") 
         FROM "Adm_Student_Attendance_Students" q, "Adm_Student_Attendance" as p
         WHERE p."ASA_Id" = q."ASA_Id" 
           AND mi_id = p_MI_Id 
           AND "ASA_Activeflag" = 1 
           AND "ASMAY_Id" = p_ASMAY_Id 
           AND "ASMCL_Id" = p_ASMCL_Id 
           AND "ASMS_Id" = p_ASMS_Id 
           AND q."AMST_Id" = f."AMST_Id" 
           AND ((p."ASA_FromDate"::timestamp BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate") 
                OR (p."ASA_ToDate"::timestamp BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))
        ) AS "ASA_Class_Attended",
        r."EMGD_Remarks",
        m."EYCES_AplResultFlg" as "EYCES_AplResultFlg2",
        COALESCE(s."ESTMP_TotalObtMarks", 0) as "ESTMP_TotalObtMarks",
        COALESCE(s."ESTMP_Percentage", 0) as "ESTMP_Percentage",
        s."ESTMP_TotalGrade",
        COALESCE(s."ESTMP_ClassRank", 0) as "ESTMP_ClassRank",
        COALESCE(s."ESTMP_SectionRank", 0) as "ESTMP_SectionRank",
        t."EMGD_Remarks" as "ESTMP_TotalGradeRemark",
        COALESCE(s."ESTMP_TotalMaxMarks", 0) as "ESTMP_TotalMaxMarks",
        w."MI_name",
        m."EYCES_SubjectOrder",
        m."EYCES_MarksDisplayFlg",
        m."EYCES_GradeDisplayFlg",
        s."ESTMP_Result",
        f."AMST_RegistrationNo"
    FROM "Adm_M_Student" as f           
    INNER JOIN "Adm_School_Y_Student" as h ON h."AMST_Id" = f."AMST_Id" 
        AND f."AMST_ActiveFlag" = 1 
        AND f."AMST_SOL" = 'S' 
        AND h."AMAY_ActiveFlag" = 1 
        AND h."ASMAY_Id" = p_ASMAY_Id 
        AND h."ASMCL_Id" = p_ASMCL_Id 
        AND h."ASMS_Id" = p_ASMS_Id                          
    INNER JOIN "Exm"."Exm_Category_Class" as j ON j."ASMAY_Id" = p_ASMAY_Id 
        AND j."ASMCL_Id" = p_ASMCL_Id 
        AND j."ASMS_Id" = p_ASMS_Id 
        AND j."MI_Id" = p_MI_Id  
    INNER JOIN "Exm"."Exm_Yearly_Category" as k ON j."EMCA_Id" = k."EMCA_Id" 
        AND k."ASMAY_Id" = p_ASMAY_Id 
        AND k."MI_Id" = p_MI_Id  
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" as l ON l."EYC_Id" = k."EYC_Id" 
        AND l."EME_Id" = p_EME_Id   
    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as m ON m."EYCE_Id" = l."EYCE_Id" 
        AND m."EYCES_ActiveFlg" = 1  
    LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process" as s ON f."AMST_Id" = s."AMST_Id"  
        AND s."ASMCL_Id" = p_ASMCL_Id  
        AND s."ASMS_Id" = p_ASMS_Id 
        AND s."ASMAY_Id" = p_ASMAY_Id 
        AND s."MI_Id" = p_MI_Id 
        AND s."EME_Id" = p_EME_Id  
    LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" as a ON m."ISMS_Id" = a."ISMS_Id" 
        AND f."AMST_Id" = a."AMST_Id" 
        AND a."ASMCL_Id" = p_ASMCL_Id  
        AND a."ASMS_Id" = p_ASMS_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."MI_Id" = p_MI_Id 
        AND a."EME_Id" = p_EME_Id 
    LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" subuj ON subuj."ESTMPS_Id" = a."ESTMPS_Id"
    LEFT OUTER JOIN "Exm"."Exm_Master_SubExam" msubsuj ON msubsuj."EMSE_Id" = subuj."EMSE_Id"
    INNER JOIN "IVRM_Master_Subjects" as d ON m."ISMS_Id" = d."ISMS_Id"  
        AND d."MI_Id" = p_MI_Id     
    INNER JOIN "Adm_School_M_Class" as b ON h."ASMCL_Id" = b."ASMCL_Id" 
        AND b."MI_Id" = p_MI_Id  
    INNER JOIN "Master_Institution" as w ON w.mi_id = p_MI_Id  
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" as r ON m.emgr_id = r.emgr_id 
        AND a."ESTMPS_ObtainedGrade" = r."EMGD_Name"  
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" as t ON l.emgr_id = t.emgr_id 
        AND s."ESTMP_TotalGrade" = t."EMGD_Name"  
    INNER JOIN "Exm"."Exm_Master_Exam" as c ON l."EME_Id" = c."EME_Id" 
        AND c."MI_Id" = p_MI_Id                               
    INNER JOIN "Adm_School_M_Section" as e ON h."ASMS_Id" = e."ASMS_Id" 
        AND e."MI_Id" = p_MI_Id   
    INNER JOIN "Exm"."Exm_Studentwise_Subjects" as n ON n."ISMS_Id" = m."ISMS_Id" 
        AND n."AMST_Id" = f."AMST_Id" 
        AND n."MI_Id" = p_MI_Id 
        AND n."ASMAY_Id" = p_ASMAY_Id 
        AND n."ASMCL_Id" = p_ASMCL_Id 
        AND n."ASMS_Id" = p_ASMS_Id  
    GROUP BY f."AMST_Id", f."AMST_FirstName", f."AMST_MiddleName", f."AMST_LastName", f."AMST_DOB", h."AMAY_RollNo", f."AMST_AdmNo", m."ISMS_Id", d."ISMS_SubjectName", d."ISMS_SubjectCode", m."EYCES_AplResultFlg", m."EYCES_MaxMarks", m."EYCES_MinMarks", m."EMGR_Id", a."ESTMPS_MaxMarks", a."ESTMPS_ClassAverage", a."ESTMPS_SectionAverage", a."ESTMPS_ClassHighest", a."ESTMPS_SectionHighest", a."ESTMPS_ObtainedMarks", a."ESTMPS_ObtainedGrade", a."ESTMPS_PassFailFlg", c."EME_ExamName", b."ASMCL_ClassName", e."ASMC_SectionName", r."EMGD_Remarks", s."ESTMP_TotalObtMarks", s."ESTMP_Percentage", s."ESTMP_TotalGrade", s."ESTMP_ClassRank", s."ESTMP_SectionRank", t."EMGD_Remarks", s."ESTMP_TotalMaxMarks", w."MI_name", m."EYCES_SubjectOrder", m."EYCES_MarksDisplayFlg", m."EYCES_GradeDisplayFlg", s."ESTMP_Result", l."EYCE_AttendanceFromDate", l."EYCE_AttendanceToDate", f."AMST_RegistrationNo", "ESTMPSSS_ObtainedMarks", "EMSE_SubExamName", msubsuj."EMSE_SubExamOrder"
    ORDER BY f."AMST_FirstName", f."AMST_MiddleName", f."AMST_LastName", h."AMAY_RollNo", m."EYCES_SubjectOrder", msubsuj."EMSE_SubExamOrder";
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    RETURN;
END;
$$;