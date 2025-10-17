CREATE OR REPLACE FUNCTION "dbo"."BUSPASS_FORM_DETAILS_COLLAGE"(
    "@amst" VARCHAR,
    "@asta" VARCHAR,
    "@mi_id" VARCHAR,
    "@asmay_id" BIGINT
)
RETURNS TABLE (
    "AMCST_Id" BIGINT,
    "AMCST_AdmNo" VARCHAR,
    "AMCST_StudentPhoto" TEXT,
    "ASTACO_Landmark" TEXT,
    "ASTACO_Regnew" VARCHAR,
    "ASTACO_Phoneoff" VARCHAR,
    "ASTACO_PhoneRes" VARCHAR,
    "ASTACO_Id" BIGINT,
    "stuname" TEXT,
    "ASTACO_AreaZoneName" TEXT,
    "AMCST_PerStreet" TEXT,
    "AMCST_PerCity" TEXT,
    "AMCST_PerArea" TEXT,
    "AMCST_PerPincode" VARCHAR,
    "AMCST_BloodGroup" VARCHAR,
    "AMCST_FatherName" TEXT,
    "ASTACO_PickupSMSMobileNo" VARCHAR,
    "ASTACO_DropSMSMobileNo" VARCHAR,
    "AMCST_emailId" VARCHAR,
    "IVRMMC_Id" BIGINT,
    "IVRMMC_CountryName" VARCHAR,
    "IVRMMS_Id" BIGINT,
    "IVRMMS_Name" VARCHAR,
    "fuyear" VARCHAR,
    "cuyear" VARCHAR,
    "appno" VARCHAR,
    "PickUp_Route" TEXT,
    "PickUp_Route_no" VARCHAR,
    "PickUp_Location" TEXT,
    "DropUp_Location" TEXT,
    "Drop_Route" TEXT,
    "Drop_Route_no" VARCHAR,
    "ASTACO_ApplicationDate" TIMESTAMP,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMCST_FatherPhoto" TEXT,
    "AMCST_MotherPhoto" TEXT,
    "CurrentSem" VARCHAR,
    "FutureSem" VARCHAR,
    "MI_Name" VARCHAR,
    "IVRMMCT_Name" VARCHAR,
    "MI_Pincode" VARCHAR,
    "MI_Address1" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMCST_Id",
        b."AMCST_AdmNo",
        b."AMCST_StudentPhoto",
        a."ASTACO_Landmark",
        a."ASTACO_Regnew",
        a."ASTACO_Phoneoff",
        a."ASTACO_PhoneRes",
        a."ASTACO_Id",
        (COALESCE(b."AMCST_FirstName",' ') || ' ' || COALESCE(b."AMCST_MiddleName",' ') || ' ' || COALESCE(b."AMCST_LastName",' ')) as "stuname",
        a."ASTACO_AreaZoneName",
        b."AMCST_PerStreet",
        b."AMCST_PerCity",
        b."AMCST_PerArea",
        b."AMCST_PerPincode",
        b."AMCST_BloodGroup",
        b."AMCST_FatherName",
        a."ASTACO_PickupSMSMobileNo",
        a."ASTACO_DropSMSMobileNo",
        b."AMCST_emailId",
        c."IVRMMC_Id",
        c."IVRMMC_CountryName",
        d."IVRMMS_Id",
        d."IVRMMS_Name",
        fyear."ASMAY_Year" as "fuyear",
        cyear."ASMAY_Year" as "cuyear",
        a."ASTACO_ApplicationNo" as "appno",
        (CASE WHEN a."ASTACO_PickUp_TRMR_Id" != 0 THEN (SELECT DISTINCT "TRMR_RouteName" FROM "trn"."tr_master_route" WHERE "mi_id" = "@mi_id"::BIGINT AND "trmr_id" = a."ASTACO_PickUp_TRMR_Id") ELSE '--' END) AS "PickUp_Route",
        (CASE WHEN a."ASTACO_PickUp_TRMR_Id" != 0 THEN (SELECT DISTINCT "TRMR_RouteNo" FROM "trn"."tr_master_route" WHERE "mi_id" = "@mi_id"::BIGINT AND "trmr_id" = a."ASTACO_PickUp_TRMR_Id") ELSE '--' END) AS "PickUp_Route_no",
        (CASE WHEN a."ASTACO_PickUp_TRML_Id" != 0 THEN (SELECT DISTINCT "TRML_LocationName" FROM "trn"."TR_Master_Location" WHERE "mi_id" = "@mi_id"::BIGINT AND "TRML_Id" = a."ASTACO_PickUp_TRML_Id") ELSE '--' END) AS "PickUp_Location",
        (CASE WHEN a."ASTACO_Drop_TRML_Id" != 0 THEN (SELECT DISTINCT "TRML_LocationName" FROM "trn"."TR_Master_Location" WHERE "mi_id" = "@mi_id"::BIGINT AND "TRML_Id" = a."ASTACO_Drop_TRML_Id") ELSE '--' END) AS "DropUp_Location",
        (CASE WHEN a."ASTACO_Drop_TRMR_Id" != 0 THEN (SELECT DISTINCT "TRMR_RouteName" FROM "trn"."tr_master_route" WHERE "mi_id" = "@mi_id"::BIGINT AND "trmr_id" = a."ASTACO_Drop_TRMR_Id") ELSE '--' END) AS "Drop_Route",
        (CASE WHEN a."ASTACO_Drop_TRMR_Id" != 0 THEN (SELECT DISTINCT "TRMR_RouteNo" FROM "trn"."tr_master_route" WHERE "mi_id" = "@mi_id"::BIGINT AND "trmr_id" = a."ASTACO_Drop_TRMR_Id") ELSE '--' END) AS "Drop_Route_no",
        a."ASTACO_ApplicationDate",
        "CRS"."AMCO_CourseName",
        "BR"."AMB_BranchName",
        b."AMCST_FatherPhoto",
        b."AMCST_MotherPhoto",
        (SELECT "AMSE_SEMName" FROM "clg"."Adm_Master_Semester" "S" WHERE "S"."AMSE_Id" = a."ASTACO_CurrentSemester" AND a."ASTACO_Id" = "@asta"::BIGINT) AS "CurrentSem",
        (SELECT "AMSE_SEMName" FROM "clg"."Adm_Master_Semester" "S" WHERE "S"."AMSE_Id" = a."ASTACO_ForSemester" AND a."ASTACO_Id" = "@asta"::BIGINT) AS "FutureSem",
        "QQ"."MI_Name",
        "QQ"."IVRMMCT_Name",
        "QQ"."MI_Pincode",
        "QQ"."MI_Address1"
    FROM "Adm_Student_Trans_Appl_College" a
    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" AND b."MI_Id" = a."MI_Id"
    INNER JOIN "clg"."Adm_College_Yearly_Student" ystudent ON ystudent."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "IVRM_Master_Country" c ON b."AMCST_ConCountryId" = c."IVRMMC_Id"
    INNER JOIN "IVRM_Master_State" d ON b."AMCST_PerState" = d."IVRMMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" cyear ON cyear."ASMAY_Id" = a."ASTACO_CurrentAY"
    INNER JOIN "Adm_School_M_Academic_Year" fyear ON fyear."ASMAY_Id" = a."ASTACO_ForAY"
    INNER JOIN "CLG"."Adm_Master_Course" "CRS" ON "CRS"."AMCO_Id" = a."ASTACO_CurrentCourse"
    INNER JOIN "CLG"."Adm_Master_Branch" "BR" ON "BR"."AMB_Id" = a."ASTACO_CurrentBranch"
    INNER JOIN "Master_Institution" "QQ" ON "QQ"."MI_Id" = a."MI_Id"
    WHERE a."MI_Id" = "@mi_id"::BIGINT 
        AND b."AMCST_ActiveFlag" = TRUE 
        AND b."AMCST_SOL" = 'S' 
        AND ystudent."AMCST_Id" = "@amst"::BIGINT 
        AND a."ASTACO_Id" = "@asta"::BIGINT;
END;
$$;