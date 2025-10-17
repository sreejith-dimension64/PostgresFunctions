CREATE OR REPLACE FUNCTION "ATTENDENCE_DETAILS"(
    p_MI_ID BIGINT,
    p_EYC_ID BIGINT,
    p_EYCE_ID BIGINT,
    p_EYCG_ID BIGINT
)
RETURNS TABLE(
    "EYC_ActiveFlg" BOOLEAN,
    "EYCE_AttendanceFromDate" TIMESTAMP,
    "CreatedDate" TIMESTAMP,
    "EYCGS_CreatedBy" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ATTENDENCE TEXT;
BEGIN
    v_ATTENDENCE := '
    SELECT "EYC_ActiveFlg", "EYCE_AttendanceFromDate", "C"."CreatedDate", "EYCGS_CreatedBy"
    FROM "Exm"."Exm_Yearly_Category" AS "A" 
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "B" ON "A"."EYC_Id" = "B"."EYC_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Group" "C" ON "C"."EYC_Id" = "A"."EYC_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Group_Subjects" "D" ON "D"."EYCG_Id" = "C"."EYCG_Id"
    WHERE "A"."MI_ID" = ' || p_MI_ID || ' 
    AND "A"."EYC_ID" IN (' || p_EYC_ID || ') 
    AND "A"."EYCE_ID" IN (' || p_EYCE_ID || ') 
    AND "C"."EYCG_ID" IN (' || p_EYCG_ID || ')';

    RETURN QUERY EXECUTE v_ATTENDENCE;
END;
$$;