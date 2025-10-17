CREATE OR REPLACE FUNCTION "dbo"."AlumniRegistrationReport"(
    p_MI_Id bigint,
    p_Fromdate timestamp,
    p_Todate timestamp,
    p_Type varchar(50)
)
RETURNS TABLE (
    "ALSREG_MemberName" varchar,
    "ALSREG_EmailId" varchar,
    "ALSREG_MobileNo" varchar,
    "ASMAY_Year" varchar,
    "ALSREG_ApprovalDate" timestamp,
    "FYP_Date" timestamp,
    "FYP_Tot_Amount" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_Type = 'Details' THEN
        RETURN QUERY
        SELECT 
            a."ALSREG_MemberName",
            a."ALSREG_EmailId",
            a."ALSREG_MobileNo",
            b."ASMAY_Year",
            a."ALSREG_ApprovalDate",
            NULL::timestamp AS "FYP_Date",
            NULL::numeric AS "FYP_Tot_Amount"
        FROM "alu"."Alumni_Student_Registration" a
        INNER JOIN "Adm_School_M_Academic_Year" b ON a."ALSREG_LeftYear" = b."ASMAY_Id"
        WHERE a."MI_Id" = b."MI_Id" 
            AND a."MI_Id" = p_MI_Id 
            AND a."CreatedDate"::date BETWEEN p_Fromdate AND p_Todate;
    
    ELSIF p_Type = 'Payment' THEN
        RETURN QUERY
        SELECT 
            c."ALSREG_MemberName",
            c."ALSREG_EmailId",
            c."ALSREG_MobileNo",
            d."ASMAY_Year",
            NULL::timestamp AS "ALSREG_ApprovalDate",
            b."FYP_Date",
            b."FYP_Tot_Amount"
        FROM "alu"."Fee_Y_Payment_Alumni" a
        INNER JOIN "Fee_Y_Payment" b ON a."FYP_Id" = b."FYP_Id"
        LEFT JOIN "alu"."Alumni_Student_Registration" c ON a."ALSREG_Id" = c."ALSREG_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON c."ALSREG_LeftYear" = d."ASMAY_Id"
        WHERE c."MI_Id" = b."MI_Id" 
            AND c."MI_Id" = p_MI_Id 
            AND b."FYP_Date"::date BETWEEN p_Fromdate AND p_Todate;
    
    END IF;
    
    RETURN;
END;
$$;