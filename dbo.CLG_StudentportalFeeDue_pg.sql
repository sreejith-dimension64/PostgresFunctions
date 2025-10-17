CREATE OR REPLACE FUNCTION "dbo"."CLG_StudentportalFeeDue"(
    p_MI_Id bigint,
    p_AMCST_Id bigint,
    p_ASMAY_ID bigint
)
RETURNS TABLE(
    "TERMNAME" character varying,
    "TobePaid" numeric,
    "DUEDATE" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "B"."FTI_Name" as "TERMNAME",
        SUM("A"."FCSS_ToBePaid") as "TobePaid",
        "C"."FTIDD_DueDate" as "DUEDATE"
    FROM "CLG"."Fee_College_Student_Status" "A"
    INNER JOIN "Fee_T_Installment" "B" ON "A"."FTI_Id" = "B"."FTI_Id"
    INNER JOIN "Fee_T_Installment_DueDate" "C" ON "C"."FTI_Id" = "B"."FTI_Id" 
        AND "A"."ASMAY_Id" = "C"."ASMAY_Id"
    WHERE "A"."AMCST_Id" = p_AMCST_Id 
        AND "A"."ASMAY_Id" = p_ASMAY_ID 
        AND "A"."MI_Id" = p_MI_Id
    GROUP BY "B"."FTI_Name", "C"."FTIDD_DueDate"
    LIMIT 1;
END;
$$;