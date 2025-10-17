CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMAN_PORTAL_EMPLOYEE_STRENGTH"(
    p_MI_Id integer
)
RETURNS TABLE(
    "HRMDES_Id" integer,
    "nameOfDesig" character varying,
    "absentee" bigint,
    "HRMDES_Order" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HR_Master_Designation"."HRMDES_Id",
        "HR_Master_Designation"."HRMDES_DesignationName" as "nameOfDesig",
        COUNT("HRME_Id") as "absentee",
        "HR_Master_Designation"."HRMDES_Order"
    FROM "HR_Master_Employee"
    INNER JOIN "HR_Master_Designation" ON 
        "HR_Master_Employee"."HRMDES_Id" = "HR_Master_Designation"."HRMDES_Id" 
        AND "HR_Master_Employee"."MI_Id" = "HR_Master_Designation"."MI_Id"
    WHERE 
        "HR_Master_Employee"."MI_Id" = p_MI_Id 
        AND "HR_Master_Employee"."HRME_ActiveFlag" = 1 
        AND "HR_Master_Employee"."HRME_LeftFlag" = 0 
        AND "HR_Master_Designation"."HRMDES_ActiveFlag" = 1
    GROUP BY 
        "HR_Master_Designation"."HRMDES_Id",
        "HR_Master_Designation"."HRMDES_DesignationName",
        "HR_Master_Designation"."HRMDES_Order"
    ORDER BY 
        "HR_Master_Designation"."HRMDES_DesignationName",
        "HR_Master_Designation"."HRMDES_Order";
END;
$$;