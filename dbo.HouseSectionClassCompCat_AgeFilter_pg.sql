CREATE OR REPLACE FUNCTION "dbo"."HouseSectionClassCompCat_AgeFilter"(
    p_MI_Id bigint,
    p_SPCCMCC_Id bigint,
    p_ASMAY_Id bigint,
    p_clss_Ids text,
    p_sect_Ids text,
    p_house_Ids text
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
    v_AMST_Id bigint;
    v_AdmNo varchar(50);
    v_sqldynamic text;
    v_SPCCMH_Id bigint;
    rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "StudentMappingHouseSectionClassCompCatwiseAgeedit";
    DROP TABLE IF EXISTS "SectionHouseClassCompCatStudents";

    CREATE TEMP TABLE "StudentMappingHouseSectionClassCompCatwiseAgeedit"(
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
    CREATE TEMP TABLE "SectionHouseClassCompCatStudents" AS
    SELECT 
        (365*CAST(split_part("SPCCSH_Age_Format",''-'',1) AS INTEGER) + 
         30*CAST(split_part("SPCCSH_Age_Format",''-'',2) AS INTEGER) + 
         CAST(split_part("SPCCSH_Age_Format",''-'',3) AS INTEGER)) AS "Tdays",
        "ASMCL_Id",
        "ASMS_Id",
        "SPCCMH_Id",
        "AMST_Id"
    FROM "SPC"."SPCC_Student_House" 
    WHERE "MI_Id" = ' || p_MI_Id || ' 
        AND "ASMAY_Id" = ' || p_ASMAY_Id || ' 
        AND "SPCCMH_ActiveFlag" = true 
        AND "ASMCL_Id" IN (' || p_clss_Ids || ') 
        AND "ASMS_Id" IN (' || p_sect_Ids || ') 
        AND "SPCCMH_Id" IN (' || p_house_Ids || ')
        AND (365*CAST(split_part("SPCCSH_Age_Format",''-'',1) AS INTEGER) + 
             30*CAST(split_part("SPCCSH_Age_Format",''-'',2) AS INTEGER) + 
             CAST(split_part("SPCCSH_Age_Format",''-'',3) AS INTEGER)) >= ' || v_FromDays || '
        AND (365*CAST(split_part("SPCCSH_Age_Format",''-'',1) AS INTEGER) + 
             30*CAST(split_part("SPCCSH_Age_Format",''-'',2) AS INTEGER) + 
             CAST(split_part("SPCCSH_Age_Format",''-'',3) AS INTEGER)) <= ' || v_ToDays;

    EXECUTE v_sqldynamic;

    FOR rec IN 
        SELECT "Tdays", "ASMCL_Id", "ASMS_Id", "SPCCMH_Id", "AMST_Id" 
        FROM "SectionHouseClassCompCatStudents"
    LOOP
        v_Tdays := rec."Tdays";
        v_ASMCL_Id := rec."ASMCL_Id";
        v_ASMS_Id := rec."ASMS_Id";
        v_SPCCMH_Id := rec."SPCCMH_Id";
        v_AMST_Id := rec."AMST_Id";

        SELECT "AMST_AdmNo" INTO v_AdmNo
        FROM "Adm_M_Student" 
        WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = v_AMST_Id;

        INSERT INTO "StudentMappingHouseSectionClassCompCatwiseAgeedit"(
            "ASMCL_Id", "ASMS_Id", "SPCCMH_Id", "AMST_Id", "AMST_AdmNo"
        ) 
        VALUES (v_ASMCL_Id, v_ASMS_Id, v_SPCCMH_Id, v_AMST_Id, v_AdmNo);
    END LOOP;

    RETURN QUERY 
    SELECT 
        s."ASMCL_Id",
        s."ASMS_Id",
        s."SPCCMH_Id",
        s."AMST_Id",
        s."AMST_AdmNo"
    FROM "StudentMappingHouseSectionClassCompCatwiseAgeedit" s;

    DROP TABLE IF EXISTS "StudentMappingHouseSectionClassCompCatwiseAgeedit";
    DROP TABLE IF EXISTS "SectionHouseClassCompCatStudents";

END;
$$;