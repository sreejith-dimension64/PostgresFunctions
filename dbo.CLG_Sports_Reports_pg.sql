CREATE OR REPLACE FUNCTION "dbo"."CLG_Sports_Reports"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint,
    p_ACMS_Id bigint,
    p_SPCCME_Id bigint,
    p_Type varchar(50),
    p_SPCCMH_Id bigint
)
RETURNS TABLE(
    "AMCST_AdmNo" varchar,
    "AMCST_Name" text,
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
    "SPCCME_Id" bigint,
    "AMCST_Id" bigint,
    "SPCCMH_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

IF p_Type = 'House' THEN

RETURN QUERY
SELECT DISTINCT a."AMCST_AdmNo",
COALESCE(a."AMCST_FirstName",'') || ' ' || COALESCE(a."AMCST_MiddleName",'') || ' ' || COALESCE(a."AMCST_LastName",'') as "AMCST_Name",
MC."AMCO_CourseName",
MB."AMB_BranchName",
AMSE."AMSE_SEMName",
MS."ACMS_SectionName",
e."SPCCESTRC_Points",
e."SPCCESTRC_Rank",
f."SPCCE_StartDate",
EV."SPCCMEV_EventVenue",
g."SPCCME_EventName",
l."SPCCMH_HouseName",
g."SPCCME_Id",
a."AMCST_Id",
l."SPCCMH_Id"
FROM "CLG"."Adm_Master_College_Student" a 
INNER JOIN "CLG"."Adm_College_Yearly_Student" YS ON a."AMCST_Id"=YS."AMCST_Id"
INNER JOIN "CLG"."Adm_Master_Course" MC ON YS."AMCO_Id"=MC."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id"=YS."AMB_Id"
INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id"=YS."AMSE_Id"
INNER JOIN "CLG"."Adm_College_Master_Section" MS ON YS."ACMS_Id"=MS."ACMS_Id"
INNER JOIN "SPC"."SPCC_Events_Students_Record_College" e ON e."AMCST_Id"=a."AMCST_Id"
INNER JOIN "SPC"."SPCC_Events_Students" ES ON ES."SPCCEST_Id"=e."SPCCEST_Id"
INNER JOIN "SPC"."SPCC_Master_Events" g ON g."SPCCME_Id"=ES."SPCCME_Id"
INNER JOIN "SPC"."SPCC_Events" f ON f."SPCCME_Id"=ES."SPCCME_Id"
INNER JOIN "SPC"."SPCC_Master_EventVenue" EV ON EV."SPCCMEV_Id"=f."SPCCMEV_Id"
INNER JOIN "SPC"."SPCC_Student_House_college" j ON j."AMCST_Id" = a."AMCST_Id"
INNER JOIN "SPC"."SPCC_Master_House" l ON l."SPCCMH_Id" = j."SPCCMH_Id"
WHERE a."MI_Id"=p_MI_Id AND YS."ASMAY_Id"=p_ASMAY_Id AND l."SPCCMH_Id"=p_SPCCMH_Id AND g."SPCCME_Id" = p_SPCCME_Id;

ELSIF p_Type = 'CS' THEN

RETURN QUERY
SELECT DISTINCT a."AMCST_AdmNo",
COALESCE(a."AMCST_FirstName",'') || ' ' || COALESCE(a."AMCST_MiddleName",'') || ' ' || COALESCE(a."AMCST_LastName",'') as "AMCST_Name",
MC."AMCO_CourseName",
MB."AMB_BranchName",
AMSE."AMSE_SEMName",
MS."ACMS_SectionName",
e."SPCCESTRC_Points",
e."SPCCESTRC_Rank",
f."SPCCE_StartDate",
EV."SPCCMEV_EventVenue",
g."SPCCME_EventName",
l."SPCCMH_HouseName",
g."SPCCME_Id",
a."AMCST_Id",
l."SPCCMH_Id"
FROM "CLG"."Adm_Master_College_Student" a 
INNER JOIN "CLG"."Adm_College_Yearly_Student" YS ON a."AMCST_Id"=YS."AMCST_Id"
INNER JOIN "CLG"."Adm_Master_Course" MC ON YS."AMCO_Id"=MC."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id"=YS."AMB_Id"
INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id"=YS."AMSE_Id"
INNER JOIN "CLG"."Adm_College_Master_Section" MS ON YS."ACMS_Id"=MS."ACMS_Id"
INNER JOIN "SPC"."SPCC_Events_Students_Record_College" e ON e."AMCST_Id"=a."AMCST_Id"
INNER JOIN "SPC"."SPCC_Events_Students" ES ON ES."SPCCEST_Id"=e."SPCCEST_Id"
INNER JOIN "SPC"."SPCC_Master_Events" g ON g."SPCCME_Id"=ES."SPCCME_Id"
INNER JOIN "SPC"."SPCC_Events" f ON f."SPCCME_Id"=ES."SPCCME_Id"
INNER JOIN "SPC"."SPCC_Master_EventVenue" EV ON EV."SPCCMEV_Id"=f."SPCCMEV_Id"
INNER JOIN "SPC"."SPCC_Student_House_college" j ON j."AMCST_Id" = a."AMCST_Id"
INNER JOIN "SPC"."SPCC_Master_House" l ON l."SPCCMH_Id" = j."SPCCMH_Id"
WHERE a."MI_Id"=p_MI_Id AND YS."ASMAY_Id"=p_ASMAY_Id AND YS."AMCO_Id" = p_AMCO_Id AND YS."AMB_Id" = p_AMB_Id AND YS."AMSE_Id"=p_AMSE_Id AND YS."ACMS_Id" = p_ACMS_Id AND g."SPCCME_Id" = p_SPCCME_Id;

END IF;

RETURN;

END;
$$;