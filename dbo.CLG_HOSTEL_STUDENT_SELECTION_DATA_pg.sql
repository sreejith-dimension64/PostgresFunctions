CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_STUDENT_SELECTION_DATA"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCST_Id" BIGINT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "studentname" TEXT,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "HLMH_Name" VARCHAR,
    "HRMRM_RoomNo" VARCHAR,
    "AMCST_Sex" VARCHAR,
    "HLMRCA_Id" BIGINT,
    "HLHSALTC_AllotRemarks" TEXT,
    "HRMRM_Id" BIGINT,
    "HLMRCA_RoomCategory" VARCHAR,
    "HLHSALTC_AllotmentDate" DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HSA"."AMCST_Id",
        COALESCE("AMS"."AMCST_FirstName", '') || ' ' || COALESCE("AMS"."AMCST_MiddleName", '') || ' ' || COALESCE("AMS"."AMCST_LastName", '') AS "studentname",
        "MC"."AMCO_CourseName",
        "MB"."AMB_BranchName",
        "AMSE"."AMSE_SEMName",
        "MS"."ACMS_SectionName",
        "MH"."HLMH_Name",
        "MR"."HRMRM_RoomNo",
        "AMS"."AMCST_Sex",
        "HSA"."HLMRCA_Id",
        "HSA"."HLHSALTC_AllotRemarks",
        "HSA"."HRMRM_Id",
        "MRC"."HLMRCA_RoomCategory",
        CAST("HSA"."HLHSALTC_AllotmentDate" AS DATE) AS "HLHSALTC_AllotmentDate"
    FROM "HL_Hostel_Student_Allot_College" "HSA"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "HSA"."AMCST_Id" 
        AND "YS"."ASMAY_Id" = "HSA"."ASMAY_Id" 
        AND "YS"."AMCO_Id" = "HSA"."AMCO_Id" 
        AND "YS"."AMSE_Id" = "HSA"."AMSE_Id" 
        AND "YS"."AMB_Id" = "HSA"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" "AMS" ON "YS"."AMCST_Id" = "AMS"."AMCST_Id" 
        AND "AMS"."AMCST_ActiveFlag" = 1 
        AND "AMS"."AMCST_SOL" = 'S' 
        AND "YS"."ACYST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
    INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
    INNER JOIN "HL_Master_Room_Category" "MRC" ON "HSA"."HLMRCA_Id" = "MRC"."HLMRCA_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "AY" ON "YS"."ASMAY_Id" = "AY"."ASMAY_Id"
    WHERE "HSA"."MI_Id" = "CLG_HOSTEL_STUDENT_SELECTION_DATA"."MI_Id" 
        AND "YS"."ASMAY_Id" = "CLG_HOSTEL_STUDENT_SELECTION_DATA"."ASMAY_Id" 
        AND "YS"."AMCST_Id" = "CLG_HOSTEL_STUDENT_SELECTION_DATA"."AMCST_Id" 
        AND "HSA"."HLHSALTC_VacateFlg" = 0;
    
    RETURN;
END;
$$;