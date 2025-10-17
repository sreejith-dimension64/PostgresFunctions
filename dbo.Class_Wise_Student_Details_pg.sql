CREATE OR REPLACE FUNCTION "dbo"."Class_Wise_Student_Details"(
    p_year TEXT,
    p_class TEXT,
    p_sec TEXT,
    p_allindiflag TEXT,
    p_tablepara TEXT,
    p_flag TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlall TEXT;
    v_flagactive TEXT;
BEGIN
    IF p_allindiflag = 'all' THEN
        IF p_flag = 'newad' THEN
            v_sqlall := ' SELECT ' || p_tablepara || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."AMAY_Id"  
WHERE "Adm_School_Y_Student"."AMAY_Id" = ' || p_year || ' AND "AMST_SOL" = ''' || v_flagactive || ''' ';
        ELSIF p_flag = 'totstd' THEN
            v_sqlall := ' SELECT ' || p_tablepara || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."AMAY_Id"  
WHERE "Adm_School_Y_Student"."AMAY_Id" = ' || p_year || ' AND "AMST_SOL" = ''' || v_flagactive || ''' ';
        ELSIF p_flag = 'prom' THEN
            v_sqlall := ' SELECT ' || p_tablepara || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."AMAY_Id"  
WHERE "Adm_School_Y_Student"."AMAY_Id" = ' || p_year || ' AND "AMST_SOL" = ''' || v_flagactive || ''' ';
        END IF;
    ELSIF p_allindiflag = 'indi' THEN
        IF p_flag = 'newad' THEN
            v_sqlall := ' SELECT ' || p_tablepara || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."AMAY_Id"  
WHERE "Adm_School_Y_Student"."AMAY_Id" = ' || p_year || ' AND "Adm_School_Y_Student"."ASMCL_Id" = ' || p_class || ' AND "Adm_School_Y_Student"."ASMS_Id" = ' || p_sec || ' AND "AMST_SOL" = ''' || v_flagactive || ''' ';
        ELSIF p_flag = 'totstd' THEN
            v_sqlall := ' SELECT ' || p_tablepara || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."AMAY_Id"  
WHERE "Adm_School_Y_Student"."AMAY_Id" = ' || p_year || ' AND "Adm_School_Y_Student"."ASMCL_Id" = ' || p_class || ' AND "Adm_School_Y_Student"."ASMS_Id" = ' || p_sec || ' AND "AMST_SOL" = ''' || v_flagactive || ''' ';
        ELSIF p_flag = 'prom' THEN
            v_sqlall := ' SELECT ' || p_tablepara || ' FROM "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."AMAY_Id"  
WHERE "Adm_School_Y_Student"."AMAY_Id" = ' || p_year || ' AND "Adm_School_Y_Student"."ASMCL_Id" = ' || p_class || ' AND "Adm_School_Y_Student"."ASMS_Id" = ' || p_sec || ' AND "AMST_SOL" = ''' || v_flagactive || ''' ';
        END IF;
    END IF;

    RETURN QUERY EXECUTE v_sqlall;
END;
$$;