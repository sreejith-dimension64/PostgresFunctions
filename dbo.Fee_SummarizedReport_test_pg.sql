CREATE OR REPLACE FUNCTION "dbo"."Fee_SummarizedReport_test"(
    "amay_id" BIGINT,
    "asmcl_id" BIGINT,
    "asms_id" BIGINT,
    "amst_id" BIGINT,
    "mi_id" BIGINT,
    "fmt_id" TEXT,
    "fmgg_id" TEXT,
    "type" VARCHAR(20),
    "AllInd" VARCHAR(20),
    "fmh_id" TEXT
)
RETURNS TABLE(
    "FMH_FeeName" VARCHAR(300),
    "FTI_Name" VARCHAR(200),
    "FMT_Id" VARCHAR(100),
    "FMG_Id" BIGINT,
    "FMA_Id" BIGINT,
    "FTI_Id" BIGINT,
    "FMH_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "FSS_ToBePaid" BIGINT,
    "FSS_PaidAmount" DECIMAL(18,0),
    "FSS_ConcessionAmount" DECIMAL(18,0),
    "FSS_NetAmount" DECIMAL(18,0),
    "FSS_FineAmount" DECIMAL(18,0),
    "AMAY_RollNo" BIGINT,
    "FSS_RefundAmount" DECIMAL(18,0),
    "ASMCL_ClassName" VARCHAR(100),
    "ASMC_SectionName" VARCHAR(100),
    "Name" VARCHAR(100),
    "AMST_AdmNo" VARCHAR(100),
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_FatherName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "amount" FLOAT;
    "b" INT;
    "fma_id" BIGINT;
    "Date" DATE;
    "Dynamic" TEXT;
    "FMA_New" BIGINT;
    "AMST_New" BIGINT;
    "FMT_New" BIGINT;
    "ASMAY_New" BIGINT;
    rec RECORD;
BEGIN
    "Date" := CURRENT_DATE;

    IF "type" = 'Annual' THEN
        IF "AllInd" = 'All' THEN
            RAISE NOTICE 'a';
            
            RETURN QUERY
            SELECT DISTINCT
                fmh."FMH_FeeName",
                fti."FTI_Name",
                NULL::VARCHAR(100) AS "FMT_Id",
                fss."FMG_Id",
                fss."FMA_Id",
                fss."FTI_Id",
                fss."FMH_Id",
                fss."ASMAY_Id",
                fss."FSS_ToBePaid",
                fss."FSS_PaidAmount",
                fss."FSS_ConcessionAmount",
                NULL::DECIMAL(18,0) AS "FSS_NetAmount",
                fss."FSS_FineAmount",
                asy."AMAY_RollNo",
                NULL::DECIMAL(18,0) AS "FSS_RefundAmount",
                asc."ASMCL_ClassName",
                ass."ASMC_SectionName",
                (COALESCE(ams."AMST_FirstName",'') || ' ' || COALESCE(ams."AMST_MiddleName",'') || ' ' || COALESCE(ams."AMST_LastName",'')) AS "Name",
                ams."AMST_AdmNo",
                ams."AMST_Id",
                asc."ASMCL_Id",
                ass."ASMS_Id",
                ams."AMST_FatherName"
            FROM "dbo"."Adm_M_Student" ams
            INNER JOIN "dbo"."Fee_Student_Status" fss ON ams."AMST_Id" = fss."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Head" fmh ON fmh."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" fti ON fti."FTI_Id" = fss."FTI_Id"
            INNER JOIN "dbo"."Fee_Group_Login_Previledge" fglp ON fglp."FMG_ID" = fss."FMG_Id" AND fglp."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" asy ON ams."AMST_Id" = asy."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" asc ON asy."ASMCL_Id" = asc."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ass ON asy."ASMS_Id" = ass."ASMS_Id"
            WHERE fss."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE fss."ASMAY_Id" = "amay_id"
            )
            AND fss."FSS_ActiveFlag" = 1
            AND fss."MI_Id" = "mi_id"
            AND asc."ASMCL_Id" = "asmcl_id"
            AND ass."ASMS_Id" = "asms_id"
            AND fss."FSS_ToBePaid" > 0
            ORDER BY ams."AMST_Id"
            LIMIT 100;

        ELSIF "AllInd" = 'Ind' THEN
            RETURN QUERY
            SELECT DISTINCT
                fmh."FMH_FeeName",
                fti."FTI_Name",
                NULL::VARCHAR(100) AS "FMT_Id",
                fss."FMG_Id",
                fss."FMA_Id",
                fss."FTI_Id",
                fss."FMH_Id",
                fss."ASMAY_Id",
                fss."FSS_ToBePaid",
                fss."FSS_PaidAmount",
                fss."FSS_ConcessionAmount",
                NULL::DECIMAL(18,0) AS "FSS_NetAmount",
                fss."FSS_FineAmount",
                asy."AMAY_RollNo",
                NULL::DECIMAL(18,0) AS "FSS_RefundAmount",
                asc."ASMCL_ClassName",
                ass."ASMC_SectionName",
                (COALESCE(ams."AMST_FirstName",'') || ' ' || COALESCE(ams."AMST_MiddleName",'') || ' ' || COALESCE(ams."AMST_LastName",'')) AS "Name",
                ams."AMST_AdmNo",
                ams."AMST_Id",
                asc."ASMCL_Id",
                ass."ASMS_Id",
                ams."AMST_FatherName"
            FROM "dbo"."Adm_M_Student" ams
            INNER JOIN "dbo"."Fee_Student_Status" fss ON ams."AMST_Id" = fss."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Head" fmh ON fmh."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" fti ON fti."FTI_Id" = fss."FTI_Id"
            INNER JOIN "dbo"."Fee_Group_Login_Previledge" fglp ON fglp."FMG_ID" = fss."FMG_Id" AND fglp."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" asy ON ams."AMST_Id" = asy."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" asc ON asy."ASMCL_Id" = asc."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ass ON asy."ASMS_Id" = ass."ASMS_Id"
            WHERE fss."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "AMST_Id" = "amst_id" AND fss."ASMAY_Id" = "amay_id"
            )
            AND fss."FSS_ActiveFlag" = 1
            AND fss."MI_Id" = "mi_id"
            AND asc."ASMCL_Id" = "asmcl_id"
            AND ass."ASMS_Id" = "asms_id"
            AND fss."FSS_ToBePaid" > 0
            ORDER BY ams."AMST_Id"
            LIMIT 100;
        END IF;
    END IF;

    IF "type" = 'Others' THEN
        IF "AllInd" = 'All' THEN
            "Dynamic" := 'SELECT DISTINCT
                fmh."FMH_FeeName",
                fti."FTI_Name",
                fmtfh."FMT_Id"::VARCHAR(100),
                fss."FMG_Id",
                fss."FMA_Id",
                fss."FTI_Id",
                fss."FMH_Id",
                fss."ASMAY_Id",
                fss."FSS_ToBePaid",
                fss."FSS_PaidAmount",
                fss."FSS_ConcessionAmount",
                fss."FSS_NetAmount",
                fss."FSS_FineAmount",
                asy."AMAY_RollNo",
                fss."FSS_RefundAmount",
                asc."ASMCL_ClassName",
                ass."ASMC_SectionName",
                (COALESCE(ams."AMST_FirstName",'''') || '' '' || COALESCE(ams."AMST_MiddleName",'''') || '' '' || COALESCE(ams."AMST_LastName",'''')) AS "Name",
                ams."AMST_AdmNo",
                ams."AMST_Id",
                asc."ASMCL_Id",
                ass."ASMS_Id",
                ams."AMST_FatherName"
            FROM "dbo"."Adm_M_Student" ams
            INNER JOIN "dbo"."Fee_Student_Status" fss ON ams."AMST_Id" = fss."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" fmtfh ON fss."FMH_Id" = fmtfh."FMH_Id" AND fss."FTI_Id" = fmtfh."FTI_Id"
            INNER JOIN "dbo"."Fee_Master_Head" fmh ON fmh."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" fti ON fti."FTI_Id" = fss."FTI_Id"
            INNER JOIN "dbo"."Fee_Group_Login_Previledge" fglp ON fglp."FMG_ID" = fss."FMG_Id" AND fglp."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" asy ON ams."AMST_Id" = asy."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" asc ON asy."ASMCL_Id" = asc."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ass ON asy."ASMS_Id" = ass."ASMS_Id"
            WHERE fss."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE fss."ASMAY_Id" = ' || "amay_id" || '
            )
            AND fss."FSS_ActiveFlag" = 1
            AND fss."MI_Id" = ' || "mi_id" || '
            AND fmtfh."FMT_Id" IN (' || "fmt_id" || ')
            AND fmtfh."FMH_Id" IN (' || "fmh_id" || ')
            AND asc."ASMCL_Id" = ' || "asmcl_id" || '
            AND ass."ASMS_Id" = ' || "asms_id" || '
            AND fss."FSS_ToBePaid" > 0
            ORDER BY ams."AMST_Id"
            LIMIT 100';

            CREATE TEMP TABLE "AllFees"(
                "FMH_FeeName" VARCHAR(300),
                "FTI_Name" VARCHAR(200),
                "FMT_Id" VARCHAR(100),
                "FMG_Id" BIGINT,
                "FMA_Id" BIGINT,
                "FTI_Id" BIGINT,
                "FMH_Id" BIGINT,
                "ASMAY_Id" BIGINT,
                "FSS_ToBePaid" BIGINT,
                "FSS_PaidAmount" DECIMAL(18,0),
                "FSS_ConcessionAmount" DECIMAL(18,0),
                "FSS_NetAmount" DECIMAL(18,0),
                "FSS_FineAmount" DECIMAL(18,0),
                "AMAY_RollNo" BIGINT,
                "FSS_RefundAmount" DECIMAL(18,0),
                "ASMCL_ClassName" VARCHAR(100),
                "ASMC_SectionName" VARCHAR(100),
                "Name" VARCHAR(100),
                "AMST_AdmNo" VARCHAR(100),
                "AMST_Id" BIGINT,
                "ASMCL_Id" BIGINT,
                "ASMS_Id" BIGINT,
                "AMST_FatherName" TEXT
            ) ON COMMIT DROP;

            EXECUTE 'INSERT INTO "AllFees" SELECT * FROM (' || "Dynamic" || ') AS temp';

            FOR rec IN SELECT DISTINCT "AMST_Id", "FMT_Id", "FMA_Id", "ASMAY_Id" FROM "AllFees"
            LOOP
                "AMST_New" := rec."AMST_Id";
                "FMT_New" := rec."FMT_Id"::BIGINT;
                "FMA_New" := rec."FMA_Id";
                "ASMAY_New" := rec."ASMAY_Id";

                PERFORM "dbo"."Sp_Calculate_Fine"("Date", "ASMAY_New", "FMA_New", "amount", "b");

                UPDATE "AllFees" 
                SET "FSS_FineAmount" = "amount"
                WHERE "ASMAY_Id" = "ASMAY_New" 
                    AND "FMA_Id" = "FMA_New" 
                    AND "AMST_Id" = "AMST_New" 
                    AND "FMT_Id"::BIGINT = "FMT_New";
            END LOOP;

            RETURN QUERY SELECT * FROM "AllFees";

        ELSIF "AllInd" = 'Ind' THEN
            "Dynamic" := 'SELECT DISTINCT
                fmh."FMH_FeeName",
                fti."FTI_Name",
                fmtfh."FMT_Id"::VARCHAR(100),
                fss."FMG_Id",
                fss."FMA_Id",
                fss."FTI_Id",
                fss."FMH_Id",
                fss."ASMAY_Id",
                fss."FSS_ToBePaid",
                fss."FSS_PaidAmount",
                fss."FSS_ConcessionAmount",
                fss."FSS_NetAmount",
                fss."FSS_FineAmount",
                asy."AMAY_RollNo",
                fss."FSS_RefundAmount",
                asc."ASMCL_ClassName",
                ass."ASMC_SectionName",
                (COALESCE(ams."AMST_FirstName",'''') || '' '' || COALESCE(ams."AMST_MiddleName",'''') || '' '' || COALESCE(ams."AMST_LastName",'''')) AS "Name",
                ams."AMST_AdmNo",
                ams."AMST_Id",
                asc."ASMCL_Id",
                ass."ASMS_Id",
                ams."AMST_FatherName"
            FROM "dbo"."Adm_M_Student" ams
            INNER JOIN "dbo"."Fee_Student_Status" fss ON ams."AMST_Id" = fss."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" fmtfh ON fss."FMH_Id" = fmtfh."FMH_Id" AND fss."FTI_Id" = fmtfh."FTI_Id"
            INNER JOIN "dbo"."Fee_Master_Head" fmh ON fmh."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" fti ON fti."FTI_Id" = fss."FTI_Id"
            INNER JOIN "dbo"."Fee_Group_Login_Previledge" fglp ON fglp."FMG_ID" = fss."FMG_Id" AND fglp."FMH_Id" = fss."FMH_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" asy ON ams."AMST_Id" = asy."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" asc ON asy."ASMCL_Id" = asc."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ass ON asy."ASMS_Id" = ass."ASMS_Id"
            WHERE fss."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "AMST_Id" = ' || "amst_id" || ' AND fss."ASMAY_Id" = ' || "amay_id" || '
            )
            AND fss."FSS_ActiveFlag" = 1
            AND fss."MI_Id" = ' || "mi_id" || '
            AND fmtfh."FMT_Id" IN (' || "fmt_id" || ')
            AND fmtfh."FMH_Id" IN (' || "fmh_id" || ')
            AND asc."ASMCL_Id" = ' || "asmcl_id" || '
            AND ass."ASMS_Id" = ' || "asms_id" || '
            AND fss."FSS_ToBePaid" > 0
            ORDER BY ams."AMST_Id"
            LIMIT 100';

            CREATE TEMP TABLE "IndFees"(
                "FMH_FeeName" VARCHAR(300),
                "FTI_Name" VARCHAR(200),
                "FMT_Id" VARCHAR(100),
                "FMG_Id" BIGINT,
                "FMA_Id" BIGINT,
                "FTI_Id" BIGINT,
                "FMH_Id" BIGINT,
                "ASMAY_Id" BIGINT,
                "FSS_ToBePaid" BIGINT,
                "FSS_PaidAmount" DECIMAL(18,0),
                "FSS_ConcessionAmount" DECIMAL(18,0),
                "FSS_NetAmount" DECIMAL(18,0),
                "FSS_FineAmount" DECIMAL(18,0),
                "AMAY_RollNo" BIGINT,
                "FSS_RefundAmount" DECIMAL(18,0),
                "ASMCL_ClassName" VARCHAR(100),
                "ASMC_SectionName" VARCHAR(100),
                "Name" VARCHAR(100),
                "AMST_AdmNo" VARCHAR(100),
                "AMST_Id" BIGINT,
                "ASMCL_Id" BIGINT,
                "ASMS_Id" BIGINT,
                "AMST_FatherName" TEXT
            ) ON COMMIT DROP;

            EXECUTE 'INSERT INTO "IndFees" SELECT * FROM (' || "Dynamic" || ') AS temp';

            FOR rec IN SELECT DISTINCT "AMST_Id", "FMA_Id" FROM "IndFees"
            LOOP
                "FMA_New" := rec."FMA_Id";
                "AMST_New" := rec."AMST_Id";

                PERFORM "dbo"."Sp_Calculate_Fine"("Date", "amay_id", "FMA_New", "amount", "b");

                UPDATE "IndFees" 
                SET "FSS_FineAmount" = "amount"
                WHERE "ASMAY_Id" = "amay_id" 
                    AND "FMA_Id" = "FMA_New" 
                    AND "AMST_Id" = "AMST_New" 
                    AND "FMT_Id" = "fmt_id";
            END LOOP;

            CREATE TEMP TABLE "IndFessNew" ON COMMIT DROP AS SELECT * FROM "IndFees";

            RETURN QUERY
            SELECT 
                B."FMH_FeeName",
                STRING_AGG(A."FTI_Name", ', ' ORDER BY A."FTI_Name") AS "FTI_Name",
                NULL::VARCHAR(100) AS "FMT_Id",
                B."FMG_Id",
                NULL::BIGINT AS "FMA_Id",
                NULL::BIGINT AS "FTI_Id",
                B."FMH_Id",
                B."ASMAY_Id",
                SUM(B."FSS_ToBePaid")::BIGINT AS "FSS_ToBePaid",
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
            LEFT JOIN "IndFessNew" A ON 
                A."AMST_Id" = B."AMST_Id" 
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