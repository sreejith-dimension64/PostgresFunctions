CREATE OR REPLACE FUNCTION "dbo"."INV_PR_List"(@MI_Id bigint)
RETURNS TABLE (
    "mI_Id" bigint,
    "invmpR_Id" bigint,
    "employeename" text,
    "HRME_Id" bigint,
    "invmpR_PRNo" varchar,
    "invmpR_PRDate" timestamp,
    "invmpR_Remarks" text,
    "INVMPR_PICreatedFlg" boolean,
    "invmpR_ApproxTotAmount" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."MI_Id" as "mI_Id", 
        a."INVMPR_Id" as "invmpR_Id", 
        (COALESCE(b."HRME_EmployeeFirstName",'') || COALESCE(b."HRME_EmployeeMiddleName",'') || COALESCE(b."HRME_EmployeeLastName",'')) as "employeename", 
        a."HRME_Id", 
        a."INVMPR_PRNo" as "invmpR_PRNo", 
        a."INVMPR_PRDate" as "invmpR_PRDate", 
        a."INVMPR_Remarks" as "invmpR_Remarks", 
        a."INVMPR_PICreatedFlg", 
        a."INVMPR_ApproxTotAmount" as "invmpR_ApproxTotAmount" 
    FROM "inv"."INV_M_PurchaseRequisition" a 
    LEFT JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
    WHERE a."INVMPR_ActiveFlg" = true 
        AND a."MI_Id" = @MI_Id 
        AND a."INVMPR_PICreatedFlg" = false 
    ORDER BY a."INVMPR_Id" DESC;
END;
$$;