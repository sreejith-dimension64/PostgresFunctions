CREATE OR REPLACE FUNCTION "dbo"."Exam_Slab_Wise_Report"(
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMS_Id BIGINT,
    p_MI_Id BIGINT,
    p_EME_Id BIGINT,
    p_ISMS_ID BIGINT,
    p_FROMMARKS DECIMAL(18,2),
    p_TOMARKS DECIMAL(18,2),
    p_reporttype VARCHAR(50)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR,
    "AMST_DOB" TIMESTAMP,
    "AMAY_RollNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_SubjectCode" VARCHAR,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MaxMarks" DECIMAL,
    "EYCES_MinMarks" DECIMAL,
    "EMGR_Id" BIGINT,
    "ESTMPS_MaxMarks" DECIMAL,
    "ESTMPS_ClassAverage" DECIMAL,
    "ESTMPS_SectionAverage" DECIMAL,
    "ESTMPS_ClassHighest" DECIMAL,
    "ESTMPS_SectionHighest" DECIMAL,
    "ESTMPS_ObtainedMarks" DECIMAL,
    "ESTMPS_ObtainedGrade" VARCHAR,
    "ESTMPS_PassFailFlg" VARCHAR,
    "EME_ExamName" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_ClassHeld" BIGINT,
    "ASA_Class_Attended" BIGINT,
    "EMGD_Remarks" VARCHAR,
    "ESTMP_TotalObtMarks" DECIMAL,
    "ESTMP_Percentage" DECIMAL,
    "ESTMP_TotalGrade" VARCHAR,
    "ESTMP_ClassRank" INTEGER,
    "ESTMP_SectionRank" INTEGER,
    "ESTMP_TotalGradeRemark" VARCHAR,
    "ESTMP_Result" VARCHAR,
    "ESTMP_TotalMaxMarks" DECIMAL,
    "MI_name" VARCHAR,
    "EYCES_SubjectOrder" INTEGER,
    "EMPATY_PaperTypeName" VARCHAR,
    "EMPATY_Color" VARCHAR,
    "studentname" TEXT,
    "ESTMP_Percentage_pct" DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_reporttype = 'Marks' THEN
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
            a."ESTMPS_ObtainedMarks" as "ESTMPS_ObtainedMarks",
            a."ESTMPS_ObtainedGrade",
            a."ESTMPS_PassFailFlg",
            c."EME_ExamName",
            b."ASMCL_ClassName",
            e."ASMC_SectionName",     
            (SELECT SUM(asa_classheld) FROM "Adm_Student_Attendance" p  
             WHERE p.mi_id = p_MI_Id AND p."ASMAY_Id" = p_ASMAY_Id AND p."ASMCL_Id" = p_ASMCL_Id 
             AND p."ASMS_Id" = p_ASMS_Id AND p."ASA_Activeflag" = 1 
             AND ((p."ASA_FromDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")     
             OR (p."ASA_ToDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")))::BIGINT AS "ASA_ClassHeld",    
            (SELECT SUM("ASA_Class_Attended") FROM "Adm_Student_Attendance_Students" q, "Adm_Student_Attendance" p    
             WHERE p."ASA_Id" = q."ASA_Id" AND mi_id = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
             AND "ASA_Activeflag" = 1 AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id 
             AND q."AMST_Id" = f."AMST_Id" AND ((p."ASA_FromDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")     
             OR (p."ASA_ToDate"::TIMESTAMP BETWEEN l."EYCE_AttendanceFromDate" AND l."EYCE_AttendanceToDate")))::BIGINT AS "ASA_Class_Attended",
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
            m."EYCES_SubjectOrder",    
            COALESCE("EMPT"."EMPATY_PaperTypeName", '') AS "EMPATY_PaperTypeName",
            COALESCE("EMPATY_Color", 'black') AS "EMPATY_Color",
            NULL::TEXT as studentname,
            NULL::DECIMAL as "ESTMP_Percentage_pct"
        FROM "Adm_M_Student" f             
        INNER JOIN "Adm_School_Y_Student" h ON h."AMST_Id" = f."AMST_Id" AND "AMAY_ActiveFlag" = 1   
        INNER JOIN "Exm"."Exm_Category_Class" j ON j."ASMAY_Id" = H."ASMAY_Id" AND j."ECAC_ActiveFlag" = 1    
        INNER JOIN "Exm"."Exm_Yearly_Category" k ON j."EMCA_Id" = k."EMCA_Id" AND K."ASMAY_Id" = H."ASMAY_Id" 
            AND K."MI_Id" = F."MI_Id" AND k."EYC_ActiveFlg" = 1    
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" l ON l."EYC_Id" = k."EYC_Id" AND l."EYCE_ActiveFlg" = 1    
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" m ON m."EYCE_Id" = l."EYCE_Id" 
            AND M."EYCES_ActiveFlg" = 1 AND m."EYCES_AplResultFlg" = 1    
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks_Process" s ON f."AMST_Id" = s."AMST_Id" 
            AND S."ASMCL_Id" = H."ASMCL_Id" AND S."ASMAY_Id" = H."ASMAY_Id" AND S."ASMS_Id" = H."ASMS_Id"
            AND S."MI_Id" = K."MI_Id" AND S."MI_Id" = F."MI_Id" AND S."EME_Id" = L."EME_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" a ON m."ISMS_Id" = a."ISMS_Id" 
            AND f."AMST_Id" = a."AMST_Id" AND A."ASMAY_Id" = S."ASMAY_Id" AND A."ASMCL_Id" = S."ASMCL_Id" 
            AND A."ASMS_Id" = S."ASMS_Id" AND A."ISMS_Id" = M."ISMS_Id" AND A."MI_Id" = S."MI_Id" AND A."EME_Id" = S."EME_Id"
        LEFT OUTER JOIN "Exm"."Exm_Master_PaperType" "EMPT" ON "EMPT"."EMPATY_Id" = a."EMPATY_Id" AND "EMPT"."MI_Id" = A."MI_Id" 
        INNER JOIN "IVRM_Master_Subjects" d ON m."ISMS_Id" = d."ISMS_Id" AND d."MI_Id" = A."MI_Id"   
        INNER JOIN "Adm_School_M_Class" b ON h."ASMCL_Id" = b."ASMCL_Id" AND B."MI_Id" = A."MI_Id"
        INNER JOIN "Master_Institution" w ON w.mi_id = A."MI_Id"    
        LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" r ON m.emgr_id = r.emgr_id AND a."ESTMPS_ObtainedGrade" = r."EMGD_Name"    
        LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" t ON l.emgr_id = t.emgr_id AND s."ESTMP_TotalGrade" = t."EMGD_Name"    
        INNER JOIN "Exm"."Exm_Master_Exam" c ON l."EME_Id" = c."EME_Id" AND C."MI_Id" = A."MI_Id" AND c."EME_ActiveFlag" = 1                                
        INNER JOIN "Adm_School_M_Section" e ON h."ASMS_Id" = e."ASMS_Id" AND E."MI_Id" = A."MI_Id"
        INNER JOIN "Exm"."Exm_Student_Marks" n ON n."ISMS_Id" = m."ISMS_Id" AND n."AMST_Id" = f."AMST_Id" 
            AND N."MI_Id" = A."MI_Id" AND N."ASMAY_Id" = A."ASMAY_Id" AND N."ASMCL_Id" = A."ASMCL_Id" AND N."ASMS_Id" = A."ASMS_Id"    
        WHERE h."ASMAY_Id" = p_ASMAY_Id AND h."ASMCL_Id" = p_ASMCL_Id AND h."ASMS_Id" = p_ASMS_Id 
            AND j."ASMAY_Id" = p_ASMAY_Id AND j."ASMCL_Id" = p_ASMCL_Id AND j."ASMS_Id" = p_ASMS_Id AND j."MI_Id" = p_MI_Id 
            AND k."ASMAY_Id" = p_ASMAY_Id AND k."MI_Id" = p_MI_Id AND l."EME_Id" = p_EME_Id 
            AND s."ASMCL_Id" = p_ASMCL_Id AND s."ASMS_Id" = p_ASMS_Id AND s."ASMAY_Id" = p_ASMAY_Id 
            AND s."MI_Id" = p_MI_Id AND s."EME_Id" = p_EME_Id 
            AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = p_ASMS_Id AND A."ISMS_Id" = p_ISMS_ID
            AND a."ASMAY_Id" = p_ASMAY_Id AND a."MI_Id" = p_MI_Id AND a."EME_Id" = p_EME_Id 
            AND n."ASMAY_Id" = p_ASMAY_Id AND n."ASMCL_Id" = p_ASMCL_Id AND n."ASMS_Id" = p_ASMS_Id 
            AND a."ESTMPS_ObtainedMarks" BETWEEN p_FROMMARKS AND p_TOMARKS
        ORDER BY h."AMAY_RollNo", m."EYCES_SubjectOrder";
        
    ELSIF p_reporttype = 'Percentage' THEN
        RETURN QUERY
        WITH amst_id_table AS (
            SELECT ADM."AMST_Id" 
            FROM "Adm_M_Student" ADM 
            INNER JOIN "Adm_School_Y_Student" AYS ON ADM."AMST_Id" = AYS."AMST_Id"
            WHERE AYS.asmay_id = p_ASMAY_Id AND AYS.asmcl_id = p_ASMCL_Id 
                AND AYS.asms_id = p_ASMS_Id AND ADM."MI_ID" = p_MI_Id
        )
        SELECT 
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::TIMESTAMP,
            NULL::VARCHAR,
            NULL::VARCHAR,
            ADM."AMST_RegistrationNo",
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::BOOLEAN,
            NULL::DECIMAL,
            NULL::DECIMAL,
            NULL::BIGINT,
            NULL::DECIMAL,
            NULL::DECIMAL,
            NULL::DECIMAL,
            NULL::DECIMAL,
            NULL::DECIMAL,
            NULL::DECIMAL,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::DECIMAL,
            NULL::DECIMAL,
            NULL::VARCHAR,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::DECIMAL,
            NULL::VARCHAR,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR,
            CONCAT(COALESCE(ADM."AMST_FirstName", ' '), ' ', COALESCE(ADM."AMST_MiddleName", ' '), ' ', COALESCE(ADM."AMST_LastName", ' ')) as studentname,
            EMP."ESTMP_Percentage"
        FROM "Adm_M_Student" ADM 
        INNER JOIN "Adm_School_Y_Student" AYS ON ADM."AMST_Id" = AYS."AMST_Id"
        INNER JOIN "Exm".exm_student_marks_process EMP ON ADM."AMST_Id" = EMP."AMST_Id"
        INNER JOIN amst_id_table amst ON EMP."AMST_Id" = amst."AMST_Id"
        WHERE AYS.asmay_id = p_ASMAY_Id AND AYS.asmcl_id = p_ASMCL_Id AND AYS.asms_id = p_ASMS_Id 
            AND EMP."EME_Id" = p_EME_Id AND EMP."ESTMP_Percentage" BETWEEN p_FROMMARKS AND p_TOMARKS;
    END IF;
END;
$$;