CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeworkclasswork_list"(
    "MI_Id" bigint,
    "Login_Id" bigint,
    "ASMAY_Id" bigint,
    "Parameter" text
)
RETURNS TABLE(
    "asmcL_ClassName" character varying,
    "asmcL_Id" bigint,
    "asmC_SectionName" character varying,
    "asmS_Id" bigint,
    "ismS_SubjectName" character varying,
    "ismS_Id" bigint,
    "icW_Id" bigint,
    "icW_Content" text,
    "icW_Topic" character varying,
    "icW_SubTopic" character varying,
    "icW_FromDate" timestamp,
    "icW_ToDate" timestamp,
    "icW_ActiveFlag" boolean,
    "icW_Assignment" text,
    "icW_TeachingAid" character varying,
    "icW_Evaluation" character varying,
    "icW_Attachment" character varying,
    "icW_FilePath" character varying,
    "mI_Id" bigint,
    "asmaY_Id" bigint,
    "ihW_AssignmentNo" character varying,
    "ihW_Attachment" character varying,
    "ihW_Assignment" text,
    "ihW_Date" timestamp,
    "ihW_Topic" character varying,
    "ihW_ActiveFlag" boolean,
    "ihW_Id" bigint,
    "ivrmuL_Id" bigint,
    "ihW_FilePath" character varying
) AS $$
DECLARE
    "emp" bigint;
BEGIN
    
    SELECT COUNT(*) INTO "emp"
    FROM "IVRM_Staff_User_Login"
    WHERE "Id" = "Login_Id" AND "MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id";

    IF "Parameter" = 'Classwork' THEN
        
        IF "emp" > 0 THEN
            
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName" AS "asmcL_ClassName",
                n."ASMCL_Id" AS "asmcL_Id",
                o."ASMC_SectionName" AS "asmC_SectionName",
                o."ASMS_Id" AS "asmS_Id",
                p."ISMS_SubjectName" AS "ismS_SubjectName",
                p."ISMS_Id" AS "ismS_Id",
                m."ICW_Id" AS "icW_Id",
                m."ICW_Content" AS "icW_Content",
                m."ICW_Topic" AS "icW_Topic",
                m."ICW_SubTopic" AS "icW_SubTopic",
                m."ICW_FromDate" AS "icW_FromDate",
                m."ICW_ToDate" AS "icW_ToDate",
                m."ICW_ActiveFlag" AS "icW_ActiveFlag",
                m."ICW_Assignment" AS "icW_Assignment",
                m."ICW_TeachingAid" AS "icW_TeachingAid",
                m."ICW_Evaluation" AS "icW_Evaluation",
                m."ICW_Attachment" AS "icW_Attachment",
                m."ICW_FilePath" AS "icW_FilePath",
                m."MI_Id" AS "mI_Id",
                m."ASMAY_Id" AS "asmaY_Id",
                NULL::character varying,
                NULL::character varying,
                NULL::text,
                NULL::timestamp,
                NULL::character varying,
                NULL::boolean,
                NULL::bigint,
                NULL::bigint,
                NULL::character varying
            FROM "IVRM_Assignment" m
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = m."ASMAY_Id" AND "ASYS"."ASMCL_Id" = m."ASMCL_Id" AND "ASYS"."ASMS_Id" = m."ASMS_Id"
            INNER JOIN "Adm_School_M_Class" n ON n."ASMCL_Id" = "ASYS"."ASMCL_Id" AND n."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "Adm_School_M_Section" o ON o."ASMS_Id" = "ASYS"."ASMS_Id" AND o."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "IVRM_Master_Subjects" p ON p."ISMS_Id" = m."ISMS_Id" AND p."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "IVRM_Staff_User_Login" z ON z."Id" = m."Login_Id" AND z."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            WHERE m."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id" 
                AND m."ASMAY_Id" = "IVRM_homeworkclasswork_list"."ASMAY_Id" 
                AND m."Login_Id" = "IVRM_homeworkclasswork_list"."Login_Id";
        
        ELSE
            
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName" AS "asmcL_ClassName",
                n."ASMCL_Id" AS "asmcL_Id",
                o."ASMC_SectionName" AS "asmC_SectionName",
                o."ASMS_Id" AS "asmS_Id",
                p."ISMS_SubjectName" AS "ismS_SubjectName",
                p."ISMS_Id" AS "ismS_Id",
                m."ICW_Id" AS "icW_Id",
                m."ICW_Content" AS "icW_Content",
                m."ICW_Topic" AS "icW_Topic",
                m."ICW_SubTopic" AS "icW_SubTopic",
                m."ICW_FromDate" AS "icW_FromDate",
                m."ICW_ToDate" AS "icW_ToDate",
                m."ICW_ActiveFlag" AS "icW_ActiveFlag",
                m."ICW_Assignment" AS "icW_Assignment",
                m."ICW_TeachingAid" AS "icW_TeachingAid",
                m."ICW_Evaluation" AS "icW_Evaluation",
                m."ICW_Attachment" AS "icW_Attachment",
                m."ICW_FilePath" AS "icW_FilePath",
                m."MI_Id" AS "mI_Id",
                m."ASMAY_Id" AS "asmaY_Id",
                NULL::character varying,
                NULL::character varying,
                NULL::text,
                NULL::timestamp,
                NULL::character varying,
                NULL::boolean,
                NULL::bigint,
                NULL::bigint,
                NULL::character varying
            FROM "IVRM_Assignment" m
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = m."ASMAY_Id" AND "ASYS"."ASMCL_Id" = m."ASMCL_Id" AND "ASYS"."ASMS_Id" = m."ASMS_Id"
            INNER JOIN "Adm_School_M_Class" n ON n."ASMCL_Id" = "ASYS"."ASMCL_Id" AND n."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "Adm_School_M_Section" o ON o."ASMS_Id" = "ASYS"."ASMS_Id" AND o."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "IVRM_Master_Subjects" p ON p."ISMS_Id" = m."ISMS_Id" AND p."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            WHERE m."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id" 
                AND m."ASMAY_Id" = "IVRM_homeworkclasswork_list"."ASMAY_Id" 
                AND m."Login_Id" = "IVRM_homeworkclasswork_list"."Login_Id";
        
        END IF;
    
    ELSIF "Parameter" = 'Homework' THEN
        
        IF "emp" > 0 THEN
            
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName" AS "asmcL_ClassName",
                NULL::bigint,
                o."ASMC_SectionName" AS "asmC_SectionName",
                NULL::bigint,
                p."ISMS_SubjectName" AS "ismS_SubjectName",
                NULL::bigint,
                NULL::bigint,
                NULL::text,
                NULL::character varying,
                NULL::character varying,
                NULL::timestamp,
                NULL::timestamp,
                NULL::boolean,
                NULL::text,
                NULL::character varying,
                NULL::character varying,
                NULL::character varying,
                NULL::character varying,
                NULL::bigint,
                m."ASMAY_Id" AS "asmaY_Id",
                m."IHW_AssignmentNo" AS "ihW_AssignmentNo",
                m."IHW_Attachment" AS "ihW_Attachment",
                m."IHW_Assignment" AS "ihW_Assignment",
                m."IHW_Date" AS "ihW_Date",
                m."IHW_Topic" AS "ihW_Topic",
                m."IHW_ActiveFlag" AS "ihW_ActiveFlag",
                m."IHW_Id" AS "ihW_Id",
                m."IVRMUL_Id" AS "ivrmuL_Id",
                m."IHW_FilePath" AS "ihW_FilePath"
            FROM "IVRM_HomeWork" m
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = m."ASMAY_Id" AND "ASYS"."ASMCL_Id" = m."ASMCL_Id" AND "ASYS"."ASMS_Id" = m."ASMS_Id"
            INNER JOIN "Adm_School_M_Class" n ON n."ASMCL_Id" = "ASYS"."ASMCL_Id" AND n."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "Adm_School_M_Section" o ON o."ASMS_Id" = "ASYS"."ASMS_Id" AND o."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "IVRM_Master_Subjects" p ON p."ISMS_Id" = m."ISMS_Id" AND p."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "IVRM_Staff_User_Login" z ON m."IVRMUL_Id" = z."Id" AND z."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            WHERE m."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id" 
                AND m."ASMAY_Id" = "IVRM_homeworkclasswork_list"."ASMAY_Id" 
                AND m."IVRMUL_Id" = "IVRM_homeworkclasswork_list"."Login_Id";
        
        ELSE
            
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName" AS "asmcL_ClassName",
                NULL::bigint,
                o."ASMC_SectionName" AS "asmC_SectionName",
                NULL::bigint,
                p."ISMS_SubjectName" AS "ismS_SubjectName",
                NULL::bigint,
                NULL::bigint,
                NULL::text,
                NULL::character varying,
                NULL::character varying,
                NULL::timestamp,
                NULL::timestamp,
                NULL::boolean,
                NULL::text,
                NULL::character varying,
                NULL::character varying,
                NULL::character varying,
                NULL::character varying,
                NULL::bigint,
                m."ASMAY_Id" AS "asmaY_Id",
                m."IHW_AssignmentNo" AS "ihW_AssignmentNo",
                m."IHW_Attachment" AS "ihW_Attachment",
                m."IHW_Assignment" AS "ihW_Assignment",
                m."IHW_Date" AS "ihW_Date",
                m."IHW_Topic" AS "ihW_Topic",
                m."IHW_ActiveFlag" AS "ihW_ActiveFlag",
                m."IHW_Id" AS "ihW_Id",
                m."IVRMUL_Id" AS "ivrmuL_Id",
                m."IHW_FilePath" AS "ihW_FilePath"
            FROM "IVRM_HomeWork" m
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = m."ASMAY_Id" AND "ASYS"."ASMCL_Id" = m."ASMCL_Id" AND "ASYS"."ASMS_Id" = m."ASMS_Id"
            INNER JOIN "Adm_School_M_Class" n ON n."ASMCL_Id" = "ASYS"."ASMCL_Id" AND n."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "Adm_School_M_Section" o ON o."ASMS_Id" = "ASYS"."ASMS_Id" AND o."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            INNER JOIN "IVRM_Master_Subjects" p ON p."ISMS_Id" = m."ISMS_Id" AND p."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id"
            WHERE m."MI_Id" = "IVRM_homeworkclasswork_list"."MI_Id" 
                AND m."ASMAY_Id" = "IVRM_homeworkclasswork_list"."ASMAY_Id" 
                AND m."IVRMUL_Id" = "IVRM_homeworkclasswork_list"."Login_Id";
        
        END IF;
    
    END IF;

    RETURN;

END;
$$ LANGUAGE plpgsql;