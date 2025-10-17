CREATE OR REPLACE FUNCTION "dbo"."Fee_DailyCollection_Vidyavikas"(
    p_ASMAY_Id bigint,
    p_MI_Id bigint,
    p_FromDate timestamp,
    p_ToDate timestamp,
    p_PaymentMode varchar(10)
)
RETURNS TABLE(
    "AMST_MobileNo" varchar,
    "AMST_Id" bigint,
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "StudentName" text,
    "ASMCL_Id" bigint,
    "ASMCL_ClassName" varchar,
    "ASMS_Id" bigint,
    "ASMC_SectionName" varchar,
    "FYP_Receipt_No" varchar,
    "ReceiptDate" timestamp,
    "TotalAmount" numeric,
    "TotalToBePaid" numeric,
    "TotalPaidAmount" numeric,
    "Payment_Mode" text,
    "FYP_DD_Cheque_no" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_PaymentMode = 'ALL' THEN
        RETURN QUERY
        SELECT 
            "STD"."AMST_MobileNo",
            "STD"."AMST_Id",
            "STD"."MI_Id",
            "YS"."ASMAY_Id",
            ("STD"."AMST_FirstName" || ' ' || "STD"."AMST_MiddleName" || '' || "STD"."AMST_LastName")::text AS "StudentName",
            "YS"."ASMCL_Id",
            "CL"."ASMCL_ClassName",
            "YS"."ASMS_Id",
            "MS"."ASMC_SectionName",
            "FYP"."FYP_Receipt_No",
            "FYP"."FYP_Date" AS "ReceiptDate",
            sum("FS"."FSS_TotalToBePaid") AS "TotalAmount",
            sum("FS"."FSS_ToBePaid") AS "TotalToBePaid",
            (sum("FS"."FSS_TotalToBePaid") - sum("FS"."FSS_ToBePaid")) AS "TotalPaidAmount",
            CASE 
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'C' THEN 'Cash'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'O' THEN 'Online'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'R' THEN 'RTGS'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'U' THEN 'UPI'
            END::text AS "Payment_Mode",
            "FYP"."FYP_DD_Cheque_no"
        FROM "dbo"."Fee_Y_Payment_School_Student" "FYPS"
        INNER JOIN "dbo"."Fee_Y_Payment" "FYP" ON "FYPS"."FYP_Id" = "FYP"."FYP_Id"
        INNER JOIN "dbo"."Adm_M_Student" "STD" ON "FYPS"."AMST_Id" = "STD"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" "YS" ON "STD"."AMST_Id" = "YS"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" "Y" ON "YS"."ASMAY_Id" = "Y"."ASMAY_Id" AND "FYPS"."ASMAY_Id" = "Y"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" "CL" ON "YS"."ASMCL_Id" = "CL"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" "MS" ON "YS"."ASMS_Id" = "MS"."ASMS_Id"
        INNER JOIN "dbo"."Fee_Student_Status" "FS" ON "FS"."AMST_Id" = "YS"."AMST_Id" AND "FS"."ASMAY_Id" = "YS"."ASMAY_Id"
        WHERE "YS"."ASMAY_Id" = p_ASMAY_Id 
            AND "STD"."MI_Id" = p_MI_Id 
            AND "FYP"."FYP_Date" BETWEEN p_FromDate AND p_ToDate
        GROUP BY 
            "STD"."AMST_MobileNo",
            "STD"."AMST_Id",
            "STD"."MI_Id",
            "YS"."ASMAY_Id",
            ("STD"."AMST_FirstName" || ' ' || "STD"."AMST_MiddleName" || '' || "STD"."AMST_LastName"),
            "YS"."ASMCL_Id",
            "CL"."ASMCL_ClassName",
            "YS"."ASMS_Id",
            "MS"."ASMC_SectionName",
            "FYP"."FYP_Receipt_No",
            "FYP"."FYP_Date",
            "FYP"."FYP_Bank_Or_Cash",
            "FYP"."FYP_DD_Cheque_no";
    ELSE
        RETURN QUERY
        SELECT 
            "STD"."AMST_MobileNo",
            "STD"."AMST_Id",
            "STD"."MI_Id",
            "YS"."ASMAY_Id",
            ("STD"."AMST_FirstName" || ' ' || "STD"."AMST_MiddleName" || '' || "STD"."AMST_LastName")::text AS "StudentName",
            "YS"."ASMCL_Id",
            "CL"."ASMCL_ClassName",
            "YS"."ASMS_Id",
            "MS"."ASMC_SectionName",
            "FYP"."FYP_Receipt_No",
            "FYP"."FYP_Date" AS "ReceiptDate",
            sum("FS"."FSS_TotalToBePaid") AS "TotalAmount",
            sum("FS"."FSS_ToBePaid") AS "TotalToBePaid",
            (sum("FS"."FSS_TotalToBePaid") - sum("FS"."FSS_ToBePaid")) AS "TotalPaidAmount",
            CASE 
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'C' THEN 'Cash'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'O' THEN 'Online'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'R' THEN 'RTGS'
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'U' THEN 'UPI'
            END::text AS "Payment_Mode",
            "FYP"."FYP_DD_Cheque_no"
        FROM "dbo"."Fee_Y_Payment_School_Student" "FYPS"
        INNER JOIN "dbo"."Fee_Y_Payment" "FYP" ON "FYPS"."FYP_Id" = "FYP"."FYP_Id"
        INNER JOIN "dbo"."Adm_M_Student" "STD" ON "FYPS"."AMST_Id" = "STD"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" "YS" ON "STD"."AMST_Id" = "YS"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" "Y" ON "YS"."ASMAY_Id" = "Y"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" "CL" ON "YS"."ASMCL_Id" = "CL"."ASMCL_Id" AND "FYPS"."ASMAY_Id" = "Y"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" "MS" ON "YS"."ASMS_Id" = "MS"."ASMS_Id"
        INNER JOIN "dbo"."Fee_Student_Status" "FS" ON "FS"."AMST_Id" = "YS"."AMST_Id" AND "FS"."ASMAY_Id" = "YS"."ASMAY_Id"
        WHERE "YS"."ASMAY_Id" = p_ASMAY_Id 
            AND "STD"."MI_Id" = p_MI_Id 
            AND "FYP"."FYP_Date" BETWEEN p_FromDate AND p_ToDate 
            AND "FYP"."FYP_Bank_Or_Cash" = p_PaymentMode
        GROUP BY 
            "STD"."AMST_MobileNo",
            "STD"."AMST_Id",
            "STD"."MI_Id",
            "YS"."ASMAY_Id",
            ("STD"."AMST_FirstName" || ' ' || "STD"."AMST_MiddleName" || '' || "STD"."AMST_LastName"),
            "YS"."ASMCL_Id",
            "CL"."ASMCL_ClassName",
            "YS"."ASMS_Id",
            "MS"."ASMC_SectionName",
            "FYP"."FYP_Receipt_No",
            "FYP"."FYP_Date",
            "FYP"."FYP_Bank_Or_Cash",
            "FYP"."FYP_DD_Cheque_no";
    END IF;
END;
$$;