CREATE OR REPLACE FUNCTION "dbo"."FEE_THIRDPARTY_TRANSACTION_GM" (
    "p_MI_Id" BIGINT,
    "p_ASMAY_Id" BIGINT,
    "p_FYP_Id" BIGINT,
    "p_FYPTP_Id" BIGINT
)
RETURNS TABLE (
    "FYPTP_Id" BIGINT,
    "AMST_FirstName" TEXT,
    "FYP_DD_Cheque_Date" TIMESTAMP,
    "FMH_FeeName" TEXT,
    "FYP_Remarks" TEXT,
    "FMH_Id" BIGINT,
    "FYP_Receipt_No" TEXT,
    "FYP_Bank_Name" TEXT,
    "FYP_Bank_Or_Cash" TEXT,
    "FYP_Tot_Amount" NUMERIC,
    "FYP_DD_Cheque_No" TEXT,
    "FYP_Id" BIGINT,
    "FYP_Date" TIMESTAMP,
    "ASMAY_Year" TEXT,
    "FYPTP_Towards" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_FatherName" TEXT,
    "AMST_MotherName" TEXT,
    "AMST_MobileNo" TEXT,
    "AMST_DOB" TIMESTAMP,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "UserName" TEXT,
    "Installment" TEXT,
    "GroupName" TEXT,
    "classname" TEXT,
    "sectionname" TEXT,
    "FYPTP_Name" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_COUNT" BIGINT;
BEGIN
    SELECT COUNT(1) INTO "v_COUNT" 
    FROM "Fee_Y_Payment_School_Student" 
    WHERE "FYP_Id" = "p_FYP_Id";

    IF "v_COUNT" > 0 THEN
        RETURN QUERY
        SELECT DISTINCT
            NULL::BIGINT AS "FYPTP_Id",
            (COALESCE(f."AMST_FirstName", '') || ' ' || COALESCE(f."AMST_MiddleName", '') || ' ' || COALESCE(f."AMST_LastName", '')) AS "AMST_FirstName",
            NULL::TIMESTAMP AS "FYP_DD_Cheque_Date",
            c."FMH_FeeName" AS "FMH_FeeName",
            NULL::TEXT AS "FYP_Remarks",
            NULL::BIGINT AS "FMH_Id",
            a."FYP_Receipt_No" AS "FYP_Receipt_No",
            NULL::TEXT AS "FYP_Bank_Name",
            a."FYP_Bank_Or_Cash" AS "FYP_Bank_Or_Cash",
            e."FTP_TotalPaidAmount" AS "FYP_Tot_Amount",
            NULL::TEXT AS "FYP_DD_Cheque_No",
            NULL::BIGINT AS "FYP_Id",
            a."FYP_Date" AS "FYP_Date",
            d."ASMAY_Year" AS "ASMAY_Year",
            NULL::TEXT AS "FYPTP_Towards",
            f."AMST_AdmNo" AS "AMST_AdmNo",
            COALESCE(f."AMST_FatherName", '') AS "AMST_FatherName",
            COALESCE(f."AMST_MotherName", '') AS "AMST_MotherName",
            f."AMST_MobileNo" AS "AMST_MobileNo",
            f."AMST_DOB" AS "AMST_DOB",
            h."ASMCL_ClassName" AS "ASMCL_ClassName",
            i."ASMC_SectionName" AS "ASMC_SectionName",
            j."UserName" AS "UserName",
            "FTI"."FTI_Name" AS "Installment",
            NULL::TEXT AS "GroupName",
            NULL::TEXT AS "classname",
            NULL::TEXT AS "sectionname",
            NULL::TEXT AS "FYPTP_Name"
        FROM "fee_Y_payment" a
        INNER JOIN "Fee_Y_Payment_ThirdParty" b ON a."FYP_Id" = b."FYP_Id"
        INNER JOIN "Fee_Master_Head" c ON b."FMH_Id" = c."FMH_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON a."ASMAY_ID" = d."ASMAY_Id" AND a."MI_Id" = d."MI_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" e ON e."FYP_Id" = a."FYP_Id"
        INNER JOIN "adm_M_student" f ON f."AMST_Id" = e."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" g ON g."AMST_Id" = e."AMST_Id" AND g."ASMAY_Id" = a."ASMAY_ID"
        INNER JOIN "Adm_School_M_Class" h ON h."ASMCL_Id" = g."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" i ON i."ASMS_Id" = g."ASMS_Id"
        INNER JOIN "ApplicationUser" j ON j."id" = a."user_id"
        INNER JOIN "Fee_T_Payment" "TP" ON "TP"."FYP_Id" = a."FYP_Id"
        INNER JOIN "Fee_student_status" fss ON fss."AMST_Id" = e."AMST_Id" AND fss."FMH_Id" = b."FMH_Id" AND fss."ASMAY_Id" = e."ASMAY_Id" AND "TP"."FMA_Id" = fss."FMA_Id"
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = fss."FTI_Id"
        INNER JOIN "Fee_Master_Installment" fmi ON fmi."FMI_Id" = "FTI"."FMI_Id"
        WHERE d."MI_Id" = "p_MI_Id" 
        AND a."FYP_Id" = "p_FYP_Id" 
        AND b."FYPTP_Id" = "p_FYPTP_Id" 
        AND c."FMH_ActiveFlag" = 1
        AND d."ASMAY_ActiveFlag" = 1;
    ELSE
        IF "p_MI_Id" = 48 THEN
            RETURN QUERY
            SELECT 
                b."FYPTP_Id" AS "FYPTP_Id",
                b."FYPTP_Name" AS "AMST_FirstName",
                a."FYP_DD_Cheque_Date" AS "FYP_DD_Cheque_Date",
                c."FMH_FeeName" AS "FMH_FeeName",
                a."FYP_Remarks" AS "FYP_Remarks",
                c."FMH_Id" AS "FMH_Id",
                a."FYP_Receipt_No" AS "FYP_Receipt_No",
                a."FYP_Bank_Name" AS "FYP_Bank_Name",
                a."FYP_Bank_Or_Cash" AS "FYP_Bank_Or_Cash",
                a."FYP_Tot_Amount" AS "FYP_Tot_Amount",
                a."FYP_DD_Cheque_No" AS "FYP_DD_Cheque_No",
                a."FYP_Id" AS "FYP_Id",
                a."FYP_Date" AS "FYP_Date",
                d."ASMAY_Year" AS "ASMAY_Year",
                b."FYPTP_Towards" AS "FYPTP_Towards",
                NULL::TEXT AS "AMST_AdmNo",
                NULL::TEXT AS "AMST_FatherName",
                NULL::TEXT AS "AMST_MotherName",
                NULL::TEXT AS "AMST_MobileNo",
                NULL::TIMESTAMP AS "AMST_DOB",
                NULL::TEXT AS "ASMCL_ClassName",
                NULL::TEXT AS "ASMC_SectionName",
                NULL::TEXT AS "UserName",
                NULL::TEXT AS "Installment",
                NULL::TEXT AS "GroupName",
                NULL::TEXT AS "classname",
                NULL::TEXT AS "sectionname",
                NULL::TEXT AS "FYPTP_Name"
            FROM "Fee_Y_Payment" a
            INNER JOIN "Fee_Y_Payment_ThirdParty" b ON a."FYP_Id" = b."FYP_Id"
            INNER JOIN "Fee_Master_Head" c ON b."FMH_Id" = c."FMH_Id"
            INNER JOIN "Adm_School_M_Academic_Year" d ON a."ASMAY_ID" = d."ASMAY_Id" AND a."MI_Id" = d."MI_Id"
            WHERE d."MI_Id" = "p_MI_Id"
            AND a."FYP_Id" = "p_FYP_Id"
            AND b."FYPTP_Id" = "p_FYPTP_Id"
            AND c."FMH_ActiveFlag" = 1
            AND d."ASMAY_ActiveFlag" = 1
            ORDER BY d."ASMAY_Year";
        ELSIF "p_MI_Id" = 68 THEN
            RETURN QUERY
            SELECT 
                b."FYPTP_Id" AS "FYPTP_Id",
                NULL::TEXT AS "AMST_FirstName",
                a."FYP_DD_Cheque_Date" AS "FYP_DD_Cheque_Date",
                c."FMH_FeeName" AS "FMH_FeeName",
                a."FYP_Remarks" AS "FYP_Remarks",
                c."FMH_Id" AS "FMH_Id",
                a."FYP_Receipt_No" AS "FYP_Receipt_No",
                a."FYP_Bank_Name" AS "FYP_Bank_Name",
                a."FYP_Bank_Or_Cash" AS "FYP_Bank_Or_Cash",
                a."FYP_Tot_Amount" AS "FYP_Tot_Amount",
                a."FYP_DD_Cheque_No" AS "FYP_DD_Cheque_No",
                a."FYP_Id" AS "FYP_Id",
                a."FYP_Date" AS "FYP_Date",
                d."ASMAY_Year" AS "ASMAY_Year",
                b."FYPTP_Towards" AS "FYPTP_Towards",
                NULL::TEXT AS "AMST_AdmNo",
                NULL::TEXT AS "AMST_FatherName",
                NULL::TEXT AS "AMST_MotherName",
                NULL::TEXT AS "AMST_MobileNo",
                NULL::TIMESTAMP AS "AMST_DOB",
                NULL::TEXT AS "ASMCL_ClassName",
                NULL::TEXT AS "ASMC_SectionName",
                NULL::TEXT AS "UserName",
                NULL::TEXT AS "Installment",
                COALESCE(b."FMG_GroupName", '') AS "GroupName",
                COALESCE(f."ASMCL_ClassName", '') AS "classname",
                COALESCE(g."ASMC_SectionName", '') AS "sectionname",
                b."FYPTP_Name" AS "FYPTP_Name"
            FROM "Fee_Y_Payment" a
            INNER JOIN "Fee_Y_Payment_ThirdParty" b ON a."FYP_Id" = b."FYP_Id"
            INNER JOIN "Fee_Master_Head" c ON b."FMH_Id" = c."FMH_Id"
            INNER JOIN "Adm_School_M_Academic_Year" d ON a."ASMAY_ID" = d."ASMAY_Id" AND a."MI_Id" = d."MI_Id"
            LEFT JOIN "Adm_School_Y_Student" e ON e."ASMAY_Id" = a."ASMAY_ID" AND b."AMST_Id" = e."AMST_Id"
            LEFT JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = e."ASMCL_Id"
            LEFT JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = e."ASMS_Id"
            WHERE d."MI_Id" = "p_MI_Id"
            AND a."FYP_Id" = "p_FYP_Id"
            AND b."FYPTP_Id" = "p_FYPTP_Id"
            AND c."FMH_ActiveFlag" = 1
            AND d."ASMAY_ActiveFlag" = 1
            ORDER BY d."ASMAY_Year";
        ELSE
            RETURN QUERY
            SELECT 
                b."FYPTP_Id" AS "FYPTP_Id",
                NULL::TEXT AS "AMST_FirstName",
                a."FYP_DD_Cheque_Date" AS "FYP_DD_Cheque_Date",
                c."FMH_FeeName" AS "FMH_FeeName",
                a."FYP_Remarks" AS "FYP_Remarks",
                c."FMH_Id" AS "FMH_Id",
                a."FYP_Receipt_No" AS "FYP_Receipt_No",
                a."FYP_Bank_Name" AS "FYP_Bank_Name",
                a."FYP_Bank_Or_Cash" AS "FYP_Bank_Or_Cash",
                a."FYP_Tot_Amount" AS "FYP_Tot_Amount",
                a."FYP_DD_Cheque_No" AS "FYP_DD_Cheque_No",
                a."FYP_Id" AS "FYP_Id",
                a."FYP_Date" AS "FYP_Date",
                d."ASMAY_Year" AS "ASMAY_Year",
                b."FYPTP_Towards" AS "FYPTP_Towards",
                NULL::TEXT AS "AMST_AdmNo",
                NULL::TEXT AS "AMST_FatherName",
                NULL::TEXT AS "AMST_MotherName",
                NULL::TEXT AS "AMST_MobileNo",
                NULL::TIMESTAMP AS "AMST_DOB",
                NULL::TEXT AS "ASMCL_ClassName",
                NULL::TEXT AS "ASMC_SectionName",
                NULL::TEXT AS "UserName",
                NULL::TEXT AS "Installment",
                NULL::TEXT AS "GroupName",
                NULL::TEXT AS "classname",
                NULL::TEXT AS "sectionname",
                b."FYPTP_Name" AS "FYPTP_Name"
            FROM "Fee_Y_Payment" a
            INNER JOIN "Fee_Y_Payment_ThirdParty" b ON a."FYP_Id" = b."FYP_Id"
            INNER JOIN "Fee_Master_Head" c ON b."FMH_Id" = c."FMH_Id"
            INNER JOIN "Adm_School_M_Academic_Year" d ON a."ASMAY_ID" = d."ASMAY_Id" AND a."MI_Id" = d."MI_Id"
            WHERE d."MI_Id" = "p_MI_Id"
            AND a."FYP_Id" = "p_FYP_Id"
            AND b."FYPTP_Id" = "p_FYPTP_Id"
            AND c."FMH_ActiveFlag" = 1
            AND d."ASMAY_ActiveFlag" = 1
            ORDER BY d."ASMAY_Year";
        END IF;
    END IF;
END;
$$;