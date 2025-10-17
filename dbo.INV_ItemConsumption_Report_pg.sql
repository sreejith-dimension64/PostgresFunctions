CREATE OR REPLACE FUNCTION "dbo"."INV_ItemConsumption_Report"(
    "p_MI_Id" BIGINT,
    "p_startdate" VARCHAR(25),
    "p_enddate" VARCHAR(25),
    "p_typeflag" VARCHAR(50),
    "p_optionflag" VARCHAR(50),
    "p_INVMI_Id" TEXT,
    "p_HRME_Id" TEXT,
    "p_HRMD_Id" TEXT,
    "p_AMST_Id" TEXT
)
RETURNS SETOF REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
    "result_cursor" REFCURSOR := 'result_cursor';
BEGIN

    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := ' AND "INVMIC_ICDate"::date BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    DROP TABLE IF EXISTS "InvStaffwiseIC_Temp";

    CREATE TEMP TABLE "InvStaffwiseIC_Temp" AS
    SELECT "INVMIC_Id", "Mastericcount" 
    FROM (
        SELECT "INVMIC_Id", COUNT(*) AS "Mastericcount" 
        FROM "INV"."INV_M_IC_Staff" 
        WHERE "INVMICST_ActiveFlg" = TRUE 
        GROUP BY "INVMIC_Id" 
        HAVING COUNT(*) >= 1
    ) AS "NEW" 
    ORDER BY "Mastericcount";

    IF ("p_typeflag" = 'All') THEN
        "v_Slqdymaic" := ' 
        SELECT DISTINCT "MIC"."INVMIC_Id", "MIC"."INVMST_Id", "TIC"."INVMI_Id", "MI"."INVMI_ItemName", 
               "TIC"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
               "MIC"."INVMIC_StuOtherFlg", "INVMIC_ICNo", "INVMIC_ICDate", "INVMIC_Remarks",
               "TIC"."INVTIC_BatchNo", "INVTIC_ICQty", "INVTIC_Naration"
        FROM "INV"."INV_M_ItemConsumption" "MIC"
        LEFT JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
        LEFT JOIN "INV"."INV_Master_Store" "MST" ON "MST"."INVMST_Id" = "MIC"."INVMST_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TIC"."INVMUOM_Id"
        WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE 
              AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates" || ' 
        ORDER BY "MIC"."INVMIC_ICDate"';

        OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
        RETURN NEXT "result_cursor";
    END IF;

    IF ("p_typeflag" = 'Overall') THEN
        IF "p_optionflag" = 'Item' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "INVMI_Id", "INVMI_ItemName", "INVMI_ItemCode", SUM("INVTIC_ICQty") AS "icQty"
            FROM (
                SELECT DISTINCT "TIC"."INVMI_Id", "MI"."INVMI_ItemName", "INVMI_ItemCode", ("TIC"."INVTIC_ICQty")
                FROM "INV"."INV_M_ItemConsumption" "MIC"
                LEFT JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
                LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
                WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE  
                      AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND "TIC"."INVMI_Id" IN (' || "p_INVMI_Id" || ') ' || "v_dates" || '
            ) AS "IC"
            GROUP BY "INVMI_Id", "INVMI_ItemName", "INVMI_ItemCode"';

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        ELSIF "p_optionflag" = 'Staff' THEN
            "v_Slqdymaic" := '
            SELECT "HRME_Id", "HRME_EmployeeCode", "membername", SUM("icQty") AS "icQty"
            FROM (
                SELECT DISTINCT "HRME"."HRME_Id", "HRME_EmployeeCode",
                (CASE WHEN "HRME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
                 CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
                 CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "membername",
                "MI"."INVMI_Id",
                ("TIC"."INVTIC_ICQty" / NULLIF("Mastericcount", 0))::DECIMAL(18,2) AS "icQty"
                FROM "INV"."INV_M_ItemConsumption" "MIC"
                INNER JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
                INNER JOIN "InvStaffwiseIC_Temp" "ISST" ON "MIC"."INVMIC_Id" = "ISST"."INVMIC_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
                INNER JOIN "INV"."INV_M_IC_Staff" "HRM" ON "HRM"."INVMIC_Id" = "MIC"."INVMIC_Id"
                INNER JOIN "HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "HRM"."HRME_Id"
                WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE 
                      AND "HRM"."INVMICST_ActiveFlg" = TRUE AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || '
            ) AS "NEW" 
            WHERE "HRME_Id" IN (' || "p_HRME_Id" || ') 
            GROUP BY "HRME_Id", "HRME_EmployeeCode", "membername"';

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        ELSIF "p_optionflag" = 'Department' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "ICD"."HRMD_Id", "HRD"."HRMD_DepartmentName" AS "membername", SUM("TIC"."INVTIC_ICQty") AS "icQty"
            FROM "INV"."INV_M_ItemConsumption" "MIC"
            INNER JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
            INNER JOIN "INV"."INV_M_IC_Department" "ICD" ON "ICD"."INVMIC_Id" = "MIC"."INVMIC_Id"
            INNER JOIN "HR_Master_Department" "HRD" ON "HRD"."HRMD_Id" = "ICD"."HRMD_Id"
            WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE 
                  AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND "ICD"."HRMD_Id" IN (' || "p_HRMD_Id" || ') ' || "v_dates" || ' 
            GROUP BY "ICD"."HRMD_Id", "HRD"."HRMD_DepartmentName"';

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        ELSIF "p_optionflag" = 'Student' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "AMST_Id", "AMST_AdmNo", "membername", SUM("INVTIC_ICQty") AS "icQty"
            FROM (
                SELECT DISTINCT "ICS"."AMST_Id", "AMS"."AMST_AdmNo",
                (CASE WHEN "AMS"."AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END ||
                 CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END ||
                 CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END) AS "membername",
                "MI"."INVMI_Id", "TIC"."INVTIC_ICQty"
                FROM "INV"."INV_M_ItemConsumption" "MIC"
                INNER JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
                INNER JOIN "INV"."INV_M_IC_Student" "ICS" ON "ICS"."INVMIC_Id" = "MIC"."INVMIC_Id"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ICS"."AMST_Id"
                WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE 
                      AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND "ICS"."AMST_Id" IN (' || "p_AMST_Id" || ') ' || "v_dates" || '
            ) AS "ICStudent" 
            GROUP BY "AMST_Id", "AMST_AdmNo", "membername"';

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        END IF;
    END IF;

    IF ("p_typeflag" = 'Detailed') THEN
        IF "p_optionflag" = 'Item' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "TIC"."INVMI_Id", "MI"."INVMI_ItemName", "TIC"."INVTIC_ICQty", "MIC"."INVMIC_ICDate"
            FROM "INV"."INV_M_ItemConsumption" "MIC"
            INNER JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
            WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE  
                  AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND "TIC"."INVMI_Id" IN (' || "p_INVMI_Id" || ') ' || "v_dates";

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        ELSIF "p_optionflag" = 'Staff' THEN
            "v_Slqdymaic" := '
            SELECT "INVMI_Id", "INVMI_ItemName", "INVMI_ItemCode", "INVMIC_ICDate", "HRME_Id", "HRME_EmployeeCode", "membername", "icQty"
            FROM (
                SELECT DISTINCT "HRME"."HRME_Id", "HRME_EmployeeCode", "MIC"."INVMIC_ICDate",
                (CASE WHEN "HRME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
                 CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
                 CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "membername",
                "MI"."INVMI_Id", "MI"."INVMI_ItemName", "INVMI_ItemCode",
                ("TIC"."INVTIC_ICQty" / NULLIF("Mastericcount", 0))::DECIMAL(18,2) AS "icQty"
                FROM "INV"."INV_M_ItemConsumption" "MIC"
                INNER JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
                INNER JOIN "InvStaffwiseIC_Temp" "ISST" ON "MIC"."INVMIC_Id" = "ISST"."INVMIC_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
                INNER JOIN "INV"."INV_M_IC_Staff" "HRM" ON "HRM"."INVMIC_Id" = "MIC"."INVMIC_Id"
                INNER JOIN "HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "HRM"."HRME_Id"
                WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE 
                      AND "HRM"."INVMICST_ActiveFlg" = TRUE AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || '
            ) AS "NEW" 
            WHERE "HRME_Id" IN (' || "p_HRME_Id" || ') 
            GROUP BY "INVMI_Id", "INVMI_ItemName", "INVMIC_ICDate", "HRME_Id", "HRME_EmployeeCode", "membername", "icQty"';

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        ELSIF "p_optionflag" = 'Department' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "ICD"."HRMD_Id", "HRD"."HRMD_DepartmentName" AS "membername", "TIC"."INVMI_Id", 
                   "MI"."INVMI_ItemName", "TIC"."INVTIC_ICQty", "MIC"."INVMIC_ICDate"
            FROM "INV"."INV_M_ItemConsumption" "MIC"
            INNER JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
            INNER JOIN "INV"."INV_M_IC_Department" "ICD" ON "ICD"."INVMIC_Id" = "MIC"."INVMIC_Id"
            INNER JOIN "HR_Master_Department" "HRD" ON "HRD"."HRMD_Id" = "ICD"."HRMD_Id"
            WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE 
                  AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND "ICD"."HRMD_Id" IN (' || "p_HRMD_Id" || ') ' || "v_dates";

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        ELSIF "p_optionflag" = 'Student' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "ICS"."AMST_Id", "AMS"."AMST_AdmNo",
            (CASE WHEN "AMS"."AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END ||
             CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END ||
             CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END) AS "membername",
            "TIC"."INVMI_Id", "MI"."INVMI_ItemName", "TIC"."INVTIC_ICQty", "MIC"."INVMIC_ICDate"
            FROM "INV"."INV_M_ItemConsumption" "MIC"
            INNER JOIN "INV"."INV_T_ItemConsumption" "TIC" ON "MIC"."INVMIC_Id" = "TIC"."INVMIC_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TIC"."INVMI_Id"
            INNER JOIN "INV"."INV_M_IC_Student" "ICS" ON "ICS"."INVMIC_Id" = "MIC"."INVMIC_Id"
            INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ICS"."AMST_Id"
            WHERE "MIC"."INVMIC_ActiveFlg" = TRUE AND "TIC"."INVTIC_ActiveFlg" = TRUE 
                  AND "MIC"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND "ICS"."AMST_Id" IN (' || "p_AMST_Id" || ') ' || "v_dates";

            OPEN "result_cursor" FOR EXECUTE "v_Slqdymaic";
            RETURN NEXT "result_cursor";
        END IF;
    END IF;

    RETURN;
END;
$$;