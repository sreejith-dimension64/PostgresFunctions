CREATE OR REPLACE FUNCTION "dbo"."get_Sms_Email_Parameters"(
    "@IVRMIM_Id" bigint,
    "@IVRMIMP_Id" bigint,
    "@IVRMHE_Name" varchar(100),
    "@MI_ID" bigint
)
RETURNS TABLE(
    "Parameter_Name" varchar,
    "Parameter_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT MAX(p."ISMP_NAME") AS "Parameter_Name", MAX(p."ISMP_ID") AS "Parameter_Id"
    FROM "IVRM_SMS_MAIL_PARAMETER" p
    LEFT JOIN "IVRM_SMS_MAIL_SAVED_PARAMETER_PAGEWISE" pg ON p."ISMP_ID" = pg."ISMP_ID"
    LEFT JOIN "IVRM_SMS_MAIL_PARAMETER_MAPPING" map ON map."ISMP_ID" = pg."ISMP_ID"
    LEFT JOIN "IVRM_Header" hea ON hea."IVRMHE_Id" = map."IVRMHE_Id"
    WHERE hea."IVRMIM_Id" = "@IVRMIM_Id" 
        AND hea."IVRMIMP_Id" = "@IVRMIMP_Id" 
        AND hea."IVRMHE_Name" = "@IVRMHE_Name" 
        AND hea."MI_Id" = "@MI_ID"
    GROUP BY p."ISMP_ID";
END;
$$;