CREATE OR REPLACE FUNCTION "Getreport_sportsnames"()
RETURNS TABLE(
    "VBSCMSCCG_SportsCCGroupName" VARCHAR,
    "VBSCMSCCG_Id" INTEGER,
    "VBSCMSCC_SportsCCName" VARCHAR,
    "VBSCMSCC_SportsCCDesc" VARCHAR,
    "VBSCMSCC_NoOfMembers" INTEGER,
    "VBSCMSCC_RecInfo" VARCHAR,
    "VBSCMSCC_RecHighLowFlag" VARCHAR,
    "VBSCMSCC_GenderFlg" VARCHAR,
    "VBSCMSCC_SGFlag" VARCHAR,
    "VBSCMSCC_Id" INTEGER,
    "VBSCMSCC_ActiveFlag" VARCHAR,
    "VBSCMSCCG_SCCFlag" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        A."VBSCMSCCG_SportsCCGroupName",
        A."VBSCMSCCG_Id",
        B."VBSCMSCC_SportsCCName",
        B."VBSCMSCC_SportsCCDesc",
        B."VBSCMSCC_NoOfMembers",
        B."VBSCMSCC_RecInfo",
        B."VBSCMSCC_RecHighLowFlag",
        B."VBSCMSCC_GenderFlg",
        B."VBSCMSCC_SGFlag",
        B."VBSCMSCC_Id",
        B."VBSCMSCC_ActiveFlag",
        A."VBSCMSCCG_SCCFlag"
    FROM "VBSC_Master_SportsCCGroupName" A
    INNER JOIN "VBSC_Master_SportsCCName" B ON A."VBSCMSCCG_Id" = B."VBSCMSCCG_Id";
END;
$$;