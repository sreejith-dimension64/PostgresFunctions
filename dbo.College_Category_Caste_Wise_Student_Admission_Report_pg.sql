CREATE OR REPLACE FUNCTION "College_Category_Caste_Wise_Student_Admission_Report"(
    p_mi_id TEXT, 
    p_asmay_id TEXT, 
    p_amco_id TEXT, 
    p_amb_id TEXT,
    p_amse_id TEXT, 
    p_imcc_id TEXT, 
    p_imc_id TEXT, 
    p_categorycasteflag TEXT, 
    p_addresstype TEXT
)
RETURNS TABLE(
    "regno" TEXT,
    "admno" TEXT,
    "amco_order" INTEGER,
    "amb_order" INTEGER,
    "amse_semorder" INTEGER,
    "amco_coursename" TEXT,
    "amb_branchname" TEXT,
    "amse_semname" TEXT,
    "caste" TEXT,
    "category" TEXT,
    "subcaste" TEXT,
    "joinedYear" TEXT,
    "studentname" TEXT,
    "address" TEXT,
    "father" TEXT,
    "dob" TEXT,
    "gender" TEXT,
    "mobileno" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
    v_branchid TEXT;
    v_categoryid TEXT;
BEGIN
    IF p_amb_id = '0' THEN
        v_branchid := ' and "amb_id" != 0 ';
    ELSE
        v_branchid := ' and "amb_id" = ' || p_amb_id || ' ';
    END IF;

    IF p_categorycasteflag = '1' THEN
        IF p_imcc_id = '0' THEN
            v_categoryid := '"IMCC_Id" != 0 ';
        ELSE
            v_categoryid := '"IMCC_Id" = ' || p_imcc_id || ' ';
        END IF;
    ELSE
        IF p_imc_id = '0' THEN
            v_categoryid := '"IMC_Id" != 0 ';
        ELSE
            v_categoryid := '"IMC_Id" = ' || p_imc_id || ' ';
        END IF;
    END IF;

    /********************************  Permanent ADDRESS **********************************/
    IF p_addresstype = '2' THEN
        /*******************************  Category Wise **********************************/
        IF p_categorycasteflag = '1' THEN
            v_query := 'SELECT "AMCST_RegistrationNo"::TEXT as regno, "AMCST_AdmNo"::TEXT as admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname", 
                "IMC_CasteName" as caste, "IMCC_CategoryName" as category, COALESCE("AMCST_StudentSubCaste", '''') as subcaste,
                (select a."ASMAY_Year" from "Adm_School_M_Academic_Year" a where a."ASMAY_Id" = b."ASMAY_Id") as joinedYear, 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) as studentname,
                (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                CASE WHEN "AMCST_PerArea" IS NULL OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN '''' ELSE "AMCST_PerAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN '''' ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN '''' ELSE "IVRMMC_CountryName" || '' '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = '''' THEN '''' ELSE ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) as address,
                (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN '''' ELSE "AMCST_FatherName" END ||
                CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) father,
                TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') dob, "AMCST_Sex"::TEXT gender, "AMCST_Mobileno"::TEXT mobileno
                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                INNER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = b."IMCC_Id"
                INNER JOIN "IVRM_Master_Caste" mc ON mc."IMC_Id" = b."IMC_Id" AND mc."IMCC_Id" = cc."IMCC_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID" = ' || p_mi_id || ' ' || v_branchid || ' AND "AMB_ActiveFlag" = 1)
                AND b."IMCC_Id" IN (SELECT "imcc_id" FROM "IVRM_Master_Caste_Category" WHERE ' || v_categoryid || ') AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1
                ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
        ELSE
            /************** Caste Wise *******************/
            v_query := 'SELECT "AMCST_RegistrationNo"::TEXT as regno, "AMCST_AdmNo"::TEXT as admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname", 
                "IMC_CasteName" as caste, "IMCC_CategoryName" as category, COALESCE("AMCST_StudentSubCaste", '''') as subcaste,
                (select a."ASMAY_Year" from "Adm_School_M_Academic_Year" a where a."ASMAY_Id" = b."ASMAY_Id") as joinedYear, 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) as studentname,
                (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                CASE WHEN "AMCST_PerArea" IS NULL OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN '''' ELSE "AMCST_PerAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN '''' ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN '''' ELSE "IVRMMC_CountryName" || '' '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = '''' THEN '''' ELSE ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) as address,
                (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN '''' ELSE "AMCST_FatherName" END ||
                CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) father,
                TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') dob, "AMCST_Sex"::TEXT gender, "AMCST_Mobileno"::TEXT mobileno
                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                INNER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = b."IMCC_Id"
                INNER JOIN "IVRM_Master_Caste" mc ON mc."IMC_Id" = b."IMC_Id" AND mc."IMCC_Id" = cc."IMCC_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID" = ' || p_mi_id || ' ' || v_branchid || ' AND "AMB_ActiveFlag" = 1)
                AND b."IMC_Id" IN (SELECT "imc_id" FROM "IVRM_Master_Caste" WHERE ' || v_categoryid || ' AND "Mi_id" = ' || p_mi_id || ') AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1
                ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
        END IF;
    /********************************  END Permanent ADDRESS **********************************/
    ELSE
        IF p_categorycasteflag = '1' THEN
            v_query := 'SELECT "AMCST_RegistrationNo"::TEXT as regno, "AMCST_AdmNo"::TEXT as admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname", 
                "IMC_CasteName" as caste, "IMCC_CategoryName" as category, COALESCE("AMCST_StudentSubCaste", '''') as subcaste,
                (select a."ASMAY_Year" from "Adm_School_M_Academic_Year" a where a."ASMAY_Id" = b."ASMAY_Id") as joinedYear, 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) as studentname,
                (CASE WHEN "AMCST_ConStreet" IS NULL OR "AMCST_ConStreet" = '''' THEN '''' ELSE "AMCST_ConStreet" || '','' END ||
                CASE WHEN "AMCST_ConArea" IS NULL OR "AMCST_ConArea" = '''' THEN '''' ELSE "AMCST_ConArea" || '','' END ||
                CASE WHEN "AMCST_ConCity" IS NULL OR "AMCST_ConCity" = '''' THEN '''' ELSE "AMCST_ConCity" || '','' END ||
                CASE WHEN "AMCST_ConAdd3" IS NULL OR "AMCST_ConAdd3" = '''' THEN '''' ELSE "AMCST_ConAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN '''' ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN '''' ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = '''' THEN '''' ELSE ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) as address,
                (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN '''' ELSE "AMCST_FatherName" END ||
                CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) father,
                TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') dob, "AMCST_Sex"::TEXT gender, "AMCST_Mobileno"::TEXT mobileno
                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                INNER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = b."IMCC_Id"
                INNER JOIN "IVRM_Master_Caste" mc ON mc."IMC_Id" = b."IMC_Id" AND mc."IMCC_Id" = cc."IMCC_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID" = ' || p_mi_id || ' ' || v_branchid || ' AND "AMB_ActiveFlag" = 1)
                AND b."IMCC_Id" IN (SELECT "imcc_id" FROM "IVRM_Master_Caste_Category" WHERE ' || v_categoryid || ') AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1
                ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
        ELSE
            /************** Caste Wise *******************/
            v_query := 'SELECT "AMCST_RegistrationNo"::TEXT as regno, "AMCST_AdmNo"::TEXT as admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname", 
                "IMC_CasteName" as caste, "IMCC_CategoryName" as category, COALESCE("AMCST_StudentSubCaste", '''') as subcaste,
                (select a."ASMAY_Year" from "Adm_School_M_Academic_Year" a where a."ASMAY_Id" = b."ASMAY_Id") as joinedYear, 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) as studentname,
                (CASE WHEN "AMCST_ConStreet" IS NULL OR "AMCST_ConStreet" = '''' THEN '''' ELSE "AMCST_ConStreet" || '','' END ||
                CASE WHEN "AMCST_ConArea" IS NULL OR "AMCST_ConArea" = '''' THEN '''' ELSE "AMCST_ConArea" || '','' END ||
                CASE WHEN "AMCST_ConCity" IS NULL OR "AMCST_ConCity" = '''' THEN '''' ELSE "AMCST_ConCity" || '','' END ||
                CASE WHEN "AMCST_ConAdd3" IS NULL OR "AMCST_ConAdd3" = '''' THEN '''' ELSE "AMCST_ConAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN '''' ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN '''' ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = '''' THEN '''' ELSE ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) as address,
                (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN '''' ELSE "AMCST_FatherName" END ||
                CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) father,
                TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') dob, "AMCST_Sex"::TEXT gender, "AMCST_Mobileno"::TEXT mobileno
                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                INNER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = b."IMCC_Id"
                INNER JOIN "IVRM_Master_Caste" mc ON mc."IMC_Id" = b."IMC_Id" AND mc."IMCC_Id" = cc."IMCC_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID" = ' || p_mi_id || ' ' || v_branchid || ' AND "AMB_ActiveFlag" = 1)
                AND b."IMC_Id" IN (SELECT "imc_id" FROM "IVRM_Master_Caste" WHERE ' || v_categoryid || ' AND "Mi_id" = ' || p_mi_id || ') AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1
                ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
        END IF;
    END IF;

    RETURN QUERY EXECUTE v_query;
END;
$$;