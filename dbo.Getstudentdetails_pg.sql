CREATE OR REPLACE FUNCTION "dbo"."Getstudentdetails"(p_MI_Id bigint)
RETURNS TABLE(
    "ALSREG_Id" bigint,
    "ALSREG_MemberName" text,
    "Admit_year" text,
    "Left_year" text,
    "Admit_class" text,
    "Left_class" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS student_temp1;
    DROP TABLE IF EXISTS student_temp2;

    CREATE TEMP TABLE student_temp1 AS
    SELECT DISTINCT 
        a."ALSREG_Id",
        a."ALSREG_MemberName",
        c."ASMAY_Year",
        b."ASMCL_ClassName"
    FROM 
        "ALU"."Alumni_Student_Registration" a,
        "Adm_School_M_Class" b,
        "Adm_School_M_Academic_Year" c
    WHERE 
        a."ALSREG_AdmittedYear" = c."ASMAY_Id" 
        AND a."ALSREG_AdmittedClass" = b."ASMCL_Id"
        AND a."MI_Id" = p_MI_Id 
        AND a."ALSREG_ApprovedFlag" = 0 
        AND a."ALSREG_ActiveFlg" = 1
    ORDER BY a."ALSREG_Id" DESC;

    CREATE TEMP TABLE student_temp2 AS
    SELECT DISTINCT 
        a."ALSREG_Id",
        a."ALSREG_MemberName",
        c."ASMAY_Year",
        b."ASMCL_ClassName"
    FROM 
        "ALU"."Alumni_Student_Registration" a,
        "Adm_School_M_Class" b,
        "Adm_School_M_Academic_Year" c
    WHERE 
        a."ALSREG_LeftYear" = c."ASMAY_Id"
        AND a."ALSREG_LeftClass" = b."ASMCL_Id"
        AND a."MI_Id" = p_MI_Id 
        AND a."ALSREG_ApprovedFlag" = 0 
        AND a."ALSREG_ActiveFlg" = 1
    ORDER BY a."ALSREG_Id" DESC;

    RETURN QUERY
    SELECT 
        a."ALSREG_Id",
        a."ALSREG_MemberName",
        a."ASMAY_Year" AS "Admit_year",
        b."ASMAY_Year" AS "Left_year",
        a."ASMCL_ClassName" AS "Admit_class",
        b."ASMCL_ClassName" AS "Left_class"
    FROM 
        student_temp1 a,
        student_temp2 b
    WHERE 
        a."ALSREG_Id" = b."ALSREG_Id"
    ORDER BY a."ALSREG_Id" DESC;

    DROP TABLE IF EXISTS student_temp1;
    DROP TABLE IF EXISTS student_temp2;
END;
$$;