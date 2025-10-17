CREATE OR REPLACE FUNCTION "AUtoLedgerCreation" (
    p_MI_Id bigint,
    p_IMFY_Id bigint,
    p_FAMCOMP_Id bigint,
    p_FAMGRP_Id bigint,
    p_UserId bigint,
    p_type text,
    p_typeid bigint,
    p_CRDRFLG text
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FAMLED_Id bigint;
    v_Studentname text;
    v_Sales text;
    v_itemname text;
    v_rowcount integer;
BEGIN

    IF (p_type = 'Student') THEN
    
        BEGIN
            SELECT * FROM "Adm_Master_Student_LegderId" WHERE "AMST_Id" = p_typeid;
            GET DIAGNOSTICS v_rowcount = ROW_COUNT;
            
            IF v_rowcount = 0 THEN
            
                SELECT ("AMST_Firstname" || ' ' || COALESCE("AMST_Middlename", '') || ' ' || COALESCE("AMST_Lastname", '') || '-' || "AMST_AdmNo")
                INTO v_Studentname
                FROM "Adm_M_Student" 
                WHERE "AMST_Id" = p_typeid AND "MI_Id" = p_MI_Id;
                
                INSERT INTO "FA_M_Ledger" ("MI_Id", "FAMCOMP_Id", "IMFY_Id", "FAMGRP_Id", "FAMLED_LedgerName", "FAMLED_LedgerAliasName", "FAMLED_LedgerCreatedDate", "FAMLED_BillwiseFlg", "FAMLED_ActiveFlg", "FAMLED_CreatedDate", "FAMLED_UpdatedDate", "FAMLED_CreatedBy", "FAMLED_UpdatedBy")
                VALUES (p_MI_Id, p_FAMCOMP_Id, p_IMFY_Id, p_FAMGRP_Id, v_Studentname, v_Studentname, CURRENT_TIMESTAMP, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_UserId, p_UserId);
                
                SELECT MAX("FAMLED_Id") INTO v_FAMLED_Id FROM "FA_M_Ledger";
                
                INSERT INTO "FA_M_Ledger_Details" ("FAMLED_Id", "IMFY_Id", "FAMLEDD_OpeningBalance", "FAMLEDD_OBCRDRFlg", "FAMLEDD_ClosingBalance", "FAMLEDD_CBCRDRFlg", "FAMLEDD_OBDate", "FAMLEDD_BudgetAmount", "FAMLEDD_Remarks", "FAMLEDD_ActiveFlg", "FAMLEDD_CreatedDate", "FAMLEDD_UpdatedDate", "FAMLEDD_CreatedBy", "FAMLEDD_UpdatedBy")
                VALUES (v_FAMLED_Id, p_IMFY_Id, 0, p_CRDRFLG, 0, p_CRDRFLG, CURRENT_TIMESTAMP, 0, 'AUTO LEDGER CREATION', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_UserId, p_UserId);
                
                INSERT INTO "Adm_Master_Student_LegderId" ("AMST_Id", "FAMCOMP_Id", "FAMLED_Id", "AMSTLED_ActiveFlg", "AMSTLED_CreatedBy", "AMSTLED_UpdatedBy", "AMSTLED_CreatedDate", "AMSTLED_UpdatedDate")
                VALUES (p_typeid, p_FAMCOMP_Id, v_FAMLED_Id, 1, p_UserId, p_UserId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                
            END IF;
        END;
        
    END IF;

    IF (p_type = 'Sales') THEN
    
        BEGIN
            SELECT * FROM "INV"."INV_Master_Supplier_LegderId" WHERE "INVMS_Id" = p_typeid;
            GET DIAGNOSTICS v_rowcount = ROW_COUNT;
            
            IF v_rowcount = 0 THEN
            
                SELECT ("INVMS_SupplierName" || ' ' || COALESCE("INVMS_SupplierCode", ''))
                INTO v_Sales
                FROM "INV"."INV_Master_Supplier" 
                WHERE "INVMS_Id" = p_typeid AND "MI_Id" = p_MI_Id;
                
                INSERT INTO "FA_M_Ledger" ("MI_Id", "FAMCOMP_Id", "IMFY_Id", "FAMGRP_Id", "FAMLED_LedgerName", "FAMLED_LedgerAliasName", "FAMLED_LedgerCreatedDate", "FAMLED_BillwiseFlg", "FAMLED_ActiveFlg", "FAMLED_CreatedDate", "FAMLED_UpdatedDate", "FAMLED_CreatedBy", "FAMLED_UpdatedBy")
                VALUES (p_MI_Id, p_FAMCOMP_Id, p_IMFY_Id, p_FAMGRP_Id, v_Sales, v_Sales, CURRENT_TIMESTAMP, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_UserId, p_UserId);
                
                SELECT MAX("FAMLED_Id") INTO v_FAMLED_Id FROM "FA_M_Ledger";
                
                INSERT INTO "FA_M_Ledger_Details" ("FAMLED_Id", "IMFY_Id", "FAMLEDD_OpeningBalance", "FAMLEDD_OBCRDRFlg", "FAMLEDD_ClosingBalance", "FAMLEDD_CBCRDRFlg", "FAMLEDD_OBDate", "FAMLEDD_BudgetAmount", "FAMLEDD_Remarks", "FAMLEDD_ActiveFlg", "FAMLEDD_CreatedDate", "FAMLEDD_UpdatedDate", "FAMLEDD_CreatedBy", "FAMLEDD_UpdatedBy")
                VALUES (v_FAMLED_Id, p_IMFY_Id, 0, p_CRDRFLG, 0, p_CRDRFLG, CURRENT_TIMESTAMP, 0, 'AUTO LEDGER CREATION', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_UserId, p_UserId);
                
                INSERT INTO "INV"."INV_Master_Supplier_LegderId" ("INVMS_Id", "FAMCOMP_Id", "FAMLED_Id", "INVMSLED_ActiveFlg", "INVMSLED_CreatedBy", "INVMSLED_UpdatedBy", "INVMSLED_CreatedDate", "INVMSLED_UpdatedDate")
                VALUES (p_typeid, p_FAMCOMP_Id, v_FAMLED_Id, 1, p_UserId, p_UserId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                
            END IF;
        END;
        
    END IF;

    IF (p_type = 'Item') THEN
    
        BEGIN
            SELECT * FROM "INV"."INV_Master_Item_LegderId" WHERE "INVMI_Id" = p_typeid;
            GET DIAGNOSTICS v_rowcount = ROW_COUNT;
            
            IF v_rowcount = 0 THEN
            
                SELECT ("INVMI_ItemName" || ' ' || COALESCE("INVMI_ItemCode", ''))
                INTO v_itemname
                FROM "INV"."INV_Master_Item" 
                WHERE "INVMI_Id" = p_typeid AND "MI_Id" = p_MI_Id;
                
                INSERT INTO "FA_M_Ledger" ("MI_Id", "FAMCOMP_Id", "IMFY_Id", "FAMGRP_Id", "FAMLED_LedgerName", "FAMLED_LedgerAliasName", "FAMLED_LedgerCreatedDate", "FAMLED_BillwiseFlg", "FAMLED_ActiveFlg", "FAMLED_CreatedDate", "FAMLED_UpdatedDate", "FAMLED_CreatedBy", "FAMLED_UpdatedBy")
                VALUES (p_MI_Id, p_FAMCOMP_Id, p_IMFY_Id, p_FAMGRP_Id, v_itemname, v_itemname, CURRENT_TIMESTAMP, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_UserId, p_UserId);
                
                SELECT MAX("FAMLED_Id") INTO v_FAMLED_Id FROM "FA_M_Ledger";
                
                INSERT INTO "FA_M_Ledger_Details" ("FAMLED_Id", "IMFY_Id", "FAMLEDD_OpeningBalance", "FAMLEDD_OBCRDRFlg", "FAMLEDD_ClosingBalance", "FAMLEDD_CBCRDRFlg", "FAMLEDD_OBDate", "FAMLEDD_BudgetAmount", "FAMLEDD_Remarks", "FAMLEDD_ActiveFlg", "FAMLEDD_CreatedDate", "FAMLEDD_UpdatedDate", "FAMLEDD_CreatedBy", "FAMLEDD_UpdatedBy")
                VALUES (v_FAMLED_Id, p_IMFY_Id, 0, p_CRDRFLG, 0, p_CRDRFLG, CURRENT_TIMESTAMP, 0, 'AUTO LEDGER CREATION', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_UserId, p_UserId);
                
                INSERT INTO "INV"."INV_Master_Item_LegderId" ("INVMI_Id", "FAMCOMP_Id", "FAMLED_Id", "INVMILED_ActiveFlg", "INVMILED_CreatedBy", "INVMILED_UpdatedBy", "INVMILED_CreatedDate", "INVMILED_UpdatedDate")
                VALUES (p_typeid, p_FAMCOMP_Id, v_FAMLED_Id, 1, p_UserId, p_UserId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                
            END IF;
        END;
        
    END IF;

    RETURN;
    
END;
$$;