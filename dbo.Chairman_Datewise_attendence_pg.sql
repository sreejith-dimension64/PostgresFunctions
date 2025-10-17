CREATE OR REPLACE FUNCTION "dbo"."Chairman_Datewise_attendence"(
    "MI_Id" INT,
    "ASMAY_Id" INT,
    "ASMCL_Id" INT,
    "ASMS_Id" INT,
    "FRM_DATE" DATE,
    "TO_DATE" DATE,
    "CONDITION" VARCHAR(50),
    "VALUE" DECIMAL
)
RETURNS TABLE(
    "AMST_Id" INT,
    "name" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMAY_RollNo" VARCHAR,
    "TOTAL_PRESENT" NUMERIC,
    "CLASS_HELD" VARCHAR,
    "per" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS "#pvn" AS
    SELECT 
        a."AMST_Id",
        a."name",
        a."AMST_AdmNo",
        a."AMAY_RollNo",
        a."TOTAL_PRESENT",
        a."CLASS_HELD",
        a."per"
    FROM (
        SELECT
            b."AMST_Id",
            (REPLACE(REPLACE(REPLACE(COALESCE(d."AMST_FirstName",''),'.',''),'$',''),'0','') || ' ' || 
             REPLACE(REPLACE(REPLACE(COALESCE(d."AMST_MiddleName",''),'.',''),'$',''),'0','') || ' ' || 
             REPLACE(REPLACE(REPLACE(COALESCE(d."AMST_LastName",''),'.',''),'$',''),'0','')) AS "name",
            d."AMST_AdmNo",
            c."AMAY_RollNo",
            SUM(b."ASA_Class_Attended") AS "TOTAL_PRESENT",
            CAST(CAST(ROUND(SUM(a."ASA_ClassHeld"),0) AS INT) AS VARCHAR) AS "CLASS_HELD",
            (SUM(b."ASA_Class_Attended") / CAST(CAST(ROUND(SUM(a."ASA_ClassHeld"),0) AS INT) AS NUMERIC) * 100) AS "per"
        FROM "Adm_Student_Attendance" a
        INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
        INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
        WHERE a."MI_Id" = "MI_Id" 
            AND c."ASMAY_Id" = "ASMAY_Id" 
            AND a."asa_fromdate" BETWEEN "FRM_DATE" AND "TO_DATE"
            AND c."ASMCL_Id" = "ASMCL_Id" 
            AND c."ASMS_Id" = "ASMS_Id"
        GROUP BY b."AMST_Id", c."ASMCL_Id", c."ASMS_Id", d."AMST_FirstName", 
                 d."AMST_MiddleName", d."AMST_LastName", d."AMST_AdmNo", c."AMAY_RollNo"
    ) AS a;

    IF "CONDITION" = '=' THEN
        RETURN QUERY SELECT * FROM "#pvn" WHERE "#pvn"."per" = "VALUE";
    ELSIF "CONDITION" = '<' THEN
        RETURN QUERY SELECT * FROM "#pvn" WHERE "#pvn"."per" < "VALUE";
    ELSIF "CONDITION" = '<=' THEN
        RETURN QUERY SELECT * FROM "#pvn" WHERE "#pvn"."per" <= "VALUE";
    ELSIF "CONDITION" = '>' THEN
        RETURN QUERY SELECT * FROM "#pvn" WHERE "#pvn"."per" > "VALUE";
    ELSIF "CONDITION" = '>=' THEN
        RETURN QUERY SELECT * FROM "#pvn" WHERE "#pvn"."per" >= "VALUE";
    END IF;

    DROP TABLE IF EXISTS "#pvn";
    
    RETURN;
END;
$$;