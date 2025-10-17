CREATE OR REPLACE FUNCTION "dbo"."CLG_Sports_House_Student_Age_Report"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_Type TEXT,
    p_AMCO_Id BIGINT,
    p_AMB_Id BIGINT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_SPCCMH_Id TEXT
)
RETURNS TABLE(
    "AMCST_DOB" TIMESTAMP,
    "Months" INTEGER,
    "Years" TEXT,
    "Monthsd" TEXT,
    "amcsT_Id" BIGINT,
    "AMCST_Name" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "ACMS_SectionName" TEXT,
    "SPCCMH_Id" BIGINT,
    "SPCCMH_HouseName" TEXT,
    "ASMAY_Year" TEXT,
    "SPCCMCL_CompitionLevel" TEXT,
    "SPCCMSCC_SportsCCName" TEXT,
    "SPCCE_StartDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Dynamicsql TEXT;
BEGIN

    IF(p_Type = 'House') THEN
        
        v_Dynamicsql := '
        SELECT DISTINCT  "AMCST_DOB",
        EXTRACT(YEAR FROM AGE("SPCCSH_Date", "AMCST_DOB")) * 12 + EXTRACT(MONTH FROM AGE("SPCCSH_Date", "AMCST_DOB")) as "Months",
        RTRIM(REPLACE(LTRIM(SUBSTRING("SPCCSH_Age_Format", 1, POSITION(''-'' IN "SPCCSH_Age_Format"))), ''-'', '''')) as "Years",
        LTRIM(REPLACE(LTRIM(SUBSTRING("SPCCSH_Age_Format", POSITION(''-'' IN "SPCCSH_Age_Format"),
        CASE WHEN (POSITION(''-'' IN SUBSTRING("SPCCSH_Age_Format", POSITION(''-'' IN "SPCCSH_Age_Format") + 1)) + POSITION(''-'' IN "SPCCSH_Age_Format") - POSITION(''-'' IN "SPCCSH_Age_Format")) <= 0
        THEN 0 ELSE POSITION(''-'' IN SUBSTRING("SPCCSH_Age_Format", POSITION(''-'' IN "SPCCSH_Age_Format") + 1)) END)), ''-'', '''')) AS "Monthsd",
        a."AMCST_Id" as "amcsT_Id",
        COALESCE(c."AMCST_FirstName", '''') || '' '' || COALESCE(c."AMCST_MiddleName", '''') || '' '' || COALESCE(c."AMCST_LastName", '''') AS "AMCST_Name",
        c."AMCST_AdmNo",
        "AMCO_CourseName",
        "AMB_BranchName",
        "AMSE_SEMName",
        "MS"."ACMS_SectionName",
        h."SPCCMH_Id",
        h."SPCCMH_HouseName",
        d."ASMAY_Year",
        "Cat"."SPCCMCC_CompitionCategory" as "SPCCMCL_CompitionLevel",
        sprt."SPCCMSCC_SportsCCName",
        me."SPCCE_StartDate"
        FROM "SPC"."SPCC_Student_House_College" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "HSAC"."AMCST_Id" AND "YS"."ASMAY_Id" = "HSAC"."ASMAY_Id" AND "YS"."AMCO_Id" = "HSAC"."AMCO_Id" AND "YS"."AMB_Id" = "HSAC"."AMB_Id" AND "YS"."AMSE_Id" = "HSAC"."AMSE_Id" AND "YS"."ACMS_Id" = "HSAC"."ACMS_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" "AMS" ON "YS"."AMCST_Id" = "AMS"."AMCST_Id" AND "AMS"."AMCST_SOL" = ''S''
        INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = b."ASMAY_Id" AND a."ASMAY_Id" = d."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_House" h ON h."SPCCMH_Id" = a."SPCCMH_Id"
        INNER JOIN "SPC"."SPCC_Events_Students" "ES" ON "ES"."ASMAY_Id" = b."ASMAY_Id" AND "ES"."MI_Id" = a."MI_Id"
        INNER JOIN "SPC"."SPCC_Events_Students_Record_College" "ESR" ON "ESR"."SPCCEST_Id" = "ES"."SPCCEST_Id" AND "ESR"."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "SPC"."SPCC_Master_Compition_Level" "CL" ON "CL"."SPCCMCL_Id" = "ES"."SPCCMCL_Id" AND "ES"."MI_Id" = "CL"."MI_Id"
        INNER JOIN "SPC"."SPCC_Master_Compition_Category" "Cat" ON "Cat"."SPCCMCC_Id" = "ES"."SPCCMCC_Id" AND "ES"."MI_Id" = "Cat"."MI_Id"
        INNER JOIN "SPC"."SPCC_Master_SportsCCName" sprt ON sprt."SPCCMSCC_Id" = "ES"."SPCCMSCC_Id" AND sprt."MI_Id" = "Cat"."MI_Id"
        INNER JOIN "SPC"."SPCC_Events" me ON me."SPCCME_Id" = "ES"."SPCCME_Id" AND me."MI_Id" = "ES"."MI_Id" AND me."SPCCE_ActiveFlag" = 1
        WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "YS"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND a."MI_Id" = ' || p_MI_Id || '
        AND h."SPCCMH_Id" IN (' || p_SPCCMH_Id || ') AND "AMST_SOL" = ''S'' AND "AMCST_ActiveFlag" = 1 AND "ACYST_ActiveFlag" = 1';

        RETURN QUERY EXECUTE v_Dynamicsql;

    ELSIF(p_Type = 'CS') THEN
        
        v_Dynamicsql := '
        SELECT DISTINCT "AMCST_DOB",
        EXTRACT(YEAR FROM AGE("SPCCSH_Date", "AMCST_DOB")) * 12 + EXTRACT(MONTH FROM AGE("SPCCSH_Date", "AMCST_DOB")) as "Months",
        RTRIM(REPLACE(LTRIM(SUBSTRING("SPCCSH_Age_Format", 1, POSITION(''-'' IN "SPCCSH_Age_Format"))), ''-'', '''')) as "Years",
        LTRIM(REPLACE(LTRIM(SUBSTRING("SPCCSH_Age_Format", POSITION(''-'' IN "SPCCSH_Age_Format"),
        CASE WHEN (POSITION(''-'' IN SUBSTRING("SPCCSH_Age_Format", POSITION(''-'' IN "SPCCSH_Age_Format") + 1)) + POSITION(''-'' IN "SPCCSH_Age_Format") - POSITION(''-'' IN "SPCCSH_Age_Format")) <= 0
        THEN 0 ELSE POSITION(''-'' IN SUBSTRING("SPCCSH_Age_Format", POSITION(''-'' IN "SPCCSH_Age_Format") + 1)) END)), ''-'', '''')) AS "Monthsd",
        a."AMCST_Id" as "amcsT_Id",
        COALESCE(c."AMCST_FirstName", '''') || '' '' || COALESCE(c."AMCST_MiddleName", '''') || '' '' || COALESCE(c."AMCST_LastName", '''') AS "AMCST_Name",
        c."AMCST_AdmNo",
        "MC"."AMCO_CourseName",
        "MB"."AMB_BranchName",
        "AMSE"."AMSE_SEMName",
        "MS"."ACMS_SectionName",
        h."SPCCMH_Id",
        h."SPCCMH_HouseName",
        d."ASMAY_Year",
        "Cat"."SPCCMCC_CompitionCategory" as "SPCCMCL_CompitionLevel",
        sprt."SPCCMSCC_SportsCCName",
        me."SPCCE_StartDate"
        FROM "SPC"."SPCC_Student_House_College" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "HSAC"."AMCST_Id" AND "YS"."ASMAY_Id" = "HSAC"."ASMAY_Id" AND "YS"."AMCO_Id" = "HSAC"."AMCO_Id" AND "YS"."AMB_Id" = "HSAC"."AMB_Id" AND "YS"."AMSE_Id" = "HSAC"."AMSE_Id" AND "YS"."ACMS_Id" = "HSAC"."ACMS_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" "AMS" ON "YS"."AMCST_Id" = "AMS"."AMCST_Id" AND "AMS"."AMCST_SOL" = ''S''
        INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = b."ASMAY_Id" AND a."ASMAY_Id" = d."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_House" h ON h."SPCCMH_Id" = a."SPCCMH_Id"
        INNER JOIN "SPC"."SPCC_Events_Students" "ES" ON "ES"."ASMAY_Id" = b."ASMAY_Id" AND "ES"."MI_Id" = a."MI_Id"
        INNER JOIN "SPC"."SPCC_Events_Students_Record" "ESR" ON "ESR"."SPCCEST_Id" = "ES"."SPCCEST_Id" AND "ESR"."AMST_Id" = a."AMST_Id"
        INNER JOIN "SPC"."SPCC_Master_Compition_Level" "CL" ON "CL"."SPCCMCL_Id" = "ES"."SPCCMCL_Id" AND "ES"."MI_Id" = "CL"."MI_Id"
        INNER JOIN "SPC"."SPCC_Master_Compition_Category" "Cat" ON "Cat"."SPCCMCC_Id" = "ES"."SPCCMCC_Id" AND "ES"."MI_Id" = "Cat"."MI_Id"
        INNER JOIN "SPC"."SPCC_Master_SportsCCName" sprt ON sprt."SPCCMSCC_Id" = "ES"."SPCCMSCC_Id" AND sprt."MI_Id" = "Cat"."MI_Id"
        INNER JOIN "SPC"."SPCC_Events" me ON me."SPCCME_Id" = "ES"."SPCCME_Id" AND me."MI_Id" = "ES"."MI_Id" AND me."SPCCE_ActiveFlag" = 1
        WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND b."ASMAY_Id" = ' || p_ASMAY_Id || ' AND c."MI_Id" = ' || p_MI_Id || ' 
        AND a."AMCO_Id" = ' || p_AMCO_Id || ' AND a."AMB_Id" = ' || p_AMB_Id || ' AND a."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND a."ACMS_Id" IN (' || p_ACMS_Id || ') AND h."SPCCMH_Id" IN (' || p_SPCCMH_Id || ') 
        AND "AMCST_SOL" = ''S'' AND "AMCST_ActiveFlag" = 1 AND "ACYST_ActiveFlag" = 1';

        RETURN QUERY EXECUTE v_Dynamicsql;

    END IF;

    RETURN;

END;
$$;