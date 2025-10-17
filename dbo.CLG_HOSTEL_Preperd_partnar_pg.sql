CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_Preperd_partnar"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@HLMH_Id" BIGINT,
    "@Type" TEXT,
    "@HRMRM_Id" BIGINT,
    "@HLMRCA_Id" BIGINT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "studentName" TEXT,
    "AMCST_AdmNo" VARCHAR,
    "AMCO_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "AMB_Id" BIGINT,
    "ACMS_Id" BIGINT,
    "HLMRCA_Id" BIGINT,
    "AMCST_RegistrationNo" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "AMCST_MobileNo" VARCHAR,
    "AMCST_emailId" VARCHAR,
    "HLHSREQC_VegMessReqdFlg" BOOLEAN,
    "HLHSREQC_NonVegMessReqdFlg" BOOLEAN,
    "HLHSREQC_ACRoomReqdFlg" BOOLEAN,
    "HLHSREQC_EntireRoomReqdFlg" BOOLEAN,
    "HLMRCA_RoomCategory" VARCHAR,
    "HRMRM_RoomNo" VARCHAR,
    "HRMRM_SharingFlg" BOOLEAN,
    "HRMRM_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@Type" = 'Search' THEN
        RETURN QUERY
        SELECT 
            a."AMCST_Id", 
            COALESCE(e."AMCST_FirstName", '') || ' ' || COALESCE(e."AMCST_MiddleName", '') || ' ' || COALESCE(e."AMCST_LastName", '') || ' ' || COALESCE(e."AMCST_RegistrationNo", '') as "studentName",
            e."AMCST_AdmNo",
            a."AMCO_Id",
            a."AMSE_Id",
            a."AMB_Id",
            a."ACMS_Id",
            a."HLMRCA_Id",
            e."AMCST_RegistrationNo",
            f."AMCO_CourseName",
            g."AMB_BranchName",
            h."AMSE_SEMName",
            e."AMCST_MobileNo",
            e."AMCST_emailId",
            m."HLHSREQC_VegMessReqdFlg",
            m."HLHSREQC_NonVegMessReqdFlg",
            m."HLHSREQC_ACRoomReqdFlg",
            m."HLHSREQC_EntireRoomReqdFlg",
            d."HLMRCA_RoomCategory",
            n."HRMRM_RoomNo",
            n."HRMRM_SharingFlg",
            a."HRMRM_Id"
        FROM "HL_Hostel_Student_Allot_College" a
        INNER JOIN "HL_Master_Hostel" l ON a."HLMH_Id" = l."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" d ON a."HLMRCA_Id" = d."HLMRCA_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" e ON a."AMCST_Id" = e."AMCST_Id"
        INNER JOIN "CLG"."adm_college_yearly_student" i ON e."AMCST_Id" = i."AMCST_Id" 
            AND i."ASMAY_Id" = a."ASMAY_Id" 
            AND i."AMCO_Id" = a."AMCO_Id" 
            AND i."AMB_Id" = a."AMB_Id" 
            AND i."AMSE_Id" = a."AMSE_Id" 
            AND i."ACMS_Id" = a."ACMS_Id" 
            AND i."ACYST_ActiveFlag" = 1 
            AND e."AMCST_SOL" = 'S' 
            AND e."AMCST_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Course" f ON a."AMCO_Id" = f."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" g ON a."AMB_Id" = g."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" h ON a."AMSE_Id" = h."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" k ON k."ACMS_Id" = a."ACMS_Id"
        INNER JOIN "HL_Hostel_Student_Request_College" m ON a."AMCST_Id" = m."AMCST_Id"
        INNER JOIN "HL_Master_Room" n ON a."HRMRM_Id" = n."HRMRM_Id"
        WHERE a."HLHSALTC_ActiveFlag" = 1 
            AND a."MI_Id" = "@MI_Id" 
            AND a."HLMH_Id" = "@HLMH_Id" 
            AND a."ASMAY_Id" = "@ASMAY_Id" 
            AND a."HLMRCA_Id" = "@HLMRCA_Id";
    END IF;

    RETURN;

END;
$$;