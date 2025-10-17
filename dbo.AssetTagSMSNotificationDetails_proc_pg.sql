CREATE OR REPLACE FUNCTION "dbo"."AssetTagSMSNotificationDetails_proc"(
    p_MI_Id bigint,
    p_WarantyExpiryDate varchar(50)
)
RETURNS TABLE(
    "INVMI_ItemName" varchar,
    "INVMS_ContactNo" varchar,
    "INVAAT_WarantyExpiryDate" timestamp,
    "count_date" integer,
    "HRME_EmailId" varchar,
    "HRME_MobileNo" varchar,
    "MI_Id" bigint,
    "INVMS_StoreName" varchar,
    "INVMS_StoreLocation" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_countdays date;
BEGIN
    SELECT CAST((CURRENT_TIMESTAMP + ("ISES_AlertBeforeDays" || ' days')::interval) AS date)
    INTO v_countdays
    FROM "IVRM_SMS_Email_Setting"
    WHERE "MI_Id" = p_MI_Id 
    AND "ISES_Template_Name" = 'AssetsExpireDate';

    RETURN QUERY
    SELECT DISTINCT 
        c."INVMI_ItemName"::varchar AS "INVMI_ItemName",
        b."INVMS_ContactNo"::varchar AS "INVMS_ContactNo",
        a."INVAAT_WarantyExpiryDate" AS "INVAAT_WarantyExpiryDate",
        (CAST(a."INVAAT_WarantyExpiryDate" AS date) - CAST(CURRENT_TIMESTAMP AS date))::integer AS "count_date",
        e."HRMEM_EmailId"::varchar AS "HRME_EmailId",
        f."HRMEMNO_MobileNo"::varchar AS "HRME_MobileNo",
        a."MI_Id" AS "MI_Id",
        b."INVMS_StoreName"::varchar AS "INVMS_StoreName",
        b."INVMS_StoreLocation"::varchar AS "INVMS_StoreLocation"
    FROM "inv"."INV_Asset_AssetTag" a
    INNER JOIN "inv"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
    INNER JOIN "inv"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
    LEFT JOIN "INV"."INV_Configuration" d ON d."INVMST_Id" = b."INVMST_Id"
    INNER JOIN "HR_Master_Employee_EmailId" e ON e."HRME_Id" = b."HRME_Id"
    INNER JOIN "HR_Master_Employee_MobileNo" f ON f."HRME_Id" = b."HRME_Id"
    WHERE a."MI_Id" = b."MI_Id" 
    AND a."MI_Id" = p_MI_Id
    AND CAST(a."INVAAT_WarantyExpiryDate" AS date) <= v_countdays 
    AND (CAST(a."INVAAT_WarantyExpiryDate" AS date) - CAST(CURRENT_TIMESTAMP AS date)) > 0
    AND CAST(a."INVAAT_WarantyExpiryDate" AS date) = CAST(p_WarantyExpiryDate AS date);
END;
$$;