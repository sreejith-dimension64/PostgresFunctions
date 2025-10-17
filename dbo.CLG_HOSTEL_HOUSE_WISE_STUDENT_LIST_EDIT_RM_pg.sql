CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_HOUSE_WISE_STUDENT_LIST_EDIT_RM"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@HLMH_Id" BIGINT,
    "@Type" TEXT
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
    "HLHSREQC_ACRoomReqdFlg" BOOLEAN,
    "HLHSREQC_EntireRoomReqdFlg" BOOLEAN,
    "HLHSREQC_VegMessReqdFlg" BOOLEAN,
    "HLHSREQC_NonVegMessReqdFlg" BOOLEAN,
    "HLMRCA_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@Type" = 'Request' THEN
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
            "HSR"."HLHSREQC_ACRoomReqdFlg",
            "HSR"."HLHSREQC_EntireRoomReqdFlg",
            "HSR"."HLHSREQC_VegMessReqdFlg",
            "HSR"."HLHSREQC_NonVegMessReqdFlg",
            "HSRC"."HLMRCA_Id",
            "MS"."AMSE_Id",
            "Msec"."ACMS_Id"
        FROM "HL_Master_Hostel" "MH"
        INNER JOIN "HL_Hostel_Student_Request_College_Confirm" "HSRC" ON "HSRC"."HLMH_Id" = "MH"."HLMH_Id"
        INNER JOIN "HL_Hostel_Student_Request_College" "HSR" ON "HSR"."HLHSREQC_Id" = "HSRC"."HLHSREQC_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" "AMST" ON "AMST"."AMCST_Id" = "HSR"."AMCST_Id" 
            AND "AMST"."AMCST_SOL" = 'S' AND "AMST"."AMCST_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "AYS" ON "AYS"."AMCST_Id" = "AMST"."AMCST_Id" 
            AND "AYS"."ACYST_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "AYS"."AMCO_Id" = "MC"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "AYS"."AMB_Id" = "MB"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "MS" ON "AYS"."AMSE_Id" = "MS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "Msec" ON "AYS"."ACMS_Id" = "Msec"."ACMS_Id"
        WHERE "MH"."MI_Id" = "@MI_Id" 
            AND "MH"."HLMH_Id" = "@HLMH_Id" 
            AND "AYS"."ASMAY_Id" = "@ASMAY_Id" 
            AND "MH"."HLMH_ActiveFlag" = 1 
            AND "HSRC"."HLHSREQCC_ActiveFlag" = 1
            AND "AYS"."ACYST_ActiveFlag" = 1 
            AND "HSRC"."HLHSREQCC_BookingStatus" = 'Approved'
            AND "AMST"."AMCST_Id" NOT IN (
                SELECT DISTINCT "AMCST_Id" 
                FROM "HL_Hostel_Student_Allot_College" "HHSALC" 
                WHERE "HHSALC"."ASMAY_Id" = "@ASMAY_Id" 
                    AND "HHSALC"."HLHSALTC_ActiveFlag" = 1
            );
    
    ELSIF "@Type" = 'Manual' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::VARCHAR AS "HLHSREQCC_BookingStatus",
            COALESCE("AMST"."AMCST_FirstName", '') || ' ' || COALESCE("AMST"."AMCST_MiddleName", '') || ' ' || COALESCE("AMST"."AMCST_LastName", '') AS "studentName",
            "AMST"."AMCST_Id",
            "MC"."AMCO_Id",
            "MC"."AMCO_CourseName",
            "MC"."AMCO_CourseCode",
            "MB"."AMB_Id",
            "MB"."AMB_BranchName",
            "MB"."AMB_BranchCode",
            "AMST"."AMCST_AdmNo",
            NULL::BOOLEAN AS "HLHSREQC_ACRoomReqdFlg",
            NULL::BOOLEAN AS "HLHSREQC_EntireRoomReqdFlg",
            NULL::BOOLEAN AS "HLHSREQC_VegMessReqdFlg",
            NULL::BOOLEAN AS "HLHSREQC_NonVegMessReqdFlg",
            NULL::BIGINT AS "HLMRCA_Id",
            "MS"."AMSE_Id",
            "Msec"."ACMS_Id"
        FROM "CLG"."Adm_Master_College_Student" "AMST"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "AYS" ON "AYS"."AMCST_Id" = "AMST"."AMCST_Id" 
            AND "AYS"."ACYST_ActiveFlag" = 1 
            AND "AMST"."AMCST_SOL" = 'S' 
            AND "AMST"."AMCST_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "AYS"."AMCO_Id" = "MC"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "AYS"."AMB_Id" = "MB"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "MS" ON "AYS"."AMSE_Id" = "MS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "Msec" ON "AYS"."ACMS_Id" = "Msec"."ACMS_Id"
        WHERE "AMST"."MI_Id" = "@MI_Id" 
            AND "AYS"."ASMAY_Id" = "@ASMAY_Id";
    
    END IF;

    RETURN;

END;
$$;