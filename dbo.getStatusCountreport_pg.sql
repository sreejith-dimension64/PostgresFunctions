CREATE OR REPLACE FUNCTION "dbo"."getStatusCountreport" (
    "Year_id" BIGINT,
    "MI_ID" BIGINT
)
RETURNS TABLE (
    "PAMS_Id" BIGINT,
    "PAMST_Status" VARCHAR,
    "Data_count" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    result_cursor1 REFCURSOR;
    result_cursor2 REFCURSOR;
BEGIN 
    IF "Year_id" > 0 THEN
        RETURN QUERY
        SELECT 
            "Preadmission_School_Registration"."PAMS_Id",
            "Preadmission_Master_Status"."PAMST_Status",
            COUNT(*) AS "Data_count"
        FROM "Preadmission_School_Registration" 
        INNER JOIN "Preadmission_Master_Status" 
        ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id" 
        WHERE "Preadmission_School_Registration"."ASMAY_Id" = "Year_id" 
        AND "Preadmission_School_Registration"."PASR_Adm_Confirm_Flag" = 0 
        AND "Preadmission_Master_Status"."MI_Id" = "MI_ID" 
        AND "Preadmission_School_Registration"."PASR_Id" 
        NOT IN (SELECT "PASR_Id" FROM "Preadmission_SeatBlocked_Students")
        GROUP BY "Preadmission_School_Registration"."PAMS_Id", "Preadmission_Master_Status"."PAMST_Status" 
        ORDER BY "Preadmission_School_Registration"."PAMS_Id";
        
        RETURN QUERY
        SELECT 
            "PASRAPS_ID"::BIGINT AS "PAMS_Id",
            NULL::VARCHAR AS "PAMST_Status",
            COUNT(*) AS "Data_count"
        FROM "Preadmission_School_Registration" 
        WHERE "MI_Id" = "MI_ID" 
        AND "ASMAY_Id" = "Year_id"  
        GROUP BY "PASRAPS_ID" 
        ORDER BY COUNT("PASRAPS_ID") DESC;
        
    ELSIF "Year_id" = 0 THEN
        RETURN QUERY
        SELECT 
            "Preadmission_School_Registration"."PAMS_Id",
            "Preadmission_Master_Status"."PAMST_Status",
            COUNT(*) AS "Data_count"
        FROM "Preadmission_School_Registration" 
        INNER JOIN "Preadmission_Master_Status" 
        ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id" 
        WHERE "Preadmission_Master_Status"."MI_Id" = "MI_ID" 
        AND "Preadmission_School_Registration"."PASR_Adm_Confirm_Flag" = 0 
        AND "Preadmission_School_Registration"."PASR_Id" 
        NOT IN (SELECT "PASR_Id" FROM "Preadmission_SeatBlocked_Students")
        GROUP BY "Preadmission_School_Registration"."PAMS_Id", "Preadmission_Master_Status"."PAMST_Status" 
        ORDER BY "Preadmission_School_Registration"."PAMS_Id";
        
        RETURN QUERY
        SELECT 
            "PASRAPS_ID"::BIGINT AS "PAMS_Id",
            NULL::VARCHAR AS "PAMST_Status",
            COUNT(*) AS "Data_count"
        FROM "Preadmission_School_Registration" 
        WHERE "MI_Id" = "MI_ID" 
        GROUP BY "PASRAPS_ID" 
        ORDER BY COUNT("PASRAPS_ID") DESC;
    END IF;
    
    RETURN;
END;
$$;