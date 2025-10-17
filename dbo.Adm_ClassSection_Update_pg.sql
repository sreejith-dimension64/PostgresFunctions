CREATE OR REPLACE FUNCTION "Adm_ClassSection_Update"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT,
    p_ASMCL_ID TEXT,
    p_ASMS_ID TEXT,
    p_AMST_ID TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_DYNAMIC TEXT;
    v_CURSOR_AMST_Id BIGINT;
    v_CURSOR_ASMCL_ID BIGINT;
    v_CURSOR_ASMS_ID BIGINT;
    student_record RECORD;
BEGIN

    DROP TABLE IF EXISTS "STUDENTCLASSSECTION_TEMP";

    v_DYNAMIC := '
    CREATE TEMP TABLE "STUDENTCLASSSECTION_TEMP" AS
    SELECT DISTINCT A."AMST_Id", B."ASMCL_ID", B."ASMS_ID"
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_ID" = B."AMST_ID"
    WHERE A."MI_Id" = ' || p_MI_ID || ' AND B."ASMAY_Id" = ' || p_ASMAY_ID || ' AND B."AMST_Id" IN (' || p_AMST_ID || ')';

    EXECUTE v_DYNAMIC;

    FOR student_record IN 
        SELECT "AMST_Id", "ASMCL_ID", "ASMS_ID" FROM "STUDENTCLASSSECTION_TEMP"
    LOOP
        v_CURSOR_AMST_Id := student_record."AMST_Id";
        v_CURSOR_ASMCL_ID := student_record."ASMCL_ID";
        v_CURSOR_ASMS_ID := student_record."ASMS_ID";

        UPDATE "EXM"."Exm_Stu_MP_Promo_Subjectwise" 
        SET "ASMCL_Id" = p_ASMCL_ID::BIGINT, "ASMS_Id" = p_ASMS_ID::BIGINT 
        WHERE "AMST_Id" = v_CURSOR_AMST_Id 
        AND "ASMCL_Id" = v_CURSOR_ASMCL_ID 
        AND "ASMS_Id" = v_CURSOR_ASMS_ID 
        AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;

        UPDATE "EXM"."Exm_CCE_Activities_Transaction" 
        SET "ASMCL_Id" = p_ASMCL_ID::BIGINT, "ASMS_Id" = p_ASMS_ID::BIGINT 
        WHERE "AMST_Id" = v_CURSOR_AMST_Id 
        AND "ASMCL_Id" = v_CURSOR_ASMCL_ID 
        AND "ASMS_Id" = v_CURSOR_ASMS_ID 
        AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;

        UPDATE "EXM"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ASMCL_Id" = p_ASMCL_ID::BIGINT, "ASMS_Id" = p_ASMS_ID::BIGINT 
        WHERE "AMST_Id" = v_CURSOR_AMST_Id 
        AND "ASMCL_Id" = v_CURSOR_ASMCL_ID 
        AND "ASMS_Id" = v_CURSOR_ASMS_ID 
        AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;

        UPDATE "EXM"."Exm_Studentwise_Subjects" 
        SET "ASMCL_Id" = p_ASMCL_ID::BIGINT, "ASMS_Id" = p_ASMS_ID::BIGINT 
        WHERE "AMST_Id" = v_CURSOR_AMST_Id 
        AND "ASMCL_Id" = v_CURSOR_ASMCL_ID 
        AND "ASMS_Id" = v_CURSOR_ASMS_ID 
        AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;

        UPDATE "SPC"."SPCC_Student_House" 
        SET "ASMCL_Id" = p_ASMCL_ID::BIGINT, "ASMS_Id" = p_ASMS_ID::BIGINT 
        WHERE "AMST_Id" = v_CURSOR_AMST_Id 
        AND "ASMCL_Id" = v_CURSOR_ASMCL_ID 
        AND "ASMS_Id" = v_CURSOR_ASMS_ID 
        AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;

        UPDATE "SPC"."SPCC_Student_Division" 
        SET "ASMCL_Id" = p_ASMCL_ID::BIGINT, "ASMS_Id" = p_ASMS_ID::BIGINT 
        WHERE "AMST_Id" = v_CURSOR_AMST_Id 
        AND "ASMCL_Id" = v_CURSOR_ASMCL_ID 
        AND "ASMS_Id" = v_CURSOR_ASMS_ID 
        AND "ASAMY_Id" = p_ASMAY_ID::BIGINT;

        UPDATE "SPC"."SPCC_Student_HeightWeight" 
        SET "ASMCL_Id" = p_ASMCL_ID::BIGINT, "ASMS_Id" = p_ASMS_ID::BIGINT 
        WHERE "AMST_Id" = v_CURSOR_AMST_Id 
        AND "ASMCL_Id" = v_CURSOR_ASMCL_ID 
        AND "ASMS_Id" = v_CURSOR_ASMS_ID 
        AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;

    END LOOP;

    DROP TABLE IF EXISTS "STUDENTCLASSSECTION_TEMP";

    RETURN;

END;
$$;