CREATE OR REPLACE FUNCTION "dbo"."GET_PORTAL_STUDENTDASHBOARD_UPDATE" (
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMST_Id" TEXT,
    "NoofDays" BIGINT
)
RETURNS TABLE (
    "ASTUREQ_Id" BIGINT,
    "studentname" TEXT,
    "fatherName" TEXT,
    "mothername" TEXT,
    "AMST_BloodGroup" TEXT,
    "AMST_PerStreet" TEXT,
    "AMST_PerArea" TEXT,
    "AMST_PerCity" TEXT,
    "AMST_PerState" TEXT,
    "AMST_PerCountry" TEXT,
    "AMST_PerPincode" TEXT,
    "AMST_ConStreet" TEXT,
    "AMST_ConArea" TEXT,
    "AMST_ConCity" TEXT,
    "AMST_ConState" TEXT,
    "AMST_ConCountry" TEXT,
    "AMST_ConPincode" TEXT,
    "AMST_emailId" TEXT,
    "AMST_MobileNo" TEXT,
    "AMST_FatherMobleNo" TEXT,
    "AMST_FatheremailId" TEXT,
    "ANST_FatherPhoto" TEXT,
    "AMST_MotherMobileNo" TEXT,
    "AMST_MotherEmailId" TEXT,
    "ANST_MotherPhoto" TEXT,
    "AMST_Photoname" TEXT,
    "admissionno" TEXT,
    "AMSTG_Id" BIGINT,
    "AMSTG_GuardianPhoneNo" TEXT,
    "AMSTG_emailid" TEXT,
    "AMSTG_GuardianName" TEXT,
    "ASTUREQ_Date" TIMESTAMP,
    "IVRMMC_Id" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "countofamst" BIGINT := 0;
BEGIN

    SELECT COUNT(*) INTO "countofamst"
    FROM "Adm_Student_Update_Request"
    WHERE "AMST_Id" = "AMST_Id"
    AND "ASMAY_Id" = "ASMAY_Id"
    AND "ASTUREQ_ReqStatus" = 'PENDING';

    IF "countofamst" > 0 THEN
        RETURN QUERY
        SELECT   
            "A"."ASTUREQ_Id",
            CASE WHEN "A"."ASTUREQ_FirstName" IS NULL OR "A"."ASTUREQ_FirstName" = '' THEN '' ELSE "A"."ASTUREQ_FirstName" END ||
            CASE WHEN "A"."ASTUREQ_MiddleName" IS NULL OR "A"."ASTUREQ_MiddleName" = '' OR "A"."ASTUREQ_MiddleName" = '0' THEN '' ELSE ' ' || "A"."ASTUREQ_MiddleName" END ||
            CASE WHEN "A"."ASTUREQ_LastName" IS NULL OR "A"."ASTUREQ_LastName" = '' OR "A"."ASTUREQ_LastName" = '0' THEN '' ELSE ' ' || "A"."ASTUREQ_LastName" END AS "studentname",
            CASE WHEN "A"."ASTUREQ_FatherName" IS NULL OR "A"."ASTUREQ_FatherName" = '' THEN '' ELSE "A"."ASTUREQ_FatherName" END ||
            CASE WHEN "A"."ASTUREQ_FatherSurname" IS NULL OR "A"."ASTUREQ_FatherSurname" = '' OR "A"."ASTUREQ_FatherSurname" = '0' THEN '' ELSE ' ' || "A"."ASTUREQ_FatherSurname" END AS "fatherName",
            CASE WHEN "A"."ASTUREQ_MotherName" IS NULL OR "A"."ASTUREQ_MotherName" = '' THEN '' ELSE "A"."ASTUREQ_MotherName" END ||
            CASE WHEN "A"."ASTUREQ_MotherSurname" IS NULL OR "A"."ASTUREQ_MotherSurname" = '' OR "A"."ASTUREQ_MotherSurname" = '0' THEN '' ELSE ' ' || "A"."ASTUREQ_MotherSurname" END AS "mothername",
            "A"."ASTUREQ_BloodGroup"::TEXT AS "AMST_BloodGroup",
            "A"."ASTUREQ_PerStreet"::TEXT AS "AMST_PerStreet",
            "A"."ASTUREQ_PerArea"::TEXT AS "AMST_PerArea",
            "A"."ASTUREQ_PerCity"::TEXT AS "AMST_PerCity",
            "A"."ASTUREQ_PerState"::TEXT AS "AMST_PerState",
            "A"."IVRMMC_Id"::TEXT AS "AMST_PerCountry",
            "A"."ASTUREQ_PerPincode"::TEXT AS "AMST_PerPincode",
            "A"."ASTUREQ_ConStreet"::TEXT AS "AMST_ConStreet",
            "A"."ASTUREQ_ConArea"::TEXT AS "AMST_ConArea",
            "A"."ASTUREQ_ConCity"::TEXT AS "AMST_ConCity",
            "A"."ASTUREQ_ConState"::TEXT AS "AMST_ConState",
            "A"."ASTUREQ_ConCountryId"::TEXT AS "AMST_ConCountry",
            "A"."ASTUREQ_ConPincode"::TEXT AS "AMST_ConPincode",
            "A"."ASTUREQ_EmailId"::TEXT AS "AMST_emailId",
            "A"."ASTUREQ_MobileNo"::TEXT AS "AMST_MobileNo",
            "A"."ASTUREQ_FatherMobleNo"::TEXT AS "AMST_FatherMobleNo",
            "A"."ASTUREQ_FatheremailId"::TEXT AS "AMST_FatheremailId",
            "A"."ASTUREQ_FatherPhoto"::TEXT AS "ANST_FatherPhoto",
            "A"."ASTUREQ_MotherMobleNo"::TEXT AS "AMST_MotherMobileNo",
            "A"."ASTUREQ_MotherEmailId"::TEXT AS "AMST_MotherEmailId",
            "A"."ASTUREQ_MotherPhoto"::TEXT AS "ANST_MotherPhoto",
            "A"."ASTUREQ_StudentPhoto"::TEXT AS "AMST_Photoname",
            "A"."ASTUREQ_AdmNo"::TEXT AS "admissionno",
            COALESCE("A"."AMSTG_Id", 0) AS "AMSTG_Id",
            "A"."ASTUREQ_GuardianMobileNo"::TEXT AS "AMSTG_GuardianPhoneNo",
            "A"."ASTUREQ_GuardianEmailId"::TEXT AS "AMSTG_emailid",
            "G"."AMSTG_GuardianName"::TEXT AS "AMSTG_GuardianName",
            "A"."ASTUREQ_Date",
            NULL::TEXT AS "IVRMMC_Id"
        FROM "Adm_Student_Update_Request" "A"
        LEFT JOIN "Adm_Master_Student_Guardian" AS "G" ON "G"."AMST_Id" = "A"."AMST_Id"
        WHERE "A"."AMST_Id" = "GET_PORTAL_STUDENTDASHBOARD_UPDATE"."AMST_Id"
        AND "A"."ASMAY_Id" = "GET_PORTAL_STUDENTDASHBOARD_UPDATE"."ASMAY_Id"
        AND "A"."MI_Id" = "GET_PORTAL_STUDENTDASHBOARD_UPDATE"."MI_Id"
        AND "A"."ASTUREQ_ReqStatus" = 'PENDING';
    ELSE
        RETURN QUERY
        SELECT   
            0::BIGINT AS "ASTUREQ_Id",
            CASE WHEN "A"."AMST_FirstName" IS NULL OR "A"."AMST_FirstName" = '' THEN '' ELSE "A"."AMST_FirstName" END ||
            CASE WHEN "A"."AMST_MiddleName" IS NULL OR "A"."AMST_MiddleName" = '' OR "A"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "A"."AMST_MiddleName" END ||
            CASE WHEN "A"."AMST_LastName" IS NULL OR "A"."AMST_LastName" = '' OR "A"."AMST_LastName" = '0' THEN '' ELSE ' ' || "A"."AMST_LastName" END AS "studentname",
            CASE WHEN "A"."AMST_FatherName" IS NULL OR "A"."AMST_FatherName" = '' THEN '' ELSE "A"."AMST_FatherName" END ||
            CASE WHEN "A"."AMST_FatherSurname" IS NULL OR "A"."AMST_FatherSurname" = '' OR "A"."AMST_FatherSurname" = '0' THEN '' ELSE ' ' || "A"."AMST_FatherSurname" END AS "fatherName",
            CASE WHEN "A"."AMST_MotherName" IS NULL OR "A"."AMST_MotherName" = '' THEN '' ELSE "A"."AMST_MotherName" END ||
            CASE WHEN "A"."AMST_MotherSurname" IS NULL OR "A"."AMST_MotherSurname" = '' OR "A"."AMST_MotherSurname" = '0' THEN '' ELSE ' ' || "A"."AMST_MotherSurname" END AS "mothername",
            "A"."AMST_BloodGroup"::TEXT,
            "A"."AMST_PerStreet"::TEXT,
            "A"."AMST_PerArea"::TEXT,
            "A"."AMST_PerCity"::TEXT,
            "A"."AMST_PerState"::TEXT,
            "A"."AMST_PerCountry"::TEXT,
            "A"."AMST_PerPincode"::TEXT,
            "A"."AMST_ConStreet"::TEXT,
            "A"."AMST_ConArea"::TEXT,
            "A"."AMST_ConCity"::TEXT,
            "A"."AMST_ConState"::TEXT,
            "A"."AMST_ConCountry"::TEXT,
            "A"."AMST_ConPincode"::TEXT,
            "A"."AMST_emailId"::TEXT,
            "A"."AMST_MobileNo"::TEXT,
            "A"."AMST_FatherMobleNo"::TEXT,
            "A"."AMST_FatheremailId"::TEXT,
            "A"."ANST_FatherPhoto"::TEXT,
            "A"."AMST_MotherMobileNo"::TEXT,
            "A"."AMST_MotherEmailId"::TEXT,
            "A"."ANST_MotherPhoto"::TEXT,
            "A"."AMST_Photoname"::TEXT,
            "A"."AMST_AdmNo"::TEXT AS "admissionno",
            COALESCE("G"."AMSTG_Id", 0) AS "AMSTG_Id",
            "G"."AMSTG_GuardianPhoneNo"::TEXT,
            "G"."AMSTG_emailid"::TEXT,
            "G"."AMSTG_GuardianName"::TEXT,
            NULL::TIMESTAMP AS "ASTUREQ_Date",
            NULL::TEXT AS "IVRMMC_Id"
        FROM "Adm_M_Student" AS "A"
        INNER JOIN "Adm_School_Y_Student" AS "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        LEFT JOIN "Adm_Master_Student_Guardian" AS "G" ON "G"."AMST_Id" = "A"."AMST_Id"
        WHERE "A"."MI_Id" = "GET_PORTAL_STUDENTDASHBOARD_UPDATE"."MI_Id"
        AND "B"."AMST_Id" = "GET_PORTAL_STUDENTDASHBOARD_UPDATE"."AMST_Id"
        AND "B"."ASMAY_Id" = "GET_PORTAL_STUDENTDASHBOARD_UPDATE"."ASMAY_Id"
        AND (CURRENT_DATE - "A"."updatedDate"::DATE) >= "GET_PORTAL_STUDENTDASHBOARD_UPDATE"."NoofDays";
    END IF;

    RETURN;
END;
$$;