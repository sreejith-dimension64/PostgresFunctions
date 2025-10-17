CREATE OR REPLACE FUNCTION "dbo"."CLG_SPC_StudentTarnsAlldata"(
    "@MI_Id" BIGINT
)
RETURNS TABLE(
    "spccesT_Id" BIGINT,
    "spccesT_ActiveFlag" BOOLEAN,
    "compitionLevel" VARCHAR,
    "SPCCMCC_Id" BIGINT,
    "categoryName" VARCHAR,
    "studentName" TEXT,
    "amcsT_AdmNo" VARCHAR,
    "spccmscC_Id" BIGINT,
    "sportsName" VARCHAR,
    "spccestRC_Points" NUMERIC,
    "spccestRC_Rank" INTEGER,
    "amcsT_Id" BIGINT,
    "spccestRC_Id" BIGINT,
    "SPCCMCL_Id" BIGINT,
    "spccestRC_ActiveFlag" BOOLEAN,
    "spccestRC_Remarks" VARCHAR,
    "spccesT_House_Class_Flag" VARCHAR,
    "spccmuoM_Id" BIGINT,
    "uomName" VARCHAR,
    "spccmE_Id" BIGINT,
    "spccmsccG_Id" BIGINT,
    "spccmsccG_SportsCCGroupName" VARCHAR,
    "eventName" VARCHAR,
    "spccmeV_EventVenue" VARCHAR,
    "amcO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "acmS_Id" BIGINT,
    "acmS_SectionName" VARCHAR,
    "asmaY_Id" BIGINT,
    "asmaY_Year" VARCHAR,
    "spccmH_HouseName" VARCHAR,
    "spccmH_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "ES"."SPCCEST_Id" AS "spccesT_Id",
        "ES"."SPCCEST_ActiveFlag" AS "spccesT_ActiveFlag",
        "MCL"."SPCCMCL_CompitionLevel" AS "compitionLevel",
        "MCC"."SPCCMCC_Id",
        "MCC"."SPCCMCC_CompitionCategory" AS "categoryName",
        (COALESCE("AMCST"."AMCST_FirstName", '') || ' ' || COALESCE("AMCST"."AMCST_MiddleName", '') || ' ' || COALESCE("AMCST"."AMCST_LastName", '')) AS "studentName",
        "AMCST"."AMCST_AdmNo" AS "amcsT_AdmNo",
        "SPN"."SPCCMSCC_Id" AS "spccmscC_Id",
        "SPN"."SPCCMSCC_SportsCCName" AS "sportsName",
        "ESR"."SPCCESTRC_Points" AS "spccestRC_Points",
        "ESR"."SPCCESTRC_Rank" AS "spccestRC_Rank",
        "ESR"."AMCST_Id" AS "amcsT_Id",
        "ESR"."SPCCESTRC_Id" AS "spccestRC_Id",
        "ES"."SPCCMCL_Id",
        "ESR"."SPCCESTRC_ActiveFlag" AS "spccestRC_ActiveFlag",
        "ESR"."SPCCESTRC_Remarks" AS "spccestRC_Remarks",
        "ES"."SPCCEST_House_Class_Flag" AS "spccesT_House_Class_Flag",
        "UOM"."SPCCMUOM_Id" AS "spccmuoM_Id",
        "UOM"."SPCCMUOM_UOMName" AS "uomName",
        "SME"."SPCCME_Id" AS "spccmE_Id",
        "SMGN"."SPCCMSCCG_Id" AS "spccmsccG_Id",
        "SMGN"."SPCCMSCCG_SportsCCGroupName" AS "spccmsccG_SportsCCGroupName",
        "SME"."SPCCME_EventName" AS "eventName",
        "SMEV"."SPCCMEV_EventVenue" AS "spccmeV_EventVenue",
        "MC"."AMCO_Id" AS "amcO_Id",
        "MC"."AMCO_CourseName" AS "AMCO_CourseName",
        "MB"."AMB_BranchName",
        "AMSE"."AMSE_SEMName",
        "MS"."ACMS_Id" AS "acmS_Id",
        "MS"."ACMS_SectionName" AS "acmS_SectionName",
        "YS"."ASMAY_Id" AS "asmaY_Id",
        "Yer"."ASMAY_Year" AS "asmaY_Year",
        "SMH"."SPCCMH_HouseName" AS "spccmH_HouseName",
        "SSH"."SPCCMH_Id" AS "spccmH_Id"
    FROM "SPC"."SPCC_Events_Students_Record_College" AS "ESR"
    INNER JOIN "SPC"."SPCC_Events_Students" AS "ES" ON "ES"."SPCCEST_Id" = "ESR"."SPCCEST_Id"
    INNER JOIN "SPC"."SPCC_Student_House_College" AS "SSH" ON "ESR"."AMCST_Id" = "SSH"."AMCST_Id" AND "ESR"."MI_Id" = "SSH"."MI_Id" AND "SSH"."ASMAY_Id" = "ES"."ASMAY_Id"
    INNER JOIN "SPC"."SPCC_Master_House" AS "SMH" ON "SSH"."SPCCMH_Id" = "SMH"."SPCCMH_Id" AND "SMH"."MI_Id" = "SSH"."MI_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" AS "AMCST" ON "AMCST"."AMCST_Id" = "ESR"."AMCST_Id" AND ("AMCST"."AMCST_SOL" = 'S') AND "AMCST"."AMCST_ActiveFlag" = 1
    INNER JOIN "SPC"."SPCC_Master_Compition_Level" AS "MCL" ON "ES"."SPCCMCL_Id" = "MCL"."SPCCMCL_Id"
    INNER JOIN "SPC"."SPCC_Master_Compition_Category" AS "MCC" ON "ES"."SPCCMCC_Id" = "MCC"."SPCCMCC_Id"
    INNER JOIN "SPC"."SPCC_Master_SportsCCName" AS "SPN" ON "ES"."SPCCMSCC_Id" = "SPN"."SPCCMSCC_Id"
    INNER JOIN "SPC"."SPCC_Master_UOM" AS "UOM" ON "UOM"."SPCCMUOM_Id" = "ES"."SPCCMUOM_Id"
    INNER JOIN "SPC"."SPCC_Master_Events" AS "SME" ON "SME"."SPCCME_Id" = "ES"."SPCCME_Id"
    INNER JOIN "SPC"."SPCC_Master_SportsCCGroupName" AS "SMGN" ON "SMGN"."SPCCMSCCG_Id" = "ES"."SPCCMSCCG_Id"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "YS" ON "YS"."AMCST_Id" = "SSH"."AMCST_Id" AND "YS"."ASMAY_Id" = "SSH"."ASMAY_Id" AND "YS"."AMCO_Id" = "SSH"."AMCO_Id" AND "YS"."AMB_Id" = "SSH"."AMB_Id" AND "YS"."AMSE_Id" = "SSH"."AMSE_Id" AND "YS"."ACMS_Id" = "SSH"."ACMS_Id" AND "YS"."ACYST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_Course" AS "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" AS "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" AS "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" AS "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" AS "Yer" ON "Yer"."ASMAY_Id" = "YS"."ASMAY_Id"
    INNER JOIN "SPC"."SPCC_Events" AS "SE" ON "SE"."SPCCME_Id" = "ES"."SPCCME_Id" AND "ES"."ASMAY_Id" = "SE"."ASMAY_Id" AND "SE"."MI_Id" = "ES"."MI_Id" AND "SE"."SPCCE_ActiveFlag" = 1
    INNER JOIN "SPC"."SPCC_Master_EventVenue" AS "SMEV" ON "SMEV"."SPCCMEV_Id" = "SE"."SPCCMEV_Id" AND "SMEV"."SPCCMEV_ActiveFlag" = 1
    WHERE "ESR"."MI_Id" = "@MI_Id"
    ORDER BY "ESR"."SPCCESTRC_Id" DESC;
    
    RETURN;
END;
$$;