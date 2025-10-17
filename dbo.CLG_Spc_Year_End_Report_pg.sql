CREATE OR REPLACE FUNCTION "dbo"."CLG_Spc_Year_End_Report"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id text,
    p_AMB_Id text,
    p_AMSE_Id text,
    p_ACMS_Id text,
    p_Type varchar(50)
)
RETURNS TABLE(
    "admNo" varchar,
    "studentName" text,
    "AMCO_Id" bigint,
    "AMCO_CourseName" varchar,
    "AMB_Id" bigint,
    "AMSE_Id" bigint,
    "ACMS_Id" bigint,
    "sectionName" varchar,
    "points" numeric,
    "spccestR_Rank" integer,
    "asmaY_Year" varchar,
    "ASMAY_Id" bigint,
    "houseName" varchar,
    "spccmE_EventName" varchar,
    "spccmeV_EventVenue" varchar,
    "spccmscC_SportsCCName" varchar,
    "spccE_StartDate" timestamp,
    "spccE_EndDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
BEGIN

    IF p_Type = 'AY' THEN
    
        v_sqldynamic := '
        SELECT DISTINCT "SSH"."AMCST_AdmNo" as "admNo",
        COALESCE("SSH"."AMCST_FirstName", '''') || ''  '' || COALESCE("SSH"."AMCST_MiddleName", '''') || ''  '' || COALESCE("SSH"."AMCST_LastName", '''') as "studentName",
        "YS"."AMCO_Id",
        "MC"."AMCO_CourseName" as "AMCO_CourseName",
        "MB"."AMB_Id",
        "AMSE"."AMSE_Id",
        "MS"."ACMS_Id",
        "MS"."ACMS_SectionName" as "sectionName",
        "SR"."SPCCESTRC_Points" as "points",
        "SR"."SPCCESTRC_Rank" as "spccestR_Rank",
        "Yr"."ASMAY_Year" as "asmaY_Year",
        "YS"."ASMAY_Id",
        "l"."SPCCMH_HouseName" as "houseName",
        "g"."SPCCME_EventName" as "spccmE_EventName",
        "EV"."SPCCMEV_EventVenue" as "spccmeV_EventVenue",
        "sport"."SPCCMSCC_SportsCCName" As "spccmscC_SportsCCName",
        "f"."SPCCE_StartDate" as "spccE_StartDate",
        "f"."SPCCE_EndDate" as "spccE_EndDate"
        
        FROM "CLG"."Adm_Master_College_Student" "SSH"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "SSH"."AMCST_Id" 
            AND "YS"."ACYST_ActiveFlag" = 1 AND "SSH"."AMCST_ActiveFlag" = 1 AND "SSH"."AMCST_SOL" = ''S''
        INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Student_House_College" "j" ON "j"."AMCST_Id" = "YS"."AMCST_Id" 
            AND "j"."AMCO_Id" = "YS"."AMCO_Id" AND "j"."AMB_Id" = "YS"."AMB_Id" 
            AND "j"."AMSE_Id" = "YS"."AMSE_Id" AND "j"."ACMS_Id" = "YS"."ACMS_Id" 
            AND "j"."ASMAY_Id" = "YS"."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Events_Students_Record_College" "e" ON "e"."AMCST_Id" = "j"."AMCST_Id"
        INNER JOIN "SPC"."SPCC_Events_Students" "ES" ON "ES"."SPCCEST_Id" = "e"."SPCCEST_Id" 
            AND "YS"."ASMAY_Id" = "ES"."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_Events" "g" ON "g"."SPCCME_Id" = "ES"."SPCCME_Id"
        INNER JOIN "SPC"."SPCC_Events" "f" ON "f"."SPCCME_Id" = "ES"."SPCCME_Id" 
            AND "f"."ASMAY_Id" = "ES"."ASMAY_Id" AND "f"."MI_Id" = ' || p_MI_Id || ' 
            AND "f"."SPCCE_ActiveFlag" = 1
        INNER JOIN "SPC"."SPCC_Master_EventVenue" "EV" ON "EV"."SPCCMEV_Id" = "f"."SPCCMEV_Id" 
            AND "EV"."SPCCMEV_ActiveFlag" = 1
        INNER JOIN "SPC"."SPCC_Master_House" "l" ON "l"."SPCCMH_Id" = "j"."SPCCMH_Id"
        INNER JOIN "SPC"."SPCC_Master_SportsCCName" "sport" ON "ES"."SPCCMSCC_Id" = "sport"."SPCCMSCC_Id"
        LEFT JOIN "SPC"."SPCC_Events_Students_Record_College" "SR" ON "SR"."AMCST_Id" = "SSH"."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "Yr" ON "Yr"."ASMAY_Id" = "YS"."ASMAY_Id"
        WHERE "ES"."MI_Id" = ' || p_MI_Id || ' AND "ES"."ASMAY_Id" = ' || p_ASMAY_Id;
        
        RETURN QUERY EXECUTE v_sqldynamic;
        
    ELSIF p_Type = 'CS' THEN
    
        v_sqldynamic := '
        SELECT DISTINCT "SSH"."AMCST_AdmNo" as "admNo",
        COALESCE("SSH"."AMCST_FirstName", '''') || ''  '' || COALESCE("SSH"."AMCST_MiddleName", '''') || ''  '' || COALESCE("SSH"."AMCST_LastName", '''') as "studentName",
        "YS"."AMCO_Id",
        "MC"."AMCO_CourseName" as "AMCO_CourseName",
        "MB"."AMB_Id",
        "AMSE"."AMSE_Id",
        "MS"."ACMS_Id",
        "MS"."ACMS_SectionName" as "sectionName",
        "SR"."SPCCESTRC_Points" as "points",
        "SR"."SPCCESTRC_Rank" as "spccestR_Rank",
        "Yr"."ASMAY_Year" as "asmaY_Year",
        "YS"."ASMAY_Id",
        "l"."SPCCMH_HouseName" as "houseName",
        "g"."SPCCME_EventName" as "spccmE_EventName",
        "EV"."SPCCMEV_EventVenue" as "spccmeV_EventVenue",
        "sport"."SPCCMSCC_SportsCCName" As "spccmscC_SportsCCName",
        "f"."SPCCE_StartDate" as "spccE_StartDate",
        "f"."SPCCE_EndDate" as "spccE_EndDate"
        
        FROM "CLG"."Adm_Master_College_Student" "SSH"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "SSH"."AMCST_Id" 
            AND "YS"."ACYST_ActiveFlag" = 1 AND "SSH"."AMCST_ActiveFlag" = 1 AND "SSH"."AMCST_SOL" = ''S''
        INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
        INNER JOIN "SPC"."SPCC_Student_House_College" "j" ON "j"."AMCST_Id" = "YS"."AMCST_Id" 
            AND "j"."AMCO_Id" = "YS"."AMCO_Id" AND "j"."AMB_Id" = "YS"."AMB_Id" 
            AND "j"."AMSE_Id" = "YS"."AMSE_Id" AND "j"."ACMS_Id" = "YS"."ACMS_Id" 
            AND "j"."ASMAY_Id" = "YS"."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Events_Students_Record_College" "e" ON "e"."AMCST_Id" = "j"."AMCST_Id"
        INNER JOIN "SPC"."SPCC_Events_Students" "ES" ON "ES"."SPCCEST_Id" = "e"."SPCCEST_Id" 
            AND "YS"."ASMAY_Id" = "ES"."ASMAY_Id"
        INNER JOIN "SPC"."SPCC_Master_Events" "g" ON "g"."SPCCME_Id" = "ES"."SPCCME_Id"
        INNER JOIN "SPC"."SPCC_Events" "f" ON "f"."SPCCME_Id" = "ES"."SPCCME_Id" 
            AND "f"."ASMAY_Id" = "ES"."ASMAY_Id" AND "f"."MI_Id" = ' || p_MI_Id || ' 
            AND "f"."SPCCE_ActiveFlag" = 1
        INNER JOIN "SPC"."SPCC_Master_EventVenue" "EV" ON "EV"."SPCCMEV_Id" = "f"."SPCCMEV_Id" 
            AND "EV"."SPCCMEV_ActiveFlag" = 1
        INNER JOIN "SPC"."SPCC_Master_House" "l" ON "l"."SPCCMH_Id" = "j"."SPCCMH_Id"
        INNER JOIN "SPC"."SPCC_Master_SportsCCName" "sport" ON "ES"."SPCCMSCC_Id" = "sport"."SPCCMSCC_Id"
        LEFT JOIN "SPC"."SPCC_Events_Students_Record_College" "SR" ON "SR"."AMCST_Id" = "SSH"."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "Yr" ON "Yr"."ASMAY_Id" = "YS"."ASMAY_Id"
        WHERE "ES"."MI_Id" = ' || p_MI_Id || ' AND "ES"."ASMAY_Id" = ' || p_ASMAY_Id || '
        AND "YS"."AMCO_Id" IN (' || p_AMCO_Id || ') 
        AND "YS"."AMB_Id" IN (' || p_AMB_Id || ') 
        AND "YS"."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND "YS"."ACMS_Id" IN (' || p_ACMS_Id || ')';
        
        RETURN QUERY EXECUTE v_sqldynamic;
        
    END IF;
    
    RETURN;
    
END;
$$;