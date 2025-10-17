CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_STUDENT_REQUEST_DETAILS"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT
)
RETURNS TABLE(
    "HLHSREQC_Id" BIGINT,
    "AMCST_Id" BIGINT,
    "studentName" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "AMCST_AdmNo" TEXT,
    "HLMH_Name" TEXT,
    "HLMH_Id" BIGINT,
    "HLMRCA_RoomCategory" TEXT,
    "HLHSREQC_RequestDate" TIMESTAMP,
    "HLHSREQC_Remarks" TEXT,
    "HLHSREQC_BookingStatus" TEXT,
    "HLMRCA_Id" BIGINT,
    "HLHSREQC_ACRoomReqdFlg" BOOLEAN,
    "HLHSREQC_EntireRoomReqdFlg" BOOLEAN,
    "HLHSREQC_VegMessReqdFlg" BOOLEAN,
    "HLHSREQC_NonVegMessReqdFlg" BOOLEAN,
    "HLHSREQC_ActiveFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "HSR"."HLHSREQC_Id",
        "HSR"."AMCST_Id",
        COALESCE("AMS"."AMCST_FirstName", '') || ' ' || COALESCE("AMS"."AMCST_MiddleName", '') || ' ' || COALESCE("AMS"."AMCST_LastName", '') AS "studentName",
        "MC"."AMCO_CourseName",
        "MB"."AMB_BranchName",
        "MS"."AMSE_SEMName",
        "AMS"."AMCST_RegistrationNo",
        "AMS"."AMCST_AdmNo",
        "MH"."HLMH_Name",
        "HSR"."HLMH_Id",
        "MRC"."HLMRCA_RoomCategory",
        "HSR"."HLHSREQC_RequestDate",
        "HSR"."HLHSREQC_Remarks",
        "HSR"."HLHSREQC_BookingStatus",
        "HSR"."HLMRCA_Id",
        "HSR"."HLHSREQC_ACRoomReqdFlg",
        "HSR"."HLHSREQC_EntireRoomReqdFlg",
        "HSR"."HLHSREQC_VegMessReqdFlg",
        "HSR"."HLHSREQC_NonVegMessReqdFlg",
        "HSR"."HLHSREQC_ActiveFlag"
    FROM "HL_Hostel_Student_Request_College" "HSR"
    INNER JOIN "HL_Master_Hostel" "MH" ON "HSR"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Master_Room_Category" "MRC" ON "HSR"."HLMRCA_Id" = "MRC"."HLMRCA_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" "AMS" ON "AMS"."AMCST_Id" = "HSR"."AMCST_Id"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "AYS" ON "AYS"."AMCST_Id" = "AMS"."AMCST_Id" 
        AND "AMS"."AMCST_ActiveFlag" = true 
        AND "AMS"."AMCST_SOL" = 'S' 
        AND "AYS"."ACYST_ActiveFlag" = true
    INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "AYS"."AMCO_Id" = "MC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "AYS"."AMCO_Id" = "MB"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "MS" ON "MS"."AMSE_Id" = "AYS"."AMSE_Id"
    WHERE "HSR"."MI_Id" = p_MI_Id 
        AND "AYS"."ASMAY_Id" = p_ASMAY_Id 
        AND "HSR"."HLHSREQC_BookingStatus" = 'Waiting';
END;
$$;