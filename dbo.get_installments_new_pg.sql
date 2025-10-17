CREATE OR REPLACE FUNCTION "dbo"."get_installments_new" (
    "p_MI_Id" VARCHAR(10),
    "p_ASMAY_Id" VARCHAR(10),
    "p_FMCC_Id" VARCHAR(10),
    "p_FTI_Id" TEXT,
    "p_asmcL_Id" VARCHAR(10),
    "p_amsC_Id" VARCHAR(10),
    "p_type" TEXT,
    "p_fmg_id" TEXT,
    "p_trmr_Id" TEXT,
    "p_user_id" TEXT,
    "p_fmh_ids" TEXT
)
RETURNS TABLE (
    "AMST_AdmNo" VARCHAR,
    "AMST_Id" BIGINT,
    "AMST_FirstName" TEXT,
    "ASMCL_Id" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMS_Id" BIGINT,
    "ASMC_SectionName" VARCHAR,
    "FTI_Id" BIGINT,
    "FTI_Name" VARCHAR,
    "Balance" NUMERIC,
    "Paid" NUMERIC,
    "Concession" NUMERIC,
    "Waivedoff" NUMERIC,
    "Fine" NUMERIC,
    "Netamount" NUMERIC,
    "AMAY_RollNo" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_query" TEXT;
BEGIN
    IF "p_type" = 'Category' THEN
        "v_query" := 'SELECT DISTINCT b."AMST_AdmNo", a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') AS "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo" 
        FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i
        WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" AND a."MI_Id" = ' || "p_MI_Id" || ' AND b."MI_Id" = ' || "p_MI_Id" || ' AND d."MI_Id" = ' || "p_MI_Id" || ' AND a."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND c."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND d."FMCC_Id" = ' || "p_FMCC_Id" || ' AND h."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 AND e."MI_Id" = ' || "p_MI_Id" || ' AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 AND f."MI_Id" = ' || "p_MI_Id" || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 AND a."FTI_Id" IN (' || "p_FTI_Id" || ') AND g."MI_ID" = ' || "p_MI_Id" || ' AND a."FTI_Id" = g."FTI_Id" AND a."User_Id" = ' || "p_user_id" || '
        GROUP BY b."AMST_AdmNo", a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
        ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
        
    ELSIF "p_type" = 'Class' THEN
        "v_query" := 'SELECT DISTINCT b."AMST_AdmNo", a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') AS "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo"
        FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i
        WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" AND a."MI_Id" = ' || "p_MI_Id" || ' AND b."MI_Id" = ' || "p_MI_Id" || ' AND d."MI_Id" = ' || "p_MI_Id" || ' AND a."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND c."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND h."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 AND e."MI_Id" = ' || "p_MI_Id" || ' AND c."ASMCL_Id" = ' || "p_asmcL_Id" || ' AND f."ASMS_Id" = ' || "p_amsC_Id" || ' AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 AND f."MI_Id" = ' || "p_MI_Id" || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 AND a."FTI_Id" IN (SELECT DISTINCT "Fee_T_Installment"."FTI_Id" FROM "Fee_T_Installment" INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" WHERE "Fee_Student_Status"."MI_Id" = ' || "p_MI_Id" || ' AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "FSS_TotalToBePaid" > 0) AND g."MI_ID" = ' || "p_MI_Id" || ' AND a."FTI_Id" = g."FTI_Id"
        GROUP BY b."AMST_AdmNo", a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
        ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
        
    ELSE
        IF "p_fmg_id" = '0' THEN
            "v_query" := 'SELECT DISTINCT b."AMST_AdmNo", a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') AS "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo"
            FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i, "trn"."TR_Student_Route" t
            WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" AND a."MI_Id" = ' || "p_MI_Id" || ' AND b."MI_Id" = ' || "p_MI_Id" || ' AND d."MI_Id" = ' || "p_MI_Id" || ' AND a."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND c."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND h."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 AND e."MI_Id" = ' || "p_MI_Id" || ' AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 AND f."MI_Id" = ' || "p_MI_Id" || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 AND a."FTI_Id" IN (SELECT DISTINCT "Fee_T_Installment"."FTI_Id" FROM "Fee_T_Installment" INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" WHERE "Fee_Student_Status"."MI_Id" = ' || "p_MI_Id" || ' AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "FSS_TotalToBePaid" > 0) AND g."MI_ID" = ' || "p_MI_Id" || ' AND a."FTI_Id" = g."FTI_Id" AND a."AMST_Id" = t."AMST_Id" AND t."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND t."MI_Id" = ' || "p_MI_Id" || ' AND ("TRMR_Id" = ' || "p_trmr_Id" || ' OR "TRMR_Drop_Route" = ' || "p_trmr_Id" || ') AND a."User_Id" = ' || "p_user_id" || ' AND a."FMH_id" IN (' || "p_fmh_ids" || ')
            GROUP BY b."AMST_AdmNo", a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
            ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
        ELSE
            "v_query" := 'SELECT DISTINCT b."AMST_AdmNo", a."AMST_Id", COALESCE(b."AMST_FirstName", '''') || '' '' || COALESCE(b."AMST_MiddleName", '''') || '' '' || COALESCE(b."AMST_LastName", '''') AS "AMST_FirstName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", SUM("FSS_ToBePaid") AS "Balance", SUM("FSS_PaidAmount") AS "Paid", SUM("FSS_ConcessionAmount") AS "Concession", SUM("FSS_WaivedAmount") AS "Waivedoff", SUM("FSS_FineAmount") AS "Fine", SUM("FSS_NetAmount") AS "Netamount", "AMAY_RollNo"
            FROM "Fee_Student_Status" a, "Adm_M_Student" b, "Adm_School_Y_Student" c, "Fee_Master_Class_Category" d, "Adm_School_M_Class" e, "Adm_School_M_Section" f, "Fee_T_Installment" g, "Fee_Yearly_Class_Category" h, "Fee_Master_Amount" i, "trn"."TR_Student_Route" t
            WHERE a."AMST_Id" = b."AMST_Id" AND b."AMST_Id" = c."AMST_Id" AND d."FMCC_Id" = h."FMCC_Id" AND h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id" AND a."MI_Id" = ' || "p_MI_Id" || ' AND b."MI_Id" = ' || "p_MI_Id" || ' AND d."MI_Id" = ' || "p_MI_Id" || ' AND a."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND c."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND h."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 AND e."MI_Id" = ' || "p_MI_Id" || ' AND e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_ActiveFlag" = 1 AND f."MI_Id" = ' || "p_MI_Id" || ' AND f."ASMS_Id" = c."ASMS_Id" AND f."ASMC_ActiveFlag" = 1 AND a."FTI_Id" IN (SELECT DISTINCT "Fee_T_Installment"."FTI_Id" FROM "Fee_T_Installment" INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" WHERE "Fee_Student_Status"."MI_Id" = ' || "p_MI_Id" || ' AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "FSS_TotalToBePaid" > 0) AND g."MI_ID" = ' || "p_MI_Id" || ' AND a."FTI_Id" = g."FTI_Id" AND a."AMST_Id" = t."AMST_Id" AND a."FMG_Id" = ' || "p_fmg_id" || ' AND t."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND t."MI_Id" = ' || "p_MI_Id" || ' AND ("TRMR_Id" = ' || "p_trmr_Id" || ' OR "TRMR_Drop_Route" = ' || "p_trmr_Id" || ') AND a."User_Id" = ' || "p_user_id" || ' AND a."FMH_id" IN (' || "p_fmh_ids" || ')
            GROUP BY b."AMST_AdmNo", a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName", c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name", "AMAY_RollNo" 
            ORDER BY "AMAY_RollNo", "AMST_Id", "FTI_Id"';
        END IF;
    END IF;

    RETURN QUERY EXECUTE "v_query";
END;
$$;