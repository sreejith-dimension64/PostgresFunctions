CREATE OR REPLACE FUNCTION "dbo"."induction_view_list_details_proc"(p_HRTCR_Id integer)
RETURNS TABLE(
    "Trainer_Name" text,
    "HRTCRD_Date" date,
    "HRTCRD_ActiveFlg" boolean,
    "HRTCR_ActiveFlag" boolean,
    "HRTCRD_StartTime" time,
    "HRTCRD_EndTime" time,
    "HRTCRD_Content" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ck integer;
BEGIN
    SELECT "HRTCR_InternalORExternalFlg" INTO v_ck 
    FROM "HR_Training_Create" 
    WHERE "HRTCR_Id" = p_HRTCR_Id;
    
    IF (v_ck = 0) THEN
        RETURN QUERY
        SELECT DISTINCT 
            CONCAT(
                (SELECT CASE WHEN "HRMETR_Id" IS NOT NULL THEN "HRMETR_Name" END 
                 FROM "HR_Master_External_Trainer_Creation"  
                 WHERE "HRMETR_Id" = "CD"."HRME_Id"),
                (SELECT CASE WHEN "HRME_Id" IS NOT NULL THEN 
                    COALESCE("HRME_EmployeeFirstName", '') || '' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '') 
                 END 
                 FROM "HR_Master_Employee" 
                 WHERE "HRME_id" = "CD"."HRME_Id")
            ) AS "Trainer_Name",
            CAST("CD"."HRTCRINTTR_StartDate" AS date) AS "HRTCRD_Date",
            "CD"."HRTCRINTTR_ActiveFlg" AS "HRTCRD_ActiveFlg",
            "C"."HRTCR_ActiveFlag" AS "HRTCR_ActiveFlag",
            "CD"."HRTCRINTTR_StartTime" AS "HRTCRD_StartTime",
            "CD"."HRTCRINTTR_EndTime" AS "HRTCRD_EndTime",
            "CD"."HRTCRINTTR_TrainingDesc" AS "HRTCRD_Content"
        FROM "HR_Training_Create" "C" 
        LEFT JOIN "HR_Training_Create_IntTrainer" "CD" ON "C"."HRTCR_Id" = "CD"."HRTCR_Id" 
        WHERE "CD"."HRTCR_Id" = p_HRTCR_Id;
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            CONCAT(
                (SELECT CASE WHEN "HRMETR_Id" IS NOT NULL THEN "HRMETR_Name" END 
                 FROM "HR_Master_External_Trainer_Creation"  
                 WHERE "HRMETR_Id" = "CD"."HRME_Id"),
                (SELECT CASE WHEN "HRME_Id" IS NOT NULL THEN 
                    COALESCE("HRME_EmployeeFirstName", '') || '' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '') 
                 END 
                 FROM "HR_Master_Employee" 
                 WHERE "HRME_id" = "CD"."HRME_Id")
            ) AS "Trainer_Name",
            CAST("CD"."HRTCREXTTR_StartDate" AS date) AS "HRTCRD_Date",
            "CD"."HRTCREXTTR_ActiveFlg" AS "HRTCRD_ActiveFlg",
            "C"."HRTCR_ActiveFlag" AS "HRTCR_ActiveFlag",
            "CD"."HRTCREXTTR_StartTime" AS "HRTCRD_StartTime",
            "CD"."HRTCREXTTR_EndTime" AS "HRTCRD_EndTime",
            "CD"."HRTCREXTTR_TrainingDesc" AS "HRTCRD_Content"
        FROM "HR_Training_Create" "C" 
        LEFT JOIN "HR_Training_Create_ExtTrainer" "CD" ON "C"."HRTCR_Id" = "CD"."HRTCR_Id" 
        WHERE "CD"."HRTCR_Id" = p_HRTCR_Id;
    END IF;
    
    RETURN;
END;
$$;