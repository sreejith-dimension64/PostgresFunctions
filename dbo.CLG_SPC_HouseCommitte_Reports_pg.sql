CREATE OR REPLACE FUNCTION "dbo"."CLG_SPC_HouseCommitte_Reports"(
    "p_MI_Id" bigint,
    "p_ASMAY_Id" bigint,
    "p_SPCCMH_Id" text
)
RETURNS TABLE(
    "spccmH_HouseName" varchar,
    "asmaY_Year" varchar,
    "amcsT_AdmNo" varchar,
    "studentname" text,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "AMSE_SEMName" varchar,
    "ACMS_SectionName" varchar,
    "spccmhD_DesignationName" varchar,
    "spccmhC_ContactNo" varchar,
    "spccmhC_EmailId" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqldynamic" text;
BEGIN

    "v_sqldynamic" := '
    SELECT DISTINCT c."SPCCMH_HouseName" as "spccmH_HouseName",
        y."ASMAY_Year" as "asmaY_Year",
        "AMCST_AdmNo" as "amcsT_AdmNo",
        COALESCE(a."AMCST_FirstName",'''') || ''  '' || COALESCE(a."AMCST_MiddleName",'''') || ''  '' || COALESCE(a."AMCST_LastName",'''') as studentname,
        "AMCO_CourseName" as "AMCO_CourseName",
        "AMB_BranchName",
        "AMSE_SEMName",
        MS."ACMS_SectionName" as "ACMS_SectionName",
        "SPCCMHD_DesignationName" AS "spccmhD_DesignationName",
        "AMCST_MobileNo" as "spccmhC_ContactNo",
        "AMST_emailId" as "spccmhC_EmailId"
    FROM "CLG"."Adm_Master_College_Student" a
    INNER JOIN "SPC"."SPCC_Master_House_Committe_Collge" HC ON a."AMCST_Id"=HC."AMCST_Id" and "SPCCMHD_ActiveFlag"=1 
    INNER JOIN "SPC"."SPCC_Student_House_College" SSH ON SSH."SPCCMH_Id"=HC."SPCCMH_Id" and SSH."AMCST_Id"=HC."AMCST_Id" and SSH."MI_Id"=' || "p_MI_Id"::text || ' and SSH."SPCCMHC_ActiveFlag"=1
    INNER JOIN "SPC"."SPCC_Master_House" c on a."MI_Id"=c."MI_Id" and HC."SPCCMH_Id"=c."SPCCMH_Id"
    INNER JOIN "SPC"."SPCC_Master_House_Designation" SHD ON SHD."SPCCMHD_Id"=HC."SPCCMHD_Id" and SHD."MI_Id"=' || "p_MI_Id"::text || ' and SHD."SPCCMHD_ActiveFlag"=1
    INNER JOIN "CLG"."Adm_College_Yearly_Student" as YS ON YS."AMCST_Id" = SSH."AMCST_Id" and YS."ASMAY_Id"=SSH."ASMAY_Id" and YS."AMCO_Id"=SSH."AMCO_Id" and YS."AMB_Id"=SSH."AMB_Id" and YS."AMSE_Id"=SSH."AMSE_Id" and YS."ACMS_Id"=SSH."ACMS_Id" and YS."ACYST_ActiveFlag"=1 and a."AMCST_ActiveFlag"=1 and a."AMCST_SOL"=''S''  
    INNER JOIN "CLG"."Adm_Master_Course" MC ON YS."AMCO_Id"=MC."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id"=YS."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."AMSE_Id"=YS."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" MS ON YS."ACMS_Id"=MS."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" Yer On Yer."ASMAY_Id"=YS."ASMAY_Id"
    WHERE a."MI_Id"=' || "p_MI_Id"::text || ' and SSH."asmay_id"=' || "p_ASMAY_Id"::text || ' and SSH."SPCCMH_Id" IN (' || "p_SPCCMH_Id" || ')';

    RETURN QUERY EXECUTE "v_sqldynamic";

END;
$$;