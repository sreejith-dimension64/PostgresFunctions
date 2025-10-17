CREATE OR REPLACE FUNCTION "dbo"."CLG_SPCC_SportPointsAndRecordReport"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id text,
    p_ACMS_Id text,
    p_SPCCME_Id text,
    p_Type varchar(50),
    p_SPCCMH_Id text,
    p_SPCCMSCC_Id text
)
RETURNS TABLE(
    "AMCST_AdmNo" varchar,
    "AMCST_Name" text,
    "AMCO_CourseName" varchar,
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
    "AMCST_Id" bigint,
    "SPCCMSCC_SportsCCName" varchar,
    "SPCCMSCC_Id" bigint,
    "ASMAY_Year" varchar,
    "SPCCESTRC_Remarks" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
    v_context text;
BEGIN

    IF p_SPCCMSCC_Id != '' THEN
        v_context := ' and "ES"."SPCCMSCC_Id" IN (' || p_SPCCMSCC_Id || ') ';
    ELSE
        v_context := '';
    END IF;

    IF p_Type = 'House' THEN
        
        v_sqldynamic := 'select distinct "AMCST_AdmNo", COALESCE(a."AMCST_FirstName",'''') || ''  '' || COALESCE(a."AMCST_MiddleName",'''') || ''  '' || COALESCE(a."AMCST_LastName",'''') as "AMCST_Name",
"MC"."AMCO_CourseName", "MS"."ACMS_SectionName", e."SPCCESTRC_Points", e."SPCCESTRC_Rank", f."SPCCE_StartDate", "EV"."SPCCMEV_EventVenue", 
g."SPCCME_EventName", l."SPCCMH_HouseName", "MC"."AMCO_Id", "MC"."AMB_Id", "MC"."AMSE_Id", "MS"."ACMS_Id", g."SPCCME_Id", a."AMCST_Id", sport."SPCCMSCC_SportsCCName", sport."SPCCMSCC_Id", "Yr"."ASMAY_Year", e."SPCCESTRC_Remarks"
FROM "CLG"."Adm_Master_College_Student" a 
INNER JOIN "CLG"."Adm_College_Yearly_Student" as "YS" ON "YS"."AMCST_Id" = "SSH"."AMCST_Id" 
INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
INNER JOIN "SPC"."SPCC_Student_House_College" j on j."AMCST_Id" = "YS"."AMCST_Id" And j."AMCO_Id" = "YS"."AMCO_Id" and j."AMB_Id" = "YS"."AMB_Id" and j."AMSE_Id" = "YS"."AMSE_Id" and j."ACMS_Id" = b."ACMS_Id" and j."ASMAY_Id" = "YS"."ASMAY_Id"
INNER JOIN "SPC"."SPCC_Events_Students_Record_College" e on e."AMCST_Id" = j."AMCST_Id"
INNER JOIN "SPC"."SPCC_Events_Students" "ES" on "ES"."SPCCEST_Id" = e."SPCCEST_Id" And "B"."ASMAY_Id" = "ES"."ASMAY_Id" 
INNER JOIN "SPC"."SPCC_Master_Events" g on g."SPCCME_Id" = es."SPCCME_Id"
INNER JOIN "SPC"."SPCC_Events" f on f."SPCCME_Id" = es."SPCCME_Id" and f."ASMAY_Id" = "Es"."ASMAY_Id" and "F"."MI_Id" = ' || p_MI_Id || ' and f."SPCCE_ActiveFlag" = 1
INNER JOIN "SPC"."SPCC_Master_EventVenue" "EV" ON "EV"."SPCCMEV_Id" = f."SPCCMEV_Id" and "EV"."SPCCMEV_ActiveFlag" = 1
INNER JOIN "SPC"."SPCC_Master_House" l on l."SPCCMH_Id" = j."SPCCMH_Id"
INNER JOIN "SPC"."SPCC_Master_SportsCCName" sport on "ES"."SPCCMSCC_Id" = sport."SPCCMSCC_Id"
INNER JOIN "Adm_School_M_Academic_Year" "Yr" On "Yr"."ASMAY_Id" = b."ASMAY_Id"
where a."MI_Id" = ' || p_MI_Id || ' and e."SPCCESTR_ActiveFlag" = 1 and es."SPCCEST_ActiveFlag" = 1 and "ES"."ASMAY_Id" = ' || p_ASMAY_Id || ' and l."SPCCMH_Id" IN(' || p_SPCCMH_Id || ') and (g."SPCCME_Id" IN (' || p_SPCCME_Id || ') ' || v_context || ')';

        RETURN QUERY EXECUTE v_sqldynamic;

    ELSIF p_Type = 'CS' THEN

        v_sqldynamic := 'select distinct "AMCST_AdmNo", COALESCE(a."AMCST_FirstName",'''') || ''  '' || COALESCE(a."AMCST_MiddleName",'''') || ''  '' || COALESCE(a."AMCST_LastName",'''') as "AMCST_Name",
"MC"."AMCO_CourseName", "MS"."ACMS_SectionName", e."SPCCESTRC_Points", e."SPCCESTRC_Rank", f."SPCCE_StartDate", "EV"."SPCCMEV_EventVenue", 
g."SPCCME_EventName", l."SPCCMH_HouseName", "MC"."AMCO_Id", "MC"."AMB_Id", "MC"."AMSE_Id", "MS"."ACMS_Id", g."SPCCME_Id", a."AMCST_Id", sport."SPCCMSCC_SportsCCName", sport."SPCCMSCC_Id", "Yr"."ASMAY_Year", e."SPCCESTRC_Remarks"
FROM "CLG"."Adm_Master_College_Student" a 
INNER JOIN "CLG"."Adm_College_Yearly_Student" as "YS" ON "YS"."AMCST_Id" = "SSH"."AMCST_Id" 
INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
INNER JOIN "SPC"."SPCC_Student_House_College" j on j."AMCST_Id" = "YS"."AMCST_Id" And j."AMCO_Id" = "YS"."AMCO_Id" and j."AMB_Id" = "YS"."AMB_Id" and j."AMSE_Id" = "YS"."AMSE_Id" and j."ACMS_Id" = b."ACMS_Id" and j."ASMAY_Id" = "YS"."ASMAY_Id"
INNER JOIN "SPC"."SPCC_Events_Students_Record_College" e on e."AMCST_Id" = j."AMCST_Id"
INNER JOIN "SPC"."SPCC_Events_Students" "ES" on "ES"."SPCCEST_Id" = e."SPCCEST_Id" And "B"."ASMAY_Id" = "ES"."ASMAY_Id" 
INNER JOIN "SPC"."SPCC_Master_Events" g on g."SPCCME_Id" = es."SPCCME_Id"
INNER JOIN "SPC"."SPCC_Events" f on f."SPCCME_Id" = es."SPCCME_Id" and f."ASMAY_Id" = "Es"."ASMAY_Id" and "F"."MI_Id" = ' || p_MI_Id || ' and f."SPCCE_ActiveFlag" = 1
INNER JOIN "SPC"."SPCC_Master_EventVenue" "EV" ON "EV"."SPCCMEV_Id" = f."SPCCMEV_Id" and "EV"."SPCCMEV_ActiveFlag" = 1
INNER JOIN "SPC"."SPCC_Master_House" l on l."SPCCMH_Id" = j."SPCCMH_Id"
INNER JOIN "SPC"."SPCC_Master_SportsCCName" sport on "ES"."SPCCMSCC_Id" = sport."SPCCMSCC_Id"
INNER JOIN "Adm_School_M_Academic_Year" "Yr" On "Yr"."ASMAY_Id" = b."ASMAY_Id"
where a."MI_Id" = ' || p_MI_Id || ' and e."SPCCESTR_ActiveFlag" = 1 and es."SPCCEST_ActiveFlag" = 1 and b."ASMAY_Id" = ' || p_ASMAY_Id || ' 
and "YS"."AMCO_Id" IN (' || p_AMCO_Id || ') and "YS"."AMB_Id" IN (' || p_AMB_Id || ') and "YS"."AMSE_Id" IN (' || p_AMSE_Id || ') and "YS"."ACMS_Id" IN (' || p_ACMS_Id || ') and (g."SPCCME_Id" IN (' || p_SPCCME_Id || ') ' || v_context || ')';

        RETURN QUERY EXECUTE v_sqldynamic;

    END IF;

    RETURN;

END;
$$;