CREATE OR REPLACE FUNCTION "dbo"."Induction_Training_Create_List_proc"(
    p_MI_Id INT,
    p_user_id INT
)
RETURNS TABLE(
    "HRTCR_Id" INT,
    "HRTCR_PrgogramName" VARCHAR,
    "MinDate" DATE,
    "MaxDate" DATE,
    "HRTCR_InternalORExternalFlg" VARCHAR,
    "HRTCR_ActiveFlag" BOOLEAN,
    "HRTCR_StatusFlg" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
    v_ixf INT;
    v_hrmeid INT;
    v_P_hrme_id INT;
    v_I_hrme_id INT;
    v_id INT;
    v_E_hrme_id INT;
BEGIN
    SELECT "Emp_Code" INTO v_hrmeid 
    FROM "IVRM_Staff_User_Login" 
    WHERE "Id" = p_user_id;

    SELECT "RoleId" INTO v_id 
    FROM "ApplicationUserRole"  
    WHERE "UserId" = p_user_id;
    
    SELECT "id" INTO v_count 
    FROM "ApplicationRole" 
    WHERE "Id" = v_id;

    SELECT COUNT(*) INTO v_P_hrme_id 
    FROM "HR_Training_Create_Participants" 
    WHERE "HRME_Id" = v_hrmeid;

    SELECT COUNT(*) INTO v_I_hrme_id 
    FROM "HR_Training_Create_IntTrainer" 
    WHERE "HRME_Id" = v_hrmeid;
    
    SELECT COUNT(*) INTO v_E_hrme_id 
    FROM "HR_Training_Create_ExtTrainer"  
    WHERE "HRME_Id" = v_hrmeid;

    IF (v_count = 1 OR v_count = 2 OR v_count = 3 OR v_count = 4) THEN
        RETURN QUERY
        SELECT 
            "C"."HRTCR_Id" AS "HRTCR_Id", 
            "C"."HRTCR_PrgogramName" AS "HRTCR_PrgogramName", 
            MIN(CAST("HRTCRINTTR_StartDate" AS DATE)) AS "MinDate",
            MAX(CAST("HRTCRINTTR_EndDate" AS DATE)) AS "MaxDate", 
            "C"."HRTCR_InternalORExternalFlg" AS "HRTCR_InternalORExternalFlg", 
            "C"."HRTCR_ActiveFlag" AS "HRTCR_ActiveFlag", 
            "C"."HRTCR_StatusFlg" AS "HRTCR_StatusFlg"
        FROM "HR_Training_Create" "C"
        INNER JOIN "HR_Training_Create_IntTrainer" "Ci" ON "C"."HRTCR_Id" = "Ci"."HRTCR_Id" 
        WHERE "C"."MI_Id" = p_MI_Id 
        GROUP BY "C"."HRTCR_Id", "C"."HRTCR_PrgogramName", "C"."HRTCR_ActiveFlag", "C"."HRTCR_InternalORExternalFlg", "C"."HRTCR_StatusFlg"
        
        UNION ALL
        
        SELECT 
            "C"."HRTCR_Id" AS "HRTCR_Id", 
            "C"."HRTCR_PrgogramName" AS "HRTCR_PrgogramName", 
            MIN(CAST("HRTCREXTTR_StartDate" AS DATE)) AS "MinDate",
            MAX(CAST("HRTCREXTTR_EndDate" AS DATE)) AS "MaxDate", 
            "C"."HRTCR_InternalORExternalFlg" AS "HRTCR_InternalORExternalFlg", 
            "C"."HRTCR_ActiveFlag" AS "HRTCR_ActiveFlag", 
            "C"."HRTCR_StatusFlg" AS "HRTCR_StatusFlg"
        FROM "HR_Training_Create" "C"
        INNER JOIN "HR_Training_Create_ExtTrainer" "Cx" ON "C"."HRTCR_Id" = "Cx"."HRTCR_Id" 
        WHERE "C"."MI_Id" = p_MI_Id
        GROUP BY "C"."HRTCR_Id", "C"."HRTCR_PrgogramName", "C"."HRTCR_ActiveFlag", "C"."HRTCR_InternalORExternalFlg", "C"."HRTCR_StatusFlg";
        
        RAISE NOTICE 'uuuuuuuuuuuuuuu';
        
    ELSIF (v_I_hrme_id > 0 OR v_E_hrme_id > 0) THEN
        RETURN QUERY
        SELECT 
            "C"."HRTCR_Id" AS "HRTCR_Id", 
            "C"."HRTCR_PrgogramName" AS "HRTCR_PrgogramName", 
            MIN(CAST("HRTCRINTTR_StartDate" AS DATE)) AS "MinDate",
            MAX(CAST("HRTCRINTTR_StartDate" AS DATE)) AS "MaxDate", 
            "C"."HRTCR_InternalORExternalFlg" AS "HRTCR_InternalORExternalFlg", 
            "C"."HRTCR_ActiveFlag" AS "HRTCR_ActiveFlag", 
            "C"."HRTCR_StatusFlg" AS "HRTCR_StatusFlg"
        FROM "HR_Training_Create" "C"
        INNER JOIN "HR_Training_Create_IntTrainer" "Ci" ON "C"."HRTCR_Id" = "Ci"."HRTCR_Id" 
        WHERE "Ci"."HRME_Id" = v_hrmeid
        GROUP BY "C"."HRTCR_Id", "C"."HRTCR_PrgogramName", "C"."HRTCR_ActiveFlag", "C"."HRTCR_InternalORExternalFlg", "C"."HRTCR_StatusFlg";
        
    ELSIF (v_P_hrme_id > 0) THEN
        RETURN QUERY
        SELECT 
            "C"."HRTCR_Id" AS "HRTCR_Id", 
            "C"."HRTCR_PrgogramName" AS "HRTCR_PrgogramName", 
            MIN(CAST("HRTCR_EndDate" AS DATE)) AS "MinDate",
            MAX(CAST("HRTCR_StartDate" AS DATE)) AS "MaxDate", 
            "C"."HRTCR_InternalORExternalFlg" AS "HRTCR_InternalORExternalFlg", 
            "C"."HRTCR_ActiveFlag" AS "HRTCR_ActiveFlag", 
            "C"."HRTCR_StatusFlg" AS "HRTCR_StatusFlg"
        FROM "HR_Training_Create" "C"
        INNER JOIN "HR_Training_Create_Participants" "Ci" ON "C"."HRTCR_Id" = "Ci"."HRTCR_Id" 
        WHERE "Ci"."HRME_Id" = v_hrmeid
        GROUP BY "C"."HRTCR_Id", "C"."HRTCR_PrgogramName", "C"."HRTCR_ActiveFlag", "C"."HRTCR_InternalORExternalFlg", "C"."HRTCR_StatusFlg";
    END IF;
    
    RETURN;
END;
$$;