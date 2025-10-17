CREATE OR REPLACE FUNCTION "FeeDefaulterEmailTrigger"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "Amount" NUMERIC,
    "FMG_GroupName" VARCHAR,
    "FMT_Name" VARCHAR,
    "FMG_Id" BIGINT,
    "FMT_Id" BIGINT,
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "AMST_FatherName" VARCHAR,
    "AMST_emailId" VARCHAR,
    "FMTFHDD_DueDate" DATE,
    "ClassSection" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "D"."AMST_Id", 
        SUM("B"."FSS_ToBePaid") AS "Amount",
        "A"."FMG_GroupName",
        "G"."FMT_Name",
        "A"."FMG_Id",
        "G"."FMT_Id",
        COALESCE("D"."AMST_FirstName", '') || ' ' || COALESCE("D"."AMST_MiddleName", '') || ' ' || COALESCE("D"."AMST_LastName", '') AS "StudentName",
        "D"."AMST_AdmNo", 
        "D"."AMST_MobileNo", 
        "D"."AMST_FatherName",
        "D"."AMST_emailId",
        CAST("H"."FMTFHDD_DueDate" AS DATE) AS "FMTFHDD_DueDate",
        ("J"."ASMCL_ClassName" || ':' || "K"."ASMC_SectionName") AS "ClassSection"
    FROM "Fee_Master_Group" "A"
    INNER JOIN "Fee_Student_Status" "B" ON "A"."FMG_Id" = "B"."FMG_Id"
    INNER JOIN "Fee_Master_Head" "C" ON "B"."FMH_Id" = "C"."FMH_Id"
    INNER JOIN "Adm_M_Student" "D" ON "D"."AMST_Id" = "B"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" "E" ON "E"."AMST_Id" = "D"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" "J" ON "J"."ASMCL_Id" = "E"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "K" ON "K"."ASMS_Id" = "E"."ASMS_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" "F" ON "F"."FMH_Id" = "B"."FMH_Id"
    INNER JOIN "Fee_Master_Terms" "G" ON "G"."FMT_Id" = "F"."FMT_Id" AND "B"."FTI_Id" = "F"."FTI_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads_DueDate" "H" ON "F"."FMTFH_Id" = "H"."FMTFH_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "I" ON "I"."ASMAY_Id" = "E"."ASMAY_Id" AND "I"."ASMAY_Id" = "B"."ASMAY_Id"
    WHERE "I"."ASMAY_Id" = p_ASMAY_Id 
        AND "I"."MI_Id" = p_MI_Id 
        AND CAST("H"."FMTFHDD_DueDate" AS DATE) <= CURRENT_DATE
    GROUP BY 
        "J"."ASMCL_ClassName",
        "K"."ASMC_SectionName",
        "A"."FMG_GroupName",
        "G"."FMT_Name",
        "A"."FMG_Id", 
        "G"."FMT_Id",
        "D"."AMST_MobileNo",
        "D"."AMST_FirstName",
        "D"."AMST_MiddleName",
        "D"."AMST_LastName",
        "D"."AMST_AdmNo", 
        "D"."AMST_FatherName",
        "D"."AMST_emailId",
        "D"."AMST_Id",
        "H"."FMTFHDD_DueDate",
        "A"."MI_Id";
END;
$$;