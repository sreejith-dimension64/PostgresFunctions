CREATE OR REPLACE FUNCTION "dbo"."Fee_Studentlist_Head" (
    "@MI_ID" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@AMST_ID" BIGINT
)
RETURNS TABLE (
    "FMH_Id" BIGINT,
    "FMH_FeeName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT a."FMH_Id", a."FMH_FeeName"
    FROM "Fee_Master_Head" a
    INNER JOIN "Fee_Student_Status" b ON b."FMH_Id" = a."FMH_Id"
    INNER JOIN "Fee_Yearly_Group_Head_Mapping" c ON a."FMH_Id" = c."FMH_Id"
    WHERE
        b."ASMAY_Id" = "@ASMAY_Id"
        AND b."MI_Id" = "@MI_ID"
        AND b."AMST_ID" = "@AMST_ID"
    ORDER BY
        a."FMH_Id";
END;
$$;