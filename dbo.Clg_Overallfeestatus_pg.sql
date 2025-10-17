CREATE OR REPLACE FUNCTION "dbo"."Clg_Overallfeestatus"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint,
    p_ACMS_Id text,
    p_ACQ_Id bigint,
    p_FMG_Id text,
    p_FMH_Id text
)
RETURNS TABLE(
    "AMCST_AdmNo" character varying,
    "StudentName" text,
    "CategoryName" text,
    "BFCSS_CurrentYrCharges" numeric,
    "BFCSS_TotalCharges" numeric,
    "BFCSS_ConcessionAmount" numeric,
    "BFCSS_AdjustedAmount" numeric,
    "BFCSS_WaivedAmount" numeric,
    "Collection" numeric,
    "CollectionAnyTime" numeric,
    "Receivable" numeric,
    "StudentDue" numeric,
    "CollegeDue" numeric,
    "OverallDue" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlQuery text;
BEGIN

    v_SqlQuery := '
    SELECT DISTINCT "AMCS"."AMCST_AdmNo",
           (COALESCE("AMCS"."AMCST_FirstName",'''') || '' '' || COALESCE("AMCS"."AMCST_MiddleName",'''') || '' '' || COALESCE("AMCS"."AMCST_LastName",'''')) AS "StudentName",
           ("ACQC"."ACQC_CategoryName" || ''::'' || "ACQC"."ACQC_CategoryCode") AS "CategoryName",
           SUM("FCSS"."FCSS_CurrentYrCharges") AS "BFCSS_CurrentYrCharges",
           SUM("FCSS"."FCSS_TotalCharges") AS "BFCSS_TotalCharges",
           SUM("FCSS"."FCSS_ConcessionAmount") AS "BFCSS_ConcessionAmount",
           SUM("FCSS"."FCSS_AdjustedAmount") AS "BFCSS_AdjustedAmount",
           SUM("FCSS"."FCSS_WaivedAmount") AS "BFCSS_WaivedAmount",
           SUM("FCSS"."FCSS_PaidAmount") AS "Collection",
           SUM("FCSS"."FCSS_FineAmount") AS "CollectionAnyTime",
           SUM("FCSS"."FCSS_ToBePaid") AS "Receivable",
           SUM("FCSS"."FCSS_OBArrearAmount") AS "StudentDue",
           SUM("FCSS"."FCSS_OBExcessAmount") AS "CollegeDue",
           (SUM("FCSS"."FCSS_OBArrearAmount") - SUM("FCSS"."FCSS_OBExcessAmount")) AS "OverallDue"
    FROM "CLG"."Adm_Master_College_Student" "AMCS"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id" 
        AND "AMCS"."AMCST_SOL" = ''S'' AND "AMCS"."AMCST_ActiveFlag" = 1 AND "ACYS"."ACYST_ActiveFlag" = 1 
        AND "AMCS"."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "CLG"."Adm_Master_Course" "AMCO" ON "AMCO"."MI_Id" = ' || p_MI_Id || ' 
        AND "AMCO"."AMCO_Id" = "AMCS"."AMCO_Id" AND "AMCO"."AMCO_Id" = "ACYS"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "AMCS"."AMB_Id" AND "AMB"."AMB_Id" = "ACYS"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "AMS" ON "AMS"."AMSE_Id" = "AMCS"."AMSE_Id" AND "AMS"."AMSE_Id" = "AMCS"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" "ACMS" ON "ACMS"."ACMS_Id" = "ACYS"."ACMS_Id"
    INNER JOIN "CLG"."Adm_College_Quota" "ACQ" ON "ACQ"."ACQ_Id" = "AMCS"."ACQ_Id"
    INNER JOIN "CLG"."Adm_College_Quota_Category" "ACQC" ON "ACQC"."ACQC_Id" = "AMCS"."ACQC_Id"
    INNER JOIN "CLG"."Adm_College_Quota_Category_Mapping" "ACQCM" ON "ACQCM"."ACQ_Id" = "ACQ"."ACQ_Id" 
        AND "ACQCM"."ACQC_Id" = "ACQC"."ACQC_Id" AND "ACQCM"."ACQCM_ActiveFlg" = 1
    INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."AMCO_Id" = "AMCS"."AMCO_Id" 
        AND "FCMA"."AMB_Id" = "AMB"."AMB_Id" AND "FCMA"."MI_Id" = ' || p_MI_Id || ' 
        AND "FCMA"."ASMAY_Id" = ' || p_ASMAY_Id || '
    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" ON "FCMAS"."MI_Id" = ' || p_MI_Id || ' 
        AND "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id"
    INNER JOIN "CLG"."Fee_College_Student_Status" "FCSS" ON "FCSS"."MI_Id" = ' || p_MI_Id || ' 
        AND "FCSS"."FCMAS_Id" = "FCMAS"."FCMAS_Id" AND "FCSS"."AMCST_Id" = "AMCS"."AMCST_Id"
    INNER JOIN "dbo"."Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCSS"."FMG_Id" AND "FMG"."MI_Id" = ' || p_MI_Id || '
    WHERE "AMCS"."MI_Id" = ' || p_MI_Id || ' 
        AND "AMCO"."AMCO_Id" IN (
            SELECT DISTINCT "AMCO_Id" 
            FROM "CLG"."Adm_College_AY_Course" "ACAC"
            INNER JOIN "CLG"."Adm_College_AY_Course_Branch" "ACACB" ON "ACACB"."MI_Id" = ' || p_MI_Id || ' 
                AND "ACACB"."ACAYC_Id" = "ACAC"."ACAYC_Id"
            WHERE "ACAC"."AMCO_Id" = "AMCO"."AMCO_Id" 
                AND "ACAC"."MI_Id" = ' || p_MI_Id || ' 
                AND "ACAC"."ASMAY_Id" = ' || p_ASMAY_Id || '
        )
        AND "AMCO"."AMCO_Id" = ' || p_AMCO_Id || ' 
        AND "AMB"."AMB_Id" = ' || p_AMB_Id || ' 
        AND "AMS"."AMSE_Id" = ' || p_AMSE_Id || ' 
        AND "ACMS"."ACMS_Id" IN (' || p_ACMS_Id || ') 
        AND "ACQ"."ACQ_Id" = ' || p_ACQ_Id || ' 
        AND "FCSS"."FMG_Id" IN (' || p_FMG_Id || ') 
        AND "FCSS"."FMH_Id" IN (' || p_FMH_Id || ')
    GROUP BY "AMCS"."AMCST_AdmNo", "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", 
             "ACQC"."ACQC_CategoryName", "ACQC"."ACQC_CategoryCode"';

    RETURN QUERY EXECUTE v_SqlQuery;

END;
$$;