CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeworkclasswork_MarksUpdate_list_Modify"(
    "@MI_Id" bigint,
    "@Login_Id" bigint,
    "@ASMAY_Id" bigint,
    "@Parameter" varchar(50)
)
RETURNS TABLE (
    "Id" bigint,
    "AMST_Id" bigint,
    "studentname" text,
    "amst_admno" varchar,
    "Topic" text,
    "Assignment_SubTopic" text,
    "Content" text,
    "Marks" varchar,
    "ISMS_SubjectName" varchar,
    "UpdatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN

IF "@Parameter" = 'Homework' THEN

    RETURN QUERY
    SELECT DISTINCT 
        a."IHW_Id" AS "Id", 
        b."AMST_Id", 
        (CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
         CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
         CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' THEN '' ELSE ' ' || d."AMST_LastName" END)::text AS "studentname",
        d."amst_admno", 
        a."IHW_Topic"::text AS "Topic",
        a."IHW_Assignment"::text AS "Assignment_SubTopic",
        ''::text AS "Content",
        b."IHWUPL_Marks"::varchar AS "Marks",
        (SELECT e."ISMS_SubjectName" 
         FROM "IVRM_Master_Subjects" e 
         WHERE e."ISMS_Id" = a."ISMS_Id" AND e."MI_Id" = "@MI_Id") AS "ISMS_SubjectName",
        b."UpdatedDate"
    FROM "IVRM_HomeWork" a
    INNER JOIN "Adm_school_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
        AND YS."ASMCL_Id" = a."ASMCL_Id" 
        AND YS."ASMS_Id" = a."ASMS_Id" 
        AND YS."ASMAY_Id" = "@ASMAY_Id"
    INNER JOIN "IVRM_HomeWork_Upload" b ON a."IHW_Id" = b."IHW_Id" 
        AND b."AMST_Id" = YS."AMST_Id"
    INNER JOIN "Adm_M_Student" d ON b."AMST_Id" = d."AMST_Id" 
        AND d."MI_Id" = "@MI_Id"
    WHERE a."MI_Id" = "@MI_Id" 
        AND a."ASMAY_Id" = "@ASMAY_Id" 
        AND a."IVRMUL_Id" = "@Login_Id" 
        AND b."IHWUPL_Marks" > 0 
    ORDER BY b."UpdatedDate" DESC;

ELSIF "@Parameter" = 'Classwork' THEN

    RETURN QUERY
    SELECT DISTINCT 
        a."ICW_Id" AS "Id", 
        b."AMST_Id", 
        (CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
         CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
         CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' THEN '' ELSE ' ' || d."AMST_LastName" END)::text AS "studentname",
        d."amst_admno", 
        a."ICW_Topic"::text AS "Topic",
        a."ICW_SubTopic"::text AS "Assignment_SubTopic",
        COALESCE(a."ICW_Content", '')::text AS "Content",
        b."ICWUPL_Marks"::varchar AS "Marks",
        (SELECT e."ISMS_SubjectName" 
         FROM "IVRM_Master_Subjects" e 
         WHERE e."ISMS_Id" = a."ISMS_Id" AND e."MI_Id" = "@MI_Id") AS "ISMS_SubjectName",
        b."UpdatedDate"
    FROM "IVRM_Assignment" a 
    INNER JOIN "Adm_school_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
        AND YS."ASMCL_Id" = a."ASMCL_Id" 
        AND YS."ASMS_Id" = a."ASMS_Id" 
        AND YS."ASMAY_Id" = "@ASMAY_Id"
    INNER JOIN "IVRM_ClassWork_Upload" b ON a."ICW_Id" = b."ICW_Id" 
        AND b."AMST_Id" = YS."AMST_Id"
    INNER JOIN "Adm_M_Student" d ON b."AMST_Id" = d."AMST_Id"
    WHERE a."ASMAY_Id" = "@ASMAY_Id" 
        AND a."MI_Id" = "@MI_Id" 
        AND a."Login_Id" = "@Login_Id" 
        AND b."ICWUPL_Marks" > 0
    ORDER BY b."UpdatedDate" DESC;

END IF;

END;
$$;