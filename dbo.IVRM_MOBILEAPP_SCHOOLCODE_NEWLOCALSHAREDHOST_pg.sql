CREATE OR REPLACE FUNCTION "IVRM_MOBILEAPP_SCHOOLCODE_NEWLOCALSHAREDHOST"(
    "p_MI_Id" BIGINT,
    "p_SCHOOLNAME" VARCHAR(500),
    "p_SCHOOLLOGO" TEXT,
    "p_SCHOOLCODE" VARCHAR(500)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_IIVRSC_IdNEW" BIGINT;
BEGIN

    INSERT INTO "IVRM_IVRS_Configuration" (
        "IIVRSC_MI_Id", 
        "IIVRSC_VirtualNo", 
        "IIVRSC_SchoolName", 
        "IIVRSC_URL", 
        "IIVRSC_VFORTTSFlg", 
        "IIVRSC_ActiveFlg", 
        "CreatedDate", 
        "UpdatedDate", 
        "IIVRSC_SchoolFlg", 
        "IIVRSC_AppLogo", 
        "IIVRSC_SchoolCode"
    )
    SELECT 
        "p_MI_Id",
        "IIVRSC_VirtualNo", 
        "p_SCHOOLNAME",
        "IIVRSC_URL", 
        "IIVRSC_VFORTTSFlg", 
        1, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        1,
        "p_SCHOOLLOGO", 
        "p_SCHOOLCODE"
    FROM "IVRM_IVRS_Configuration" 
    WHERE "IIVRSC_Id" = 249
    RETURNING "IIVRSC_Id" INTO "v_IIVRSC_IdNEW";

    INSERT INTO "IVRM_Configuration_URL" (
        "IIVRSC_Id", 
        "IIVRSCURL_APIName", 
        "IIVRSCURL_APIURL", 
        "IIVRSCURL_CreatedDate", 
        "IIVRSCURL_UpdatedDate", 
        "IIVRSCURL_CreatedBy", 
        "IIVRSCURL_UpdatedBy"
    )
    SELECT 
        "v_IIVRSC_IdNEW",
        "IIVRSCURL_APIName",
        "IIVRSCURL_APIURL",
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '',
        ''
    FROM "IVRM_Configuration_URL" 
    WHERE "IIVRSC_Id" = 249;

    RETURN;

END;
$$;