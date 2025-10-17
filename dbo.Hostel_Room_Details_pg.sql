CREATE OR REPLACE FUNCTION "dbo"."Hostel_Room_Details"(
    p_MI_Id BIGINT,
    p_HLMH_Id BIGINT,
    p_HLMF_Id BIGINT,
    p_HLMRCA_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_HRMRM_Id BIGINT
)
RETURNS TABLE(
    "HLMH_Name" VARCHAR,
    "HRMF_FloorName" VARCHAR,
    "HLMRCA_RoomCategory" VARCHAR,
    "HRMRM_RoomNo" VARCHAR,
    "HRMRM_BedCapacity" INTEGER,
    "AllotedCount" BIGINT,
    "AvailableBedCapacity" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HMH"."HLMH_Name",
        "HMF"."HRMF_FloorName",
        "HMRC"."HLMRCA_RoomCategory",
        "HMR"."HRMRM_RoomNo",
        "HMR"."HRMRM_BedCapacity",
        COUNT("AC"."AMCST_Id") AS "AllotedCount",
        ("HMR"."HRMRM_BedCapacity" - COUNT("AC"."AMCST_Id")) AS "AvailableBedCapacity"
    FROM "HL_Master_Room" "HMR"
    INNER JOIN "HL_Master_Room_Category" "HMRC" 
        ON "HMRC"."HLMRCA_Id" = "HMR"."HLMRCA_Id" 
        AND "HMR"."HLMH_Id" = "HMRC"."HLMH_Id"
    INNER JOIN "HL_Master_Hostel" "HMH" 
        ON "HMH"."HLMH_Id" = "HMR"."HLMH_Id"
    INNER JOIN "HL_Master_Floor" "HMF" 
        ON "HMF"."HLMF_Id" = "HMR"."HLMF_Id"
    LEFT JOIN "HL_Hostel_Student_Allot_College" "AC" 
        ON "AC"."HLMH_Id" = "HMR"."HLMH_Id" 
        AND "AC"."HLMRCA_Id" = "HMRC"."HLMRCA_Id" 
        AND "AC"."HRMRM_Id" = "HMR"."HRMRM_Id" 
        AND "AC"."ASMAY_Id" = p_ASMAY_Id
    WHERE "HMR"."MI_Id" = p_MI_Id 
        AND "HMR"."HLMH_Id" = p_HLMH_Id 
        AND "HMRC"."HLMRCA_Id" = p_HLMRCA_Id 
        AND "HMR"."HRMRM_Id" = p_HRMRM_Id 
        AND "HMR"."HRMRM_ActiveFlag" = true
    GROUP BY 
        "HMH"."HLMH_Name",
        "HMF"."HRMF_FloorName",
        "HMRC"."HLMRCA_RoomCategory",
        "HMR"."HRMRM_RoomNo",
        "HMR"."HRMRM_BedCapacity";
END;
$$;