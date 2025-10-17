CREATE OR REPLACE FUNCTION "dbo"."Clg_IVRM_Interaction_ReadCount"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMST_Id BIGINT,
    p_HRME_Id BIGINT,
    p_roleflg VARCHAR(50)
)
RETURNS TABLE(
    "ISMINT_Id" BIGINT,
    "ISTINT_ReadFlg" INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "StudentInt_Temp6clg";
    DROP TABLE IF EXISTS "StudentInt_Temp3clg";
    DROP TABLE IF EXISTS "StudentInt_Temp4clg";
    DROP TABLE IF EXISTS "StudentInt_Temp5clg";

    IF p_roleflg = 'Student' THEN
    
        CREATE TEMP TABLE "StudentInt_Temp6clg" AS
        SELECT DISTINCT a."ISMINT_Id",
            COUNT(b."ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "Clg"."Adm_Master_College_Student" AM ON AM."AMCST_Id" = b."ISTINT_ToId"
        WHERE a."MI_Id" = p_MI_Id
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ToId" = p_AMST_Id 
            AND "ISTINT_ToFlg" = 'Student'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp3clg" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE COALESCE("ISTINT_ReadFlg", 0) = 1
            AND "ISTINT_ToId" = p_AMST_Id 
            AND "ISTINT_ToFlg" = 'Student'
        GROUP BY "ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp4clg" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "Clg"."Adm_Master_College_Student" AM ON AM."AMCST_Id" = b."ISTINT_ComposedById"
        WHERE a."MI_Id" = p_MI_Id
            AND a."ISMINT_Id" NOT IN (SELECT "ISMINT_Id" FROM "StudentInt_Temp6clg")
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ComposedById" = p_AMST_Id 
            AND "ISTINT_ComposedByFlg" = 'Student'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp5clg" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE "ISTINT_ComposedById" = p_AMST_Id 
            AND "ISTINT_ComposedByFlg" = 'Student'
        GROUP BY "ISMINT_Id";

        RETURN QUERY
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp6clg" A
        LEFT JOIN "StudentInt_Temp3clg" B ON B."ISMINT_Id" = A."ISMINT_Id"
        UNION
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp4clg" A
        LEFT JOIN "StudentInt_Temp5clg" B ON B."ISMINT_Id" = A."ISMINT_Id";

    END IF;

    IF p_roleflg = 'Staff' THEN

        CREATE TEMP TABLE "StudentInt_Temp6clg" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = p_MI_Id
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ToId" = p_HRME_Id 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp3clg" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE COALESCE("ISTINT_ReadFlg", 0) = 1
            AND "ISTINT_ToId" = p_HRME_Id 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp4clg" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ComposedById"
        WHERE a."MI_Id" = p_MI_Id
            AND a."ISMINT_Id" NOT IN (SELECT "ISMINT_Id" FROM "StudentInt_Temp6clg")
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ComposedById" = p_HRME_Id 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp5clg" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE "ISTINT_ComposedById" = p_HRME_Id 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        RETURN QUERY
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp6clg" A
        LEFT JOIN "StudentInt_Temp3clg" B ON B."ISMINT_Id" = A."ISMINT_Id"
        UNION
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp4clg" A
        LEFT JOIN "StudentInt_Temp5clg" B ON B."ISMINT_Id" = A."ISMINT_Id";

    END IF;

    IF p_roleflg = 'HOD' THEN

        CREATE TEMP TABLE "StudentInt_Temp6clg" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ToId"
        WHERE a."MI_Id" = p_MI_Id
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ToId" = p_HRME_Id 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp3clg" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE COALESCE("ISTINT_ReadFlg", 0) = 1
            AND "ISTINT_ToId" = p_HRME_Id 
            AND "ISTINT_ToFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp4clg" AS
        SELECT DISTINCT a."ISMINT_Id", COUNT(b."ISTINT_Id") AS "READFLG"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
        INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ComposedById"
        WHERE a."MI_Id" = p_MI_Id
            AND a."ISMINT_Id" NOT IN (SELECT "ISMINT_Id" FROM "StudentInt_Temp6clg")
            AND a."ISMINT_ActiveFlag" = 1 
            AND b."ISTINT_ActiveFlag" = 1 
            AND b."ISTINT_ComposedById" = p_HRME_Id 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY a."ISMINT_Id";

        CREATE TEMP TABLE "StudentInt_Temp5clg" AS
        SELECT "ISMINT_Id", COUNT("ISTINT_Id") as "READFLG"
        FROM "IVRM_School_Transaction_Interactions"
        WHERE "ISTINT_ComposedById" = p_HRME_Id 
            AND "ISTINT_ComposedByFlg" = 'Staff'
        GROUP BY "ISMINT_Id";

        RETURN QUERY
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp6clg" A
        LEFT JOIN "StudentInt_Temp3clg" B ON B."ISMINT_Id" = A."ISMINT_Id"
        UNION
        SELECT A."ISMINT_Id", 
            (CASE WHEN A."READFLG" = B."READFLG" THEN 1 ELSE 0 END) AS "ISTINT_ReadFlg"
        FROM "StudentInt_Temp4clg" A
        LEFT JOIN "StudentInt_Temp5clg" B ON B."ISMINT_Id" = A."ISMINT_Id";

    END IF;

    DROP TABLE IF EXISTS "StudentInt_Temp6clg";
    DROP TABLE IF EXISTS "StudentInt_Temp3clg";
    DROP TABLE IF EXISTS "StudentInt_Temp4clg";
    DROP TABLE IF EXISTS "StudentInt_Temp5clg";

    RETURN;

END;
$$;