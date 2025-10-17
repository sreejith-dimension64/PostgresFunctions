CREATE OR REPLACE FUNCTION "dbo"."exm_subject_wise_report1"(
    p_ASMAY_ID TEXT,
    p_MI_id TEXT,
    p_ASMCL_id TEXT,
    p_ASMS_id TEXT,
    p_AMST_ID TEXT,
    p_EME_id TEXT
)
RETURNS TABLE (
    "AMST_Id" INTEGER,
    "studentname" TEXT,
    "ISMS_Id" INTEGER,
    "ISMS_SubjectName" TEXT,
    "ISMS_SubjectCode" TEXT,
    "EME_ExamName" TEXT,
    "EYCES_AplResultFlg" TEXT,
    "EYCES_MaxMarks" NUMERIC,
    "EYCES_MinMarks" NUMERIC,
    "ESTMPS_ClassAverage" NUMERIC,
    "ESTMPS_SectionAverage" NUMERIC,
    "ESTMPS_ClassHighest" NUMERIC,
    "ESTMPS_SectionHighest" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_ObtainedGrade" TEXT,
    "ESTMPS_PassFailFlg" TEXT,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_MarksDisplayFlg" TEXT,
    "EYCES_GradeDisplayFlg" TEXT,
    "classrank" TEXT,
    "sectionrank" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT DISTINCT "ADM"."AMST_Id",
        (COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''')) AS studentname,
        "EYCES"."ISMS_Id",
        "IMS"."ISMS_SubjectName",
        "IMS"."ISMS_SubjectCode",
        "EME"."EME_ExamName",
        "EYCES"."EYCES_AplResultFlg",
        "EYCES"."EYCES_MaxMarks",
        "EYCES"."EYCES_MinMarks",
        "ESMTMPS"."ESTMPS_ClassAverage",
        "ESMTMPS"."ESTMPS_SectionAverage",
        "ESMTMPS"."ESTMPS_ClassHighest",
        "ESMTMPS"."ESTMPS_SectionHighest",
        "ESMTMPS"."ESTMPS_ObtainedMarks",
        "ESMTMPS"."ESTMPS_ObtainedGrade",
        "ESMTMPS"."ESTMPS_PassFailFlg",
        "EYCES"."EYCES_SubjectOrder",
        "EYCES"."EYCES_MarksDisplayFlg",
        "EYCES"."EYCES_GradeDisplayFlg",
        COALESCE("ESMTMPS"."ESTMPS_ClassRank",'''')::TEXT AS classrank,
        COALESCE("ESMTMPS"."ESTMPS_SectionRank",'''')::TEXT AS sectionrank
    FROM "Adm_M_Student" "ADM"
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ADM"."AMST_Id" = "ASYS"."AMST_id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id"
    INNER JOIN "exm"."Exm_Category_Class" "ECC" ON "ECC"."ASMAY_Id" = "ASMAY"."ASMAY_Id" 
        AND "ECC"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
        AND "ECC"."ECAC_ActiveFlag" = 1 
        AND "ECC"."asms_id" = "ASYS"."asms_id" 
        AND "ECC"."asmcl_id" = "ASYS"."asmcl_id"
    LEFT JOIN "EXM"."Exm_Master_Category" "EMC" ON "ECC"."EMCA_Id" = "EMC"."EMCA_Id" 
        AND "EMC"."mi_id" = "ADM"."Mi_id"
    INNER JOIN "exm"."Exm_Yearly_Category" "EYC" ON "EYC"."EMCA_Id" = "EMC"."EMCA_Id" 
        AND "EYC"."ASMAY_Id" = "ASMAY"."ASMAY_Id"
    INNER JOIN "exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id" 
        AND "EYCE"."EYCE_ActiveFlg" = 1
    INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
        AND "EYCES"."EYCES_ActiveFlg" = 1 
        AND "EYCES"."EYCES_ActiveFlg" = 1
    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMTMPS" ON "ESMTMPS"."ISMS_Id" = "EYCES"."isms_id"
    LEFT JOIN "exm"."Exm_Master_Exam" "EME" ON "EME"."EME_Id" = "ESMTMPS"."EME_ID" 
        AND "EYCE"."EME_Id" = "EME"."EME_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_ID" = "EYCES"."ISMS_Id"
    INNER JOIN "Adm_School_M_Class" "CLS" ON "ASYS"."ASMCL_Id" = "CLS"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "SEC" ON "SEC"."ASMS_id" = "ESMTMPS"."ASMS_ID"
    INNER JOIN "Exm"."Exm_Studentwise_Subjects" "ESS" ON "ESS"."ISMS_Id" = "ESMTMPS"."ISMS_Id" 
        AND "ESS"."AMST_Id" = "ADM"."AMST_Id" 
        AND "ESS"."asms_id" = "SEC"."asms_id" 
        AND "ESS"."asmcl_id" = "CLS"."asmcl_id"
        AND "ESS"."ASmay_id" = "ASmay"."ASmay_id"
    INNER JOIN "Exm"."exm_master_group" "EMG" ON "ESS"."emg_id" = "EMG"."emg_id"
    WHERE "ADM"."AMST_ActiveFlag" = 1 
        AND "ADM"."AMST_SOL" = ''S'' 
        AND "ASYS"."AMAY_ActiveFlag" = 1
        AND "ASYS"."ASMAY_Id" = ' || p_ASMAY_ID || '
        AND "ASYS"."ASMCL_Id" = ' || p_ASMCL_id || '
        AND "ASYS"."ASMS_Id" = ' || p_ASMS_id || '
        AND "ESMTMPS"."ASMCL_Id" = ' || p_ASMCL_id || '
        AND "ESMTMPS"."ASMS_Id" = ' || p_ASMS_id || '
        AND "ESMTMPS"."ASMAY_Id" = ' || p_ASMAY_ID || '
        AND "ESMTMPS"."MI_Id" = ' || p_MI_id || '
        AND "EME"."eme_id" IN (' || p_EME_id || ')
        AND "SEC"."MI_id" = ' || p_MI_id || '
        AND "ESS"."MI_Id" = ' || p_MI_id || '
        AND "ESS"."ASMAY_Id" = ' || p_ASMAY_ID || '
        AND "ESS"."ASMCL_Id" = ' || p_ASMCL_id || '
        AND "ESS"."ASMS_Id" = ' || p_ASMS_id || '
        AND "ESS"."ESTSU_ActiveFlg" = 1
        AND "ASYS"."AMST_Id" IN (' || p_AMST_ID || ')
        AND "ADM"."AMST_Id" IN (' || p_AMST_ID || ')
    GROUP BY "ADM"."AMST_Id",
        (COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''')),
        "EYCES"."ISMS_Id",
        "IMS"."ISMS_SubjectName",
        "IMS"."ISMS_SubjectCode",
        "EME"."EME_ExamName",
        "EYCES"."EYCES_AplResultFlg",
        "EYCES"."EYCES_MaxMarks",
        "EYCES"."EYCES_MinMarks",
        "ESMTMPS"."ESTMPS_ClassAverage",
        "ESMTMPS"."ESTMPS_SectionAverage",
        "ESMTMPS"."ESTMPS_ClassHighest",
        "ESMTMPS"."ESTMPS_SectionHighest",
        "ESMTMPS"."ESTMPS_ObtainedMarks",
        "ESMTMPS"."ESTMPS_ObtainedGrade",
        "ESMTMPS"."ESTMPS_PassFailFlg",
        "EYCES"."EYCES_SubjectOrder",
        "EYCES"."EYCES_MarksDisplayFlg",
        "EYCES"."EYCES_GradeDisplayFlg",
        "ESMTMPS"."ESTMPS_ClassRank",
        "ESMTMPS"."ESTMPS_SectionRank"';

    RETURN QUERY EXECUTE v_sql;
END;
$$;