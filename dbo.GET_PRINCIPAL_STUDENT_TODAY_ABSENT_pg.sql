CREATE OR REPLACE FUNCTION "dbo"."GET_PRINCIPAL_STUDENT_TODAY_ABSENT"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    stdname text,
    "ASMCL_Id" bigint,
    "ASMCL_ClassName" varchar,
    "ASMS_Id" bigint,
    "ASMC_SectionName" varchar,
    "AMST_AdmNo" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        C."AMST_Id",
        CONCAT(C."AMST_FirstName",' ',C."AMST_MiddleName",' ',C."AMST_LastName") AS stdname,
        A."ASMCL_Id",
        D."ASMCL_ClassName",
        A."ASMS_Id",
        E."ASMC_SectionName",
        C."AMST_AdmNo"
    FROM "Adm_Student_Attendance" AS A 
    INNER JOIN "Adm_Student_Attendance_Students" AS B ON A."ASA_Id" = B."ASA_Id"
    INNER JOIN "Adm_M_Student" AS C ON C."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Class" AS D ON D."ASMCL_Id" = A."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" AS E ON E."ASMS_Id" = A."ASMS_Id"
    WHERE A."ASMAY_Id" = p_ASMAY_Id 
        AND A."ASA_Activeflag" = 1 
        AND B."ASA_Class_Attended" = 0 
        AND DATE(A."ASA_FromDate") = CURRENT_DATE
        AND A."MI_Id" = p_MI_Id 
        AND C."MI_Id" = p_MI_Id 
        AND C."AMST_SOL" = 'S' 
        AND C."AMST_ActiveFlag" = 1;
END;
$$;