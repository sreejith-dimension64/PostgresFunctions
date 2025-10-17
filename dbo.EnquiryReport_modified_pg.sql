CREATE OR REPLACE FUNCTION "dbo"."EnquiryReport_modified"(
    "year" VARCHAR(100),
    "RoleId" BIGINT,
    "RoleTypeId" BIGINT,
    "From_Date" TIMESTAMP,
    "To_Date" TIMESTAMP,
    "miid" BIGINT
)
RETURNS TABLE(
    "UserName" TEXT,
    "PASE_emailid" TEXT,
    "PASE_MobileNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "PASE_Date" TIMESTAMP,
    "PASE_EnquiryNo" TEXT,
    "PASE_FirstName" TEXT,
    "PASE_MiddleName" TEXT,
    "PASE_LastName" TEXT,
    "PASE_Address1" TEXT,
    "PASE_Address2" TEXT,
    "PASE_Address3" TEXT,
    "Id" TEXT,
    "PASE_EnquiryDetails" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "year" != '0' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."ApplicationUser"."UserName",
            "dbo"."Preadmission_School_Enquiry"."PASE_emailid",
            "dbo"."Preadmission_School_Enquiry"."PASE_MobileNo",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
            "dbo"."Preadmission_School_Enquiry"."PASE_Date",
            "dbo"."Preadmission_School_Enquiry"."PASE_EnquiryNo",
            "dbo"."Preadmission_School_Enquiry"."PASE_FirstName",
            "dbo"."Preadmission_School_Enquiry"."PASE_MiddleName",
            "dbo"."Preadmission_School_Enquiry"."PASE_LastName",
            "dbo"."Preadmission_School_Enquiry"."PASE_Address1",
            "dbo"."Preadmission_School_Enquiry"."PASE_Address2",
            "dbo"."Preadmission_School_Enquiry"."PASE_Address3",
            "dbo"."ApplicationUser"."Id",
            "dbo"."Preadmission_School_Enquiry"."PASE_EnquiryDetails"
        FROM "dbo"."Preadmission_School_Enquiry"
        LEFT OUTER JOIN "dbo"."ApplicationUser" 
            ON "dbo"."Preadmission_School_Enquiry"."Id" = "dbo"."ApplicationUser"."Id"
        LEFT OUTER JOIN "dbo"."Adm_School_M_Class" 
            ON "dbo"."Preadmission_School_Enquiry"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        WHERE "dbo"."Preadmission_School_Enquiry"."ASMAY_Id" = "year"::BIGINT 
            AND "dbo"."Preadmission_School_Enquiry"."MI_Id" = "miid";
    
    ELSIF "year" = '0' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."ApplicationUser"."UserName",
            "dbo"."Preadmission_School_Enquiry"."PASE_emailid",
            "dbo"."Preadmission_School_Enquiry"."PASE_MobileNo",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
            "dbo"."Preadmission_School_Enquiry"."PASE_Date",
            "dbo"."Preadmission_School_Enquiry"."PASE_EnquiryNo",
            "dbo"."Preadmission_School_Enquiry"."PASE_FirstName",
            "dbo"."Preadmission_School_Enquiry"."PASE_MiddleName",
            "dbo"."Preadmission_School_Enquiry"."PASE_LastName",
            "dbo"."Preadmission_School_Enquiry"."PASE_Address1",
            "dbo"."Preadmission_School_Enquiry"."PASE_Address2",
            "dbo"."Preadmission_School_Enquiry"."PASE_Address3",
            "dbo"."ApplicationUser"."Id",
            "dbo"."Preadmission_School_Enquiry"."PASE_EnquiryDetails"
        FROM "dbo"."Preadmission_School_Enquiry"
        LEFT OUTER JOIN "dbo"."ApplicationUser" 
            ON "dbo"."Preadmission_School_Enquiry"."Id" = "dbo"."ApplicationUser"."Id"
        LEFT OUTER JOIN "dbo"."Adm_School_M_Class" 
            ON "dbo"."Preadmission_School_Enquiry"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        WHERE "dbo"."Preadmission_School_Enquiry"."PASE_Date" BETWEEN "From_Date" 
            AND ("To_Date" + INTERVAL '1 day' - INTERVAL '1 second')
            AND "dbo"."Preadmission_School_Enquiry"."MI_Id" = "miid";
    
    END IF;

    RETURN;

END;
$$;