CREATE OR REPLACE FUNCTION "dbo"."Exam_get_BB_Exam_Details_New_Aug"(
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_MI_Id bigint,
    p_EME_Id bigint,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FatherName" varchar,
    "AMST_MotherName" varchar,
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
    "SPCCMH_HouseName" varchar,
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
    "stu_grandmin_marks" numeric,
    "AMST_Photoname" varchar,
    "ESTMP_QRCode" varchar,
    "ASMCL_ClassCode" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQLQUERY TEXT;
    v_ExmConfig_LeftStuFlag boolean;
BEGIN
    DROP TABLE IF EXISTS "Baldwin_Temp_StudentDetails_Amstids";
    
    v_SQLQUERY := 'CREATE TEMP TABLE "Baldwin_Temp_StudentDetails_Amstids" AS SELECT DISTINCT "AMST_Id" FROM "ADM_M_STUDENT" WHERE "AMST_Id" IN(' || p_AMST_Id || ')';
    EXECUTE v_SQLQUERY;
    
    v_ExmConfig_LeftStuFlag := false;
    
    SELECT "ExmConfig_LeftStuFlag" INTO v_ExmConfig_LeftStuFlag 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id;
    
    IF (v_ExmConfig_LeftStuFlag = false) THEN
        RETURN QUERY
        SELECT DISTINCT 
            f."AMST_Id",
            f."AMST_FatherName",
            f."AMST_MotherName",
            f."AMST_FirstName",
            f."AMST_MiddleName",
            f."AMST_LastName",
            f."AMST_DOB",
            COALESCE(h."AMAY_RollNo", ' ') as "AMAY_RollNo",
            f."AMST_AdmNo",
            m."ISMS_Id",
            d."ISMS_SubjectName",
            d."ISMS_SubjectCode",
            m."EYCES_AplResultFlg",
            m."EYCES_MaxMarks",
            m."EYCES_MinMarks",
            m."EMGR_Id",
            COALESCE(a."ESTMPS_MaxMarks", 0) as "ESTMPS_MaxMarks",
            COALESCE(SPH."SPCCMH_HouseName", '') as "SPCCMH_HouseName",
            COALESCE(a."ESTMPS_ClassAverage", 0) as "ESTMPS_ClassAverage",
            COALESCE(a."ESTMPS_SectionAverage", 0) as "ESTMPS_SectionAverage",
            ROUND(COALESCE(a."ESTMPS_ClassHighest", 0), 0) as "ESTMPS_ClassHighest",
            ROUND(COALESCE(a."ESTMPS_SectionHighest", 0), 0) as "ESTMPS_SectionHighest",
            COALESCE(a."ESTMPS_ObtainedMarks", null) as "ESTMPS_ObtainedMarks",
            a."ESTMPS_ObtainedGrade",
            a."ESTMPS_PassFailFlg",
            c."EME_ExamName",
            COALESCE(b."ASMCL_ClassName", ' ') as "ASMCL_ClassName",
            COALESCE(e."ASMC_SectionName", ' ') as "ASMC_SectionName",
            (SELECT sum(p."asa_classheld") FROM "Adm_Student_Attendance" p 
             WHERE p."mi_id" = p_MI_Id AND p."ASMAY_Id" = p_ASMAY_Id
             AND p."ASMCL_Id" = p_ASMCL_Id AND p."ASA_Activeflag" = true AND p."ASMS_Id" = p_ASMS_Id
             AND ((TO_DATE(p."ASA_FromDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")
             OR (TO_DATE(p."ASA_ToDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))) AS "ASA_ClassHeld",
            (SELECT sum(q."ASA_Class_Attended") FROM "Adm_Student_Attendance_Students" q, "Adm_Student_Attendance" as p
             WHERE p."ASA_Id" = q."ASA_Id" AND p."mi_id" = p_MI_Id AND p."ASMAY_Id" = p_ASMAY_Id 
             AND p."ASA_Activeflag" = true AND p."ASMCL_Id" = p_ASMCL_Id AND p."ASMS_Id" = p_ASMS_Id 
             AND q."AMST_Id" = f."AMST_Id"
             AND ((TO_DATE(p."ASA_FromDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")
             OR (TO_DATE(p."ASA_ToDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))) AS "ASA_Class_Attended",
            r."EMGD_Remarks",
            m."EYCES_AplResultFlg",
            COALESCE(s."ESTMP_TotalObtMarks", null) as "ESTMP_TotalObtMarks",
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
            (SELECT COALESCE(SUM(Eyck."EYCES_MinMarks"), 0) FROM "Exm"."Exm_Category_Class" as sub
             INNER JOIN "Adm_School_Y_Student" std ON sub."ASMAY_Id" = std."ASMAY_Id" AND sub."ASMCL_Id" = std."ASMCL_Id" 
             AND sub."ASMS_Id" = std."ASMS_Id" AND sub."ASMAY_Id" = p_ASMAY_Id
             AND std."ASMCL_Id" = p_ASMCL_Id AND std."ASMS_Id" = p_ASMS_Id
             INNER JOIN "Exm"."Exm_Yearly_Category" exc ON sub."EMCA_Id" = exc."EMCA_Id" AND exc."ASMAY_Id" = p_ASMAY_Id AND exc."EYC_ActiveFlg" = true
             INNER JOIN "Exm"."Exm_Yearly_Category_Exams" as eyc ON eyc."EYC_Id" = exc."EYC_Id" AND eyc."EME_Id" = p_EME_Id AND eyc."EYCE_ActiveFlg" = true
             INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as Eyck ON eyc."EYCE_Id" = Eyck."EYCE_Id" AND Eyck."EYCES_AplResultFlg" = true AND eyck."EYCES_ActiveFlg" = true
             AND std."AMST_Id" = f."AMST_Id" AND std."ASMAY_Id" = p_ASMAY_Id 
             AND Eyck."ISMS_Id" IN (SELECT "ISMS_Id" FROM "Exm"."Exm_Student_Marks" WHERE "AMST_Id" = std."AMST_Id" 
                                    AND "ASMAY_Id" = p_ASMAY_Id AND "EME_Id" = p_EME_Id AND "ASMS_Id" = p_ASMS_Id AND "ASMCL_Id" = p_ASMCL_Id)) as "stu_grandmin_marks",
            f."AMST_Photoname",
            b."ASMCL_ClassCode" AS "ESTMP_QRCode",
            b."ASMCL_ClassCode"
        FROM "Adm_M_Student" as f
        INNER JOIN "Adm_School_Y_Student" as h ON h."AMST_Id" = f."AMST_Id"
        INNER JOIN "Baldwin_Temp_StudentDetails_Amstids" BDN ON BDN."AMST_Id" = h."AMST_Id" AND BDN."AMST_Id" = f."AMST_Id"
        AND f."AMST_ActiveFlag" = true AND f."AMST_SOL" = 'S' AND h."AMAY_ActiveFlag" = true
        AND h."ASMAY_Id" = p_ASMAY_Id AND h."ASMCL_Id" = p_ASMCL_Id AND h."ASMS_Id" = p_ASMS_Id
        INNER JOIN "Exm"."Exm_Category_Class" as j ON j."ASMAY_Id" = p_ASMAY_Id AND j."ASMCL_Id" = p_ASMCL_Id 
        AND j."ASMS_Id" = p_ASMS_Id AND j."MI_Id" = p_MI_Id AND j."ECAC_ActiveFlag" = true
        INNER JOIN "Exm"."Exm_Yearly_Category" as k ON j."EMCA_Id" = k."EMCA_Id" AND k."ASMAY_Id" = p_ASMAY_Id 
        AND k."MI_Id" = p_MI_Id AND k."EYC_ActiveFlg" = true
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" as l ON l."EYC_Id" = k."EYC_Id" AND l."EME_Id" = p_EME_Id AND l."EYCE_ActiveFlg" = true
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as m ON m."EYCE_Id" = l."EYCE_Id" AND m."EYCES_ActiveFlg" = true
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process" as s ON f."AMST_Id" = s."AMST_Id" AND s."ASMCL_Id" = p_ASMCL_Id 
        AND s."ASMS_Id" = p_ASMS_Id AND s."ASMAY_Id" = p_ASMAY_Id AND s."MI_Id" = p_MI_Id AND s."EME_Id" = p_EME_Id
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" as a ON m."ISMS_Id" = a."ISMS_Id" AND f."AMST_Id" = a."AMST_Id" 
        AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = p_ASMS_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."MI_Id" = p_MI_Id AND a."EME_Id" = p_EME_Id
        INNER JOIN "IVRM_Master_Subjects" as d ON m."ISMS_Id" = d."ISMS_Id" AND d."MI_Id" = p_MI_Id AND m."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "Adm_School_M_Class" as b ON h."ASMCL_Id" = b."ASMCL_Id" AND b."MI_Id" = p_MI_Id
        INNER JOIN "Master_Institution" as w ON w."mi_id" = p_MI_Id
        LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" as r ON m."emgr_id" = r."emgr_id" AND a."ESTMPS_ObtainedGrade" = r."EMGD_Name"
        LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" as t ON l."emgr_id" = t."emgr_id" AND s."ESTMP_TotalGrade" = t."EMGD_Name"
        INNER JOIN "Exm"."Exm_Master_Exam" as c ON l."EME_Id" = c."EME_Id" AND c."MI_Id" = p_MI_Id AND c."EME_ActiveFlag" = true
        INNER JOIN "Adm_School_M_Section" as e ON h."ASMS_Id" = e."ASMS_Id" AND e."MI_Id" = p_MI_Id
        INNER JOIN "Exm"."Exm_Studentwise_Subjects" as n ON n."ISMS_Id" = m."ISMS_Id" AND n."AMST_Id" = f."AMST_Id" 
        AND n."MI_Id" = p_MI_Id AND n."ASMAY_Id" = p_ASMAY_Id
        LEFT JOIN "SPC"."SPCC_Student_House" SPT ON spt."AMST_Id" = h."AMST_Id" AND SPT."ASMAY_Id" = h."ASMAY_Id" 
        AND SPT."ASMCL_Id" = h."ASMCL_Id" AND SPT."ASMS_Id" = h."ASMS_Id" AND SPT."ASMAY_Id" = p_ASMAY_Id
        AND SPT."ASMCL_Id" = p_ASMCL_Id AND SPT."ASMS_Id" = p_ASMS_Id
        LEFT JOIN "SPC"."SPCC_Master_House" SPH ON SPH."SPCCMH_Id" = SPT."SPCCMH_Id" AND SPH."MI_Id" = p_MI_Id
        GROUP BY f."AMST_Id", f."AMST_FatherName", f."AMST_MotherName", f."AMST_FirstName", f."AMST_MiddleName", f."AMST_LastName", 
        f."AMST_DOB", h."AMAY_RollNo", f."AMST_AdmNo", m."ISMS_Id", d."ISMS_SubjectName", d."ISMS_SubjectCode", m."EYCES_AplResultFlg", 
        m."EYCES_MaxMarks", m."EYCES_MinMarks", m."EMGR_Id", a."ESTMPS_MaxMarks", a."ESTMPS_ClassAverage", a."ESTMPS_SectionAverage", 
        a."ESTMPS_ClassHighest", a."ESTMPS_SectionHighest", a."ESTMPS_ObtainedMarks", a."ESTMPS_ObtainedGrade", a."ESTMPS_PassFailFlg", 
        c."EME_ExamName", b."ASMCL_ClassName", e."ASMC_SectionName", r."EMGD_Remarks", s."ESTMP_TotalObtMarks", s."ESTMP_Percentage", 
        s."ESTMP_TotalGrade", s."ESTMP_ClassRank", s."ESTMP_SectionRank", t."EMGD_Remarks", s."ESTMP_TotalMaxMarks", w."MI_name", 
        m."EYCES_SubjectOrder", m."EYCES_MarksDisplayFlg", m."EYCES_GradeDisplayFlg", s."ESTMP_Result", l."EYCE_AttendanceFromDate", 
        l."EYCE_AttendanceToDate", SPH."SPCCMH_HouseName", f."AMST_Photoname", b."ASMCL_ClassCode"
        ORDER BY f."AMST_FirstName", f."AMST_MiddleName", f."AMST_LastName", m."EYCES_SubjectOrder" ASC;
    ELSE
        IF (v_ExmConfig_LeftStuFlag = true) THEN
            RETURN QUERY
            SELECT 
                f."AMST_Id",
                f."AMST_FatherName",
                f."AMST_MotherName",
                f."AMST_FirstName",
                f."AMST_MiddleName",
                f."AMST_LastName",
                f."AMST_DOB",
                COALESCE(h."AMAY_RollNo", ' ') as "AMAY_RollNo",
                f."AMST_AdmNo",
                m."ISMS_Id",
                d."ISMS_SubjectName",
                d."ISMS_SubjectCode",
                m."EYCES_AplResultFlg",
                m."EYCES_MaxMarks",
                m."EYCES_MinMarks",
                m."EMGR_Id",
                COALESCE(a."ESTMPS_MaxMarks", 0) as "ESTMPS_MaxMarks",
                COALESCE(SPH."SPCCMH_HouseName", '') as "SPCCMH_HouseName",
                COALESCE(a."ESTMPS_ClassAverage", 0) as "ESTMPS_ClassAverage",
                COALESCE(a."ESTMPS_SectionAverage", 0) as "ESTMPS_SectionAverage",
                ROUND(COALESCE(a."ESTMPS_ClassHighest", 0), 0) as "ESTMPS_ClassHighest",
                ROUND(COALESCE(a."ESTMPS_SectionHighest", 0), 0) as "ESTMPS_SectionHighest",
                COALESCE(a."ESTMPS_ObtainedMarks", null) as "ESTMPS_ObtainedMarks",
                a."ESTMPS_ObtainedGrade",
                a."ESTMPS_PassFailFlg",
                c."EME_ExamName",
                COALESCE(b."ASMCL_ClassName", ' ') as "ASMCL_ClassName",
                COALESCE(e."ASMC_SectionName", ' ') as "ASMC_SectionName",
                (SELECT sum(p."asa_classheld") FROM "Adm_Student_Attendance" p 
                 WHERE p."mi_id" = p_MI_Id AND p."ASMAY_Id" = p_ASMAY_Id
                 AND p."ASMCL_Id" = p_ASMCL_Id AND p."ASA_Activeflag" = true AND p."ASMS_Id" = p_ASMS_Id
                 AND ((TO_DATE(p."ASA_FromDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")
                 OR (TO_DATE(p."ASA_ToDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))) AS "ASA_ClassHeld",
                (SELECT sum(q."ASA_Class_Attended") FROM "Adm_Student_Attendance_Students" q, "Adm_Student_Attendance" as p
                 WHERE p."ASA_Id" = q."ASA_Id" AND p."mi_id" = p_MI_Id AND p."ASMAY_Id" = p_ASMAY_Id 
                 AND p."ASA_Activeflag" = true AND p."ASMCL_Id" = p_ASMCL_Id AND p."ASMS_Id" = p_ASMS_Id 
                 AND q."AMST_Id" = f."AMST_Id"
                 AND ((TO_DATE(p."ASA_FromDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")
                 OR (TO_DATE(p."ASA_ToDate", 'DD/MM/YYYY') BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate"))) AS "ASA_Class_Attended",
                r."EMGD_Remarks",
                m."EYCES_AplResultFlg",
                COALESCE(s."ESTMP_TotalObtMarks", null) as "ESTMP_TotalObtMarks",
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
                (SELECT COALESCE(SUM(Eyck."EYCES_MinMarks"), 0) FROM "Exm"."Exm_Category_Class" as sub
                 INNER JOIN "Adm_School_Y_Student" std ON sub."ASMAY_Id" = std."ASMAY_Id" AND sub."ASMCL_Id" = std."ASMCL_Id" 
                 AND sub."ASMS_Id" = std."ASMS_Id" AND sub."ASMAY_Id" = p_ASMAY_Id
                 AND std."ASMCL_Id" = p_ASMCL_Id AND std."ASMS_Id" = p_ASMS_Id
                 INNER JOIN "Exm"."Exm_Yearly_Category" exc ON sub."EMCA_Id" = exc."EMCA_Id" AND exc."ASMAY_Id" = p_ASMAY_Id AND exc."EYC_ActiveFlg" = true
                 INNER JOIN "Exm"."Exm_Yearly_Category_Exams" as eyc ON eyc."EYC_Id" = exc."EYC_Id" AND eyc."EME_Id" = p_EME_Id AND eyc."EYCE_ActiveFlg" = true
                 INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as Eyck ON eyc."EYCE_Id" = Eyck."EYCE_Id" AND Eyck."EYCES_AplResultFlg" = true AND eyck."EYCES_ActiveFlg" = true
                 AND std."AMST_Id" = f."AMST_Id" AND std."ASMAY_Id" = p_ASMAY_Id 
                 AND Eyck."ISMS_Id" IN (SELECT "ISMS_Id" FROM "Exm"."Exm_Student_Marks" WHERE "AMST_Id" = std."AMST_Id" 
                                        AND "ASMAY_Id" = p_ASMAY_Id AND "EME_Id" = p_EME_Id AND "ASMS_Id" = p_ASMS_Id AND "ASMCL_Id" = p_ASMCL_Id)) as "stu_grandmin_marks",
                f."AMST_Photoname",
                s."ESTMP_QRCode",
                b."ASMCL_ClassCode"
            FROM "Adm_M_Student" as f
            INNER JOIN "Adm_School_Y_Student" as h ON h."AMST_Id" = f."AMST_Id"
            INNER JOIN "Baldwin_Temp_StudentDetails_Amstids" BDN ON BDN."AMST_Id" = h."AMST_Id" AND BDN."AMST_Id" = f."AMST_Id"
            AND h."ASMAY_Id" = p_ASMAY_Id AND h."ASMCL_Id" = p_ASMCL_Id AND h."ASMS_Id" = p_ASMS_Id
            INNER JOIN "Exm"."Exm_Category_Class" as j ON j."ASMAY_Id" = p_ASMAY_Id AND j."ASMCL_Id" = p_ASMCL_Id 
            AND j."ASMS_Id" = p_ASMS_Id AND j."MI_Id" = p_MI_Id AND j."ECAC_ActiveFlag" = true
            INNER JOIN "Exm"."Exm_Yearly_Category" as k ON j."EMCA_Id" = k."EMCA_Id" AND k."ASMAY_Id" = p_ASMAY_Id 
            AND k."MI_Id" = p_MI_Id AND k."EYC_ActiveFlg" = true
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" as l ON l."EYC_Id" = k."EYC_Id" AND l."EME_Id" = p_EME_Id AND l."EYCE_ActiveFlg" = true
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as m ON m."EYCE_Id" = l."EYCE_Id" AND m."EYCES_ActiveFlg" = true
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process" as s ON f."AMST_Id" = s."AMST_Id" AND s."ASMCL_Id" = p_ASMCL_Id 
            AND s."ASMS_Id" = p_ASMS_Id AND s."ASMAY_Id" = p_ASMAY_Id AND s."MI_Id" = p_MI_Id AND s."EME_Id" = p_EME_Id
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" as a ON m."ISMS_Id" = a."ISMS_Id" AND f."AMST_Id" = a."AMST_Id" 
            AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = p_ASMS_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."MI_Id" = p_MI_Id AND a."EME_Id" = p_EME_Id
            INNER JOIN "IVRM_Master_Subjects" as d ON m."ISMS_Id" = d."ISMS_Id" AND d."MI_Id" = p_MI_Id AND m."ISMS_Id" = a."ISMS_Id"
            INNER JOIN "Adm_School_M_Class" as b ON h."ASMCL_Id" = b."ASMCL_Id" AND b."MI_Id" = p_MI_Id
            INNER JOIN "Master_Institution" as w ON w."mi_id" = p_MI_Id
            LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" as r ON m."emgr_id" = r."emgr_id" AND a."ESTMPS_ObtainedGrade" = r."EMGD_Name"
            LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" as t ON l."emgr_id" = t."emgr_id" AND s."ESTMP_TotalGrade" = t."EMGD_Name"
            INNER JOIN "Exm"."Exm_