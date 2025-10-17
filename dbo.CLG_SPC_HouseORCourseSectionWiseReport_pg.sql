CREATE OR REPLACE FUNCTION "dbo"."CLG_SPC_HouseORCourseSectionWiseReport"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_Type varchar(100),
    p_SPCCMH_Id text,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint,
    p_ACMS_Id text
)
RETURNS TABLE(
    "SPCCMH_HouseName" varchar,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "AMSE_SEMName" varchar,
    "ACMS_SectionName" varchar,
    "AMCST_Id" bigint,
    "AMCST_Name" text,
    "AMCST_AdmNo" varchar,
    "ACYST_RollNo" varchar,
    "ASMAY_Year" varchar,
    "AMCST_MobileNo" varchar,
    "AMCST_emailId" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamicsql text;
BEGIN
    IF(p_Type='House') THEN
        v_dynamicsql := '
        SELECT DISTINCT H."SPCCMH_HouseName", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", SE."ACMS_SectionName", ST."AMCST_Id",
        COALESCE("AMCST_FirstName",'''')||'' ''||COALESCE("AMCST_MiddleName",'''')||'' ''||COALESCE("AMCST_LastName",'''') AS "AMCST_Name",
        ST."AMCST_AdmNo", Y."ACYST_RollNo", Yr."ASMAY_Year", ST."AMCST_MobileNo", ST."AMCST_emailId"
        FROM "SPC"."SPCC_Student_House_College" SSH 
        INNER JOIN "SPC"."SPCC_Master_House" H ON H."SPCCMH_Id"=SSH."SPCCMH_Id" and H."MI_Id"=' || p_MI_Id::varchar || ' and H."SPCCMH_ActiveFlag"=true
        INNER JOIN "CLG"."Adm_Master_College_Student" ST ON SSH."AMCST_Id"=ST."AMCST_Id" and ST."AMCST_SOL"=''S'' and ST."AMCST_ActiveFlag"=true
        INNER JOIN "CLG"."Adm_College_Yearly_Student" YS ON YS."AMCST_Id" = SSH."AMCST_Id" and YS."AMCO_Id"=SSH."AMCO_Id" and YS."AMB_Id"=SSH."AMB_Id" and YS."AMSE_Id"=SSH."AMSE_Id" and YS."ACMS_Id"=SSH."ACMS_Id" and YS."ACYST_ActiveFlag"=true  
        INNER JOIN "CLG"."Adm_Master_Course" MC ON MC."AMCO_Id"=YS."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id"=YS."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id"=YS."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" SE ON YS."ACMS_Id"=SE."ACMS_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" Y ON Y."AMCST_Id"=SSH."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" Yr ON Yr."ASMAY_Id"=YS."ASMAY_Id"
        WHERE SSH."MI_Id"=' || p_MI_Id::varchar || ' and SSH."ASMAY_Id"=' || p_ASMAY_Id::varchar || ' and H."SPCCMH_Id" IN (' || p_SPCCMH_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamicsql;
        
    ELSIF(p_Type='CS') THEN
        v_dynamicsql := '
        SELECT DISTINCT H."SPCCMH_HouseName", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", SE."ACMS_SectionName", SSH."AMCST_Id",
        COALESCE("AMCST_FirstName",'''')||'' ''||COALESCE("AMCST_MiddleName",'''')||'' ''||COALESCE("AMCST_LastName",'''') AS "AMCST_Name",
        ST."AMCST_AdmNo", Y."ACYST_RollNo", Yr."ASMAY_Year", ST."AMCST_MobileNo", ST."AMCST_emailId"
        FROM "SPC"."SPCC_Student_House_College" SSH 
        INNER JOIN "SPC"."SPCC_Master_House" H ON H."SPCCMH_Id"=SSH."SPCCMH_Id" and H."MI_Id"=' || p_MI_Id::varchar || ' and H."SPCCMH_ActiveFlag"=true
        INNER JOIN "CLG"."Adm_Master_College_Student" ST ON SSH."AMCST_Id"=ST."AMCST_Id" and ST."AMCST_SOL"=''S'' and ST."AMCST_ActiveFlag"=true
        INNER JOIN "CLG"."Adm_College_Yearly_Student" YS ON YS."AMCST_Id" = SSH."AMCST_Id" and YS."AMCO_Id"=SSH."AMCO_Id" and YS."AMB_Id"=SSH."AMB_Id" and YS."AMSE_Id"=SSH."AMSE_Id" and YS."ACMS_Id"=SSH."ACMS_Id" and YS."ACYST_ActiveFlag"=true 
        INNER JOIN "CLG"."Adm_Master_Course" MC ON MC."AMCO_Id"=YS."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id"=YS."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id"=YS."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" SE ON YS."ACMS_Id"=SE."ACMS_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" Y ON Y."AMCST_Id"=SSH."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" Yr ON Yr."ASMAY_Id"=YS."ASMAY_Id"
        WHERE H."MI_Id"=' || p_MI_Id::varchar || ' and ST."ASMAY_Id"=' || p_ASMAY_Id::varchar || ' and SSH."AMCO_Id"=' || p_AMCO_Id::varchar || '
        and SSH."AMB_Id"=' || p_AMB_Id::varchar || ' and SSH."AMSE_Id"=' || p_AMSE_Id::varchar || ' and ST."ACMS_Id" IN (' || p_ACMS_Id || ') and H."SPCCMH_Id" IN (' || p_SPCCMH_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamicsql;
        
    END IF;
    
    RETURN;
END;
$$;