CREATE OR REPLACE FUNCTION "dbo"."Get_No_of_Absent"(
    p_MI_Id INTEGER
)
RETURNS TABLE(
    "HRMDES_Id" INTEGER,
    "NameOfDesig" VARCHAR,
    "absentee" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HR_Master_Designation"."HRMDES_Id",
        "HR_Master_Designation"."HRMDES_DesignationName" AS "NameOfDesig",
        COUNT("HRME_Id") AS "absentee" 
    FROM "HR_Master_Employee" 
    INNER JOIN "HR_Master_Designation" ON 
        "HR_Master_Employee"."HRMDES_Id" = "HR_Master_Designation"."HRMDES_Id" 
        AND "HR_Master_Employee"."MI_Id" = "HR_Master_Designation"."MI_Id"
    WHERE "HR_Master_Employee"."MI_Id" = p_MI_Id 
        AND "HR_Master_Employee"."HRME_ActiveFlag" = 1 
        AND "HR_Master_Employee"."HRME_LeftFlag" = 0 
        AND "HR_Master_Designation"."HRMDES_ActiveFlag" = 1
    GROUP BY 
        "HR_Master_Designation"."HRMDES_Id",
        "HR_Master_Designation"."HRMDES_DesignationName"
    ORDER BY "HR_Master_Designation"."HRMDES_DesignationName";
    
    RETURN;
END;
$$;