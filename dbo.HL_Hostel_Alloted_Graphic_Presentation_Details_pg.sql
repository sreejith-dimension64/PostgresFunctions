CREATE OR REPLACE FUNCTION "dbo"."HL_Hostel_Alloted_Graphic_Presentation_Details"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "HLMH_Id" TEXT,
    "HLMF_Id" TEXT,
    "HLMRCA_Id" TEXT,
    "Type" VARCHAR(10)
)
RETURNS TABLE(
    "HLMH_Id" INTEGER,
    "HLMH_Name" TEXT,
    "HLMF_Id" INTEGER,
    "HRMF_FloorName" TEXT,
    "HLMRCA_Id" INTEGER,
    "HLMRCA_RoomCategory" TEXT,
    "HRMRM_Id" INTEGER,
    "HRMRM_RoomNo" TEXT,
    "HRMRM_BedCapacity" INTEGER,
    "AllotedBedsCount" BIGINT,
    "AvailableBedsCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Sqldynamic" TEXT;
BEGIN
    IF("Type" = 'C') THEN
        "Sqldynamic" := '
        SELECT "HLMH_Id", "HLMH_Name", "HLMF_Id", "HRMF_FloorName", "HLMRCA_Id", "HLMRCA_RoomCategory", 
               "HRMRM_Id", "HRMRM_RoomNo", "HRMRM_BedCapacity", COUNT("AMCST_Id") AS "AllotedBedsCount",
               "HRMRM_BedCapacity" - COUNT("AMCST_Id") AS "AvailableBedsCount"
        FROM (
            SELECT HML."HLMH_Id", "HLMH_Name", HMF."HLMF_Id", "HRMF_FloorName", HMRC."HLMRCA_Id", 
                   "HLMRCA_RoomCategory", HMR."HRMRM_Id", "HRMRM_RoomNo",
                   COALESCE("HRMRM_BedCapacity", 0) AS "HRMRM_BedCapacity", AC."AMCST_Id"
            FROM "HL_Master_Hostel" HML
            INNER JOIN "HL_Master_Floor" HMF ON HMF."HLMH_Id" = HML."HLMH_Id"
            INNER JOIN "HL_Master_Room" HMR ON HMR."HLMH_Id" = HMF."HLMH_Id" AND HMR."HLMF_Id" = HMF."HLMF_Id"
            INNER JOIN "HL_Master_Room_Category" HMRC ON HMRC."HLMRCA_Id" = HMR."HLMRCA_Id"
            LEFT JOIN "HL_Hostel_Student_Allot_College" AC ON AC."HLMH_Id" = HMF."HLMH_Id" 
                AND AC."HLMRCA_Id" = HMRC."HLMRCA_Id" AND AC."HRMRM_Id" = HMR."HRMRM_Id"
                AND "HLHSALTC_ActiveFlag" = 1 AND (COALESCE("HLHSALTC_VacateFlg", 0) = 0)
                AND AC."MI_Id"::TEXT = ANY(STRING_TO_ARRAY($1, '',''))
                AND AC."ASMAY_Id"::TEXT = ANY(STRING_TO_ARRAY($2, '',''))
                AND AC."HLMH_Id"::TEXT = ANY(STRING_TO_ARRAY($3, '',''))
                AND AC."HLMRCA_Id"::TEXT = ANY(STRING_TO_ARRAY($5, '',''))
            WHERE HML."MI_Id"::TEXT = ANY(STRING_TO_ARRAY($1, '',''))
                AND HML."HLMH_Id"::TEXT = ANY(STRING_TO_ARRAY($3, '',''))
                AND HMR."HLMF_Id"::TEXT = ANY(STRING_TO_ARRAY($4, '',''))
                AND HMR."HLMRCA_Id"::TEXT = ANY(STRING_TO_ARRAY($5, '',''))
        ) AS "New" 
        GROUP BY "HLMH_Id", "HLMH_Name", "HLMF_Id", "HRMF_FloorName", "HLMRCA_Id", 
                 "HLMRCA_RoomCategory", "HRMRM_Id", "HRMRM_RoomNo", "HRMRM_BedCapacity"';
        
        RETURN QUERY EXECUTE "Sqldynamic" USING "MI_Id", "ASMAY_Id", "HLMH_Id", "HLMF_Id", "HLMRCA_Id";
        
    ELSIF("Type" = 'S') THEN
        "Sqldynamic" := '
        SELECT "HLMH_Id", "HLMH_Name", "HLMF_Id", "HRMF_FloorName", "HLMRCA_Id", "HLMRCA_RoomCategory", 
               "HRMRM_Id", "HRMRM_RoomNo", "HRMRM_BedCapacity", COUNT("AMST_Id") AS "AllotedBedsCount",
               "HRMRM_BedCapacity" - COUNT("AMST_Id") AS "AvailableBedsCount"
        FROM (
            SELECT HML."HLMH_Id", "HLMH_Name", HMF."HLMF_Id", "HRMF_FloorName", HMRC."HLMRCA_Id", 
                   "HLMRCA_RoomCategory", HMR."HRMRM_Id", "HRMRM_RoomNo",
                   COALESCE("HRMRM_BedCapacity", 0) AS "HRMRM_BedCapacity", AC."AMST_Id"
            FROM "HL_Master_Hostel" HML
            INNER JOIN "HL_Master_Floor" HMF ON HMF."HLMH_Id" = HML."HLMH_Id"
            INNER JOIN "HL_Master_Room" HMR ON HMR."HLMH_Id" = HMF."HLMH_Id" AND HMR."HLMF_Id" = HMF."HLMF_Id"
            INNER JOIN "HL_Master_Room_Category" HMRC ON HMRC."HLMRCA_Id" = HMR."HLMRCA_Id"
            LEFT JOIN "HL_Hostel_Student_Allot" AC ON AC."HLMH_Id" = HMF."HLMH_Id" 
                AND AC."HLMRCA_Id" = HMRC."HLMRCA_Id" AND AC."HRMRM_Id" = HMR."HRMRM_Id"
                AND "HLHSALT_ActiveFlag" = 1 AND (COALESCE("HLHSALT_VacateFlg", 0) = 0)
                AND AC."MI_Id"::TEXT = ANY(STRING_TO_ARRAY($1, '',''))
                AND AC."ASMAY_Id"::TEXT = ANY(STRING_TO_ARRAY($2, '',''))
                AND AC."HLMH_Id"::TEXT = ANY(STRING_TO_ARRAY($3, '',''))
                AND AC."HLMRCA_Id"::TEXT = ANY(STRING_TO_ARRAY($5, '',''))
            WHERE HML."MI_Id"::TEXT = ANY(STRING_TO_ARRAY($1, '',''))
                AND HML."HLMH_Id"::TEXT = ANY(STRING_TO_ARRAY($3, '',''))
                AND HMR."HLMF_Id"::TEXT = ANY(STRING_TO_ARRAY($4, '',''))
                AND HMR."HLMRCA_Id"::TEXT = ANY(STRING_TO_ARRAY($5, '',''))
        ) AS "New" 
        GROUP BY "HLMH_Id", "HLMH_Name", "HLMF_Id", "HRMF_FloorName", "HLMRCA_Id", 
                 "HLMRCA_RoomCategory", "HRMRM_Id", "HRMRM_RoomNo", "HRMRM_BedCapacity"';
        
        RETURN QUERY EXECUTE "Sqldynamic" USING "MI_Id", "ASMAY_Id", "HLMH_Id", "HLMF_Id", "HLMRCA_Id";
        
    END IF;
    
    RETURN;
END;
$$;