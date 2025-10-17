CREATE OR REPLACE FUNCTION "dbo"."Adm_getClassSectiondata_By_Classteacher_New" (
    "p_MI_ID" int,
    "p_asmay_id" varchar,
    "p_HRME_Id" varchar,
    "p_type" int
)
RETURNS TABLE (
    "name" varchar,
    "ASMCL_Id" int,
    "ASMC_Id" int,
    "classsection" text,
    "asmcL_ClassName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "p_type" = 1 THEN
        RETURN QUERY
        SELECT 
            "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" as "name",
            "class"."ASMCL_Id",
            "section"."ASMS_Id" as "ASMC_Id",
            "class"."ASMCL_Id"::text || '-' || "section"."ASMS_Id"::text as "classsection",
            NULL::varchar as "asmcL_ClassName"
        FROM "dbo"."Adm_School_M_Class" "class" 
        INNER JOIN "dbo"."Adm_School_M_Section" "section" ON "class"."MI_Id" = "section"."MI_Id" 
        INNER JOIN "dbo"."Adm_School_Attendance_EntryType" "entrytype" ON "entrytype"."ASMCL_Id" = "class"."ASMCL_Id" 
        INNER JOIN "dbo"."Adm_School_M_Class_Category" a ON a."ASMCL_Id" = "entrytype"."ASMCL_Id" 
            AND a."ASMCL_Id" = "class"."ASMCL_Id" 
            AND a."ASMAY_Id" = "entrytype"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_Master_Class_Cat_Sec" "sec" ON "sec"."ASMCC_Id" = a."ASMCC_Id" 
            AND "sec"."ASMS_Id" = "section"."ASMS_Id"
        WHERE "class"."MI_Id" = "p_MI_ID" 
            AND "section"."MI_Id" = "p_MI_ID" 
            AND "entrytype"."MI_Id" = "p_MI_ID" 
            AND "entrytype"."ASMAY_Id" = "p_asmay_id"::int 
            AND "ASMCL_ActiveFlag" = 1 
            AND "ASMC_ActiveFlag" = 1 
            AND "ASAET_Att_Type" = 'P' 
            AND a."ASMAY_Id" = "p_asmay_id"::int 
        ORDER BY "class"."ASMCL_Id", "section"."ASMS_Id";

    ELSIF "p_type" = 2 THEN
        RETURN QUERY
        SELECT 
            "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" as "name",
            "class"."ASMCL_Id",
            "section"."ASMS_Id" as "ASMC_Id",
            "class"."ASMCL_Id"::text || '-' || "section"."ASMS_Id"::text as "classsection",
            NULL::varchar as "asmcL_ClassName"
        FROM "dbo"."IVRM_Master_ClassTeacher" a 
        INNER JOIN "dbo"."Adm_School_M_Class" as "class" ON "class"."ASMCL_Id" = a."ASMCL_Id" 
        INNER JOIN "dbo"."Adm_School_M_Section" as "section" ON "section"."ASMS_Id" = a."ASMS_Id" 
        WHERE "class"."MI_Id" = "p_MI_ID" 
            AND "class"."ASMCL_ActiveFlag" = 1 
            AND "section"."MI_Id" = "p_MI_ID" 
            AND "section"."ASMC_ActiveFlag" = 1 
            AND a."ASMAY_Id" = "p_asmay_id"::int 
            AND a."HRME_Id" = "p_HRME_Id"::int
            AND a."IMCT_ActiveFlag" = 1
        ORDER BY "class"."ASMCL_Id", "section"."ASMS_Id";

    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            c."ASMCL_ClassName" || ' - ' || "sec"."ASMC_SectionName" as "name",
            c."ASMCL_Id",
            "sec"."ASMS_Id" as "ASMC_Id",
            c."ASMCL_Id"::text || '-' || "sec"."ASMS_Id"::text as "classsection",
            c."ASMCL_ClassName" as "asmcL_ClassName"
        FROM "exm"."Exm_Login_Privilege" a 
        INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
        INNER JOIN "dbo"."IVRM_Staff_User_Login" d ON d."IVRMSTAUL_Id" = a."Login_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" c ON b."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" "sec" ON "sec"."ASMS_Id" = b."ASMS_Id"
        WHERE a."MI_Id" = "p_MI_Id" 
            AND d."id" = (
                SELECT "id" 
                FROM "dbo"."IVRM_Staff_User_Login" 
                INNER JOIN "dbo"."HR_Master_Employee" ON "IVRM_Staff_User_Login"."Emp_Code" = "HR_Master_Employee"."HRME_Id" 
                WHERE "HR_Master_Employee"."HRME_Id" = "p_HRME_Id"::int
            ) 
            AND "ASMAY_Id" = "p_ASMAY_Id"::int;

    END IF;

END;
$$;