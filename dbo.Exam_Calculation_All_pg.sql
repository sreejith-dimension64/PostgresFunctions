CREATE OR REPLACE FUNCTION "dbo"."Exam_Calculation_All"(
    p_MI_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMAY_Id INT;
    v_ASMCL_Id INT;
    v_ASMS_Id INT;
    v_EME_Id INT;
    exam_record RECORD;
BEGIN
    -- Get the academic year
    SELECT "ASMAY_Id" INTO v_ASMAY_Id
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_MI_Id 
        AND CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date"
    LIMIT 1;

    -- Loop through exam cursor records
    FOR exam_record IN
        SELECT c."ASMCL_Id", c."ASMS_Id", b."EME_Id"
        FROM "Exm"."Exm_Yearly_Category" a
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" b ON a."EYC_Id" = b."EYC_Id"
        INNER JOIN "Exm"."Exm_Category_Class" c ON c."EMCA_Id" = a."EMCA_Id"
        WHERE a."MI_ID" = p_MI_Id
            AND a."ASMAY_Id" = v_ASMAY_Id
    LOOP
        v_ASMCL_Id := exam_record."ASMCL_Id";
        v_ASMS_Id := exam_record."ASMS_Id";
        v_EME_Id := exam_record."EME_Id";

        -- Call the function
        PERFORM "dbo"."IndExamMarksCalculation"(p_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_EME_Id, 0);
    END LOOP;

END;
$$;