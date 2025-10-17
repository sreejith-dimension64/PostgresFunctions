CREATE OR REPLACE FUNCTION "dbo"."HM_student_Illness_Report"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMST_Id" TEXT,
    "REPORT_TYPE" TEXT
)
RETURNS TABLE(
    "studentName" TEXT,
    "admissionNo" VARCHAR,
    "AMST_Id" BIGINT,
    "yearName" VARCHAR,
    "className" VARCHAR,
    "sectionName" VARCHAR,
    "hmmilL_IllnessName" VARCHAR,
    "hmtilL_Date" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "REPORT_TYPE" = 'YearWise' THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "B"."AMST_FirstName" IS NULL THEN '' ELSE "B"."AMST_FirstName" END ||
            CASE WHEN "B"."AMST_MiddleName" IS NULL OR "B"."AMST_MiddleName" = '' THEN '' ELSE "B"."AMST_MiddleName" END ||
            CASE WHEN "B"."AMST_LastName" IS NULL OR "B"."AMST_LastName" = '' THEN '' ELSE "B"."AMST_LastName" END) AS "studentName",
            "B"."AMST_AdmNo" AS "admissionNo",
            "A"."AMST_Id",
            "C"."ASMAY_Year" AS "yearName",
            "D"."ASMCL_ClassName" AS "className",
            "E"."ASMC_SectionName" AS "sectionName",
            "F"."HMMILL_IllnessName" AS "hmmilL_IllnessName",
            "A"."HMTILL_Date" AS "hmtilL_Date"
        FROM "HM_T_Illness" "A" 
        INNER JOIN "Adm_M_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id" = "A"."ASMS_Id"
        INNER JOIN "HM_M_Illness" "F" ON "F"."HMMILL_Id" = "A"."HMMILL_Id"
        WHERE "A"."ASMAY_Id" = "ASMAY_Id" AND "F"."MI_Id" = "MI_Id" AND "B"."MI_Id" = "MI_Id";
    ELSE
        RETURN QUERY
        SELECT 
            (CASE WHEN "B"."AMST_FirstName" IS NULL THEN '' ELSE "B"."AMST_FirstName" END ||
            CASE WHEN "B"."AMST_MiddleName" IS NULL OR "B"."AMST_MiddleName" = '' THEN '' ELSE "B"."AMST_MiddleName" END ||
            CASE WHEN "B"."AMST_LastName" IS NULL OR "B"."AMST_LastName" = '' THEN '' ELSE "B"."AMST_LastName" END) AS "studentName",
            "B"."AMST_AdmNo" AS "admissionNo",
            "A"."AMST_Id",
            "C"."ASMAY_Year" AS "yearName",
            "D"."ASMCL_ClassName" AS "className",
            "E"."ASMC_SectionName" AS "sectionName",
            "F"."HMMILL_IllnessName" AS "hmmilL_IllnessName",
            "A"."HMTILL_Date" AS "hmtilL_Date"
        FROM "HM_T_Illness" "A" 
        INNER JOIN "Adm_M_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id" = "A"."ASMS_Id"
        INNER JOIN "HM_M_Illness" "F" ON "F"."HMMILL_Id" = "A"."HMMILL_Id"
        WHERE "A"."ASMAY_Id" = "ASMAY_Id" AND "F"."MI_Id" = "MI_Id" AND "B"."MI_Id" = "MI_Id" AND "A"."AMST_Id" = "AMST_Id";
    END IF;

    RETURN;

END;
$$;