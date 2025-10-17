CREATE OR REPLACE FUNCTION "dbo"."Empnewleftratio"(
    "MI_Id" VARCHAR(100),
    "ASMAY_Id" VARCHAR(100)
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "IVRM_Month_Name" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "NewCount" BIGINT,
    "LeftCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SqlDynamic" TEXT;
BEGIN
    "SqlDynamic" := '
    SELECT "ASMAY"."ASMAY_Year", "IM"."IVRM_Month_Name", "HRMD_DepartmentName",
    SUM(COALESCE((CASE WHEN "HRME_LeftFlag" = false THEN 1 END), 0)) AS "NewCount",
    SUM(COALESCE((CASE WHEN "HRME_LeftFlag" = true THEN 1 END), 0)) AS "LeftCount"
    FROM "HR_Master_Employee" "HME"
    INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id" AND "HME"."MI_Id" = "HMD"."MI_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."MI_Id" = "HMD"."MI_Id"
    INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("HME"."HRME_DOJ", ''Month'')
    WHERE "HME"."MI_Id" IN (' || "MI_Id" || ') AND "HMD"."MI_Id" IN (' || "MI_Id" || ') 
    AND ("HME"."HRME_DOJ" >= "ASMAY_FYStartDate" AND "HME"."HRME_DOJ" <= "ASMAY_FYEndDate") 
    AND "ASMAY"."MI_Id" IN (' || "MI_Id" || ')
    AND "ASMAY"."ASMAY_Id" IN (' || "ASMAY_Id" || ')
    GROUP BY "ASMAY"."ASMAY_Year", "IVRM_Month_Id", "IM"."IVRM_Month_Name", "HRMD_DepartmentName"
    ORDER BY "IVRM_Month_Id"
    LIMIT 100';

    RETURN QUERY EXECUTE "SqlDynamic";
END;
$$;