CREATE OR REPLACE FUNCTION "HR_Training_Details"(
    p_mi_id TEXT,
    p_hrme_id TEXT,
    p_flag TEXT
)
RETURNS TABLE(
    "HREXTTRN_Id" INTEGER,
    "HRME_Id" INTEGER,
    "NAME" TEXT,
    "HRMETRCEN_Id" INTEGER,
    "HRMETRTY_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF(p_flag = 'APPROVED') THEN
        RETURN QUERY
        SELECT 
            "A"."HREXTTRN_Id",
            "B"."HRME_Id",
            CONCAT(COALESCE("B"."HRME_EmployeeFirstName",''),' ',COALESCE("B"."HRME_EmployeeMiddleName",''),' ',COALESCE("B"."HRME_EmployeeLastName",'')) AS "NAME",
            "D"."HRMETRCEN_Id",
            "E"."HRMETRTY_Id"
        FROM "HR_External_Training" "A"
        INNER JOIN "HR_Master_Employee" "B" ON "A"."HRME_Id" = "B"."HRME_Id"
        INNER JOIN "HR_External_Training_Approval" "C" ON "C"."HREXTTRN_Id" = "A"."HREXTTRN_Id"
        INNER JOIN "HR_Master_External_TrainingCenters" "D" ON "D"."HRMETRCEN_Id" = "A"."HRMETRCEN_Id"
        INNER JOIN "HR_Master_External_TrainingType" "E" ON "E"."HRMETRTY_Id" = "A"."HRMETRTY_Id"
        WHERE "A"."mi_id" = p_mi_id 
        AND "C"."HREXTTRNAPP_ApprovalFlg" = p_flag 
        AND CURRENT_DATE BETWEEN CAST("A"."HREXTTRN_StartDate" AS DATE) AND CAST("A"."HREXTTRN_EndDate" AS DATE);
        
    ELSIF(p_flag = 'REJECTED') THEN
        RETURN QUERY
        SELECT 
            "A"."HREXTTRN_Id",
            "B"."HRME_Id",
            CONCAT(COALESCE("B"."HRME_EmployeeFirstName",''),' ',COALESCE("B"."HRME_EmployeeMiddleName",''),' ',COALESCE("B"."HRME_EmployeeLastName",'')) AS "NAME",
            "D"."HRMETRCEN_Id",
            "E"."HRMETRTY_Id"
        FROM "HR_External_Training" "A"
        INNER JOIN "HR_Master_Employee" "B" ON "A"."HRME_Id" = "B"."HRME_Id"
        INNER JOIN "HR_External_Training_Approval" "C" ON "C"."HREXTTRN_Id" = "A"."HREXTTRN_Id"
        INNER JOIN "HR_Master_External_TrainingCenters" "D" ON "D"."HRMETRCEN_Id" = "A"."HRMETRCEN_Id"
        INNER JOIN "HR_Master_External_TrainingType" "E" ON "E"."HRMETRTY_Id" = "A"."HRMETRTY_Id"
        WHERE "A"."mi_id" = p_mi_id 
        AND "C"."HREXTTRNAPP_ApprovalFlg" = p_flag;
        
    END IF;
    
    RETURN;
END;
$$;