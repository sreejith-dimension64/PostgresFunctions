CREATE OR REPLACE FUNCTION "dbo"."FEE_TRNS_NAME_SEARCH"(
    "Mi_Id" bigint,
    "searchtext" TEXT,
    "ASMAY_ID" bigint,
    "user_id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR,
    "FYP_Receipt_No" VARCHAR,
    "FYP_Bank_Or_Cash" VARCHAR,
    "FYP_Tot_Amount" NUMERIC,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "FYP_Id" bigint,
    "AMST_AdmNo" VARCHAR,
    "FYP_Date" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "D"."AMST_Id",
        "C"."AMST_FirstName",
        "C"."AMST_MiddleName",
        "C"."AMST_LastName",
        "A"."FYP_Receipt_No",
        "A"."FYP_Bank_Or_Cash",
        "A"."FYP_Tot_Amount",
        "E"."ASMCL_ClassName",
        "F"."ASMC_SectionName",
        "A"."FYP_Id",
        "C"."AMST_AdmNo",
        "A"."FYP_Date"
    FROM "fee_Y_payment" AS "A"
    INNER JOIN "Fee_Y_Payment_School_Student" AS "B" ON "A"."FYP_Id" = "B"."FYP_Id"
    INNER JOIN "Adm_M_Student" AS "C" ON "C"."AMST_Id" = "B"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" AS "D" ON "D"."AMST_Id" = "B"."AMST_Id" AND "D"."ASMAY_Id" = "A"."ASMAY_ID"
    INNER JOIN "Adm_School_M_Class" AS "E" ON "E"."ASMCL_Id" = "D"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" AS "F" ON "F"."ASMS_Id" = "D"."ASMS_Id"
    WHERE "A"."MI_Id" = "Mi_Id" 
        AND "A"."ASMAY_ID" = "ASMAY_ID" 
        AND "A"."user_id" = "user_id" 
        AND "E"."MI_Id" = "Mi_Id" 
        AND "F"."MI_Id" = "Mi_Id"
        AND (
            "C"."AMST_FirstName" LIKE '%' || "searchtext" || '%' 
            OR "C"."AMST_MiddleName" LIKE '%' || "searchtext" || '%' 
            OR "C"."AMST_LastName" LIKE '%' || "searchtext" || '%'
        );
END;
$$;