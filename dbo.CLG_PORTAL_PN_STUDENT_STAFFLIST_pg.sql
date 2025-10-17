CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_PN_STUDENT_STAFFLIST" (
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@AMCST_Id" bigint,
    "@HRME_Id" bigint,
    "@roleflag" varchar(10)
)
RETURNS TABLE (
    "AMCST_Id" bigint,
    "studentname" text,
    "AMCST_AdmNo" varchar,
    "HRME_Id" bigint,
    "employeename" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@roleflag" = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "AMCS"."AMCST_Id",
            (CASE WHEN "AMCS"."AMCST_FirstName" IS NULL OR "AMCS"."AMCST_FirstName" = '' THEN '' ELSE "AMCS"."AMCST_FirstName" END ||
             CASE WHEN "AMCS"."AMCST_MiddleName" IS NULL OR "AMCS"."AMCST_MiddleName" = '' OR "AMCS"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCS"."AMCST_MiddleName" END ||
             CASE WHEN "AMCS"."AMCST_LastName" IS NULL OR "AMCS"."AMCST_LastName" = '' OR "AMCS"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "AMCS"."AMCST_LastName" END)::text,
            "AMCS"."AMCST_AdmNo",
            NULL::bigint,
            NULL::text
        FROM "CLG"."Adm_Master_College_Student" "AMCS"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id" 
            AND "AMCS"."AMCST_SOL" = 'S' 
            AND "AMCS"."AMCST_ActiveFlag" = 1 
            AND "ACYS"."ACYST_ActiveFlag" = 1 
            AND "AMCS"."MI_Id" = "@MI_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "@ASMAY_Id" 
            AND "ASMAY"."MI_Id" = "@MI_Id"
        WHERE "AMCS"."MI_Id" = "@MI_Id" 
            AND "AMCS"."ASMAY_Id" = "@ASMAY_Id";

    ELSIF "@roleflag" = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::bigint,
            NULL::text,
            NULL::varchar,
            "HRME_Id",
            (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)::text
        FROM "dbo"."HR_Master_Employee"
        WHERE "MI_Id" = "@MI_Id" 
            AND "HRME_ActiveFlag" = 1;

    END IF;

    RETURN;

END;
$$;