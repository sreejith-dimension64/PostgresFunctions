CREATE OR REPLACE FUNCTION "dbo"."Admission_Get_Tpin_Student_List"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_Flag BIGINT
)
RETURNS TABLE(
    studentname TEXT,
    admno VARCHAR,
    classname VARCHAR,
    sectionname VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    tpin VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_Flag = 1 THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "A"."AMST_FirstName" IS NULL OR "A"."AMST_FirstName" = '' THEN '' ELSE "A"."AMST_FirstName" END || 
            CASE WHEN "A"."AMST_MiddleName" IS NULL OR "A"."AMST_MiddleName" = '' THEN '' ELSE ' ' || "A"."AMST_MiddleName" END || 
            CASE WHEN "A"."AMST_LastName" IS NULL OR "A"."AMST_LastName" = '' THEN '' ELSE ' ' || "A"."AMST_LastName" END)::TEXT AS studentname,
            "A"."AMST_AdmNo" AS admno,
            "D"."ASMCL_ClassName" AS classname,
            "E"."ASMC_SectionName" AS sectionname,
            "D"."ASMCL_Order",
            "E"."ASMC_Order",
            NULL::VARCHAR AS tpin
        FROM "Adm_M_Student" "A"
        INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "B"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id" = "B"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id" = "B"."ASMS_Id"
        WHERE "B"."ASMAY_Id" = p_ASMAY_Id 
            AND "A"."MI_Id" = p_MI_Id 
            AND "A"."AMST_SOL" = 'S' 
            AND "A"."AMST_ActiveFlag" = 1 
            AND "B"."AMAY_ActiveFlag" = 1
            AND ("A"."AMST_Tpin" IS NULL OR "A"."AMST_Tpin" = '0')
        ORDER BY "D"."ASMCL_Order", "E"."ASMC_Order", studentname;

    ELSIF p_Flag = 2 THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "A"."AMST_FirstName" IS NULL OR "A"."AMST_FirstName" = '' THEN '' ELSE "A"."AMST_FirstName" END || 
            CASE WHEN "A"."AMST_MiddleName" IS NULL OR "A"."AMST_MiddleName" = '' THEN '' ELSE ' ' || "A"."AMST_MiddleName" END || 
            CASE WHEN "A"."AMST_LastName" IS NULL OR "A"."AMST_LastName" = '' THEN '' ELSE ' ' || "A"."AMST_LastName" END)::TEXT AS studentname,
            "A"."AMST_AdmNo" AS admno,
            "D"."ASMCL_ClassName" AS classname,
            "E"."ASMC_SectionName" AS sectionname,
            "D"."ASMCL_Order",
            "E"."ASMC_Order",
            "A"."AMST_Tpin" AS tpin
        FROM "Adm_M_Student" "A"
        INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "B"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id" = "B"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id" = "B"."ASMS_Id"
        WHERE "B"."ASMAY_Id" = p_ASMAY_Id 
            AND "A"."MI_Id" = p_MI_Id 
            AND "A"."AMST_SOL" = 'S' 
            AND "A"."AMST_ActiveFlag" = 1 
            AND "B"."AMAY_ActiveFlag" = 1
            AND "A"."AMST_Tpin" IS NOT NULL 
            AND "A"."AMST_Tpin" != '0'
        ORDER BY "D"."ASMCL_Order", "E"."ASMC_Order", studentname;

    END IF;

    RETURN;
END;
$$;