CREATE OR REPLACE FUNCTION "dbo"."AutoReceiptNo_GN_Testing"(
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
        
        RAISE NOTICE 'Prefixname  %', "Prefixname";
        RAISE NOTICE 'Suffixname  %', "Suffixname";
    END LOOP;

    "Prefixnamelen" := LENGTH("Prefixname");
    "suffixnamelen" := LENGTH("Suffixname");

    RAISE NOTICE 'Prefixnamelen   %', "Prefixnamelen";
    RAISE NOTICE 'Suffixnamelen   %', "suffixnamelen";

    "suffixnamelen" := "suffixnamelen" + "Prefixnamelen";
    "Prefixnamelen" := "Prefixnamelen" + 1;

    RAISE NOTICE 'Suffixnamelen   %', "suffixnamelen";
    RAISE NOTICE 'Prefixnamelen   %', "Prefixnamelen";

    SELECT COUNT(*) INTO "Rowcount"
    FROM "Fee_Y_Payment" 
    WHERE "MI_Id" = "MI_Id" 
      AND "ASMAY_ID" = "asmayid" 
      AND "fyp_receipt_no" LIKE "Prefixname" || '%' || "Suffixname";

    IF "Rowcount" = 0 THEN
        "Receiptno" := '1';
        RAISE NOTICE '%', "Prefixname" || "Receiptno" || "Suffixname";
        "Receiptno" := "Prefixname" || "Receiptno" || "Suffixname";
    ELSE
        RAISE NOTICE '%', "Rowcount";
        
        SELECT MAX(CAST(SUBSTRING("fyp_receipt_no", "Prefixnamelen"::INTEGER, (LENGTH("fyp_receipt_no") - "suffixnamelen")::INTEGER) AS BIGINT))
        INTO "Receiptno"
        FROM "Fee_Y_Payment" 
        WHERE "mi_id" = "MI_Id" 
          AND "asmay_id" = "asmayid" 
          AND "fyp_receipt_no" LIKE "Prefixname" || '%' || "Suffixname";
        
        "Receiptno" := (CAST("Receiptno" AS BIGINT) + 1)::VARCHAR;
        RAISE NOTICE '%', "Receiptno";
        RAISE NOTICE '%', "Prefixname" || "Receiptno" || "Suffixname";
        "Receiptno" := "Prefixname" || "Receiptno" || "Suffixname";
    END IF;

END;
$$;