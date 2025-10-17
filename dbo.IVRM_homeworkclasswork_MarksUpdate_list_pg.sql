CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeworkclasswork_MarksUpdate_list"(
    "MI_Id" bigint,
    "Login_Id" bigint,
    "ASMAY_Id" bigint,
    "Parameter" varchar(50)
)
RETURNS TABLE(
    id bigint,
    "AMST_Id" bigint,
    studentname text,
    topic text,
    assignment_or_subtopic text,
    marks numeric,
    "ISMS_SubjectName" varchar,
    "UpdatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "Parameter" = 'Homework' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."IHW_Id" AS id,
            b."AMST_Id",
            (COALESCE(d."AMST_FirstName", '') || COALESCE(d."AMST_MiddleName", '') || COALESCE(d."AMST_LastName", '')) AS studentname,
            a."IHW_Topic" AS topic,
            a."IHW_Assignment" AS assignment_or_subtopic,
            b."IHWUPL_Marks" AS marks,
            (SELECT e."ISMS_SubjectName" 
             FROM "IVRM_Master_Subjects" e 
             WHERE e."ISMS_Id" = a."ISMS_Id" AND e."MI_Id" = "MI_Id") AS "ISMS_SubjectName",
            b."UpdatedDate"
        FROM "IVRM_HomeWork" a
        INNER JOIN "Adm_school_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
            AND YS."ASMCL_Id" = a."ASMCL_Id" 
            AND YS."ASMS_Id" = a."ASMS_Id" 
            AND YS."ASMAY_Id" = "ASMAY_Id"
        INNER JOIN "IVRM_HomeWork_Upload" b ON a."IHW_Id" = b."IHW_Id" 
            AND b."AMST_Id" = YS."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON b."AMST_Id" = d."AMST_Id" 
            AND d."MI_Id" = "MI_Id"
        WHERE a."MI_Id" = "MI_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND a."IVRMUL_Id" = "Login_Id"
        ORDER BY b."UpdatedDate" DESC;

    ELSIF "Parameter" = 'Classwork' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."ICW_Id" AS id,
            b."AMST_Id",
            (COALESCE(d."AMST_FirstName", '') || COALESCE(d."AMST_MiddleName", '') || COALESCE(d."AMST_LastName", '')) AS studentname,
            a."ICW_Topic" AS topic,
            a."ICW_SubTopic" AS assignment_or_subtopic,
            b."ICWUPL_Marks" AS marks,
            (SELECT e."ISMS_SubjectName" 
             FROM "IVRM_Master_Subjects" e 
             WHERE e."ISMS_Id" = a."ISMS_Id" AND e."MI_Id" = "MI_Id") AS "ISMS_SubjectName",
            b."UpdatedDate"
        FROM "IVRM_Assignment" a
        INNER JOIN "Adm_school_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
            AND YS."ASMCL_Id" = a."ASMCL_Id" 
            AND YS."ASMS_Id" = a."ASMS_Id" 
            AND YS."ASMAY_Id" = "ASMAY_Id"
        INNER JOIN "IVRM_ClassWork_Upload" b ON a."ICW_Id" = b."ICW_Id" 
            AND b."AMST_Id" = YS."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON b."AMST_Id" = d."AMST_Id"
        WHERE a."ASMAY_Id" = "ASMAY_Id" 
            AND a."MI_Id" = "MI_Id" 
            AND a."Login_Id" = "Login_Id"
        ORDER BY b."UpdatedDate" DESC;

    END IF;

END;
$$;