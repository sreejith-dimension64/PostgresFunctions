CREATE OR REPLACE FUNCTION "dbo"."Fee_receiptnogeneration_School"(
    "MI_Id" VARCHAR(100),
    "asmayid" VARCHAR(100),
    "fmgid" TEXT,
    OUT "Receiptno" VARCHAR(500)
)
RETURNS VARCHAR(500)
LANGUAGE plpgsql
AS $$
DECLARE
    "Prefixname" VARCHAR(50);
    "Suffixname" VARCHAR(50);
    "Prefixnamelen" BIGINT;
    "suffixnamelen" BIGINT;
    "Rowcount" BIGINT;
    "objcursor" REFCURSOR;
    rec RECORD;
BEGIN

    FOR rec IN EXECUTE 
        'SELECT DISTINCT "FGAR_PrefixName", "FGAR_SuffixName" 
         FROM "Fee_Groupwise_AutoReceipt" 
         INNER JOIN "Fee_Groupwise_AutoReceipt_Groups" 
            ON "Fee_Groupwise_AutoReceipt_Groups"."fgar_id" = "Fee_Groupwise_AutoReceipt"."fgar_id" 
         WHERE "Fee_Groupwise_AutoReceipt"."mi_id" = ' || "MI_Id" || 
        ' AND "Fee_Groupwise_AutoReceipt"."asmay_id" = ' || "asmayid" || 
        ' AND "fmg_id" IN (' || "fmgid" || ')'
    LOOP
        "Prefixname" := rec."FGAR_PrefixName";
        "Suffixname" := rec."FGAR_SuffixName";
    END LOOP;

    "Prefixnamelen" := LENGTH("Prefixname");
    "suffixnamelen" := LENGTH("Suffixname");

    "suffixnamelen" := "suffixnamelen" + "Prefixnamelen";
    "Prefixnamelen" := "Prefixnamelen" + 1;

    SELECT COUNT(*) INTO "Rowcount" 
    FROM "Fee_Y_Payment" 
    WHERE "MI_Id" = "Fee_receiptnogeneration_School"."MI_Id" 
      AND "ASMAY_Id" = "Fee_receiptnogeneration_School"."asmayid" 
      AND "FYP_Receipt_No" LIKE "Prefixname" || '%' || "Suffixname";

    IF "Rowcount" = 0 THEN
        "Receiptno" := '1';
        "Receiptno" := "Prefixname" || "Receiptno" || "Suffixname";
    ELSE
        SELECT MAX(CAST(SUBSTRING("FYP_Receipt_No", "Prefixnamelen", (LENGTH("FYP_Receipt_No") - "suffixnamelen")) AS BIGINT)) 
        INTO "Receiptno"
        FROM "Fee_Y_Payment" 
        WHERE "mi_id" = "Fee_receiptnogeneration_School"."MI_Id" 
          AND "asmay_id" = "Fee_receiptnogeneration_School"."asmayid" 
          AND "FYP_Receipt_No" LIKE "Prefixname" || '%' || "Suffixname";
        
        "Receiptno" := CAST(CAST("Receiptno" AS BIGINT) + 1 AS VARCHAR);
        "Receiptno" := "Prefixname" || "Receiptno" || "Suffixname";
    END IF;

END;
$$;