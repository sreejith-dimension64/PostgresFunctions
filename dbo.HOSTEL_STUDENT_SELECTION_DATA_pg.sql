CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_STUDENT_SELECTION_DATA"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMST_Id BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "HLMH_Name" VARCHAR,
    "HRMRM_RoomNo" VARCHAR,
    "HLHSALT_AllotmentDate" DATE
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HSA"."AMST_Id",
        COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS "studentname",
        "MC"."ASMCL_ClassName",
        "MS"."ASMC_SectionName",
        "MH"."HLMH_Name",
        "MR"."HRMRM_RoomNo",
        CAST("HSA"."HLHSALT_AllotmentDate" AS DATE) AS "HLHSALT_AllotmentDate"
    FROM "HL_Hostel_Student_Allot" "HSA"
    INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "HSA"."AMST_Id" 
        AND "YS"."ASMAY_Id" = "HSA"."ASMAY_Id" 
        AND "YS"."ASMCL_Id" = "HSA"."ASMCL_Id" 
        AND "YS"."ASMS_Id" = "HSA"."ASMS_Id"
    INNER JOIN "Adm_M_Student" "AMS" ON "YS"."AMST_Id" = "AMS"."AMST_Id" 
        AND "AMS"."AMST_ActiveFlag" = 1 
        AND "AMS"."AMST_SOL" = 'S' 
        AND "AMS"."AMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Class" "MC" ON "YS"."ASMCL_Id" = "MC"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "MS" ON "YS"."ASMS_Id" = "MS"."ASMS_Id"
    INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "AY" ON "YS"."ASMAY_Id" = "AY"."ASMAY_Id"
    WHERE "HSA"."MI_Id" = p_MI_Id 
        AND "YS"."ASMAY_Id" = p_ASMAY_Id 
        AND "YS"."AMST_Id" = p_AMST_Id;
END;
$$;