CREATE OR REPLACE FUNCTION "dbo"."Exam_TimeTable_Generation"(
    p_MI_Id bigint,
    p_Flag VARCHAR(50),
    p_ASMAY_Id BIGINT,
    p_AMCO_Id BIGINT,
    p_AMB_Id BIGINT,
    p_AMSE_Id BIGINT,
    p_ACMS_Id BIGINT,
    p_EME_Id BIGINT,
    p_AMCST_Id TEXT
)
RETURNS TABLE(
    "EXTTC_Id" bigint,
    "ASMAY_Year" varchar,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "AMSE_SEMName" varchar,
    "EME_ExamName" varchar,
    "ASMAY_Id" bigint,
    "AMCO_Id" bigint,
    "AMB_Id" bigint,
    "AMSE_Id" bigint,
    "EME_Id" bigint,
    "EXTTC_FromDateTime" timestamp,
    "EXTTC_ToDateTime" timestamp,
    "EXTTC_Note" text,
    "EXTTC_ActiveFlag" boolean,
    "ACST_Id" bigint,
    "ACSS_Id" bigint,
    "AMCST_Id" bigint,
    "AMCST_FirstName" text,
    "EHTC_HallTicketNo" varchar,
    "AMCST_AdmNo" varchar,
    "ISMS_SubjectName" varchar,
    "ISMS_SubjectCode" varchar,
    "ACYST_RollNo" varchar,
    "ETTS_StartTime" time,
    "ETTS_EndTime" time,
    "ExamStarDate" timestamp,
    "EXTTC_ReportingTime" time,
    "EXTTC_ExaminationCenter" varchar,
    "section" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQLQUERY TEXT;
BEGIN
    DROP TABLE IF EXISTS "EXAM_Temp_StudentDetails_Amstids";
    
    v_SQLQUERY := 'CREATE TEMP TABLE "EXAM_Temp_StudentDetails_Amstids" AS SELECT DISTINCT "AMCST_Id" FROM "CLG"."Adm_Master_College_Student" WHERE "AMCST_Id" IN (' || p_AMCST_Id || ')';
    EXECUTE v_SQLQUERY;
    
    IF p_Flag = '1' THEN
        RETURN QUERY
        SELECT 
            a."EXTTC_Id", 
            b."ASMAY_Year",
            c."AMCO_CourseName",
            D."AMB_BranchName",
            E."AMSE_SEMName",
            f."EME_ExamName",
            a."ASMAY_Id",
            a."AMCO_Id",
            a."AMB_Id",
            a."AMSE_Id",
            a."EME_Id",
            a."EXTTC_FromDateTime",
            a."EXTTC_ToDateTime",
            a."EXTTC_Note",
            a."EXTTC_ActiveFlag",
            a."ACST_Id",
            a."ACSS_Id",
            NULL::bigint,
            NULL::text,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::time,
            NULL::time,
            NULL::timestamp,
            NULL::time,
            NULL::varchar,
            NULL::varchar
        FROM "CLG"."Exm_TimeTable_College" a
        INNER JOIN "Adm_School_M_Academic_Year" b ON a."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" D ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "EXM"."Exm_Master_Exam" F ON F."EME_Id" = a."EME_Id"
        WHERE a."MI_Id" = p_MI_Id;
    END IF;
    
    IF p_Flag = '2' THEN
        RETURN QUERY
        SELECT 
            a."EXTTC_Id",
            b."ASMAY_Year",
            c."AMCO_CourseName",
            D."AMB_BranchName",
            E."AMSE_SEMName",
            NULL::varchar,
            a."ASMAY_Id",
            a."AMCO_Id",
            a."AMB_Id",
            a."AMSE_Id",
            a."EME_Id",
            a."EXTTC_FromDateTime",
            a."EXTTC_ToDateTime",
            a."EXTTC_Note",
            a."EXTTC_ActiveFlag",
            NULL::bigint,
            NULL::bigint,
            H."AMCST_Id",
            CONCAT(AMCS."AMCST_FirstName", ' ', AMCS."AMCST_MiddleName", ' ', AMCS."AMCST_LastName", ''),
            H."EHTC_HallTicketNo",
            AMCS."AMCST_AdmNo",
            IVM."ISMS_SubjectName",
            IVM."ISMS_SubjectCode",
            ACYS."ACYST_RollNo",
            EXTTMS."ETTS_StartTime",
            EXTTMS."ETTS_EndTime",
            EXTMCG."EXTTSC_Date",
            EXTMCG."EXTTC_ReportingTime",
            EXTMCG."EXTTC_ExaminationCenter",
            CLE."ACMS_SectionName"
        FROM "CLG"."Exm_TimeTable_College" a
        INNER JOIN "Adm_School_M_Academic_Year" b ON a."ASMAY_Id" = b."ASMAY_Id" AND b."ASMAY_Id" = p_ASMAY_Id
        INNER JOIN "clg"."Exm_HallTicket_College" H ON a."ASMAY_Id" = H."ASMAY_Id" AND a."AMCO_Id" = H."AMCO_Id"
            AND H."ASMAY_Id" = p_ASMAY_Id AND H."AMCO_Id" = p_AMCO_Id
            AND H."AMB_Id" = p_AMB_Id AND H."AMSE_Id" = p_AMSE_Id AND H."ACMS_Id" = p_ACMS_Id AND H."EME_Id" = p_EME_Id
        INNER JOIN "CLG"."Adm_Master_College_Student" AMCS ON AMCS."AMCST_Id" = H."AMCST_Id" AND AMCS."AMCST_SOL" = 'S'
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS ACYS ON ACYS."AMCST_Id" = AMCS."AMCST_Id" AND AMCS."AMCST_ActiveFlag" = true
            AND AMCS."AMCST_SOL" = 'S' AND ACYS."ACYST_ActiveFlag" = true
            AND AMCS."AMCST_ActiveFlag" = true AND H."ASMAY_Id" = ACYS."ASMAY_Id" AND H."AMCO_Id" = ACYS."AMCO_Id"
            AND H."AMB_Id" = ACYS."AMB_Id" AND H."AMSE_Id" = ACYS."AMSE_Id" AND H."ACMS_Id" = ACYS."ACMS_Id"
            AND ACYS."ASMAY_Id" = p_ASMAY_Id AND ACYS."AMCO_Id" = p_AMCO_Id
            AND ACYS."AMB_Id" = p_AMB_Id AND ACYS."AMSE_Id" = p_AMSE_Id AND ACYS."ACMS_Id" = p_ACMS_Id
        INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" CLGY ON H."AMCST_Id" = CLGY."AMCST_Id"
            AND H."ASMAY_Id" = CLGY."ASMAY_Id" AND H."AMCO_Id" = CLGY."AMCO_Id"
            AND H."AMB_Id" = CLGY."AMB_Id" AND H."AMSE_Id" = CLGY."AMSE_Id" AND H."ACMS_Id" = CLGY."ACMS_Id"
            AND CLGY."MI_Id" = p_MI_Id AND CLGY."ASMAY_Id" = p_ASMAY_Id AND CLGY."AMCO_Id" = p_AMCO_Id
            AND CLGY."AMB_Id" = p_AMB_Id AND CLGY."AMSE_Id" = p_AMSE_Id AND CLGY."ACMS_Id" = p_ACMS_Id
        INNER JOIN "IVRM_Master_Subjects" IVM ON IVM."ISMS_Id" = CLGY."ISMS_Id"
        INNER JOIN "CLG"."Exm_TimeTable_College_Subjects" EXTMCG ON IVM."ISMS_Id" = EXTMCG."ISMS_Id" AND EXTMCG."EXTTC_Id" = a."EXTTC_Id"
        INNER JOIN "Exm"."Exm_TT_M_Session" EXTTMS ON EXTTMS."ETTS_Id" = EXTMCG."EMTTSC_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id" AND c."AMCO_Id" = p_AMCO_Id
        INNER JOIN "clg"."Adm_Master_Branch" D ON d."AMB_Id" = a."AMB_Id" AND d."AMB_Id" = p_AMB_Id
        INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = a."AMSE_Id" AND E."AMSE_Id" = p_AMSE_Id
        INNER JOIN "clg"."Adm_College_Master_Section" CLE ON CLE."ACMS_Id" = ACYS."ACMS_Id"
        WHERE H."EHTC_PublishFlg" = true AND a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."AMCO_Id" = p_AMCO_Id
            AND a."AMB_Id" = p_AMB_Id AND a."AMSE_Id" = p_AMSE_Id AND a."EME_Id" = p_EME_Id
            AND H."AMCST_Id" IN (SELECT "AMCST_Id" FROM "EXAM_Temp_StudentDetails_Amstids")
        ORDER BY H."AMCST_Id";
    END IF;
    
    RETURN;
END;
$$;