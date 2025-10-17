CREATE OR REPLACE FUNCTION "dbo"."Fee_termwise_statistics"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "FMG_Id" TEXT,
    "FMT_Id" TEXT,
    "FMCC_Id" TEXT,
    "User_Id" TEXT,
    "active" TEXT,
    "deactive" TEXT,
    "left" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "admno" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "FMT_Name" TEXT,
    "PayableAmount" NUMERIC,
    "PaidAmount" NUMERIC,
    "Balance" NUMERIC,
    "ConcessionAmount" NUMERIC,
    "AdjustedAmount" NUMERIC,
    "WaivedAmount" NUMERIC,
    "RefundAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlquery TEXT;
    v_script TEXT;
    v_script3 TEXT;
    v_script2 TEXT;
    v_count_temp BIGINT;
    v_amst_sol TEXT;
BEGIN

    v_amst_sol := '';

    IF "active" = '1' AND "deactive" = '0' AND "left" = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "deactive" = '1' AND "active" = '0' AND "left" = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0) and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=0)';
    END IF;

    IF ("ASMCL_Id" <> '0' AND "ASMS_Id" <> '0' AND (COALESCE("FMCC_Id", '') = '' OR "FMCC_Id" = '0')) THEN

        v_sqlquery := 'WITH cte AS (
            SELECT DISTINCT "Fee_Student_Status"."AMST_Id",
                "Adm_M_Student"."AMST_Admno" AS admno,
                (COALESCE("AMST_FirstName", '' '') || '''' || COALESCE("AMST_MiddleName", '' '') || '''' || COALESCE("AMST_LastName", '' '')) AS "StudentName",
                "Fee_Master_Terms"."FMT_Name",
                ("FSS_OBArrearAmount" + "FSS_CurrentYrCharges") AS "PayableAmount",
                "FSS_PaidAmount" AS "PaidAmount",
                "FSS_ToBePaid" AS "Balance",
                "FSS_ConcessionAmount",
                "FSS_AdjustedAmount",
                "FSS_WaivedAmount",
                "FSS_RefundAmount",
                "ASMCL_ClassName",
                "ASMC_SectionName"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id" || '
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Master_Terms"."MI_Id" = ' || "MI_Id" || '
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "Fee_Student_Status"."MI_Id" = ' || "MI_Id" || ' 
                AND "Adm_School_M_Class"."ASMCL_Id" IN (' || "ASMCL_Id" || ') 
                AND "Adm_School_M_Section"."ASMS_Id" IN (' || "ASMS_Id" || ')
                AND "Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
                AND "Fee_Master_Group"."FMG_Id" IN (' || "FMG_Id" || ') 
                AND "Fee_Master_Terms"."FMT_Id" IN (' || "FMT_Id" || ') ' || v_amst_sol || '
        )
        SELECT DISTINCT "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name",
            SUM("PayableAmount") AS "PayableAmount",
            SUM("PaidAmount") AS "PaidAmount",
            SUM("Balance") AS "Balance",
            SUM("FSS_ConcessionAmount") AS "ConcessionAmount",
            SUM("FSS_AdjustedAmount") AS "AdjustedAmount",
            SUM("FSS_WaivedAmount") AS "WaivedAmount",
            SUM("FSS_RefundAmount") AS "RefundAmount"
        FROM (
            SELECT "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName",
                STRING_AGG(DISTINCT "FMT_Name", ''],['' ORDER BY "FMT_Name") AS "FMT_Name",
                "PayableAmount", "PaidAmount", "Balance", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RefundAmount"
            FROM cte
            GROUP BY "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName", "PayableAmount", "PaidAmount", "Balance", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RefundAmount"
        ) AS "New"
        GROUP BY admno, "StudentName", "ASMCL_ClassName", "ASMC_SectionName", "AMST_Id", "FMT_Name"
        ORDER BY "ASMCL_ClassName", "ASMC_SectionName"';

    ELSIF ("ASMCL_Id" <> '0' AND (COALESCE("ASMS_Id", '') = '' OR "ASMS_Id" = '0') AND (COALESCE("FMCC_Id", '') = '' OR "FMCC_Id" = '0')) THEN

        v_sqlquery := 'WITH cte AS (
            SELECT DISTINCT "Fee_Student_Status"."AMST_Id",
                "Adm_M_Student"."AMST_Admno" AS admno,
                (COALESCE("AMST_FirstName", '' '') || '' '' || COALESCE("AMST_MiddleName", '' '') || '' '' || COALESCE("AMST_LastName", '' '')) AS "StudentName",
                "Fee_Master_Terms"."FMT_Name",
                ("FSS_OBArrearAmount" + "FSS_CurrentYrCharges") AS "PayableAmount",
                "FSS_PaidAmount" AS "PaidAmount",
                "FSS_ToBePaid" AS "Balance",
                "FSS_ConcessionAmount",
                "FSS_AdjustedAmount",
                "FSS_WaivedAmount",
                "FSS_RefundAmount",
                "ASMCL_ClassName",
                "ASMC_SectionName"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id" || '
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Master_Terms"."MI_Id" = ' || "MI_Id" || '
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "Fee_Student_Status"."MI_Id" = ' || "MI_Id" || ' 
                AND "Adm_School_M_Class"."ASMCL_Id" IN (' || "ASMCL_Id" || ') 
                AND "Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
                AND "Fee_Master_Group"."FMG_Id" IN (' || "FMG_Id" || ') 
                AND "Fee_Master_Terms"."FMT_Id" IN (' || "FMT_Id" || ') ' || v_amst_sol || '
        )
        SELECT DISTINCT "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name",
            SUM("PayableAmount") AS "PayableAmount",
            SUM("PaidAmount") AS "PaidAmount",
            SUM("Balance") AS "Balance",
            SUM("FSS_ConcessionAmount") AS "ConcessionAmount",
            SUM("FSS_AdjustedAmount") AS "AdjustedAmount",
            SUM("FSS_WaivedAmount") AS "WaivedAmount",
            SUM("FSS_RefundAmount") AS "RefundAmount"
        FROM (
            SELECT "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName",
                STRING_AGG(DISTINCT "FMT_Name", ''],['' ORDER BY "FMT_Name") AS "FMT_Name",
                "PayableAmount", "PaidAmount", "Balance", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RefundAmount"
            FROM cte
            GROUP BY "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName", "PayableAmount", "PaidAmount", "Balance", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RefundAmount"
        ) AS "New"
        GROUP BY admno, "StudentName", "ASMCL_ClassName", "ASMC_SectionName", "AMST_Id", "FMT_Name"
        ORDER BY "ASMCL_ClassName", "ASMC_SectionName"';

    ELSE

        IF (("ASMCL_Id" = '0' AND "ASMS_Id" = '0') OR (COALESCE("ASMCL_Id", '') = '' AND COALESCE("ASMS_Id", '') = '') AND ("FMCC_Id" = '0' AND "FMT_Id" <> '0' AND "FMG_Id" <> '0' AND "User_Id" <> '0')) THEN

            v_sqlquery := 'WITH cte AS (
                SELECT DISTINCT "Fee_Student_Status"."AMST_Id",
                    "Adm_M_Student"."AMST_Admno" AS admno,
                    (COALESCE("AMST_FirstName", '' '') || '''' || COALESCE("AMST_MiddleName", '' '') || '''' || COALESCE("AMST_LastName", '' '')) AS "StudentName",
                    "Fee_Master_Terms"."FMT_Name",
                    ("FSS_OBArrearAmount" + "FSS_CurrentYrCharges") AS "PayableAmount",
                    "FSS_PaidAmount" AS "PaidAmount",
                    "FSS_ToBePaid" AS "Balance",
                    "FSS_ConcessionAmount",
                    "FSS_AdjustedAmount",
                    "FSS_WaivedAmount",
                    "FSS_RefundAmount",
                    "ASMCL_ClassName",
                    "ASMC_SectionName"
                FROM "Fee_Master_Group"
                INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = ' || "MI_Id" || '
                INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = ' || "MI_Id" || '
                INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = ' || "MI_Id" || '
                INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id" || '
                INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id" = ' || "MI_Id" || '
                INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id" = ' || "MI_Id" || '
                INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "MI_Id" || '
                INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Master_Terms"."MI_Id" = ' || "MI_Id" || '
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "Fee_Student_Status"."MI_Id" = ' || "MI_Id" || '
                    AND "Adm_School_M_Class"."ASMCL_Id" IN (
                        SELECT DISTINCT "ASMCL_Id" 
                        FROM "Fee_Yearly_Class_Category" YCC 
                        INNER JOIN "Fee_Yearly_Class_Category_Classes" YCCC ON YCC."FYCC_Id" = YCCC."FYCC_Id" 
                        INNER JOIN "Fee_Master_Class_Category" FMCC ON FMCC."FMCC_Id" = YCC."FMCC_Id" AND FMCC."MI_Id" = ' || "MI_Id" || '
                        WHERE YCC."MI_Id" = ' || "MI_Id" || ' AND YCC."ASMAY_Id" = ' || "ASMAY_Id" || '
                    )
                    AND "Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
                    AND "Fee_Master_Group"."FMG_Id" IN (' || "FMG_Id" || ') 
                    AND "Fee_Master_Terms"."FMT_Id" IN (' || "FMT_Id" || ') ' || v_amst_sol || '
            )
            SELECT DISTINCT "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name",
                SUM("PayableAmount") AS "PayableAmount",
                SUM("PaidAmount") AS "PaidAmount",
                SUM("Balance") AS "Balance",
                SUM("FSS_ConcessionAmount") AS "ConcessionAmount",
                SUM("FSS_AdjustedAmount") AS "AdjustedAmount",
                SUM("FSS_WaivedAmount") AS "WaivedAmount",
                SUM("FSS_RefundAmount") AS "RefundAmount"
            FROM (
                SELECT "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName",
                    STRING_AGG(DISTINCT "FMT_Name", ''],['' ORDER BY "FMT_Name") AS "FMT_Name",
                    "PayableAmount", "PaidAmount", "Balance", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RefundAmount"
                FROM cte
                GROUP BY "AMST_Id", "StudentName", admno, "ASMCL_ClassName", "ASMC_SectionName", "PayableAmount", "PaidAmount", "Balance", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RefundAmount"
            ) AS "New"
            GROUP BY admno, "StudentName", "ASMCL_ClassName", "ASMC_SectionName", "AMST_Id", "FMT_Name"
            ORDER BY "ASMCL_ClassName", "ASMC_SectionName"';

        END IF;

    END IF;

    RETURN QUERY EXECUTE v_sqlquery;

END;
$$;