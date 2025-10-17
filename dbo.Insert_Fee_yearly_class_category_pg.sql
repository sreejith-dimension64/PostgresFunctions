CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_yearly_class_category"(
    p_mi_id BIGINT,
    p_asmay_id BIGINT,
    p_fmcc_id BIGINT,
    p_amcl_id BIGINT,
    p_activeflag BOOLEAN,
    p_FYCC_Id BIGINT,
    p_User_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_maxid BIGINT;
    v_return BIGINT;
    v_FYCCRcount BIGINT;
    v_FYCCCRcount BIGINT;
BEGIN
    v_return := 0;

    IF (p_FYCC_Id = 0) THEN
        -- insert --
        SELECT COUNT(*) INTO v_FYCCRcount 
        FROM "Fee_Yearly_Class_Category" 
        WHERE "MI_Id" = p_mi_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "FMCC_Id" = p_fmcc_id;

        IF (v_FYCCRcount = 0) THEN
            INSERT INTO "Fee_Yearly_Class_Category" 
                ("MI_Id", "FMCC_Id", "ASMAY_Id", "FYCC_ActiveFlag", "CreatedDate", "UpdatedDate", "FYCC_CreatedBy") 
            VALUES 
                (p_mi_id, p_fmcc_id, p_asmay_id, p_activeflag, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_User_id);
        END IF;

        SELECT "FYCC_Id" INTO v_maxid 
        FROM "Fee_Yearly_Class_Category" 
        WHERE "MI_Id" = p_mi_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "FMCC_Id" = p_fmcc_id;

        SELECT COUNT(*) INTO v_FYCCCRcount 
        FROM "Fee_Yearly_Class_Category_Classes" 
        WHERE "FYCC_Id" = v_maxid 
            AND "ASMCL_Id" = p_amcl_id;

        IF (v_FYCCCRcount = 0) THEN
            INSERT INTO "Fee_Yearly_Class_Category_Classes" 
                ("FYCC_Id", "ASMCL_Id", "CreatedDate", "UpdatedDate", "FYCCC_CreatedBy") 
            VALUES 
                (v_maxid, p_amcl_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_User_id);
            v_return := 1;
            RAISE NOTICE 'sucess';
        ELSE
            v_return := 0;
            RAISE NOTICE 'fail';
        END IF;
    ELSE
        -- updating ---
        SELECT COUNT(*) INTO v_FYCCCRCount 
        FROM "Fee_Yearly_Class_Category_Classes" 
        WHERE "FYCC_Id" = p_FYCC_Id;

        IF (v_FYCCCRCount <> 0) THEN
            UPDATE "Fee_Yearly_Class_Category_Classes" 
            SET "ASMCL_Id" = p_amcl_id,
                "UpdatedDate" = CURRENT_TIMESTAMP,
                "FYCCC_UpdatedBy" = p_User_id 
            WHERE "FYCC_Id" = p_FYCC_Id;

            UPDATE "Fee_Yearly_Class_Category" 
            SET "MI_Id" = p_mi_id,
                "ASMAY_Id" = p_asmay_id,
                "FMCC_Id" = p_fmcc_id,
                "FYCC_ActiveFlag" = p_activeflag,
                "UpdatedDate" = CURRENT_TIMESTAMP,
                "FYCC_UpdatedBy" = p_User_id 
            WHERE "FYCC_Id" = p_FYCC_Id;

            v_return := 1;
            RAISE NOTICE 'sucess';
        END IF;
    END IF;

    RETURN v_return;
END;
$$;