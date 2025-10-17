CREATE OR REPLACE FUNCTION "dbo"."Collage_User_profileDetails"(
    "p_MI_Id" bigint,
    "p_usercode" bigint,
    "p_ASMAY_Id" bigint,
    "p_type" text
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "HRME_Photo" text,
    "emp_name" text,
    "HRME_EmployeeCode" text,
    "HRME_MobileNo" text,
    "HRMEMNO_MobileNo" text,
    "HRMEM_EmailId" text,
    "HRMD_DepartmentName" text,
    "HRMDES_DesignationName" text,
    "MI_Name" text,
    "MI_address" text,
    "AMCST_Id" bigint,
    "studentname" text,
    "fatherName" text,
    "mothername" text,
    "AMCO_Id" bigint,
    "AMCO_CourseName" text,
    "AMB_Id" bigint,
    "AMB_BranchName" text,
    "AMSE_SEMName" text,
    "ACMS_SectionName" text,
    "ASMAY_Id" bigint,
    "ASMAY_Year" text,
    "AMCST_AdmNo" text,
    "AMCST_DOB" timestamp,
    "AMCST_emailId" text,
    "AMCST_MobileNo" text,
    "AMCST_RegistrationNo" text,
    "AMCST_StudentPhoto" text,
    "AMCST_PerStreet" text,
    "AMCST_PerArea" text,
    "AMCST_PerCity" text,
    "ACYST_RollNo" text,
    "AMCST_Sex" text,
    "AMCST_FatherMobleNo" text,
    "AMCST_FatheremailId" text,
    "AMCST_MotherMobleNo" text,
    "AMCST_MotheremailId" text,
    "AMCST_Date" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_clgstudentid" bigint;
BEGIN
    "v_clgstudentid" := 0;
    
    IF("p_type" = 'Student') THEN
        SELECT a."AMCST_Id" INTO "v_clgstudentid"
        FROM "IVRM_User_Login_Student_College" a
        INNER JOIN "ApplicationUser" b ON a."IVRMUL_Id" = b."Id"
        WHERE b."Id" = "p_usercode";
    END IF;

    IF("p_type" = 'Staff') THEN
        RETURN QUERY
        SELECT 
            a."HRME_Id",
            a."HRME_Photo",
            COALESCE(a."HRME_EmployeeFirstName", '') || ' ' || COALESCE(a."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(a."HRME_EmployeeLastName", '') AS "emp_name",
            a."HRME_EmployeeCode",
            a."HRME_MobileNo",
            (SELECT "HRMEMNO_MobileNo" FROM "HR_Master_Employee_MobileNo" WHERE "HRME_Id" = a."HRME_Id" LIMIT 1) AS "HRMEMNO_MobileNo",
            (SELECT "HRMEM_EmailId" FROM "HR_Master_Employee_EmailId" WHERE "HRME_Id" = a."HRME_Id" LIMIT 1) AS "HRMEM_EmailId",
            b."HRMD_DepartmentName",
            c."HRMDES_DesignationName",
            d."MI_Name",
            COALESCE(d."MI_Address1", '') || ' ' || COALESCE(d."MI_Address2", '') || ' ' || COALESCE(d."MI_Address3", '') AS "MI_address",
            NULL::bigint,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::bigint,
            NULL::text,
            NULL::bigint,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::bigint,
            NULL::text,
            NULL::text,
            NULL::timestamp,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::timestamp
        FROM "HR_Master_Employee" a 
        INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
        INNER JOIN "HR_Master_Designation" c ON a."HRMDES_Id" = c."HRMDES_Id"
        INNER JOIN "master_institution" d ON a."mi_id" = d."mi_id"
        WHERE a."MI_Id" = "p_MI_Id" AND a."HRME_Id" = "p_usercode";
        
    ELSIF("p_type" = 'Student' AND "v_clgstudentid" > 0) THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::bigint,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::text,
            "AMCS"."AMCST_Id",
            (CASE WHEN "AMCS"."AMCST_FirstName" IS NULL OR "AMCS"."AMCST_FirstName" = '' THEN '' ELSE "AMCS"."AMCST_FirstName" END || 
             CASE WHEN "AMCS"."AMCST_MiddleName" IS NULL OR "AMCS"."AMCST_MiddleName" = '' OR "AMCS"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCS"."AMCST_MiddleName" END || 
             CASE WHEN "AMCS"."AMCST_LastName" IS NULL OR "AMCS"."AMCST_LastName" = '' OR "AMCS"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "AMCS"."AMCST_LastName" END) AS "studentname",
            (CASE WHEN "AMCS"."AMCST_FatherName" IS NULL OR "AMCS"."AMCST_FatherName" = '' THEN '' ELSE "AMCS"."AMCST_FatherName" END || 
             CASE WHEN "AMCS"."AMCST_FatherSurname" IS NULL OR "AMCS"."AMCST_FatherSurname" = '' OR "AMCS"."AMCST_FatherSurname" = '0' THEN '' ELSE ' ' || "AMCS"."AMCST_FatherSurname" END) AS "fatherName",
            (CASE WHEN "AMCS"."AMCST_MotherName" IS NULL OR "AMCS"."AMCST_MotherName" = '' THEN '' ELSE "AMCS"."AMCST_MotherName" END || 
             CASE WHEN "AMCS"."AMCST_MotherSurname" IS NULL OR "AMCS"."AMCST_MotherSurname" = '' OR "AMCS"."AMCST_MotherSurname" = '0' THEN '' ELSE ' ' || "AMCS"."AMCST_MotherSurname" END) AS "mothername",
            "AMCO"."AMCO_Id",
            "AMCO"."AMCO_CourseName",
            "AMB"."AMB_Id",
            "AMB"."AMB_BranchName",
            "AMSE"."AMSE_SEMName",
            "ACMS"."ACMS_SectionName",
            "ACYS"."ASMAY_Id",
            "ASMAY"."ASMAY_Year",
            "AMCS"."AMCST_AdmNo",
            "AMCS"."AMCST_DOB",
            "AMCS"."AMCST_emailId",
            "AMCS"."AMCST_MobileNo",
            "AMCS"."AMCST_RegistrationNo",
            "AMCS"."AMCST_StudentPhoto",
            "AMCS"."AMCST_PerStreet",
            "AMCS"."AMCST_PerArea",
            "AMCS"."AMCST_PerCity",
            "ACYS"."ACYST_RollNo",
            "AMCS"."AMCST_Sex",
            "AMCS"."AMCST_FatherMobleNo",
            "AMCS"."AMCST_FatheremailId",
            "AMCS"."AMCST_MotherMobleNo",
            "AMCS"."AMCST_MotheremailId",
            "AMCS"."AMCST_Date"
        FROM "CLG"."Adm_Master_College_Student" "AMCS"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id" AND "AMCS"."AMCST_SOL" = 'S' AND "AMCS"."AMCST_ActiveFlag" = 1 AND "ACYS"."ACYST_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Course" "AMCO" ON "AMCO"."MI_Id" = "p_MI_Id" AND "AMCO"."AMCO_Id" = "ACYS"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."MI_Id" = "p_MI_Id" AND "AMB"."AMB_Id" = "ACYS"."AMB_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."MI_Id" = "p_MI_Id" AND "ASMAY"."ASMAY_Id" = "p_ASMAY_Id" AND "ACYS"."ASMAY_Id" = "ASMAY"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."MI_Id" = "p_MI_Id" AND "AMSE"."AMSE_Id" = "ACYS"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "ACMS" ON "ACMS"."ACMS_Id" = "ACYS"."ACMS_Id" AND "ACMS"."MI_Id" = "p_MI_Id"
        WHERE "ASMAY"."MI_Id" = "p_MI_Id" AND "ACYS"."AMCST_Id" = "v_clgstudentid" AND "ASMAY"."ASMAY_Id" = "p_ASMAY_Id" AND "ACYS"."ASMAY_Id" = "p_ASMAY_Id";
    END IF;

    RETURN;
END;
$$;