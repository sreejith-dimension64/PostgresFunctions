CREATE OR REPLACE FUNCTION "dbo"."CLG_Sports_VenuewiseParticipation_Report"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "AMCO_Id" bigint,
    "AMB_Id" bigint,
    "AMSE_Id" text,
    "ACMS_Id" text,
    "SPCCMEV_Id" text,
    "Type" varchar(50),
    "SPCCMH_Id" text
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    sqldynamic text;
BEGIN

    IF "Type" = 'House' THEN
    
        sqldynamic := 'SELECT DISTINCT "AMCST_AdmNo", ' ||
                      'COALESCE("a"."AMCST_FirstName", '''') || '' '' || COALESCE("a"."AMCST_MiddleName", '''') || ''  '' || COALESCE("a"."AMCST_LastName", '''') AS "AMCST_Name", ' ||
                      '"AMC"."AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "d"."ACMS_SectionName", "e"."SPCCESTRC_Points", "e"."SPCCESTRC_Rank", "f"."SPCCE_StartDate", "EV"."SPCCMEV_EventVenue", ' ||
                      '"g"."SPCCME_EventName", "l"."SPCCMH_HouseName", "g"."SPCCME_Id", "a"."AMCST_Id", "l"."SPCCMH_Id", "sp"."SPCCMSCC_SportsCCName", "Yr"."ASMAY_Year" ' ||
                      'FROM "CLG"."Adm_Master_College_Student" "a" ' ||
                      'INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "YS" ON "YS"."AMCST_Id" = "SSH"."AMCST_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Student_House_College" "j" ON "j"."AMCST_Id" = "YS"."AMCST_Id" AND "j"."AMCO_Id" = "YS"."AMCO_Id" AND "j"."AMB_Id" = "YS"."AMB_Id" AND "j"."AMSE_Id" = "YS"."AMSE_Id" AND "j"."ACMS_Id" = "b"."ACMS_Id" AND "j"."ASMAY_Id" = "YS"."ASMAY_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Events_Students_Record_College" "e" ON "e"."AMCST_Id" = "j"."AMCST_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Events_Students" "ES" ON "ES"."SPCCEST_Id" = "e"."SPCCEST_Id" AND "B"."ASMAY_Id" = "ES"."ASMAY_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_Events" "g" ON "g"."SPCCME_Id" = "es"."SPCCME_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Events" "f" ON "f"."SPCCME_Id" = "es"."SPCCME_Id" AND "f"."ASMAY_Id" = "Es"."ASMAY_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_EventVenue" "EV" ON "EV"."SPCCMEV_Id" = "f"."SPCCMEV_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_House" "l" ON "l"."SPCCMH_Id" = "j"."SPCCMH_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_SportsCCName" "sport" ON "ES"."SPCCMSCC_Id" = "sport"."SPCCMSCC_Id" ' ||
                      'INNER JOIN "Adm_School_M_Academic_Year" "Yr" ON "Yr"."ASMAY_Id" = "b"."ASMAY_Id" ' ||
                      'WHERE "a"."MI_Id" = ' || "MI_Id"::varchar || ' AND "YS"."ASMAY_Id" = ' || "ASMAY_Id"::varchar || ' AND "l"."SPCCMH_Id" IN (' || "SPCCMH_Id" || ') AND "Ev"."SPCCMEV_Id" IN (' || "SPCCMEV_Id" || ')';

        EXECUTE sqldynamic;
    
    ELSIF "Type" = 'CS' THEN
    
        sqldynamic := 'SELECT DISTINCT "AMCST_AdmNo", ' ||
                      'COALESCE("a"."AMCST_FirstName", '''') || ''  '' || COALESCE("a"."AMCST_MiddleName", '''') || ''  '' || COALESCE("a"."AMCST_LastName", '''') AS "AMCST_Name", ' ||
                      '"AMC"."AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "d"."ACMS_SectionName", "e"."SPCCESTRC_Points", "e"."SPCCESTRC_Rank", "f"."SPCCE_StartDate", "EV"."SPCCMEV_EventVenue", ' ||
                      '"g"."SPCCME_EventName", "l"."SPCCMH_HouseName", "g"."SPCCME_Id", "a"."AMCST_Id", "l"."SPCCMH_Id", "sp"."SPCCMSCC_SportsCCName", "Yr"."ASMAY_Year" ' ||
                      'FROM "CLG"."Adm_Master_College_Student" "a" ' ||
                      'INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "YS" ON "YS"."AMCST_Id" = "SSH"."AMCST_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Student_House_College" "j" ON "j"."AMCST_Id" = "YS"."AMCST_Id" AND "j"."AMCO_Id" = "YS"."AMCO_Id" AND "j"."AMB_Id" = "YS"."AMB_Id" AND "j"."AMSE_Id" = "YS"."AMSE_Id" AND "j"."ACMS_Id" = "b"."ACMS_Id" AND "j"."ASMAY_Id" = "YS"."ASMAY_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Events_Students_Record_College" "e" ON "e"."AMCST_Id" = "j"."AMCST_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Events_Students" "ES" ON "ES"."SPCCEST_Id" = "e"."SPCCEST_Id" AND "B"."ASMAY_Id" = "ES"."ASMAY_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_Events" "g" ON "g"."SPCCME_Id" = "es"."SPCCME_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Events" "f" ON "f"."SPCCME_Id" = "es"."SPCCME_Id" AND "f"."ASMAY_Id" = "Es"."ASMAY_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_EventVenue" "EV" ON "EV"."SPCCMEV_Id" = "f"."SPCCMEV_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_House" "l" ON "l"."SPCCMH_Id" = "j"."SPCCMH_Id" ' ||
                      'INNER JOIN "SPC"."SPCC_Master_SportsCCName" "sport" ON "ES"."SPCCMSCC_Id" = "sport"."SPCCMSCC_Id" ' ||
                      'INNER JOIN "Adm_School_M_Academic_Year" "Yr" ON "Yr"."ASMAY_Id" = "b"."ASMAY_Id" ' ||
                      'WHERE "a"."MI_Id" = ' || "MI_Id"::varchar || ' AND "b"."ASMAY_Id" = ' || "ASMAY_Id"::varchar || ' AND "YS"."AMB_Id" = ' || "AMB_Id"::varchar ||
                      ' AND "YS"."AMB_Id" IN (' || "AMSE_Id" || ') AND "YS"."ACMS_Id" IN (' || "ACMS_Id" || ') AND "Ev"."SPCCMEV_Id" IN (' || "SPCCMEV_Id" || ') AND "l"."SPCCMH_Id" IN (' || "SPCCMH_Id" || ')';

        EXECUTE sqldynamic;
    
    END IF;

END;
$$;