CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_ALLOT_FOR_STUDENT"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT
)
RETURNS TABLE(
    "HLHSREQCC_BookingStatus" VARCHAR,
    "studentName" TEXT,
    "AMCST_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "AMCO_CourseCode" VARCHAR,
    "AMB_Id" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMB_BranchCode" VARCHAR,
    "AMCST_AdmNo" VARCHAR,
    "HLHSREQCC_ACRoomFlg" BOOLEAN,
    "HLHSREQCC_SingleRoomFlg" BOOLEAN,
    "HLHSREQCC_VegMessFlg" BOOLEAN,
    "HLHSREQCC_NonVegMessFlg" BOOLEAN,
    "HLMRCA_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "HSRC"."HLHSREQCC_BookingStatus",
        COALESCE("AMST"."AMCST_FirstName", '') || ' ' || COALESCE("AMST"."AMCST_MiddleName", '') || ' ' || COALESCE("AMST"."AMCST_LastName", '') AS "studentName",
        "AMST"."AMCST_Id",
        "MC"."AMCO_Id",
        "MC"."AMCO_CourseName",
        "MC"."AMCO_CourseCode",
        "MB"."AMB_Id",
        "MB"."AMB_BranchName",
        "MB"."AMB_BranchCode",
        "AMST"."AMCST_AdmNo",
        "HSRC"."HLHSREQCC_ACRoomFlg",
        "HSRC"."HLHSREQCC_SingleRoomFlg",
        "HSRC"."HLHSREQCC_VegMessFlg",
        "HSRC"."HLHSREQCC_NonVegMessFlg",
        "HSRC"."HLMRCA_Id"
    FROM "HL_Master_Hostel" "MH"
    INNER JOIN "HL_Hostel_Student_Request_College_Confirm" "HSRC" ON "HSRC"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Hostel_Student_Request_College" "HSR" ON "HSR"."HLHSREQC_Id" = "HSRC"."HLHSREQC_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" "AMST" ON "AMST"."AMCST_Id" = "HSR"."AMCST_Id" 
        AND "AMST"."AMCST_SOL" = 'S' AND "AMST"."AMCST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "AYS" ON "AYS"."AMCST_Id" = "AMST"."AMCST_Id" 
        AND "AYS"."ACYST_ActiveFlag" = 1
    INNER JOIN "HL_Hostel_Student_Allot_College" "HSA" ON "AYS"."AMCST_Id" = "HSA"."AMCST_Id" 
        AND "AYS"."AMCO_Id" = "HSA"."AMCO_Id" 
        AND "AYS"."AMB_Id" = "HSA"."AMB_Id" 
        AND "AYS"."AMSE_Id" = "HSA"."AMSE_Id"
        AND "AYS"."ACMS_Id" = "HSA"."ACMS_Id"
    INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "AYS"."AMCO_Id" = "MC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "AYS"."AMB_Id" = "MB"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "MS" ON "AYS"."AMSE_Id" = "MS"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" "Msec" ON "AYS"."ACMS_Id" = "Msec"."ACMS_Id"
    WHERE "MH"."MI_Id" = p_MI_Id 
        AND "AYS"."ASMAY_Id" = p_ASMAY_Id 
        AND "MH"."HLMH_ActiveFlag" = 1 
        AND "HSRC"."HLHSREQCC_ActiveFlag" = 1
        AND "AYS"."ACYST_ActiveFlag" = 1 
        AND "HSRC"."HLHSREQCC_BookingStatus" = 'Approved';
END;
$$;