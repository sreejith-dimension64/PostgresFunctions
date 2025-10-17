CREATE OR REPLACE FUNCTION "dbo"."ISM_EmployeesWiseApprovedEffortsIntoDays"(
    "FromDate" VARCHAR(10),
    "ToDate" VARCHAR(10)
)
RETURNS TABLE(
    "DREmpId" BIGINT,
    "DREmpname" TEXT,
    "ApprovedEfforts" DECIMAL(18,2),
    "EffortsInAppDays" DECIMAL(18,2),
    "EffortsInRejDays" DECIMAL(18,2),
    "EmpTotWdsWithHds" DECIMAL(18,2),
    "TotalPayableDays" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id BIGINT;
    v_DrEmpName TEXT;
    v_AppEmpName TEXT;
    v_DRHRME_Id BIGINT;
    v_ISMDRPTDW_Date TIMESTAMP;
    v_AppHRME_Id BIGINT;
    v_ISMUSEMM_Order INT;
    v_ApprovedEfforts DECIMAL(18,2);
    v_HDCount INT;
    rec_EmpDates RECORD;
BEGIN
    v_HDCount := 0;

    DROP TABLE IF EXISTS "ISM_EmpWiseApprovedDays_Temp";

    CREATE TEMP TABLE "ISM_EmpWiseApprovedDays_Temp"(
        "DREmpId" BIGINT,
        "DREmpname" TEXT,
        "DRDate" TIMESTAMP,
        "ApprovedEmpId" BIGINT,
        "ApprovedEmpName" TEXT,
        "UserLevel" INT,
        "ApprovedEfforts" DECIMAL(18,2),
        "EffortsInAppDays" DECIMAL(18,2),
        "EffortsInRejDays" DECIMAL(18,2)
    );

    FOR v_HRME_Id IN 
        SELECT DISTINCT "HRME_Id" 
        FROM "HR_Master_Employee" 
        WHERE "HRME_ActiveFlag" = 1 AND "HRME_ExcPunch" = 0
    LOOP
        FOR rec_EmpDates IN
            SELECT DISTINCT 
                "DRD"."HRME_Id",
                CAST("ISMDRPTDW_Date" AS DATE) AS "ISMDRPTDW_Date",
                "ISMDRPTDWMAPP_ApprovedHRME_Id",
                (SELECT DISTINCT MAX("UEM"."ISMUSEMM_Order") 
                 FROM "ISM_DailyReport_Daywise_Multiple_Approval" "MA"
                 INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id" = "MA"."ISMDRPTDWMAPP_CreatedBy"
                 WHERE "MA"."ISMDRPTDW_Id" = "DMA"."ISMDRPTDW_Id" 
                   AND "ISMUSEMM_Order" <> 0 
                   AND "UEM"."ISMUSEMM_ActiveFlag" = 1) AS "ISMUSEMM_Order",
                SUM("ISMDRPTDW_ApprovedEffort") AS "ApprovedEfforts"
            FROM "ISM_DailyReport_Daywise" "DRD"
            LEFT JOIN "ISM_DailyReport_Daywise_Multiple_Approval" "DMA" 
                ON "DMA"."ISMDRPTDW_Id" = "DRD"."ISMDRPTDW_Id"
            WHERE "DRD"."HRME_Id" = v_HRME_Id 
              AND CAST("ISMDRPTDW_Date" AS DATE) BETWEEN CAST("FromDate" AS DATE) AND CAST("ToDate" AS DATE)
            GROUP BY "DRD"."HRME_Id", CAST("ISMDRPTDW_Date" AS DATE), "ISMDRPTDWMAPP_ApprovedHRME_Id", "ISMDRPTDWMAPP_CreatedBy", "DMA"."ISMDRPTDW_Id"
        LOOP
            v_DRHRME_Id := rec_EmpDates."HRME_Id";
            v_ISMDRPTDW_Date := rec_EmpDates."ISMDRPTDW_Date";
            v_AppHRME_Id := rec_EmpDates."ISMDRPTDWMAPP_ApprovedHRME_Id";
            v_ISMUSEMM_Order := rec_EmpDates."ISMUSEMM_Order";
            v_ApprovedEfforts := rec_EmpDates."ApprovedEfforts";

            SELECT COALESCE("HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '')
            INTO v_DrEmpName
            FROM "HR_Master_Employee" 
            WHERE "HRME_Id" = v_DRHRME_Id;

            SELECT COALESCE("HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '')
            INTO v_AppEmpName
            FROM "HR_Master_Employee" 
            WHERE "HRME_Id" = v_AppHRME_Id;

            INSERT INTO "ISM_EmpWiseApprovedDays_Temp"(
                "DREmpId", "DREmpname", "DRDate", "ApprovedEmpId", "ApprovedEmpName", 
                "UserLevel", "ApprovedEfforts", "EffortsInAppDays", "EffortsInRejDays"
            )
            VALUES(
                v_DRHRME_Id, 
                v_DrEmpName, 
                v_ISMDRPTDW_Date, 
                v_AppHRME_Id, 
                v_AppEmpName, 
                v_ISMUSEMM_Order, 
                v_ApprovedEfforts, 
                (CASE 
                    WHEN v_ApprovedEfforts >= 8.00 THEN 1 
                    WHEN v_ApprovedEfforts > 0.00 AND v_ApprovedEfforts < 8.00 THEN 0.5 
                    ELSE NULL
                END),
                (CASE 
                    WHEN v_ApprovedEfforts = 0 THEN 1 
                    ELSE NULL
                END)
            );
        END LOOP;
    END LOOP;

    SELECT COUNT(DISTINCT CAST("FOMHWDD_FromDate" AS DATE))
    INTO v_HDCount
    FROM "FO"."FO_HolidayWorkingDay_Type" "HWT"
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "DD" 
        ON "DD"."FOHWDT_Id" = "HWT"."FOHWDT_Id"
    WHERE "HWT"."FOHTWD_HolidayFlag" = 1 
      AND "DD"."FOMHWD_ActiveFlg" = 1
      AND CAST("FOMHWDD_FromDate" AS DATE) BETWEEN CAST("FromDate" AS DATE) AND CAST("ToDate" AS DATE)
      AND "DD"."MI_Id" = 17;

    RETURN QUERY
    SELECT DISTINCT 
        "New"."DREmpId",
        "New"."DREmpname",
        "New"."ApprovedEfforts",
        "New"."EffortsInAppDays",
        "New"."EffortsInRejDays",
        v_HDCount + "New"."EffortsInAppDays" AS "EmpTotWdsWithHds",
        (v_HDCount + ("New"."EffortsInAppDays" - COALESCE("New"."EffortsInRejDays", 0))) AS "TotalPayableDays"
    FROM (
        SELECT 
            "DREmpId",
            "DREmpname",
            SUM("ApprovedEfforts") AS "ApprovedEfforts",
            SUM("EffortsInAppDays") AS "EffortsInAppDays",
            SUM("EffortsInRejDays") AS "EffortsInRejDays"
        FROM "ISM_EmpWiseApprovedDays_Temp" 
        GROUP BY "DREmpId", "DREmpname"
    ) AS "New" 
    ORDER BY "New"."DREmpId";

    DROP TABLE IF EXISTS "ISM_EmpWiseApprovedDays_Temp";

    RETURN;
END;
$$;