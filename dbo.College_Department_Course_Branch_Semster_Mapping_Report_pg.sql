CREATE OR REPLACE FUNCTION "dbo"."College_Department_Course_Branch_Semster_Mapping_Report"(
    p_MI_Id TEXT,
    p_HRMD_Id TEXT,
    p_AMCO_Id TEXT
)
RETURNS TABLE(
    deptname VARCHAR,
    coursename VARCHAR,
    branchname VARCHAR,
    semestername VARCHAR,
    "HRMD_Order" INTEGER,
    "AMB_Order" INTEGER,
    "AMSE_SEMOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."HRMD_DepartmentName" AS deptname,
        d."AMCO_CourseName" AS coursename,
        e."AMB_BranchName" AS branchname,
        f."AMSE_SEMName" AS semestername,
        c."HRMD_Order",
        e."AMB_Order",
        f."AMSE_SEMOrder"
    FROM "CLG"."Adm_Dept_Course" a
    INNER JOIN "clg"."Adm_Dept_Course_Branch_Semester" b ON a."ADCO_Id" = b."ADCO_Id"
    INNER JOIN "HR_Master_Department" c ON c."HRMD_Id" = a."HRMD_Id"
    INNER JOIN "clg"."Adm_Master_Course" d ON d."AMCO_Id" = a."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = b."AMSE_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."HRMD_Id" = p_HRMD_Id
        AND a."ADCO_ActiveFlag" = 1 
        AND b."ADCOBS_ActiveFlag" = 1 
        AND d."AMCO_ActiveFlag" = 1
        AND e."AMB_ActiveFlag" = 1 
        AND f."AMSE_ActiveFlg" = 1 
        AND c."HRMD_ActiveFlag" = 1
    ORDER BY e."AMB_Order", f."AMSE_SEMOrder";
END;
$$;