CREATE OR REPLACE FUNCTION "dbo"."College_Student_Birthday_Report"(
    "MI_Id" TEXT,
    "Monthid" TEXT,
    "Fromdate" VARCHAR(10),
    "Todate" TEXT,
    "AMSE_Id" TEXT,
    "flag" TEXT
)
RETURNS TABLE(
    "regno" TEXT,
    "admno" TEXT,
    "amco_order" INTEGER,
    "amb_order" INTEGER,
    "amse_semorder" INTEGER,
    "course" TEXT,
    "branch" TEXT,
    "semester" TEXT,
    "dob" TEXT,
    "section" TEXT,
    "studentname" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "condition" TEXT;
    "asmay_id" TEXT;
BEGIN

    IF "AMSE_Id" = '0' THEN
        "condition" := '"AMSE_Id" != 0';
    ELSE
        "condition" := '"AMSE_Id" = ' || "AMSE_Id";
    END IF;

    SELECT "ASMAY_Id" INTO "asmay_id"
    FROM "Adm_School_M_Academic_Year"
    WHERE "mi_id" = "MI_Id"::INTEGER
    AND CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date";

    IF "flag" = '0' THEN
        "query" := 'SELECT 
            b."AMCST_RegistrationNo",
            b."AMCST_AdmNo",
            c."amco_order",
            d."amb_order",
            e."amse_semorder",
            c."amco_coursename",
            d."amb_branchname",
            e."amse_semname",
            TO_CHAR(b."amcst_dob", ''DD/MM/YYYY''),
            g."ACMS_SectionName",
            (CASE WHEN b."AMCST_FirstName" IS NULL OR b."AMCST_FirstName" = '''' THEN '''' ELSE b."AMCST_FirstName" END ||
             CASE WHEN b."AMCST_MiddleName" IS NULL OR b."AMCST_MiddleName" = '''' OR b."AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || b."AMCST_MiddleName" END ||
             CASE WHEN b."AMCST_LastName" IS NULL OR b."AMCST_LastName" = '''' OR b."AMCST_LastName" = ''0'' THEN '''' ELSE '' '' || b."AMCST_LastName" END)
        FROM "clg"."Adm_College_Yearly_Student" a
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" g ON g."ACMS_Id" = a."ACMS_Id"
        WHERE b."MI_Id" = ' || "MI_Id" || '
        AND b."AMCST_SOL" = ''s''
        AND b."AMCST_ActiveFlag" = 1
        AND a."ACYST_ActiveFlag" = 1
        AND EXTRACT(MONTH FROM b."amcst_dob") = ' || "Monthid" || '
        AND a."ASMAY_Id" = ' || "asmay_id" || '
        AND a."AMSE_Id" IN (SELECT "AMSE_Id" FROM "clg"."Adm_Master_Semester" WHERE "mi_id" = ' || "MI_Id" || ' AND ' || "condition" || ')
        ORDER BY EXTRACT(MONTH FROM b."amcst_dob"), EXTRACT(DAY FROM b."amcst_dob")';
    ELSE
        "query" := 'SELECT 
            b."AMCST_RegistrationNo",
            b."AMCST_AdmNo",
            c."amco_order",
            d."amb_order",
            e."amse_semorder",
            c."amco_coursename",
            d."amb_branchname",
            e."amse_semname",
            TO_CHAR(b."amcst_dob", ''DD/MM/YYYY''),
            g."ACMS_SectionName",
            (CASE WHEN b."AMCST_FirstName" IS NULL OR b."AMCST_FirstName" = '''' THEN '''' ELSE b."AMCST_FirstName" END ||
             CASE WHEN b."AMCST_MiddleName" IS NULL OR b."AMCST_MiddleName" = '''' OR b."AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || b."AMCST_MiddleName" END ||
             CASE WHEN b."AMCST_LastName" IS NULL OR b."AMCST_LastName" = '''' OR b."AMCST_LastName" = ''0'' THEN '''' ELSE '' '' || b."AMCST_LastName" END)
        FROM "clg"."Adm_College_Yearly_Student" a
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" g ON g."ACMS_Id" = a."ACMS_Id"
        WHERE b."MI_Id" = ' || "MI_Id" || '
        AND b."AMCST_SOL" = ''s''
        AND b."AMCST_ActiveFlag" = 1
        AND a."ACYST_ActiveFlag" = 1
        AND (EXTRACT(DAY FROM b."amcst_dob") BETWEEN EXTRACT(DAY FROM ''' || "Fromdate" || '''::DATE) AND EXTRACT(DAY FROM ''' || "Todate" || '''::DATE))
        AND (EXTRACT(MONTH FROM b."amcst_dob") BETWEEN EXTRACT(MONTH FROM ''' || "Fromdate" || '''::DATE) AND EXTRACT(MONTH FROM ''' || "Todate" || '''::DATE))
        AND a."ASMAY_Id" = ' || "asmay_id" || '
        AND a."AMSE_Id" IN (SELECT "AMSE_Id" FROM "clg"."Adm_Master_Semester" WHERE "mi_id" = ' || "MI_Id" || ' AND ' || "condition" || ')
        ORDER BY EXTRACT(MONTH FROM b."amcst_dob"), EXTRACT(DAY FROM b."amcst_dob")';
    END IF;

    RETURN QUERY EXECUTE "query";

END;
$$;