CREATE OR REPLACE FUNCTION "dbo"."ADM_Student_Punch_InoutDetails"(
    "AMST_ID" TEXT,
    "FROMDATE" VARCHAR(10),
    "TODATE" VARCHAR(10),
    "FLAG" VARCHAR(1),
    "individual" VARCHAR(10)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "MI_Id" BIGINT,
    "AMST_FirstName" TEXT,
    "ASPU_PunchDate" DATE,
    "ASPU_ManualEntryFlg" INTEGER,
    "ASPUD_PunchTime" TIME,
    "ASPUD_InOutFlg" VARCHAR(1),
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "Intime" TIME,
    "Outtime" TIME,
    "RNO" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "DYNAMIC" TEXT;
BEGIN
    IF("FLAG" = 'A') THEN
        "DYNAMIC" := '
        WITH Employee AS (
            SELECT A."AMST_Id", A."MI_Id", 
                   COALESCE(A."AMST_FirstName", '''') || '' '' || COALESCE(A."AMST_MiddleName", '''') || '' '' || COALESCE(A."AMST_LastName", '' '') AS "AMST_FirstName",
                   B."ASPU_PunchDate", B."ASPU_ManualEntryFlg"
            FROM "Adm_M_Student" A
            INNER JOIN "Adm_Student_Punch" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_Student_Punch_Details" C ON B."ASPU_Id" = C."ASPU_Id"
            WHERE A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = ''S'' 
                AND B."AMST_ID" IN (' || "AMST_ID" || ') 
                AND B."ASPU_PunchDate" BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || '''
        ),
        Intime AS (
            SELECT A."AMST_Id", A."MI_Id",
                   COALESCE(A."AMST_FirstName", '''') || '' '' || COALESCE(A."AMST_MiddleName", '''') || '' '' || COALESCE(A."AMST_LastName", '' '') AS "AMST_FirstName",
                   B."ASPU_PunchDate", B."ASPU_ManualEntryFlg", C."ASPUD_PunchTime" AS "Intime"
            FROM "Adm_M_Student" A
            INNER JOIN "Adm_Student_Punch" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_Student_Punch_Details" C ON B."ASPU_Id" = C."ASPU_Id"
            WHERE A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = ''S'' 
                AND B."AMST_ID" IN (' || "AMST_ID" || ') 
                AND C."ASPUD_InOutFlg" = ''I''
                AND B."ASPU_PunchDate" BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || '''
        ),
        Outtime AS (
            SELECT A."AMST_Id", A."MI_Id",
                   COALESCE(A."AMST_FirstName", '''') || '' '' || COALESCE(A."AMST_MiddleName", '''') || '' '' || COALESCE(A."AMST_LastName", '' '') AS "AMST_FirstName",
                   B."ASPU_PunchDate", B."ASPU_ManualEntryFlg", C."ASPUD_PunchTime" AS "Outtime"
            FROM "Adm_M_Student" A
            INNER JOIN "Adm_Student_Punch" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_Student_Punch_Details" C ON B."ASPU_Id" = C."ASPU_Id"
            WHERE A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = ''S'' 
                AND B."AMST_ID" IN (' || "AMST_ID" || ') 
                AND C."ASPUD_InOutFlg" = ''O''
                AND B."ASPU_PunchDate" BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || '''
        )
        SELECT A."AMST_Id", A."MI_Id", A."AMST_FirstName", A."ASPU_PunchDate", A."ASPU_ManualEntryFlg", 
               NULL::TIME AS "ASPUD_PunchTime", NULL::VARCHAR(1) AS "ASPUD_InOutFlg", 
               NULL::TEXT AS "ASMCL_ClassName", NULL::TEXT AS "ASMC_SectionName",
               A."Intime", A."Outtime", A."RNO"
        FROM (
            SELECT ROW_NUMBER() OVER(PARTITION BY EMP."AMST_Id", EMP."MI_Id", EMP."AMST_FirstName", EMP."ASPU_PunchDate" 
                                     ORDER BY EMP."AMST_Id") AS "RNO",
                   EMP."AMST_Id", EMP."MI_Id", EMP."AMST_FirstName", EMP."ASPU_PunchDate", 
                   COALESCE(EMP."ASPU_ManualEntryFlg", 0) AS "ASPU_ManualEntryFlg", 
                   IT."Intime", OT."Outtime"
            FROM Employee EMP
            INNER JOIN Intime IT ON EMP."AMST_Id" = IT."AMST_Id" AND EMP."MI_Id" = IT."MI_Id" 
                AND EMP."AMST_FirstName" = IT."AMST_FirstName" AND EMP."ASPU_PunchDate" = IT."ASPU_PunchDate"
            INNER JOIN Outtime OT ON EMP."AMST_Id" = OT."AMST_Id" AND EMP."MI_Id" = OT."MI_Id" 
                AND EMP."AMST_FirstName" = OT."AMST_FirstName" AND EMP."ASPU_PunchDate" = OT."ASPU_PunchDate"
        ) A WHERE A."RNO" = 1';
        
        RETURN QUERY EXECUTE "DYNAMIC";
        
    ELSIF("FLAG" = 'I') THEN
        "DYNAMIC" := 'SELECT A."AMST_Id", A."MI_Id", 
                             COALESCE(A."AMST_FirstName", '''') || '' '' || COALESCE(A."AMST_MiddleName", '''') || '' '' || COALESCE(A."AMST_LastName", '' '') AS "AMST_FirstName",
                             B."ASPU_PunchDate", B."ASPU_ManualEntryFlg", C."ASPUD_PunchTime", C."ASPUD_InOutFlg", 
                             D."ASMCL_ClassName", E."ASMC_SectionName",
                             NULL::TIME AS "Intime", NULL::TIME AS "Outtime", NULL::BIGINT AS "RNO"
                      FROM "Adm_M_Student" A
                      INNER JOIN "Adm_Student_Punch" B ON A."AMST_Id" = B."AMST_Id"
                      INNER JOIN "Adm_Student_Punch_Details" C ON B."ASPU_Id" = C."ASPU_Id"
                      INNER JOIN "Adm_School_Y_Student" F ON A."AMST_Id" = F."AMST_Id"
                      INNER JOIN "Adm_School_M_Class" D ON A."ASMCL_Id" = D."ASMCL_Id"
                      INNER JOIN "Adm_School_M_Section" E ON F."ASMS_Id" = E."ASMS_Id"
                      WHERE C."ASPUD_InOutFlg" = ''I'' AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = ''S'' 
                        AND B."AMST_ID" IN (' || "AMST_ID" || ') 
                        AND B."ASPU_PunchDate" BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || '''
                      ORDER BY B."ASPU_PunchDate", D."ASMCL_ClassName", E."ASMC_SectionName", C."ASPUD_PunchTime", C."ASPUD_InOutFlg"';
        
        RETURN QUERY EXECUTE "DYNAMIC";
        
    ELSIF("FLAG" = 'O') THEN
        "DYNAMIC" := 'SELECT A."AMST_Id", A."MI_Id", 
                             COALESCE(A."AMST_FirstName", '''') || '' '' || COALESCE(A."AMST_MiddleName", '''') || '' '' || COALESCE(A."AMST_LastName", '' '') AS "AMST_FirstName",
                             B."ASPU_PunchDate", B."ASPU_ManualEntryFlg", C."ASPUD_PunchTime", C."ASPUD_InOutFlg", 
                             D."ASMCL_ClassName", E."ASMC_SectionName",
                             NULL::TIME AS "Intime", NULL::TIME AS "Outtime", NULL::BIGINT AS "RNO"
                      FROM "Adm_M_Student" A
                      INNER JOIN "Adm_Student_Punch" B ON A."AMST_Id" = B."AMST_Id"
                      INNER JOIN "Adm_Student_Punch_Details" C ON B."ASPU_Id" = C."ASPU_Id"
                      INNER JOIN "Adm_School_Y_Student" F ON A."AMST_Id" = F."AMST_Id"
                      INNER JOIN "Adm_School_M_Class" D ON A."ASMCL_Id" = D."ASMCL_Id"
                      INNER JOIN "Adm_School_M_Section" E ON F."ASMS_Id" = E."ASMS_Id"
                      WHERE C."ASPUD_InOutFlg" = ''O'' AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = ''S'' 
                        AND B."AMST_ID" IN (' || "AMST_ID" || ') 
                        AND B."ASPU_PunchDate" BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || '''
                      ORDER BY B."ASPU_PunchDate", D."ASMCL_ClassName", E."ASMC_SectionName", C."ASPUD_PunchTime", C."ASPUD_InOutFlg"';
        
        RETURN QUERY EXECUTE "DYNAMIC";
    END IF;
    
    RETURN;
END;
$$;