CREATE OR REPLACE FUNCTION "collegeFeeBalanceCheck" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCST_Id bigint
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    v_count bigint;
    v_sum bigint;
BEGIN
    SELECT SUM("FCSS_ToBePaid") 
    INTO v_sum
    FROM "CLG"."Fee_College_Student_Status" 
    WHERE "MI_Id" = p_MI_Id 
      AND "ASMAY_Id" = p_ASMAY_Id 
      AND "AMCST_Id" = p_AMCST_Id;

    IF (COALESCE(v_sum, 0) > 0) THEN
        v_count := 1;
    ELSE
        v_count := 0;
    END IF;

    RETURN v_count;
END;
$$;