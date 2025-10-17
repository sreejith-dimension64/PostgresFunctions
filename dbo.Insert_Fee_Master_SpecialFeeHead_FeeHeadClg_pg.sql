CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Master_SpecialFeeHead_FeeHeadClg"(
    p_mi_id bigint,
    p_FMSFH_Name varchar(50),
    p_IVRMSTAUL_Id bigint,
    p_fmh_id bigint,
    p_FMSFH_ActiceFlag boolean,
    p_FMSFH_Id bigint,
    p_curtime timestamp,
    p_userid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_maxid bigint;
    v_rowcount integer;
BEGIN
    
    SELECT * FROM "Fee_Master_SpecialFeeHead" 
    WHERE "FMSFH_Name" = p_FMSFH_Name AND "MI_Id" = p_mi_id;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount = 0 THEN
        INSERT INTO "Fee_Master_SpecialFeeHead" (
            "MI_Id",
            "FMSFH_Name",
            "FMSFH_ActiceFlag",
            "IVRMSTAUL_Id",
            "CreatedDate",
            "UpdatedDate",
            "FMSFH_CreatedBy",
            "FMSFH_UpdatedBy"
        ) VALUES (
            p_mi_id,
            p_FMSFH_Name,
            p_FMSFH_ActiceFlag,
            p_IVRMSTAUL_Id,
            p_curtime,
            p_curtime,
            p_userid,
            p_userid
        );
    END IF;
    
    SELECT MAX("FMSFH_Id") INTO v_maxid FROM "Fee_Master_SpecialFeeHead";
    
    INSERT INTO "Fee_Master_SpecialFeeHead_FeeHead" (
        "FMSFH_Id",
        "FMH_Id",
        "FMSFHFH_ActiceFlag",
        "CreatedDate",
        "UpdatedDate",
        "FMSFHFH_CreatedBy",
        "FMSFHFH_UpdatedBy"
    ) VALUES (
        v_maxid,
        p_fmh_id,
        true,
        p_curtime,
        p_curtime,
        p_userid,
        p_userid
    );
    
END;
$$;