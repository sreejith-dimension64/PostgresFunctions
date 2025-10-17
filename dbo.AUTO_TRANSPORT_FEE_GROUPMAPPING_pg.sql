CREATE OR REPLACE FUNCTION "AUTO_TRANSPORT_FEE_GROUPMAPPING" (
    p_MI_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_NASMAY_ID BIGINT,
    p_USERID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_TRMLID BIGINT;
    v_FMGID BIGINT;
    rec RECORD;
BEGIN
    FOR rec IN 
        SELECT "TRML_Id", "FMG_Id" 
        FROM "TRN"."TR_Location_FeeGroup_Mapping"
        WHERE "MI_Id" = p_MI_ID 
        AND "ASMAY_Id" = p_ASMAY_ID
    LOOP
        v_TRMLID := rec."TRML_Id";
        v_FMGID := rec."FMG_Id";
        
        INSERT INTO "TRN"."TR_Location_FeeGroup_Mapping" (
            "MI_Id",
            "TRML_Id",
            "FMG_Id",
            "ASMAY_Id",
            "TRLFM_ActiveFlag",
            "CreatedDate",
            "UpdatedDate",
            "TRLFM_CreatedBy",
            "TRLFM_UpdatedBy"
        )
        VALUES (
            p_MI_ID,
            v_TRMLID,
            v_FMGID,
            p_NASMAY_ID,
            1,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            p_USERID,
            p_USERID
        );
    END LOOP;
    
    RETURN;
END;
$$;