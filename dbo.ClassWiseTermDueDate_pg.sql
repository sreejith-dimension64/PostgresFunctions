CREATE OR REPLACE FUNCTION "dbo"."ClassWiseTermDueDate"(
    "TermIds" TEXT,
    "Classids" TEXT,
    "groupids" TEXT,
    "MI_Id" VARCHAR(60),
    "ASMAY_Id" VARCHAR(60)
)
RETURNS TABLE(
    "ASMCL_Id" BIGINT,
    "FMT_Id" BIGINT,
    "DueDate" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    "DueDate" VARCHAR(10);
    "NoOfDays" INT;
    "Emon" INT;
    "Smon" INT;
    "Syear" INT;
    "Eyear" INT;
    "FMA_Id" BIGINT;
    "FTI_Id" BIGINT;
    "ftdd_day" FLOAT;
    "ftdd_month" FLOAT;
    "frm_day" INT;
    "fmfs_from_day" INT;
    "FMH_Id" BIGINT;
    "fmfs_to_day" INT;
    "FMH_FeeName" VARCHAR(70);
    "FTFS_Amount" FLOAT;
    "from_day" INT;
    "FMT_Name" VARCHAR(70);
    "FMT_Id" BIGINT;
    "On_Date" DATE;
    "Sqldynamic" TEXT;
    "FASMCL_Id" BIGINT;
    "FFMA_Id" BIGINT;
    "Sqldynamic1" TEXT;
    classfmaids_rec RECORD;
    termids_rec RECORD;
    fmaids_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "FeeTermsDueDatesClassWise_Temp";
    DROP TABLE IF EXISTS "FeeClassWiseFmaids_Temp";

    CREATE TEMP TABLE "FeeTermsDueDatesClassWise_Temp"(
        "MI_Id" BIGINT,
        "ASMAY_Id" BIGINT,
        "ASMCL_Id" BIGINT,
        "FMH_name" VARCHAR(200),
        "FMT_Id" BIGINT,
        "FMT_Name" VARCHAR(200),
        "FMA_Id" BIGINT,
        "DueDate" DATE,
        "On_Date" DATE
    );

    "Sqldynamic" := 'CREATE TEMP TABLE "FeeClassWiseFmaids_Temp" AS 
        SELECT DISTINCT "ASMCL_Id", "FMA_Id"
        FROM "Fee_Yearly_Class_Category" "FYCC"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" "CL" ON "FYCC"."FYCC_Id" = "CL"."FYCC_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMCC_Id" = "FYCC"."FMCC_Id" 
            AND "FMA"."FMG_Id" IN (' || "groupids" || ')
        WHERE "FYCC"."MI_Id" = ' || "MI_Id" || ' 
            AND "FYCC"."asmay_id" = ' || "ASMAY_Id" || ' 
            AND "FYCC"."FYCC_ActiveFlag" = 1 
            AND "ASMCL_Id" IN (' || "Classids" || ') 
            AND "FMA"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
            AND "FMA"."MI_Id" = ' || "MI_Id";

    EXECUTE "Sqldynamic";

    FOR classfmaids_rec IN 
        SELECT DISTINCT "ASMCL_Id", "FMA_Id" FROM "FeeClassWiseFmaids_Temp"
    LOOP
        "FASMCL_Id" := classfmaids_rec."ASMCL_Id";
        "FFMA_Id" := classfmaids_rec."FMA_Id";

        "frm_day" := 0;
        "On_Date" := CURRENT_DATE;

        SELECT EXTRACT(YEAR FROM "ASMAY_From_Date"), 
               EXTRACT(YEAR FROM "ASMAY_To_Date"), 
               EXTRACT(MONTH FROM "ASMAY_From_Date"), 
               EXTRACT(MONTH FROM "ASMAY_To_Date")
        INTO "Syear", "Eyear", "Smon", "Emon"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Id" = "ASMAY_Id"::BIGINT AND "MI_Id" = "MI_Id"::BIGINT;

        DROP TABLE IF EXISTS "FeeTermIds_Temp";

        "Sqldynamic1" := 'CREATE TEMP TABLE "FeeTermIds_Temp" AS 
            SELECT DISTINCT "FMT_Id" 
            FROM "Fee_Master_Terms" 
            WHERE "MI_Id" = ' || "MI_Id" || ' AND "FMT_Id" IN (' || "TermIds" || ')';
        
        EXECUTE "Sqldynamic1";

        FOR termids_rec IN 
            SELECT DISTINCT "TF"."FTI_Id", "MT"."FMT_Name" 
            FROM "Fee_Master_Terms" "MT"
            INNER JOIN "Fee_Master_Terms_FeeHeads" "TF" 
                ON "MT"."FMT_Id" = "TF"."FMT_Id" 
                AND "TF"."MI_Id" = "MI_Id"::BIGINT
            WHERE "MT"."MI_Id" = "MI_Id"::BIGINT 
                AND "MT"."FMT_Id" IN (SELECT DISTINCT "FMT_Id" FROM "FeeTermIds_Temp")
        LOOP
            "FTI_Id" := termids_rec."FTI_Id";
            "FMT_Name" := termids_rec."FMT_Name";

            FOR fmaids_rec IN 
                SELECT DISTINCT "FMH_Id", "FMA_Id" 
                FROM "FEE_STUDENT_STATUS" 
                WHERE "MI_Id" = "MI_Id"::BIGINT 
                    AND "FTI_Id" = "FTI_Id" 
                    AND "ASMAY_Id" = "ASMAY_Id"::BIGINT 
                    AND "FMA_Id" = "FFMA_Id" 
                    AND "FMG_Id" IN (SELECT DISTINCT "FMG_Id" FROM "FeeClassWiseFmaids_Temp") 
                ORDER BY "FMA_Id"
            LOOP
                "FMH_Id" := fmaids_rec."FMH_Id";
                "FMA_Id" := fmaids_rec."FMA_Id";

                SELECT "ftdd_day", "ftdd_month" 
                INTO "ftdd_day", "ftdd_month"
                FROM "fee_t_due_date" 
                WHERE "FMA_Id" = "FMA_Id" AND "FMA_Id" = "FFMA_Id";

                IF ("ftdd_day" <> 0 AND "ftdd_month" <> 0) THEN

                    IF "ftdd_month" < "Emon" THEN
                        "DueDate" := LPAD("ftdd_day"::TEXT, 2, '0') || '/' || LPAD("ftdd_month"::TEXT, 2, '0') || '/' || "Eyear"::TEXT;
                    ELSE
                        "DueDate" := LPAD("ftdd_day"::TEXT, 2, '0') || '/' || LPAD("ftdd_month"::TEXT, 2, '0') || '/' || "Syear"::TEXT;
                    END IF;

                    RAISE NOTICE 'FMAID --> % DueDate --> %   OnDate --> %', "FMA_Id", "DueDate", "On_Date";

                    SELECT DISTINCT "MT"."FMT_Id" 
                    INTO "FMT_Id"
                    FROM "Fee_Master_Terms" "MT" 
                    WHERE "MT"."MI_Id" = "MI_Id"::BIGINT AND "MT"."FMT_Name" = "FMT_Name";

                    SELECT "FMH_FeeName" 
                    INTO "FMH_FeeName"
                    FROM "Fee_Master_Head" 
                    WHERE "MI_Id" = "MI_Id"::BIGINT AND "FMH_Id" = "FMH_Id";

                    INSERT INTO "FeeTermsDueDatesClassWise_Temp"(
                        "MI_Id", "ASMAY_Id", "ASMCL_Id", "FMH_name", "FMT_Id", 
                        "FMT_Name", "FMA_Id", "DueDate", "On_Date"
                    )
                    VALUES(
                        "MI_Id"::BIGINT, "ASMAY_Id"::BIGINT, "FASMCL_Id", "FMH_FeeName", 
                        "FMT_Id", "FMT_Name", "FMA_Id", 
                        TO_DATE("DueDate", 'DD/MM/YYYY'), "On_Date"
                    );

                END IF;

            END LOOP;

        END LOOP;

    END LOOP;

    RETURN QUERY 
    SELECT "t"."ASMCL_Id", "t"."FMT_Id", MAX("t"."DueDate") AS "DueDate"
    FROM "FeeTermsDueDatesClassWise_Temp" "t"
    GROUP BY "t"."ASMCL_Id", "t"."FMT_Id";

END;
$$;