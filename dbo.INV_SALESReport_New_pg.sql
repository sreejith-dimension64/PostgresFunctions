CREATE OR REPLACE FUNCTION "dbo"."INV_SALESReport_New" (
    "MI_Id" BIGINT, 
    "startdate" VARCHAR(25), 
    "enddate" VARCHAR(25), 
    "optionflag" VARCHAR(20),
    "INVMST_Id" VARCHAR(100),
    "INVMSL_Id" VARCHAR(100),
    "INVMI_Id" VARCHAR(100),
    "AMST_Id" VARCHAR(100),
    "HRME_Id" VARCHAR(100),
    "INVMC_Id" VARCHAR
)
RETURNS TABLE (
    "INVMSL_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMS_StoreName" TEXT,
    "INVMI_ItemName" TEXT,
    "membername" TEXT,
    "INVMSL_StuOtherFlg" TEXT,
    "INVMSL_SalesDate" TIMESTAMP,
    "INVTSL_SalesQty" NUMERIC,
    "INVTSL_SalesPrice" NUMERIC,
    "INVTSL_DiscountAmt" NUMERIC,
    "INVTSL_TaxAmt" NUMERIC,
    "INVTSL_Amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN

    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := ' and "INVMSL_SalesDate"::date between TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') and TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", 
        NULL::TEXT as "INVMS_StoreName",
        "MI"."INVMI_ItemName",
        TRIM(CONCAT("INVMC_CustomerName",
            (CASE WHEN "ADM"."AMST_FirstName" is null or "AMST_FirstName"='''' then '''' else "AMST_FirstName" end ||
             CASE WHEN "AMST_MiddleName" is null or "AMST_MiddleName" = '''' or "AMST_MiddleName" = ''0'' then '''' ELSE '' '' || "AMST_MiddleName" END || 
             CASE WHEN "AMST_LastName" is null or "AMST_LastName" = '''' or "AMST_LastName" = ''0'' then '''' ELSE '' '' || "AMST_LastName" END),
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end ||
             CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END))) as membername,
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", 
        "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        LEFT JOIN "INV"."INV_Master_Store" "MSTR" ON "MSTR"."INVMST_Id" = "MSL"."INVMST_Id"
        LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        LEFT JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
        LEFT JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
        LEFT JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
        WHERE "MSL"."MI_Id" = ' || "MI_Id" || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Store' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", "MSTR"."INVMS_StoreName", "MI"."INVMI_ItemName",
        TRIM(CONCAT("INVMC_CustomerName",
            (CASE WHEN "ADM"."AMST_FirstName" is null or "AMST_FirstName"='''' then '''' else "AMST_FirstName" end ||
             CASE WHEN "AMST_MiddleName" is null or "AMST_MiddleName" = '''' or "AMST_MiddleName" = ''0'' then '''' ELSE '' '' || "AMST_MiddleName" END || 
             CASE WHEN "AMST_LastName" is null or "AMST_LastName" = '''' or "AMST_LastName" = ''0'' then '''' ELSE '' '' || "AMST_LastName" END),
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end ||
             CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END))) as membername,
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", 
        "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        LEFT JOIN "INV"."INV_Master_Store" "MSTR" ON "MSTR"."INVMST_Id" = "MSL"."INVMST_Id"
        LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        LEFT JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
        LEFT JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
        LEFT JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
        WHERE "MSL"."MI_Id" = ' || "MI_Id" || ' AND "MSL"."INVMST_Id" IN (' || "INVMST_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Saleno' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", 
        NULL::TEXT as "INVMS_StoreName",
        "MI"."INVMI_ItemName",
        TRIM(CONCAT("INVMC_CustomerName",
            (CASE WHEN "ADM"."AMST_FirstName" is null or "AMST_FirstName"='''' then '''' else "AMST_FirstName" end ||
             CASE WHEN "AMST_MiddleName" is null or "AMST_MiddleName" = '''' or "AMST_MiddleName" = ''0'' then '''' ELSE '' '' || "AMST_MiddleName" END || 
             CASE WHEN "AMST_LastName" is null or "AMST_LastName" = '''' or "AMST_LastName" = ''0'' then '''' ELSE '' '' || "AMST_LastName" END),
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end ||
             CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END))) as membername,
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", 
        "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        LEFT JOIN "INV"."INV_Master_Store" "MSTR" ON "MSTR"."INVMST_Id" = "MSL"."INVMST_Id"
        LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        LEFT JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
        LEFT JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
        LEFT JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
        WHERE "MSL"."MI_Id" = ' || "MI_Id" || ' AND "MSL"."INVMSL_Id" IN (' || "INVMSL_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", 
        NULL::TEXT as "INVMS_StoreName",
        "MI"."INVMI_ItemName",
        TRIM(CONCAT("INVMC_CustomerName",
            (CASE WHEN "ADM"."AMST_FirstName" is null or "AMST_FirstName"='''' then '''' else "AMST_FirstName" end ||
             CASE WHEN "AMST_MiddleName" is null or "AMST_MiddleName" = '''' or "AMST_MiddleName" = ''0'' then '''' ELSE '' '' || "AMST_MiddleName" END || 
             CASE WHEN "AMST_LastName" is null or "AMST_LastName" = '''' or "AMST_LastName" = ''0'' then '''' ELSE '' '' || "AMST_LastName" END),
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end ||
             CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END))) as membername,
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", 
        "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        LEFT JOIN "INV"."INV_Master_Store" "MSTR" ON "MSTR"."INVMST_Id" = "MSL"."INVMST_Id"
        LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        LEFT JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
        LEFT JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
        LEFT JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
        WHERE "MSL"."MI_Id" = ' || "MI_Id" || ' AND "MST"."INVMI_Id" IN (' || "INVMI_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Student' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", 
        NULL::TEXT as "INVMS_StoreName",
        "MI"."INVMI_ItemName",
        ((CASE WHEN "ADM"."AMST_FirstName" is null or "AMST_FirstName"='''' then '''' else "AMST_FirstName" end ||
          CASE WHEN "AMST_MiddleName" is null or "AMST_MiddleName" = '''' or "AMST_MiddleName" = ''0'' then '''' ELSE '' '' || "AMST_MiddleName" END || 
          CASE WHEN "AMST_LastName" is null or "AMST_LastName" = '''' or "AMST_LastName" = ''0'' then '''' ELSE '' '' || "AMST_LastName" END)) as membername,
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", 
        "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        INNER JOIN "INV"."INV_Master_Store" "MSTR" ON "MSTR"."INVMST_Id" = "MSL"."INVMST_Id"
        INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
        WHERE "MSST"."AMST_Id" = "ADM"."AMST_Id" AND "MSL"."MI_Id" = ' || "MI_Id" || ' AND "MSST"."AMST_Id" IN (' || "AMST_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Staff' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", 
        NULL::TEXT as "INVMS_StoreName",
        "MI"."INVMI_ItemName",
        ((CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end ||
          CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
          CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)) as membername,
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", 
        "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        INNER JOIN "INV"."INV_Master_Store" "MSTR" ON "MSTR"."INVMST_Id" = "MSL"."INVMST_Id"
        INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        INNER JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
        WHERE "MSSF"."HRME_Id" = "HRE"."HRME_Id" AND "MSL"."MI_Id" = ' || "MI_Id" || ' AND "MSSF"."HRME_Id" IN (' || "HRME_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Customer' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", 
        NULL::TEXT as "INVMS_StoreName",
        "MI"."INVMI_ItemName",
        "IMC"."INVMC_CustomerName" as membername,
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", 
        "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        INNER JOIN "INV"."INV_Master_Store" "MSTR" ON "MSTR"."INVMST_Id" = "MSL"."INVMST_Id"
        INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
        WHERE "MSSC"."INVMC_Id" = "IMC"."INVMC_Id" AND "MSL"."MI_Id" = ' || "MI_Id" || ' AND "MSSC"."INVMC_Id" IN (' || "INVMC_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
    END IF;

    RETURN;

END;
$$;