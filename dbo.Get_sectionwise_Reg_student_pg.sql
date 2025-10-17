CREATE OR REPLACE FUNCTION "dbo"."Get_sectionwise_Reg_student"(
    p_mi_id INT,
    p_yearId INT
)
RETURNS TABLE(
    classid INT,
    class VARCHAR,
    sectionid INT,
    section VARCHAR,
    boys BIGINT,
    girls BIGINT,
    total BIGINT,
    "ASMCL_Order" INT,
    "ASMC_Order" INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT  
        (mailf."ASMCL_Id") AS classid,
        (mailf."ASMCL_ClassName") AS class,
        (mailf."ASMS_Id") AS sectionid,
        (mailf."ASMC_SectionName") AS section,  
        SUM(mailf.m_s) AS boys,
        SUM(mailf.f_s) AS girls,      
        SUM(mailf.f_s) + SUM(mailf.m_s) AS total,
        mailf."ASMCL_Order",
        mailf."ASMC_Order"
    FROM (      
        (SELECT 
            COUNT(DISTINCT 1) AS M_S, 
            0::BIGINT AS f_s, 
            "Adm_School_M_Class"."ASMCL_ClassName",
            "Adm_School_M_Class"."ASMCL_Id",    
            "Adm_School_M_Section"."ASMS_Id", 
            "Adm_School_M_Section"."ASMC_SectionName",
            "Adm_School_M_Class"."ASMCL_Order",
            "Adm_School_M_Section"."ASMC_Order" 
        FROM "dbo"."Adm_School_Y_Student"       
        INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"     
        INNER JOIN "dbo"."Adm_School_M_Section" ON       
            "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
        INNER JOIN "dbo"."Adm_M_Student"     
            ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"         
        WHERE  "Adm_School_Y_Student"."ASMAY_Id" = p_yearId 
            AND ("Adm_M_Student"."AMST_SOL" IN ('S','L')) 
            AND ("Adm_M_Student"."AMST_Sex" = 'Male') 
            AND "Adm_M_Student"."MI_Id" = p_mi_id
        GROUP BY 
            "Adm_School_M_Section"."ASMS_Id",
            "Adm_School_Y_Student"."ASMCL_Id", 
            "Adm_School_M_Class"."ASMCL_Id",       
            "Adm_School_M_Class"."ASMCL_ClassName", 
            "Adm_School_M_Class"."ASMCL_Order",    
            "Adm_School_M_Section"."ASMC_SectionName",
            "Adm_M_Student"."AMC_Id",       
            "Adm_M_Student"."AMST_Id",
            "Adm_School_M_Class"."ASMCL_Order",
            "Adm_School_M_Section"."ASMC_Order"
        ORDER BY "Adm_School_M_Class"."ASMCL_Order", "Adm_School_M_Section"."ASMC_Order"
        LIMIT 100)      
        
        UNION ALL       
         
        (SELECT 
            0::BIGINT AS M_S, 
            COUNT(DISTINCT 1) AS f_s,
            "Adm_School_M_Class"."ASMCL_ClassName",  
            "Adm_School_M_Class"."ASMCL_Id",    
            "Adm_School_M_Section"."ASMS_Id",
            "Adm_School_M_Section"."ASMC_SectionName",
            "Adm_School_M_Class"."ASMCL_Order",
            "Adm_School_M_Section"."ASMC_Order" 
        FROM "dbo"."Adm_School_Y_Student"      
        INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"  
        INNER JOIN "dbo"."Adm_School_M_Section" ON       
            "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
        INNER JOIN "dbo"."Adm_M_Student" ON  
            "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"    
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_yearId   
            AND ("Adm_M_Student"."AMST_SOL" IN ('S','L'))  
            AND ("Adm_M_Student"."AMST_Sex" = 'Female')  
            AND "Adm_M_Student"."MI_Id" = p_mi_id     
        GROUP BY 
            "Adm_School_M_Section"."ASMS_Id", 
            "Adm_School_Y_Student"."ASMCL_Id", 
            "Adm_School_M_Class"."ASMCL_Id",       
            "Adm_School_M_Class"."ASMCL_ClassName", 
            "Adm_School_M_Class"."ASMCL_Order",   
            "Adm_School_M_Section"."ASMC_SectionName",
            "Adm_M_Student"."AMC_Id",       
            "Adm_M_Student"."AMST_Id",
            "Adm_School_M_Class"."ASMCL_Order",
            "Adm_School_M_Section"."ASMC_Order"
        ORDER BY "Adm_School_M_Class"."ASMCL_Order", "Adm_School_M_Section"."ASMC_Order"
        LIMIT 100)
    ) mailf  
    GROUP BY 
        mailf."ASMS_Id",
        mailf."ASMC_SectionName",
        mailf."ASMCL_Id",
        mailf."ASMS_Id",
        mailf."ASMCL_ClassName",
        mailf."ASMCL_Order",
        mailf."ASMC_Order"  
    ORDER BY mailf."ASMCL_Order", mailf."ASMC_Order";
    
    RETURN;
END;
$$;