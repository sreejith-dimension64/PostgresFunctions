CREATE OR REPLACE FUNCTION "dbo"."Exam_cumulative_BB_Report_Elective"(
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_MI_Id bigint,
    p_EME_Id bigint
)
RETURNS TABLE (
    "AMST_Id" bigint,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR,
    "AMST_DOB" TIMESTAMP,
    "AMAY_RollNo" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_SubjectCode" VARCHAR,
    "EYCES_AplResultFlg" INTEGER,
    "EYCES_MaxMarks" NUMERIC,
    "EYCES_MinMarks" NUMERIC,
    "EMGR_Id" bigint,
    "ESTMPS_MaxMarks" NUMERIC,
    "ESTMPS_ClassAverage" NUMERIC,
    "ESTMPS_SectionAverage" NUMERIC,
    "ESTMPS_ClassHighest" NUMERIC,
    "ESTMPS_SectionHighest" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_ObtainedGrade" VARCHAR,
    "ESTMPS_PassFailFlg" VARCHAR,
    "EME_ExamName" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_ClassHeld" NUMERIC,
    "ASA_Class_Attended" NUMERIC,
    "EMGD_Remarks" VARCHAR,
    "EYCES_AplResultFlg_2" INTEGER,
    "ESTMP_TotalObtMarks" NUMERIC,
    "ESTMP_Percentage" NUMERIC,
    "ESTMP_TotalGrade" VARCHAR,
    "ESTMP_ClassRank" INTEGER,
    "ESTMP_SectionRank" INTEGER,
    "ESTMP_TotalGradeRemark" VARCHAR,
    "ESTMP_TotalMaxMarks" NUMERIC,
    "MI_name" VARCHAR,
    "EYCES_SubjectOrder" INTEGER
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
        (SELECT sum(asa_classheld) FROM "Adm_Student_Attendance" p 
         WHERE mi_id = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id
         AND "ASMCL_Id" = p_ASMCL_Id AND asms_id = p_ASMS_Id AND "ASA_Activeflag" = 1 
         AND ((p."ASA_FromDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate") 
         OR (p."ASA_ToDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))) AS "ASA_ClassHeld",
        (SELECT sum("ASA_Class_Attended") FROM "Adm_Student_Attendance_Students" q, "Adm_Student_Attendance" AS p
         WHERE p."ASA_Id" = q."ASA_Id" AND mi_id = p_MI_Id AND "ASA_Activeflag" = 1 
         AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id AND asms_id = p_ASMS_Id 
         AND q."AMST_Id" = f."AMST_Id" 
         AND ((p."ASA_FromDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate") 
         OR (p."ASA_ToDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))) AS "ASA_Class_Attended",
        r."EMGD_Remarks",
        m."EYCES_AplResultFlg" as "EYCES_AplResultFlg_2",
        COALESCE(s."ESTMP_TotalObtMarks", 0) as "ESTMP_TotalObtMarks",
        COALESCE(s."ESTMP_Percentage", 0) as "ESTMP_Percentage",
        s."ESTMP_TotalGrade",
        COALESCE(s."ESTMP_ClassRank", 0) as "ESTMP_ClassRank",
        COALESCE(s."ESTMP_SectionRank", 0) as "ESTMP_SectionRank",
        t."EMGD_Remarks" as "ESTMP_TotalGradeRemark",
        COALESCE(s."ESTMP_TotalMaxMarks", 0) as "ESTMP_TotalMaxMarks",
        w."MI_name",
        m."EYCES_SubjectOrder"
    FROM "Adm_M_Student" AS f         
    INNER JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
        AND f."AMST_ActiveFlag" IN (0, 1) 
        AND f."AMST_SOL" IN ('L', 'S') 
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
        AND m."EYCES_ActiveFlg" = 1 
        AND m."EYCES_AplResultFlg" = 0
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
    INNER JOIN "Master_Institution" AS w ON w.mi_id = p_MI_Id
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS r ON m.emgr_id = r.emgr_id 
        AND a."ESTMPS_ObtainedGrade" = r."EMGD_Name"
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS t ON l.emgr_id = t.emgr_id 
        AND s."ESTMP_TotalGrade" = t."EMGD_Name"
    INNER JOIN "Exm"."Exm_Master_Exam" AS c ON l."EME_Id" = c."EME_Id" 
        AND c."MI_Id" = p_MI_Id                             
    INNER JOIN "Adm_School_M_Section" AS e ON h."ASMS_Id" = e."ASMS_Id" 
        AND e."MI_Id" = p_MI_Id 
    GROUP BY 
        f."AMST_Id", f."AMST_FirstName", f."AMST_MiddleName", f."AMST_LastName", f."AMST_DOB", 
        h."AMAY_RollNo", f."AMST_AdmNo", f."AMST_RegistrationNo", m."ISMS_Id", d."ISMS_SubjectName", 
        d."ISMS_SubjectCode", m."EYCES_AplResultFlg", m."EYCES_MaxMarks", m."EYCES_MinMarks", m."EMGR_Id", 
        a."ESTMPS_MaxMarks", a."ESTMPS_ClassAverage", a."ESTMPS_SectionAverage", a."ESTMPS_ClassHighest", 
        a."ESTMPS_SectionHighest", a."ESTMPS_ObtainedMarks", a."ESTMPS_ObtainedGrade", a."ESTMPS_PassFailFlg", 
        c."EME_ExamName", b."ASMCL_ClassName", e."ASMC_SectionName", r."EMGD_Remarks", s."ESTMP_TotalObtMarks", 
        s."ESTMP_Percentage", s."ESTMP_TotalGrade", s."ESTMP_ClassRank", s."ESTMP_SectionRank", t."EMGD_Remarks", 
        s."ESTMP_TotalMaxMarks", w."MI_name", m."EYCES_SubjectOrder", l."EYCE_AttendanceFromDate", 
        l."EYCE_AttendanceToDate"
    ORDER BY 
        h."AMAY_RollNo", m."EYCES_SubjectOrder" ASC;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

END;
$$;