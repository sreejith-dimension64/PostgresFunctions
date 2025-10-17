CREATE OR REPLACE FUNCTION "dbo"."INV_PurchageIndent_Approval"(p_User_Id bigint)
RETURNS TABLE(
    "MI_Id" bigint,
    "MI_Name" text,
    "INVMPI_Id" bigint,
    "INVMPI_PINo" text,
    "INVMPI_PIDate" timestamp,
    "INVMPI_Remarks" text,
    "INVMPI_ReferenceNo" text,
    "INVMPI_ApproxTotAmount" decimal(18,2),
    "INVMPI_RejectFlg" boolean,
    "User_Id" bigint,
    "SanctionLevelNo" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SanctionLevelNo bigint;
    v_Rcount bigint;
    v_Rcount1 bigint;
    v_MaxSanctionLevelNo bigint;
    v_MaxSanctionLevelNo_New bigint;
    v_ApprCount bigint;
    v_INVMPI_Id bigint;
    v_MI_Id bigint;
    v_Preuserid bigint;
    indent_rec RECORD;
BEGIN
    DROP TABLE IF EXISTS "INV_PurchageIndent_Approval_Temp";

    CREATE TEMP TABLE "INV_PurchageIndent_Approval_Temp" (
        "MI_Id" bigint,
        "MI_Name" text,
        "INVMPI_Id" bigint,
        "INVMPI_PINo" text,
        "INVMPI_PIDate" timestamp,
        "INVMPI_Remarks" text,
        "INVMPI_ReferenceNo" text,
        "INVMPI_ApproxTotAmount" decimal(18,2),
        "INVMPI_RejectFlg" boolean,
        "User_Id" bigint,
        "SanctionLevelNo" bigint
    );

    v_Rcount1 := 0;
    
    SELECT COUNT(*) INTO v_Rcount1
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'PI' AND "IVRMUL_Id" = p_User_Id;

    IF v_Rcount1 > 0 THEN
        v_SanctionLevelNo := 0;
        v_MaxSanctionLevelNo := 0;
        v_Preuserid := 0;

        SELECT MAX("HRPAON_SanctionLevelNo") INTO v_MaxSanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'PI';

        SELECT "HRPAON_SanctionLevelNo" INTO v_SanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'PI' AND "IVRMUL_Id" = p_User_Id;

        FOR indent_rec IN 
            SELECT DISTINCT "INVMPI_Id", "MI_Id" 
            FROM "INV"."INV_M_PurchaseIndent" 
            WHERE "INVMPI_POCreatedFlg" = FALSE 
            AND (COALESCE("INVMPI_RejectFlg", FALSE) = FALSE)
            AND (COALESCE("INVMPI_FinalProcessFlag", FALSE) = FALSE)
        LOOP
            v_INVMPI_Id := indent_rec."INVMPI_Id";
            v_MI_Id := indent_rec."MI_Id";

            IF (v_SanctionLevelNo = 1) THEN
                v_Rcount := 0;
                
                SELECT COUNT(*) INTO v_Rcount
                FROM "INV"."INV_M_PurchaseIndent_Approval" "PIA" 
                WHERE "INVMPIAPP_ApprovedBy" = p_User_Id 
                AND ("INVMPIAPP_RejectFlg" = FALSE OR "INVMPIAPP_RejectFlg" = TRUE) 
                AND "INVMPI_Id" = v_INVMPI_Id 
                AND "MI_Id" = v_MI_Id;

                IF (v_Rcount = 0) THEN
                    INSERT INTO "INV_PurchageIndent_Approval_Temp" (
                        "MI_Id", "MI_Name", "INVMPI_Id", "INVMPI_PINo", "INVMPI_PIDate", 
                        "INVMPI_Remarks", "INVMPI_ReferenceNo", "INVMPI_ApproxTotAmount", 
                        "INVMPI_RejectFlg", "User_Id", "SanctionLevelNo"
                    )
                    SELECT 
                        "MI"."MI_Id", "MI_Name", "INVMPI_Id", "INVMPI_PINo", "INVMPI_PIDate", 
                        "INVMPI_Remarks", "INVMPI_ReferenceNo", "INVMPI_ApproxTotAmount", 
                        "INVMPI_RejectFlg", p_User_Id, v_SanctionLevelNo
                    FROM "INV"."INV_M_PurchaseIndent" "PI"
                    INNER JOIN "Master_Institution" "MI" ON "PI"."MI_Id" = "MI"."MI_Id" 
                    WHERE (COALESCE("INVMPI_RejectFlg", FALSE) = FALSE)
                    AND "INVMPI_ActiveFlg" = TRUE 
                    AND "PI"."INVMPI_Id" = v_INVMPI_Id 
                    AND "PI"."MI_Id" = v_MI_Id 
                    AND "PI"."INVMPI_Id" NOT IN (
                        SELECT DISTINCT "INVMPI_Id" 
                        FROM "INV"."INV_M_PurchaseIndent_Approval" 
                        WHERE "INVMPIAPP_ApprovedBy" = p_User_Id
                    );
                END IF;
            END IF;

            v_Rcount := 0;
            SELECT COUNT(*) INTO v_Rcount
            FROM "INV"."INV_M_PurchaseIndent_Approval" "PIA" 
            WHERE ("INVMPIAPP_RejectFlg" = FALSE OR "INVMPIAPP_RejectFlg" = TRUE) 
            AND "INVMPI_Id" = v_INVMPI_Id 
            AND "MI_Id" = v_MI_Id;

            IF (v_Rcount > 0) THEN
                SELECT DISTINCT "IVRMUL_Id" INTO v_Preuserid
                FROM "HR_Process_Authorisation" "PA"
                INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                WHERE "HRPA_TypeFlag" = 'PI' 
                AND "IVRMUL_Id" IN (
                    SELECT DISTINCT "IVRMUL_Id"
                    FROM "HR_Process_Authorisation" "PA"
                    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                    WHERE "HRPA_TypeFlag" = 'PI' 
                    AND "HRPAON_SanctionLevelNo" = v_SanctionLevelNo - 1
                )
                LIMIT 1;

                INSERT INTO "INV_PurchageIndent_Approval_Temp"(
                    "MI_Id", "MI_Name", "INVMPI_Id", "INVMPI_PINo", "INVMPI_PIDate", 
                    "INVMPI_Remarks", "INVMPI_ReferenceNo", "INVMPI_ApproxTotAmount", 
                    "INVMPI_RejectFlg", "User_Id", "SanctionLevelNo"
                )
                SELECT 
                    "MI"."MI_Id", "MI_Name", "INVMPI_Id", "INVMPIAPP_PINo", "INVMPIAPP_PIDate", 
                    "INVMPIAPP_Remarks", "INVMPIAPP_ReferenceNo", "INVMPIAPP_ApproxTotAmount", 
                    "INVMPIAPP_RejectFlg", "INVMPIAPP_ApprovedBy", v_SanctionLevelNo
                FROM "INV"."INV_M_PurchaseIndent_Approval" "PIA"
                INNER JOIN "Master_Institution" "MI" ON "PIA"."MI_Id" = "MI"."MI_Id" 
                WHERE "INVMPIAPP_ActiveFlg" = TRUE
                AND ("INVMPIAPP_RejectFlg" = FALSE OR "INVMPIAPP_RejectFlg" = TRUE) 
                AND "INVMPI_Id" = v_INVMPI_Id 
                AND "PIA"."MI_Id" = v_MI_Id 
                AND "PIA"."INVMPI_Id" NOT IN (
                    SELECT DISTINCT "INVMPI_Id" 
                    FROM "INV"."INV_M_PurchaseIndent_Approval" 
                    WHERE "INVMPIAPP_ApprovedBy" = p_User_Id
                )
                AND "PIA"."INVMPIAPP_ApprovedBy" = v_Preuserid;
            END IF;

            v_ApprCount := 0;
            SELECT COUNT(*) INTO v_ApprCount
            FROM "INV"."INV_M_PurchaseIndent_Approval" "PIA" 
            WHERE ("INVMPIAPP_RejectFlg" = FALSE OR "INVMPIAPP_RejectFlg" = TRUE) 
            AND "INVMPI_Id" = v_INVMPI_Id 
            AND "MI_Id" = v_MI_Id;

            v_MaxSanctionLevelNo_New := v_MaxSanctionLevelNo - 1;
        END LOOP;

        RETURN QUERY 
        SELECT DISTINCT 
            "A"."MI_Id", 
            "A"."MI_Name", 
            "A"."INVMPI_Id", 
            "A"."INVMPI_PINo", 
            "A"."INVMPI_PIDate", 
            "A"."INVMPI_Remarks", 
            "A"."INVMPI_ReferenceNo", 
            "A"."INVMPI_ApproxTotAmount", 
            "A"."INVMPI_RejectFlg", 
            "A"."User_Id", 
            "A"."SanctionLevelNo"
        FROM "INV_PurchageIndent_Approval_Temp" "A";
    END IF;
END;
$$;