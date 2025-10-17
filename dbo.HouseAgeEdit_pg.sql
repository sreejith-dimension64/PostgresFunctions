CREATE OR REPLACE FUNCTION "dbo"."HouseAgeEdit"(
    p_MI_Id bigint,
    p_SPCCMCC_Id bigint,
    p_ASMAY_Id bigint,
    p_SPCCMH_Id text
)
RETURNS TABLE(
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "SPCCMH_Id" bigint,
    "AMST_Id" bigint,
    "AMST_AdmNo" varchar(40)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_FromDays bigint;
    v_ToDays bigint;
    v_Tdays bigint;
    v_ASMCL_Id bigint;
    v_ASMS_Id bigint;
    v_SPCCMH_Id bigint;
    v_AMST_Id bigint;
    v_AdmNo varchar(50);
    v_sqldynamic text;
    student_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "StudentMappingAgeedit";
    DROP TABLE IF EXISTS "HouseStudents";

    CREATE TEMP TABLE "StudentMappingAgeedit"(
        "ASMCL_Id" bigint,
        "ASMS_Id" bigint,
        "SPCCMH_Id" bigint,
        "AMST_Id" bigint,
        "AMST_AdmNo" varchar(40)
    );

    SELECT 
        ("SPCCMCC_FromCCAgeYear"*365 + "SPCCMCC_FromCCAgeMonth"*30 + "SPCCMCC_FromCCAgeDays"),
        ("SPCCMCC_ToCCAgeYear"*365 + 30*"SPCCMCC_ToCCAgeMonth" + "SPCCMCC_ToCCAgeDays")
    INTO v_FromDays, v_ToDays
    FROM "SPC"."SPCC_Master_Compition_Category" 
    WHERE "MI_Id" = p_MI_Id AND "SPCCMCC_Id" = p_SPCCMCC_Id;

    v_sqldynamic := '
    CREATE TEMP TABLE "HouseStudents" AS
    SELECT 
        (365*CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',1) AS INTEGER) + 
         30*CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',2) AS INTEGER) + 
         CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',3) AS INTEGER)) AS "Tdays",
        "ASMCL_Id",
        "ASMS_Id",
        "SPCCMH_Id",
        "AMST_Id"
    FROM "SPC"."SPCC_Student_House" 
    WHERE "MI_Id" = ' || p_MI_Id || ' 
        AND "ASMAY_Id" = ' || p_ASMAY_Id || ' 
        AND "SPCCMH_ActiveFlag" = 1 
        AND "SPCCMH_Id" IN (' || p_SPCCMH_Id || ')
        AND (365*CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',1) AS INTEGER) + 
             30*CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',2) AS INTEGER) + 
             CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',3) AS INTEGER)) >= ' || v_FromDays || '
        AND (365*CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',1) AS INTEGER) + 
             30*CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',2) AS INTEGER) + 
             CAST(split_part(REPLACE("SPCCSH_Age_Format",''-'',''.''),''.'',3) AS INTEGER)) <= ' || v_ToDays;

    EXECUTE v_sqldynamic;

    FOR student_rec IN 
        SELECT "Tdays", "ASMCL_Id", "ASMS_Id", "SPCCMH_Id", "AMST_Id" 
        FROM "HouseStudents"
    LOOP
        v_Tdays := student_rec."Tdays";
        v_ASMCL_Id := student_rec."ASMCL_Id";
        v_ASMS_Id := student_rec."ASMS_Id";
        v_SPCCMH_Id := student_rec."SPCCMH_Id";
        v_AMST_Id := student_rec."AMST_Id";

        SELECT "AMST_AdmNo" INTO v_AdmNo
        FROM "Adm_M_Student" 
        WHERE "MI_Id" = p_MI_Id;

        INSERT INTO "StudentMappingAgeedit"("ASMCL_Id", "ASMS_Id", "SPCCMH_Id", "AMST_Id", "AMST_AdmNo")  
        VALUES(v_ASMCL_Id, v_ASMS_Id, v_SPCCMH_Id, v_AMST_Id, v_AdmNo);

    END LOOP;

    RETURN QUERY SELECT * FROM "StudentMappingAgeedit";

END;
$$;