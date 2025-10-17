CREATE OR REPLACE FUNCTION "dbo"."GET_PRINCIPAL_TERMWISE"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "FMT_Id" bigint,
    "FMT_Name" VARCHAR,
    "BalanceAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "dbo"."Fee_Student_Status"."AMST_Id",
        "dbo"."Fee_Master_Terms"."FMT_Id",
        "dbo"."Fee_Master_Terms"."FMT_Name",
        SUM("FSS_ToBePaid") AS "BalanceAmount"
    FROM "dbo"."Fee_Master_Group" 
    INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" 
    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" 
    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id" 
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" 
    INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id" 
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" 
    INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master_Terms"."FMT_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" 
        AND "dbo"."Fee_Student_Status"."FTI_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" 
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id" 
        AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Fee_Student_Status"."ASMAY_Id" 
    WHERE "dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id 
        AND "dbo"."Fee_Student_Status"."MI_Id" = p_MI_Id
        AND ("dbo"."Adm_School_Y_Student"."AMAY_ActiveFlag" = 1)
        AND ("dbo"."Adm_M_Student"."AMST_SOL" = 'S') 
        AND ("dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1) 
        AND "dbo"."Fee_Student_Status"."AMST_Id" IN (p_AMST_Id) 
    GROUP BY "dbo"."Fee_Master_Terms"."FMT_Id", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Student_Status"."AMST_Id";
END;
$$;