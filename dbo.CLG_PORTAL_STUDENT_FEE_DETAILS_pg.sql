CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STUDENT_FEE_DETAILS"(
    @asmay_id TEXT,
    @amcst_id TEXT,
    @mi_id TEXT
)
RETURNS TABLE(
    totalstudamount NUMERIC,
    concession NUMERIC,
    paidamount NUMERIC,
    adjusted NUMERIC,
    balanceamount NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN 
    RETURN QUERY
    SELECT 
        SUM("FCSS_TotalCharges") AS totalstudamount,
        SUM("FCSS_ConcessionAmount") AS concession,
        SUM("FCSS_PaidAmount") AS paidamount,
        SUM("FCSS_AdjustedAmount") AS adjusted,
        SUM("FCSS_ToBePaid") AS balanceamount  
    FROM "CLG"."Fee_College_Student_Status"   
    INNER JOIN "Adm_School_M_Academic_Year" ON "CLG"."Fee_College_Student_Status"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "CLG"."Fee_College_Student_Status"."MI_Id" = "Fee_Master_Terms_FeeHeads"."MI_Id" 
        AND "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
        AND "CLG"."Fee_College_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
    WHERE "CLG"."Fee_College_Student_Status"."MI_Id" = @MI_Id 
        AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = @AMCST_Id 
        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = @ASMAY_Id;
END;
$$;