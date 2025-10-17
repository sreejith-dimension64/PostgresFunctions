CREATE OR REPLACE FUNCTION "dbo"."excesspaiddetails"(
    "Mi_Id" BIGINT,
    "ASMAY_Id" BIGINT
)
RETURNS TABLE(
    "FMG_GroupName" VARCHAR,
    "FMH_FeeName" VARCHAR,
    "Name" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "FSS_RunningExcessAmount" NUMERIC,
    "AMST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."FMG_GroupName",
        e."FMH_FeeName",
        (c."AMST_FirstName" || ' ' || c."AMST_MiddleName" || ' ' || c."AMST_LastName") AS "Name",
        c."AMST_AdmNo",
        f."ASMCL_ClassName",
        g."ASMC_SectionName",
        SUM(a."FSS_RunningExcessAmount") AS "FSS_RunningExcessAmount",
        a."AMST_Id"
    FROM "dbo"."fee_student_status" AS a
    INNER JOIN "dbo"."fee_master_group" AS b ON a."fmg_id" = b."FMG_Id"
    INNER JOIN "dbo"."fee_master_head" AS e ON e."FMH_Id" = a."FMH_Id"
    INNER JOIN "dbo"."Adm_M_Student" AS c ON c."AMST_Id" = a."AMST_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" AS d ON d."AMST_Id" = c."AMST_Id" AND a."ASMAY_Id" = d."ASMAY_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" AS f ON f."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" AS g ON g."ASMS_Id" = d."ASMS_Id"
    WHERE a."MI_Id" = "Mi_Id" AND a."ASMAY_Id" = "ASMAY_Id" AND a."FSS_RunningExcessAmount" > 0
    GROUP BY a."AMST_Id", b."FMG_GroupName", e."FMH_FeeName", c."AMST_FirstName", c."AMST_MiddleName", c."AMST_LastName", c."AMST_AdmNo", f."ASMCL_ClassName", g."ASMC_SectionName"
    ORDER BY f."ASMCL_ClassName", g."ASMC_SectionName", c."AMST_FirstName";
END;
$$;