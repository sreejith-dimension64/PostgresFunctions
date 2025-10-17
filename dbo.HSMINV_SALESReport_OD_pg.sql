CREATE OR REPLACE FUNCTION "dbo"."HSMINV_SALESReport_OD"(
    p_MI_Id BIGINT,
    p_startdate VARCHAR(25),
    p_enddate VARCHAR(25),
    p_typeflag VARCHAR(50),
    p_optionflag VARCHAR(50),
    p_INVMSL_Id TEXT,
    p_INVMI_Id TEXT,
    p_AMST_Id TEXT,
    p_HRME_Id TEXT,
    p_INVMC_Id VARCHAR,
    p_INVMST_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_Slqdymaic1 TEXT;
    v_Slqdymaic12 TEXT;
    v_ASMAY_Id BIGINT;
    v_dates VARCHAR(200);
BEGIN
    
    IF p_INVMST_Id = 0 THEN
        IF p_startdate != '' AND p_enddate != '' THEN
            v_dates := ' and "INVMSL_SalesDate"::date between TO_DATE(''' || p_startdate || ''',''DD/MM/YYYY'') and TO_DATE(''' || p_enddate || ''',''DD/MM/YYYY'')';
        ELSE
            v_dates := '';
        END IF;

        DROP TABLE IF EXISTS "InvStuwiseSales_Temp";
        DROP TABLE IF EXISTS "ItemSalesPrice_Temp";

        SELECT "ASMAY_Id" INTO v_ASMAY_Id 
        FROM "Adm_School_M_Academic_Year" 
        WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
        AND "MI_Id" = p_MI_Id;

        RAISE NOTICE 'year %', v_ASMAY_Id;

        CREATE TEMP TABLE "InvStuwiseSales_Temp" AS
        SELECT "INVMSL_Id", "Mastersalescount" 
        FROM (
            SELECT "INVMSL_Id", COUNT(*) AS "Mastersalescount" 
            FROM "INV"."INV_M_Sales_Student" 
            WHERE "INVMSLS_ActiveFlg" = 1 AND "ASMAY_Id" = v_ASMAY_Id 
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
            WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSL"."MI_Id" = ' || p_MI_Id || ' ' || v_dates || ' ';

            EXECUTE v_Slqdymaic;
        END IF;

        IF (p_typeflag = 'Overall') THEN
            IF p_optionflag = 'Item' THEN
                v_Slqdymaic1 := 'CREATE TEMP TABLE "ItemSalesPrice_Temp" AS 
                SELECT DISTINCT "MST"."INVMI_Id", "MI"."INVMI_ItemName", ("MST"."INVTSL_SalesPrice") AS "INVTSL_SalesPrice"
                FROM "INV"."INV_M_Sales" "MSL"
                LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1 
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MST"."INVMI_Id" IN (' || p_INVMI_Id || ')';

                EXECUTE v_Slqdymaic1;

                v_Slqdymaic := '
                SELECT DISTINCT "INVMI_Id", "INVMI_ItemName", SUM("INVTSL_SalesQty") AS "saleQty",
                SUM("INVTSL_SalesPrice") AS "salePrice", SUM("INVTSL_DiscountAmt") AS "saleDiscount",
                SUM("INVTSL_TaxAmt") AS "saleTax", SUM("INVTSL_Amount") AS "saleAmount"
                FROM (
                    SELECT DISTINCT "MST"."INVMI_Id", "MI"."INVMI_ItemName", 
                    ("MST"."INVTSL_SalesQty") AS "INVTSL_SalesQty", ("INVMSL_SalesDate") AS "INVMSL_SalesDate",
                    ("MST"."INVTSL_SalesPrice") AS "INVTSL_SalesPrice", ("INVTSL_DiscountAmt") AS "INVTSL_DiscountAmt",
                    ("INVTSL_TaxAmt") AS "INVTSL_TaxAmt", ("INVTSL_Amount") AS "INVTSL_Amount", 
                    ("INVMSL_SalesValue") AS "INVMSL_SalesValue"
                    FROM "INV"."INV_M_Sales" "MSL"
                    LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                    LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                    WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1  
                    AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MST"."INVMI_Id" IN (' || p_INVMI_Id || ') 
                    AND "MST"."INVTSL_SalesPrice" IN (SELECT "INVTSL_SalesPrice" FROM "ItemSalesPrice_Temp") ' || v_dates || '
                ) AS "Sales"
                GROUP BY "INVMI_Id", "INVMI_ItemName"';

                EXECUTE v_Slqdymaic;
            END IF;

            IF p_optionflag = 'Student' THEN
                v_Slqdymaic := '
                SELECT "AMST_Id", "AMST_AdmNo", "membername", SUM("saleQty") AS "saleQty", 
                SUM("salePrice") AS "salePrice", SUM("saleDiscount") AS "saleDiscount", 
                SUM("saleTax") AS "saleTax", SUM("saleAmount") AS "saleAmount"
                FROM (
                    SELECT DISTINCT "ADM"."AMST_Id", "ADM"."AMST_AdmNo",
                    (COALESCE("ADM"."AMST_FirstName", '''') || 
                     CASE WHEN COALESCE("AMST_MiddleName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "AMST_MiddleName" END || 
                     CASE WHEN COALESCE("AMST_LastName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "AMST_LastName" END) AS "membername",
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
                    INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                    INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
                    WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSST"."AMST_Id" = "ADM"."AMST_Id" 
                    AND "MSL"."MI_Id" = ' || p_MI_Id || ' ' || v_dates || '
                ) AS "NEW" 
                WHERE "AMST_Id" IN (' || p_AMST_Id || ') 
                GROUP BY "AMST_Id", "AMST_AdmNo", "membername"';

                EXECUTE v_Slqdymaic;
            END IF;

            IF p_optionflag = 'Staff' THEN
                v_Slqdymaic := '
                SELECT DISTINCT "MSSF"."HRME_Id",
                (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || 
                 CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                 CASE WHEN COALESCE("HRME_EmployeeLastName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "membername",
                SUM("MST"."INVTSL_SalesQty") AS "saleQty", SUM("MST"."INVTSL_SalesPrice") AS "salePrice",
                SUM("INVTSL_DiscountAmt") AS "saleDiscount", SUM("INVTSL_TaxAmt") AS "saleTax",
                SUM("INVTSL_Amount") AS "saleAmount", SUM("MSL"."INVMSL_SalesValue") AS "saleValue"
                FROM "INV"."INV_M_Sales" "MSL"
                INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                INNER JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSSF"."HRME_Id" = "HRE"."HRME_Id" 
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSSF"."HRME_Id" IN (' || p_HRME_Id || ') ' || v_dates || ' 
                GROUP BY "MSSF"."HRME_Id", "HRE"."HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"';

                EXECUTE v_Slqdymaic;
            END IF;

            IF p_optionflag = 'Customer' THEN
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
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSSC"."INVMC_Id" = "IMC"."INVMC_Id" 
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
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1 
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MST"."INVMI_Id" IN (' || p_INVMI_Id || ') ' || v_dates || ' 
                ORDER BY "INVMSL_SalesDate"';

                EXECUTE v_Slqdymaic;
            END IF;

            IF p_optionflag = 'Student' THEN
                v_Slqdymaic := '
                SELECT DISTINCT "ADM"."AMST_Id", "ADM"."AMST_AdmNo", "MI"."INVMI_ItemName",
                (COALESCE("ADM"."AMST_FirstName", '''') || 
                 CASE WHEN COALESCE("AMST_MiddleName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "AMST_MiddleName" END || 
                 CASE WHEN COALESCE("AMST_LastName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "AMST_LastName" END) AS "membername",
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
                INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSST"."AMST_Id" = "ADM"."AMST_Id" 
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSST"."AMST_Id" IN (' || p_AMST_Id || ') ' || v_dates || '
                ORDER BY "INVMSL_SalesDate"';

                EXECUTE v_Slqdymaic;
            END IF;

            IF p_optionflag = 'Staff' THEN
                v_Slqdymaic := '
                SELECT DISTINCT "MSL"."INVMSL_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName",
                (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || 
                 CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                 CASE WHEN COALESCE("HRME_EmployeeLastName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "membername",
                "MSL"."INVMSL_StuOtherFlg", "INVMSL_SalesNo", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", 
                "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
                FROM "INV"."INV_M_Sales" "MSL"
                INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                INNER JOIN "INV"."INV_M_Sales_Staff" "MSSF" ON "MSSF"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "MSSF"."HRME_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSSF"."HRME_Id" = "HRE"."HRME_Id" 
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSSF"."HRME_Id" IN (' || p_HRME_Id || ') ' || v_dates || '
                ORDER BY "INVMSL_SalesDate"';

                EXECUTE v_Slqdymaic;
            END IF;

            IF p_optionflag = 'Customer' THEN
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
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSSC"."INVMC_Id" = "IMC"."INVMC_Id" 
                AND "MSL"."MI_Id" = ' || p_MI_Id || ' AND "MSSC"."INVMC_Id" IN (' || p_INVMC_Id || ') ' || v_dates || '
                ORDER BY "INVMSL_SalesDate"';

                EXECUTE v_Slqdymaic;
            END IF;

            IF p_optionflag = 'Saleno' THEN
                v_Slqdymaic := '
                SELECT DISTINCT "MSL"."INVMSL_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName", 
                "ADM"."AMST_Id", "ADM"."AMST_AdmNo",
                (COALESCE("ADM"."AMST_FirstName", '''') || 
                 CASE WHEN COALESCE("AMST_MiddleName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "AMST_MiddleName" END || 
                 CASE WHEN COALESCE("AMST_LastName", '''', ''0'') IN ('''', ''0'') THEN '''' ELSE '' '' || "AMST_LastName" END) AS "membername",
                "INVMSL_SalesNo", "INVMSL_SalesDate", "MSL"."INVMSL_StuOtherFlg",
                CAST("MST"."INVTSL_SalesQty" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "INVTSL_SalesQty",
                ("MST"."INVTSL_SalesPrice") AS "INVTSL_SalesPrice", ("INVTSL_DiscountAmt") AS "INVTSL_DiscountAmt",
                ("INVTSL_TaxAmt") AS "INVTSL_TaxAmt", 
                CAST("INVTSL_Amount" / NULLIF("Mastersalescount", 0) AS DECIMAL(18,2)) AS "INVTSL_Amount",
                ("MSL"."INVMSL_SalesValue") AS "saleValue"
                FROM "INV"."INV_M_Sales" "MSL"
                LEFT JOIN "InvStuwiseSales_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
                LEFT JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                LEFT JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                LEFT JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSL"."MI_Id" = ' || p_MI_Id || ' 
                AND "MSL"."INVMSL_Id" IN (' || p_INVMSL_Id || ') ' || v_dates || ' 
                ORDER BY "INVMSL_SalesDate"';

                EXECUTE v_Slqdymaic;
            END IF;
        END IF;

    ELSE
        IF p_startdate != '' AND p_enddate != '' THEN
            v_dates := ' and "INVMSL_SalesDate"::date between TO_DATE(''' || p_startdate || ''',''DD/MM/YYYY'') and TO_DATE(''' || p_enddate || ''',''DD/MM/YYYY'')';
        ELSE
            v_dates := '';
        END IF;

        DROP TABLE IF EXISTS "InvStuwiseSales_Temp";
        DROP TABLE IF EXISTS "ItemSalesPrice_Temp";

        SELECT "ASMAY_Id" INTO v_ASMAY_Id 
        FROM "Adm_School_M_Academic_Year" 
        WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
        AND "MI_Id" = p_MI_Id;

        RAISE NOTICE 'year %', v_ASMAY_Id;

        CREATE TEMP TABLE "InvStuwiseSales_Temp" AS
        SELECT "INVMSL_Id", "Mastersalescount" 
        FROM (
            SELECT "INVMSL_Id", COUNT(*) AS "Mastersalescount" 
            FROM "INV"."INV_M_Sales_Student" 
            WHERE "INVMSLS_ActiveFlg" = 1 AND "ASMAY_Id" = v_ASMAY_Id 
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
            WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSL"."INVMST_Id" = ' || p_INVMST_Id || 
            ' AND "MSL"."MI_Id" = ' || p_MI_Id || ' ' || v_dates || ' ';

            EXECUTE v_Slqdymaic;
        END IF;

        IF (p_typeflag = 'Overall') THEN
            IF p_optionflag = 'Item' THEN
                v_Slqdymaic12 := 'CREATE TEMP TABLE "ItemSalesPrice_Temp" AS 
                SELECT DISTINCT "MST"."INVMI_I