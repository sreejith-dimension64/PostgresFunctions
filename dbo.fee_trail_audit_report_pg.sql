CREATE OR REPLACE FUNCTION "dbo"."fee_trail_audit_report"(
    "@receiptno" BIGINT,
    "@amst" BIGINT,
    "@mi_id" BIGINT,
    "@asmyid" BIGINT,
    "@fromdate" TIMESTAMP,
    "@todate" TIMESTAMP,
    "@userid" BIGINT,
    "@transflag" VARCHAR
)
RETURNS TABLE(
    "FYP_Receipt_No" BIGINT,
    "NormalizedUserName" VARCHAR,
    "name" TEXT,
    "date" DATE,
    "time" TIME(0),
    "FYP_Remarks" TEXT,
    "FYP_Tot_Amount" NUMERIC,
    "FYP_Tot_Concession_Amt" NUMERIC,
    "FYP_Tot_Fine_Amt" NUMERIC,
    "FYP_Tot_Waived_Amt" NUMERIC,
    "Machine_Ip_Address" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "a"."FYP_Receipt_No",
        "g"."NormalizedUserName",
        (CAST("c"."AMST_Id" AS VARCHAR) || '::' || "c"."AMST_FirstName" || "c"."AMST_MiddleName" || "c"."AMST_LastName") AS "name",
        CAST("a"."FYP_Date" AS DATE) AS "date",
        CAST("a"."FYP_Date" AS TIME(0)) AS "time",
        "a"."FYP_Remarks",
        "a"."FYP_Tot_Amount",
        "a"."FYP_Tot_Concession_Amt",
        "a"."FYP_Tot_Fine_Amt",
        "a"."FYP_Tot_Waived_Amt",
        "g"."Machine_Ip_Address"
    FROM "Fee_Y_Payment" "a"
    INNER JOIN "Fee_Y_Payment_School_Student" "b" ON "a"."FYP_Id" = "b"."FYP_Id"
    INNER JOIN "Adm_M_Student" "c" ON "b"."AMST_Id" = "c"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" "d" ON "b"."AMST_Id" = "d"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" "e" ON "d"."ASMCL_Id" = "e"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "f" ON "d"."ASMS_Id" = "f"."ASMS_Id"
    INNER JOIN "ApplicationUser" "g" ON "a"."user_id" = "g"."Id"
    WHERE "g"."Id" = "@userid"
        AND "c"."AMST_Id" = "@amst" 
        AND "c"."AMST_SOL" = 'S' 
        AND "c"."MI_Id" = "@mi_id" 
        AND "c"."ASMAY_Id" = "@asmyid";
END;
$$;