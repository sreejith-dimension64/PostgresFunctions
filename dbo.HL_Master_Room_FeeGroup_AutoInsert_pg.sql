CREATE OR REPLACE FUNCTION "dbo"."HL_Master_Room_FeeGroup_AutoInsert"(
    p_MI_Id bigint,
    p_HRMRM_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_HLMRCA_Id bigint;
    v_FMG_Id bigint;
    v_HRMRM_Id_C bigint;
    v_RFRcount int;
    category_rec RECORD;
    room_rec RECORD;
BEGIN
    FOR category_rec IN 
        SELECT DISTINCT "HLMRCA_Id", "FMG_Id" 
        FROM "HL_Master_Room_Category" 
        WHERE "MI_Id" = p_MI_Id AND "HLMRCA_ActiveFlag" = 1
    LOOP
        v_HLMRCA_Id := category_rec."HLMRCA_Id";
        v_FMG_Id := category_rec."FMG_Id";
        
        FOR room_rec IN 
            SELECT DISTINCT "HRMRM_Id" 
            FROM "HL_Master_Room" 
            WHERE "MI_Id" = p_MI_Id 
                AND "HLMRCA_Id" = v_HLMRCA_Id 
                AND "HRMRM_ActiveFlag" = 1 
                AND "HRMRM_Id" = p_HRMRM_Id
        LOOP
            v_HRMRM_Id_C := room_rec."HRMRM_Id";
            
            v_RFRcount := 0;
            
            SELECT COUNT(*) INTO v_RFRcount
            FROM "HL_Master_Room_FeeGroup" 
            WHERE "MI_Id" = p_MI_Id 
                AND "HLMRFG_ActiveFlag" = 1 
                AND "FMG_Id" = v_FMG_Id 
                AND "HRMRM_Id" = p_HRMRM_Id;
            
            IF (v_RFRcount = 0) THEN
                INSERT INTO "HL_Master_Room_FeeGroup"(
                    "MI_Id",
                    "HRMRM_Id",
                    "FMG_Id",
                    "HLMRFG_ActiveFlag",
                    "HLMRFG_CreatedDate",
                    "HLMRFG_UpdatedDate"
                )
                VALUES(
                    p_MI_Id,
                    v_HRMRM_Id_C,
                    v_FMG_Id,
                    1,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP
                );
            END IF;
            
        END LOOP;
        
    END LOOP;
    
END;
$$;