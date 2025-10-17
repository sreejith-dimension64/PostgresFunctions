CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_ReadCount"(
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
    DROP TABLE IF EXISTS "StudentInt_Temp6";
    DROP TABLE IF EXISTS "StudentInt_Temp3";
    DROP TABLE IF EXISTS "StudentInt_Temp4";
    DROP TABLE IF EXISTS "StudentInt_Temp5";

    IF "roleflg" = 'Student' THEN
    
        CREATE TEMP TABLE "StudentInt_Temp6" AS
        SELECT DISTINCT a."ISMINT_Id",
            COUNT(b."ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "Adm_m_student" AM ON AM."AMST_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = "MI_Id"
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ToId" = "AMST_Id" 
            AND "ISTINT_ToFlg" = 'Student'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp3" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE COALESCE("ISTINT_ReadFlg", 0) = 1
            AND "ISTINT_ToId" = "AMST_Id" 
            AND "ISTINT_ToFlg" = 'Student'
        GROUP BY "ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp4" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "Adm_m_student" AM ON AM."AMST_ID" = b."ISTINT_ComposedById"
        WHERE a."MI_Id" = "MI_Id"
            AND a."ISMINT_Id" NOT IN (SELECT "ISMINT_Id" FROM "StudentInt_Temp6")
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ComposedById" = "AMST_Id" 
            AND "ISTINT_ComposedByFlg" = 'Student'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp5" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE "ISTINT_ComposedById" = "AMST_Id" 
            AND "ISTINT_ComposedByFlg" = 'Student'
        GROUP BY "ISMINT_Id";

        RETURN QUERY
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp6" A
        LEFT JOIN "StudentInt_Temp3" B ON B."ISMINT_Id" = A."ISMINT_Id"
        UNION
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp4" A
        LEFT JOIN "StudentInt_Temp5" B ON B."ISMINT_Id" = A."ISMINT_Id";

    END IF;

    IF "roleflg" = 'Staff' THEN

        CREATE TEMP TABLE "StudentInt_Temp6" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = "MI_Id"
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ToId" = "HRME_Id" 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp3" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE COALESCE("ISTINT_ReadFlg", 0) = 1
            AND "ISTINT_ToId" = "HRME_Id" 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp4" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ComposedById"
        WHERE a."MI_Id" = "MI_Id"
            AND a."ISMINT_Id" NOT IN (SELECT "ISMINT_Id" FROM "StudentInt_Temp6")
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ComposedById" = "HRME_Id" 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp5" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE "ISTINT_ComposedById" = "HRME_Id" 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        RETURN QUERY
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp6" A
        LEFT JOIN "StudentInt_Temp3" B ON B."ISMINT_Id" = A."ISMINT_Id"
        UNION
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp4" A
        LEFT JOIN "StudentInt_Temp5" B ON B."ISMINT_Id" = A."ISMINT_Id";

    END IF;

    IF "roleflg" = 'HOD' THEN

        CREATE TEMP TABLE "StudentInt_Temp6" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = "MI_Id"
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ToId" = "HRME_Id" 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp3" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE COALESCE("ISTINT_ReadFlg", 0) = 1
            AND "ISTINT_ToId" = "HRME_Id" 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp4" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ComposedById"
        WHERE a."MI_Id" = "MI_Id"
            AND a."ISMINT_Id" NOT IN (SELECT "ISMINT_Id" FROM "StudentInt_Temp6")
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ComposedById" = "HRME_Id" 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp5" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE "ISTINT_ComposedById" = "HRME_Id" 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        RETURN QUERY
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp6" A
        LEFT JOIN "StudentInt_Temp3" B ON B."ISMINT_Id" = A."ISMINT_Id"
        UNION
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp4" A
        LEFT JOIN "StudentInt_Temp5" B ON B."ISMINT_Id" = A."ISMINT_Id";

    END IF;

    DROP TABLE IF EXISTS "StudentInt_Temp6";
    DROP TABLE IF EXISTS "StudentInt_Temp3";
    DROP TABLE IF EXISTS "StudentInt_Temp4";
    DROP TABLE IF EXISTS "StudentInt_Temp5";

    RETURN;
END;
$$;