CREATE OR REPLACE FUNCTION "dbo"."CLG_SPC_WinnerReport"(
    "p_MI_Id" bigint,
    "p_ASMAY_Id" bigint,
    "p_AMCO_Id" bigint,
    "p_AMB_Id" bigint,
    "p_AMSE_Id" text,
    "p_ACMS_Id" text,
    "p_Type" varchar(50),
    "p_SPCCMH_Id" text,
    "p_SPCCME_Id" text,
    "p_SPCCMSCC_Id" text
)
RETURNS TABLE(
    "AMCST_AdmNo" varchar,
    "AMCST_Name" text,
    "SPCCMSCC_SportsCCName" varchar,
    "SPCCMSCC_Id" bigint,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "AMSE_SEMName" varchar,
    "ACMS_SectionName" varchar,
    "SPCCESTRC_Points" numeric,
    "SPCCESTRC_Rank" integer,
    "SPCCE_StartDate" timestamp,
    "SPCCMEV_EventVenue" varchar,
    "SPCCME_EventName" varchar,
    "SPCCMH_HouseName" varchar,
    "AMCO_Id" bigint,
    "AMB_Id" bigint,
    "AMSE_Id" bigint,
    "ACMS_Id" bigint,
    "SPCCME_Id" bigint,
    "SPCCE_Id" bigint,
    "AMCST_Id" bigint,
    "ASMAY_Year" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamicsql text;
BEGIN

    IF "p_Type" = 'House' THEN
    
        v_dynamicsql := '
        SELECT DISTINCT a."AMCST_AdmNo",
               COALESCE(a."AMCST_FirstName",'''') || '' '' || COALESCE(a."AMCST_MiddleName",'''') || '' '' || COALESCE(a."AMCST_LastName",'''') as "AMCST_Name",
               sport."SPCCMSCC_SportsCCName",
               sport."SPCCMSCC_Id",
               AMC."AMCO_CourseName",
               MB."AMB_BranchName",
               AMSE."AMSE_SEMName",
               d."ACMS_SectionName",
               e."SPCCESTRC_Points",
               e."SPCCESTRC_Rank",
               f."SPCCE_StartDate",
               EV."SPCCMEV_EventVenue",
               g."SPCCME_EventName",
               l."SPCCMH_HouseName",
               AMC."AMCO_Id",
               MB."AMB_Id",
               AMSE."AMSE_Id",
               d."ACMS_Id",
               g."SPCCME_Id",
               f."SPCCE_Id",
               a."AMCST_Id",
               Yr."ASMAY_Year"
        FROM "CLG"."Adm_Master_College_Student" a 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" YS ON YS."AMCST_Id" = a."AMCST_Id" AND YS."ACYST_ActiveFlag" = 1 AND a."AMCST_ActiveFlag" = 1 AND a."AMCST_SOL" = ''S''
        INNER JOIN "CLG"."Adm_Master_Course" AMC ON YS."AMCO_Id" = AMC."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id" = YS."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id" = YS."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" d ON YS."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Student_House_College" j ON j."AMCST_Id" = YS."AMCST_Id" AND j."AMCO_Id" = YS."AMCO_Id" AND j."AMB_Id" = YS."AMB_Id" AND j."AMSE_Id" = YS."AMSE_Id" AND j."ACMS_Id" = YS."ACMS_Id" AND j."ASMAY_Id" = YS."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Events_Students_Record_College" e ON e."AMCST_Id" = j."AMCST_Id"
        INNER JOIN "SPC"."SPCC_Events_Students" ES ON ES."SPCCEST_Id" = e."SPCCEST_Id" AND YS."ASMAY_Id" = ES."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_Events" g ON g."SPCCME_Id" = ES."SPCCME_Id"
        INNER JOIN "SPC"."SPCC_Events" f ON f."SPCCME_Id" = ES."SPCCME_Id" AND f."ASMAY_Id" = ES."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_EventVenue" EV ON EV."SPCCMEV_Id" = f."SPCCMEV_Id"
        INNER JOIN "SPC"."SPCC_Master_House" l ON l."SPCCMH_Id" = j."SPCCMH_Id"
        INNER JOIN "SPC"."SPCC_Master_SportsCCName" sport ON ES."SPCCMSCC_Id" = sport."SPCCMSCC_Id"
        INNER JOIN "Adm_School_M_Academic_Year" Yr ON Yr."ASMAY_Id" = YS."ASMAY_Id"
        WHERE a."MI_Id" = ' || "p_MI_Id" || ' AND YS."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND l."SPCCMH_Id" IN (' || "p_SPCCMH_Id" || ') AND g."SPCCME_Id" IN (' || "p_SPCCME_Id" || ') AND ES."SPCCMSCC_Id" IN (' || "p_SPCCMSCC_Id" || ') AND e."SPCCESTRC_Rank" <= 3';

        RETURN QUERY EXECUTE v_dynamicsql;

    ELSIF "p_Type" = 'CS' THEN
    
        v_dynamicsql := '
        SELECT DISTINCT a."AMCST_AdmNo",
               COALESCE(a."AMCST_FirstName",'''') || '' '' || COALESCE(a."AMCST_MiddleName",'''') || '' '' || COALESCE(a."AMCST_LastName",'''') as "AMCST_Name",
               sport."SPCCMSCC_SportsCCName",
               sport."SPCCMSCC_Id",
               AMC."AMCO_CourseName",
               MB."AMB_BranchName",
               AMSE."AMSE_SEMName",
               d."ACMS_SectionName",
               e."SPCCESTRC_Points",
               e."SPCCESTRC_Rank",
               f."SPCCE_StartDate",
               EV."SPCCMEV_EventVenue",
               g."SPCCME_EventName",
               l."SPCCMH_HouseName",
               AMC."AMCO_Id",
               MB."AMB_Id",
               AMSE."AMSE_Id",
               d."ACMS_Id",
               g."SPCCME_Id",
               f."SPCCE_Id",
               a."AMCST_Id",
               Yr."ASMAY_Year"
        FROM "CLG"."Adm_Master_College_Student" a 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" YS ON YS."AMCST_Id" = a."AMCST_Id" AND YS."ACYST_ActiveFlag" = 1 AND a."AMCST_ActiveFlag" = 1 AND a."AMCST_SOL" = ''S''
        INNER JOIN "CLG"."Adm_Master_Course" AMC ON YS."AMCO_Id" = AMC."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id" = YS."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id" = YS."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" d ON YS."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Events_Students_Record_College" e ON e."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "SPC"."SPCC_Student_House_College" j ON j."AMCST_Id" = a."AMCST_Id" AND j."AMCO_Id" = YS."AMCO_Id" AND j."AMB_Id" = YS."AMB_Id" AND j."AMSE_Id" = YS."AMSE_Id" AND j."ACMS_Id" = YS."ACMS_Id" AND j."ASMAY_Id" = YS."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Events_Students" ES ON ES."SPCCEST_Id" = e."SPCCEST_Id" AND YS."ASMAY_Id" = ES."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_Events" g ON g."SPCCME_Id" = ES."SPCCME_Id"
        INNER JOIN "SPC"."SPCC_Events" f ON f."SPCCME_Id" = ES."SPCCME_Id" AND f."ASMAY_Id" = ES."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_EventVenue" EV ON EV."SPCCMEV_Id" = f."SPCCMEV_Id"
        INNER JOIN "SPC"."SPCC_Master_House" l ON l."SPCCMH_Id" = j."SPCCMH_Id"
        INNER JOIN "SPC"."SPCC_Master_SportsCCName" sport ON ES."SPCCMSCC_Id" = sport."SPCCMSCC_Id"
        INNER JOIN "Adm_School_M_Academic_Year" Yr ON Yr."ASMAY_Id" = YS."ASMAY_Id"
        WHERE a."MI_Id" = ' || "p_MI_Id" || ' AND YS."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND YS."AMCO_Id" = ' || "p_AMCO_Id" || '
        AND YS."AMB_Id" = ' || "p_AMB_Id" || '
        AND YS."AMSE_Id" IN (' || "p_AMSE_Id" || ') AND YS."ACMS_Id" IN (' || "p_ACMS_Id" || ') AND g."SPCCME_Id" IN (' || "p_SPCCME_Id" || ') AND ES."SPCCMSCC_Id" IN (' || "p_SPCCMSCC_Id" || ') AND e."SPCCESTRC_Rank" <= 3';

        RETURN QUERY EXECUTE v_dynamicsql;

    END IF;

    RETURN;

END;
$$;