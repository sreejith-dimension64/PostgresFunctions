CREATE OR REPLACE FUNCTION "College_Religion_Urban_Rural_wise_Student_Admission_Details"(
    p_mi_id TEXT,
    p_asmay_id TEXT,
    p_amco_id TEXT,
    p_amb_id TEXT,
    p_amse_id TEXT,
    p_religionid TEXT,
    p_flag TEXT,
    p_ruralurban TEXT,
    p_flagreligionrural TEXT
)
RETURNS TABLE(
    regno VARCHAR,
    admno VARCHAR,
    amco_order INTEGER,
    amb_order INTEGER,
    amse_semorder INTEGER,
    amco_coursename VARCHAR,
    amb_branchname VARCHAR,
    amse_semname VARCHAR,
    religionurban12 VARCHAR,
    father TEXT,
    dob VARCHAR,
    gender VARCHAR,
    mobileno VARCHAR,
    joinedyear VARCHAR,
    studentname TEXT,
    address TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    
    IF p_flagreligionrural::INTEGER = 1 THEN
        
        IF p_flag::INTEGER = 2 THEN
            
            IF p_amb_id::INTEGER = 0 THEN
                
                IF p_religionid::INTEGER = 0 THEN
                    v_sql := '
                    SELECT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname",
                    "ivrmmr_name" AS religionurban12, (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN ''''  ELSE "AMCST_FatherName" END ||
                    CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                    CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) AS father,
                    TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') AS dob, "AMCST_Sex" AS gender, "AMCST_MobileNo" AS mobileno,
                    (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS joinedYear,
                    (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END ||
                    CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                    CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS studentname,
                    (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                    CASE WHEN "AMCST_PerArea" IS NULL OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                    CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                    CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END ||
                    CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                    CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END ||
                    CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || CAST("AMCST_MobileNo" AS TEXT) END) AS address
                    FROM "clg"."Adm_College_Yearly_Student" a 
                    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "Ivrm_master_religion" re ON re."ivrmmr_id" = b."ivrmmr_id"
                    LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                    LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                    WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                    AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID" = ' || p_mi_id || ' AND "AMB_ActiveFlag" = true) AND "AMCST_ActiveFlag" = true AND a."ACYST_ActiveFlag" = true
                    ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
                ELSE
                    v_sql := '
                    SELECT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname",
                    "ivrmmr_name" AS religionurban12, (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN ''''  ELSE "AMCST_FatherName" END ||
                    CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                    CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) AS father,
                    TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') AS dob, "AMCST_Sex" AS gender, "AMCST_MobileNo" AS mobileno,
                    (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS joinedYear,
                    (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END ||
                    CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                    CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS studentname,
                    (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                    CASE WHEN "AMCST_PerArea" IS NULL OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                    CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                    CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END ||
                    CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                    CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END ||
                    CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || CAST("AMCST_MobileNo" AS TEXT) END) AS address
                    FROM "clg"."Adm_College_Yearly_Student" a 
                    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "Ivrm_master_religion" re ON re."ivrmmr_id" = b."ivrmmr_id"
                    LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                    LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                    WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                    AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID" = ' || p_mi_id || ' AND "AMB_ActiveFlag" = true) AND b."ivrmmR_Id" = ' || p_religionid || ' AND "AMCST_ActiveFlag" = true AND a."ACYST_ActiveFlag" = true
                    ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
                END IF;
            ELSE
                IF p_religionid::INTEGER = 0 THEN
                    v_sql := '
                    SELECT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname",
                    "ivrmmr_name" AS religionurban12, (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN ''''  ELSE "AMCST_FatherName" END ||
                    CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                    CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) AS father,
                    TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') AS dob, "AMCST_Sex" AS gender, "AMCST_MobileNo" AS mobileno,
                    (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS joinedYear,
                    (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END ||
                    CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                    CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS studentname,
                    (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                    CASE WHEN "AMCST_PerArea" IS NULL OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                    CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                    CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END ||
                    CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                    CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END ||
                    CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || CAST("AMCST_MobileNo" AS TEXT) END) AS address
                    FROM "clg"."Adm_College_Yearly_Student" a 
                    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "Ivrm_master_religion" re ON re."ivrmmr_id" = b."ivrmmr_id"
                    LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                    LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                    WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                    AND a."AMB_ID" IN (' || p_amb_id || ') AND "AMCST_ActiveFlag" = true AND a."ACYST_ActiveFlag" = true
                    ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
                ELSE
                    v_sql := '
                    SELECT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname",
                    "ivrmmr_name" AS religionurban12, (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN ''''  ELSE "AMCST_FatherName" END ||
                    CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                    CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) AS father,
                    TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') AS dob, "AMCST_Sex" AS gender, "AMCST_MobileNo" AS mobileno,
                    (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS joinedYear,
                    (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END ||
                    CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                    CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS studentname,
                    (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '''' ELSE "AMCST_PerStreet" || '','' END ||
                    CASE WHEN "AMCST_PerArea" IS NULL OR "AMCST_PerArea" = '''' THEN '''' ELSE "AMCST_PerArea" || '','' END ||
                    CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '''' THEN '''' ELSE "AMCST_PerCity" || '','' END ||
                    CASE WHEN "AMCST_PerAdd3" IS NULL OR "AMCST_PerAdd3" = '''' THEN ''''  ELSE "AMCST_PerAdd3" || '','' END ||
                    CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                    CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END ||
                    CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || CAST("AMCST_MobileNo" AS TEXT) END) AS address
                    FROM "clg"."Adm_College_Yearly_Student" a 
                    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "Ivrm_master_religion" re ON re."ivrmmr_id" = b."ivrmmr_id"
                    LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."IVRMMC_Id"
                    LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_PerState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                    WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                    AND a."AMB_ID" IN (' || p_amb_id || ') AND b."ivrmmR_Id" = ' || p_religionid || ' AND "AMCST_ActiveFlag" = true AND a."ACYST_ActiveFlag" = true
                    ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
                END IF;
            END IF;
        ELSE
            IF p_amb_id::INTEGER = 0 THEN
                IF p_religionid::INTEGER = 0 THEN
                    v_sql := '
                    SELECT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname",
                    "ivrmmr_name" AS religionurban12, (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN ''''  ELSE "AMCST_FatherName" END ||
                    CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '''' THEN '''' ELSE '' '' || "AMCST_FatherSurname" END ||
                    CASE WHEN "AMCST_FatherOccupation" IS NULL OR "AMCST_FatherOccupation" = '''' THEN '''' ELSE ''  Occupation :  '' || "AMCST_FatherOccupation" END) AS father,
                    TO_CHAR("AMCST_DOB", ''DD/MM/YYYY'') AS dob, "AMCST_Sex" AS gender, "AMCST_MobileNo" AS mobileno,
                    (SELECT a."ASMAY_Year" FROM "Adm_School_M_Academic_Year" a WHERE a."ASMAY_Id" = b."ASMAY_Id") AS joinedYear,
                    (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN ''''  ELSE "AMCST_FirstName" END ||
                    CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN ''''  ELSE  '' '' || "AMCST_MiddleName" END ||
                    CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS studentname,
                    (CASE WHEN "AMCST_ConStreet" IS NULL OR "AMCST_ConStreet" = '''' THEN '''' ELSE "AMCST_ConStreet" || '','' END ||
                    CASE WHEN "AMCST_ConArea" IS NULL OR "AMCST_ConArea" = '''' THEN '''' ELSE "AMCST_ConArea" || '','' END ||
                    CASE WHEN "AMCST_ConCity" IS NULL OR "AMCST_ConCity" = '''' THEN '''' ELSE "AMCST_ConCity" || '','' END ||
                    CASE WHEN "AMCST_ConAdd3" IS NULL OR "AMCST_ConAdd3" = '''' THEN ''''  ELSE "AMCST_ConAdd3" || '','' END ||
                    CASE WHEN "IVRMMS_Name" IS NULL OR "IVRMMS_Name" = '''' THEN  ''''  ELSE "IVRMMS_Name" || '','' END ||
                    CASE WHEN "IVRMMC_CountryName" IS NULL OR "IVRMMC_CountryName" = '''' THEN ''''  ELSE "IVRMMC_CountryName" || ''  '' END ||
                    CASE WHEN "AMCST_MobileNo" IS NULL OR "AMCST_MobileNo" = ''''  THEN '''' ELSE  ''Phone Number : '' || CAST("AMCST_MobileNo" AS TEXT) END) AS address
                    FROM "clg"."Adm_College_Yearly_Student" a 
                    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "Ivrm_master_religion" re ON re."ivrmmr_id" = b."ivrmmr_id"
                    LEFT JOIN "IVRM_Master_Country" g ON g."IVRMMC_Id" = b."AMCST_ConCountryId"
                    LEFT JOIN "IVRM_Master_State" h ON h."IVRMMS_Id" = b."AMCST_ConState" AND g."IVRMMC_Id" = h."IVRMMC_Id"
                    WHERE b."MI_Id" = ' || p_mi_id || ' AND b."AMCO_Id" IN (' || p_amco_id || ') AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."AMSE_ID" IN (' || p_amse_id || ') AND "AMCST_SOL" = ''S''
                    AND a."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID" = ' || p_mi_id || ' AND "AMB_ActiveFlag" = true) AND "AMCST_ActiveFlag" = true AND a."ACYST_ActiveFlag" = true
                    ORDER BY "amco_order", "amb_order", "amse_semorder", studentname';
                ELSE
                    v_sql := '
                    SELECT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, "amco_order", "amb_order", "amse_semorder", "amco_coursename", "amb_branchname", "amse_semname",
                    "ivrmmr_name" AS religionurban12, (CASE WHEN "AMCST_FatherName" IS NULL OR "AMCST_FatherName" = '''' THEN ''''  ELSE "AMCST_F