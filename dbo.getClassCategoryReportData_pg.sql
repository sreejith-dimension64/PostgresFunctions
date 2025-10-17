CREATE OR REPLACE FUNCTION "dbo"."getClassCategoryReportData"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "FMCC_ClassCategoryName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMCL_ClassName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "dbo"."Fee_Yearly_Class_Category"."MI_Id",
        "dbo"."Fee_Yearly_Class_Category"."ASMAY_Id",
        "dbo"."Fee_Master_Class_Category"."FMCC_ClassCategoryName",
        "dbo"."Adm_School_M_Section"."ASMC_SectionName",
        "dbo"."Adm_School_M_Class"."ASMCL_ClassName"
    FROM "dbo"."Fee_Yearly_Class_Category"
    INNER JOIN "dbo"."Fee_Master_Class_Category" 
        ON "dbo"."Fee_Yearly_Class_Category"."FMCC_Id" = "dbo"."Fee_Master_Class_Category"."FMCC_Id"
    INNER JOIN "dbo"."Fee_Yearly_Class_Category_Classes" 
        ON "dbo"."Fee_Yearly_Class_Category"."FYCC_Id" = "dbo"."Fee_Yearly_Class_Category_Classes"."FYCC_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" 
        ON "dbo"."Fee_Yearly_Class_Category_Classes"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" 
        ON "dbo"."Fee_Yearly_Class_Category"."MI_Id" = "dbo"."Adm_School_M_Section"."MI_Id"
    WHERE "dbo"."Fee_Yearly_Class_Category"."MI_Id" = p_MI_Id
        AND "dbo"."Fee_Yearly_Class_Category"."ASMAY_Id" = p_ASMAY_Id;
END;
$$;