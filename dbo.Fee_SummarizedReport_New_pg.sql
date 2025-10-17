CREATE OR REPLACE FUNCTION "dbo"."Fee_SummarizedReport_New" (
    p_amay_id bigint,
    p_asmcl_id bigint,
    p_asms_id bigint,
    p_amst_id bigint,
    p_mi_id bigint,
    p_fmt_id text,
    p_fmgg_id text,
    p_type varchar(20),
    p_AllInd varchar(20)
)
RETURNS TABLE (
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
    "ASMS_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount float;
    v_b int;
    v_fma_id bigint;
    v_Date date;
    v_Dynamic text;
    v_FMA_New bigint;
    v_AMST_New bigint;
    v_FMT_New bigint;
    v_ASMAY_New bigint;
    rec RECORD;
BEGIN

    v_Date := CURRENT_DATE;

    IF p_type = 'Annual' THEN
        
        IF p_AllInd = 'All' THEN
            
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
                (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || COALESCE("Adm_M_Student"."AMST_MiddleName", '') || ' ' || COALESCE("Adm_M_Student"."AMST_LastName", '')) AS "Name",
                "Adm_M_Student"."AMST_AdmNo",
                "Adm_M_Student"."AMST_Id",
                "Adm_School_M_Class"."ASMCL_Id",
                "Adm_School_M_Section"."ASMS_Id"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Fee_Student_Status" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id" 
                AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            WHERE "Fee_Student_Status"."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "Fee_Student_Status"."ASMAY_Id" = p_amay_id
            )
            AND "Fee_Student_Status"."FSS_ActiveFlag" = 1
            AND "Fee_Master_Head"."FMH_Flag" = 'N'
            AND "Fee_Student_Status"."MI_Id" = p_mi_id
            AND "Adm_School_M_Class"."ASMCL_Id" = p_asmcl_id
            AND "Adm_School_M_Section"."ASMS_Id" = p_asms_id
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0
            ORDER BY "Adm_M_Student"."AMST_Id"
            LIMIT 100;
            
        ELSIF p_AllInd = 'Ind' THEN
            
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
                (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || COALESCE("Adm_M_Student"."AMST_MiddleName", '') || ' ' || COALESCE("Adm_M_Student"."AMST_LastName", '')) AS "Name",
                "Adm_M_Student"."AMST_AdmNo",
                "Adm_M_Student"."AMST_Id",
                "Adm_School_M_Class"."ASMCL_Id",
                "Adm_School_M_Section"."ASMS_Id"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Fee_Student_Status" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id" 
                AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            WHERE "Fee_Student_Status"."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "dbo"."Adm_School_Y_Student"
                WHERE "AMST_Id" = p_amst_id AND "Fee_Student_Status"."ASMAY_Id" = p_amay_id
            )
            AND "Fee_Student_Status"."FSS_ActiveFlag" = 1
            AND "Fee_Master_Head"."FMH_Flag" = 'N'
            AND "Fee_Student_Status"."MI_Id" = p_mi_id
            AND "Adm_School_M_Class"."ASMCL_Id" = p_asmcl_id
            AND "Adm_School_M_Section"."ASMS_Id" = p_asms_id
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0
            ORDER BY "Adm_M_Student"."AMST_Id"
            LIMIT 100;
            
        END IF;
        
    END IF;

    IF p_type = 'Others' THEN
        
        IF p_AllInd = 'All' THEN
            
            CREATE TEMP TABLE "temp_AllFees" (
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
                "ASMS_Id" bigint
            ) ON COMMIT DROP;

            v_Dynamic := 'INSERT INTO "temp_AllFees" ' ||
                'SELECT DISTINCT ' ||
                '"Fee_Master_Head"."FMH_FeeName", ' ||
                '"Fee_T_Installment"."FTI_Name", ' ||
                '"Fee_Master_Terms_FeeHeads"."FMT_Id"::varchar(100), ' ||
                '"Fee_Student_Status"."FMG_Id", ' ||
                '"Fee_Student_Status"."FMA_Id", ' ||
                '"Fee_Student_Status"."FTI_Id", ' ||
                '"Fee_Student_Status"."FMH_Id", ' ||
                '"Fee_Student_Status"."ASMAY_Id", ' ||
                '"Fee_Student_Status"."FSS_ToBePaid", ' ||
                '"Fee_Student_Status"."FSS_PaidAmount", ' ||
                '"Fee_Student_Status"."FSS_ConcessionAmount", ' ||
                '"Fee_Student_Status"."FSS_NetAmount", ' ||
                '"Fee_Student_Status"."FSS_FineAmount", ' ||
                '"Adm_School_Y_Student"."AMAY_RollNo", ' ||
                '"Fee_Student_Status"."FSS_RefundAmount", ' ||
                '"Adm_School_M_Class"."ASMCL_ClassName", ' ||
                '"Adm_School_M_Section"."ASMC_SectionName", ' ||
                '(COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')), ' ||
                '"Adm_M_Student"."AMST_AdmNo", ' ||
                '"Adm_M_Student"."AMST_Id", ' ||
                '"Adm_School_M_Class"."ASMCL_Id", ' ||
                '"Adm_School_M_Section"."ASMS_Id" ' ||
                'FROM "dbo"."Adm_M_Student" ' ||
                'INNER JOIN "dbo"."Fee_Student_Status" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" ' ||
                'INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" ' ||
                '    AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" ' ||
                'INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id" ' ||
                'INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id" ' ||
                'INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id" ' ||
                '    AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id" ' ||
                'INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" ' ||
                'INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" ' ||
                'INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ' ||
                'WHERE "Fee_Student_Status"."AMST_Id" IN ( ' ||
                '    SELECT DISTINCT "AMST_Id" ' ||
                '    FROM "dbo"."Adm_School_Y_Student" ' ||
                '    WHERE "Fee_Student_Status"."ASMAY_Id" = ' || p_amay_id || ' ' ||
                ') ' ||
                'AND "Fee_Student_Status"."FSS_ActiveFlag" = 1 ' ||
                'AND "Fee_Student_Status"."MI_Id" = ' || p_mi_id || ' ' ||
                'AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_id || ') ' ||
                'AND "Adm_School_M_Class"."ASMCL_Id" = ' || p_asmcl_id || ' ' ||
                'AND "Adm_School_M_Section"."ASMS_Id" = ' || p_asms_id || ' ' ||
                'AND "Fee_Student_Status"."FSS_ToBePaid" > 0 ' ||
                'ORDER BY "AMST_Id" ' ||
                'LIMIT 100';

            EXECUTE v_Dynamic;

            FOR rec IN 
                SELECT DISTINCT "AMST_Id", "FMT_Id"::bigint, "FMA_Id", "ASMAY_Id" 
                FROM "temp_AllFees"
            LOOP
                v_AMST_New := rec."AMST_Id";
                v_FMT_New := rec."FMT_Id";
                v_FMA_New := rec."FMA_Id";
                v_ASMAY_New := rec."ASMAY_Id";

                SELECT * INTO v_amount, v_b 
                FROM "dbo"."Sp_Calculate_Fine"(v_Date, v_ASMAY_New, v_FMA_New);

                UPDATE "temp_AllFees" 
                SET "FSS_FineAmount" = v_amount
                WHERE "ASMAY_Id" = v_ASMAY_New 
                    AND "FMA_Id" = v_FMA_New 
                    AND "AMST_Id" = v_AMST_New 
                    AND "FMT_Id"::bigint = v_FMT_New;
            END LOOP;

            RETURN QUERY SELECT * FROM "temp_AllFees";

        ELSIF p_AllInd = 'Ind' THEN

            CREATE TEMP TABLE "temp_IndFees" (
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
                "ASMS_Id" bigint
            ) ON COMMIT DROP;

            v_Dynamic := 'INSERT INTO "temp_IndFees" ' ||
                'SELECT DISTINCT ' ||
                '"Fee_Master_Head"."FMH_FeeName", ' ||
                '"Fee_T_Installment"."FTI_Name", ' ||
                '"Fee_Master_Terms_FeeHeads"."FMT_Id"::varchar(100), ' ||
                '"Fee_Student_Status"."FMG_Id", ' ||
                '"Fee_Student_Status"."FMA_Id", ' ||
                '"Fee_Student_Status"."FTI_Id", ' ||
                '"Fee_Student_Status"."FMH_Id", ' ||
                '"Fee_Student_Status"."ASMAY_Id", ' ||
                '"Fee_Student_Status"."FSS_ToBePaid", ' ||
                '"Fee_Student_Status"."FSS_PaidAmount", ' ||
                '"Fee_Student_Status"."FSS_ConcessionAmount", ' ||
                '"Fee_Student_Status"."FSS_NetAmount", ' ||
                '"Fee_Student_Status"."FSS_FineAmount", ' ||
                '"Adm_School_Y_Student"."AMAY_RollNo", ' ||
                '"Fee_Student_Status"."FSS_RefundAmount", ' ||
                '"Adm_School_M_Class"."ASMCL_ClassName", ' ||
                '"Adm_School_M_Section"."ASMC_SectionName", ' ||
                '(COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')), ' ||
                '"Adm_M_Student"."AMST_AdmNo", ' ||
                '"Adm_M_Student"."AMST_Id", ' ||
                '"Adm_School_M_Class"."ASMCL_Id", ' ||
                '"Adm_School_M_Section"."ASMS_Id" ' ||
                'FROM "dbo"."Adm_M_Student" ' ||
                'INNER JOIN "dbo"."Fee_Student_Status" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" ' ||
                'INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" ' ||
                '    AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" ' ||
                'INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id" ' ||
                'INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id" ' ||
                'INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Student_Status"."FMG_Id" ' ||
                '    AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Student_Status"."FMH_Id" ' ||
                'INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" ' ||
                'INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" ' ||
                'INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ' ||
                'WHERE "Fee_Student_Status"."AMST_Id" IN ( ' ||
                '    SELECT DISTINCT "AMST_Id" ' ||
                '    FROM "dbo"."Adm_School_Y_Student" ' ||
                '    WHERE "AMST_Id" = ' || p_amst_id || ' AND "Fee_Student_Status"."ASMAY_Id" = ' || p_amay_id || ' ' ||
                ') ' ||
                'AND "Fee_Student_Status"."FSS_ActiveFlag" = 1 ' ||
                'AND "Fee_Student_Status"."MI_Id" = ' || p_mi_id || ' ' ||
                'AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_id || ') ' ||
                'AND "Adm_School_M_Class"."ASMCL_Id" = ' || p_asmcl_id || ' ' ||
                'AND "Adm_School_M_Section"."ASMS_Id" = ' || p_asms_id || ' ' ||
                'AND "Fee_Student_Status"."FSS_ToBePaid" > 0 ' ||
                'ORDER BY "AMST_Id" ' ||
                'LIMIT 100';

            EXECUTE v_Dynamic;

            FOR rec IN 
                SELECT DISTINCT "AMST_Id", "FMA_Id" 
                FROM "temp_IndFees"
            LOOP
                v_AMST_New := rec."AMST_Id";
                v_FMA_New := rec."FMA_Id";

                SELECT * INTO v_amount, v_b 
                FROM "dbo"."Sp_Calculate_Fine"(v_Date, p_amay_id, v_FMA_New);

                UPDATE "temp_IndFees" 
                SET "FSS_FineAmount" = v_amount
                WHERE "ASMAY_Id" = p_amay_id 
                    AND "FMA_Id" = v_FMA_New 
                    AND "AMST_Id" = v_AMST_New 
                    AND "FMT_Id" = p_fmt_id;
            END LOOP;

            CREATE TEMP TABLE "temp_IndFeesNew" ON COMMIT DROP AS
            SELECT * FROM "temp_IndFees";

            RETURN QUERY
            SELECT 
                "FMH_FeeName",
                string_agg("FTI_Name", ', ' ORDER BY "FTI_Name") AS "FTI_Name",
                NULL::varchar(100) AS "FMT_Id",
                "FMG_Id",
                NULL::bigint AS "FMA_Id",
                NULL::bigint AS "FTI_Id",
                "FMH_Id",
                "ASMAY_Id",
                SUM("FSS_ToBePaid") AS "FSS_ToBePaid",
                SUM("FSS_PaidAmount") AS "FSS_PaidAmount",
                SUM("FSS_ConcessionAmount") AS "FSS_ConcessionAmount",
                SUM("FSS_NetAmount") AS "FSS_NetAmount",
                SUM("FSS_FineAmount") AS "FSS_FineAmount",
                "AMAY_RollNo",
                SUM("FSS_RefundAmount") AS "FSS_RefundAmount",
                "ASMCL_ClassName",
                "ASMC_SectionName",
                "Name",
                "AMST_AdmNo",
                "AMST_Id",
                "ASMCL_Id",
                "ASMS_Id"
            FROM "temp_IndFeesNew"
            GROUP BY 
                "FMH_FeeName", "FMG_Id", "FMH_Id", "ASMAY_Id", "AMAY_RollNo", 
                "ASMCL_ClassName", "ASMC_SectionName", "Name", "AMST_AdmNo", 
                "ASMCL_Id", "ASMS_Id", "AMST_Id";

        END IF;

    END IF;

    RETURN;

END;
$$;