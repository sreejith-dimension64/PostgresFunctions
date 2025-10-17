CREATE OR REPLACE FUNCTION "dbo"."EDIT_Live_meeting_data"(
    p_meetingid BIGINT
)
RETURNS TABLE(
    classname VARCHAR,
    sectioname VARCHAR,
    subjectname VARCHAR,
    classid BIGINT,
    sectionid BIGINT,
    subjectid BIGINT,
    clcode VARCHAR,
    seccode VARCHAR,
    subcode VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "c"."ASMCL_ClassName" AS classname,
        "d"."ASMC_SectionName" AS sectioname,
        "e"."ISMS_SubjectName" AS subjectname,
        "b"."ASMCL_Id" AS classid,
        "b"."ASMS_Id" AS sectionid,
        "b"."ISMS_Id" AS subjectid,
        "c"."ASMCL_ClassCode" AS clcode,
        "d"."ASMC_SectionCode" AS seccode,
        "e"."ISMS_SubjectCode" AS subcode
    FROM "LMS_Live_Meeting" "a"
    INNER JOIN "LMS_Live_Meeting_Class" "b" ON "a"."LMSLMEET_Id" = "b"."LMSLMEET_Id"
    INNER JOIN "Adm_School_M_Class" "c" ON "b"."ASMCL_Id" = "c"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "d" ON "b"."ASMS_Id" = "d"."ASMS_Id"
    INNER JOIN "IVRM_Master_Subjects" "e" ON "b"."ISMS_Id" = "e"."ISMS_Id"
    WHERE "a"."LMSLMEET_Id" = p_meetingid;
END;
$$;