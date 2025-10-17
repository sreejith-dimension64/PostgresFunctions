CREATE OR REPLACE FUNCTION "dbo"."AlumnistudentsearchReport_new"(
    "MI_Id" TEXT,
    "year" TEXT,
    "clas" TEXT,
    "Occupation" TEXT,
    "city" TEXT,
    "IVRMMC_Id" TEXT,
    "IVRMMS_Id" TEXT
)
RETURNS TABLE (
    "almst_id" INTEGER,
    "amsT_FirstName" TEXT,
    "amsT_DOB" TIMESTAMP,
    "ALSPR_Designation" TEXT,
    "amsT_emailId" TEXT,
    "amsT_MobileNo" TEXT,
    "amsT_BloodGroup" TEXT,
    "city" TEXT,
    "ALMST_FatherName" TEXT,
    "ALMST_ConCity" TEXT,
    "ALMST_ConStreet" TEXT,
    "ALMST_ConPincode" TEXT,
    "ALMST_ConArea" TEXT,
    "IVRMMS_Name" TEXT,
    "IVRMMC_CountryName" TEXT,
    "ALMST_FullAddess" TEXT,
    "ALMST_AdmNo" TEXT,
    "ASMAY_Year" TEXT,
    "ALMMC_MembershipCategory" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
    "ASMAY_Id_Left" TEXT;
    "ASMCL_Id_Left" TEXT;
    "IVRMMC_Id1" TEXT;
    "ALMST_ConState" TEXT;
BEGIN

    "sql" := 'SELECT DISTINCT a."almst_id",
        CASE WHEN a."ALMST_FirstName" IS NULL OR a."ALMST_FirstName" = '''' THEN '''' ELSE a."ALMST_FirstName" END ||
        CASE WHEN a."ALMST_MiddleName" IS NULL OR a."ALMST_MiddleName" = '''' OR a."ALMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || a."ALMST_MiddleName" END ||
        CASE WHEN a."ALMST_LastName" IS NULL OR a."ALMST_LastName" = '''' OR a."ALMST_LastName" = ''0'' THEN '''' ELSE '' '' || a."ALMST_LastName" END AS "amsT_FirstName",
        a."ALMST_DOB" AS "amsT_DOB",
        COALESCE(SP."ALSPR_Designation", '''') AS "ALSPR_Designation",
        COALESCE(a."ALMST_emailId", '''') AS "amsT_emailId",
        COALESCE(a."ALMST_MobileNo", '''') AS "amsT_MobileNo",
        COALESCE(a."ALMST_BloodGroup", '''') AS "amsT_BloodGroup",
        COALESCE(a."ALMST_ConCity", '''') || '':'' || COALESCE(st."IVRMMS_Name", '''') AS "city",
        a."ALMST_FatherName",
        a."ALMST_ConCity",
        a."ALMST_ConStreet",
        a."ALMST_ConPincode",
        a."ALMST_ConArea",
        st."IVRMMS_Name",
        co."IVRMMC_CountryName",
        COALESCE(a."ALMST_FullAddess", '''') AS "ALMST_FullAddess",
        a."ALMST_AdmNo",
        e."ASMAY_Year",
        ca."ALMMC_MembershipCategory"
    FROM "ALU"."Alumni_Master_Student" a
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id_Left"
    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id_Left"
    LEFT JOIN "IVRM_Master_Country" co ON a."ALMST_ConCountryId" = co."IVRMMC_Id"
    LEFT JOIN "IVRM_Master_State" st ON a."ALMST_ConState" = st."IVRMMS_Id"
    LEFT JOIN "ALU"."Alumni_Student_Profession" SP ON SP."ALMST_Id" = a."ALMST_Id"
    LEFT JOIN "ALU"."Alumni_Student_Qulaification" SQ ON SQ."ALMST_Id" = a."ALMST_Id"
    LEFT JOIN "ALU"."Alumni_Student_Achivement" SA ON SA."ALMST_Id" = a."ALMST_Id"
    LEFT JOIN "ALU"."Alumni_Master_MembershipCategory" CA ON CA."ALMMC_Id" = a."ALMST_MembershipCategory"
    WHERE a."MI_Id" = ' || "MI_Id" || ' 
        AND a."ASMAY_Id_Left" IN (' || "year" || ') 
        AND a."ASMCL_Id_Left" IN (' || "clas" || ') 
        AND a."IVRMMC_Id" IN (' || "IVRMMC_Id" || ') 
        AND a."ALMST_ConState" IN (' || "IVRMMS_Id" || ')';

    RETURN QUERY EXECUTE "sql";

END;
$$;