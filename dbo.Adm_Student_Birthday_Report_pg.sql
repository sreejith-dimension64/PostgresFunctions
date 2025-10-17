CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Birthday_Report"(
    "p_month" VARCHAR(10),
    "p_fromdate" VARCHAR(10),
    "p_todate" VARCHAR(10),
    "p_MI_Id" TEXT,
    "p_flag" VARCHAR(30),
    "p_all1" VARCHAR(30)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "AMST_FirstName" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "amst_dob" DATE,
    "stdaddress" TEXT,
    "AMST_PerPincode" INTEGER,
    "AMST_PerCountry" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_name" VARCHAR(100);
    "v_admno" VARCHAR(30);
    "v_class_name" VARCHAR(30);
    "v_section_name" VARCHAR(30);
    "v_dob" TIMESTAMP;
    "v_AMST_Activeflag" VARCHAR(10);
    "v_AMAY_Activefalg" VARCHAR(10);
    "v_ASMAY_Id" TEXT;
    "v_asmayid" TEXT;
BEGIN

    SELECT "ASMAY_Id" INTO "v_ASMAY_Id" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
        AND "MI_Id" = "p_MI_Id" 
        AND "Is_Active" = 1;

    IF "p_flag" = 'S' THEN
        "v_AMST_Activeflag" := '1';
        "v_AMAY_Activefalg" := '1';
    ELSE
        "v_AMST_Activeflag" := '0';
        "v_AMAY_Activefalg" := '0';
    END IF;

    SELECT "ASMAY_Id" INTO "v_asmayid" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "mi_id" = "p_MI_Id" 
        AND CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date";

    IF "p_flag" = 'S' THEN

        IF "p_all1" = '0' THEN

            RETURN QUERY
            SELECT 
                stud."AMST_Id",
                (COALESCE(stud."AMST_FirstName", '') || ' ' || COALESCE(stud."amst_middlename", '') || ' ' || COALESCE(stud."AMST_LastName", '')) AS "AMST_FirstName",
                cls."ASMCL_ClassName",
                sec."ASMC_SectionName",
                stud."AMST_AdmNo",
                stud."AMST_DOB"::DATE AS "amst_dob",
                (COALESCE(stud."AMST_PerStreet", '') || ',' || COALESCE(stud."AMST_PerArea", '') || ',' || COALESCE(stud."AMST_PerCity", '') || ',' || COALESCE(st."IVRMMS_Name", '') || ',' || COALESCE(con."IVRMMC_CountryName", '') || '-' || CAST(stud."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                stud."AMST_PerPincode",
                stud."AMST_PerCountry"
            FROM "dbo"."Adm_M_Student" stud 
            INNER JOIN "Adm_School_Y_Student" study ON stud."AMST_Id" = study."AMST_Id"
            INNER JOIN "Adm_School_M_Class" cls ON study."ASMCL_Id" = cls."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" sec ON study."ASMS_Id" = sec."ASMS_Id"
            LEFT JOIN "IVRM_Master_Country" con ON stud."AMST_PerCountry" = con."IVRMMC_Id"
            LEFT JOIN "IVRM_Master_State" st ON stud."AMST_PerState" = st."IVRMMS_Id"
            WHERE stud."MI_Id" = "p_MI_Id" 
                AND EXTRACT(MONTH FROM stud."AMST_DOB") = "p_month"::INTEGER
                AND study."ASMAY_Id" = "v_asmayid"
                AND study."ASMAY_Id" = "v_ASMAY_Id"
                AND stud."AMST_SOL" = "p_flag"
                AND stud."AMST_ActiveFlag"::VARCHAR = "v_AMST_Activeflag"
                AND study."AMAY_ActiveFlag"::VARCHAR = "v_AMAY_Activefalg"
            ORDER BY EXTRACT(YEAR FROM stud."AMST_DOB"), EXTRACT(MONTH FROM stud."AMST_DOB"), EXTRACT(DAY FROM stud."AMST_DOB");

        ELSE

            RETURN QUERY
            SELECT 
                stud."AMST_Id",
                (COALESCE(stud."AMST_FirstName", '') || ' ' || COALESCE(stud."amst_middlename", '') || ' ' || COALESCE(stud."AMST_LastName", '')) AS "AMST_FirstName",
                cls."ASMCL_ClassName",
                sec."ASMC_SectionName",
                stud."AMST_AdmNo",
                stud."AMST_DOB"::DATE AS "amst_dob",
                (COALESCE(stud."AMST_PerStreet", '') || ',' || COALESCE(stud."AMST_PerArea", '') || ',' || COALESCE(stud."AMST_PerCity", '') || ',' || COALESCE(st."IVRMMS_Name", '') || ',' || COALESCE(con."IVRMMC_CountryName", '') || '-' || CAST(stud."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                stud."AMST_PerPincode",
                stud."AMST_PerCountry"
            FROM "dbo"."Adm_M_Student" stud 
            INNER JOIN "Adm_School_Y_Student" study ON stud."AMST_Id" = study."AMST_Id"
            INNER JOIN "Adm_School_M_Class" cls ON study."ASMCL_Id" = cls."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" sec ON study."ASMS_Id" = sec."ASMS_Id"
            LEFT JOIN "IVRM_Master_Country" con ON stud."AMST_PerCountry" = con."IVRMMC_Id"
            LEFT JOIN "IVRM_Master_State" st ON stud."AMST_PerState" = st."IVRMMS_Id"
            WHERE stud."MI_Id" = "p_MI_Id" 
                AND stud."AMST_SOL" = "p_flag"
                AND study."ASMAY_Id" = "v_ASMAY_Id"
                AND stud."AMST_ActiveFlag"::VARCHAR = "v_AMST_Activeflag"
                AND study."AMAY_ActiveFlag"::VARCHAR = "v_AMAY_Activefalg"
                AND EXTRACT(DAY FROM stud."AMST_DOB") BETWEEN EXTRACT(DAY FROM "p_fromdate"::DATE) AND EXTRACT(DAY FROM "p_todate"::DATE)
                AND EXTRACT(MONTH FROM stud."AMST_DOB") BETWEEN EXTRACT(MONTH FROM "p_fromdate"::DATE) AND EXTRACT(MONTH FROM "p_todate"::DATE)
            ORDER BY EXTRACT(YEAR FROM stud."AMST_DOB"), EXTRACT(MONTH FROM stud."AMST_DOB"), EXTRACT(DAY FROM stud."AMST_DOB");

        END IF;

    ELSE

        IF "p_all1" = '0' THEN

            RETURN QUERY
            SELECT 
                stud."AMST_Id",
                (COALESCE(stud."AMST_FirstName", '') || ' ' || COALESCE(stud."amst_middlename", '') || ' ' || COALESCE(stud."AMST_LastName", '')) AS "AMST_FirstName",
                cls."ASMCL_ClassName",
                sec."ASMC_SectionName",
                stud."AMST_AdmNo",
                stud."AMST_DOB"::DATE AS "amst_dob",
                (COALESCE(stud."AMST_PerStreet", '') || ',' || COALESCE(stud."AMST_PerArea", '') || ',' || COALESCE(stud."AMST_PerCity", '') || ',' || COALESCE(st."IVRMMS_Name", '') || ',' || COALESCE(con."IVRMMC_CountryName", '') || '-' || CAST(stud."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                stud."AMST_PerPincode",
                stud."AMST_PerCountry"
            FROM "dbo"."Adm_M_Student" stud 
            INNER JOIN "Adm_School_Y_Student" study ON stud."AMST_Id" = study."AMST_Id"
            INNER JOIN "Adm_School_M_Class" cls ON study."ASMCL_Id" = cls."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" sec ON study."ASMS_Id" = sec."ASMS_Id"
            LEFT JOIN "IVRM_Master_Country" con ON stud."AMST_PerCountry" = con."IVRMMC_Id"
            LEFT JOIN "IVRM_Master_State" st ON stud."AMST_PerState" = st."IVRMMS_Id"
            WHERE stud."MI_Id" = "p_MI_Id" 
                AND EXTRACT(MONTH FROM stud."AMST_DOB") = "p_month"::INTEGER
                AND study."ASMAY_Id" = "v_ASMAY_Id"
                AND stud."AMST_SOL" = "p_flag"
                AND stud."AMST_ActiveFlag"::VARCHAR = "v_AMST_Activeflag"
                AND study."AMAY_ActiveFlag"::VARCHAR = "v_AMAY_Activefalg"
            ORDER BY EXTRACT(YEAR FROM stud."AMST_DOB"), EXTRACT(MONTH FROM stud."AMST_DOB"), EXTRACT(DAY FROM stud."AMST_DOB");

        ELSE

            RETURN QUERY
            SELECT 
                stud."AMST_Id",
                (COALESCE(stud."AMST_FirstName", '') || ' ' || COALESCE(stud."amst_middlename", '') || ' ' || COALESCE(stud."AMST_LastName", '')) AS "AMST_FirstName",
                cls."ASMCL_ClassName",
                sec."ASMC_SectionName",
                stud."AMST_AdmNo",
                stud."AMST_DOB"::DATE AS "amst_dob",
                (COALESCE(stud."AMST_PerStreet", '') || ',' || COALESCE(stud."AMST_PerArea", '') || ',' || COALESCE(stud."AMST_PerCity", '') || ',' || COALESCE(st."IVRMMS_Name", '') || ',' || COALESCE(con."IVRMMC_CountryName", '') || '-' || CAST(stud."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                stud."AMST_PerPincode",
                stud."AMST_PerCountry"
            FROM "dbo"."Adm_M_Student" stud 
            INNER JOIN "Adm_School_Y_Student" study ON stud."AMST_Id" = study."AMST_Id"
            INNER JOIN "Adm_School_M_Class" cls ON study."ASMCL_Id" = cls."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" sec ON study."ASMS_Id" = sec."ASMS_Id"
            LEFT JOIN "IVRM_Master_Country" con ON stud."AMST_PerCountry" = con."IVRMMC_Id"
            LEFT JOIN "IVRM_Master_State" st ON stud."AMST_PerState" = st."IVRMMS_Id"
            WHERE stud."MI_Id" = "p_MI_Id" 
                AND stud."AMST_SOL" = "p_flag"
                AND stud."AMST_ActiveFlag"::VARCHAR = "v_AMST_Activeflag"
                AND study."AMAY_ActiveFlag"::VARCHAR = "v_AMAY_Activefalg"
                AND EXTRACT(DAY FROM stud."AMST_DOB") BETWEEN EXTRACT(DAY FROM "p_fromdate"::DATE) AND EXTRACT(DAY FROM "p_todate"::DATE)
                AND EXTRACT(MONTH FROM stud."AMST_DOB") BETWEEN EXTRACT(MONTH FROM "p_fromdate"::DATE) AND EXTRACT(MONTH FROM "p_todate"::DATE)
            ORDER BY EXTRACT(YEAR FROM stud."AMST_DOB"), EXTRACT(MONTH FROM stud."AMST_DOB"), EXTRACT(DAY FROM stud."AMST_DOB");

        END IF;

    END IF;

END;
$$;