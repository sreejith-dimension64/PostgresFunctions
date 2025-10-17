CREATE OR REPLACE FUNCTION "dbo"."ISM_resignation_checklist_update_proc"(
    p_ISMRESG_Id bigint,
    p_ISMRESGMCL_Id bigint,
    p_ISMRESGCL_FileName text,
    p_ISMRESGCL_FilePath text,
    p_MI_Id bigint,
    p_userId bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRMD_Id bigint;
    v_hrmeid bigint;
    v_count_r bigint;
    v_count_rc bigint;
BEGIN
    INSERT INTO "dbo"."ISM_Resignation_ChecKLists"(
        "MI_Id",
        "ISMRESG_Id",
        "ISMRESGMCL_Id",
        "ISMRESGCL_FileName",
        "ISMRESGCL_FilePath",
        "ISMRESGCL_ActiveFlag",
        "CreatedDate",
        "ISMRESGCL_CreatedBy"
    ) 
    VALUES(
        p_MI_Id,
        p_ISMRESG_Id,
        p_ISMRESGMCL_Id,
        p_ISMRESGCL_FileName,
        p_ISMRESGCL_FilePath,
        1,
        CURRENT_TIMESTAMP,
        p_userId
    );

    SELECT "HRME_Id" INTO v_hrmeid 
    FROM "dbo"."ISM_Resignation" 
    WHERE "ISMRESG_Id" = p_ISMRESG_Id;

    SELECT "HRMD_Id" INTO v_HRMD_Id 
    FROM "dbo"."HR_Master_Employee" 
    WHERE "HRME_Id" = v_hrmeid 
    AND "MI_Id" = p_MI_Id;

    SELECT COUNT(*) INTO v_count_r 
    FROM "dbo"."ISM_Resignation_ChecKLists" 
    WHERE "ISMRESG_Id" = p_ISMRESG_Id;

    SELECT COUNT(*) INTO v_count_rc 
    FROM "dbo"."ISM_Resignation_Master_CheckLists" 
    WHERE "HRMD_Id" = v_HRMD_Id;

    IF (v_count_r = v_count_rc) THEN
        UPDATE "dbo"."ISM_Resignation" 
        SET "ISMRESG_Status_Flg" = 1 
        WHERE "ISMRESG_Id" = p_ISMRESG_Id;
    END IF;

    RETURN;
END;
$$;