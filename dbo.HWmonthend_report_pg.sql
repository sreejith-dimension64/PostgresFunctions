CREATE OR REPLACE FUNCTION dbo."HWmonthend_report" (
    "Year" VARCHAR,
    "month" VARCHAR,
    "asmay_id" VARCHAR,
    "mi_id" VARCHAR,
    "flag" VARCHAR(100)
)
RETURNS TABLE (
    "ASMCL_Id" BIGINT,
    "asmcL_ClassName" VARCHAR,
    "total_count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_totalcount BIGINT;
BEGIN
    
    ----------Total Strength-----------------------------------------------------
    IF "flag" = 'Homework' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."ASMCL_Id",
            b."ASMCL_ClassName" as "asmcL_ClassName",
            (SELECT COUNT(*) FROM "IVRM_HomeWork" WHERE "ASMCL_Id" = a."ASMCL_Id") as "total_count"
        FROM "IVRM_HomeWork" a
        INNER JOIN "Adm_School_M_Class" b ON b."ASMCL_Id" = a."ASMCL_Id"
        WHERE a."IHW_ActiveFlag" = 1 
            AND EXTRACT(YEAR FROM a."CreatedDate") = "Year"::INTEGER
            AND EXTRACT(MONTH FROM a."CreatedDate") = "month"::INTEGER
            AND a."MI_Id" = "mi_id"
            AND a."ASMAY_Id" = "asmay_id";
    END IF;
    
    IF "flag" = 'Classwork' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."ASMCL_Id",
            b."ASMCL_ClassName" as "asmcL_ClassName",
            (SELECT COUNT(*) FROM "IVRM_Assignment" WHERE "ASMCL_Id" = a."ASMCL_Id") as "total_count"
        FROM "IVRM_Assignment" a 
        INNER JOIN "Adm_School_M_Class" b ON a."ASMCL_Id" = b."ASMCL_Id"
        WHERE a."ICW_ActiveFlag" = 1 
            AND EXTRACT(YEAR FROM a."CreatedDate") = "Year"::INTEGER
            AND EXTRACT(MONTH FROM a."CreatedDate") = "month"::INTEGER
            AND a."MI_Id" = "mi_id"
            AND a."ASMAY_Id" = "asmay_id";
    END IF;
    
    IF "flag" = 'Noticeboard' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."ASMCL_Id",
            d."ASMCL_ClassName",
            COUNT(*)::BIGINT as "total_count"
        FROM "IVRM_Noticeboard" b
        INNER JOIN "IVRM_NoticeBoard_Class" a ON a."INTB_Id" = b."INTB_Id"
        LEFT JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = a."ASMCL_Id" AND d."MI_Id" = "mi_id"
        WHERE b."MI_Id" = "mi_id"
            AND a."INTBC_ActiveFlag" = 1
            AND EXTRACT(YEAR FROM a."CreatedDate") = "Year"::INTEGER
            AND EXTRACT(MONTH FROM a."CreatedDate") = "month"::INTEGER
            AND b."MI_Id" = "mi_id"
            AND a."ASMCL_Id" != 0
        GROUP BY a."ASMCL_Id", d."ASMCL_ClassName";
    END IF;
    
    RETURN;
    
END;
$$;