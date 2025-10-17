CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_filter_CLG"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_HRME_Id BIGINT,
    p_AMCO_Id BIGINT,
    p_AMB_Id BIGINT,
    p_AMSE_Id BIGINT,
    p_ACMS_Id BIGINT,
    p_IINTS_Flag VARCHAR(50),
    p_roletype VARCHAR(50)
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "EmpName" TEXT,
    "AMSE_Id" BIGINT,
    "AMSE_SEMName" VARCHAR,
    "ASMAY_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "HRME_EmployeeCode" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "AMB_BranchName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_roletype = 'Staff' THEN
    
        IF p_IINTS_Flag = 'Student' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                b."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                "SE"."AMSE_Id",
                "SE"."AMSE_SEMName",
                b."ASMAY_Id",
                "CO"."AMCO_Id",
                "CO"."AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "CLG"."Adm_College_Atten_Login_Details" a
            INNER JOIN "CLG"."Adm_College_Atten_Login_User" b ON a."ACALU_Id" = b."ACALU_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = b."HRME_Id"
            INNER JOIN "CLG"."Adm_Master_Course" "CO" ON "CO"."AMCO_Id" = a."AMCO_Id" AND "CO"."AMCO_ActiveFlag" = 1
            INNER JOIN "CLG"."Adm_Master_Branch" "BR" ON "BR"."AMB_Id" = a."AMB_Id" AND "BR"."AMB_ActiveFlag" = 1
            INNER JOIN "CLG"."Adm_Master_Semester" "SE" ON "SE"."AMSE_Id" = a."AMSE_Id"
            WHERE b."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."HRME_Id" = p_HRME_Id AND "SE"."AMSE_ActiveFlg" = 1;
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'Teachers' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                d."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                d."HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "CLG"."Adm_College_Atten_Login_Details" a
            INNER JOIN "CLG"."Adm_College_Atten_Login_User" b ON a."ACALU_Id" = b."ACALU_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = b."HRME_Id"
            WHERE b."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND d."HRME_LeftFlag" = 0 AND d."HRME_Id" != p_HRME_Id;
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'HOD' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHOD_Id" = c."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id"
            WHERE a."MI_Id" = p_MI_Id AND c."HRME_Id" = p_HRME_Id AND a."IHOD_ActiveFlag" = 1 
                AND c."IHODS_ActiveFlag" = 1 AND d."HRME_ActiveFlag" = 1 AND a."IHOD_Flg" = 'HOD' AND b."AMB_Id" = p_AMB_Id;
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'Principal' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."IVRMUL_Id" AS "HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "IVRM_Principal" a
            INNER JOIN "IVRM_Principal_Staff" c ON c."IPR_Id" = a."IPR_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."IVRMUL_Id"
            INNER JOIN "IVRM_Principal_CourseBranch" "CB" ON "CB"."IPR_Id" = a."IPR_Id"
            WHERE a."MI_Id" = p_MI_Id AND c."HRME_Id" = p_HRME_Id AND a."IPR_ActiveFlag" = 1 
                AND c."IRPS_ActiveFlag" = 1 AND d."HRME_ActiveFlag" = 1
                AND "CB"."AMCO_Id" = p_AMCO_Id AND "CB"."AMB_Id" = p_AMB_Id AND "CB"."IRPCB_ActiveFlag" = 1;
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'AS' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            WHERE a."MI_Id" = p_MI_Id AND c."HRME_Id" = p_HRME_Id AND a."IHOD_ActiveFlag" = 1 
                AND a."IHOD_Flg" = 'AS' AND b."AMB_Id" = p_AMB_Id;
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'EC' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            WHERE a."MI_Id" = p_MI_Id AND a."HRME_Id" = p_HRME_Id AND a."IHOD_ActiveFlag" = 1 
                AND a."IHOD_Flg" = 'EC' AND b."AMB_Id" = p_AMB_Id;
            
            RETURN;
        END IF;
        
    ELSIF p_roletype = 'Student' THEN
    
        IF p_IINTS_Flag = 'SubjectTeacher' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                b."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                e."ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "CLG"."Adm_College_Atten_Login_Details" a
            INNER JOIN "CLG"."Adm_College_Atten_Login_User" b ON a."ACALU_Id" = b."ACALU_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = b."HRME_Id"
            INNER JOIN "IVRM_Master_Subjects_Branch" "SB" ON "SB"."AMCO_Id" = a."AMCO_Id" AND "SB"."AMB_Id" = a."AMB_Id" 
                AND "SB"."ISMS_Id" = a."ISMS_Id" AND "SB"."IMSBR_ActiveFlg" = 1
            INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = "SB"."ISMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" y ON y."ASMAY_Id" = b."ASMAY_Id"
            WHERE b."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND a."AMCO_Id" = p_AMCO_Id 
                AND a."AMB_Id" = p_AMB_Id AND a."ACMS_Id" = p_ACMS_Id;
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'HOD' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            INNER JOIN "CLG"."Adm_Master_Branch" "BR" ON "BR"."AMB_Id" = b."AMB_Id" AND "BR"."AMB_ActiveFlag" = 1
            WHERE a."MI_Id" = p_MI_Id AND b."AMB_Id" = p_AMB_Id AND a."IHOD_ActiveFlag" = 1 AND a."IHOD_Flg" = 'HOD';
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'Principal' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."IVRMUL_Id" AS "HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                NULL::VARCHAR AS "AMB_BranchName"
            FROM "IVRM_Principal" a
            INNER JOIN "IVRM_Principal_CourseBranch" b ON a."IPR_Id" = b."IPR_Id"
            INNER JOIN "IVRM_Principal_Staff" c ON c."IPR_Id" = a."IPR_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."HRME_Id"
            INNER JOIN "CLG"."Adm_Master_Course" "CO" ON "CO"."AMCO_Id" = b."AMCO_Id" AND "CO"."AMCO_ActiveFlag" = 1
            INNER JOIN "CLG"."Adm_Master_Branch" "BR" ON "BR"."AMB_Id" = b."AMB_Id" AND "BR"."AMB_ActiveFlag" = 1
            WHERE a."MI_Id" = p_MI_Id AND b."AMCO_Id" = p_AMCO_Id AND b."AMB_Id" = p_AMB_Id 
                AND a."IPR_ActiveFlag" = 1 AND c."IRPS_ActiveFlag" = 1 AND d."HRME_ActiveFlag" = 1
                AND b."IRPCB_ActiveFlag" = 1;
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'AS' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                e."AMB_BranchName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id" AND e."AMB_ActiveFlag" = 1
            WHERE a."MI_Id" = p_MI_Id AND b."AMB_Id" = p_AMB_Id AND a."IHOD_ActiveFlag" = 1 AND a."IHOD_Flg" = 'AS';
            
            RETURN;
        END IF;
        
        IF p_IINTS_Flag = 'EC' THEN
        
            RETURN QUERY
            SELECT DISTINCT 
                a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                NULL::BIGINT AS "AMSE_Id",
                NULL::VARCHAR AS "AMSE_SEMName",
                NULL::BIGINT AS "ASMAY_Id",
                NULL::BIGINT AS "AMCO_Id",
                NULL::VARCHAR AS "AMCO_CourseName",
                NULL::VARCHAR AS "HRME_EmployeeCode",
                NULL::VARCHAR AS "ISMS_SubjectName",
                e."AMB_BranchName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Branch" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODB_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id" AND e."AMB_ActiveFlag" = 1
            WHERE a."MI_Id" = p_MI_Id AND b."AMB_Id" = p_AMB_Id AND a."IHOD_ActiveFlag" = 1 AND a."IHOD_Flg" = 'EC';
            
            RETURN;
        END IF;
        
    END IF;
    
    RETURN;

END;
$$;