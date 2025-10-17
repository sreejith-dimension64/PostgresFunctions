CREATE OR REPLACE FUNCTION "dbo"."Hostel_Requested_Student_List"(p_MI_Id BIGINT)
RETURNS TABLE(
    "HLHSREQC_BookingStatus" VARCHAR,
    "studentName" TEXT,
    "AMCST_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "AMCO_CourseCode" VARCHAR,
    "AMB_Id" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMB_BranchCode" VARCHAR,
    "AMCST_AdmNo" VARCHAR,
    "HLHSREQC_ACRoomReqdFlg" BOOLEAN,
    "HLHSREQC_EntireRoomReqdFlg" BOOLEAN,
    "HLHSREQC_VegMessReqdFlg" BOOLEAN,
    "HLHSREQC_NonVegMessReqdFlg" BOOLEAN,
    "HLHSREQC_Id" BIGINT,
    "HLMRCA_Id" BIGINT,
    "HLHSREQC_Remarks" TEXT,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT,
    "AMCST_RegistrationNo" VARCHAR,
    "AMCST_MobileNo" VARCHAR,
    "AMCST_emailId" VARCHAR,
    "AMSE_SEMName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT "HSR"."HLHSREQC_BookingStatus",
        COALESCE("AMST"."AMCST_FirstName", '') || ' ' || COALESCE("AMST"."AMCST_MiddleName", '') || ' ' || COALESCE("AMST"."AMCST_LastName", '') AS "studentName",
        "AMST"."AMCST_Id",
        "MC"."AMCO_Id",
        "MC"."AMCO_CourseName",
        "MC"."AMCO_CourseCode",
        "MB"."AMB_Id",
        "MB"."AMB_BranchName",
        "MB"."AMB_BranchCode",
        "AMST"."AMCST_AdmNo",
        "HSR"."HLHSREQC_ACRoomReqdFlg",
        "HSR"."HLHSREQC_EntireRoomReqdFlg",
        "HSR"."HLHSREQC_VegMessReqdFlg",
        "HSR"."HLHSREQC_NonVegMessReqdFlg",
        "HSR"."HLHSREQC_Id",
        "HSR"."HLMRCA_Id",
        "HSR"."HLHSREQC_Remarks",
        "MS"."AMSE_Id",
        "Msec"."ACMS_Id",
        "AMST"."AMCST_RegistrationNo",
        "AMST"."AMCST_MobileNo",
        "AMST"."AMCST_emailId",
        "MS"."AMSE_SEMName"
    FROM "HL_Master_Hostel" "MH"
    INNER JOIN "HL_Hostel_Student_Request_College" "HSR" ON "HSR"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" "AMST" ON "AMST"."AMCST_Id" = "HSR"."AMCST_Id" 
        AND "AMST"."AMCST_SOL" = 'S' AND "AMST"."AMCST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "AYS" ON "AYS"."AMCST_Id" = "AMST"."AMCST_Id" 
        AND "AYS"."ACYST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "AYS"."AMCO_Id" = "MC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "AYS"."AMB_Id" = "MB"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "MS" ON "AYS"."AMSE_Id" = "MS"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" "Msec" ON "AYS"."ACMS_Id" = "Msec"."ACMS_Id"
    WHERE "MH"."MI_Id" = 5 
        AND "MH"."HLMH_ActiveFlag" = 1 
        AND "HSR"."HLHSREQC_ActiveFlag" = 1
        AND "AYS"."ACYST_ActiveFlag" = 1 
        AND "HSR"."HLHSREQC_BookingStatus" = 'Waiting'
        AND "AMST"."AMCST_Id" NOT IN (
            SELECT DISTINCT "AMCST_Id" 
            FROM "HL_Hostel_Student_Allot_College" "HHSALC" 
            WHERE "HHSALC"."HLHSALTC_ActiveFlag" = 1
        );
END;
$$;