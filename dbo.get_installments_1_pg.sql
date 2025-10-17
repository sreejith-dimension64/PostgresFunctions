CREATE OR REPLACE FUNCTION "dbo"."get_installments_1" (
    "MI_Id" VARCHAR(10),
    "ASMAY_Id" VARCHAR(10),
    "FMCC_Id" VARCHAR(10),
    "FTI_Id" TEXT,
    "asmcL_Id" VARCHAR(10),
    "amsC_Id" VARCHAR(10),
    "type" TEXT,
    "fmg_id" TEXT,
    "trmr_Id" TEXT,
    "user_id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    IF "type" = 'Category' THEN
        v_query := 'SELECT DISTINCT a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') as "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo" 
        FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i
        WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" 
        AND a."MI_Id" = ' || quote_literal("MI_Id") || ' AND b."MI_Id" = ' || quote_literal("MI_Id") || ' AND d."MI_Id" = ' || quote_literal("MI_Id") || ' 
        AND a."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND c."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND d."FMCC_Id" = ' || quote_literal("FMCC_Id") || ' 
        AND h."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 
        AND e."MI_Id" = ' || quote_literal("MI_Id") || ' AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 
        AND f."MI_Id" = ' || quote_literal("MI_Id") || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 
        AND a."FTI_Id" IN (' || "FTI_Id" || ') AND g."MI_ID" = ' || quote_literal("MI_Id") || ' AND a."FTI_Id" = g."FTI_Id" 
        AND a."User_Id" = ' || quote_literal("user_id") || '
        GROUP BY a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
        ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
    ELSIF "type" = 'Class' THEN
        v_query := 'SELECT DISTINCT a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') as "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo" 
        FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i
        WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" 
        AND a."MI_Id" = ' || quote_literal("MI_Id") || ' AND b."MI_Id" = ' || quote_literal("MI_Id") || ' AND d."MI_Id" = ' || quote_literal("MI_Id") || ' 
        AND a."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND c."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' 
        AND h."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 
        AND e."MI_Id" = ' || quote_literal("MI_Id") || ' AND c."ASMCL_Id" = ' || quote_literal("asmcL_Id") || ' AND f."ASMS_Id" = ' || quote_literal("amsC_Id") || ' 
        AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 
        AND f."MI_Id" = ' || quote_literal("MI_Id") || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 
        AND a."FTI_Id" IN (SELECT DISTINCT "Fee_T_Installment"."FTI_Id" FROM "Fee_T_Installment" 
            INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id" 
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
            WHERE "Fee_Student_Status"."MI_Id" = ' || quote_literal("MI_Id") || ' 
            AND "Adm_School_Y_Student"."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND "FSS_TotalToBePaid" > 0) 
        AND g."MI_ID" = ' || quote_literal("MI_Id") || ' AND a."FTI_Id" = g."FTI_Id"
        GROUP BY a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
        ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
    ELSE
        IF "fmg_id" = '0' THEN
            v_query := 'SELECT DISTINCT a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') as "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo" 
            FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i, "trn"."TR_Student_Route" t
            WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" 
            AND a."MI_Id" = ' || quote_literal("MI_Id") || ' AND b."MI_Id" = ' || quote_literal("MI_Id") || ' AND d."MI_Id" = ' || quote_literal("MI_Id") || ' 
            AND a."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND c."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' 
            AND h."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 
            AND e."MI_Id" = ' || quote_literal("MI_Id") || ' AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 
            AND f."MI_Id" = ' || quote_literal("MI_Id") || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 
            AND a."FTI_Id" IN (SELECT DISTINCT "Fee_T_Installment"."FTI_Id" FROM "Fee_T_Installment" 
                INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id" 
                INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
                WHERE "Fee_Student_Status"."MI_Id" = ' || quote_literal("MI_Id") || ' 
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND "FSS_TotalToBePaid" > 0) 
            AND g."MI_ID" = ' || quote_literal("MI_Id") || ' AND a."FTI_Id" = g."FTI_Id" 
            AND a."AMST_Id" = t."AMST_Id" AND a."FMG_Id" = t."FMG_Id" 
            AND t."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND t."MI_Id" = ' || quote_literal("MI_Id") || ' 
            AND ("TRMR_Id" = ' || quote_literal("trmr_Id") || ' OR "TRMR_Drop_Route" = ' || quote_literal("trmr_Id") || ') 
            AND a."User_Id" = ' || quote_literal("user_id") || '
            GROUP BY a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
            ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
        ELSE
            v_query := 'SELECT DISTINCT a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') as "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo" 
            FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i, "trn"."TR_Student_Route" t
            WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" 
            AND a."MI_Id" = ' || quote_literal("MI_Id") || ' AND b."MI_Id" = ' || quote_literal("MI_Id") || ' AND d."MI_Id" = ' || quote_literal("MI_Id") || ' 
            AND a."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND c."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' 
            AND h."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 
            AND e."MI_Id" = ' || quote_literal("MI_Id") || ' AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 
            AND f."MI_Id" = ' || quote_literal("MI_Id") || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 
            AND a."FTI_Id" IN (SELECT DISTINCT "Fee_T_Installment"."FTI_Id" FROM "Fee_T_Installment" 
                INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id" 
                INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
                WHERE "Fee_Student_Status"."MI_Id" = ' || quote_literal("MI_Id") || ' 
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND "FSS_TotalToBePaid" > 0) 
            AND g."MI_ID" = ' || quote_literal("MI_Id") || ' AND a."FTI_Id" = g."FTI_Id" 
            AND a."AMST_Id" = t."AMST_Id" AND a."FMG_Id" = t."FMG_Id" 
            AND t."FMG_Id" = ' || quote_literal("fmg_id") || ' 
            AND t."ASMAY_Id" = ' || quote_literal("ASMAY_Id") || ' AND t."MI_Id" = ' || quote_literal("MI_Id") || ' 
            AND ("TRMR_Id" = ' || quote_literal("trmr_Id") || ' OR "TRMR_Drop_Route" = ' || quote_literal("trmr_Id") || ') 
            AND a."User_Id" = ' || quote_literal("user_id") || '
            GROUP BY a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
            ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
        END IF;
    END IF;

    RETURN QUERY EXECUTE v_query;
END;
$$;