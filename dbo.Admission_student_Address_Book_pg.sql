CREATE OR REPLACE FUNCTION "dbo"."Admission_student_Address_Book"(
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "flag" TEXT,
    "amst_id" TEXT,
    "all1" TEXT
)
RETURNS TABLE(
    "AMST_FirstName" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_Sex" TEXT,
    "AMST_DOB" TIMESTAMP,
    "AMST_BloodGroup" TEXT,
    "AMST_PerStreet" TEXT,
    "AMST_PerArea" TEXT,
    "AMST_PerCity" TEXT,
    "AMST_PerAdd3" TEXT,
    "AMST_PerPincode" INTEGER,
    "AMST_ConStreet" TEXT,
    "AMST_ConArea" TEXT,
    "AMST_ConCity" TEXT,
    "AMST_ConPincode" INTEGER,
    "AMST_emailId" TEXT,
    "AMST_FatherName" TEXT,
    "AMST_Id" BIGINT,
    "ASMCL_ClassName" TEXT,
    "AMST_MobileNo" TEXT,
    "ASMC_SectionName" TEXT,
    "AMST_SOL" TEXT,
    "AMST_Photoname" TEXT,
    "AMST_Date" TIMESTAMP,
    "AMST_MotherName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "name" TEXT;
    "AMST_RegistrationNo_var" TEXT;
    "admno" TEXT;
    "AMST_Sex_var" TEXT;
    "dob" TIMESTAMP;
    "AMST_BloodGroup_var" TEXT;
    "AMST_PerStreet_var" TEXT;
    "AMST_PerArea_var" TEXT;
    "AMST_PerCity_var" TEXT;
    "AMST_PerAdd3_var" TEXT;
    "AMST_PerState_var" TEXT;
    "AMST_PerCountry_var" TEXT;
    "AMST_PerPincode_var" INTEGER;
    "AMST_ConStreet_var" TEXT;
    "AMST_ConArea_var" TEXT;
    "AMST_ConCity_var" TEXT;
    "AMST_ConCountry_var" BIGINT;
    "AMST_ConPincode_var" INTEGER;
    "asmcL_ClassName_var" TEXT;
    "amst_activeflag" TEXT;
    "amay_activeflag" TEXT;
    "SQLQUERY" TEXT;
BEGIN
    IF "flag" = 'S' THEN
        "amst_activeflag" := '1';
        "amay_activeflag" := '1';
    ELSE
        "amst_activeflag" := '0';
        "amay_activeflag" := '0';
    END IF;

    IF "all1" = '1' THEN
        "SQLQUERY" := 'SELECT DISTINCT (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."Amst_MiddleName", '''') || '' '' || ' ||
                      'COALESCE("Adm_M_Student"."Amst_LastName", '''')) as "AMST_FirstName", "Adm_M_Student"."AMST_RegistrationNo", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_Sex", ' ||
                      '"Adm_M_Student"."AMST_DOB", "Adm_M_Student"."AMST_BloodGroup", "Adm_M_Student"."AMST_PerStreet", "Adm_M_Student"."AMST_PerArea", ' ||
                      '"Adm_M_Student"."AMST_PerCity", "Adm_M_Student"."AMST_PerAdd3", "Adm_M_Student"."AMST_PerPincode", "Adm_M_Student"."AMST_ConStreet", ' ||
                      '"Adm_M_Student"."AMST_ConArea", "Adm_M_Student"."AMST_ConCity", "Adm_M_Student"."AMST_ConPincode", "Adm_M_Student"."AMST_emailId", ' ||
                      '"Adm_M_Student"."AMST_FatherName", "Adm_M_Student"."AMST_Id", "Adm_School_M_Class"."ASMCL_ClassName", "Adm_M_Student"."AMST_MobileNo", "ASMC_SectionName", ' ||
                      '"Adm_M_Student"."AMST_SOL", "Adm_M_Student"."AMST_Photoname", "Adm_M_Student"."AMST_Date", "Adm_M_Student"."AMST_MotherName" ' ||
                      'FROM "dbo"."Adm_M_Student" ' ||
                      'INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" ' ||
                      'INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" ' ||
                      'INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ' ||
                      'INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" ' ||
                      'INNER JOIN "dbo"."Adm_School_M_Class" AS "Adm_School_M_Class_1" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_M_Class_1"."ASMCL_Id" ' ||
                      'WHERE ("Adm_School_Y_Student"."ASMCL_Id" = ' || "ASMCL_Id" || ') AND ("Adm_School_Y_Student"."AMST_Id" IN (' || "amst_id" || ')) ' ||
                      'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id" || ') ' ||
                      'AND ("Adm_M_Student"."AMST_SOL" = ''' || "flag" || ''' AND "AMST_ActiveFlag" = ' || "amst_activeflag" || ' AND "AMAY_ActiveFlag" = ' || "amay_activeflag" || ')';

        RETURN QUERY EXECUTE "SQLQUERY";
    ELSE
        RETURN QUERY
        SELECT DISTINCT (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || COALESCE("Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("Adm_M_Student"."Amst_LastName", '')) as "AMST_FirstName",
            "Adm_M_Student"."AMST_RegistrationNo", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_Sex",
            "Adm_M_Student"."AMST_DOB", "Adm_M_Student"."AMST_BloodGroup", "Adm_M_Student"."AMST_PerStreet", "Adm_M_Student"."AMST_PerArea",
            "Adm_M_Student"."AMST_PerCity", "Adm_M_Student"."AMST_PerAdd3", "Adm_M_Student"."AMST_PerPincode", "Adm_M_Student"."AMST_ConStreet",
            "Adm_M_Student"."AMST_ConArea", "Adm_M_Student"."AMST_ConCity", "Adm_M_Student"."AMST_ConPincode", "Adm_M_Student"."AMST_emailId",
            "Adm_M_Student"."AMST_FatherName", "Adm_M_Student"."AMST_Id", "Adm_School_M_Class"."ASMCL_ClassName", "Adm_M_Student"."AMST_MobileNo", "ASMC_SectionName",
            "Adm_M_Student"."AMST_SOL", "Adm_M_Student"."AMST_Photoname", "Adm_M_Student"."AMST_Date", "Adm_M_Student"."AMST_MotherName"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" AS "Adm_School_M_Class_1" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_M_Class_1"."ASMCL_Id"
        WHERE ("Adm_School_Y_Student"."ASMCL_Id" = "ASMCL_Id"::BIGINT) 
            AND ("Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id"::BIGINT) 
            AND ("Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::BIGINT)
            AND ("Adm_M_Student"."AMST_SOL" = "flag") 
            AND ("Adm_M_Student"."AMST_Id" = "amst_id"::BIGINT AND "AMST_ActiveFlag" = "amst_activeflag"::INTEGER AND "AMAY_ActiveFlag" = "amay_activeflag"::INTEGER);
    END IF;

    RETURN;
END;
$$;