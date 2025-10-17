CREATE OR REPLACE FUNCTION "dbo"."CLG_SPCC_SportPointsAndRecordReportCCWise"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_SPCCME_Id text,
    p_Type varchar(50),
    p_SPCCMH_Id text,
    p_SPCCMSCC_Id text,
    p_SPCCESTR_Rank text,
    p_SPCCMCC_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
    v_context text;
BEGIN

    -- EXEC CLG_SPCC_SportPointsAndRecordReportCCWise 4,11,'0,98','CC','0,61','0,12','1,2','31'

    IF p_SPCCMSCC_Id != '' AND p_SPCCESTR_Rank != '' THEN
        v_context := ' and ES."SPCCMSCC_Id" IN (' || p_SPCCMSCC_Id || ') and e."SPCCESTR_Rank" IN (' || p_SPCCESTR_Rank || ') ';
    ELSE
        v_context := '';
    END IF;

    IF p_Type = 'CC' THEN
        v_sqldynamic := 'select distinct "AMCST_AdmNo", COALESCE(a."AMCST_FirstName",'''') || ''  '' || COALESCE(a."AMCST_MiddleName",'''') || ''  '' || COALESCE(a."AMCST_LastName",'''') as "AMCST_Name",
MC."AMCO_CourseName", MB."AMB_BranchName", AMSE."AMSE_SEMName", MS."ACMS_SectionName", e."SPCCESTRC_Points", e."SPCCESTR_Rank", f."SPCCE_StartDate", EV."SPCCMEV_EventVenue", 
g."SPCCME_EventName", l."SPCCMH_HouseName", MC."AMCO_Id", MB."AMB_Id", AMSE."AMSE_Id", d."ACMS_Id", g."SPCCME_Id", a."AMCST_Id", sport."SPCCMSCC_SportsCCName", sport."SPCCMSCC_Id", Yr."ASMAY_Year", e."SPCCESTRC_Remarks"

FROM "CLG"."Adm_Master_College_Student" a 
INNER JOIN "CLG"."Adm_College_Yearly_Student" as YS ON YS."AMCST_Id" = a."AMCST_Id" 
INNER JOIN "CLG"."Adm_Master_Course" MC ON YS."AMCO_Id" = MC."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id" = YS."AMB_Id"
INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id" = YS."AMSE_Id"
INNER JOIN "CLG"."Adm_College_Master_Section" MS ON YS."ACMS_Id" = MS."ACMS_Id"
INNER JOIN "SPC"."SPCC_Student_House_College" j on j."AMCST_Id" = YS."AMCST_Id" And j."AMCO_Id" = YS."AMCO_Id" and j."AMB_Id" = YS."AMB_Id" and j."AMSE_Id" = YS."AMSE_Id" and j."ACMS_Id" = YS."ACMS_Id" and j."ASMAY_Id" = YS."ASMAY_Id"
INNER JOIN "SPC"."SPCC_Events_Students_Record_College" e on e."AMCST_Id" = j."AMCST_Id"
INNER JOIN "SPC"."SPCC_Events_Students" ES on ES."SPCCEST_Id" = e."SPCCEST_Id" And YS."ASMAY_Id" = ES."ASMAY_Id" 
INNER JOIN "SPC"."SPCC_Master_Events" g on g."SPCCME_Id" = ES."SPCCME_Id"
INNER JOIN "SPC"."SPCC_Events" f on f."SPCCME_Id" = ES."SPCCME_Id" and f."ASMAY_Id" = ES."ASMAY_Id" and f."MI_Id" = ' || p_MI_Id::varchar || ' and f."SPCCE_ActiveFlag" = 1
INNER JOIN "SPC"."SPCC_Master_EventVenue" EV ON EV."SPCCMEV_Id" = f."SPCCMEV_Id" and EV."SPCCMEV_ActiveFlag" = 1
INNER JOIN "SPC"."SPCC_Master_House" l on l."SPCCMH_Id" = j."SPCCMH_Id"
INNER JOIN "SPC"."SPCC_Master_SportsCCName" sport on ES."SPCCMSCC_Id" = sport."SPCCMSCC_Id"
INNER JOIN "Adm_School_M_Academic_Year" Yr On Yr."ASMAY_Id" = YS."ASMAY_Id"
WHERE a."MI_Id" = ' || p_MI_Id::varchar || ' and ES."ASMAY_Id" = ' || p_ASMAY_Id::varchar || ' and ES."SPCCMCC_Id" = ' || p_SPCCMCC_Id::varchar || ' and l."SPCCMH_Id" IN(' || p_SPCCMH_Id || ') and (g."SPCCME_Id" IN (' || p_SPCCME_Id || ') ' || v_context || ' ) order by e."SPCCESTR_Rank"';

        EXECUTE v_sqldynamic;
    END IF;

    RETURN;
END;
$$;