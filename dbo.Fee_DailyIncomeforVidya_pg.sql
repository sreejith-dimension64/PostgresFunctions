CREATE OR REPLACE FUNCTION "dbo"."Fee_DailyIncomeforVidya"(
    "@MI_Id" bigint,
    "@DateSelection" timestamp
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "Payment_Mode" text,
    "FYP_Tot_Amount" numeric,
    "FYP_Date" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."AMST_Id",
        a."MI_Id",
        a."ASMAY_Id",
        (a."AMST_FirstName" || ' ' || a."AMST_MiddleName" || '' || a."AMST_LastName") || ' / ' || 
        CASE 
            WHEN FYP."FYP_Bank_Or_Cash" = 'C' THEN 'Cash' 
            WHEN FYP."FYP_Bank_Or_Cash" = 'B' THEN 'Bank'
            WHEN FYP."FYP_Bank_Or_Cash" = 'O' THEN 'Online'
            WHEN FYP."FYP_Bank_Or_Cash" = 'R' THEN 'RTGS'
            WHEN FYP."FYP_Bank_Or_Cash" = 'U' THEN 'UPI' 
        END AS "Payment_Mode",
        FYP."FYP_Tot_Amount",
        FYP."FYP_Date"
    FROM "Adm_M_Student" a
    INNER JOIN "Adm_School_Y_Student" b ON a."ASMAY_Id" = b."ASMAY_Id" AND b."AMST_Id" = a."AMST_Id"
    INNER JOIN "Adm_School_M_Class" c ON c."MI_Id" = a."MI_Id" AND c."ASMCL_Id" = b."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" d ON d."MI_Id" = a."MI_Id" AND b."ASMS_Id" = d."ASMS_Id"
    INNER JOIN "Fee_Student_Status" FS ON FS."MI_Id" = a."MI_Id" AND FS."ASMAY_Id" = b."ASMAY_Id" AND FS."AMST_Id" = a."AMST_Id"
    INNER JOIN "Fee_Y_Payment_School_Student" FY ON fs."ASMAY_Id" = FY."ASMAY_Id" AND fs."AMST_Id" = fy."AMST_Id"
    INNER JOIN "Fee_Y_Payment" FYP ON FYP."FYP_Id" = FY."FYP_Id"
    WHERE a."MI_Id" = "@MI_Id" 
        AND DATE(FYP."FYP_Date") = DATE("@DateSelection")
    GROUP BY 
        a."AMST_Id",
        a."MI_Id",
        a."ASMAY_Id",
        (a."AMST_FirstName" || ' ' || a."AMST_MiddleName" || '' || a."AMST_LastName"),
        FYP."FYP_Bank_Or_Cash",
        b."ASMCL_Id",
        FYP."FYP_Date",
        FYP."FYP_Tot_Amount";
END;
$$;