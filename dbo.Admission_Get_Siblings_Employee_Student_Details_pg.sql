CREATE OR REPLACE FUNCTION "dbo"."Admission_Get_Siblings_Employee_Student_Details"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMST_HRME_Id" TEXT,
    "FLAG" TEXT
)
RETURNS TABLE (
    "FirstStudentName" TEXT,
    "FirstStudentAdmNo" VARCHAR,
    "AMSTS_SiblingsName" VARCHAR,
    "orders" INT,
    "FirstStudentclass" VARCHAR,
    "firstamstid" BIGINT,
    "siblingamstid" BIGINT,
    "FirstStudentsection" VARCHAR,
    "AMST_FatherName" VARCHAR,
    "AMST_MotherName" VARCHAR,
    "AMST_FatherMobleNo" BIGINT,
    "AMST_MotherMobileNo" BIGINT,
    "UserName" VARCHAR,
    "Id" BIGINT,
    "FATHERUSERNAME" VARCHAR,
    "FATHERUSERId" BIGINT,
    "MOTHERUSERNAME" VARCHAR,
    "MOTHERUSERId" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "FLAG" = 'sibling' THEN
        RETURN QUERY
        SELECT 
            a."FirstStudentName",
            a."FirstStudentAdmNo",
            a."AMSTS_SiblingsName",
            a."AMSTS_SiblingsOrder" AS "orders",
            a."FirstStudentclass",
            a."firstamstid",
            a."siblingamstid",
            a."FirstStudentsection",
            a."AMST_FatherName",
            a."AMST_MotherName",
            a."AMST_FatherMobleNo",
            a."AMST_MotherMobileNo",
            a."UserName",
            a."Id",
            (SELECT "A"."UserName" 
             FROM "ApplicationUser" "A" 
             INNER JOIN "Ivrm_User_StudentApp_login" "B" ON "A"."Id" = "B"."FAT_APP_ID" 
             WHERE "B"."AMST_ID" = a."siblingamstid") AS "FATHERUSERNAME",
            (SELECT "A"."Id" 
             FROM "ApplicationUser" "A" 
             INNER JOIN "Ivrm_User_StudentApp_login" "B" ON "A"."Id" = "B"."FAT_APP_ID" 
             WHERE "B"."AMST_ID" = a."siblingamstid") AS "FATHERUSERId",
            (SELECT "A"."UserName" 
             FROM "ApplicationUser" "A" 
             INNER JOIN "Ivrm_User_StudentApp_login" "B" ON "A"."Id" = "B"."MOT_APP_ID" 
             WHERE "B"."AMST_ID" = a."siblingamstid") AS "MOTHERUSERNAME",
            (SELECT "A"."Id" 
             FROM "ApplicationUser" "A" 
             INNER JOIN "Ivrm_User_StudentApp_login" "B" ON "A"."Id" = "B"."MOT_APP_ID" 
             WHERE "B"."AMST_ID" = a."siblingamstid") AS "MOTHERUSERId"
        FROM (
            SELECT DISTINCT 
                (COALESCE("amst_firstname", '') || ' ' || COALESCE("amst_middlename", '') || ' ' || COALESCE("amst_lastname", '')) AS "FirstStudentName",
                "AMS"."AMST_AdmNo" AS "FirstStudentAdmNo",
                "AMSS"."AMSTS_SiblingsName",
                "AMS"."AMST_AdmNo" AS "SubAdmNo",
                "mclass"."ASMCL_ClassName" AS "FirstStudentclass",
                "mclass"."ASMCL_ClassName" AS "Subclass",
                "msection"."ASMC_SectionName" AS "FirstStudentsection",
                "msection"."ASMC_SectionName" AS "Subsection",
                "AMSS"."AMST_Id" AS "firstamstid",
                "AMSS"."AMSTS_Siblings_AMST_ID" AS "siblingamstid",
                "AMSS"."AMSTS_SiblingsOrder",
                "AMS"."AMST_FatherName",
                "AMS"."AMST_MotherName",
                "AMS"."AMST_FatherMobleNo",
                "AMS"."AMST_MotherMobileNo",
                "APPUSER"."UserName",
                "APPUSER"."Id"
            FROM "Adm_Master_Student_SiblingsDetails" "AMSS"
            INNER JOIN "Adm_M_student" "AMS" ON "AMSS"."AMSTS_Siblings_AMST_ID" = "AMS"."AMST_Id"
            INNER JOIN "adm_school_Y_student" "ays" ON "ays"."AMST_Id" = "AMS"."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "myear" ON "myear"."ASMAY_Id" = "ays"."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" "mclass" ON "mclass"."ASMCL_Id" = "ays"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" "msection" ON "msection"."ASMS_Id" = "ays"."ASMS_Id"
            LEFT JOIN "Ivrm_User_StudentApp_login" "STDLOGIN" ON "STDLOGIN"."AMST_ID" = "AMS"."AMST_Id"
            LEFT JOIN "ApplicationUser" "APPUSER" ON "APPUSER"."Id" = "STDLOGIN"."STD_APP_ID"
            WHERE "ays"."ASMAY_Id"::TEXT = "ASMAY_Id"
                AND "AMS"."AMST_SOL" = 'S'
                AND "AMS"."AMST_ActiveFlag" = 1
                AND "ays"."AMAY_ActiveFlag" = 1
                AND "AMSS"."AMSTS_TCIssuesFlag" = 0
                AND "AMS"."MI_Id"::TEXT = "MI_Id"
                AND "AMSS"."AMST_Id"::TEXT = "AMST_HRME_Id"
        ) a
        ORDER BY a."FirstStudentName", a."FirstStudentAdmNo", a."AMSTS_SiblingsOrder";
        
    END IF;

    RETURN;

END;
$$;