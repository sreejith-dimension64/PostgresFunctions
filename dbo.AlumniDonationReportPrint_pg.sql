CREATE OR REPLACE FUNCTION "dbo"."AlumniDonationReportPrint"(
    "MI_Id" bigint,
    "Fromdate" timestamp,
    "Todate" timestamp,
    "userid" bigint,
    "Role" varchar(50)
)
RETURNS TABLE(
    "ALDON_DonorName" varchar,
    "LeftBatch" varchar,
    "ALDON_Date" timestamp,
    "ALMDON_DonationName" varchar,
    "ALDON_Amount" numeric,
    "ALDON_ReceiptNo" varchar,
    "ALDON_ModeOfPayment" varchar,
    "ALMST_MobileNo" varchar,
    "ALMST_emailId" varchar,
    "ALDON_DonarPANNo" varchar,
    "ALDON_Id" bigint,
    "MI_PAN" varchar,
    "ALDON_ReferenceNo" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    "alsregid" bigint;
BEGIN

    IF "Role" = 'Alumni' THEN
        SELECT "ALSREG_Id" INTO "alsregid" 
        FROM "alu"."IVRM_User_Login_Alumni" 
        WHERE "IVRMUL_Id" = "userid";
        
        RETURN QUERY
        SELECT DISTINCT 
            a."ALDON_DonorName", 
            d."ASMAY_Year" AS "LeftBatch", 
            a."ALDON_Date",  
            b."ALMDON_DonationName", 
            a."ALDON_Amount",
            a."ALDON_ReceiptNo", 
            a."ALDON_ModeOfPayment", 
            c."ALMST_MobileNo", 
            c."ALMST_emailId", 
            a."ALDON_DonarPANNo", 
            a."ALDON_Id",
            e."MI_PAN", 
            a."ALDON_ReferenceNo"
        FROM "alu"."Alumni_Donation" a 
        INNER JOIN "alu"."Alumni_Master_Donation" b ON b."ALMDON_Id" = a."ALMDON_Id"  
        LEFT JOIN "alu"."Alumni_Master_Student" c ON a."ALSREG_Id" = c."ALSREG_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = c."ASMAY_Id_Left"
        LEFT JOIN "Master_Institution" e ON e."MI_Id" = b."MI_Id"
        WHERE CAST(a."ALDON_Date" AS date) BETWEEN "Fromdate" AND "Todate"  
            AND b."MI_Id" = "MI_Id" 
            AND a."ALSREG_Id" = "alsregid" 
        ORDER BY a."ALDON_Id";
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            a."ALDON_DonorName", 
            d."ASMAY_Year" AS "LeftBatch", 
            a."ALDON_Date",  
            b."ALMDON_DonationName", 
            a."ALDON_Amount",
            a."ALDON_ReceiptNo", 
            a."ALDON_ModeOfPayment", 
            c."ALMST_MobileNo", 
            c."ALMST_emailId", 
            a."ALDON_DonarPANNo", 
            a."ALDON_Id",
            e."MI_PAN", 
            a."ALDON_ReferenceNo"
        FROM "alu"."Alumni_Donation" a 
        INNER JOIN "alu"."Alumni_Master_Donation" b ON b."ALMDON_Id" = a."ALMDON_Id"  
        LEFT JOIN "alu"."Alumni_Master_Student" c ON a."ALSREG_Id" = c."ALSREG_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = c."ASMAY_Id_Left"
        LEFT JOIN "Master_Institution" e ON e."MI_Id" = b."MI_Id"
        WHERE CAST(a."ALDON_Date" AS date) BETWEEN "Fromdate" AND "Todate"  
            AND b."MI_Id" = "MI_Id"  
        ORDER BY a."ALDON_Id";
    END IF;

END;
$$;