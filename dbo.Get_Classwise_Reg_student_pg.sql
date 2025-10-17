CREATE OR REPLACE FUNCTION "dbo"."Get_Classwise_Reg_student"(
    p_MI_Id INT,
    p_ASMAY_Id INT
)
RETURNS TABLE(
    class VARCHAR,
    "Total" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH abc AS (
        SELECT 
            a.class,
            a.section,
            a.boys,
            a.girls,
            a.total,
            a."ASMCL_Order",
            a."ASMC_Order"
        FROM (
            SELECT 
                mailf."ASMCL_ClassName" AS class,
                mailf."ASMC_SectionName" AS section,
                SUM(mailf.m_s) AS boys,
                SUM(mailf.f_s) AS girls,
                SUM(mailf.f_s) + SUM(mailf.m_s) AS total,
                mailf."ASMCL_Order",
                mailf."ASMC_Order"
            FROM (
                (SELECT 
                    COUNT(DISTINCT 1) AS M_S, 
                    0 AS f_s, 
                    "Adm_School_M_Class"."ASMCL_ClassName",
                    "Adm_School_M_Section"."ASMC_SectionName",
                    "Adm_School_M_Class"."ASMCL_Order",
                    "Adm_School_M_Section"."ASMC_Order"
                FROM "dbo"."Adm_School_Y_Student"
                INNER JOIN "dbo"."Adm_School_M_Class" 
                    ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" 
                    ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_M_Student" 
                    ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id
                    AND "Adm_M_Student"."AMST_SOL" IN ('S')
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                    AND "Adm_School_Y_Student"."amay_activeflag" = 1
                    AND "Adm_M_Student"."AMST_Sex" = 'Male'
                    AND "Adm_M_Student"."MI_Id" = p_MI_Id
                GROUP BY 
                    "Adm_School_Y_Student"."ASMCL_Id",
                    "Adm_School_M_Class"."ASMCL_Id",
                    "Adm_School_M_Class"."ASMCL_ClassName",
                    "Adm_School_M_Class"."ASMCL_Order",
                    "Adm_School_M_Section"."ASMC_SectionName",
                    "Adm_M_Student"."AMC_Id",
                    "Adm_M_Student"."AMST_Id",
                    "Adm_School_M_Section"."ASMC_Order"
                ORDER BY 
                    "Adm_School_M_Class"."ASMCL_Order",
                    "Adm_School_M_Section"."ASMC_Order"
                LIMIT 100)
                
                UNION ALL
                
                (SELECT 
                    0 AS M_S, 
                    COUNT(DISTINCT 1) AS f_s,
                    "Adm_School_M_Class"."ASMCL_ClassName",
                    "Adm_School_M_Section"."ASMC_SectionName",
                    "Adm_School_M_Class"."ASMCL_Order",
                    "Adm_School_M_Section"."ASMC_Order"
                FROM "dbo"."Adm_School_Y_Student"
                INNER JOIN "dbo"."Adm_School_M_Class" 
                    ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" 
                    ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_M_Student" 
                    ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id
                    AND "Adm_M_Student"."AMST_SOL" IN ('S')
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                    AND "Adm_School_Y_Student"."amay_activeflag" = 1
                    AND "Adm_M_Student"."AMST_Sex" = 'Female'
                    AND "Adm_M_Student"."MI_Id" = p_MI_Id
                GROUP BY 
                    "Adm_School_Y_Student"."ASMCL_Id",
                    "Adm_School_M_Class"."ASMCL_Id",
                    "Adm_School_M_Class"."ASMCL_ClassName",
                    "Adm_School_M_Class"."ASMCL_Order",
                    "Adm_School_M_Section"."ASMC_SectionName",
                    "Adm_M_Student"."AMC_Id",
                    "Adm_M_Student"."AMST_Id",
                    "Adm_School_M_Section"."ASMC_Order"
                ORDER BY 
                    "Adm_School_M_Class"."ASMCL_Order",
                    "Adm_School_M_Section"."ASMC_Order"
                LIMIT 100)
            ) mailf
            GROUP BY 
                mailf."ASMC_SectionName",
                mailf."ASMCL_ClassName",
                mailf."ASMCL_Order",
                mailf."ASMC_Order"
            ORDER BY 
                mailf."ASMCL_Order",
                mailf."ASMC_Order"
            LIMIT 100
        ) a
    )
    SELECT 
        abc.class,
        SUM(abc.total) AS "Total"
    FROM abc
    GROUP BY abc.class, abc."ASMCL_Order"
    ORDER BY abc."ASMCL_Order";
    
    RETURN;
END;
$$;