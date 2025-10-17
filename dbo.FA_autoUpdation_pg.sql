CREATE OR REPLACE FUNCTION "dbo"."FA_autoUpdation"(
    "MI_Id" bigint,
    "FAMLED_Id" bigint,
    "IMFY_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "Cmp_code" bigint;
    "Fid" bigint;
    "enddate" date;
    cmp_rec RECORD;
    fy_rec RECORD;
    enddate_rec RECORD;
BEGIN
    "Cmp_code" := 0;

    FOR cmp_rec IN 
        SELECT "FMC"."FAMCOMP_Id" 
        FROM "FA_Master_Company" "FMC" 
        INNER JOIN "FA_Company_FY_Mapping" "FYM" ON "FMC"."FAMCOMP_Id" = "FYM"."FAMCOMP_Id" 
            AND "FMC"."MI_Id" = "FYM"."MI_Id"
        WHERE "FYM"."IMFY_Id" = "IMFY_Id" 
            AND "FMC"."MI_Id" = "MI_Id" 
            AND "FYM"."MI_Id" = "MI_Id"
    LOOP
        "Cmp_code" := cmp_rec."FAMCOMP_Id";
    END LOOP;

    "Fid" := 0;

    FOR fy_rec IN 
        SELECT DISTINCT "IMFY_Id" 
        FROM "FA_Company_FY_Mapping"  
        WHERE "IMFY_Id" > "IMFY_Id" 
            AND "FAMCOMP_Id" = "Cmp_code" 
            AND "MI_Id" = "MI_Id"  
        ORDER BY "IMFY_Id"
    LOOP
        "Fid" := fy_rec."IMFY_Id";

        FOR enddate_rec IN
            SELECT CAST("IMFY_ToDate" AS date) AS "IMFY_ToDate" 
            FROM "IVRM_Master_FinancialYear" 
            WHERE "IMFY_Id" = (
                SELECT "IMFY_Id" 
                FROM "FA_Company_FY_Mapping" 
                WHERE "IMFY_Id" = "Fid" 
                    AND "MI_Id" = "MI_Id" 
                    AND "FAMCOMP_Id" = "Cmp_code"
            )
        LOOP
            "enddate" := enddate_rec."IMFY_ToDate";
        END LOOP;

        PERFORM "dbo"."FA_ClosingbalanceSingLeAcc"("FAMLED_Id", "Fid", "MI_Id", "Cmp_code", "enddate");

    END LOOP;

    RETURN;
END;
$$;