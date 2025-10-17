CREATE OR REPLACE FUNCTION "dbo"."Exam_Duplicate_MarksEntry_Delete"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_EME_Id bigint,
    p_ISMS_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_count1 bigint;
BEGIN
    DROP TABLE IF EXISTS temp_exam;

    CREATE TEMP TABLE temp_exam AS
    WITH cte AS (
        SELECT 
            ROW_NUMBER() OVER(
                PARTITION BY "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ISMS_Id" 
                ORDER BY "ESTM_Id" DESC
            ) AS rno,
            *
        FROM "Exm"."Exm_Student_Marks"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id
            AND "ISMS_Id" = p_ISMS_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "EME_Id" = p_EME_Id
    )
    SELECT "ESTM_Id" 
    FROM cte 
    WHERE rno > 1
    ORDER BY "AMST_Id", "ESTM_Marks" DESC;

    SELECT COUNT(*) INTO v_count1 FROM temp_exam;

    IF (v_count1 > 0) THEN
        UPDATE "Exm"."Exm_Student_Marks_SubSubject" 
        SET "ESTMSS_ActiveFlg" = FALSE 
        WHERE "ESTM_Id" IN (SELECT "ESTM_Id" FROM temp_exam);
    END IF;

    UPDATE "Exm"."Exm_Student_Marks" 
    SET "ESTM_ActiveFlg" = FALSE 
    WHERE "ESTM_Id" IN (SELECT "ESTM_Id" FROM temp_exam);

    DROP TABLE IF EXISTS temp_exam;

    RETURN;
END;
$$;