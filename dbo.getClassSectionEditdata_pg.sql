CREATE OR REPLACE FUNCTION "dbo"."getClassSectionEditdata"(
    "ASALU_Id" integer,
    "ASALUC_Id" integer,
    "ASALUCS_Id" integer,
    "type" integer
)
RETURNS TABLE(
    "ASALUC_Id" integer,
    "ASALU_Id" integer,
    "name" text,
    "ASMCL_Id" integer,
    "ASMC_Id" integer,
    "classsection" text,
    "ASMAY_Id" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF("type" = 0) THEN
        RETURN QUERY
        SELECT      "admluc"."ASALUC_Id",
                    "admluc"."ASALU_Id",
                    "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" as "name",
                    "class"."ASMCL_Id",
                    "section"."ASMS_Id" as "ASMC_Id",
                    "class"."ASMCL_Id"::text || '-' || "section"."ASMS_Id"::text as "classsection",
                    "admluc"."ASMAY_Id"
        FROM        "Adm_School_Attendance_Login_User" "admlu"
        LEFT JOIN   "Adm_School_Attendance_Login_User_Class" "admluc" ON "admluc"."ASALU_Id" = "admlu"."ASALU_Id"
        LEFT JOIN   "Adm_School_Attendance_Login_User_Class_Subjects" "admlucs" ON "admlucs"."ASALUC_Id" = "admluc"."ASALUC_Id"
        LEFT JOIN   "IVRM_Staff_User_Login" "appuser" ON "appuser"."IVRMSTAUL_Id" = "admlu"."HRME_Id"
        LEFT JOIN   "Adm_School_M_Class" "class" ON "class"."ASMCL_Id" = "admluc"."ASMCL_Id"
        LEFT JOIN   "Adm_School_M_Section" "section" ON "section"."ASMS_Id" = "admluc"."ASMS_Id"
        WHERE       "admlu"."ASALU_Id" = "getClassSectionEditdata"."ASALU_Id" 
                    AND "admluc"."ASALUC_Id" = "getClassSectionEditdata"."ASALUC_Id"
        ORDER BY    "class"."ASMCL_Id", "section"."ASMS_Id";
        
    ELSIF("type" = 1) THEN
        RETURN QUERY
        SELECT      "admluc"."ASALUC_Id",
                    "admluc"."ASALU_Id",
                    "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" as "name",
                    "class"."ASMCL_Id",
                    "section"."ASMS_Id" as "ASMC_Id",
                    "class"."ASMCL_Id"::text || '-' || "section"."ASMS_Id"::text as "classsection",
                    "admluc"."ASMAY_Id"
        FROM        "Adm_School_Attendance_Login_User" "admlu"
        LEFT JOIN   "Adm_School_Attendance_Login_User_Class" "admluc" ON "admluc"."ASALU_Id" = "admlu"."ASALU_Id"
        LEFT JOIN   "Adm_School_Attendance_Login_User_Class_Subjects" "admlucs" ON "admlucs"."ASALUC_Id" = "admluc"."ASALUC_Id"
        LEFT JOIN   "IVRM_Staff_User_Login" "appuser" ON "appuser"."IVRMSTAUL_Id" = "admlu"."HRME_Id"
        LEFT JOIN   "Adm_School_M_Class" "class" ON "class"."ASMCL_Id" = "admluc"."ASMCL_Id"
        LEFT JOIN   "Adm_School_M_Section" "section" ON "section"."ASMS_Id" = "admluc"."ASMS_Id"
        WHERE       "admlu"."ASALU_Id" = "getClassSectionEditdata"."ASALU_Id" 
                    AND "admluc"."ASALUC_Id" = "getClassSectionEditdata"."ASALUC_Id" 
                    AND "admlucs"."ASALUCS_Id" = "getClassSectionEditdata"."ASALUCS_Id"
        ORDER BY    "class"."ASMCL_Id", "section"."ASMS_Id";
        
    END IF;
    
    RETURN;
END;
$$;