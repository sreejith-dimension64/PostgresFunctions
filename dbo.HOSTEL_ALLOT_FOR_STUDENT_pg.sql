CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_ALLOT_FOR_STUDENT"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentName" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ASMAY_Id" BIGINT,
    "ASMAY_Year" VARCHAR,
    "HLMH_Name" VARCHAR,
    "HLMRCA_RoomCategory" VARCHAR,
    "HLHSALT_AllotmentDate" TIMESTAMP,
    "HLHSALT_Id" BIGINT,
    "HRMRM_RoomNo" VARCHAR,
    "HLHSALT_ActiveFlag" BOOLEAN,
    "HLMH_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMS"."AMST_Id",
        COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS "studentName",
        "MC"."ASMCL_ClassName",
        "AMS"."AMST_RegistrationNo",
        "AMS"."AMST_AdmNo",
        "AYS"."ASMAY_Id",
        "AY"."ASMAY_Year",
        "MH"."HLMH_Name",
        "MRC"."HLMRCA_RoomCategory",
        "HSA"."HLHSALT_AllotmentDate",
        "HSA"."HLHSALT_Id",
        "MR"."HRMRM_RoomNo",
        "HSA"."HLHSALT_ActiveFlag",
        "MH"."HLMH_Id"
    FROM "HL_Hostel_Student_Request_Confirm" "HSR"
    INNER JOIN "HL_Hostel_Student_Request" "HSRC" ON "HSRC"."HLHSREQ_Id" = "HSR"."HLHSREQ_Id"
    INNER JOIN "HL_Hostel_Student_Allot" "HSA" ON "HSRC"."AMST_Id" = "HSA"."AMST_Id"
    INNER JOIN "HL_Master_Hostel" "MH" ON "HSRC"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
    INNER JOIN "HL_Master_Room_Category" "MRC" ON "HSRC"."HLMRCA_Id" = "MRC"."HLMRCA_Id"
    INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "HSRC"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" "AYS" ON "AYS"."AMST_Id" = "AMS"."AMST_Id" 
        AND "AMS"."AMST_ActiveFlag" = 1 
        AND "AMS"."AMST_SOL" = 'S' 
        AND "AYS"."AMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Class" "MC" ON "AYS"."ASMCL_Id" = "MC"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "MS" ON "AYS"."ASMS_Id" = "MS"."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "AY" ON "AYS"."ASMAY_Id" = "AY"."ASMAY_Id"
    WHERE "HSRC"."MI_Id" = p_MI_Id 
        AND "AYS"."ASMAY_Id" = p_ASMAY_Id 
        AND "HSR"."HLHSREQC_BookingStatus" = 'Approved';
END;
$$;