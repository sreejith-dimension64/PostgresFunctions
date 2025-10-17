CREATE OR REPLACE FUNCTION "dbo"."EnquiryReport"(
    "RoleId" bigint,
    "RoleTypeId" bigint,
    "@From_Date" timestamp,
    "@To_Date" timestamp
)
RETURNS TABLE(
    "UserName" varchar,
    "PASE_emailid" varchar,
    "PASE_MobileNo" varchar,
    "ASMCL_ClassName" varchar,
    "PASE_Date" timestamp,
    "PASE_EnquiryNo" varchar,
    "PASE_FirstName" varchar,
    "PASE_MiddleName" varchar,
    "PASE_LastName" varchar,
    "PASE_Address1" varchar,
    "PASE_Address2" varchar,
    "PASE_Address3" varchar,
    "Id" bigint,
    "PASE_EnquiryDetails" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "userId" bigint;
BEGIN

    RETURN QUERY
    SELECT 
        "ApplicationUser"."UserName",
        "Preadmission_School_Enquiry"."PASE_emailid",
        "Preadmission_School_Enquiry"."PASE_MobileNo",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Preadmission_School_Enquiry"."PASE_Date",
        "Preadmission_School_Enquiry"."PASE_EnquiryNo",
        "Preadmission_School_Enquiry"."PASE_FirstName",
        "Preadmission_School_Enquiry"."PASE_MiddleName",
        "Preadmission_School_Enquiry"."PASE_LastName",
        "Preadmission_School_Enquiry"."PASE_Address1",
        "Preadmission_School_Enquiry"."PASE_Address2",
        "Preadmission_School_Enquiry"."PASE_Address3",
        "ApplicationUser"."Id",
        "Preadmission_School_Enquiry"."PASE_EnquiryDetails"
    FROM 
        "dbo"."Preadmission_School_Enquiry"
        LEFT OUTER JOIN "dbo"."ApplicationUser" 
            ON "Preadmission_School_Enquiry"."Id" = "ApplicationUser"."Id"
        LEFT OUTER JOIN "dbo"."Adm_School_M_Class" 
            ON "Preadmission_School_Enquiry"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    WHERE 
        "Preadmission_School_Enquiry"."PASE_Date" >= "@From_Date"
        AND "Preadmission_School_Enquiry"."PASE_Date" <= "@To_Date";

    RETURN;

END;
$$;