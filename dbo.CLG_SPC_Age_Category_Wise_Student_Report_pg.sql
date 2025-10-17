CREATE OR REPLACE FUNCTION "dbo"."CLG_SPC_Age_Category_Wise_Student_Report"(
    "MI_Id" VARCHAR(50),
    "ASMAY_Id" VARCHAR(50),
    "AMCO_Id" VARCHAR(50),
    "AMB_Id" VARCHAR(50),
    "AMSE_Id" TEXT,
    "ACMS_Id" TEXT,
    "SPCCMH_Id" TEXT,
    "Type" TEXT
)
RETURNS TABLE(
    "amcsT_Id" BIGINT,
    "AMST_Name" VARCHAR(60),
    "AMCO_CourseName" VARCHAR(60),
    "AMB_BranchName" VARCHAR(60),
    "AMSE_SEMName" VARCHAR(60),
    "ACMS_SectionName" VARCHAR(60),
    "SPCCMH_HouseName" VARCHAR(60),
    "AMCST_DOB" TIMESTAMP,
    "AMCST_AdmNo" VARCHAR(60),
    "SPCCSHC_Date" TIMESTAMP,
    "SPCCMCL_CompitionLevel" VARCHAR(60),
    "SPCCSHC_Age" VARCHAR(60),
    "Months" BIGINT,
    "Years" BIGINT,
    "Monthsd" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqldynamic" TEXT;
    "sqldynamic1" TEXT;
    "context" TEXT;
    "AMCST_Id" BIGINT;
    "StuAgeDays" BIGINT;
    "CCategoryName" VARCHAR(60);
    rec RECORD;
    cat_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "CLG_SportsAgeFilterHouse_Temp";
    DROP TABLE IF EXISTS "CLG_SportsAgeFilter_Temp";
    DROP TABLE IF EXISTS "CLG_SportsCategory_Temp";

    CREATE TEMP TABLE "CLG_SportsAgeFilterHouse_Temp"(
        "AMCST_Id" BIGINT,
        "SPCCSHC_Date" TIMESTAMP,
        "StudentName" VARCHAR(60),
        "AMCO_CourseName" VARCHAR(60),
        "AMB_BranchName" VARCHAR(60),
        "AMSE_SEMName" VARCHAR(60),
        "ACMS_SectionName" VARCHAR(60),
        "SPCCMH_HouseName" VARCHAR(60),
        "AMCST_AdmNo" VARCHAR(60),
        "AYear" BIGINT,
        "AMonth" BIGINT,
        "ADays" BIGINT,
        "SPCCSHC_Age" VARCHAR(60),
        "Months" BIGINT,
        "Years" BIGINT,
        "SMonth" BIGINT,
        "AMCST_DOB" TIMESTAMP,
        "CategoryName" VARCHAR(60)
    );

    CREATE TEMP TABLE "CLG_SportsCategory_Temp" AS
    SELECT DISTINCT "SPCCMCC_CompitionCategory",
        ("SPCCMCC_FromCCAgeYear"*365+"SPCCMCC_FromCCAgeMonth"*30+"SPCCMCC_FromCCAgeDays") AS "CatFrom",
        ("SPCCMCC_ToCCAgeYear"*365+"SPCCMCC_ToCCAgeMonth"*30+"SPCCMCC_ToCCAgeDays") AS "CatTo"
    FROM "SPC"."SPCC_Master_Compition_Category" CC 
    WHERE CC."MI_Id" = "MI_Id"::BIGINT;

    IF ("Type" = 'CS') THEN
        
        IF ("SPCCMH_Id" != '') THEN
            "context" := ' WHERE j."MI_Id"=' || "MI_Id" || ' AND j."ASMAY_Id"=' || "ASMAY_Id" || 
                        ' AND j."AMCO_Id" IN (' || "AMCO_Id" || ') AND j."AMB_Id" IN (' || "AMB_Id" || 
                        ') AND j."AMSE_Id" IN (' || "AMSE_Id" || ') AND j."ACMS_Id" IN (' || "ACMS_Id" || 
                        ') AND j."SPCCMH_Id" IN (' || "SPCCMH_Id" || ') ';
        ELSE
            "context" := ' WHERE j."MI_Id"=' || "MI_Id" || ' AND j."ASMAY_Id"=' || "ASMAY_Id" || 
                        ' AND j."AMCO_Id" IN (' || "AMCO_Id" || ') AND j."AMB_Id" IN (' || "AMB_Id" || 
                        ') AND j."AMSE_Id" IN (' || "AMSE_Id" || ') AND j."ACMS_Id" IN (' || "ACMS_Id" || ') ';
        END IF;

        "sqldynamic" := '
        INSERT INTO "CLG_SportsAgeFilterHouse_Temp"("AMCST_Id","SPCCSHC_Date","StudentName","AMCO_CourseName","AMB_BranchName","AMSE_SEMName","ACMS_SectionName","SPCCMH_HouseName","AMCST_AdmNo","AYear","AMonth","ADays","SPCCSHC_Age","Months","Years","SMonth","AMCST_DOB")
        SELECT DISTINCT AMCST."AMCST_Id", j."SPCCSHC_Date",
            COALESCE(AMCST."AMCST_FirstName",'''') || '' '' || COALESCE(AMCST."AMCST_MiddleName",'''') || '' '' || COALESCE(AMCST."AMCST_LastName",'''') AS "StudentName",
            MC."AMCO_CourseName", MB."AMB_BranchName", AMSE."AMSE_SEMName",
            MS."ACMS_SectionName", l."SPCCMH_HouseName", AMCST."AMST_AdmNo",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',1)::BIGINT AS "AYear",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',2)::BIGINT AS "AMonth",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',3)::BIGINT AS "ADays",
            j."SPCCSH_Age",
            EXTRACT(YEAR FROM AGE(j."SPCCSH_Date", AMCST."AMCST_DOB"))*12 + EXTRACT(MONTH FROM AGE(j."SPCCSH_Date", AMCST."AMCST_DOB")) AS "Months",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',1)::BIGINT AS "Years",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',2)::BIGINT AS "SMonth",
            AMCST."AMCST_DOB"
        FROM "CLG"."Adm_Master_College_Student" AS AMCST 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS YS ON YS."AMCST_Id" = AMCST."AMCST_Id" 
            AND YS."AMCO_Id" = AMCST."AMCO_Id" AND YS."AMB_Id" = AMCST."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Course" MC ON YS."AMCO_Id" = MC."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id" = YS."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id" = YS."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" MS ON YS."ACMS_Id" = MS."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Student_House_College" j ON j."AMCST_Id" = AMCST."AMCST_Id" 
            AND j."ASMAY_Id" = YS."ASMAY_Id" AND j."SPCCMHC_ActiveFlag" = TRUE 
            AND YS."ASMAY_Id" = j."ASMAY_Id" AND YS."AMCO_Id" = j."AMCO_Id" 
            AND YS."AMB_Id" = j."AMB_Id" AND YS."AMSE_Id" = j."AMSE_Id" AND YS."ACMS_Id" = j."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Master_House" l ON l."SPCCMH_Id" = j."SPCCMH_Id" ' || "context";

        EXECUTE "sqldynamic";

        FOR rec IN SELECT "AMCST_Id", ("AYear"*365+"AMonth"*30+"ADays") AS "StuAgeDays" 
                   FROM "CLG_SportsAgeFilterHouse_Temp"
        LOOP
            "AMCST_Id" := rec."AMCST_Id";
            "StuAgeDays" := rec."StuAgeDays";

            FOR cat_rec IN SELECT DISTINCT "SPCCMCC_CompitionCategory" 
                          FROM "CLG_SportsCategory_Temp" CC 
                          WHERE "StuAgeDays" BETWEEN "CatFrom" AND "CatTo"
            LOOP
                "CCategoryName" := cat_rec."SPCCMCC_CompitionCategory";
                
                UPDATE "CLG_SportsAgeFilterHouse_Temp" 
                SET "CategoryName" = "CCategoryName" 
                WHERE "AMCST_Id" = "AMCST_Id";
            END LOOP;
        END LOOP;

        RETURN QUERY
        SELECT "AMCST_Id" AS "amcsT_Id", "StudentName" AS "AMST_Name", "AMCO_CourseName", "AMB_BranchName", 
               "AMSE_SEMName", "ACMS_SectionName", "SPCCMH_HouseName", "AMCST_DOB", "AMCST_AdmNo", 
               "SPCCSHC_Date", "CategoryName" AS "SPCCMCL_CompitionLevel", "SPCCSHC_Age", 
               "Months", "Years", "SMonth" AS "Monthsd"
        FROM "CLG_SportsAgeFilterHouse_Temp";

    ELSIF ("Type" = 'House') THEN

        "sqldynamic" := '
        INSERT INTO "CLG_SportsAgeFilterHouse_Temp"("AMCST_Id","SPCCSHC_Date","StudentName","AMCO_CourseName","AMB_BranchName","AMSE_SEMName","ACMS_SectionName","SPCCMH_HouseName","AMCST_AdmNo","AYear","AMonth","ADays","SPCCSHC_Age","Months","Years","SMonth","AMCST_DOB")
        SELECT DISTINCT AMCST."AMCST_Id", j."SPCCSHC_Date",
            COALESCE(AMCST."AMCST_FirstName",'''') || '' '' || COALESCE(AMCST."AMCST_MiddleName",'''') || '' '' || COALESCE(AMCST."AMCST_LastName",'''') AS "StudentName",
            MC."AMCO_CourseName", MB."AMB_BranchName", AMSE."AMSE_SEMName",
            MS."ACMS_SectionName", l."SPCCMH_HouseName", AMCST."AMST_AdmNo",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',1)::BIGINT AS "AYear",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',2)::BIGINT AS "AMonth",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',3)::BIGINT AS "ADays",
            j."SPCCSH_Age",
            EXTRACT(YEAR FROM AGE(j."SPCCSH_Date", AMCST."AMCST_DOB"))*12 + EXTRACT(MONTH FROM AGE(j."SPCCSH_Date", AMCST."AMCST_DOB")) AS "Months",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',1)::BIGINT AS "Years",
            SPLIT_PART(REPLACE(j."SPCCSHC_Age_Format",''-'',''.''),''.'',2)::BIGINT AS "SMonth",
            AMCST."AMCST_DOB"
        FROM "CLG"."Adm_Master_College_Student" AS AMCST 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS YS ON YS."AMCST_Id" = AMCST."AMCST_Id" 
            AND YS."AMCO_Id" = AMCST."AMCO_Id" AND YS."AMB_Id" = AMCST."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Course" MC ON YS."AMCO_Id" = MC."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id" = YS."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id" = YS."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" MS ON YS."ACMS_Id" = MS."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Student_House_College" j ON j."AMCST_Id" = AMCST."AMCST_Id" 
            AND j."ASMAY_Id" = YS."ASMAY_Id" AND j."SPCCMHC_ActiveFlag" = TRUE 
            AND YS."ASMAY_Id" = j."ASMAY_Id" AND YS."AMCO_Id" = j."AMCO_Id" 
            AND YS."AMB_Id" = j."AMB_Id" AND YS."AMSE_Id" = j."AMSE_Id" AND YS."ACMS_Id" = j."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Master_House" l ON l."SPCCMH_Id" = j."SPCCMH_Id"
        WHERE j."MI_Id" = ' || "MI_Id" || ' AND j."ASMAY_Id" = ' || "ASMAY_Id" || 
        ' AND j."SPCCMH_Id" IN (' || "SPCCMH_Id" || ')';

        EXECUTE "sqldynamic";

        FOR rec IN SELECT "AMCST_Id", ("AYear"*365+"AMonth"*30+"ADays") AS "StuAgeDays" 
                   FROM "CLG_SportsAgeFilterHouse_Temp"
        LOOP
            "AMCST_Id" := rec."AMCST_Id";
            "StuAgeDays" := rec."StuAgeDays";

            FOR cat_rec IN SELECT DISTINCT "SPCCMCC_CompitionCategory" 
                          FROM "CLG_SportsCategory_Temp" 
                          WHERE "StuAgeDays" BETWEEN "CatFrom" AND "CatTo"
            LOOP
                "CCategoryName" := cat_rec."SPCCMCC_CompitionCategory";
                
                UPDATE "CLG_SportsAgeFilterHouse_Temp" 
                SET "CategoryName" = "CCategoryName" 
                WHERE "AMCST_Id" = "AMCST_Id";
            END LOOP;
        END LOOP;

        RETURN QUERY
        SELECT "AMCST_Id" AS "amcsT_Id", "StudentName" AS "AMST_Name", "AMCO_CourseName", "AMB_BranchName", 
               "AMSE_SEMName", "ACMS_SectionName", "SPCCMH_HouseName", "AMCST_DOB", "AMCST_AdmNo", 
               "SPCCSHC_Date", "CategoryName" AS "SPCCMCL_CompitionLevel", "SPCCSHC_Age", 
               "Months", "Years", "SMonth" AS "Monthsd"
        FROM "CLG_SportsAgeFilterHouse_Temp";

    END IF;

    RETURN;

END;
$$;