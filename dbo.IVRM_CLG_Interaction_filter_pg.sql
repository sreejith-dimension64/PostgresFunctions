CREATE OR REPLACE FUNCTION "dbo"."IVRM_CLG_Interaction_filter"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_HRME_Id BIGINT,
    p_AMCO_Id BIGINT,
    p_AMB_Id BIGINT,
    p_AMSE_Id BIGINT,
    p_IINTS_Flag VARCHAR(50),
    p_roletype VARCHAR(50)
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "EmpName" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "AMB_Id" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMSE_Id" BIGINT,
    "AMSE_SEMName" VARCHAR,
    "ASMAY_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

IF p_roletype = 'Staff' THEN

    IF p_IINTS_Flag = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            c."AMCO_Id",
            c."AMCO_CourseName",
            E."AMB_Id",
            E."AMB_BranchName",
            F."AMSE_Id",
            F."AMSE_SEMName",
            b."ASMAY_Id"
        FROM "CLG"."Adm_College_Atten_Login_Details" a
        INNER JOIN "CLG"."Adm_College_Atten_Login_User" b ON a."ACALU_Id" = b."ACALU_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = b."HRME_Id"
        INNER JOIN "CLG"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = a."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = a."AMSE_Id"
        WHERE b."MI_Id" = p_MI_Id 
            AND b."ASMAY_Id" = p_ASMAY_Id 
            AND b."HRME_Id" = p_HRME_Id 
            AND c."AMCO_ActiveFlag" = 1 
            AND E."AMB_ActiveFlag" = 1 
            AND F."AMSE_ActiveFlg" = 1;
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'Teachers' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            d."HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            NULL::BIGINT AS "AMB_Id",
            NULL::VARCHAR AS "AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "exm"."Exm_Login_Privilege" a
        INNER JOIN "IVRM_Staff_User_Login" c ON c."IVRMSTAUL_Id" = a."Login_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."Emp_Code"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."ELP_ActiveFlg" = 1 
            AND d."HRME_LeftFlag" = 0 
            AND a."ELP_Flg" IN ('st', 'ct') 
            AND d."HRME_Id" != p_HRME_Id;
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'HOD' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            NULL::BIGINT AS "AMB_Id",
            NULL::VARCHAR AS "AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_HOD" a
        INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND c."HRME_Id" = p_HRME_Id 
            AND a."IHOD_ActiveFlag" = 1 
            AND c."IHODS_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'HOD';
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'Principal' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."IVRMUL_Id" AS "HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            NULL::BIGINT AS "AMB_Id",
            NULL::VARCHAR AS "AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_Principal" a
        INNER JOIN "IVRM_Principal_Staff" c ON c."IPR_Id" = a."IPR_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."IVRMUL_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND c."HRME_Id" = p_HRME_Id 
            AND a."IPR_ActiveFlag" = 1 
            AND c."IRPS_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'AS' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            NULL::BIGINT AS "AMB_Id",
            NULL::VARCHAR AS "AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_HOD" a
        INNER JOIN "CLG"."IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
        INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
        WHERE a."MI_Id" = p_MI_Id 
            AND c."HRME_Id" = p_HRME_Id 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'AS';
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'EC' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            NULL::BIGINT AS "AMB_Id",
            NULL::VARCHAR AS "AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_HOD" a
        INNER JOIN "CLG"."IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
        WHERE a."MI_Id" = p_MI_Id 
            AND a."HRME_Id" = p_HRME_Id 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'EC';
        RETURN;
    END IF;

ELSIF p_roletype = 'Student' THEN

    IF p_IINTS_Flag = 'HOD' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            E."AMB_Id",
            E."AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_HOD" a
        INNER JOIN "CLG"."IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
        INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = b."AMB_Id" AND E."AMB_ActiveFlag" = 1
        WHERE a."MI_Id" = p_MI_Id 
            AND b."AMB_Id" = p_AMB_Id 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'HOD';
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'Principal' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."IVRMUL_Id" AS "HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            NULL::BIGINT AS "AMB_Id",
            NULL::VARCHAR AS "AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_Principal" a
        INNER JOIN "IVRM_Principal_CourseBranch" b ON a."IPR_Id" = b."IPR_Id"
        INNER JOIN "IVRM_Principal_Staff" c ON c."IPR_Id" = a."IPR_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."IVRMUL_Id"
        INNER JOIN "CLG"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND b."AMCO_Id" = p_AMCO_Id 
            AND b."AMB_Id" = p_AMB_Id 
            AND a."IPR_ActiveFlag" = 1 
            AND b."IRPCB_ActiveFlag" = 1 
            AND c."IRPS_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'AS' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            E."AMB_Id",
            E."AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_HOD" a
        INNER JOIN "CLG"."IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
        INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = b."AMB_Id" AND E."AMB_ActiveFlag" = 1
        WHERE a."MI_Id" = p_MI_Id 
            AND b."AMB_Id" = p_AMB_Id 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'AS';
        RETURN;
    END IF;

    IF p_IINTS_Flag = 'EC' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            e."AMB_Id",
            e."AMB_BranchName",
            NULL::BIGINT AS "AMSE_Id",
            NULL::VARCHAR AS "AMSE_SEMName",
            NULL::BIGINT AS "ASMAY_Id"
        FROM "IVRM_HOD" a
        INNER JOIN "CLG"."IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
        INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id" AND e."AMB_ActiveFlag" = 1
        WHERE a."MI_Id" = p_MI_Id 
            AND b."AMB_Id" = p_AMB_Id 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'EC';
        RETURN;
    END IF;

END IF;

RETURN;

END;
$$;