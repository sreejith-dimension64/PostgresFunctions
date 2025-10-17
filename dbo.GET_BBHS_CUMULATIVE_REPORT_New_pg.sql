CREATE OR REPLACE FUNCTION "dbo"."GET_BBHS_CUMULATIVE_REPORT_New"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_studentname TEXT;
    v_amst_id TEXT;
    v_casetname TEXT;
    v_ect_id TEXT;
    v_ect_name TEXT;
    v_eme_id TEXT;
    v_eme_name TEXT;
    v_eme_order TEXT;
    studentlist_rec RECORD;
    termlist_rec RECORD;
    termexamlist_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "tempstudentlistbbs";

    CREATE TEMP TABLE "tempstudentlistbbs" (
        "AMST_Id" TEXT,
        "StudentName" TEXT,
        "AMST_AdmNo" TEXT,
        "ECT_Id" TEXT,
        "ECT_TermName" TEXT,
        "EMPSG_Id" TEXT,
        "EMPSG_GroupName" TEXT,
        "EMPSG_PercentValue" DECIMAL(18,2),
        "EME_ID" TEXT,
        "ISMS_Id" TEXT,
        "ESTMPPSG_GroupMaxMarks" DECIMAL(18,2),
        "ESTMPPSG_GroupObtMarks" DECIMAL(18,2),
        "ESTMPPSG_GroupObtGrade" TEXT,
        "IMC_CasteName" TEXT,
        "ISMS_SubjectName" TEXT,
        "EMPS_AppToResultFlg" BOOLEAN,
        "displayname" TEXT
    );

    FOR studentlist_rec IN 
        SELECT DISTINCT * 
        FROM "Adm_School_Y_Student" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."amst_id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = a."ASMAY_Id"
        INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = a."ASMS_Id"
        LEFT JOIN "IVRM_Master_Caste" f ON f."IMC_Id" = b."ic_id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id 
          AND a."ASMCL_Id" = p_ASMCL_Id 
          AND a."ASMS_Id" = p_ASMS_Id 
          AND b."mi_id" = p_MI_Id 
          AND b."amst_sol" = 'S' 
          AND b."amst_activeflag" = 1
          AND a."AMAY_ActiveFlag" = 1
    LOOP
        v_amst_id := studentlist_rec."AMST_Id"::TEXT;
        v_studentname := studentlist_rec."StudentName"::TEXT;
        v_casetname := studentlist_rec."IMC_CasteName"::TEXT;

        FOR termlist_rec IN 
            SELECT DISTINCT "ECT_Id", "ECT_TermName" 
            FROM "exm"."Exm_CCE_TERMS" 
            WHERE "MI_Id" = p_MI_Id 
              AND "ECT_ActiveFlag" = 1
        LOOP
            v_ect_id := termlist_rec."ECT_Id"::TEXT;
            v_ect_name := termlist_rec."ECT_TermName"::TEXT;

            FOR termexamlist_rec IN 
                SELECT DISTINCT d."eme_id", d."eme_examname", d."EME_ExamOrder"
                FROM "exm"."Exm_CCE_TERMS" a 
                INNER JOIN "exm"."Exm_CCE_TERMS_MP" b ON a."ECT_Id" = b."ECT_Id"
                INNER JOIN "exm"."Exm_CCE_TERMS_MP_EXAMS" c ON c."ECTMP_Id" = b."ECTMP_Id"
                INNER JOIN "exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_ID"
                INNER JOIN "exm"."Exm_Category_Class" e ON e."EMCA_Id" = b."EMCA_Id"
                WHERE b."ASMAY_Id" = p_ASMAY_Id 
                  AND e."ASMAY_Id" = p_ASMAY_Id 
                  AND e."ASMCL_Id" = p_ASMCL_Id 
                  AND e."ASMS_Id" = p_ASMS_Id 
                  AND a."MI_Id" = p_MI_Id 
                  AND a."ECT_ActiveFlag" = 1 
                  AND b."ECTMP_ActiveFlag" = 1 
                  AND c."ECTMPE_ActiveFlag" = 1 
                  AND e."ECAC_ActiveFlag" = 1 
                  AND b."ECT_Id" = v_ect_id::bigint
            LOOP
                v_eme_id := termexamlist_rec."eme_id"::TEXT;
                v_eme_name := termexamlist_rec."eme_examname"::TEXT;
                v_eme_order := termexamlist_rec."EME_ExamOrder"::TEXT;

            END LOOP;

        END LOOP;

    END LOOP;

    RETURN;
END;
$$;