CREATE OR REPLACE FUNCTION "dbo"."Adm_student_Employee_SmartCard_Details" (
    "asmaY_Id" bigint,
    "asmcL_Id" bigint,
    "ASMS_Id" bigint,
    "flag" varchar(30),
    "mi_id" bigint
)
RETURNS TABLE (
    "AMST_FirstName" varchar,
    "AMST_RegistrationNo" varchar,
    "AMST_AdmNo" varchar,
    "AMST_Sex" varchar,
    "AMST_DOB" timestamp,
    "AMST_BloodGroup" varchar,
    "address" text,
    "AMST_PerAdd3" varchar,
    "AMST_PerPincode" integer,
    "AMST_ConStreet" varchar,
    "AMST_ConArea" varchar,
    "AMST_ConCity" varchar,
    "AMST_ConPincode" integer,
    "AMST_emailId" varchar,
    "AMST_FatherName" varchar,
    "AMST_Id" bigint,
    "ASMCL_ClassName" varchar,
    "AMST_MobileNo" varchar,
    "AMST_SOL" varchar,
    "AMST_Photoname" varchar,
    "AMST_Date" timestamp,
    "AMST_MotherName" varchar,
    "hrme_employeefirstname" varchar,
    "HRME_DOB" timestamp,
    "HRME_DOJ" timestamp,
    "ecode" varchar,
    "HRME_LocAdd4" varchar,
    "HRME_LocArea" varchar,
    "HRME_LocCity" varchar,
    "HRME_BloodGroup" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    "name" varchar(100);
    "AMST_RegistrationNo_var" varchar(30);
    "admno" varchar(30);
    "AMST_Sex_var" varchar(30);
    "dob" timestamp;
    "AMST_BloodGroup_var" varchar(30);
    "AMST_PerStreet" varchar(30);
    "AMST_PerArea" varchar(30);
    "AMST_PerCity" varchar(30);
    "AMST_PerAdd3_var" varchar(30);
    "AMST_PerState" bigint;
    "AMST_PerCountry" bigint;
    "AMST_PerPincode_var" integer;
    "AMST_ConStreet_var" varchar(30);
    "AMST_ConArea_var" varchar(30);
    "AMST_ConCity_var" varchar(30);
    "AMST_ConCountry" bigint;
    "AMST_ConPincode_var" integer;
    "asmcL_ClassName" varchar(30);
    "amst_activeflag" varchar(10);
    "amay_activeflag" varchar(10);
BEGIN
    IF "flag" = 'Std' THEN
        RETURN QUERY
        SELECT DISTINCT
            (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' ||        
            COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", ''))::varchar AS "AMST_FirstName",
            "dbo"."Adm_M_Student"."AMST_RegistrationNo",
            "dbo"."Adm_M_Student"."AMST_AdmNo",
            "dbo"."Adm_M_Student"."AMST_Sex",
            "dbo"."Adm_M_Student"."AMST_DOB",
            "dbo"."Adm_M_Student"."AMST_BloodGroup",
            (COALESCE("dbo"."Adm_M_Student"."AMST_PerStreet", '') || ',' || COALESCE("dbo"."Adm_M_Student"."AMST_PerArea", '') || ',' ||   
            COALESCE("dbo"."Adm_M_Student"."AMST_PerCity", ''))::text AS "address",
            "dbo"."Adm_M_Student"."AMST_PerAdd3",
            "dbo"."Adm_M_Student"."AMST_PerPincode",
            "dbo"."Adm_M_Student"."AMST_ConStreet",
            "dbo"."Adm_M_Student"."AMST_ConArea",
            "dbo"."Adm_M_Student"."AMST_ConCity",
            "dbo"."Adm_M_Student"."AMST_ConPincode",
            "dbo"."Adm_M_Student"."AMST_emailId",
            "dbo"."Adm_M_Student"."AMST_FatherName",
            "dbo"."Adm_M_Student"."AMST_Id",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
            "dbo"."Adm_M_Student"."AMST_MobileNo",
            "dbo"."Adm_M_Student"."AMST_SOL",
            "dbo"."Adm_M_Student"."AMST_Photoname",
            "dbo"."Adm_M_Student"."AMST_Date",
            "dbo"."Adm_M_Student"."AMST_MotherName",
            NULL::varchar,
            NULL::timestamp,
            NULL::timestamp,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" AS "Adm_School_M_Class_1" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "Adm_School_M_Class_1"."ASMCL_Id"
        WHERE ("dbo"."Adm_School_Y_Student"."ASMCL_Id" = "asmcL_Id")
            AND ("dbo"."Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id")
            AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = "asmaY_Id")
            AND ("dbo"."Adm_M_Student"."AMST_SOL" = 'S' AND "dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1 AND "dbo"."Adm_School_Y_Student"."AMAY_ActiveFlag" = 1);
    ELSE
        RETURN QUERY
        SELECT DISTINCT
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::timestamp,
            NULL::varchar,
            NULL::text,
            NULL::varchar,
            NULL::integer,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::integer,
            NULL::varchar,
            NULL::varchar,
            NULL::bigint,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::varchar,
            NULL::timestamp,
            NULL::varchar,
            (COALESCE("dbo"."HR_Master_Employee"."hrme_employeefirstname", '') || ' ' ||        
            COALESCE("dbo"."HR_Master_Employee"."hrme_employeemiddlename", '') || ' ' || COALESCE("dbo"."HR_Master_Employee"."hrme_employeelastname", ''))::varchar AS "hrme_employeefirstname",
            "dbo"."HR_Master_Employee"."HRME_DOB",
            "dbo"."HR_Master_Employee"."HRME_DOJ",
            "dbo"."HR_Master_Employee"."HRME_EmployeeCode",
            "dbo"."HR_Master_Employee"."HRME_LocAdd4",
            "dbo"."HR_Master_Employee"."HRME_LocArea",
            "dbo"."HR_Master_Employee"."HRME_LocCity",
            "dbo"."HR_Master_Employee"."HRME_BloodGroup"
        FROM "dbo"."HR_Master_Employee"
        WHERE "dbo"."HR_Master_Employee"."MI_Id" = "mi_id"
            AND "dbo"."HR_Master_Employee"."HRME_LeftFlag" = 0
            AND "dbo"."HR_Master_Employee"."HRME_ActiveFlag" = 1;
    END IF;
    
    RETURN;
END;
$$;