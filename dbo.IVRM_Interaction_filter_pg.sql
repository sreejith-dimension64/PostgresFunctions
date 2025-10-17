CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_filter"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "IINTS_Flag" VARCHAR(50),
    "roletype" VARCHAR(50)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "lgid" BIGINT;
    "lgidcount" BIGINT;
    "ELP_Id" BIGINT;
    "date" BIGINT;
BEGIN
    IF "roletype" = 'Staff' THEN
        IF "IINTS_Flag" = 'Student' THEN
            SELECT "IVRMSTAUL_Id" INTO "lgid" 
            FROM "IVRM_Staff_User_Login" 
            WHERE "Emp_Code" = "HRME_Id";
            
            SELECT "Login_Id", "ELP_Id" INTO "lgidcount", "ELP_Id" 
            FROM "exm"."Exm_Login_Privilege" 
            WHERE "Login_Id" = "lgid" 
            AND ("ELP_Flg" = 'st' OR "ELP_Flg" = 'ct') 
            AND "MI_Id" = "MI_Id" 
            AND "ASMAY_Id" = "ASMAY_Id";
            
            IF "lgidcount" > 0 THEN
                RETURN QUERY
                SELECT DISTINCT a."ASMCL_Id", a."ASMCL_ClassName", c."ASMAY_Id"
                FROM "Adm_School_M_Class" a
                INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "exm"."Exm_Login_Privilege" c ON b."ELP_Id" = c."ELP_Id"
                WHERE a."ASMCL_Id" IN (
                    SELECT "ASMCL_Id" 
                    FROM "exm"."Exm_Login_Privilege_Subjects" 
                    WHERE "ELP_Id" = "ELP_Id" AND "ELPS_ActiveFlg" = 1
                ) 
                AND c."ASMAY_Id" = "ASMAY_Id"
                
                UNION
                
                SELECT DISTINCT 
                    MC."ASMCL_Id", SC."ASMCL_ClassName", MC."ASMAY_Id"
                FROM "IVRM_Master_ClassTeacher" MC
                INNER JOIN "Adm_School_M_Class" SC ON MC."ASMCL_Id" = SC."ASMCL_Id"
                INNER JOIN "HR_Master_Employee" ME ON ME."HRME_Id" = MC."HRME_Id"
                WHERE SC."MI_Id" = "MI_Id" 
                AND MC."ASMAY_Id" = "ASMAY_Id" 
                AND ME."HRME_Id" = "HRME_Id" 
                AND SC."ASMCL_ActiveFlag" = 1 
                AND MC."IMCT_ActiveFlag" = 1;
            ELSE
                RETURN QUERY
                SELECT DISTINCT ME."HRME_Id", 
                    (COALESCE(ME."HRME_EmployeeFirstName", '') || ' ' || COALESCE(ME."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(ME."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                    MC."ASMCL_Id", SC."ASMCL_ClassName", MC."ASMAY_Id"
                FROM "IVRM_Master_ClassTeacher" MC
                INNER JOIN "Adm_School_M_Class" SC ON MC."ASMCL_Id" = SC."ASMCL_Id"
                INNER JOIN "HR_Master_Employee" ME ON ME."HRME_Id" = MC."HRME_Id"
                WHERE SC."MI_Id" = "MI_Id" 
                AND MC."ASMAY_Id" = "ASMAY_Id" 
                AND ME."HRME_Id" = "HRME_Id" 
                AND SC."ASMCL_ActiveFlag" = 1 
                AND MC."IMCT_ActiveFlag" = 1;
            END IF;
        END IF;
        
        IF "IINTS_Flag" = 'Teachers' THEN
            RETURN QUERY
            SELECT DISTINCT d."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                d."HRME_EmployeeCode"
            FROM "exm"."Exm_Login_Privilege" a
            INNER JOIN "IVRM_Staff_User_Login" c ON c."IVRMSTAUL_Id" = a."Login_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."Emp_Code"
            WHERE a."MI_Id" = "MI_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND a."ELP_ActiveFlg" = 1 
            AND d."HRME_LeftFlag" = 0 
            AND a."ELP_Flg" IN ('st', 'ct');
        ELSIF "IINTS_Flag" = 'HOD' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id"
            WHERE a."MI_Id" = "MI_Id" 
            AND c."HRME_Id" = "HRME_Id" 
            AND a."IHOD_ActiveFlag" = 1 
            AND c."IHODS_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
        ELSIF "IINTS_Flag" = 'Principal' THEN
            RETURN QUERY
            SELECT DISTINCT a."IVRMUL_Id" AS "hrmE_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName"
            FROM "IVRM_Principal" a
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."IVRMUL_Id"
            WHERE a."MI_Id" = "MI_Id" 
            AND a."IPR_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
        ELSIF "IINTS_Flag" = 'AS' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Class" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODC_ActiveFlag" = 1
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            WHERE a."MI_Id" = "MI_Id" 
            AND c."HRME_Id" = "HRME_Id" 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'AS';
        ELSIF "IINTS_Flag" = 'EC' THEN
            RETURN QUERY
            SELECT a."HRME_Id" AS "hrmE_Id",
                (COALESCE(b."HRME_EmployeeFirstName", '') || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(b."HRME_EmployeeLastName", ''))::TEXT AS "empName"
            FROM "IVRM_HOD" a, "HR_Master_Employee" b
            WHERE a."HRME_Id" = b."HRME_Id" 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'EC';
        END IF;
    ELSIF "roletype" = 'Student' THEN
        IF "IINTS_Flag" = 'SubjectTeacher' THEN
            RETURN QUERY
            SELECT DISTINCT d."HRME_Id" AS "hrmE_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                e."ISMS_SubjectName"
            FROM "exm"."Exm_Login_Privilege" a
            INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
            INNER JOIN "IVRM_Staff_User_Login" c ON c."IVRMSTAUL_Id" = a."Login_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."Emp_Code"
            INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = b."ISMS_Id"
            WHERE a."MI_Id" = "MI_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND b."ASMCL_Id" = "ASMCL_Id" 
            AND b."ASMS_Id" = "ASMS_Id" 
            AND a."ELP_ActiveFlg" = 1 
            AND b."ELPS_ActiveFlg" = 1 
            AND a."ELP_Flg" = 'st';
        ELSIF "IINTS_Flag" = 'ClassTeacher' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id" AS "hrmE_Id", a."ASMCL_Id", a."ASMS_Id",
                (COALESCE(b."HRME_EmployeeFirstName", '') || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(b."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                c."ASMCL_ClassName", d."ASMC_SectionName"
            FROM "IVRM_Master_ClassTeacher" a
            INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id" AND b."HRME_LeftFlag" = 0 AND b."HRME_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" c ON a."ASMCL_Id" = c."ASMCL_Id" AND c."ASMCL_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Section" d ON a."ASMS_Id" = d."ASMS_Id" AND d."ASMC_ActiveFlag" = 1
            WHERE a."MI_Id" = "MI_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND a."ASMCL_Id" = "ASMCL_Id" 
            AND a."ASMS_Id" = "ASMS_Id" 
            AND a."IMCT_ActiveFlag" = 1;
        END IF;
        
        IF "IINTS_Flag" = 'HOD' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id" AS "hrmE_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                e."ASMCL_ClassName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Class" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODC_ActiveFlag" = 1
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = b."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1
            WHERE a."MI_Id" = "MI_Id" 
            AND b."ASMCL_Id" = "ASMCL_Id" 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'HOD';
        END IF;
        
        IF "IINTS_Flag" = 'Principal' THEN
            RETURN QUERY
            SELECT DISTINCT a."IVRMUL_Id" AS "hrmE_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName"
            FROM "IVRM_Principal" a
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."IVRMUL_Id"
            WHERE a."MI_Id" = "MI_Id" 
            AND a."IPR_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
        END IF;
        
        IF "IINTS_Flag" = 'AS' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id" AS "hrmE_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                e."ASMCL_ClassName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Class" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODC_ActiveFlag" = 1
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = b."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1
            WHERE a."MI_Id" = "MI_Id" 
            AND b."ASMCL_Id" = "ASMCL_Id" 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'AS';
        END IF;
    ELSIF "roletype" = 'HOD' THEN
        IF "IINTS_Flag" = 'Student' THEN
            RETURN QUERY
            SELECT DISTINCT ME."HRME_Id",
                (COALESCE(ME."HRME_EmployeeFirstName", '') || ' ' || COALESCE(ME."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(ME."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
                SC."ASMCL_Id", SC."ASMCL_ClassName"
            FROM "IVRM_hod" IH
            INNER JOIN "IVRM_HOD_Class" HC ON IH."IHOD_Id" = HC."IHOD_Id"
            LEFT JOIN "Adm_School_M_Class" SC ON SC."ASMCL_Id" = HC."ASMCL_Id"
            LEFT JOIN "HR_Master_Employee" ME ON ME."HRME_Id" = IH."HRME_Id"
            WHERE IH."MI_Id" = "MI_Id" 
            AND IH."HRME_Id" = "HRME_Id" 
            AND IH."IHOD_ActiveFlag" = 1 
            AND HC."IHODC_ActiveFlag" = 1;
        ELSIF "IINTS_Flag" = 'Teachers' THEN
            RETURN QUERY
            SELECT b."HRME_Id",
                (COALESCE(c."HRME_EmployeeFirstName", '') || ' ' || COALESCE(c."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(c."HRME_EmployeeLastName", ''))::TEXT AS "EmpName"
            FROM "IVRM_HOD" a, "IVRM_HOD_Staff" b, "HR_Master_Employee" c
            WHERE a."IHOD_Id" = b."IHOD_Id" 
            AND b."HRME_Id" = c."HRME_Id" 
            AND a."HRME_Id" = "HRME_Id" 
            AND c."HRME_ActiveFlag" = 1 
            AND b."IHODS_ActiveFlag" = 1 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."MI_Id" = "MI_Id";
        ELSIF "IINTS_Flag" = 'Principal' THEN
            RETURN QUERY
            SELECT DISTINCT a."IVRMUL_Id" AS "hrmE_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName"
            FROM "IVRM_Principal" a
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."IVRMUL_Id"
            WHERE a."MI_Id" = "MI_Id" 
            AND a."IPR_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
        ELSIF "IINTS_Flag" = 'AS' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id",
                (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::TEXT AS "EmpName"
            FROM "IVRM_HOD" a
            INNER JOIN "IVRM_HOD_Class" b ON a."IHOD_Id" = b."IHOD_Id" AND b."IHODC_ActiveFlag" = 1
            INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
            INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1
            WHERE a."MI_Id" = "MI_Id" 
            AND c."HRME_Id" = "HRME_Id" 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'AS';
        ELSIF "IINTS_Flag" = 'EC' THEN
            RETURN QUERY
            SELECT a."HRME_Id" AS "hrmE_Id",
                (COALESCE(b."HRME_EmployeeFirstName", '') || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(b."HRME_EmployeeLastName", ''))::TEXT AS "empName"
            FROM "IVRM_HOD" a, "HR_Master_Employee" b
            WHERE a."HRME_Id" = b."HRME_Id" 
            AND a."IHOD_ActiveFlag" = 1 
            AND a."IHOD_Flg" = 'EC';
        END IF;
    END IF;
    
    RETURN;
END;
$$;