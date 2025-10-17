CREATE OR REPLACE FUNCTION "dbo"."FMS_Correspondence_AutoGenerateNo"(
    "p_MI_Id" TEXT,
    "p_HRMD_Id" TEXT,
    "p_FMSMFC_Id" TEXT,
    "p_ISMMCLT_Id" TEXT,
    "p_ISMSLE_Id" TEXT,
    "p_INVMS_Id" TEXT,
    "p_IMFY_Id" TEXT,
    "p_ClientSupplierFlg" TEXT,
    OUT "p_FileGenNo" TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    "v_String" TEXT;
    "v_FinancialYear" TEXT;
    "v_Rowcount" BIGINT;
    "v_FileNo" BIGINT;
    "v_K" INT;
    "v_MI_Code" TEXT;
    "v_CategoryCode" TEXT;
    "v_DeptCode" TEXT;
    "v_INVMS_SupplierCode" TEXT;
    "v_ISMMCLT_Code" TEXT;
    "v_ISMSLE_LeadCode" TEXT;
    "v_Internal" TEXT;
    "v_Others" TEXT;
BEGIN

    "v_FileNo" := 0;

    SELECT "MI_Code" INTO "v_MI_Code" FROM "Master_Institution" WHERE "MI_Id" = "p_MI_Id";
    
    SELECT "FMSMFC_FileCategoryCode" INTO "v_CategoryCode" 
    FROM "FMS_Master_FileCategory" 
    WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_ActiveFlg" = 1 AND "FMSMFC_Id" = "p_FMSMFC_Id";

    SELECT "HRMDC_Code" INTO "v_DeptCode" 
    FROM "HR_Master_Department" "MD"
    INNER JOIN "HR_Master_DepartmentCode" "MDCode" ON "MD"."HRMDC_ID" = "MDCode"."HRMDC_ID" 
    WHERE "MD"."MI_Id" = "p_MI_Id" AND "MD"."HRMD_Id" = "p_HRMD_Id";

    SELECT "IMFY_FinancialYear" INTO "v_FinancialYear" 
    FROM "IVRM_Master_FinancialYear" 
    WHERE "IMFY_Id" = "p_IMFY_Id";

    IF (COALESCE("v_FinancialYear", '') <> '' AND COALESCE("v_DeptCode", '') <> '' AND COALESCE("v_CategoryCode", '') <> '' AND COALESCE("v_MI_Code", '') <> '') THEN

        IF ("p_ClientSupplierFlg" = 'Client' OR "p_ClientSupplierFlg" = 'Supplier' OR "p_ClientSupplierFlg" = 'Sales Lead') THEN

            SELECT "ISMMCLT_Code" INTO "v_ISMMCLT_Code" 
            FROM "ISM_Master_Client" 
            WHERE "ISMMCLT_Id" = "p_ISMMCLT_Id" AND "MI_Id" = "p_MI_Id";

            SELECT "ISMSLE_LeadCode" INTO "v_ISMSLE_LeadCode" 
            FROM "ISM_Sales_Lead" 
            WHERE "MI_Id" = "p_MI_Id" AND "ISMSLE_Id" = "p_ISMSLE_Id";

            SELECT "INVMS_SupplierCode" INTO "v_INVMS_SupplierCode" 
            FROM "INV"."INV_Master_Supplier" 
            WHERE "MI_Id" = "p_MI_Id" AND "INVMS_Id" = "p_INVMS_Id";

        ELSIF ("p_ClientSupplierFlg" = 'Internal' OR "p_ClientSupplierFlg" = 'INT') THEN
            "v_Internal" := 'INT';
        ELSIF ("p_ClientSupplierFlg" = 'Others' OR "p_ClientSupplierFlg" = 'OTH') THEN
            "v_Others" := 'OTH';
        END IF;

        IF (COALESCE("v_ISMMCLT_Code", '') <> '' AND "p_ClientSupplierFlg" = 'Client') THEN

            RAISE NOTICE 'client code 1';

            "v_String" := "v_MI_Code" || '/' || "v_DeptCode" || '/' || "v_CategoryCode" || '/' || "v_ISMMCLT_Code" || '/' || "v_FinancialYear";

            SELECT COUNT(*) INTO "v_Rowcount" 
            FROM "FMS_Correspondence" 
            WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id" AND "IMFY_Id" = "p_IMFY_Id" 
            AND SUBSTRING("FMSCOR_RefernceNo", 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) = "v_String";

            IF ("v_Rowcount" > 0) THEN

                SELECT MAX(CAST(SUBSTRING(REVERSE("FMSCOR_RefernceNo"), 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) AS BIGINT)) 
                INTO "v_FileNo"
                FROM "FMS_Correspondence" 
                WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id";

                "v_K" := "v_FileNo" + 1;

            ELSE
                "v_K" := 1;
            END IF;

            "p_FileGenNo" := "v_String" || '/' || LPAD("v_K"::TEXT, 3, '0');

            RAISE NOTICE '%', "p_FileGenNo";

        ELSIF (COALESCE("v_ISMSLE_LeadCode", '') <> '' AND "p_ClientSupplierFlg" = 'Sales Lead') THEN

            "v_String" := "v_MI_Code" || '/' || "v_DeptCode" || '/' || "v_CategoryCode" || '/' || "v_ISMSLE_LeadCode" || '/' || "v_FinancialYear";

            SELECT COUNT(*) INTO "v_Rowcount" 
            FROM "FMS_Correspondence" 
            WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id" AND "IMFY_Id" = "p_IMFY_Id"
            AND SUBSTRING("FMSCOR_RefernceNo", 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) = "v_String";

            IF ("v_Rowcount" > 0) THEN

                SELECT MAX(CAST(SUBSTRING(REVERSE("FMSCOR_RefernceNo"), 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) AS BIGINT)) 
                INTO "v_FileNo"
                FROM "FMS_Correspondence" 
                WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id";

                "v_K" := "v_FileNo" + 1;

            ELSE
                "v_K" := 1;
            END IF;

            "p_FileGenNo" := "v_String" || '/' || LPAD("v_K"::TEXT, 3, '0');

            RAISE NOTICE '%', "p_FileGenNo";

        ELSIF (COALESCE("v_INVMS_SupplierCode", '') <> '' AND "p_ClientSupplierFlg" = 'Supplier') THEN

            "v_String" := "v_MI_Code" || '/' || "v_DeptCode" || '/' || "v_CategoryCode" || '/' || "v_INVMS_SupplierCode" || '/' || "v_FinancialYear";

            SELECT COUNT(*) INTO "v_Rowcount" 
            FROM "FMS_Correspondence" 
            WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id" AND "IMFY_Id" = "p_IMFY_Id"
            AND SUBSTRING("FMSCOR_RefernceNo", 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) = "v_String";

            IF ("v_Rowcount" > 0) THEN

                SELECT MAX(CAST(SUBSTRING(REVERSE("FMSCOR_RefernceNo"), 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) AS BIGINT)) 
                INTO "v_FileNo"
                FROM "FMS_Correspondence" 
                WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id";

                "v_K" := "v_FileNo" + 1;

            ELSE
                "v_K" := 1;
            END IF;

            "p_FileGenNo" := "v_String" || '/' || LPAD("v_K"::TEXT, 3, '0');

            RAISE NOTICE '%', "p_FileGenNo";

        ELSIF ("v_Internal" = 'INT' AND "p_ClientSupplierFlg" = 'Internal') THEN

            "v_String" := "v_MI_Code" || '/' || "v_DeptCode" || '/' || "v_CategoryCode" || '/' || "v_Internal" || '/' || "v_FinancialYear";

            SELECT COUNT(*) INTO "v_Rowcount" 
            FROM "FMS_Correspondence" 
            WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id" AND "IMFY_Id" = "p_IMFY_Id"
            AND SUBSTRING("FMSCOR_RefernceNo", 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) = "v_String";

            IF ("v_Rowcount" > 0) THEN

                SELECT MAX(CAST(SUBSTRING(REVERSE("FMSCOR_RefernceNo"), 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) AS BIGINT)) 
                INTO "v_FileNo"
                FROM "FMS_Correspondence" 
                WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id";

                "v_K" := "v_FileNo" + 1;

            ELSE
                "v_K" := 1;
            END IF;

            "p_FileGenNo" := "v_String" || '/' || LPAD("v_K"::TEXT, 3, '0');

            RAISE NOTICE '%', "p_FileGenNo";

        ELSE

            IF ("v_Others" = 'OTH' AND "p_ClientSupplierFlg" = 'Others') THEN
                RAISE NOTICE '1----others';

                "v_String" := "v_MI_Code" || '/' || "v_DeptCode" || '/' || "v_CategoryCode" || '/' || "v_Others" || '/' || "v_FinancialYear";

                SELECT COUNT(*) INTO "v_Rowcount" 
                FROM "FMS_Correspondence" 
                WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id" AND "IMFY_Id" = "p_IMFY_Id"
                AND SUBSTRING("FMSCOR_RefernceNo", 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) = "v_String";

                IF ("v_Rowcount" > 0) THEN

                    SELECT MAX(CAST(SUBSTRING(REVERSE("FMSCOR_RefernceNo"), 1, POSITION('/' IN REVERSE("FMSCOR_RefernceNo")) - 1) AS BIGINT)) 
                    INTO "v_FileNo"
                    FROM "FMS_Correspondence" 
                    WHERE "MI_Id" = "p_MI_Id" AND "FMSMFC_Id" = "p_FMSMFC_Id";

                    "v_K" := "v_FileNo" + 1;

                ELSE
                    "v_K" := 1;
                END IF;

                "p_FileGenNo" := "v_String" || '/' || LPAD("v_K"::TEXT, 3, '0');

                RAISE NOTICE '%', "p_FileGenNo";

            END IF;

        END IF;

    ELSE

        "p_FileGenNo" := 'Codes';
        RAISE NOTICE '%', "p_FileGenNo";

    END IF;

    RETURN;

END;
$$;