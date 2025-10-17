CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeclasswork_List"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_AMST_Id text,
    p_Login_Id bigint,
    p_Parameter text
)
RETURNS TABLE (
    work_id bigint,
    "AMST_Id" bigint,
    studentname text,
    topic text,
    subtopic text,
    assignment text,
    fromdate timestamp,
    todate timestamp,
    "ISMS_SubjectName" varchar,
    "FilesCount" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlexec text;
BEGIN
    IF p_Parameter = 'Homework' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."IHW_Id" AS work_id,
            d."AMST_Id",
            (COALESCE(d."AMST_FirstName", '') || COALESCE(d."AMST_MiddleName", '') || COALESCE(d."AMST_LastName", '')) AS studentname,
            e."IHW_Topic" AS topic,
            NULL::text AS subtopic,
            e."IHW_Assignment" AS assignment,
            e."IHW_Date" AS fromdate,
            NULL::timestamp AS todate,
            f."ISMS_SubjectName",
            (SELECT COUNT(*) FROM "IVRM_HomeWork_Attatchment" HA WHERE HA."IHW_Id" = e."IHW_Id") AS "FilesCount"
        FROM "Adm_School_Y_Student" a
        INNER JOIN "IVRM_HomeWork_Upload" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = a."AMST_Id"
        INNER JOIN "IVRM_HomeWork" e ON e."IHW_Id" = b."IHW_Id"
        INNER JOIN "IVRM_Master_Subjects" f ON f."ISMS_Id" = e."ISMS_Id"
        WHERE a."ASMCL_Id" = p_ASMCL_Id 
            AND a."ASMS_Id" = p_ASMS_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id
            AND f."MI_Id" = p_MI_Id 
            AND e."IVRMUL_Id" = p_Login_Id
        ORDER BY b."IHW_Id" DESC;
        
    ELSIF p_Parameter = 'Classwork' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."ICW_Id" AS work_id,
            d."AMST_Id",
            (COALESCE(d."AMST_FirstName", '') || COALESCE(d."AMST_MiddleName", '') || COALESCE(d."AMST_LastName", '')) AS studentname,
            e."ICW_Topic" AS topic,
            e."ICW_SubTopic" AS subtopic,
            e."ICW_Assignment" AS assignment,
            e."ICW_FromDate" AS fromdate,
            e."ICW_ToDate" AS todate,
            f."ISMS_SubjectName",
            (SELECT COUNT(*) FROM "IVRM_ClassWork_Attatchment" CA WHERE CA."ICW_Id" = e."ICW_Id") AS "FilesCount"
        FROM "Adm_School_Y_Student" a
        INNER JOIN "IVRM_ClassWork_Upload" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = a."AMST_Id"
        INNER JOIN "IVRM_Assignment" e ON e."ICW_Id" = b."ICW_Id"
        INNER JOIN "IVRM_Master_Subjects" f ON f."ISMS_Id" = e."ISMS_Id"
        WHERE a."ASMCL_Id" = p_ASMCL_Id 
            AND a."ASMS_Id" = p_ASMS_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id
            AND f."MI_Id" = p_MI_Id 
            AND e."Login_Id" = p_Login_Id
        ORDER BY b."ICW_Id" DESC;
    END IF;
END;
$$;