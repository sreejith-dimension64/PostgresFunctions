CREATE OR REPLACE FUNCTION "dbo"."INV_BillForMonth_Report"(
    p_MI_ID BIGINT,
    p_ASMAY_Id BIGINT,
    p_OptionFlag VARCHAR(50),
    p_AMST_ID BIGINT DEFAULT NULL,
    p_ASMCL_ID BIGINT,
    p_Startdate TEXT,
    p_Enddate TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "AMST_AdmNo" VARCHAR,
    "StudentName" TEXT,
    "ClassSection" TEXT,
    "SaleAmount" NUMERIC,
    "INVMI_ItemCode" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVSTO_BatchNo" VARCHAR,
    "INVSTO_SalesRate" NUMERIC,
    "INVSTO_AvaiableStock" NUMERIC,
    "saleQty" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_OptionFlag = 'All') THEN
        IF (p_Startdate = '') THEN
            RETURN QUERY
            SELECT DISTINCT "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                   SUM("NEW"."saleAmount") AS "SaleAmount",
                   "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                   "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            FROM (
                SELECT DISTINCT "ASYS"."ASMAY_Id", "ADM"."AMST_Id", "ADM"."AMST_AdmNo", "ASYS"."AMAY_RollNo",
                       ("ASMC"."ASMCL_ClassName" || '-' || "ASMS"."ASMC_SectionName") AS "ClassSection",
                       ((CASE WHEN "ADM"."AMST_FirstName" IS NULL OR "ADM"."AMST_FirstName" = '' THEN '' ELSE "ADM"."AMST_FirstName" END ||
                         CASE WHEN "ADM"."AMST_MiddleName" IS NULL OR "ADM"."AMST_MiddleName" = '' OR "ADM"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_MiddleName" END ||
                         CASE WHEN "ADM"."AMST_LastName" IS NULL OR "ADM"."AMST_LastName" = '' OR "ADM"."AMST_LastName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_LastName" END)) AS "StudentName",
                       "MI"."INVMI_Id",
                       CAST("MST"."INVTSL_SalesQty" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleQty",
                       ("MST"."INVTSL_SalesPrice") AS "salePrice",
                       ("MST"."INVTSL_DiscountAmt") AS "saleDiscount",
                       "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "sto"."INVSTO_BatchNo", 
                       "sto"."INVSTO_SalesRate", "sto"."INVSTO_AvaiableStock",
                       ("MST"."INVTSL_TaxAmt") AS "saleTax",
                       CAST("MST"."INVTSL_Amount" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleAmount",
                       ("MSL"."INVMSL_SalesValue") AS "saleValue"
                FROM "INV"."INV_M_Sales" "MSL"
                INNER JOIN "PDA_BillForMonth_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
                INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ADM"."AMST_Id"
                INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
                INNER JOIN "inv"."INV_Stock" "sto" ON "sto"."INVMI_Id" = "MI"."INVMI_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSST"."AMST_Id" = "ADM"."AMST_Id" 
                  AND "MSL"."MI_Id" = p_MI_ID AND "ASYS"."ASMAY_Id" = p_ASMAY_Id
            ) AS "NEW"
            GROUP BY "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                     "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                     "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            HAVING SUM("NEW"."saleAmount") > 0;
        ELSE
            RETURN QUERY
            SELECT DISTINCT "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                   SUM("NEW"."saleAmount") AS "SaleAmount",
                   "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                   "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            FROM (
                SELECT DISTINCT "ASYS"."ASMAY_Id", "ADM"."AMST_Id", "ADM"."AMST_AdmNo", "ASYS"."AMAY_RollNo",
                       ("ASMC"."ASMCL_ClassName" || '-' || "ASMS"."ASMC_SectionName") AS "ClassSection",
                       ((CASE WHEN "ADM"."AMST_FirstName" IS NULL OR "ADM"."AMST_FirstName" = '' THEN '' ELSE "ADM"."AMST_FirstName" END ||
                         CASE WHEN "ADM"."AMST_MiddleName" IS NULL OR "ADM"."AMST_MiddleName" = '' OR "ADM"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_MiddleName" END ||
                         CASE WHEN "ADM"."AMST_LastName" IS NULL OR "ADM"."AMST_LastName" = '' OR "ADM"."AMST_LastName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_LastName" END)) AS "StudentName",
                       "MI"."INVMI_Id",
                       CAST("MST"."INVTSL_SalesQty" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleQty",
                       ("MST"."INVTSL_SalesPrice") AS "salePrice",
                       ("MST"."INVTSL_DiscountAmt") AS "saleDiscount",
                       "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "sto"."INVSTO_BatchNo", 
                       "sto"."INVSTO_SalesRate", "sto"."INVSTO_AvaiableStock",
                       ("MST"."INVTSL_TaxAmt") AS "saleTax",
                       CAST("MST"."INVTSL_Amount" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleAmount",
                       ("MSL"."INVMSL_SalesValue") AS "saleValue"
                FROM "INV"."INV_M_Sales" "MSL"
                INNER JOIN "PDA_BillForMonth_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
                INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ADM"."AMST_Id"
                INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
                INNER JOIN "inv"."INV_Stock" "sto" ON "sto"."INVMI_Id" = "MI"."INVMI_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSST"."AMST_Id" = "ADM"."AMST_Id" 
                  AND "MSL"."MI_Id" = p_MI_ID AND "ASYS"."ASMAY_Id" = p_ASMAY_Id
                  AND CAST("MSL"."INVMSL_SalesDate" AS DATE) BETWEEN CAST(p_Startdate AS DATE) AND CAST(p_Enddate AS DATE)
            ) AS "NEW"
            GROUP BY "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                     "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                     "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            HAVING SUM("NEW"."saleAmount") > 0;
        END IF;

    ELSIF (p_OptionFlag = 'Individual') THEN
        IF (p_Startdate = '') THEN
            RETURN QUERY
            SELECT DISTINCT "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                   SUM("NEW"."saleAmount") AS "SaleAmount",
                   "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                   "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            FROM (
                SELECT DISTINCT "ASYS"."ASMAY_Id", "ADM"."AMST_Id", "ADM"."AMST_AdmNo", "ASYS"."AMAY_RollNo",
                       ("ASMC"."ASMCL_ClassName" || '-' || "ASMS"."ASMC_SectionName") AS "ClassSection",
                       ((CASE WHEN "ADM"."AMST_FirstName" IS NULL OR "ADM"."AMST_FirstName" = '' THEN '' ELSE "ADM"."AMST_FirstName" END ||
                         CASE WHEN "ADM"."AMST_MiddleName" IS NULL OR "ADM"."AMST_MiddleName" = '' OR "ADM"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_MiddleName" END ||
                         CASE WHEN "ADM"."AMST_LastName" IS NULL OR "ADM"."AMST_LastName" = '' OR "ADM"."AMST_LastName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_LastName" END)) AS "StudentName",
                       "MI"."INVMI_Id",
                       CAST("MST"."INVTSL_SalesQty" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleQty",
                       ("MST"."INVTSL_SalesPrice") AS "salePrice",
                       ("MST"."INVTSL_DiscountAmt") AS "saleDiscount",
                       "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "sto"."INVSTO_BatchNo", 
                       "sto"."INVSTO_SalesRate", "sto"."INVSTO_AvaiableStock",
                       ("MST"."INVTSL_TaxAmt") AS "saleTax",
                       CAST("MST"."INVTSL_Amount" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleAmount",
                       ("MSL"."INVMSL_SalesValue") AS "saleValue"
                FROM "INV"."INV_M_Sales" "MSL"
                INNER JOIN "PDA_BillForMonth_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
                INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ADM"."AMST_Id"
                INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
                INNER JOIN "inv"."INV_Stock" "sto" ON "sto"."INVMI_Id" = "MI"."INVMI_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSST"."AMST_Id" = "ADM"."AMST_Id" 
                  AND "MSL"."MI_Id" = p_MI_ID AND "ASYS"."ASMAY_Id" = p_ASMAY_Id 
                  AND "ASYS"."ASMCL_Id" = p_ASMCL_ID
            ) AS "NEW"
            GROUP BY "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                     "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                     "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            HAVING SUM("NEW"."saleAmount") > 0;
        ELSE
            RAISE NOTICE 'Startdate: %', p_Startdate;
            RAISE NOTICE 'Enddate: %', p_Enddate;
            
            RETURN QUERY
            SELECT DISTINCT "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                   SUM("NEW"."saleAmount") AS "SaleAmount",
                   "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                   "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            FROM (
                SELECT DISTINCT "ASYS"."ASMAY_Id", "ADM"."AMST_Id", "ADM"."AMST_AdmNo", "ASYS"."AMAY_RollNo",
                       ("ASMC"."ASMCL_ClassName" || '-' || "ASMS"."ASMC_SectionName") AS "ClassSection",
                       ((CASE WHEN "ADM"."AMST_FirstName" IS NULL OR "ADM"."AMST_FirstName" = '' THEN '' ELSE "ADM"."AMST_FirstName" END ||
                         CASE WHEN "ADM"."AMST_MiddleName" IS NULL OR "ADM"."AMST_MiddleName" = '' OR "ADM"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_MiddleName" END ||
                         CASE WHEN "ADM"."AMST_LastName" IS NULL OR "ADM"."AMST_LastName" = '' OR "ADM"."AMST_LastName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_LastName" END)) AS "StudentName",
                       "MI"."INVMI_Id",
                       CAST("MST"."INVTSL_SalesQty" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleQty",
                       ("MST"."INVTSL_SalesPrice") AS "salePrice",
                       ("MST"."INVTSL_DiscountAmt") AS "saleDiscount",
                       "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "sto"."INVSTO_BatchNo", 
                       "sto"."INVSTO_SalesRate", "sto"."INVSTO_AvaiableStock",
                       ("MST"."INVTSL_TaxAmt") AS "saleTax",
                       CAST("MST"."INVTSL_Amount" / NULLIF("ISST"."Mastersalescount", 0) AS NUMERIC(18,2)) AS "saleAmount",
                       ("MSL"."INVMSL_SalesValue") AS "saleValue"
                FROM "INV"."INV_M_Sales" "MSL"
                INNER JOIN "PDA_BillForMonth_Temp" "ISST" ON "MSL"."INVMSL_Id" = "ISST"."INVMSL_Id"
                INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
                INNER JOIN "INV"."INV_M_Sales_Student" "MSST" ON "MSST"."INVMSL_Id" = "MSL"."INVMSL_Id"
                INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "MSST"."AMST_Id"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ADM"."AMST_Id"
                INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
                INNER JOIN "inv"."INV_Stock" "sto" ON "sto"."INVMI_Id" = "MI"."INVMI_Id"
                WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MSST"."AMST_Id" = "ADM"."AMST_Id" 
                  AND "MSL"."MI_Id" = p_MI_ID AND "ASYS"."ASMAY_Id" = p_ASMAY_Id 
                  AND "ASYS"."ASMCL_Id" = p_ASMCL_ID
                  AND CAST("MSL"."INVMSL_SalesDate" AS DATE) BETWEEN CAST(p_Startdate AS DATE) AND CAST(p_Enddate AS DATE)
            ) AS "NEW"
            GROUP BY "NEW"."AMST_Id", "NEW"."AMST_AdmNo", "NEW"."StudentName", "NEW"."ClassSection", 
                     "NEW"."INVMI_ItemCode", "NEW"."INVMI_ItemName", "NEW"."INVSTO_BatchNo", 
                     "NEW"."INVSTO_SalesRate", "NEW"."INVSTO_AvaiableStock", "NEW"."saleQty"
            HAVING SUM("NEW"."saleAmount") > 0;
        END IF;
    END IF;

    RETURN;
END;
$$;