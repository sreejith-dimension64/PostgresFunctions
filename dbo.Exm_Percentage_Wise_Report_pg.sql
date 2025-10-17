CREATE OR REPLACE FUNCTION "dbo"."Exm_Percentage_Wise_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_EMCA_Id" TEXT,
    "p_REPORT_TYPE" TEXT,
    "p_PERCENTAGE_FLAG" TEXT,
    "p_EME_Id" TEXT
)
RETURNS TABLE(
    "studentname" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "AMST_Id" BIGINT,
    "ESTMP_Percentage" NUMERIC,
    "ESTMP_TotalMaxMarks" NUMERIC,
    "ESTMP_TotalObtMarks" NUMERIC,
    "ESTMP_TotalGrade" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_GREATHERTHAN_PERCENTAGE" DECIMAL(18,2);
    "v_LESSTHAN_PERCENTAGE" DECIMAL(18,2);
    "v_ASMS_Id_INT" BIGINT;
BEGIN

    IF "p_PERCENTAGE_FLAG" = '1' THEN
        "v_GREATHERTHAN_PERCENTAGE" := 80.00;
        "v_LESSTHAN_PERCENTAGE" := 100.00;
    ELSIF "p_PERCENTAGE_FLAG" = '2' THEN
        "v_GREATHERTHAN_PERCENTAGE" := 60.00;
        "v_LESSTHAN_PERCENTAGE" := 80.00;
    ELSIF "p_PERCENTAGE_FLAG" = '3' THEN
        "v_GREATHERTHAN_PERCENTAGE" := 40.00;
        "v_LESSTHAN_PERCENTAGE" := 60.00;
    ELSIF "p_PERCENTAGE_FLAG" = '4' THEN
        "v_GREATHERTHAN_PERCENTAGE" := 30.00;
        "v_LESSTHAN_PERCENTAGE" := 40.00;
    ELSIF "p_PERCENTAGE_FLAG" = '5' THEN
        "v_GREATHERTHAN_PERCENTAGE" := 0.00;
        "v_LESSTHAN_PERCENTAGE" := 30.00;
    END IF;

    "v_ASMS_Id_INT" := "p_ASMS_Id"::BIGINT;

    IF "p_REPORT_TYPE" = 'all' THEN
        RETURN QUERY
        SELECT 
            (COALESCE("C"."AMST_FirstName", '') || ' ' || COALESCE("C"."AMST_MiddleName", '') || ' ' || COALESCE("C"."AMST_LastName", '') || ' : ' || COALESCE("C"."AMST_AdmNo", '')) AS "studentname",
            "E"."ASMCL_ClassName",
            "F"."ASMC_SectionName",
            "B"."ASMCL_Id",
            "B"."ASMS_Id",
            "E"."ASMCL_Order",
            "F"."ASMC_Order",
            "B"."AMST_Id",
            "A"."ESTMP_Percentage",
            "A"."ESTMP_TotalMaxMarks",
            "A"."ESTMP_TotalObtMarks",
            "A"."ESTMP_TotalGrade"
        FROM "Exm"."Exm_Student_Marks_Process" "A"
        INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_M_Student" "C" ON "C"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "D" ON "D"."ASMAY_Id" = "B"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "E" ON "E"."ASMCL_Id" = "B"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "F" ON "F"."ASMS_Id" = "B"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "G" ON "G"."EME_Id" = "A"."EME_Id"
        INNER JOIN "Exm"."Exm_Category_Class" "H" ON "H"."ASMAY_Id" = "D"."ASMAY_Id" AND "H"."ASMCL_Id" = "E"."ASMCL_Id" AND "H"."ASMS_Id" = "F"."ASMS_Id" AND "H"."ECAC_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Master_Category" "I" ON "I"."EMCA_Id" = "H"."EMCA_Id" AND "I"."EMCA_ActiveFlag" = 1
        WHERE "A"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND "A"."EME_Id" = "p_EME_Id"::BIGINT 
            AND "A"."ESTMP_Percentage" > "v_GREATHERTHAN_PERCENTAGE" 
            AND "A"."ESTMP_Percentage" <= "v_LESSTHAN_PERCENTAGE"
            AND "B"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND "B"."AMAY_ActiveFlag" IN (0, 1) 
            AND "C"."AMST_ACTIVEFLAG" IN (0, 1) 
            AND "C"."AMST_SOL" != 'Del' 
            AND "H"."EMCA_Id" = "p_EMCA_Id"::BIGINT
        ORDER BY "E"."ASMCL_Order", "F"."ASMC_Order", "studentname";
    ELSIF "p_REPORT_TYPE" != 'all' THEN
        IF "v_ASMS_Id_INT" > 0 THEN
            RETURN QUERY
            SELECT 
                (COALESCE("C"."AMST_FirstName", '') || ' ' || COALESCE("C"."AMST_MiddleName", '') || ' ' || COALESCE("C"."AMST_LastName", '') || ' : ' || COALESCE("C"."AMST_AdmNo", '')) AS "studentname",
                "E"."ASMCL_ClassName",
                "F"."ASMC_SectionName",
                "B"."ASMCL_Id",
                "B"."ASMS_Id",
                "E"."ASMCL_Order",
                "F"."ASMC_Order",
                "B"."AMST_Id",
                "A"."ESTMP_Percentage",
                "A"."ESTMP_TotalMaxMarks",
                "A"."ESTMP_TotalObtMarks",
                "A"."ESTMP_TotalGrade"
            FROM "Exm"."Exm_Student_Marks_Process" "A"
            INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
            INNER JOIN "Adm_M_Student" "C" ON "C"."AMST_Id" = "B"."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "D" ON "D"."ASMAY_Id" = "B"."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" "E" ON "E"."ASMCL_Id" = "B"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" "F" ON "F"."ASMS_Id" = "B"."ASMS_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "G" ON "G"."EME_Id" = "A"."EME_Id"
            INNER JOIN "Exm"."Exm_Category_Class" "H" ON "H"."ASMAY_Id" = "D"."ASMAY_Id" AND "H"."ASMCL_Id" = "E"."ASMCL_Id" AND "H"."ASMS_Id" = "F"."ASMS_Id" AND "H"."ECAC_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_Master_Category" "I" ON "I"."EMCA_Id" = "H"."EMCA_Id" AND "I"."EMCA_ActiveFlag" = 1
            WHERE "A"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                AND "A"."EME_Id" = "p_EME_Id"::BIGINT 
                AND "A"."ESTMP_Percentage" > "v_GREATHERTHAN_PERCENTAGE" 
                AND "A"."ESTMP_Percentage" <= "v_LESSTHAN_PERCENTAGE"
                AND "B"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                AND "B"."AMAY_ActiveFlag" IN (0, 1) 
                AND "C"."AMST_ACTIVEFLAG" IN (0, 1) 
                AND "C"."AMST_SOL" != 'Del' 
                AND "B"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
                AND "A"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
                AND "H"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
                AND "B"."ASMS_Id" = "v_ASMS_Id_INT" 
                AND "A"."ASMS_Id" = "v_ASMS_Id_INT" 
                AND "H"."ASMS_Id" = "v_ASMS_Id_INT"
            ORDER BY "E"."ASMCL_Order", "F"."ASMC_Order", "studentname";
        ELSE
            RETURN QUERY
            SELECT 
                (COALESCE("C"."AMST_FirstName", '') || ' ' || COALESCE("C"."AMST_MiddleName", '') || ' ' || COALESCE("C"."AMST_LastName", '') || ' : ' || COALESCE("C"."AMST_AdmNo", '')) AS "studentname",
                "E"."ASMCL_ClassName",
                "F"."ASMC_SectionName",
                "B"."ASMCL_Id",
                "B"."ASMS_Id",
                "E"."ASMCL_Order",
                "F"."ASMC_Order",
                "B"."AMST_Id",
                "A"."ESTMP_Percentage",
                "A"."ESTMP_TotalMaxMarks",
                "A"."ESTMP_TotalObtMarks",
                "A"."ESTMP_TotalGrade"
            FROM "Exm"."Exm_Student_Marks_Process" "A"
            INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
            INNER JOIN "Adm_M_Student" "C" ON "C"."AMST_Id" = "B"."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "D" ON "D"."ASMAY_Id" = "B"."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" "E" ON "E"."ASMCL_Id" = "B"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" "F" ON "F"."ASMS_Id" = "B"."ASMS_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "G" ON "G"."EME_Id" = "A"."EME_Id"
            INNER JOIN "Exm"."Exm_Category_Class" "H" ON "H"."ASMAY_Id" = "D"."ASMAY_Id" AND "H"."ASMCL_Id" = "E"."ASMCL_Id" AND "H"."ASMS_Id" = "F"."ASMS_Id" AND "H"."ECAC_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_Master_Category" "I" ON "I"."EMCA_Id" = "H"."EMCA_Id" AND "I"."EMCA_ActiveFlag" = 1
            WHERE "A"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                AND "A"."EME_Id" = "p_EME_Id"::BIGINT 
                AND "A"."ESTMP_Percentage" > "v_GREATHERTHAN_PERCENTAGE" 
                AND "A"."ESTMP_Percentage" <= "v_LESSTHAN_PERCENTAGE"
                AND "B"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                AND "B"."AMAY_ActiveFlag" IN (0, 1) 
                AND "C"."AMST_ACTIVEFLAG" IN (0, 1) 
                AND "C"."AMST_SOL" != 'Del' 
                AND "B"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
                AND "A"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
                AND "H"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
            ORDER BY "E"."ASMCL_Order", "F"."ASMC_Order", "studentname";
        END IF;
    END IF;

    RETURN;
END;
$$;