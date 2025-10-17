CREATE OR REPLACE FUNCTION "Emplist"()
RETURNS TABLE(
    "EmployeeID" INTEGER,
    "FirstName" VARCHAR,
    "LastName" VARCHAR,
    "BirthDate" TIMESTAMP,
    "HireDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "Employees"."EmployeeID", 
           "Employees"."FirstName", 
           "Employees"."LastName", 
           "Employees"."BirthDate", 
           "Employees"."HireDate"
    FROM "Employees";
END;
$$;