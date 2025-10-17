CREATE OR REPLACE FUNCTION "dbo"."GET_PARENT_SMARTCARD_REPORT"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "STFLAG" TEXT,
    "FRMDATE" DATE,
    "TODATE" DATE
)
RETURNS TABLE(
    "STP_ID" INTEGER,
    "STP_SNAME" VARCHAR,
    "STP_SEMAIL" VARCHAR,
    "STP_SMOBILENO" VARCHAR,
    "STP_SBLOOD" VARCHAR,
    "STP_SPHOTO" TEXT,
    "STP_FNAME" VARCHAR,
    "STP_FEMAIL" VARCHAR,
    "STP_FMOBILENO" VARCHAR,
    "STP_FBLOOD" VARCHAR,
    "STP_FPHOTO" TEXT,
    "STP_MNAME" VARCHAR,
    "STP_MEMAIL" VARCHAR,
    "STP_MMOBILENO" VARCHAR,
    "STP_MBLOOD" VARCHAR,
    "STP_MPHOTO" TEXT,
    "STP_PERSTREET" VARCHAR,
    "STP_PERAREA" VARCHAR,
    "STP_PERCITY" VARCHAR,
    "STP_PERSTATE" INTEGER,
    "STP_PERCOUNTRY" INTEGER,
    "pstate" VARCHAR,
    "pcountry" VARCHAR,
    "STP_PERPIN" VARCHAR,
    "STP_CURSTREET" VARCHAR,
    "STP_CURAREA" VARCHAR,
    "STP_CURCITY" VARCHAR,
    "STP_CURSTATE" INTEGER,
    "STP_CURCOUNTRY" INTEGER,
    "cstate" VARCHAR,
    "ccountry" VARCHAR,
    "STP_CURPIN" VARCHAR,
    "STP_STATUS" VARCHAR,
    "Createddate" TIMESTAMP,
    "Updateddate" TIMESTAMP,
    "STP_DOB" DATE,
    "STP_DOBWORDS" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "STFLAG" = 'ALL' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."STP_ID", 
            A."STP_SNAME",
            A."STP_SEMAIL",
            A."STP_SMOBILENO",
            A."STP_SBLOOD",
            A."STP_SPHOTO",
            A."STP_FNAME",
            A."STP_FEMAIL",
            A."STP_FMOBILENO",
            A."STP_FBLOOD",
            A."STP_FPHOTO",
            A."STP_MNAME",
            A."STP_MEMAIL",
            A."STP_MMOBILENO",
            A."STP_MBLOOD",
            A."STP_MPHOTO",
            A."STP_PERSTREET",
            A."STP_PERAREA",
            A."STP_PERCITY",
            A."STP_PERSTATE",
            A."STP_PERCOUNTRY",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE A."STP_PERSTATE" = "IVRMMS_Id") AS "pstate",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE A."STP_PERCOUNTRY" = "IVRMMC_Id") AS "pcountry",
            A."STP_PERPIN",
            A."STP_CURSTREET",
            A."STP_CURAREA",
            A."STP_CURCITY",
            A."STP_CURSTATE",
            A."STP_CURCOUNTRY",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE A."STP_CURSTATE" = "IVRMMS_Id") AS "cstate",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE A."STP_CURCOUNTRY" = "IVRMMC_Id") AS "ccountry",
            A."STP_CURPIN",
            (CASE WHEN A."STP_STATUS" = 'Updated' THEN 'APPROVED' ELSE 'PENDING' END) AS "STP_STATUS",
            A."Createddate",
            A."Updateddate",
            A."STP_DOB",
            A."STP_DOBWORDS",
            "ASMC"."ASMCL_ClassName",
            "ASMS"."ASMC_SectionName"
        FROM "STUDENT_PORTAL_DATA_UPDATE" AS A
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
        WHERE "AMS"."MI_Id" = "MI_Id" 
            AND CAST(A."Updateddate" AS DATE) BETWEEN "FRMDATE" AND "TODATE" 
            AND "ASYS"."ASMAY_Id" = "ASMAY_Id";
    
    ELSIF "STFLAG" = 'APPROVED' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."STP_ID", 
            A."STP_SNAME",
            A."STP_SEMAIL",
            A."STP_SMOBILENO",
            A."STP_SBLOOD",
            A."STP_SPHOTO",
            A."STP_FNAME",
            A."STP_FEMAIL",
            A."STP_FMOBILENO",
            A."STP_FBLOOD",
            A."STP_FPHOTO",
            A."STP_MNAME",
            A."STP_MEMAIL",
            A."STP_MMOBILENO",
            A."STP_MBLOOD",
            A."STP_MPHOTO",
            A."STP_PERSTREET",
            A."STP_PERAREA",
            A."STP_PERCITY",
            A."STP_PERSTATE",
            A."STP_PERCOUNTRY",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE A."STP_PERSTATE" = "IVRMMS_Id") AS "pstate",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE A."STP_PERCOUNTRY" = "IVRMMC_Id") AS "pcountry",
            A."STP_PERPIN",
            A."STP_CURSTREET",
            A."STP_CURAREA",
            A."STP_CURCITY",
            A."STP_CURSTATE",
            A."STP_CURCOUNTRY",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE A."STP_CURSTATE" = "IVRMMS_Id") AS "cstate",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE A."STP_CURCOUNTRY" = "IVRMMC_Id") AS "ccountry",
            A."STP_CURPIN",
            (CASE WHEN A."STP_STATUS" = 'Updated' THEN 'APPROVED' ELSE 'PENDING' END) AS "STP_STATUS",
            A."Createddate",
            A."Updateddate",
            A."STP_DOB",
            A."STP_DOBWORDS",
            "ASMC"."ASMCL_ClassName",
            "ASMS"."ASMC_SectionName"
        FROM "STUDENT_PORTAL_DATA_UPDATE" AS A
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
        WHERE "AMS"."MI_Id" = "MI_Id" 
            AND CAST(A."Updateddate" AS DATE) BETWEEN "FRMDATE" AND "TODATE" 
            AND A."STP_STATUS" = 'Updated' 
            AND "ASYS"."ASMAY_Id" = "ASMAY_Id";
    
    ELSIF "STFLAG" = 'PENDING' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."STP_ID", 
            A."STP_SNAME",
            A."STP_SEMAIL",
            A."STP_SMOBILENO",
            A."STP_SBLOOD",
            A."STP_SPHOTO",
            A."STP_FNAME",
            A."STP_FEMAIL",
            A."STP_FMOBILENO",
            A."STP_FBLOOD",
            A."STP_FPHOTO",
            A."STP_MNAME",
            A."STP_MEMAIL",
            A."STP_MMOBILENO",
            A."STP_MBLOOD",
            A."STP_MPHOTO",
            A."STP_PERSTREET",
            A."STP_PERAREA",
            A."STP_PERCITY",
            A."STP_PERSTATE",
            A."STP_PERCOUNTRY",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE A."STP_PERSTATE" = "IVRMMS_Id") AS "pstate",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE A."STP_PERCOUNTRY" = "IVRMMC_Id") AS "pcountry",
            A."STP_PERPIN",
            A."STP_CURSTREET",
            A."STP_CURAREA",
            A."STP_CURCITY",
            A."STP_CURSTATE",
            A."STP_CURCOUNTRY",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE A."STP_CURSTATE" = "IVRMMS_Id") AS "cstate",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE A."STP_CURCOUNTRY" = "IVRMMC_Id") AS "ccountry",
            A."STP_CURPIN",
            (CASE WHEN A."STP_STATUS" = 'Updated' THEN 'APPROVED' ELSE 'PENDING' END) AS "STP_STATUS",
            A."Createddate",
            A."Updateddate",
            A."STP_DOB",
            A."STP_DOBWORDS",
            "ASMC"."ASMCL_ClassName",
            "ASMS"."ASMC_SectionName"
        FROM "STUDENT_PORTAL_DATA_UPDATE" AS A
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
        WHERE "AMS"."MI_Id" = "MI_Id" 
            AND CAST(A."Updateddate" AS DATE) BETWEEN "FRMDATE" AND "TODATE" 
            AND A."STP_STATUS" = 'Waiting' 
            AND "ASYS"."ASMAY_Id" = "ASMAY_Id";
    END IF;
    
    RETURN;
END;
$$;