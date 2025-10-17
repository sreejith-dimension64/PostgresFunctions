CREATE OR REPLACE FUNCTION "dbo"."FA_VoucherNoGen" (
    "MI_Id" bigint,
    "IMFY_Id" bigint,
    "EndDay" int,
    "Vid" int,
    "Cdate" timestamp
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    "Cmp_code" bigint;
    "MaxVal" bigint;
    "V_type" varchar(20);
    "Particulars" varchar(10);
    "Start_no" int;
    "Sdate" timestamp;
    "Edate" timestamp;
    row_cnt int;
BEGIN
    SELECT "FAMCOMP_Id" INTO "Cmp_code" 
    FROM "FA_Company_FY_Mapping" 
    WHERE "MI_Id" = "FA_VoucherNoGen"."MI_Id" 
    AND "IMFY_Id" = "FA_VoucherNoGen"."IMFY_Id";
    
    GET DIAGNOSTICS row_cnt = ROW_COUNT;
    
    IF row_cnt = 0 THEN
        "MaxVal" := 0;
        RETURN "MaxVal";
    END IF;
    
    IF "Particulars" = 'Yearly' THEN
        SELECT COALESCE(MAX("FAMVOU_VoucherNo"), 0) INTO "MaxVal" 
        FROM "FA_M_Voucher" 
        WHERE "MI_Id" = "FA_VoucherNoGen"."MI_Id" 
        AND "FAMCOMP_Id" = "Cmp_code" 
        AND "FAMVOU_VoucherType" = "V_type" 
        AND "IMFY_Id" = "FA_VoucherNoGen"."IMFY_Id";
        
        IF "MaxVal" = 0 THEN
            "MaxVal" := "Start_no";
        ELSE
            "MaxVal" := "MaxVal" + 1;
        END IF;
    END IF;
    
    IF "Particulars" = 'Never' THEN
        SELECT COALESCE(MAX(a."FAMVOU_VoucherNo"), 0) INTO "MaxVal" 
        FROM "FA_M_Voucher" a, "FA_Company_FY_Mapping" b 
        WHERE "FAMVOU_VoucherType" = "V_type" 
        AND a."IMFY_Id" = b."IMFY_Id" 
        AND a."MI_Id" = b."MI_Id" 
        AND a."FAMCOMP_Id" = b."FAMCOMP_Id" 
        AND b."FAMCOMP_Id" = "Cmp_code";
        
        IF "MaxVal" = 0 THEN
            "MaxVal" := "Start_no";
        ELSE
            "MaxVal" := "MaxVal" + 1;
        END IF;
    END IF;
    
    IF "Particulars" = 'Monthly' THEN
        "Sdate" := TO_TIMESTAMP('01/' || LPAD(EXTRACT(MONTH FROM "Cdate")::text, 2, '0') || '/' || EXTRACT(YEAR FROM "Cdate")::text, 'DD/MM/YYYY');
        "Edate" := TO_TIMESTAMP(LPAD("EndDay"::text, 2, '0') || '/' || LPAD(EXTRACT(MONTH FROM "Cdate")::text, 2, '0') || '/' || EXTRACT(YEAR FROM "Cdate")::text, 'DD/MM/YYYY');
        
        SELECT COALESCE(MAX("FAMVOU_VoucherNo"), 0) INTO "MaxVal" 
        FROM "FA_M_Voucher" 
        WHERE "FAMVOU_VoucherType" = "V_type" 
        AND "IMFY_Id" = "FA_VoucherNoGen"."IMFY_Id" 
        AND "FAMVOU_VoucherDate"::date BETWEEN "Sdate"::date AND "Edate"::date;
        
        IF "MaxVal" = 0 THEN
            "MaxVal" := "Start_no";
        ELSE
            "MaxVal" := "MaxVal" + 1;
        END IF;
    END IF;
    
    RETURN "MaxVal";
END;
$$;