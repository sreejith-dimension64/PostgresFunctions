CREATE OR REPLACE FUNCTION "dbo"."INV_CLG_SALESReport"(
    p_MI_Id BIGINT,
    p_startdate VARCHAR(25),
    p_enddate VARCHAR(25),
    p_typeflag VARCHAR(50),
    p_optionflag VARCHAR(50),
    p_INVMSL_Id TEXT,
    p_INVMI_Id TEXT,
    p_AMCST_Id TEXT,
    p_HRME_Id TEXT,
    p_INVMC_Id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_Slqdymaic1 TEXT;
    v_ASMAY_Id BIGINT;
    v_dates VARCHAR(200);
BEGIN

    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := ' AND DATE("INVMSL_SalesDate") BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    DROP TABLE IF EXISTS "InvStuwiseSales_Temp";
    DROP TABLE IF EXISTS "ItemSalesPrice_Temp";

    SELECT "ASMAY_Id" INTO v_ASMAY_Id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "MI_Id" = p_MI_Id;

    RAISE NOTICE 'year%', v_ASMAY_Id;

    CREATE TEMP TABLE "InvStuwiseSales_Temp" AS
    SELECT "INVMSL_Id", "Mastersalescount"
    FROM (
        SELECT "INVMSL_Id", COUNT(*) AS "Mastersalescount" 
        FROM "INV"."INV_M_Sales_College_Student" 
        WHERE "INVMSLCS_ActiveFlg" = TRUE 
        AND "ASMAY_Id" = v_ASMAY_Id 
        GROUP BY "INVMSL_Id" 
        HAVING COUNT(*) >= 1
    ) AS new 
    ORDER BY "Mastersalescount";

    IF (p_typeflag = 'All') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MSL"."INVMSL_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName",
        "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesNo", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", 
        "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
        FROM "INV"."INV_M_Sales" "MSL"
        LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
        WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSL"."MI_Id" = ' || p_MI_Id || ' ' || v_dates;

        EXECUTE v_Slqdymaic;
    END IF;

    IF (p_typeflag = 'Overall') THEN
        IF p_optionflag = 'Item' THEN

            v_Slqdymaic1 := 'CREATE TEMP TABLE "ItemSalesPrice_Temp" AS 
            SELECT DISTINCT "MST"."INVMI_Id", "MI"."INVMI_ItemName", ("MST"."INVTSL_SalesPrice") AS "INVTSL_SalesPrice"
            FROM "INV"."INV_M_Sales" "MSL"
            LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MST"."INVTSL_ActiveFlg" = TRUE 
            AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MST"."INVMI_Id" IN (' || p_INVMI_Id || ')';

            EXECUTE v_Slqdymaic1;

            v_Slqdymaic := '
            SELECT DISTINCT "INVMI_Id", "INVMI_ItemName", SUM("INVTSL_SalesQty") AS "saleQty",
            SUM("INVTSL_SalesPrice") AS "salePrice", SUM("INVTSL_DiscountAmt") AS "saleDiscount",
            SUM("INVTSL_TaxAmt") AS "saleTax", SUM("INVTSL_Amount") AS "saleAmount"
            FROM (
                SELECT DISTINCT "MST"."INVMI_Id", "MI"."INVMI_ItemName", ("MST"."INVTSL_SalesQty") AS "INVTSL_SalesQty",
                ("INVMSL_SalesDate") AS "INVMSL_SalesDate", ("MST"."INVTSL_SalesPrice") AS "INVTSL_SalesPrice",
                ("INVTSL_DiscountAmt") AS "INVTSL_DiscountAmt", ("INVTSL_TaxAmt") AS "INVTSL_TaxAmt",
                ("INVTSL_Amount") AS "INVTSL_Amount", ("INVMSL_SalesValue") AS "INVMSL_SalesValue"
                FROM "INV"."INV_M_Sales" "MSL"
                LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MST"."INVTSL_ActiveFlg" = TRUE
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MST"."INVMI_Id" IN (' || p_INVMI_Id || ') 
                AND "MST"."INVTSL_SalesPrice" IN (SELECT "INVTSL_SalesPrice" FROM "ItemSalesPrice_Temp") ' || v_dates || '
            ) AS "Sales"
            GROUP BY "INVMI_Id", "INVMI_ItemName"';

            EXECUTE v_Slqdymaic;

        ELSIF p_optionflag = 'Student' THEN

            v_Slqdymaic := '
            SELECT "AMCST_Id", "AMCST_AdmNo", "membername", 
            SUM("saleQty") AS "saleQty", SUM("salePrice") AS "salePrice", 
            SUM("saleDiscount") AS "saleDiscount", SUM("saleTax") AS "saleTax", SUM("saleAmount") AS "saleAmount"
            FROM (
                SELECT DISTINCT "ADM"."AMCST_Id", "ADM"."AMCST_AdmNo",
                (COALESCE("ADM"."AMCST_FirstName", '''') || 
                 CASE WHEN COALESCE("AMCST_MiddleName", '''') = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_MiddleName" END ||
                 CASE WHEN COALESCE("AMCST_LastName", '''') = '''' OR "AMCST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "membername",
                "MI"."INVMI_Id",
                CAST("MST"."INVTSL_SalesQty" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "saleQty",
                ("MST"."INVTSL_SalesPrice") AS "salePrice", ("INVTSL_DiscountAmt") AS "saleDiscount",
                ("INVTSL_TaxAmt") AS "saleTax",
                CAST("INVTSL_Amount" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "saleAmount",
                ("MSL"."INVMSL_SalesValue") AS "saleValue"
                FROM "INV"."INV_M_Sales" "MSL"
                INNER JOIN "InvStuwiseSales_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
                INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                INNER JOIN "INV"."INV_M_Sales_College_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "CLG"."Adm_Master_College_Student" "ADM" ON "ADM"."AMCST_Id" = "MSST"."AMCST_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSST"."AMCST_Id" = "ADM"."AMCST_Id"
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' ' || v_dates || '
            ) AS "NEW" 
            WHERE "AMCST_Id" IN (' || p_AMCST_Id || ')
            GROUP BY "AMCST_Id", "AMCST_AdmNo", "membername"';

            EXECUTE v_Slqdymaic;

        ELSIF p_optionflag = 'Staff' THEN

            v_Slqdymaic := '
            SELECT DISTINCT "MSSF"."HRME_Id",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '''') ||
             CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "membername",
            SUM("MST"."INVTSL_SalesQty") AS "saleQty", SUM("MST"."INVTSL_SalesPrice") AS "salePrice",
            SUM("INVTSL_DiscountAmt") AS "saleDiscount", SUM("INVTSL_TaxAmt") AS "saleTax",
            SUM("INVTSL_Amount") AS "saleAmount", SUM("MSL"."INVMSL_SalesValue") AS "saleValue"
            FROM "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            INNER JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSSF"."HRME_Id" = "HRE"."HRME_Id"
            AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSSF"."HRME_Id" IN (' || p_HRME_Id || ') ' || v_dates || '
            GROUP BY "MSSF"."HRME_Id", "HRE"."HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"';

            EXECUTE v_Slqdymaic;

        ELSIF p_optionflag = 'Customer' THEN

            v_Slqdymaic := '
            SELECT DISTINCT "MSSC"."INVMC_Id", "IMC"."INVMC_CustomerName" AS "membername",
            SUM("MST"."INVTSL_SalesQty") AS "saleQty", SUM("MST"."INVTSL_SalesPrice") AS "salePrice",
            SUM("INVTSL_DiscountAmt") AS "saleDiscount", SUM("INVTSL_TaxAmt") AS "saleTax",
            SUM("INVTSL_Amount") AS "saleAmount", SUM("MSL"."INVMSL_SalesValue") AS "saleValue"
            FROM "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSSC"."INVMC_Id" = "IMC"."INVMC_Id"
            AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSSC"."INVMC_Id" IN (' || p_INVMC_Id || ') ' || v_dates || '
            GROUP BY "MSSC"."INVMC_Id", "IMC"."INVMC_CustomerName"';

            EXECUTE v_Slqdymaic;

        END IF;
    END IF;

    IF (p_typeflag = 'Detailed') THEN
        IF p_optionflag = 'Item' THEN

            v_Slqdymaic := '
            SELECT DISTINCT "MSL"."INVMSL_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName",
            "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesNo", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty",
            "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
            FROM "INV"."INV_M_Sales" "MSL"
            LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MST"."INVTSL_ActiveFlg" = TRUE
            AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MST"."INVMI_Id" IN (' || p_INVMI_Id || ') ' || v_dates || '
            ORDER BY "INVMSL_SalesDate"';

            EXECUTE v_Slqdymaic;

        ELSIF p_optionflag = 'Student' THEN

            v_Slqdymaic := '
            SELECT DISTINCT "ADM"."AMCST_Id", "ADM"."AMCST_AdmNo", "MI"."INVMI_ItemName",
            (COALESCE("ADM"."AMCST_FirstName", '''') ||
             CASE WHEN COALESCE("AMCST_MiddleName", '''') = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_MiddleName" END ||
             CASE WHEN COALESCE("AMCST_LastName", '''') = '''' OR "AMCST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "membername",
            "MI"."INVMI_Id", "INVMSL_SalesNo", "INVMSL_SalesDate",
            CAST("MST"."INVTSL_SalesQty" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "saleQty",
            ("MST"."INVTSL_SalesPrice") AS "salePrice", ("INVTSL_DiscountAmt") AS "saleDiscount",
            ("INVTSL_TaxAmt") AS "saleTax",
            CAST("INVTSL_Amount" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "saleAmount",
            ("MSL"."INVMSL_SalesValue") AS "saleValue"
            FROM "INV"."INV_M_Sales" "MSL"
            INNER JOIN "InvStuwiseSales_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
            INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            INNER JOIN "INV"."INV_M_Sales_College_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "CLG"."Adm_Master_College_Student" "ADM" ON "ADM"."AMCST_Id" = "MSST"."AMCST_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSST"."AMCST_Id" = "ADM"."AMCST_Id"
            AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSST"."AMCST_Id" IN (' || p_AMCST_Id || ') ' || v_dates || '
            ORDER BY "INVMSL_SalesDate"';

            EXECUTE v_Slqdymaic;

        ELSIF p_optionflag = 'Staff' THEN

            v_Slqdymaic := '
            SELECT DISTINCT "MSL"."INVMSL_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '''') ||
             CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "membername",
            "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesNo", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty",
            "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
            FROM "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            INNER JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSSF"."HRME_Id" = "HRE"."HRME_Id"
            AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSSF"."HRME_Id" IN (' || p_HRME_Id || ') ' || v_dates || '
            ORDER BY "INVMSL_SalesDate"';

            EXECUTE v_Slqdymaic;

        ELSIF p_optionflag = 'Customer' THEN

            v_Slqdymaic := '
            SELECT DISTINCT "MSL"."INVMSL_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName",
            "IMC"."INVMC_CustomerName" AS "membername",
            "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesNo", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty",
            "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
            FROM "INV"."INV_M_Sales" "MSL"
            INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSSC"."INVMC_Id" = "IMC"."INVMC_Id"
            AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSSC"."INVMC_Id" IN (' || p_INVMC_Id || ') ' || v_dates || '
            ORDER BY "INVMSL_SalesDate"';

            EXECUTE v_Slqdymaic;

        ELSIF p_optionflag = 'Saleno' THEN

            v_Slqdymaic := '
            SELECT DISTINCT "MSL"."INVMSL_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName",
            "INVMSL_SalesNo", "INVMSL_SalesDate", "MSL"."INVMSL_StuOtherFlg",
            CAST("MST"."INVTSL_SalesQty" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "INVTSL_SalesQty",
            ("MST"."INVTSL_SalesPrice") AS "INVTSL_SalesPrice",
            ("INVTSL_DiscountAmt") AS "INVTSL_DiscountAmt", ("INVTSL_TaxAmt") AS "INVTSL_TaxAmt",
            CAST("INVTSL_Amount" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "INVTSL_Amount",
            ("MSL"."INVMSL_SalesValue") AS "saleValue"
            FROM "INV"."INV_M_Sales" "MSL"
            INNER JOIN "InvStuwiseSales_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
            INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
            WHERE "MSL"."INVMSL_ActiveFlg" = TRUE AND "MSL"."MI_Id" = ' || p_MI_Id || '
            AND "MSL"."INVMSL_Id" IN (' || p_INVMSL_Id || ') ' || v_dates || '
            ORDER BY "INVMSL_SalesDate"';

            EXECUTE v_Slqdymaic;

        END IF;
    END IF;

END;
$$;