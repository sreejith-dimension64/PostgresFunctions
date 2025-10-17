CREATE OR REPLACE FUNCTION "dbo"."ISM_DepartmentList"(
    "@MI_Id" bigint,
    "@role" text,
    "@HRMD_Id" bigint
)
RETURNS TABLE (
    "HRMDC_Name" varchar,
    "HRMDC_ID" bigint,
    "HRMDC_Code" varchar,
    "HRMDC_Order" int,
    "HRMDC_ActiveFlag" boolean,
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" text;
BEGIN
    IF "@role" = 'Admin' OR "@role" = 'ADMIN' OR "@role" = 'HR' THEN
        RETURN QUERY
        SELECT * FROM "HR_Master_DepartmentCode";
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            "a"."HRMDC_Name",
            "a"."HRMDC_ID",
            NULL::varchar AS "HRMDC_Code",
            NULL::int AS "HRMDC_Order",
            NULL::boolean AS "HRMDC_ActiveFlag",
            NULL::timestamp AS "CreatedDate",
            NULL::timestamp AS "UpdatedDate"
        FROM "HR_Master_DepartmentCode" "a"
        INNER JOIN "HR_Master_Department" "b" ON "a"."HRMDC_ID" = "b"."HRMDC_ID"
        WHERE "HRMD_Id" = 4;
    END IF;
END;
$$;