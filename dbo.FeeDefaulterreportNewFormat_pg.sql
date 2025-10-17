CREATE OR REPLACE FUNCTION "dbo"."FeeDefaulterreportNewFormat"(
    "MI_Id" VARCHAR(100),
    "ASMAY_ID" VARCHAR(100),
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "Type" TEXT,
    "AMST_Id" TEXT,
    "FMT_Id" TEXT
)
RETURNS TABLE(
    "classname" TEXT,
    "sectionname" TEXT,
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "AMST_AdmNo" TEXT,
    "FatherName" TEXT,
    "AMST_MobileNo" TEXT,
    "Address" TEXT,
    "dynamic_columns" TEXT,
    "Total" NUMERIC
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "head_names" TEXT;
    "sql1head" TEXT;
    "sqlhead" TEXT;
    "cols" TEXT;
    "query" TEXT;
    "monthyearsd" TEXT;
    "monthyearsd_select" TEXT;
    "monthyearsid_total" TEXT;
    "objcursor" REFCURSOR;
BEGIN
    
    "sql1head" := 'SELECT DISTINCT "FMT_Name" FROM "Fee_Master_Terms" WHERE "FMT_ActiveFlag"=1 AND "MI_Id" IN (' || "MI_Id" || ') AND "FMT_Id" IN (' || "FMT_Id" || ')';
    
    "monthyearsd" := '';
    "monthyearsd_select" := '';
    "monthyearsid_total" := '';
    
    FOR "cols" IN EXECUTE "sql1head"
    LOOP
        "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE('"' || "cols" || '"' || ', ', '');
        "monthyearsd_select" := COALESCE("monthyearsd_select", '') || COALESCE('CAST("' || "cols" || '" AS VARCHAR) AS "' || "cols" || '"' || ', ', '');
        "monthyearsid_total" := COALESCE("monthyearsid_total", '') || COALESCE('COALESCE("' || "cols" || '", 0)' || '+ ', '');
    END LOOP;
    
    IF LENGTH("monthyearsd") > 0 THEN
        "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd") - 1);
    END IF;
    
    IF LENGTH("monthyearsd_select") > 0 THEN
        "monthyearsd_select" := LEFT("monthyearsd_select", LENGTH("monthyearsd_select") - 1);
    END IF;
    
    IF LENGTH("monthyearsid_total") > 0 THEN
        "monthyearsid_total" := LEFT("monthyearsid_total", LENGTH("monthyearsid_total") - 1);
    END IF;
    
    IF "Type" = 'All' THEN
        "query" := 'SELECT "classname", "sectionname", "AMST_Id", "StudentName", "AMST_AdmNo", "FatherName", "AMST_MobileNo", "Address", ' || "monthyearsd_select" || ', (' || "monthyearsid_total" || ') AS "Total"
        FROM CROSSTAB(
            ''SELECT K."ASMCL_ClassName" AS classname, "ASMC_SectionName" AS sectionname, F."AMST_Id", 
            CONCAT(F."AMST_FirstName", '' '', F."AMST_MiddleName", '' '', F."AMST_LastName") AS "StudentName", 
            F."AMST_AdmNo",
            CONCAT(COALESCE(F."AMST_FatherName", ''''), '' '', COALESCE(F."AMST_FatherSurname", '''')) AS "FatherName", 
            F."AMST_MobileNo",
            CONCAT(COALESCE(F."AMST_PerStreet", ''''), '' '', COALESCE(F."AMST_PerCity", '''')) AS "Address",
            H."FMT_Name",
            COALESCE(A."FSS_ToBePaid", 0) AS "FSS_ToBePaid"
            FROM "Fee_Student_Status" A
            INNER JOIN "Fee_Master_Terms_FeeHeads" D ON D."FMH_Id" = A."FMH_Id" AND A."FTI_Id" = D."FTI_Id"
            INNER JOIN "Fee_Master_Head" E ON A."FMH_Id" = E."FMH_Id" AND D."FMH_Id" = A."FMH_Id"
            INNER JOIN "Adm_M_Student" F ON F."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" G ON G."ASMAY_Id" = A."ASMAY_Id" AND A."AMST_Id" = G."AMST_Id"
            INNER JOIN "Fee_Master_Terms" H ON H."FMT_Id" = D."FMT_Id"
            INNER JOIN "Fee_Master_Amount" I ON I."FMA_Id" = A."FMA_Id"
            INNER JOIN "Fee_Master_Class_Category" J ON J."FMCC_Id" = I."FMCC_Id"
            INNER JOIN "Adm_School_M_Class" K ON K."ASMCL_Id" = G."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" L ON L."ASMS_Id" = G."ASMS_Id"
            WHERE A."ASMAY_Id" IN (' || "ASMAY_ID" || ') 
            AND A."MI_Id" IN (' || "MI_Id" || ') 
            AND K."ASMCL_Id" IN (' || "ASMCL_Id" || ') 
            AND L."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND H."FMT_Id" IN (' || "FMT_Id" || ') 
            AND COALESCE(A."FSS_ToBePaid", 0) > 0
            ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9'',
            ''SELECT DISTINCT "FMT_Name" FROM "Fee_Master_Terms" WHERE "FMT_ActiveFlag"=1 AND "MI_Id" IN (' || "MI_Id" || ') AND "FMT_Id" IN (' || "FMT_Id" || ') ORDER BY 1''
        ) AS ct("classname" TEXT, "sectionname" TEXT, "AMST_Id" BIGINT, "StudentName" TEXT, "AMST_AdmNo" TEXT, "FatherName" TEXT, "AMST_MobileNo" TEXT, "Address" TEXT, ' || "monthyearsd" || ')';
    ELSE
        "query" := 'SELECT "classname", "sectionname", "AMST_Id", "StudentName", "AMST_AdmNo", "FatherName", "AMST_MobileNo", "Address", ' || "monthyearsd_select" || ', (' || "monthyearsid_total" || ') AS "Total"
        FROM CROSSTAB(
            ''SELECT K."ASMCL_ClassName" AS classname, "ASMC_SectionName" AS sectionname, F."AMST_Id", 
            CONCAT(F."AMST_FirstName", '' '', F."AMST_MiddleName", '' '', F."AMST_LastName") AS "StudentName", 
            F."AMST_AdmNo",
            CONCAT(COALESCE(F."AMST_FatherName", ''''), '' '', COALESCE(F."AMST_FatherSurname", '''')) AS "FatherName", 
            F."AMST_MobileNo",
            CONCAT(COALESCE(F."AMST_PerStreet", ''''), '' '', COALESCE(F."AMST_PerCity", '''')) AS "Address",
            H."FMT_Name",
            COALESCE(A."FSS_ToBePaid", 0) AS "FSS_ToBePaid"
            FROM "Fee_Student_Status" A
            INNER JOIN "Fee_Master_Terms_FeeHeads" D ON D."FMH_Id" = A."FMH_Id" AND A."FTI_Id" = D."FTI_Id"
            INNER JOIN "Fee_Master_Head" E ON A."FMH_Id" = E."FMH_Id" AND D."FMH_Id" = A."FMH_Id"
            INNER JOIN "Adm_M_Student" F ON F."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" G ON G."ASMAY_Id" = A."ASMAY_Id" AND A."AMST_Id" = G."AMST_Id"
            INNER JOIN "Fee_Master_Terms" H ON H."FMT_Id" = D."FMT_Id"
            INNER JOIN "Fee_Master_Amount" I ON I."FMA_Id" = A."FMA_Id"
            INNER JOIN "Fee_Master_Class_Category" J ON J."FMCC_Id" = I."FMCC_Id"
            INNER JOIN "Adm_School_M_Class" K ON K."ASMCL_Id" = G."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" L ON L."ASMS_Id" = G."ASMS_Id"
            WHERE A."ASMAY_Id" IN (' || "ASMAY_ID" || ') 
            AND A."MI_Id" IN (' || "MI_Id" || ') 
            AND K."ASMCL_Id" IN (' || "ASMCL_Id" || ') 
            AND L."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND A."AMST_Id" IN (' || "AMST_Id" || ') 
            AND H."FMT_Id" IN (' || "FMT_Id" || ') 
            AND COALESCE(A."FSS_ToBePaid", 0) > 0
            ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9'',
            ''SELECT DISTINCT "FMT_Name" FROM "Fee_Master_Terms" WHERE "FMT_ActiveFlag"=1 AND "MI_Id" IN (' || "MI_Id" || ') AND "FMT_Id" IN (' || "FMT_Id" || ') ORDER BY 1''
        ) AS ct("classname" TEXT, "sectionname" TEXT, "AMST_Id" BIGINT, "StudentName" TEXT, "AMST_AdmNo" TEXT, "FatherName" TEXT, "AMST_MobileNo" TEXT, "Address" TEXT, ' || "monthyearsd" || ')';
    END IF;
    
    RAISE NOTICE '%', "query";
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;