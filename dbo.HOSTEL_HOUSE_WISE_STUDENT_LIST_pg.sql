CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_HOUSE_WISE_STUDENT_LIST"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_HLMH_Id BIGINT
)
RETURNS TABLE(
    "HLHSREQC_BookingStatus" VARCHAR,
    "studentName" TEXT,
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMS_Id" BIGINT,
    "ASMC_SectionName" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "HLHSREQC_ACRoomFlg" BOOLEAN,
    "HLHSREQC_SingleRoomFlg" BOOLEAN,
    "HLHSREQC_VegMessFlg" BOOLEAN,
    "HLHSREQC_NonVegMessFlg" BOOLEAN,
    "HLMRCA_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        HSRC."HLHSREQC_BookingStatus",
        COALESCE(AMST."AMST_FirstName", '') || ' ' || COALESCE(AMST."AMST_MiddleName", '') || ' ' || COALESCE(AMST."AMST_LastName", '') AS "studentName",
        AMST."AMST_Id",
        MC."ASMCL_Id",
        MC."ASMCL_ClassName",
        MS."ASMS_Id",
        MS."ASMC_SectionName",
        AMST."AMST_AdmNo",
        HSRC."HLHSREQC_ACRoomFlg",
        HSRC."HLHSREQC_SingleRoomFlg",
        HSRC."HLHSREQC_VegMessFlg",
        HSRC."HLHSREQC_NonVegMessFlg",
        HSRC."HLMRCA_Id"
    FROM "HL_Master_Hostel" MH
    INNER JOIN "HL_Hostel_Student_Request_Confirm" HSRC ON HSRC."HLMH_Id" = MH."HLMH_Id"
    INNER JOIN "HL_Hostel_Student_Request" HSR ON HSR."HLHSREQ_Id" = HSRC."HLHSREQ_Id"
    INNER JOIN "Adm_M_Student" AMST ON AMST."AMST_Id" = HSR."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" AYS ON AYS."AMST_Id" = AMST."AMST_Id" 
        AND AMST."AMST_ActiveFlag" = 1 
        AND AMST."AMST_SOL" = 'S' 
        AND AYS."AMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Class" MC ON AYS."ASMCL_Id" = MC."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" MS ON AYS."ASMS_Id" = MS."ASMS_Id"
    WHERE MH."MI_Id" = p_MI_Id 
        AND MH."HLMH_Id" = p_HLMH_Id 
        AND AYS."ASMAY_Id" = p_ASMAY_Id 
        AND MH."HLMH_ActiveFlag" = 1 
        AND HSRC."HLHSREQC_ActiveFlag" = 1
        AND AYS."AMAY_ActiveFlag" = 1 
        AND HSRC."HLHSREQC_BookingStatus" = 'Approved';
END;
$$;