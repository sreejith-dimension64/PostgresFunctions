CREATE OR REPLACE FUNCTION "dbo"."fee_remittance_certificate_StuName"(
    "asmay_id" INT,
    "mi_id" INT,
    "Type" INT
)
RETURNS TABLE(
    "AMST_Id" INT,
    "Name" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF("Type" = 1) THEN
        RETURN QUERY
        SELECT 
            "dbo"."Adm_M_Student"."AMST_Id",
            ("dbo"."Adm_M_Student"."AMST_AdmNo" || ' :' || "dbo"."Adm_M_Student"."AMST_FirstName" || ' ' || 
             "dbo"."Adm_M_Student"."AMST_MiddleName" || ' ' || "dbo"."Adm_M_Student"."AMST_LastName")::TEXT AS "Name"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
        WHERE ("dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "asmay_id") 
        AND ("dbo"."Adm_School_M_Academic_Year"."MI_Id" = "mi_id");
    END IF;

    IF("Type" = 2) THEN
        RETURN QUERY
        SELECT 
            "dbo"."Adm_M_Student"."AMST_Id",
            ("dbo"."Adm_M_Student"."AMST_FirstName" || ' ' || "dbo"."Adm_M_Student"."AMST_MiddleName" || ' ' || 
             "dbo"."Adm_M_Student"."AMST_LastName" || ':' || "dbo"."Adm_M_Student"."AMST_AdmNo")::TEXT AS "Name"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
        WHERE ("dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "asmay_id") 
        AND ("dbo"."Adm_School_M_Academic_Year"."MI_Id" = "mi_id");
    END IF;

    RETURN;
END;
$$;