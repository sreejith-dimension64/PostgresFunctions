CREATE OR REPLACE FUNCTION "dbo"."Admission_CountIssueBook"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMST_Id BIGINT
)
RETURNS TABLE("CountIssueBook" BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT COUNT(a."LBTR_Status") as "CountIssueBook"
    FROM "LIB"."LIB_Book_Transaction" a 
    INNER JOIN "LIB"."LIB_Book_Transaction_Student" b ON a."LBTR_Id" = b."LBTR_Id" AND a."LBTR_ActiveFlg" = 1
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = b."AMST_Id"   
    WHERE a."MI_Id" = p_MI_Id 
        AND "ASYS"."ASMAY_Id" = p_ASMAY_Id  
        AND a."LBTR_Status" = 'Issue' 
        AND b."AMST_Id" = p_AMST_Id;
END;
$$;