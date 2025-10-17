CREATE OR REPLACE FUNCTION "dbo"."ClassRadioWiseCompCat_AgeFilter"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id text
)
RETURNS TABLE(
    comptcatenamecls varchar(60),
    comcat_idcls bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
    v_AMST_Id bigint;
    v_StuAgeDays bigint;
    v_CCategoryName varchar(60);
    rec_student RECORD;
    rec_category RECORD;
BEGIN

    DROP TABLE IF EXISTS "SportsAgeFilterHouse12";

    CREATE TEMP TABLE "SportsAgeFilterHouse12"(
        "AMST_Id" bigint,
        "SPCCSH_Date" timestamp,
        "StudentName" varchar(60),
        "ASMCL_ClassName" varchar(60),
        "ASMC_SectionName" varchar(60),
        "SPCCMH_HouseName" varchar(60),
        "AMST_AdmNo" varchar(60),
        "AYear" bigint,
        "AMonth" bigint,
        "ADays" bigint,
        "SPCCSH_Age" varchar(60),
        "Months" bigint,
        "Years" bigint,
        "SMonth" bigint,
        "AMST_DOB" timestamp,
        "CategoryName" varchar(60)
    );

    v_sqldynamic := '
    SELECT DISTINCT a."AMST_Id", j."SPCCSH_Date", 
        CONCAT(a."AMST_FirstName", a."AMST_MiddleName", a."AMST_LastName") AS "StudentName",
        c."ASMCL_ClassName",
        d."ASMC_SectionName",
        l."SPCCMH_HouseName",
        a."AMST_AdmNo",
        CAST(SPLIT_PART(j."SPCCSH_Age_Format", ''-'', 1) AS bigint) AS "AYear",
        CAST(SPLIT_PART(j."SPCCSH_Age_Format", ''-'', 2) AS bigint) AS "AMonth",
        CAST(SPLIT_PART(j."SPCCSH_Age_Format", ''-'', 3) AS bigint) AS "ADays",
        j."SPCCSH_Age",
        EXTRACT(YEAR FROM AGE(j."SPCCSH_Date", a."AMST_DOB")) * 12 + EXTRACT(MONTH FROM AGE(j."SPCCSH_Date", a."AMST_DOB")) AS "Months",
        CAST(SPLIT_PART(j."SPCCSH_Age_Format", ''-'', 1) AS bigint) AS "Years",
        CAST(SPLIT_PART(j."SPCCSH_Age_Format", ''-'', 2) AS bigint) AS "SMonth",
        a."AMST_DOB"
    FROM "adm_school_y_student" b 
    INNER JOIN "SPC"."SPCC_Student_House" j ON b."ASMAY_Id" = j."ASMAY_Id" 
        AND j."ASMCL_Id" = b."ASMCL_Id" 
        AND b."ASMS_Id" = j."ASMS_Id" 
        AND b."AMST_Id" = j."AMST_Id" 
        AND j."MI_Id" = ' || p_MI_Id || ' 
        AND j."ASMAY_Id" = ' || p_ASMAY_Id || ' 
        AND j."SPCCMH_ActiveFlag" = 1 
    INNER JOIN "Adm_M_Student" a ON b."AMST_Id" = a."AMST_Id" 
        AND a."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = j."ASMCL_Id" 
        AND c."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = j."ASMS_Id" 
        AND d."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "SPC"."SPCC_Master_House" l ON l."SPCCMH_Id" = j."SPCCMH_Id" 
    WHERE j."ASMCL_Id" IN (' || p_ASMCL_Id || ')';

    EXECUTE 'INSERT INTO "SportsAgeFilterHouse12" ("AMST_Id", "SPCCSH_Date", "StudentName", "ASMCL_ClassName", "ASMC_SectionName",
        "SPCCMH_HouseName", "AMST_AdmNo", "AYear", "AMonth", "ADays", "SPCCSH_Age", "Months", "Years", "SMonth", "AMST_DOB") ' || v_sqldynamic;

    FOR rec_student IN 
        SELECT "AMST_Id", ("AYear" * 365 + "AMonth" * 30 + "ADays") AS "StuAgeDays" 
        FROM "SportsAgeFilterHouse12"
    LOOP
        v_AMST_Id := rec_student."AMST_Id";
        v_StuAgeDays := rec_student."StuAgeDays";

        FOR rec_category IN 
            SELECT DISTINCT "SPCCMCC_CompitionCategory" 
            FROM "SPC"."SPCC_Master_Compition_Category" 
            WHERE "MI_Id" = p_MI_Id 
                AND v_StuAgeDays >= ("SPCCMCC_FromCCAgeYear" * 365 + "SPCCMCC_FromCCAgeMonth" * 30 + "SPCCMCC_FromCCAgeDays") 
                AND v_StuAgeDays <= ("SPCCMCC_ToCCAgeYear" * 365 + "SPCCMCC_ToCCAgeMonth" * 30 + "SPCCMCC_ToCCAgeDays") 
                AND "SPCCMCC_ActiveFlag" = 1
        LOOP
            v_CCategoryName := rec_category."SPCCMCC_CompitionCategory";

            RAISE NOTICE 'category : %', v_CCategoryName;

            UPDATE "SportsAgeFilterHouse12" 
            SET "CategoryName" = v_CCategoryName 
            WHERE "AMST_Id" = v_AMST_Id;

        END LOOP;

    END LOOP;

    RETURN QUERY
    SELECT DISTINCT a."CategoryName"::varchar(60) AS comptcatenamecls, 
           b."SPCCMCC_Id" AS comcat_idcls
    FROM "SportsAgeFilterHouse12" a
    INNER JOIN "SPC"."SPCC_Master_Compition_Category" b ON b."SPCCMCC_CompitionCategory" = a."CategoryName";

END;
$$;