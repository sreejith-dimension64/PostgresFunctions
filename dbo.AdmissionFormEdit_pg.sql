CREATE OR REPLACE FUNCTION "dbo"."AdmissionFormEdit"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint
)
RETURNS TABLE(
    "amstdT_IdentificationMark" VARCHAR,
    "amstdT_AdmType" VARCHAR,
    "amstdT_DisabilityType" VARCHAR,
    "amstdT_HealthId" VARCHAR,
    "amstdT_PostOffice" VARCHAR,
    "amstdT_Panchayat" VARCHAR,
    "amstdT_Municipality" VARCHAR,
    "amstdT_Locality" VARCHAR,
    "amstdT_PoliceStation" VARCHAR,
    "amstdT_FatherSpecificOccupation" VARCHAR,
    "amstdT_MotherSpecificOccupation" VARCHAR,
    "amstdT_PrevSection" VARCHAR,
    "amstdT_PrevAttendance" VARCHAR,
    "amstdT_PrevResult" VARCHAR,
    "amstdT_PrevRollNo" VARCHAR,
    "amstG_Relation" VARCHAR,
    "amstgD_District" VARCHAR,
    "amstgD_Pincode" VARCHAR,
    "amstgD_Locality" VARCHAR,
    "amstgD_Qualification" VARCHAR,
    "amstgD_Panchayat" VARCHAR,
    "amstgD_PostOffice" VARCHAR,
    "amstgD_PoliceStation" VARCHAR,
    "amstgD_Municipality" VARCHAR,
    "AMSTACT_Scholarshipreceived" VARCHAR,
    "AMSTACT_HeightCms" VARCHAR,
    "AMSTACT_WeightKg" VARCHAR,
    "AMSTACT_Gifted" VARCHAR,
    "AMSTACT_Participated_ExtraActivity" VARCHAR,
    "AMSTACT_ElectiveClass1" VARCHAR,
    "AMSTACT_ElectiveClass2" VARCHAR,
    "AMSTACT_Participated_NCC_NSS" VARCHAR,
    "AMSTDT_BPLStatus" VARCHAR,
    "AMSTACT_ScholarshipName" VARCHAR,
    "AMSTACT_ScholarshipAmount" VARCHAR,
    "AMSTACT_AppearedLevel" VARCHAR,
    "AMSTACT_CompetitionName" VARCHAR,
    "AMSTACT_Partcptd_Nurturancecamp" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        "SD"."AMSTDT_IdentificationMark" AS "amstdT_IdentificationMark",
        "SD"."AMSTDT_AdmType" AS "amstdT_AdmType",
        "SD"."AMSTDT_DisabilityType" AS "amstdT_DisabilityType",
        "SD"."AMSTDT_HealthId" AS "amstdT_HealthId",
        "SD"."AMSTDT_PostOffice" AS "amstdT_PostOffice",
        "SD"."AMSTDT_Panchayat" AS "amstdT_Panchayat",
        "SD"."AMSTDT_Municipality" AS "amstdT_Municipality",
        "SD"."AMSTDT_Locality" AS "amstdT_Locality",
        "SD"."AMSTDT_PoliceStation" AS "amstdT_PoliceStation",
        "SD"."AMSTDT_FatherSpecificOccupation" AS "amstdT_FatherSpecificOccupation",
        "SD"."AMSTDT_MotherSpecificOccupation" AS "amstdT_MotherSpecificOccupation",
        "SD"."AMSTDT_PrevSection" AS "amstdT_PrevSection",
        "SD"."AMSTDT_PrevAttendance" AS "amstdT_PrevAttendance",
        "SD"."AMSTDT_PrevResult" AS "amstdT_PrevResult",
        "SD"."AMSTDT_PrevRollNo" AS "amstdT_PrevRollNo",
        "SG"."AMSTG_Relation" AS "amstG_Relation",
        "SGD"."AMSTGD_District" AS "amstgD_District",
        "SGD"."AMSTGD_Pincode" AS "amstgD_Pincode",
        "SGD"."AMSTGD_Locality" AS "amstgD_Locality",
        "SGD"."AMSTGD_Qualification" AS "amstgD_Qualification",
        "SGD"."AMSTGD_Panchayat" AS "amstgD_Panchayat",
        "SGD"."AMSTGD_PostOffice" AS "amstgD_PostOffice",
        "SGD"."AMSTGD_PoliceStation" AS "amstgD_PoliceStation",
        "SGD"."AMSTGD_Municipality" AS "amstgD_Municipality",
        "SA"."AMSTACT_Scholarshipreceived"::VARCHAR,
        "SA"."AMSTACT_HeightCms"::VARCHAR,
        "SA"."AMSTACT_WeightKg"::VARCHAR,
        "SA"."AMSTACT_Gifted"::VARCHAR,
        "SA"."AMSTACT_Participated_ExtraActivity"::VARCHAR,
        "SA"."AMSTACT_ElectiveClass1"::VARCHAR,
        "SA"."AMSTACT_ElectiveClass2"::VARCHAR,
        "SA"."AMSTACT_Participated_NCC_NSS"::VARCHAR,
        "SD"."AMSTDT_BPLStatus"::VARCHAR,
        "SA"."AMSTACT_ScholarshipName"::VARCHAR,
        "SA"."AMSTACT_ScholarshipAmount"::VARCHAR,
        "SA"."AMSTACT_AppearedLevel"::VARCHAR,
        "SA"."AMSTACT_CompetitionName"::VARCHAR,
        "SA"."AMSTACT_Partcptd_Nurturancecamp"::VARCHAR
    FROM "Adm_M_Student" "STD"
    LEFT JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "STD"."AMST_Id"
    LEFT JOIN "Adm_M_Student_Detail" "SD" ON "SD"."AMST_Id" = "STD"."AMST_Id"
    LEFT JOIN "Adm_Master_Student_Guardian" "SG" ON "SG"."AMST_Id" = "STD"."AMST_Id"
    LEFT JOIN "Adm_Master_Student_Guardian_Details" "SGD" ON "SGD"."AMSTG_Id" = "SG"."AMSTG_Id"
    LEFT JOIN "Adm_Master_Student_PrevSchool" "PrevS" ON "PrevS"."AMST_Id" = "STD"."AMST_Id"
    LEFT JOIN "Adm_M_Student_Activities" "SA" ON "SA"."AMST_Id" = "STD"."AMST_Id"
    WHERE "STD"."MI_Id" = p_MI_Id 
        AND "STD"."ASMAY_Id" = p_ASMAY_Id 
        AND "STD"."AMST_Id" = p_AMST_Id;
END;
$$;