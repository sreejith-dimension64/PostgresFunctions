CREATE OR REPLACE FUNCTION "dbo"."Exam_Get_StudentList_PublishMarks_Subjects"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_EME_Id TEXT,
    p_radiotype TEXT,
    p_feeinstallmentcheckbox TEXT,
    p_FMT_Id TEXT,
    p_FMGIDS TEXT,
    p_ISMS_Id TEXT
)
RETURNS TABLE(
    "amsT_Id" BIGINT,
    "amsT_FirstName" TEXT,
    "amsT_AdmNo" VARCHAR,
    "amaY_Rollno" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "obtainedmarks" NUMERIC,
    "totalmaxmarks" NUMERIC,
    "percentage" NUMERIC,
    "estmP_PublishToStudentFlg" INTEGER,
    "estmP_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQL TEXT;
BEGIN

    DROP TABLE IF EXISTS "Exan_Fee_Defaulter_StudentDetails_TermWise";
    DROP TABLE IF EXISTS "Exan_StudentDetails_YearWise";

    CREATE TEMP TABLE "Exan_Fee_Defaulter_StudentDetails_TermWise" ("AMST_Id" BIGINT);

    IF p_feeinstallmentcheckbox = '1' THEN
        v_SQL := '
        INSERT INTO "Exan_Fee_Defaulter_StudentDetails_TermWise"
        SELECT DISTINCT c."AMST_Id" 
        FROM "fee_master_terms" AS a 
        INNER JOIN "Fee_Master_Terms_FeeHeads" AS b ON a."FMT_Id" = b."FMT_Id"
        INNER JOIN "fee_student_status" AS c ON c."fmh_id" = b."fmh_id" AND c."fti_id" = b."fti_id"
        INNER JOIN "adm_m_student" AS d ON d."amst_id" = c."amst_id"
        WHERE c."mi_id" = ' || p_MI_Id || ' AND c."asmay_id" = ' || p_ASMAY_Id || 
        ' AND b."FMT_Id" = ' || p_FMT_Id || ' AND "FSS_ToBePaid" > 0 AND "amst_sol" = ''S''
        AND "fmg_id" IN (' || p_FMGIDS || ')';

        EXECUTE v_SQL;
    END IF;

    CREATE TEMP TABLE "Exan_StudentDetails_YearWise" AS
    SELECT A."AMST_Id" AS "amsT_Id",
        (CASE WHEN B."AMST_FirstName" IS NULL THEN '' ELSE B."AMST_FirstName" END || 
         CASE WHEN B."AMST_MiddleName" IS NULL OR B."AMST_MiddleName" = '' THEN '' ELSE ' ' || B."AMST_MiddleName" END ||
         CASE WHEN B."AMST_LastName" IS NULL OR B."AMST_LastName" = '' THEN '' ELSE ' ' || B."AMST_LastName" END) AS "amsT_FirstName",
        "AMST_AdmNo" AS "amsT_AdmNo",
        "AMAY_Rollno" AS "amaY_Rollno",
        "ASMCL_ClassName",
        "ASMC_SectionName"
    FROM "Adm_School_Y_Student" A 
    INNER JOIN "Adm_M_Student" B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = A."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = A."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = A."ASMS_Id"
    WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
        AND A."AMST_Id" NOT IN (SELECT "AMST_Id" FROM "Exan_Fee_Defaulter_StudentDetails_TermWise");

    IF p_radiotype = 'Exam' THEN
        RETURN QUERY
        SELECT B."amsT_Id",
               B."amsT_FirstName",
               B."amsT_AdmNo",
               B."amaY_Rollno",
               B."ASMCL_ClassName",
               B."ASMC_SectionName",
               A."ESTMP_TotalObtMarks" AS "obtainedmarks",
               A."ESTMP_TotalMaxMarks" AS "totalmaxmarks",
               A."ESTMP_Percentage" AS "percentage",
               CASE WHEN A."ESTMP_PublishToStudentFlg" = TRUE THEN 1 ELSE 0 END AS "estmP_PublishToStudentFlg",
               A."ESTMP_Id" AS "estmP_Id"
        FROM "Exm"."Exm_Student_Marks_Process" A 
        INNER JOIN "Exan_StudentDetails_YearWise" B ON A."AMST_Id" = B."amsT_Id"
        WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND A."EME_Id" = p_EME_Id::BIGINT;

    ELSIF p_radiotype = 'Subject' THEN
        RETURN QUERY
        SELECT B."amsT_Id",
               B."amsT_FirstName",
               B."amsT_AdmNo",
               B."amaY_Rollno",
               B."ASMCL_ClassName",
               B."ASMC_SectionName",
               A."ESTM_Marks" AS "obtainedmarks",
               NULL::NUMERIC AS "totalmaxmarks",
               NULL::NUMERIC AS "percentage",
               CASE WHEN A."ESTM_PublishToStudentFlg" = TRUE THEN 1 ELSE 0 END AS "estmP_PublishToStudentFlg",
               A."ESTM_Id" AS "estmP_Id"
        FROM "Exm"."Exm_Student_Marks" A 
        INNER JOIN "Exan_StudentDetails_YearWise" B ON A."AMST_Id" = B."amsT_Id"
        WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND A."EME_Id" = p_EME_Id::BIGINT 
            AND "ISMS_Id" = p_ISMS_Id::BIGINT;

    ELSE
        RETURN QUERY
        SELECT B."amsT_Id",
               B."amsT_FirstName",
               B."amsT_AdmNo",
               B."amaY_Rollno",
               B."ASMCL_ClassName",
               B."ASMC_SectionName",
               A."ESTMPP_TotalObtMarks" AS "obtainedmarks",
               A."ESTMPP_TotalMaxMarks" AS "totalmaxmarks",
               A."ESTMPP_Percentage" AS "percentage",
               CASE WHEN A."ESTMPP_PublishToStudentFlg" = TRUE THEN 1 ELSE 0 END AS "estmP_PublishToStudentFlg",
               A."ESTMPP_Id" AS "estmP_Id"
        FROM "Exm"."Exm_Student_MP_Promotion" A 
        INNER JOIN "Exan_StudentDetails_YearWise" B ON A."AMST_Id" = B."amsT_Id"
        WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT;

    END IF;

    DROP TABLE IF EXISTS "Exan_Fee_Defaulter_StudentDetails_TermWise";
    DROP TABLE IF EXISTS "Exan_StudentDetails_YearWise";

END;
$$;