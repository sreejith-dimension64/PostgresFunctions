CREATE OR REPLACE FUNCTION "dbo"."Fee_SummarizedReport"(
    "amay_id" bigint,
    "asmcl_id" bigint,
    "asms_id" bigint,
    "amst_id" bigint,
    "mi_id" bigint,
    "fmt_id" text,
    "fmgg_id" text,
    "type" varchar(20),
    "AllInd" varchar(20),
    "fmh_id" text
)
RETURNS TABLE(
    "FMH_FeeName" varchar(300),
    "FTI_Name" varchar(200),
    "FMT_Id" varchar(100),
    "FMG_Id" bigint,
    "FMA_Id" bigint,
    "FTI_Id" bigint,
    "FMH_Id" bigint,
    "ASMAY_Id" bigint,
    "FSS_ToBePaid" bigint,
    "FSS_PaidAmount" decimal(18,0),
    "FSS_ConcessionAmount" decimal(18,0),
    "FSS_NetAmount" decimal(18,0),
    "FSS_FineAmount" decimal(18,0),
    "AMAY_RollNo" bigint,
    "FSS_RefundAmount" decimal(18,0),
    "ASMCL_ClassName" varchar(100),
    "ASMC_SectionName" varchar(100),
    "Name" varchar(100),
    "AMST_AdmNo" varchar(100),
    "AMST_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "AMST_FatherName" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "amount" float;
    "b" int;
    "fma_id" bigint;
    "Date" date;
    "Dynamic" text;
    "FMA_New" bigint;
    "AMST_New" bigint;
    "FMT_New" bigint;
    "ASMAY_New" bigint;
    rec RECORD;
BEGIN
    
    "Date" := CURRENT_DATE;
    
    IF "type" = 'Annual' THEN
        
        IF "AllInd" = 'All' THEN
            
            RETURN QUERY
            SELECT DISTINCT
                "Fee_Master_Head"."FMH_FeeName",
                "Fee_T_Installment"."FTI_Name",
                NULL::varchar(100) AS "FMT_Id",
                "Fee_Student_Status"."FMG_Id",
                "Fee_Student_Status"."FMA_Id",
                "Fee_Student_Status"."FTI_Id",
                "Fee_Student_Status"."FMH_Id",
                "Fee_Student_Status"."ASMAY_Id",
                "Fee_Student_Status"."FSS_ToBePaid",
                "Fee_Student_Status"."FSS_PaidAmount",
                "Fee_Student_Status"."FSS_ConcessionAmount",
                NULL::decimal(18,0) AS "FSS_NetAmount",
                "Fee_Student_Status"."FSS_FineAmount",
                "Adm_School_Y_Student"."AMAY_RollNo",
                NULL::decimal(18,0) AS "FSS_RefundAmount",
                "Adm_School_M_Class"."ASMCL_ClassName",
                "Adm_School_M_Section"."ASMC_SectionName",
                (COALESCE("Adm_M_Student"."AMST_FirstName",'') || ' ' || COALESCE("Adm_M_Student"."AMST_MiddleName",'') || ' ' || COALESCE("Adm_M_Student"."AMST_LastName",''))::varchar(100) AS "Name",
                "Adm_M_Student"."AMST_AdmNo",
                "Adm_M_Student"."AMST_Id",
                "Adm_School_M_Class"."ASMCL_Id",
                "Adm_School_M_Section"."ASMS_Id",
                "Adm_M_Student"."AMST_FatherName"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Fee_Student_Status"
                INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id"
                    AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            WHERE "Fee_Student_Status"."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "Fee_Student_Status"."ASMAY_Id" = "amay_id"
            )
            AND "Fee_Student_Status"."FSS_ActiveFlag" = true
            AND "Fee_Master_Head"."FMH_Flag" = 'N'
            AND "Fee_Student_Status"."MI_Id" = "mi_id"
            AND "Adm_School_M_Class"."ASMCL_Id" = "asmcl_id"
            AND "Adm_School_M_Section"."ASMS_Id" = "asms_id"
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0
            ORDER BY "Adm_M_Student"."AMST_Id"
            LIMIT 100;
            
        ELSIF "AllInd" = 'Ind' THEN
            
            RETURN QUERY
            SELECT DISTINCT
                "Fee_Master_Head"."FMH_FeeName",
                "Fee_T_Installment"."FTI_Name",
                NULL::varchar(100) AS "FMT_Id",
                "Fee_Student_Status"."FMG_Id",
                "Fee_Student_Status"."FMA_Id",
                "Fee_Student_Status"."FTI_Id",
                "Fee_Student_Status"."FMH_Id",
                "Fee_Student_Status"."ASMAY_Id",
                "Fee_Student_Status"."FSS_ToBePaid",
                "Fee_Student_Status"."FSS_PaidAmount",
                "Fee_Student_Status"."FSS_ConcessionAmount",
                NULL::decimal(18,0) AS "FSS_NetAmount",
                "Fee_Student_Status"."FSS_FineAmount",
                "Adm_School_Y_Student"."AMAY_RollNo",
                NULL::decimal(18,0) AS "FSS_RefundAmount",
                "Adm_School_M_Class"."ASMCL_ClassName",
                "Adm_School_M_Section"."ASMC_SectionName",
                (COALESCE("Adm_M_Student"."AMST_FirstName",'') || ' ' || COALESCE("Adm_M_Student"."AMST_MiddleName",'') || ' ' || COALESCE("Adm_M_Student"."AMST_LastName",''))::varchar(100) AS "Name",
                "Adm_M_Student"."AMST_AdmNo",
                "Adm_M_Student"."AMST_Id",
                "Adm_School_M_Class"."ASMCL_Id",
                "Adm_School_M_Section"."ASMS_Id",
                "Adm_M_Student"."AMST_FatherName"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Fee_Student_Status"
                INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id"
                    AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            WHERE "Fee_Student_Status"."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "AMST_Id" = "amst_id"
                AND "Fee_Student_Status"."ASMAY_Id" = "amay_id"
            )
            AND "Fee_Student_Status"."FSS_ActiveFlag" = true
            AND "Fee_Master_Head"."FMH_Flag" = 'N'
            AND "Fee_Student_Status"."MI_Id" = "mi_id"
            AND "Adm_School_M_Class"."ASMCL_Id" = "asmcl_id"
            AND "Adm_School_M_Section"."ASMS_Id" = "asms_id"
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0
            ORDER BY "Adm_M_Student"."AMST_Id"
            LIMIT 100;
            
        END IF;
        
    END IF;
    
    IF "type" = 'Others' THEN
        
        IF "AllInd" = 'All' THEN
            
            "Dynamic" := 'SELECT DISTINCT
                "Fee_Master_Head"."FMH_FeeName",
                "Fee_T_Installment"."FTI_Name",
                "Fee_Master_Terms_FeeHeads"."FMT_Id"::varchar(100),
                "Fee_Student_Status"."FMG_Id",
                "Fee_Student_Status"."FMA_Id",
                "Fee_Student_Status"."FTI_Id",
                "Fee_Student_Status"."FMH_Id",
                "Fee_Student_Status"."ASMAY_Id",
                "Fee_Student_Status"."FSS_ToBePaid",
                "Fee_Student_Status"."FSS_PaidAmount",
                "Fee_Student_Status"."FSS_ConcessionAmount",
                "Fee_Student_Status"."FSS_NetAmount",
                "Fee_Student_Status"."FSS_FineAmount",
                "Adm_School_Y_Student"."AMAY_RollNo",
                "Fee_Student_Status"."FSS_RefundAmount",
                "Adm_School_M_Class"."ASMCL_ClassName",
                "Adm_School_M_Section"."ASMC_SectionName",
                (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",''''))::varchar(100) AS "Name",
                "Adm_M_Student"."AMST_AdmNo",
                "Adm_M_Student"."AMST_Id",
                "Adm_School_M_Class"."ASMCL_Id",
                "Adm_School_M_Section"."ASMS_Id",
                "Adm_M_Student"."AMST_FatherName"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Fee_Student_Status"
                INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
                    AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
                INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id"
                    AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            WHERE "Fee_Student_Status"."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "Fee_Student_Status"."ASMAY_Id" = ' || "amay_id" || '
            )
            AND "Fee_Student_Status"."FSS_ActiveFlag" = true
            AND "Fee_Student_Status"."MI_Id" = ' || "mi_id" || '
            AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')
            AND "Fee_Master_Terms_FeeHeads"."FMH_Id" IN (' || "fmh_id" || ')
            AND "Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || '
            AND "Adm_School_M_Section"."ASMS_Id" = ' || "asms_id" || '
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0
            ORDER BY "AMST_Id"
            LIMIT 100';
            
            CREATE TEMP TABLE "AllFees"(
                "FMH_FeeName" varchar(300),
                "FTI_Name" varchar(200),
                "FMT_Id" varchar(100),
                "FMG_Id" bigint,
                "FMA_Id" bigint,
                "FTI_Id" bigint,
                "FMH_Id" bigint,
                "ASMAY_Id" bigint,
                "FSS_ToBePaid" bigint,
                "FSS_PaidAmount" decimal(18,0),
                "FSS_ConcessionAmount" decimal(18,0),
                "FSS_NetAmount" decimal(18,0),
                "FSS_FineAmount" decimal(18,0),
                "AMAY_RollNo" bigint,
                "FSS_RefundAmount" decimal(18,0),
                "ASMCL_ClassName" varchar(100),
                "ASMC_SectionName" varchar(100),
                "Name" varchar(100),
                "AMST_AdmNo" varchar(100),
                "AMST_Id" bigint,
                "ASMCL_Id" bigint,
                "ASMS_Id" bigint,
                "AMST_FatherName" text
            ) ON COMMIT DROP;
            
            EXECUTE 'INSERT INTO "AllFees" SELECT * FROM (' || "Dynamic" || ') AS subquery';
            
            FOR rec IN SELECT DISTINCT "AMST_Id", "FMT_Id", "FMA_Id", "ASMAY_Id" FROM "AllFees"
            LOOP
                "AMST_New" := rec."AMST_Id";
                "FMT_New" := rec."FMT_Id"::bigint;
                "FMA_New" := rec."FMA_Id";
                "ASMAY_New" := rec."ASMAY_Id";
                
                PERFORM "dbo"."Sp_Calculate_Fine"("Date", "ASMAY_New", "FMA_New", "amount", "b");
                
                UPDATE "AllFees" SET "FSS_FineAmount" = "amount"
                WHERE "ASMAY_Id" = "ASMAY_New"
                AND "FMA_Id" = "FMA_New"
                AND "AMST_Id" = "AMST_New"
                AND "FMT_Id" = "FMT_New"::varchar(100);
            END LOOP;
            
            RETURN QUERY SELECT * FROM "AllFees";
            
        ELSIF "AllInd" = 'Ind' THEN
            
            "Dynamic" := 'SELECT DISTINCT
                "Fee_Master_Head"."FMH_FeeName",
                "Fee_T_Installment"."FTI_Name",
                "Fee_Master_Terms_FeeHeads"."FMT_Id"::varchar(100),
                "Fee_Student_Status"."FMG_Id",
                "Fee_Student_Status"."FMA_Id",
                "Fee_Student_Status"."FTI_Id",
                "Fee_Student_Status"."FMH_Id",
                "Fee_Student_Status"."ASMAY_Id",
                "Fee_Student_Status"."FSS_ToBePaid",
                "Fee_Student_Status"."FSS_PaidAmount",
                "Fee_Student_Status"."FSS_ConcessionAmount",
                "Fee_Student_Status"."FSS_NetAmount",
                "Fee_Student_Status"."FSS_FineAmount",
                "Adm_School_Y_Student"."AMAY_RollNo",
                "Fee_Student_Status"."FSS_RefundAmount",
                "Adm_School_M_Class"."ASMCL_ClassName",
                "Adm_School_M_Section"."ASMC_SectionName",
                (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",''''))::varchar(100) AS "Name",
                "Adm_M_Student"."AMST_AdmNo",
                "Adm_M_Student"."AMST_Id",
                "Adm_School_M_Class"."ASMCL_Id",
                "Adm_School_M_Section"."ASMS_Id",
                "Adm_M_Student"."AMST_FatherName"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Fee_Student_Status"
                INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
                    AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
                INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id"
                    AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            WHERE "Fee_Student_Status"."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "AMST_Id" = ' || "amst_id" || '
                AND "Fee_Student_Status"."ASMAY_Id" = ' || "amay_id" || '
            )
            AND "Fee_Student_Status"."FSS_ActiveFlag" = true
            AND "Fee_Student_Status"."MI_Id" = ' || "mi_id" || '
            AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')
            AND "Fee_Master_Terms_FeeHeads"."FMH_Id" IN (' || "fmh_id" || ')
            AND "Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || '
            AND "Adm_School_M_Section"."ASMS_Id" = ' || "asms_id" || '
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0
            ORDER BY "AMST_Id"
            LIMIT 100';
            
            CREATE TEMP TABLE "IndFees"(
                "FMH_FeeName" varchar(300),
                "FTI_Name" varchar(200),
                "FMT_Id" varchar(100),
                "FMG_Id" bigint,
                "FMA_Id" bigint,
                "FTI_Id" bigint,
                "FMH_Id" bigint,
                "ASMAY_Id" bigint,
                "FSS_ToBePaid" bigint,
                "FSS_PaidAmount" decimal(18,0),
                "FSS_ConcessionAmount" decimal(18,0),
                "FSS_NetAmount" decimal(18,0),
                "FSS_FineAmount" decimal(18,0),
                "AMAY_RollNo" bigint,
                "FSS_RefundAmount" decimal(18,0),
                "ASMCL_ClassName" varchar(100),
                "ASMC_SectionName" varchar(100),
                "Name" varchar(100),
                "AMST_AdmNo" varchar(100),
                "AMST_Id" bigint,
                "ASMCL_Id" bigint,
                "ASMS_Id" bigint,
                "AMST_FatherName" text
            ) ON COMMIT DROP;
            
            EXECUTE 'INSERT INTO "IndFees" SELECT * FROM (' || "Dynamic" || ') AS subquery';
            
            FOR rec IN SELECT DISTINCT "AMST_Id", "FMA_Id" FROM "IndFees"
            LOOP
                "FMA_New" := rec."AMST_Id";
                "AMST_New" := rec."FMA_Id";
                
                PERFORM "dbo"."Sp_Calculate_Fine"("Date", "amay_id", "AMST_New", "amount", "b");
                
                UPDATE "IndFees" SET "FSS_FineAmount" = "amount"
                WHERE "ASMAY_Id" = "amay_id"
                AND "FMA_Id" = "AMST_New"
                AND "AMST_Id" = "FMA_New"
                AND "FMT_Id" = "fmt_id";
            END LOOP;
            
            CREATE TEMP TABLE "IndFessNew" ON COMMIT DROP AS SELECT * FROM "IndFees";
            
            RETURN QUERY
            SELECT 
                B."FMH_FeeName",
                string_agg(A."FTI_Name", ', ' ORDER BY A."FTI_Name")::varchar(200) AS "FTI_Name",
                NULL::varchar(100) AS "FMT_Id",
                B."FMG_Id",
                NULL::bigint AS "FMA_Id",
                NULL::bigint AS "FTI_Id",
                B."FMH_Id",
                B."ASMAY_Id",
                SUM(B."FSS_ToBePaid")::bigint AS "FSS_ToBePaid",
                SUM(B."FSS_PaidAmount") AS "FSS_PaidAmount",
                SUM(B."FSS_ConcessionAmount") AS "FSS_ConcessionAmount",
                SUM(B."FSS_NetAmount") AS "FSS_NetAmount",
                SUM(B."FSS_FineAmount") AS "FSS_FineAmount",
                B."AMAY_RollNo",
                SUM(B."FSS_RefundAmount") AS "FSS_RefundAmount",
                B."ASMCL_ClassName",
                B."ASMC_SectionName",
                B."Name",
                B."AMST_AdmNo",
                B."AMST_Id",
                B."ASMCL_Id",
                B."ASMS_Id",
                B."AMST_FatherName"
            FROM "IndFessNew" B
            LEFT JOIN "IndFessNew" A ON A."AMST_Id" = B."AMST_Id" 
                AND A."FMH_FeeName" = B."FMH_FeeName" 
                AND A."FMG_Id" = B."FMG_Id" 
                AND A."FMH_Id" = B."FMH_Id"
                AND A."ASMAY_Id" = B."ASMAY_Id" 
                AND A."AMAY_RollNo" = B."AMAY_RollNo" 
                AND A."ASMCL_ClassName" = B."ASMCL_ClassName"
                AND A."ASMC_SectionName" = B."ASMC_SectionName" 
                AND A."Name" = B."Name" 
                AND A."AMST_AdmNo" = B."AMST_AdmNo"
                AND A."AMST_FatherName" = B."AMST_FatherName"
            GROUP BY 
                B."FMH_FeeName", B."FMG_Id", B."FMH_Id", B."ASMAY_Id", B."AMAY_RollNo", 
                B."ASMCL_ClassName", B."ASMC_SectionName", B."Name", B."AMST_AdmNo", 
                B."ASMCL_Id", B."ASMS_Id", B."AMST_Id", B."AMST_FatherName";
            
        END IF;
        
    END IF;
    
    RETURN;
    
END;
$$;