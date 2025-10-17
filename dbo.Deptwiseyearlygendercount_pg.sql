CREATE OR REPLACE FUNCTION "dbo"."Deptwiseyearlygendercount"(
    "MI_Id" VARCHAR(100),
    "ASMAY_Id" VARCHAR(100)
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "MaleCount" BIGINT,
    "FemaleCount" BIGINT,
    "OthersCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SqlDynamic" TEXT;
BEGIN
    "SqlDynamic" := '
    SELECT DISTINCT "ASMAY"."ASMAY_Year",
           "HRMD_DepartmentName",
           SUM(COALESCE((CASE WHEN "IVRMMG_GenderName"=''Male'' THEN 1 ELSE 0 END),0)) AS "MaleCount",
           SUM(COALESCE((CASE WHEN "IVRMMG_GenderName"=''FeMale'' THEN 1 ELSE 0 END),0)) AS "FemaleCount",
           SUM(COALESCE((CASE WHEN "IVRMMG_GenderName"=''Others'' THEN 1 ELSE 0 END),0)) AS "OthersCount"
    FROM "HR_Master_Employee" "HME"
    INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id"="HME"."HRMD_Id" AND "HME"."MI_Id"="HMD"."MI_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."MI_Id"="HMD"."MI_Id"
    INNER JOIN "IVRM_Master_Gender" "IMG" ON "IMG"."IVRMMG_Id"="HME"."IVRMMG_Id"
    INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name"=TO_CHAR("HME"."HRME_DOJ", ''Month'')
    WHERE "HME"."MI_Id" IN (' || "MI_Id" || ') 
      AND "HMD"."MI_Id" IN (' || "MI_Id" || ') 
      AND "ASMAY"."MI_Id" IN (' || "MI_Id" || ')
      AND "ASMAY"."ASMAY_Id" IN (' || "ASMAY_Id" || ')
    GROUP BY "HME"."MI_Id", "ASMAY"."ASMAY_Year", "HRMD_DepartmentName"';

    RETURN QUERY EXECUTE "SqlDynamic";
END;
$$;