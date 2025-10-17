CREATE OR REPLACE FUNCTION "dbo"."College_Countrywise_Student_Admission_Details" (
    p_mi_id TEXT, 
    p_asmay_id TEXT, 
    p_amco_id TEXT, 
    p_amb_id TEXT, 
    p_amse_id TEXT, 
    p_countryid TEXT, 
    p_flag TEXT
)
RETURNS TABLE (
    "regno" TEXT,
    "admno" TEXT,
    "amco_order" INTEGER,
    "amb_order" INTEGER,
    "amse_semorder" INTEGER,
    "amco_coursename" TEXT,
    "amb_branchname" TEXT,
    "amse_semname" TEXT,
    "joinedYear" TEXT,
    "studentname" TEXT,
    "address" TEXT,
    "IVRMMC_CountryName" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    
    /*************** Permanent Address *************/
    IF p_flag = '2' THEN
    
        /********************** Branch Not Selected **************************/
        IF p_amb_id = '0' THEN
        
            /************************** State Not Selected ****************************/ 
            IF p_countryid = '0' THEN
                v_sql := '
                SELECT "AMCST_RegistrationNo"::TEXT AS regno, "AMCST_AdmNo"::TEXT AS admno, "amco_order"::INTEGER, "amb_order"::INTEGER, "amse_semorder"::INTEGER, "amco_coursename"::TEXT, "amb_branchname"::TEXT, "amse_semname"::TEXT, 

                (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS "joinedYear", 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "studentname",

                (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                CASE WHEN "AMCST_PerArea" IS NULL  OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) AS "address",
                NULL::TEXT AS "IVRMMC_CountryName"

                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id" 
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ')  AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."ADM_MASTER_BRANCH" WHERE "MI_ID" = ' || p_mi_id || ' AND "AMB_ActiveFlag" = 1) AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1 
                ORDER BY "amco_order", "amb_order", "amse_semorder", "studentname"';
            
            /***************** State Selected *********************/
            ELSE
                v_sql := '
                SELECT "AMCST_RegistrationNo"::TEXT AS regno, "AMCST_AdmNo"::TEXT AS admno, "amco_order"::INTEGER, "amb_order"::INTEGER, "amse_semorder"::INTEGER, "amco_coursename"::TEXT, "amb_branchname"::TEXT, "amse_semname"::TEXT, 

                (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS "joinedYear", 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "studentname",

                (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                CASE WHEN "AMCST_PerArea" IS NULL  OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) AS "address",
                NULL::TEXT AS "IVRMMC_CountryName"

                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id" 
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ')  AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."ADM_MASTER_BRANCH" WHERE "MI_ID" = ' || p_mi_id || ' AND "AMB_ActiveFlag" = 1) AND  b."IVRMMC_Id" = ' || p_countryid || ' AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1 
                ORDER BY "amco_order", "amb_order", "amse_semorder", "studentname"';
            END IF;
        
        /************* When Branch Selected ********************/
        ELSE
        
            IF p_countryid = '0' THEN
                v_sql := '
                SELECT "AMCST_RegistrationNo"::TEXT AS regno, "AMCST_AdmNo"::TEXT AS admno, "amco_order"::INTEGER, "amb_order"::INTEGER, "amse_semorder"::INTEGER, "amco_coursename"::TEXT, "amb_branchname"::TEXT, "amse_semname"::TEXT, 

                (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS "joinedYear", 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "studentname",

                (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                CASE WHEN "AMCST_PerArea" IS NULL  OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) AS "address",
                "IVRMMC_CountryName"::TEXT

                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id" 
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ')  AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (' || p_amb_id || ')  AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1 
                ORDER BY "amco_order", "amb_order", "amse_semorder", "studentname"';
            
            ELSE
                v_sql := '
                SELECT "AMCST_RegistrationNo"::TEXT AS regno, "AMCST_AdmNo"::TEXT AS admno, "amco_order"::INTEGER, "amb_order"::INTEGER, "amse_semorder"::INTEGER, "amco_coursename"::TEXT, "amb_branchname"::TEXT, "amse_semname"::TEXT, 

                (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS "joinedYear", 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "studentname",

                (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                CASE WHEN "AMCST_PerArea" IS NULL  OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) AS "address",
                "IVRMMC_CountryName"::TEXT

                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id" 
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ')  AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (' || p_amb_id || ') AND  b."IVRMMC_Id" = ' || p_countryid || ' AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1 
                ORDER BY "amco_order", "amb_order", "amse_semorder", "studentname"';
            END IF;
        
        END IF;
    
    /*** Present address*** */
    ELSE
    
        IF p_amb_id = '0' THEN
        
            IF p_countryid = '0' THEN
                v_sql := '
                SELECT "AMCST_RegistrationNo"::TEXT AS regno, "AMCST_AdmNo"::TEXT AS admno, "amco_order"::INTEGER, "amb_order"::INTEGER, "amse_semorder"::INTEGER, "amco_coursename"::TEXT, "amb_branchname"::TEXT, "amse_semname"::TEXT, 

                (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS "joinedYear", 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "studentname",

                (CASE WHEN "AMCST_ConStreet" IS NULL OR "AMCST_ConStreet" = '''' THEN '''' ELSE "AMCST_ConStreet" || '','' END ||
                CASE WHEN "AMCST_ConArea" IS NULL  OR "AMCST_ConArea" = '''' THEN '''' ELSE "AMCST_ConArea" || '','' END ||
                CASE WHEN "AMCST_ConCity" IS NULL OR "AMCST_ConCity" = '''' THEN '''' ELSE "AMCST_ConCity" || '','' END ||
                CASE WHEN "AMCST_ConAdd3" IS NULL OR "AMCST_ConAdd3" = '''' THEN ''''  ELSE "AMCST_ConAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) AS "address",
                "IVRMMC_CountryName"::TEXT

                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."AMCST_ConCountryId" 
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_ConState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ')  AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."ADM_MASTER_BRANCH" WHERE "MI_ID" = ' || p_mi_id || ' AND "AMB_ActiveFlag" = 1) AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1 
                ORDER BY "amco_order", "amb_order", "amse_semorder", "studentname"';
            
            ELSE
                v_sql := '
                SELECT "AMCST_RegistrationNo"::TEXT AS regno, "AMCST_AdmNo"::TEXT AS admno, "amco_order"::INTEGER, "amb_order"::INTEGER, "amse_semorder"::INTEGER, "amco_coursename"::TEXT, "amb_branchname"::TEXT, "amse_semname"::TEXT, 

                (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS "joinedYear", 
                (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END || 
                CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS "studentname",

                (CASE WHEN "AMCST_ConStreet" IS NULL OR "AMCST_ConStreet" = '''' THEN '''' ELSE "AMCST_ConStreet" || '','' END ||
                CASE WHEN "AMCST_ConArea" IS NULL  OR "AMCST_ConArea" = '''' THEN '''' ELSE "AMCST_ConArea" || '','' END ||
                CASE WHEN "AMCST_ConCity" IS NULL OR "AMCST_ConCity" = '''' THEN '''' ELSE "AMCST_ConCity" || '','' END ||
                CASE WHEN "AMCST_ConAdd3" IS NULL OR "AMCST_ConAdd3" = '''' THEN ''''  ELSE "AMCST_ConAdd3" || '','' END || 
                CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END || 
                CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || "AMCST_MobileNo"::TEXT END) AS "address",
                "IVRMMC_CountryName"::TEXT

                FROM "clg"."Adm_College_Yearly_Student" a 
                INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."AMCST_ConCountryId" 
                LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_ConState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ')  AND "AMCST_SOL" = ''S''
                AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."ADM_MASTER_BRANCH" WHERE "MI_ID" = ' || p_mi_id || ' AND "AMB_ActiveFlag" = 1) AND  "AMCST_ConCountryId" = ' || p_countryid || ' AND "AMCST_ActiveFlag" = 1 AND a."ACYST_ActiveFlag" = 1 
                ORDER BY "amco_order", "amb_order", "amse_semorder", "studentname"';
            END IF;
        
        ELSE
        
            IF p_countryid = '0' THEN
                v_sql := '
                SELECT "AMCST_RegistrationNo"::TEXT AS regno, "AMCST_AdmNo"::TEXT AS admno, "amco_order"::INTEGER, "amb_order"::INTEGER, "amse_semorder"::INTEGER, "amco_coursename"::TEXT, "amb_branchname"::TEXT, "amse_semname"::