CREATE OR REPLACE FUNCTION "dbo"."HRMS_SMSSENTCOUNT"(
    "month" BIGINT,
    "year" BIGINT,
    "multiplehrmeid" VARCHAR(2000),
    "miid" BIGINT
)
RETURNS TABLE("count" BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    "query" := 'SELECT COUNT(*) as count FROM "HR_Master_Employee" a ' ||
               'INNER JOIN "HR_Master_Employee_MobileNo" b ON a."MI_Id" = ' || "miid"::TEXT || 
               ' AND a."hrme_id" IN (' || "multiplehrmeid" || ') ' ||
               'AND a."hrme_id" = b."hrme_id" ' ||
               'INNER JOIN "IVRM_sms_sentBox" c ON a."mi_id" = c."mi_id" ' ||
               'AND c."module_name" = ''HRMS'' ' ||
               'AND EXTRACT(MONTH FROM c."Datetime") = ' || "month"::TEXT || 
               ' AND EXTRACT(YEAR FROM c."Datetime") = ' || "year"::TEXT || 
               ' AND b."HRMEMNO_MobileNo" = c."Mobile_no"';
    
    RETURN QUERY EXECUTE "query";
END;
$$;