CREATE OR REPLACE FUNCTION "dbo"."get_installments"(
    "MI_Id" VARCHAR(10),
    "ASMAY_Id" VARCHAR(10),
    "FMCC_Id" VARCHAR(10),
    "FTI_Id" TEXT,
    "asmcL_Id" VARCHAR(10),
    "amsC_Id" VARCHAR(10),
    "type" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "AMST_FirstName" TEXT,
    "ASMCL_Id" INTEGER,
    "ASMCL_ClassName" TEXT,
    "ASMS_Id" INTEGER,
    "ASMC_SectionName" TEXT,
    "FTI_Id" INTEGER,
    "FTI_Name" TEXT,
    "Balance" NUMERIC,
    "Paid" NUMERIC,
    "Concession" NUMERIC,
    "Waivedoff" NUMERIC,
    "Fine" NUMERIC,
    "Netamount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    query TEXT;
BEGIN
    IF "type" = 'Category' THEN
        query := 'SELECT DISTINCT a."AMST_Id",
            COALESCE(b."AMST_FirstName",'''') || '' '' || COALESCE(b."AMST_MiddleName",'''') || '' '' || COALESCE(b."AMST_LastName",'''') as "AMST_FirstName",
            c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name",
            SUM(a."FSS_ToBePaid") as "Balance", SUM(a."FSS_PaidAmount") as "Paid", 
            SUM(a."FSS_ConcessionAmount") as "Concession", SUM(a."FSS_WaivedAmount") as "Waivedoff",
            SUM(a."FSS_FineAmount") as "Fine", SUM(a."FSS_NetAmount") as "Netamount"
        FROM "Fee_Student_Status" a
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" c ON b."AMST_Id" = c."AMST_Id"
        INNER JOIN "Fee_Master_Class_Category" d ON d."FMCC_Id" = ' || "FMCC_Id" || '
        INNER JOIN "Fee_Yearly_Class_Category" h ON d."FMCC_Id" = h."FMCC_Id"
        INNER JOIN "Fee_Master_Amount" i ON h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id"
        INNER JOIN "Fee_T_Installment" g ON a."FTI_Id" = g."FTI_Id"
        WHERE a."MI_Id" = ' || "MI_Id" || '
            AND b."MI_Id" = ' || "MI_Id" || '
            AND d."MI_Id" = ' || "MI_Id" || '
            AND a."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND c."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND h."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND b."AMST_SOL" = ''S''
            AND b."AMST_ActiveFlag" = 1
            AND c."AMAY_ActiveFlag" = 1
            AND e."MI_Id" = ' || "MI_Id" || '
            AND e."ASMCL_ActiveFlag" = 1
            AND f."MI_Id" = ' || "MI_Id" || '
            AND f."ASMC_ActiveFlag" = 1
            AND a."FTI_Id" IN (' || "FTI_Id" || ')
            AND g."MI_ID" = ' || "MI_Id" || '
        GROUP BY a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName",
            c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name"
        ORDER BY a."AMST_Id", a."FTI_Id"';
        
    ELSIF "type" = 'Class' THEN
        query := 'SELECT DISTINCT a."AMST_Id",
            COALESCE(b."AMST_FirstName",'''') || '' '' || COALESCE(b."AMST_MiddleName",'''') || '' '' || COALESCE(b."AMST_LastName",'''') as "AMST_FirstName",
            c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name",
            SUM(a."FSS_ToBePaid") as "Balance", SUM(a."FSS_PaidAmount") as "Paid", 
            SUM(a."FSS_ConcessionAmount") as "Concession", SUM(a."FSS_WaivedAmount") as "Waivedoff",
            SUM(a."FSS_FineAmount") as "Fine", SUM(a."FSS_NetAmount") as "Netamount"
        FROM "Fee_Student_Status" a
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" c ON b."AMST_Id" = c."AMST_Id"
        INNER JOIN "Fee_Master_Class_Category" d ON TRUE
        INNER JOIN "Fee_Yearly_Class_Category" h ON d."FMCC_Id" = h."FMCC_Id"
        INNER JOIN "Fee_Master_Amount" i ON h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id"
        INNER JOIN "Fee_T_Installment" g ON a."FTI_Id" = g."FTI_Id"
        WHERE a."MI_Id" = ' || "MI_Id" || '
            AND b."MI_Id" = ' || "MI_Id" || '
            AND d."MI_Id" = ' || "MI_Id" || '
            AND a."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND c."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND h."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND b."AMST_SOL" = ''S''
            AND b."AMST_ActiveFlag" = 1
            AND c."AMAY_ActiveFlag" = 1
            AND e."MI_Id" = ' || "MI_Id" || '
            AND c."ASMCL_Id" = ' || "asmcL_Id" || '
            AND f."ASMS_Id" = ' || "amsC_Id" || '
            AND e."ASMCL_ActiveFlag" = 1
            AND f."MI_Id" = ' || "MI_Id" || '
            AND f."ASMC_ActiveFlag" = 1
            AND a."FTI_Id" IN (
                SELECT DISTINCT fti."FTI_Id" 
                FROM "Fee_T_Installment" fti
                INNER JOIN "Fee_Student_Status" fss ON fss."FTI_Id" = fti."FTI_Id"
                INNER JOIN "Adm_School_Y_Student" asy ON asy."AMST_Id" = fss."AMST_Id"
                WHERE fss."MI_Id" = ' || "MI_Id" || '
                    AND asy."ASMAY_Id" = ' || "ASMAY_Id" || '
                    AND fss."FSS_TotalToBePaid" > 0
            )
            AND g."MI_ID" = ' || "MI_Id" || '
        GROUP BY a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName",
            c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name"
        ORDER BY a."AMST_Id", a."FTI_Id"';
        
    ELSE
        query := 'SELECT DISTINCT a."AMST_Id",
            COALESCE(b."AMST_FirstName",'''') || '' '' || COALESCE(b."AMST_MiddleName",'''') || '' '' || COALESCE(b."AMST_LastName",'''') as "AMST_FirstName",
            c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name",
            SUM(a."FSS_ToBePaid") as "Balance", SUM(a."FSS_PaidAmount") as "Paid", 
            SUM(a."FSS_ConcessionAmount") as "Concession", SUM(a."FSS_WaivedAmount") as "Waivedoff",
            SUM(a."FSS_FineAmount") as "Fine", SUM(a."FSS_NetAmount") as "Netamount"
        FROM "Fee_Student_Status" a
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" c ON b."AMST_Id" = c."AMST_Id"
        INNER JOIN "Fee_Master_Class_Category" d ON TRUE
        INNER JOIN "Fee_Yearly_Class_Category" h ON d."FMCC_Id" = h."FMCC_Id"
        INNER JOIN "Fee_Master_Amount" i ON h."FMCC_Id" = i."FMCC_Id" AND i."FMA_Id" = a."FMA_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id"
        INNER JOIN "Fee_T_Installment" g ON a."FTI_Id" = g."FTI_Id"
        INNER JOIN "trn"."TR_Student_Route" t ON a."AMST_Id" = t."AMST_Id" AND a."FMG_Id" = t."FMG_Id"
        WHERE a."MI_Id" = ' || "MI_Id" || '
            AND b."MI_Id" = ' || "MI_Id" || '
            AND d."MI_Id" = ' || "MI_Id" || '
            AND a."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND c."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND h."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND b."AMST_SOL" = ''S''
            AND b."AMST_ActiveFlag" = 1
            AND c."AMAY_ActiveFlag" = 1
            AND e."MI_Id" = ' || "MI_Id" || '
            AND c."ASMCL_Id" = ' || "asmcL_Id" || '
            AND f."ASMS_Id" = ' || "amsC_Id" || '
            AND e."ASMCL_ActiveFlag" = 1
            AND f."MI_Id" = ' || "MI_Id" || '
            AND f."ASMC_ActiveFlag" = 1
            AND a."FTI_Id" IN (
                SELECT DISTINCT fti."FTI_Id" 
                FROM "Fee_T_Installment" fti
                INNER JOIN "Fee_Student_Status" fss ON fss."FTI_Id" = fti."FTI_Id"
                INNER JOIN "Adm_School_Y_Student" asy ON asy."AMST_Id" = fss."AMST_Id"
                WHERE fss."MI_Id" = ' || "MI_Id" || '
                    AND asy."ASMAY_Id" = ' || "ASMAY_Id" || '
                    AND fss."FSS_TotalToBePaid" > 0
            )
            AND g."MI_ID" = ' || "MI_Id" || '
            AND t."FMG_Id" = ' || "amsC_Id" || '
            AND t."ASMAY_Id" = ' || "ASMAY_Id" || '
            AND t."MI_Id" = ' || "MI_Id" || '
        GROUP BY a."AMST_Id", b."AMST_FirstName", b."AMST_MiddleName", b."AMST_LastName",
            c."ASMCL_Id", e."ASMCL_ClassName", c."ASMS_Id", f."ASMC_SectionName", a."FTI_Id", g."FTI_Name"
        ORDER BY a."AMST_Id", a."FTI_Id"';
    END IF;
    
    RETURN QUERY EXECUTE query;
END;
$$;