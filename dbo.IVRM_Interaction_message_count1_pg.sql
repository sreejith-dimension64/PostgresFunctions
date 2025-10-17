CREATE OR REPLACE FUNCTION "IVRM_Interaction_message_count1"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMST_Id" BIGINT,
    "HRME_Id" BIGINT,
    "roleflg" VARCHAR(50)
)
RETURNS TABLE(
    "ISMINT_Id" BIGINT,
    "ISTINT_ReadFlg" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    DROP TABLE IF EXISTS "StudentInt_Temp2";
    
    IF "roleflg" = 'Student' THEN
        
        CREATE TEMP TABLE "StudentInt_Temp2" AS
        SELECT DISTINCT a."ISMINT_Id",
        (CASE WHEN COUNT(b."ISTINT_Id") = (
            SELECT COUNT(X."ISTINT_Id") 
            FROM "IVRM_School_Transaction_Interactions" X 
            WHERE X."ISTINT_Id" = b."ISTINT_Id" 
            AND COALESCE(X."ISTINT_ReadFlg", 0) = 1
        ) THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "Adm_m_student" AM ON AM."AMST_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = "MI_Id"
        AND a."ISMINT_ActiveFlag" = 1 
        AND b."ISTINT_ActiveFlag" = 1 
        AND b."ISTINT_ToId" = "AMST_Id" 
        AND b."ISTINT_ToFlg" = 'Student'
        GROUP BY a."ISMINT_Id", b."ISTINT_Id";
        
        RETURN QUERY SELECT * FROM "StudentInt_Temp2";
        
    END IF;
    
    IF "roleflg" = 'Staff' THEN
        
        CREATE TEMP TABLE "StudentInt_Temp2" AS
        SELECT DISTINCT a."ISMINT_Id",
        (CASE WHEN COUNT(b."ISTINT_Id") = (
            SELECT COUNT(X."ISTINT_Id") 
            FROM "IVRM_School_Transaction_Interactions" X 
            WHERE X."ISMINT_Id" = a."ISMINT_Id" 
            AND COALESCE(X."ISTINT_ReadFlg", 0) = 1
        ) THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = "MI_Id"
        AND a."ISMINT_ActiveFlag" = 1 
        AND b."ISTINT_ActiveFlag" = 1 
        AND b."ISTINT_ToId" = "HRME_Id" 
        AND b."ISTINT_ToFlg" = 'Staff'
        GROUP BY a."ISMINT_Id", b."ISTINT_Id";
        
        RETURN QUERY SELECT * FROM "StudentInt_Temp2";
        
    END IF;
    
    IF "roleflg" = 'HOD' THEN
        
        CREATE TEMP TABLE "StudentInt_Temp2" AS
        SELECT DISTINCT a."ISMINT_Id",
        (CASE WHEN COUNT(b."ISTINT_Id") = (
            SELECT COUNT(X."ISTINT_Id") 
            FROM "IVRM_School_Transaction_Interactions" X 
            WHERE X."ISMINT_Id" = a."ISMINT_Id" 
            AND COALESCE(X."ISTINT_ReadFlg", 0) = 1
        ) THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = "MI_Id"
        AND a."ISMINT_ActiveFlag" = 1 
        AND b."ISTINT_ActiveFlag" = 1 
        AND b."ISTINT_ToId" = "HRME_Id" 
        AND b."ISTINT_ToFlg" = 'Staff'
        GROUP BY a."ISMINT_Id", b."ISTINT_Id";
        
        RETURN QUERY SELECT * FROM "StudentInt_Temp2";
        
    END IF;
    
    RETURN;
    
END;
$$;