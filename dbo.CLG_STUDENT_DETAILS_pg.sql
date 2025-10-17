CREATE OR REPLACE FUNCTION "dbo"."CLG_STUDENT_DETAILS"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_HLMH_Id BIGINT,
    p_Type TEXT,
    p_AMCST_Id BIGINT
)
RETURNS TABLE (
    "AMCST_Id" BIGINT,
    "studentName" TEXT,
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "AMCO_CourseCode" VARCHAR,
    "AMB_Id" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMB_BranchCode" VARCHAR,
    "AMCST_AdmNo" VARCHAR,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT,
    "AMCST_RegistrationNo" VARCHAR,
    "AMCST_MobileNo" VARCHAR,
    "AMCST_emailId" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "HLMRCA_RoomCategory" VARCHAR,
    "HRMRM_RoomNo" VARCHAR,
    "HRMRM_SharingFlg" VARCHAR,
    "HRMRM_ACFlg" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "ACMS_SectionCode" VARCHAR,
    "AMSE_SEMCode" VARCHAR,
    "HRMRM_Id" BIGINT,
    "HLMRCA_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_Type = 'studentlist' THEN
        RETURN QUERY
        SELECT 
            a."AMCST_Id",
            COALESCE(e."AMCST_FirstName", '') || ' ' || COALESCE(e."AMCST_MiddleName", '') || ' ' || COALESCE(e."AMCST_LastName", '') || ' ' || COALESCE(e."AMCST_RegistrationNo", '') AS "studentName",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            NULL::VARCHAR AS "AMCO_CourseCode",
            NULL::BIGINT AS "AMB_Id",
            NULL::VARCHAR AS "AMB_BranchName",
            NULL::VARCHAR AS "AMB_BranchCode",
            NULL::VARCHAR AS "AMCST_AdmNo",
            NULL::BIGINT AS "AMSE_Id",
            NULL::BIGINT AS "ACMS_Id",
            NULL::VARCHAR AS "AMCST_RegistrationNo",
            NULL::VARCHAR AS "AMCST_MobileNo",
            NULL::VARCHAR AS "AMCST_emailId",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::VARCHAR AS "HLMRCA_RoomCategory",
            NULL::VARCHAR AS "HRMRM_RoomNo",
            NULL::VARCHAR AS "HRMRM_SharingFlg",
            NULL::VARCHAR AS "HRMRM_ACFlg",
            NULL::VARCHAR AS "ACMS_SectionName",
            NULL::VARCHAR AS "ACMS_SectionCode",
            NULL::VARCHAR AS "AMSE_SEMCode",
            NULL::BIGINT AS "HRMRM_Id",
            NULL::BIGINT AS "HLMRCA_Id"
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
        WHERE a."HLHSALTC_ActiveFlag" = 1 
            AND a."MI_Id" = p_MI_Id 
            AND a."HLMH_Id" = p_HLMH_Id;
            
    ELSIF p_Type = 'ind' THEN
        RETURN QUERY
        SELECT DISTINCT
            "AMST"."AMCST_Id",
            COALESCE("AMST"."AMCST_FirstName", '') || ' ' || COALESCE("AMST"."AMCST_MiddleName", '') || ' ' || COALESCE("AMST"."AMCST_LastName", '') AS "studentName",
            "MC"."AMCO_Id",
            "MC"."AMCO_CourseName",
            "MC"."AMCO_CourseCode",
            "MB"."AMB_Id",
            "MB"."AMB_BranchName",
            "MB"."AMB_BranchCode",
            "AMST"."AMCST_AdmNo",
            "MS"."AMSE_Id",
            "Msec"."ACMS_Id",
            "AMST"."AMCST_RegistrationNo",
            "AMST"."AMCST_MobileNo",
            "AMST"."AMCST_emailId",
            "MS"."AMSE_SEMName",
            "HLC"."HLMRCA_RoomCategory",
            "HRR"."HRMRM_RoomNo",
            "HRR"."HRMRM_SharingFlg",
            "HRR"."HRMRM_ACFlg",
            "Msec"."ACMS_SectionName",
            "Msec"."ACMS_SectionCode",
            "MS"."AMSE_SEMCode",
            "HRR"."HRMRM_Id",
            "HLC"."HLMRCA_Id"
        FROM "CLG"."Adm_Master_College_Student" "AMST"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "AYS" ON "AYS"."AMCST_Id" = "AMST"."AMCST_Id" 
            AND "AYS"."ACYST_ActiveFlag" = 1 
            AND "AMST"."AMCST_SOL" = 'S' 
            AND "AMST"."AMCST_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "AYS"."AMCO_Id" = "MC"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "AYS"."AMB_Id" = "MB"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "MS" ON "AYS"."AMSE_Id" = "MS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "Msec" ON "AYS"."ACMS_Id" = "Msec"."ACMS_Id"
        INNER JOIN "HL_Hostel_Student_Allot_College" "HL" ON "AMST"."AMCST_Id" = "HL"."AMCST_Id" 
            AND "AYS"."ASMAY_Id" = "HL"."ASMAY_Id" 
            AND "AYS"."AMCO_Id" = "HL"."AMCO_Id" 
            AND "AYS"."AMB_Id" = "HL"."AMB_Id" 
            AND "AYS"."AMSE_Id" = "HL"."AMSE_Id" 
            AND "AYS"."ACMS_Id" = "HL"."ACMS_Id"
        INNER JOIN "HL_Master_Room_Category" "HLC" ON "HLC"."HLMRCA_Id" = "HL"."HLMRCA_Id"
        INNER JOIN "HL_Master_Room" "HRR" ON "HRR"."HRMRM_Id" = "HL"."HRMRM_Id" 
            AND "HRR"."HLMRCA_Id" = "HLC"."HLMRCA_Id"
        WHERE "AMST"."MI_Id" = p_MI_Id 
            AND "AYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "AMST"."AMCST_Id" = p_AMCST_Id;
    END IF;
    
    RETURN;
END;
$$;