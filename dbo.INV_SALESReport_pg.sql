CREATE OR REPLACE FUNCTION "dbo"."INV_SALESReport"(
    "MI_Id" bigint,
    "startdate" varchar(10),
    "enddate" varchar(10),
    "optionflag" varchar(10),
    "individualflag" varchar(10),
    "HRME_Id" bigint,
    "INVMC_Id" bigint
)
RETURNS TABLE(
    "INVMSL_Id" bigint,
    "INVMSL_SalesNo" varchar,
    "INVMSL_SalesDate" timestamp,
    "membersname" text,
    "INVMSL_StuOtherFlg" varchar,
    "INVMSL_TotTaxAmt" numeric,
    "INVMSL_TotDiscount" numeric,
    "INVMSL_TotalAmount" numeric,
    "INVMSL_SalesValue" numeric,
    "employeename" text,
    "INVMC_CustomerName" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" text;
    "dates" varchar(200);
BEGIN
    
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := ' and "INVMSL_SalesDate"::date between TO_DATE(''' || "startdate" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "enddate" || ''',''DD-MM-YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := ' 
        select Distinct "MSL"."INVMSL_Id", "MSL"."INVMSL_SalesNo", "MSL"."INVMSL_SalesDate",
        RTRIM(LTRIM(CONCAT("IMC"."INVMC_CustomerName",(CASE WHEN "ADM"."AMST_FirstName" is null or "ADM"."AMST_FirstName"='''' then '''' else "ADM"."AMST_FirstName" end || CASE WHEN "ADM"."AMST_MiddleName" is null or "ADM"."AMST_MiddleName" = '''' or "ADM"."AMST_MiddleName" = ''0'' then '''' ELSE '' '' || "ADM"."AMST_MiddleName" END || CASE WHEN "ADM"."AMST_LastName" is null or "ADM"."AMST_LastName" = '''' or "ADM"."AMST_LastName" = ''0'' then '''' ELSE '' '' || "ADM"."AMST_LastName" END ),
        (CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRE"."HRME_EmployeeFirstName"='''' then '''' else "HRE"."HRME_EmployeeFirstName" end || CASE WHEN "HRE"."HRME_EmployeeMiddleName" is null or "HRE"."HRME_EmployeeMiddleName" = '''' or "HRE"."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRE"."HRME_EmployeeMiddleName" END || CASE WHEN "HRE"."HRME_EmployeeLastName" is null or "HRE"."HRME_EmployeeLastName" = '''' or "HRE"."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRE"."HRME_EmployeeLastName" END ))) as membersname, "MSL"."INVMSL_StuOtherFlg", "MSL"."INVMSL_TotTaxAmt", "MSL"."INVMSL_TotDiscount", "MSL"."INVMSL_TotalAmount",
        NULL::numeric as "INVMSL_SalesValue", NULL::text as employeename, NULL::varchar as "INVMC_CustomerName"
        from "INV"."INV_M_Sales" "MSL"
        LEFT JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
        LEFT JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
        LEFT JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
        where "MSL"."MI_Id" = ' || "MI_Id"::varchar || ' ' || "dates" || ' ';

        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'I' THEN
        IF "individualflag" = 'I' THEN
            "Slqdymaic" := '
            select "MSL"."INVMSL_Id", "MSL"."INVMSL_SalesNo", "MSL"."INVMSL_SalesDate",
            NULL::text as membersname, NULL::varchar as "INVMSL_StuOtherFlg", NULL::numeric as "INVMSL_TotTaxAmt", NULL::numeric as "INVMSL_TotDiscount", NULL::numeric as "INVMSL_TotalAmount",
            NULL::numeric as "INVMSL_SalesValue", NULL::text as employeename, NULL::varchar as "INVMC_CustomerName"
            from "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "TSL" ON "MSL"."INVMSL_Id" = "TSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_T_Sales_Tax" "TT" ON "TT"."INVTSL_Id" = "TSL"."INVTSL_Id"
            INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
            where "MSST"."AMST_Id" = "ADM"."AMST_Id" and "MSL"."MI_Id" = ' || "MI_Id"::varchar || ' and "MSL"."INVMSL_SalesDate"::date between TO_DATE(''' || "startdate" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "enddate" || ''',''DD-MM-YYYY'')';
        ELSIF "individualflag" = 'C' THEN
            "Slqdymaic" := '
            select "MSL"."INVMSL_Id", "MSL"."INVMSL_SalesNo", "MSL"."INVMSL_SalesDate",
            NULL::text as membersname, NULL::varchar as "INVMSL_StuOtherFlg", NULL::numeric as "INVMSL_TotTaxAmt", NULL::numeric as "INVMSL_TotDiscount", NULL::numeric as "INVMSL_TotalAmount",
            NULL::numeric as "INVMSL_SalesValue", NULL::text as employeename, NULL::varchar as "INVMC_CustomerName"
            from "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "TSL" ON "MSL"."INVMSL_Id" = "TSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_T_Sales_Tax" "TT" ON "TT"."INVTSL_Id" = "TSL"."INVTSL_Id"
            INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
            where "MSST"."AMST_Id" = "ADM"."AMST_Id" and "MSL"."MI_Id" = ' || "MI_Id"::varchar || ' and "MSL"."INVMSL_SalesDate"::date between TO_DATE(''' || "startdate" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "enddate" || ''',''DD-MM-YYYY'')';
        ELSIF "individualflag" = 'CS' THEN
            "Slqdymaic" := '
            select "MSL"."INVMSL_Id", "MSL"."INVMSL_SalesNo", "MSL"."INVMSL_SalesDate",
            NULL::text as membersname, NULL::varchar as "INVMSL_StuOtherFlg", NULL::numeric as "INVMSL_TotTaxAmt", NULL::numeric as "INVMSL_TotDiscount", NULL::numeric as "INVMSL_TotalAmount",
            NULL::numeric as "INVMSL_SalesValue", NULL::text as employeename, NULL::varchar as "INVMC_CustomerName"
            from "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "TSL" ON "MSL"."INVMSL_Id" = "TSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_T_Sales_Tax" "TT" ON "TT"."INVTSL_Id" = "TSL"."INVTSL_Id"
            INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
            where "MSST"."AMST_Id" = "ADM"."AMST_Id" and "MSL"."MI_Id" = ' || "MI_Id"::varchar || ' and "MSL"."INVMSL_SalesDate"::date between TO_DATE(''' || "startdate" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "enddate" || ''',''DD-MM-YYYY'')';
        ELSIF "individualflag" = 'SN' THEN
            "Slqdymaic" := '
            select "MSL"."INVMSL_Id", "MSL"."INVMSL_SalesNo", "MSL"."INVMSL_SalesDate",
            NULL::text as membersname, NULL::varchar as "INVMSL_StuOtherFlg", NULL::numeric as "INVMSL_TotTaxAmt", NULL::numeric as "INVMSL_TotDiscount", NULL::numeric as "INVMSL_TotalAmount",
            NULL::numeric as "INVMSL_SalesValue", NULL::text as employeename, NULL::varchar as "INVMC_CustomerName"
            from "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "TSL" ON "MSL"."INVMSL_Id" = "TSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_T_Sales_Tax" "TT" ON "TT"."INVTSL_Id" = "TSL"."INVTSL_Id"
            INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
            where "MSST"."AMST_Id" = "ADM"."AMST_Id" and "MSL"."MI_Id" = ' || "MI_Id"::varchar || ' and "MSL"."INVMSL_SalesDate"::date between TO_DATE(''' || "startdate" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "enddate" || ''',''DD-MM-YYYY'')';
        END IF;
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Staff' THEN
        "Slqdymaic" := ' 
        select Distinct "MSL"."INVMSL_Id", "MSL"."INVMSL_SalesNo", "MSL"."INVMSL_SalesDate",
        NULL::text as membersname, "MSL"."INVMSL_StuOtherFlg", "MSL"."INVMSL_TotTaxAmt", "MSL"."INVMSL_TotDiscount", "MSL"."INVMSL_TotalAmount",
        "MSL"."INVMSL_SalesValue",
        (CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRE"."HRME_EmployeeFirstName"='''' then '''' else "HRE"."HRME_EmployeeFirstName" end || CASE WHEN "HRE"."HRME_EmployeeMiddleName" is null or "HRE"."HRME_EmployeeMiddleName" = '''' or "HRE"."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRE"."HRME_EmployeeMiddleName" END || CASE WHEN "HRE"."HRME_EmployeeLastName" is null or "HRE"."HRME_EmployeeLastName" = '''' or "HRE"."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRE"."HRME_EmployeeLastName" END ) as employeename,
        NULL::varchar as "INVMC_CustomerName"
        from "INV"."INV_M_Sales" "MSL"
        INNER JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
        where "MSSF"."HRME_Id" = "HRE"."HRME_Id" and "MSL"."MI_Id" = ' || "MI_Id"::varchar || ' and "HRE"."HRME_Id" = ' || "HRME_Id"::varchar || ' ' || "dates" || ' ';

        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Customer' THEN
        "Slqdymaic" := ' 
        select Distinct "MSL"."INVMSL_Id", "MSL"."INVMSL_SalesNo", "MSL"."INVMSL_SalesDate",
        NULL::text as membersname, "MSL"."INVMSL_StuOtherFlg", "MSL"."INVMSL_TotTaxAmt", "MSL"."INVMSL_TotDiscount", "MSL"."INVMSL_TotalAmount",
        NULL::numeric as "INVMSL_SalesValue", NULL::text as employeename,
        "IMC"."INVMC_CustomerName"
        from "INV"."INV_M_Sales" "MSL"
        INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
        where "MSSC"."INVMC_Id" = "IMC"."INVMC_Id" and "MSL"."MI_Id" = ' || "MI_Id"::varchar || ' and "IMC"."INVMC_Id" = ' || "INVMC_Id"::varchar || ' ' || "dates" || ' ';

        RETURN QUERY EXECUTE "Slqdymaic";
    END IF;
    
    RETURN;
END;
$$;