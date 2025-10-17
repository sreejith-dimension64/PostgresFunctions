CREATE OR REPLACE FUNCTION "dbo"."GetLoginPreviledges_New"(
    "MIID" INTEGER,
    "Year" INTEGER,
    "EntryFlag" INTEGER,
    "hrme_id" TEXT
)
RETURNS TABLE(
    "ASALU_Id" INTEGER,
    "ASALUC_Id" INTEGER,
    "ASALUCS_Id" INTEGER,
    "IVRMSTAUL_UserName" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "PAMS_SubjectName" TEXT,
    "ASMAY_Year" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "EntryFlag" = 1 THEN
        IF "hrme_id" != '0' THEN
            RETURN QUERY
            SELECT DISTINCT 
                a."ASALU_Id",
                COALESCE(c."ASALUC_Id", 0) AS "ASALUC_Id",
                COALESCE(c."ASALUCS_Id", 0) AS "ASALUCS_Id",
                (CASE WHEN d."HRME_EmployeeFirstName" IS NULL OR d."HRME_EmployeeFirstName" = '' THEN '' ELSE d."HRME_EmployeeFirstName" END ||
                CASE WHEN d."HRME_EmployeeMiddleName" IS NULL OR d."HRME_EmployeeMiddleName" = '' OR d."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeMiddleName" END ||
                CASE WHEN d."HRME_EmployeeLastName" IS NULL OR d."HRME_EmployeeLastName" = '' OR d."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeLastName" END ||
                CASE WHEN d."HRME_EmployeeCode" IS NULL OR d."HRME_EmployeeCode" = '' THEN '' ELSE ':' || d."HRME_EmployeeCode" END)::TEXT AS "IVRMSTAUL_UserName",
                e."ASMCL_ClassName"::TEXT,
                f."ASMC_SectionName"::TEXT,
                g."ISMS_SubjectName"::TEXT AS "PAMS_SubjectName",
                h."ASMAY_Year"::TEXT
            FROM "Adm_School_Attendance_Login_User" a
            INNER JOIN "Adm_School_Attendance_Login_User_Class" b ON a."ASALU_Id" = b."ASALU_Id"
            INNER JOIN "Adm_School_Attendance_Login_User_Class_Subjects" c ON c."ASALUC_Id" = b."ASALUC_Id"
            INNER JOIN "hr_master_employee" d ON d."HRME_Id" = a."HRME_Id"
            INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
            INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
            INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = c."ISMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" h ON h."ASMAY_Id" = a."ASMAY_Id"
            WHERE a."MI_Id" = "MIID" AND a."HRME_Id"::TEXT = "hrme_id" AND a."ASMAY_Id" = "Year" AND a."ASALU_EntryTypeFlag" = "EntryFlag";
        ELSE
            RETURN QUERY
            SELECT DISTINCT 
                a."ASALU_Id",
                COALESCE(c."ASALUC_Id", 0) AS "ASALUC_Id",
                COALESCE(c."ASALUCS_Id", 0) AS "ASALUCS_Id",
                (CASE WHEN d."HRME_EmployeeFirstName" IS NULL OR d."HRME_EmployeeFirstName" = '' THEN '' ELSE d."HRME_EmployeeFirstName" END ||
                CASE WHEN d."HRME_EmployeeMiddleName" IS NULL OR d."HRME_EmployeeMiddleName" = '' OR d."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeMiddleName" END ||
                CASE WHEN d."HRME_EmployeeLastName" IS NULL OR d."HRME_EmployeeLastName" = '' OR d."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeLastName" END ||
                CASE WHEN d."HRME_EmployeeCode" IS NULL OR d."HRME_EmployeeCode" = '' THEN '' ELSE ':' || d."HRME_EmployeeCode" END)::TEXT AS "IVRMSTAUL_UserName",
                e."ASMCL_ClassName"::TEXT,
                f."ASMC_SectionName"::TEXT,
                g."ISMS_SubjectName"::TEXT AS "PAMS_SubjectName",
                h."ASMAY_Year"::TEXT
            FROM "Adm_School_Attendance_Login_User" a
            INNER JOIN "Adm_School_Attendance_Login_User_Class" b ON a."ASALU_Id" = b."ASALU_Id"
            INNER JOIN "Adm_School_Attendance_Login_User_Class_Subjects" c ON c."ASALUC_Id" = b."ASALUC_Id"
            INNER JOIN "hr_master_employee" d ON d."HRME_Id" = a."HRME_Id"
            INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
            INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
            INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = c."ISMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" h ON h."ASMAY_Id" = a."ASMAY_Id"
            WHERE a."MI_Id" = "MIID" AND a."HRME_Id" != 0 AND a."ASMAY_Id" = "Year" AND a."ASALU_EntryTypeFlag" = "EntryFlag";
        END IF;

    ELSIF "EntryFlag" = 2 OR "EntryFlag" = 3 THEN
        IF "hrme_id" != '0' THEN
            RETURN QUERY
            SELECT DISTINCT 
                a."ASALU_Id",
                b."ASALUC_Id" AS "ASALUC_Id",
                0 AS "ASALUCS_Id",
                (CASE WHEN d."HRME_EmployeeFirstName" IS NULL OR d."HRME_EmployeeFirstName" = '' THEN '' ELSE d."HRME_EmployeeFirstName" END ||
                CASE WHEN d."HRME_EmployeeMiddleName" IS NULL OR d."HRME_EmployeeMiddleName" = '' OR d."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeMiddleName" END ||
                CASE WHEN d."HRME_EmployeeLastName" IS NULL OR d."HRME_EmployeeLastName" = '' OR d."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeLastName" END ||
                CASE WHEN d."HRME_EmployeeCode" IS NULL OR d."HRME_EmployeeCode" = '' THEN '' ELSE ':' || d."HRME_EmployeeCode" END)::TEXT AS "IVRMSTAUL_UserName",
                e."ASMCL_ClassName"::TEXT,
                f."ASMC_SectionName"::TEXT,
                ''::TEXT AS "PAMS_SubjectName",
                h."ASMAY_Year"::TEXT
            FROM "Adm_School_Attendance_Login_User" a
            INNER JOIN "Adm_School_Attendance_Login_User_Class" b ON a."ASALU_Id" = b."ASALU_Id"
            INNER JOIN "hr_master_employee" d ON d."HRME_Id" = a."HRME_Id"
            INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
            INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" h ON h."ASMAY_Id" = a."ASMAY_Id"
            WHERE a."MI_Id" = "MIID" AND a."HRME_Id"::TEXT = "hrme_id" AND a."ASMAY_Id" = "Year" AND a."ASALU_EntryTypeFlag" = "EntryFlag";
        ELSE
            RETURN QUERY
            SELECT DISTINCT 
                a."ASALU_Id",
                b."ASALUC_Id" AS "ASALUC_Id",
                0 AS "ASALUCS_Id",
                (CASE WHEN d."HRME_EmployeeFirstName" IS NULL OR d."HRME_EmployeeFirstName" = '' THEN '' ELSE d."HRME_EmployeeFirstName" END ||
                CASE WHEN d."HRME_EmployeeMiddleName" IS NULL OR d."HRME_EmployeeMiddleName" = '' OR d."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeMiddleName" END ||
                CASE WHEN d."HRME_EmployeeLastName" IS NULL OR d."HRME_EmployeeLastName" = '' OR d."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || d."HRME_EmployeeLastName" END ||
                CASE WHEN d."HRME_EmployeeCode" IS NULL OR d."HRME_EmployeeCode" = '' THEN '' ELSE ':' || d."HRME_EmployeeCode" END)::TEXT AS "IVRMSTAUL_UserName",
                e."ASMCL_ClassName"::TEXT,
                f."ASMC_SectionName"::TEXT,
                ''::TEXT AS "PAMS_SubjectName",
                h."ASMAY_Year"::TEXT
            FROM "Adm_School_Attendance_Login_User" a
            INNER JOIN "Adm_School_Attendance_Login_User_Class" b ON a."ASALU_Id" = b."ASALU_Id"
            INNER JOIN "hr_master_employee" d ON d."HRME_Id" = a."HRME_Id"
            INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
            INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" h ON h."ASMAY_Id" = a."ASMAY_Id"
            WHERE a."MI_Id" = "MIID" AND a."HRME_Id" != 0 AND a."ASMAY_Id" = "Year" AND a."ASALU_EntryTypeFlag" = "EntryFlag";
        END IF;
    END IF;

    RETURN;
END;
$$;