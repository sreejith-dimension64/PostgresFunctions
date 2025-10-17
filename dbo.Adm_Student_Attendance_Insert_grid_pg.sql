CREATE OR REPLACE FUNCTION "Adm_Student_Attendance_Insert_grid"(
    "@MI_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@date" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_FromDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Resultdata" TEXT;
BEGIN
    "@Resultdata" := '
    SELECT DISTINCT B."AMST_Id", C."ASMCL_Id", C."ASMS_Id", 
    (B."AMST_FirstName" || '' '' || B."AMST_MiddleName" || '' '' || B."AMST_LastName") as "StudentName",
    B."AMST_AdmNo", A."ASMCL_ClassName", D."ASMC_SectionName", E."ASA_FromDate"
    FROM "Adm_m_Student" B
    INNER JOIN "Adm_School_Y_Student" C ON C."AMST_ID" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Class" A ON A."ASMCL_Id" = C."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" D ON D."ASMS_Id" = C."ASMS_Id"
    INNER JOIN "Adm_Student_Attendance" E ON E."ASMCL_Id" = A."ASMCL_Id" AND E."ASMS_Id" = D."ASMS_Id"
    INNER JOIN "Adm_Student_Attendance_Students" F ON F."ASA_Id" = E."ASA_Id"
    WHERE B."MI_Id" = ' || "@MI_Id" || ' AND C."ASMAY_Id" = ' || "@ASMAY_Id" || '
    AND A."ASMCL_Id" IN (' || "@ASMCL_Id" || ') AND D."ASMS_Id" IN (' || "@ASMS_Id" || ') 
    AND E."ASA_FromDate" = ''' || "@date" || '''
    AND B."AMST_ActiveFlag" = 1 AND A."ASMCL_ActiveFlag" = 1 AND C."AMAY_ActiveFlag" = 1
    ORDER BY C."ASMCL_Id", C."ASMS_Id"';
    
    RETURN QUERY EXECUTE "@Resultdata";
    
END;
$$;