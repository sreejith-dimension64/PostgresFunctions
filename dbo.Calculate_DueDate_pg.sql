CREATE OR REPLACE FUNCTION "dbo"."Calculate_DueDate" (
    "On_Date" TIMESTAMP,
    "fma_id" BIGINT,
    "amay_id" BIGINT,
    OUT "DueDt" TIMESTAMP
)
RETURNS TIMESTAMP
LANGUAGE plpgsql
AS $$
DECLARE
    "Emon" INT;
    "Smon" INT;
    "Syear" INT;
    "Eyear" INT;
    "ftdd_day" FLOAT;
    "ftdd_month" FLOAT;
    v_row_count INT;
BEGIN
    SELECT 
        EXTRACT(YEAR FROM "ASMAY_Year"),
        EXTRACT(YEAR FROM "ASMAY_To_Date"),
        EXTRACT(MONTH FROM "ASMAY_From_Date"),
        EXTRACT(MONTH FROM "ASMAY_To_Date")
    INTO 
        "Syear",
        "Eyear",
        "Emon",
        "Smon"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "asmay_id" = "amay_id";

    SELECT "ftdd_day", "ftdd_month"
    INTO "ftdd_day", "ftdd_month"
    FROM "fee_t_due_date" 
    WHERE "fma_id" = "fma_id";

    IF "ftdd_day" = 0 OR "ftdd_month" = 0 THEN
        "DueDt" := "On_Date";
        RETURN;
    END IF;

    IF "ftdd_month" < "Emon" THEN
        "DueDt" := TO_TIMESTAMP(
            LPAD("ftdd_day"::TEXT, 2, '0') || '/' || 
            LPAD("ftdd_month"::TEXT, 2, '0') || '/' || 
            "Eyear"::TEXT, 
            'DD/MM/YYYY'
        );
    ELSE
        "DueDt" := TO_TIMESTAMP(
            LPAD("ftdd_day"::TEXT, 2, '0') || '/' || 
            LPAD("ftdd_month"::TEXT, 2, '0') || '/' || 
            "Syear"::TEXT, 
            'DD/MM/YYYY'
        );
    END IF;

    RETURN;
END;
$$;