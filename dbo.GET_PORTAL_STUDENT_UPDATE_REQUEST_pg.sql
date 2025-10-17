CREATE OR REPLACE FUNCTION "dbo"."GET_PORTAL_STUDENT_UPDATE_REQUEST" (
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMST_Id" TEXT,
    "RoleName" VARCHAR(100)
)
RETURNS TABLE (
    "studentname" TEXT,
    "fatherName" TEXT,
    "mothername" TEXT,
    "AMST_BloodGroup" TEXT,
    "AMST_PerStreet" TEXT,
    "AMST_PerArea" TEXT,
    "AMST_PerCity" TEXT,
    "AMST_PerState" TEXT,
    "AMST_PerCountry" BIGINT,
    "AMST_PerPincode" TEXT,
    "AMST_ConStreet" TEXT,
    "AMST_ConArea" TEXT,
    "AMST_ConCity" TEXT,
    "AMST_ConState" TEXT,
    "AMST_ConCountry" BIGINT,
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
    "ASTUREQ_Id" BIGINT,
    "ASTUREQ_Date" TIMESTAMP,
    "AMSTG_GuardianName" TEXT,
    "AMST_AdmNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "ASTUREQ_ReqStatus" TEXT,
    "AMST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "countofamst" BIGINT;
BEGIN

    "countofamst" := 0;

    IF "RoleName" = 'Student' THEN
    
        SELECT COUNT(*) INTO "countofamst" 
        FROM "Adm_Student_Update_Request" 
        WHERE "AMST_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."AMST_Id"::BIGINT 
            AND "ASMAY_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."ASMAY_Id"::BIGINT 
            AND "ASTUREQ_ReqStatus" = 'PENDING';

        IF "countofamst" > 0 THEN
        
            RETURN QUERY
            SELECT   
                CASE WHEN COALESCE(A."ASTUREQ_FirstName", '') = '' THEN '' ELSE A."ASTUREQ_FirstName" END ||
                CASE WHEN COALESCE(A."ASTUREQ_MiddleName", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_MiddleName" END ||
                CASE WHEN COALESCE(A."ASTUREQ_LastName", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_LastName" END AS "studentname",
                
                CASE WHEN COALESCE(A."ASTUREQ_FatherName", '') = '' THEN '' ELSE A."ASTUREQ_FatherName" END ||
                CASE WHEN COALESCE(A."ASTUREQ_FatherSurname", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_FatherSurname" END AS "fatherName",
                
                CASE WHEN COALESCE(A."ASTUREQ_MotherName", '') = '' THEN '' ELSE A."ASTUREQ_MotherName" END ||
                CASE WHEN COALESCE(A."ASTUREQ_MotherSurname", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_MotherSurname" END AS "mothername",
                
                A."ASTUREQ_BloodGroup"::TEXT AS "AMST_BloodGroup",
                A."ASTUREQ_PerStreet"::TEXT AS "AMST_PerStreet",
                A."ASTUREQ_PerArea"::TEXT AS "AMST_PerArea",
                A."ASTUREQ_PerCity"::TEXT AS "AMST_PerCity",
                A."ASTUREQ_PerState"::TEXT AS "AMST_PerState",
                A."IVRMMC_Id" AS "AMST_PerCountry",
                A."ASTUREQ_PerPincode"::TEXT AS "AMST_PerPincode",
                A."ASTUREQ_ConStreet"::TEXT AS "AMST_ConStreet",
                A."ASTUREQ_ConArea"::TEXT AS "AMST_ConArea",
                A."ASTUREQ_ConCity"::TEXT AS "AMST_ConCity",
                A."ASTUREQ_ConState"::TEXT AS "AMST_ConState",
                A."ASTUREQ_ConCountryId" AS "AMST_ConCountry",
                A."ASTUREQ_ConPincode"::TEXT AS "AMST_ConPincode",
                A."ASTUREQ_EmailId"::TEXT AS "AMST_emailId",
                A."ASTUREQ_MobileNo"::TEXT AS "AMST_MobileNo",
                A."ASTUREQ_FatherMobleNo"::TEXT AS "AMST_FatherMobleNo",
                A."ASTUREQ_FatheremailId"::TEXT AS "AMST_FatheremailId",
                A."ASTUREQ_FatherPhoto"::TEXT AS "ANST_FatherPhoto",
                A."ASTUREQ_MotherMobleNo"::TEXT AS "AMST_MotherMobileNo",
                A."ASTUREQ_MotherEmailId"::TEXT AS "AMST_MotherEmailId",
                A."ASTUREQ_MotherPhoto"::TEXT AS "ANST_MotherPhoto",
                A."ASTUREQ_StudentPhoto"::TEXT AS "AMST_Photoname",
                A."ASTUREQ_AdmNo"::TEXT AS "admissionno",
                COALESCE(A."AMSTG_Id", 0) AS "AMSTG_Id",
                A."ASTUREQ_GuardianMobileNo"::TEXT AS "AMSTG_GuardianPhoneNo",
                A."ASTUREQ_GuardianEmailId"::TEXT AS "AMSTG_emailid",
                A."ASTUREQ_Id",
                A."ASTUREQ_Date",
                G."AMSTG_GuardianName"::TEXT,
                AMS."AMST_AdmNo"::TEXT,
                ASMC."ASMCL_ClassName"::TEXT,
                ASMS."ASMC_SectionName"::TEXT,
                A."ASTUREQ_ReqStatus"::TEXT,
                A."AMST_Id"
            FROM "dbo"."Adm_Student_Update_Request" A
            INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = ASYS."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ASMS ON ASMS."ASMS_Id" = ASYS."ASMS_Id"
            LEFT JOIN "Adm_Master_Student_Guardian" AS G ON G."AMST_Id" = A."AMST_Id"
            WHERE A."AMST_ID" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."AMST_Id"::BIGINT 
                AND A."ASMAY_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."ASMAY_Id"::BIGINT 
                AND A."MI_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."MI_Id"::BIGINT 
                AND ASYS."ASMAY_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."ASMAY_Id"::BIGINT 
                AND A."ASTUREQ_ReqStatus" = 'PENDING';
        
        ELSE
        
            RETURN QUERY
            SELECT 
                CASE WHEN COALESCE(A."AMST_FirstName", '') = '' THEN '' ELSE A."AMST_FirstName" END ||
                CASE WHEN COALESCE(A."AMST_MiddleName", '') IN ('', '0') THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
                CASE WHEN COALESCE(A."AMST_LastName", '') IN ('', '0') THEN '' ELSE ' ' || A."AMST_LastName" END AS "studentname",
                
                CASE WHEN COALESCE(A."AMST_FatherName", '') = '' THEN '' ELSE A."AMST_FatherName" END ||
                CASE WHEN COALESCE(A."AMST_FatherSurname", '') IN ('', '0') THEN '' ELSE ' ' || A."AMST_FatherSurname" END AS "fatherName",
                
                CASE WHEN COALESCE(A."AMST_MotherName", '') = '' THEN '' ELSE A."AMST_MotherName" END ||
                CASE WHEN COALESCE(A."AMST_MotherSurname", '') IN ('', '0') THEN '' ELSE ' ' || A."AMST_MotherSurname" END AS "mothername",
                
                A."AMST_BloodGroup"::TEXT,
                A."AMST_PerStreet"::TEXT,
                A."AMST_PerArea"::TEXT,
                A."AMST_PerCity"::TEXT,
                A."AMST_PerState"::TEXT,
                A."AMST_PerCountry",
                A."AMST_PerPincode"::TEXT,
                A."AMST_ConStreet"::TEXT,
                A."AMST_ConArea"::TEXT,
                A."AMST_ConCity"::TEXT,
                A."AMST_ConState"::TEXT,
                A."AMST_ConCountry",
                A."AMST_ConPincode"::TEXT,
                A."AMST_emailId"::TEXT,
                A."AMST_MobileNo"::TEXT,
                A."AMST_FatherMobleNo"::TEXT,
                A."AMST_FatheremailId"::TEXT,
                A."ANST_FatherPhoto"::TEXT,
                A."AMST_MotherMobileNo"::TEXT,
                A."AMST_MotherEmailId"::TEXT,
                A."ANST_MotherPhoto"::TEXT,
                A."AMST_Photoname"::TEXT,
                A."AMST_AdmNo"::TEXT AS "admissionno",
                COALESCE(G."AMSTG_Id", 0) AS "AMSTG_Id",
                G."AMSTG_GuardianPhoneNo"::TEXT,
                G."AMSTG_emailid"::TEXT,
                0::BIGINT AS "ASTUREQ_Id",
                NULL::TIMESTAMP AS "ASTUREQ_Date",
                G."AMSTG_GuardianName"::TEXT,
                A."AMST_AdmNo"::TEXT,
                ASMC."ASMCL_ClassName"::TEXT,
                ASMS."ASMC_SectionName"::TEXT,
                ''::TEXT AS "ASTUREQ_ReqStatus",
                A."AMST_Id"
            FROM "dbo"."Adm_M_Student" AS A 
            INNER JOIN "dbo"."Adm_School_Y_Student" AS B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = B."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ASMS ON ASMS."ASMS_Id" = B."ASMS_Id"
            LEFT JOIN "Adm_Master_Student_Guardian" AS G ON G."AMST_Id" = A."AMST_Id"
            WHERE A."MI_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."MI_Id"::BIGINT 
                AND B."AMST_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."AMST_Id"::BIGINT 
                AND B."ASMAY_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."ASMAY_Id"::BIGINT;
        
        END IF;

    ELSE
    
        RETURN QUERY
        SELECT DISTINCT
            CASE WHEN COALESCE(A."ASTUREQ_FirstName", '') = '' THEN '' ELSE A."ASTUREQ_FirstName" END ||
            CASE WHEN COALESCE(A."ASTUREQ_MiddleName", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_MiddleName" END ||
            CASE WHEN COALESCE(A."ASTUREQ_LastName", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_LastName" END AS "studentname",
            
            CASE WHEN COALESCE(A."ASTUREQ_FatherName", '') = '' THEN '' ELSE A."ASTUREQ_FatherName" END ||
            CASE WHEN COALESCE(A."ASTUREQ_FatherSurname", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_FatherSurname" END AS "fatherName",
            
            CASE WHEN COALESCE(A."ASTUREQ_MotherName", '') = '' THEN '' ELSE A."ASTUREQ_MotherName" END ||
            CASE WHEN COALESCE(A."ASTUREQ_MotherSurname", '') IN ('', '0') THEN '' ELSE ' ' || A."ASTUREQ_MotherSurname" END AS "mothername",
            
            A."ASTUREQ_BloodGroup"::TEXT AS "AMST_BloodGroup",
            A."ASTUREQ_PerStreet"::TEXT AS "AMST_PerStreet",
            A."ASTUREQ_PerArea"::TEXT AS "AMST_PerArea",
            A."ASTUREQ_PerCity"::TEXT AS "AMST_PerCity",
            A."ASTUREQ_PerState"::TEXT AS "AMST_PerState",
            A."IVRMMC_Id" AS "AMST_PerCountry",
            A."ASTUREQ_PerPincode"::TEXT AS "AMST_PerPincode",
            A."ASTUREQ_ConStreet"::TEXT AS "AMST_ConStreet",
            A."ASTUREQ_ConArea"::TEXT AS "AMST_ConArea",
            A."ASTUREQ_ConCity"::TEXT AS "AMST_ConCity",
            A."ASTUREQ_ConState"::TEXT AS "AMST_ConState",
            A."ASTUREQ_ConCountryId" AS "AMST_ConCountry",
            A."ASTUREQ_ConPincode"::TEXT AS "AMST_ConPincode",
            A."ASTUREQ_EmailId"::TEXT AS "AMST_emailId",
            A."ASTUREQ_MobileNo"::TEXT AS "AMST_MobileNo",
            A."ASTUREQ_FatherMobleNo"::TEXT AS "AMST_FatherMobleNo",
            A."ASTUREQ_FatheremailId"::TEXT AS "AMST_FatheremailId",
            A."ASTUREQ_FatherPhoto"::TEXT AS "ANST_FatherPhoto",
            A."ASTUREQ_MotherMobleNo"::TEXT AS "AMST_MotherMobileNo",
            A."ASTUREQ_MotherEmailId"::TEXT AS "AMST_MotherEmailId",
            A."ASTUREQ_MotherPhoto"::TEXT AS "ANST_MotherPhoto",
            A."ASTUREQ_StudentPhoto"::TEXT AS "AMST_Photoname",
            A."ASTUREQ_AdmNo"::TEXT AS "admissionno",
            COALESCE(A."AMSTG_Id", 0) AS "AMSTG_Id",
            A."ASTUREQ_GuardianMobileNo"::TEXT AS "AMSTG_GuardianPhoneNo",
            A."ASTUREQ_GuardianEmailId"::TEXT AS "AMSTG_emailid",
            A."ASTUREQ_Id",
            A."ASTUREQ_Date",
            G."AMSTG_GuardianName"::TEXT,
            AMS."AMST_AdmNo"::TEXT,
            ASMC."ASMCL_ClassName"::TEXT,
            ASMS."ASMC_SectionName"::TEXT,
            A."ASTUREQ_ReqStatus"::TEXT,
            A."AMST_Id"
        FROM "dbo"."Adm_Student_Update_Request" A
        INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id" = A."AMST_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" AS B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ASMS ON ASMS."ASMS_Id" = B."ASMS_Id"
        LEFT JOIN "Adm_Master_Student_Guardian" AS G ON G."AMST_Id" = A."AMST_Id"
        WHERE A."ASMAY_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."ASMAY_Id"::BIGINT 
            AND A."MI_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."MI_Id"::BIGINT 
            AND B."ASMAY_Id" = "GET_PORTAL_STUDENT_UPDATE_REQUEST"."ASMAY_Id"::BIGINT 
            AND A."ASTUREQ_ReqStatus" = 'PENDING';

    END IF;

    RETURN;

END;
$$;