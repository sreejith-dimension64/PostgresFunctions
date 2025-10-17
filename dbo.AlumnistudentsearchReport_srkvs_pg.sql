CREATE OR REPLACE FUNCTION "dbo"."AlumnistudentsearchReport_srkvs"(
    "p_MI_Id" VARCHAR,
    "p_year" VARCHAR,
    "p_clas" VARCHAR,
    "p_Occupation" VARCHAR,
    "p_city" VARCHAR,
    "p_IVRMMC_Id" VARCHAR,
    "p_IVRMMS_Id" VARCHAR,
    "p_district" VARCHAR
)
RETURNS TABLE(
    "almst_id" BIGINT,
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
    "ASMAY_Year" TEXT,
    "ALMST_MembershipId" TEXT,
    "ALMMC_MembershipCategory" TEXT,
    "ALMST_AdmNo" TEXT,
    "LeftClass" TEXT,
    "ALMST_District" TEXT,
    "ASMAY_Id_Join" TEXT,
    "ASMAY_Id_Left" TEXT,
    "ASMAY_Id_NEW_Left" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql" TEXT;
    "v_ASMAY_Id_Left" TEXT;
    "v_ASMCL_Id_Left" TEXT;
    "v_IVRMMC_Id1" TEXT;
    "v_ALMST_ConState" TEXT;
    "v_ALMST_Occupation" TEXT;
    "v_ALMST_City" TEXT;
    "v_ALMST_Class" TEXT;
    "v_ALMST_District" TEXT;
    "v_ASMAY_Id" TEXT;
BEGIN

    IF "p_IVRMMC_Id" != '' THEN
        "v_IVRMMC_Id1" := 'AND a."IVRMMC_Id" IN (' || "p_IVRMMC_Id" || ') ';
    ELSE
        "v_IVRMMC_Id1" := '';
    END IF;

    IF "p_IVRMMS_Id" != '' THEN
        "v_ALMST_ConState" := 'AND a."ALMST_ConState" IN (' || "p_IVRMMS_Id" || ') ';
    ELSE
        "v_ALMST_ConState" := '';
    END IF;

    IF "p_Occupation" != '' THEN
        "v_ALMST_Occupation" := 'AND SP."ALSPR_Designation" ILIKE ''%' || "p_Occupation" || '%''';
    ELSE
        "v_ALMST_Occupation" := '';
    END IF;

    IF "p_city" != '' THEN
        "v_ALMST_City" := 'AND a."ALMST_ConCity" ILIKE ''%' || "p_city" || '%''';
    ELSE
        "v_ALMST_City" := '';
    END IF;

    IF "p_clas" != '' THEN
        "v_ALMST_Class" := 'AND a."ASMCL_Id_Left" IN (' || "p_clas" || ')';
    ELSE
        "v_ALMST_Class" := '';
    END IF;

    IF "p_district" != '' AND "p_district" != '0' THEN
        "v_ALMST_District" := 'AND a."ALMST_ConDistrict" IN (' || "p_district" || ')';
    ELSE
        "v_ALMST_District" := '';
    END IF;

    IF "p_year" != '' THEN
        "v_ASMAY_Id" := 'AND a."ASMAY_Id_Left" IN (' || "p_year" || ')';
    ELSE
        "v_ASMAY_Id" := '';
    END IF;

    "v_sql" := 'SELECT DISTINCT a."almst_id", 
        CASE WHEN a."ALMST_FirstName" IS NULL OR a."ALMST_FirstName" = '''' THEN '''' ELSE a."ALMST_FirstName" END ||
        CASE WHEN a."ALMST_MiddleName" IS NULL OR a."ALMST_MiddleName" = '''' OR a."ALMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || a."ALMST_MiddleName" END ||
        CASE WHEN a."ALMST_LastName" IS NULL OR a."ALMST_LastName" = '''' OR a."ALMST_LastName" = ''0'' THEN '''' ELSE '' '' || a."ALMST_LastName" END AS "amsT_FirstName",
        a."ALMST_DOB" AS "amsT_DOB",
        CASE WHEN SP."ALSPR_Designation" IS NULL THEN '''' ELSE SP."ALSPR_Designation" END AS "ALSPR_Designation",
        CASE WHEN a."ALMST_emailId" IS NULL THEN '''' ELSE a."ALMST_emailId" END AS "amsT_emailId",
        CASE WHEN a."ALMST_MobileNo" IS NULL THEN '''' ELSE a."ALMST_MobileNo" END AS "amsT_MobileNo",
        CASE WHEN a."ALMST_BloodGroup" IS NULL THEN '''' ELSE a."ALMST_BloodGroup" END AS "amsT_BloodGroup",
        CASE WHEN a."ALMST_ConCity" IS NULL THEN '''' ELSE a."ALMST_ConCity" END || '':'' || CASE WHEN st."IVRMMS_Name" IS NULL THEN '''' ELSE st."IVRMMS_Name" END AS "city",
        a."ALMST_FatherName", a."ALMST_ConCity", a."ALMST_ConStreet", a."ALMST_ConPincode", a."ALMST_ConArea", st."IVRMMS_Name", co."IVRMMC_CountryName",
        CASE WHEN a."ALMST_FullAddess" IS NULL THEN '''' ELSE a."ALMST_FullAddess" END AS "ALMST_FullAddess",
        e."ASMAY_Year", a."ALMST_MembershipId", ca."ALMMC_MembershipCategory", a."ALMST_AdmNo", c."ASMCL_ClassName" AS "LeftClass", a."ALMST_District",
        (SELECT ay."ASMAY_Year" FROM "Adm_School_M_Academic_Year" ay WHERE ay."MI_Id" = ' || "p_MI_Id" || ' AND ay."ASMAY_Id" = a."ASMAY_Id_Join") AS "ASMAY_Id_Join",
        (SELECT ay."ASMAY_Year" FROM "Adm_School_M_Academic_Year" ay WHERE ay."MI_Id" = ' || "p_MI_Id" || ' AND ay."ASMAY_Id" = a."ASMAY_Id_Left") AS "ASMAY_Id_Left",
        (SELECT SUBSTRING(ay."ASMAY_Year", 1, POSITION(''-'' IN ay."ASMAY_Year") - 1) FROM "Adm_School_M_Academic_Year" ay WHERE ay."MI_Id" = ' || "p_MI_Id" || ' AND ay."ASMAY_Id" = a."ASMAY_Id_Join") || ''-'' ||
        (SELECT SUBSTRING(ay."ASMAY_Year", POSITION(''-'' IN ay."ASMAY_Year") + 1, LENGTH(ay."ASMAY_Year") - POSITION(''-'' IN ay."ASMAY_Year")) FROM "Adm_School_M_Academic_Year" ay WHERE ay."MI_Id" = ' || "p_MI_Id" || ' AND ay."ASMAY_Id" = a."ASMAY_Id_Left") AS "ASMAY_Id_NEW_Left"
        FROM "ALU"."Alumni_Master_Student" a
        INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id_Left" AND c."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id_Left"
        LEFT JOIN "IVRM_Master_Country" co ON a."ALMST_ConCountryId" = co."IVRMMC_Id"
        LEFT JOIN "IVRM_Master_State" st ON a."ALMST_ConState" = st."IVRMMS_Id"
        LEFT JOIN "ALU"."Alumni_Student_Profession" SP ON SP."ALMST_Id" = a."ALMST_Id" AND SP."MI_Id" = ' || "p_MI_Id" || '
        LEFT JOIN "ALU"."Alumni_Student_Qulaification" SQ ON SQ."ALMST_Id" = a."ALMST_Id" AND SQ."MI_Id" = ' || "p_MI_Id" || '
        LEFT JOIN "ALU"."Alumni_Student_Achivement" SA ON SA."ALMST_Id" = a."ALMST_Id" AND SA."MI_Id" = ' || "p_MI_Id" || '
        LEFT JOIN "ALU"."Alumni_Master_MembershipCategory" CA ON CA."ALMMC_Id" = a."ALMST_MembershipCategory"
        LEFT JOIN "IVRM_Master_District" MD ON MD."IVRMMD_Id" = a."ALMST_ConDistrict"
        LEFT JOIN "IVRM_Master_city" IMC ON IMC."IVRMMS_Id" = st."IVRMMS_Id"
        WHERE a."MI_Id" = ' || "p_MI_Id" || ' AND a."ALMST_ActiveFlag" = TRUE ' ||
        "v_ASMAY_Id" || ' ' ||
        "v_IVRMMC_Id1" || ' ' || "v_ALMST_ConState" || ' ' || "v_ALMST_District" || ' ' ||
        "v_ALMST_Class" || ' ' || "v_ALMST_Occupation" || ' ' || "v_ALMST_City";

    RETURN QUERY EXECUTE "v_sql";

END;
$$;