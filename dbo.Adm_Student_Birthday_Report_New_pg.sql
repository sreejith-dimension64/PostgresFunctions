CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Birthday_Report_New"(
    "p_month" VARCHAR(10),
    "p_fromdate" VARCHAR(10),
    "p_todate" VARCHAR(10),
    "p_MI_Id" TEXT,
    "p_flag" VARCHAR(30),
    "p_all1" VARCHAR(30)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "classname" TEXT,
    "fathername" TEXT,
    "sectionname" TEXT,
    "admno" TEXT,
    "mobileno" TEXT,
    "emailid" TEXT,
    "amst_dob" DATE,
    "amst_photo" TEXT,
    "stdaddress" TEXT,
    "perpincode" TEXT,
    "percountry" TEXT
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
    "v_fromdate" TIMESTAMP;
    "v_todate" TIMESTAMP;
BEGIN

    SELECT "ASMAY_Id" INTO "v_ASMAY_Id"
    FROM "dbo"."Adm_School_M_Academic_Year"
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
    FROM "dbo"."Adm_School_M_Academic_Year"
    WHERE "mi_id" = "p_MI_Id"
    AND CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date";

    "v_fromdate" := TO_TIMESTAMP("p_fromdate", 'YYYY-MM-DD');
    "v_todate" := TO_TIMESTAMP("p_todate", 'YYYY-MM-DD');

    IF "p_flag" = 'S' THEN

        IF "p_all1" = '0' THEN

            RETURN QUERY
            SELECT 
                "stud"."AMST_Id",
                (COALESCE("stud"."AMST_FirstName", '') || ' ' || COALESCE("stud"."amst_middlename", '') || ' ' || COALESCE("stud"."AMST_LastName", '')) AS "studentname",
                "cls"."ASMCL_ClassName" AS "classname",
                (COALESCE("stud"."amst_fathername", '') || ' ' || COALESCE("stud"."AMST_FatherSurname", '')) AS "fathername",
                "sec"."ASMC_SectionName" AS "sectionname",
                "stud"."AMST_AdmNo" AS "admno",
                "stud"."amst_mobileno" AS "mobileno",
                "stud"."AMST_emailId" AS "emailid",
                CAST("stud"."AMST_DOB" AS DATE) AS "amst_dob",
                "stud"."AMST_Photoname" AS "amst_photo",
                (COALESCE("stud"."AMST_PerStreet", '') || ',' || COALESCE("stud"."AMST_PerArea", '') || ',' || COALESCE("stud"."AMST_PerCity", '') || ',' || COALESCE("st"."IVRMMS_Name", '') || ',' || COALESCE("con"."IVRMMC_CountryName", '') || '-' || CAST("stud"."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                CAST("stud"."AMST_PerPincode" AS TEXT) AS "perpincode",
                CAST("stud"."AMST_PerCountry" AS TEXT) AS "percountry"
            FROM "dbo"."Adm_M_Student" "stud"
            INNER JOIN "dbo"."Adm_School_Y_Student" "study" ON "stud"."AMST_Id" = "study"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" "cls" ON "study"."ASMCL_Id" = "cls"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" "sec" ON "study"."ASMS_Id" = "sec"."ASMS_Id"
            LEFT JOIN "dbo"."IVRM_Master_Country" "con" ON "stud"."AMST_PerCountry" = "con"."IVRMMC_Id"
            LEFT JOIN "dbo"."IVRM_Master_State" "st" ON "stud"."AMST_PerState" = "st"."IVRMMS_Id"
            WHERE "stud"."MI_Id" = "p_MI_Id"
            AND EXTRACT(MONTH FROM "stud"."AMST_DOB") = CAST("p_month" AS INTEGER)
            AND "study"."ASMAY_Id" = "v_asmayid"
            AND "study"."ASMAY_Id" = "v_ASMAY_Id"
            AND "stud"."AMST_SOL" = "p_flag"
            AND "stud"."AMST_ActiveFlag" = CAST("v_AMST_Activeflag" AS INTEGER)
            AND "study"."AMAY_ActiveFlag" = CAST("v_AMAY_Activefalg" AS INTEGER)
            ORDER BY EXTRACT(YEAR FROM "stud"."AMST_DOB"), EXTRACT(MONTH FROM "stud"."AMST_DOB"), EXTRACT(DAY FROM "stud"."AMST_DOB");

        ELSE

            RETURN QUERY
            SELECT 
                "stud"."AMST_Id",
                (COALESCE("stud"."AMST_FirstName", '') || ' ' || COALESCE("stud"."amst_middlename", '') || ' ' || COALESCE("stud"."AMST_LastName", '')) AS "studentname",
                "cls"."ASMCL_ClassName" AS "classname",
                (COALESCE("stud"."amst_fathername", '') || ' ' || COALESCE("stud"."AMST_FatherSurname", '')) AS "fathername",
                "sec"."ASMC_SectionName" AS "sectionname",
                "stud"."AMST_AdmNo" AS "admno",
                "stud"."amst_mobileno" AS "mobileno",
                "stud"."AMST_emailId" AS "emailid",
                CAST("stud"."AMST_DOB" AS DATE) AS "amst_dob",
                "stud"."AMST_Photoname" AS "amst_photo",
                (COALESCE("stud"."AMST_PerStreet", '') || ',' || COALESCE("stud"."AMST_PerArea", '') || ',' || COALESCE("stud"."AMST_PerCity", '') || ',' || COALESCE("st"."IVRMMS_Name", '') || ',' || COALESCE("con"."IVRMMC_CountryName", '') || '-' || CAST("stud"."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                CAST("stud"."AMST_PerPincode" AS TEXT) AS "perpincode",
                CAST("stud"."AMST_PerCountry" AS TEXT) AS "percountry"
            FROM "dbo"."Adm_M_Student" "stud"
            INNER JOIN "dbo"."Adm_School_Y_Student" "study" ON "stud"."AMST_Id" = "study"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" "cls" ON "study"."ASMCL_Id" = "cls"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" "sec" ON "study"."ASMS_Id" = "sec"."ASMS_Id"
            LEFT JOIN "dbo"."IVRM_Master_Country" "con" ON "stud"."AMST_PerCountry" = "con"."IVRMMC_Id"
            LEFT JOIN "dbo"."IVRM_Master_State" "st" ON "stud"."AMST_PerState" = "st"."IVRMMS_Id"
            WHERE "stud"."MI_Id" = "p_MI_Id"
            AND "stud"."AMST_SOL" = "p_flag"
            AND "study"."ASMAY_Id" = "v_ASMAY_Id"
            AND "stud"."AMST_ActiveFlag" = CAST("v_AMST_Activeflag" AS INTEGER)
            AND "study"."AMAY_ActiveFlag" = CAST("v_AMAY_Activefalg" AS INTEGER)
            AND (EXTRACT(MONTH FROM "stud"."AMST_DOB") * 100 + EXTRACT(DAY FROM "stud"."AMST_DOB")) 
                BETWEEN (EXTRACT(MONTH FROM "v_fromdate") * 100 + EXTRACT(DAY FROM "v_fromdate")) 
                AND (EXTRACT(MONTH FROM "v_todate") * 100 + EXTRACT(DAY FROM "v_todate"))
            ORDER BY EXTRACT(YEAR FROM "stud"."AMST_DOB"), EXTRACT(MONTH FROM "stud"."AMST_DOB"), EXTRACT(DAY FROM "stud"."AMST_DOB");

        END IF;

    ELSE

        IF "p_all1" = '0' THEN

            RETURN QUERY
            SELECT 
                "stud"."AMST_Id",
                (COALESCE("stud"."AMST_FirstName", '') || ' ' || COALESCE("stud"."amst_middlename", '') || ' ' || COALESCE("stud"."AMST_LastName", '')) AS "studentname",
                "cls"."ASMCL_ClassName" AS "classname",
                (COALESCE("stud"."amst_fathername", '') || ' ' || COALESCE("stud"."AMST_FatherSurname", '')) AS "fathername",
                "sec"."ASMC_SectionName" AS "sectionname",
                "stud"."AMST_AdmNo" AS "admno",
                "stud"."amst_mobileno" AS "mobileno",
                "stud"."AMST_emailId" AS "emailid",
                CAST("stud"."AMST_DOB" AS DATE) AS "amst_dob",
                "stud"."AMST_Photoname" AS "amst_photo",
                (COALESCE("stud"."AMST_PerStreet", '') || ',' || COALESCE("stud"."AMST_PerArea", '') || ',' || COALESCE("stud"."AMST_PerCity", '') || ',' || COALESCE("st"."IVRMMS_Name", '') || ',' || COALESCE("con"."IVRMMC_CountryName", '') || '-' || CAST("stud"."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                CAST("stud"."AMST_PerPincode" AS TEXT) AS "perpincode",
                CAST("stud"."AMST_PerCountry" AS TEXT) AS "percountry"
            FROM "dbo"."Adm_M_Student" "stud"
            INNER JOIN "dbo"."Adm_School_Y_Student" "study" ON "stud"."AMST_Id" = "study"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" "cls" ON "study"."ASMCL_Id" = "cls"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" "sec" ON "study"."ASMS_Id" = "sec"."ASMS_Id"
            LEFT JOIN "dbo"."IVRM_Master_Country" "con" ON "stud"."AMST_PerCountry" = "con"."IVRMMC_Id"
            LEFT JOIN "dbo"."IVRM_Master_State" "st" ON "stud"."AMST_PerState" = "st"."IVRMMS_Id"
            WHERE "stud"."MI_Id" = "p_MI_Id"
            AND EXTRACT(MONTH FROM "stud"."AMST_DOB") = CAST("p_month" AS INTEGER)
            AND "study"."ASMAY_Id" = "v_ASMAY_Id"
            AND "stud"."AMST_SOL" = "p_flag"
            AND "stud"."AMST_ActiveFlag" = CAST("v_AMST_Activeflag" AS INTEGER)
            AND "study"."AMAY_ActiveFlag" = CAST("v_AMAY_Activefalg" AS INTEGER)
            ORDER BY EXTRACT(YEAR FROM "stud"."AMST_DOB"), EXTRACT(MONTH FROM "stud"."AMST_DOB"), EXTRACT(DAY FROM "stud"."AMST_DOB");

        ELSE

            RETURN QUERY
            SELECT 
                "stud"."AMST_Id",
                (COALESCE("stud"."AMST_FirstName", '') || ' ' || COALESCE("stud"."amst_middlename", '') || ' ' || COALESCE("stud"."AMST_LastName", '')) AS "studentname",
                "cls"."ASMCL_ClassName" AS "classname",
                (COALESCE("stud"."amst_fathername", '') || ' ' || COALESCE("stud"."AMST_FatherSurname", '')) AS "fathername",
                "sec"."ASMC_SectionName" AS "sectionname",
                "stud"."AMST_AdmNo" AS "admno",
                "stud"."amst_mobileno" AS "mobileno",
                "stud"."AMST_emailId" AS "emailid",
                CAST("stud"."AMST_DOB" AS DATE) AS "amst_dob",
                "stud"."AMST_Photoname" AS "amst_photo",
                (COALESCE("stud"."AMST_PerStreet", '') || ',' || COALESCE("stud"."AMST_PerArea", '') || ',' || COALESCE("stud"."AMST_PerCity", '') || ',' || COALESCE("st"."IVRMMS_Name", '') || ',' || COALESCE("con"."IVRMMC_CountryName", '') || '-' || CAST("stud"."amst_perpincode" AS VARCHAR)) AS "stdaddress",
                CAST("stud"."AMST_PerPincode" AS TEXT) AS "perpincode",
                CAST("stud"."AMST_PerCountry" AS TEXT) AS "percountry"
            FROM "dbo"."Adm_M_Student" "stud"
            INNER JOIN "dbo"."Adm_School_Y_Student" "study" ON "stud"."AMST_Id" = "study"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" "cls" ON "study"."ASMCL_Id" = "cls"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" "sec" ON "study"."ASMS_Id" = "sec"."ASMS_Id"
            LEFT JOIN "dbo"."IVRM_Master_Country" "con" ON "stud"."AMST_PerCountry" = "con"."IVRMMC_Id"
            LEFT JOIN "dbo"."IVRM_Master_State" "st" ON "stud"."AMST_PerState" = "st"."IVRMMS_Id"
            WHERE "stud"."MI_Id" = "p_MI_Id"
            AND "stud"."AMST_SOL" = "p_flag"
            AND "stud"."AMST_ActiveFlag" = CAST("v_AMST_Activeflag" AS INTEGER)
            AND "study"."AMAY_ActiveFlag" = CAST("v_AMAY_Activefalg" AS INTEGER)
            AND (EXTRACT(MONTH FROM "stud"."AMST_DOB") * 100 + EXTRACT(DAY FROM "stud"."AMST_DOB")) 
                BETWEEN (EXTRACT(MONTH FROM "v_fromdate") * 100 + EXTRACT(DAY FROM "v_fromdate")) 
                AND (EXTRACT(MONTH FROM "v_todate") * 100 + EXTRACT(DAY FROM "v_todate"))
            ORDER BY EXTRACT(YEAR FROM "stud"."AMST_DOB"), EXTRACT(MONTH FROM "stud"."AMST_DOB"), EXTRACT(DAY FROM "stud"."AMST_DOB");

        END IF;

    END IF;

    RETURN;

END;
$$;