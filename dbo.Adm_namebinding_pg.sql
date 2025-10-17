CREATE OR REPLACE FUNCTION "dbo"."Adm_namebinding"(
    p_year BIGINT,
    p_classid BIGINT,
    p_secid BIGINT,
    p_flag VARCHAR(500),
    p_mi_id BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "name" TEXT,
    "AMST_AdmNo" TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_classid = 0 AND p_secid = 0 AND p_flag = 'admno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."Adm_M_Student"."AMST_Id", 
            (COALESCE("dbo"."Adm_M_Student"."AMST_AdmNo", '') || ':' || COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' ||      
            COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", ''))    
            AS name,
            "dbo"."Adm_M_Student"."AMST_AdmNo" 
        FROM "dbo"."Adm_M_Student"  
        INNER JOIN "dbo"."Adm_School_Y_Student"     
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"  
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_year  
            AND "Adm_M_Student"."MI_Id" = p_mi_id   
            AND "AMST_SOL" = 'S'  
            AND "AMST_ActiveFlag" = 1  
            AND "AMAY_ActiveFlag" = 1 
        GROUP BY "dbo"."Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName",  
            "AMST_LastName", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo";
        RETURN;
    END IF;

    IF p_classid = 0 AND p_secid = 0 AND p_flag != 'admno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."Adm_M_Student"."AMST_Id", 
            (COALESCE("dbo"."Adm_M_Student"."AMST_AdmNo", '') || ':' || COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' ||      
            COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", ''))    
            AS name,
            "dbo"."Adm_M_Student"."AMST_AdmNo" 
        FROM "dbo"."Adm_M_Student"  
        INNER JOIN "dbo"."Adm_School_Y_Student"     
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"  
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_year   
            AND "Adm_M_Student"."MI_Id" = p_mi_id   
            AND "Adm_M_Student"."AMST_SOL" = 'S'   
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1   
            AND "dbo"."Adm_School_Y_Student"."AMAY_ActiveFlag" = 1   
        GROUP BY "dbo"."Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName",  
            "AMST_LastName", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo";
        RETURN;
    END IF;

    IF p_classid != 0 AND p_secid = 0 AND p_flag = 'admno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."Adm_M_Student"."AMST_Id", 
            (COALESCE("dbo"."Adm_M_Student"."AMST_AdmNo", '') || ':' || COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' ||      
            COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", ''))    
            AS name,
            "dbo"."Adm_M_Student"."AMST_AdmNo" 
        FROM "dbo"."Adm_M_Student"  
        INNER JOIN "dbo"."Adm_School_Y_Student"     
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_year  
            AND "Adm_School_Y_Student"."ASMCL_Id" = p_classid   
            AND "Adm_M_Student"."MI_Id" = p_mi_id   
            AND "Adm_M_Student"."AMST_SOL" = 'S'   
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1  
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1   
        GROUP BY "dbo"."Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName",  
            "AMST_LastName", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo";
        RETURN;
    END IF;

    IF p_classid != 0 AND p_secid = 0 AND p_flag != 'admno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."Adm_M_Student"."AMST_Id", 
            (COALESCE("dbo"."Adm_M_Student"."AMST_AdmNo", '') || ':' || COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' ||      
            COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", ''))    
            AS name,
            "dbo"."Adm_M_Student"."AMST_AdmNo" 
        FROM "dbo"."Adm_M_Student"  
        INNER JOIN "dbo"."Adm_School_Y_Student"     
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"  
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_year  
            AND "Adm_School_Y_Student"."ASMCL_Id" = p_classid   
            AND "Adm_M_Student"."MI_Id" = p_mi_id  
            AND "Adm_M_Student"."AMST_SOL" = 'S'  
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1   
        GROUP BY "dbo"."Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName",  
            "AMST_LastName", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo";
        RETURN;
    END IF;

    IF p_classid != 0 AND p_secid != 0 AND p_flag = 'admno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."Adm_M_Student"."AMST_Id", 
            (COALESCE("dbo"."Adm_M_Student"."AMST_AdmNo", '') || ':' || COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' ||      
            COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", ''))    
            AS name,
            "dbo"."Adm_M_Student"."AMST_AdmNo" 
        FROM "dbo"."Adm_M_Student"  
        INNER JOIN "dbo"."Adm_School_Y_Student"     
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"   
        WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_year)  
            AND ("dbo"."Adm_School_Y_Student"."ASMCL_Id" = p_classid)  
            AND ("dbo"."Adm_School_Y_Student"."ASMS_Id" = p_secid)   
            AND "Adm_M_Student"."MI_Id" = p_mi_id   
            AND "Adm_M_Student"."AMST_SOL" = 'S'   
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1   
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
        GROUP BY "dbo"."Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName",  
            "AMST_LastName", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo";
        RETURN;
    END IF;

    IF p_classid != 0 AND p_secid != 0 AND p_flag != 'admno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "dbo"."Adm_M_Student"."AMST_Id", 
            (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' ||      
            COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", '') || ':' || COALESCE("dbo"."Adm_M_Student"."AMST_AdmNo", ''))    
            AS name,
            "dbo"."Adm_M_Student"."AMST_AdmNo" 
        FROM "dbo"."Adm_M_Student"  
        INNER JOIN "dbo"."Adm_School_Y_Student"     
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"    
        WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_year)  
            AND ("dbo"."Adm_School_Y_Student"."ASMCL_Id" = p_classid) 
            AND ("dbo"."Adm_School_Y_Student"."ASMS_Id" = p_secid)   
            AND "Adm_M_Student"."MI_Id" = p_mi_id   
            AND "Adm_M_Student"."AMST_SOL" = 'S'   
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1   
            AND "AMAY_ActiveFlag" = 1 
        GROUP BY "dbo"."Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName",  
            "AMST_LastName", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo";
        RETURN;
    END IF;

END;
$$;