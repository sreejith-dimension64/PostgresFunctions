CREATE OR REPLACE FUNCTION "dbo"."Fee_termwise_statistics_old" (
    "@mi_id" bigint,
    "@asmay_id" bigint,
    "@asmcl_id" varchar(50),
    "@asms_id" varchar(50),
    "@fmg_id" varchar(50),
    "@user_id" bigint
)
RETURNS TABLE (
    "AMST_Id" bigint,
    "AMST_AdmNo" varchar,
    "Net" numeric,
    "Bal" numeric,
    "Paid" numeric,
    "FMT_Id" bigint,
    "FMT_Name" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
    'SELECT DISTINCT z."AMST_Id", z."AMST_AdmNo", 
        SUM(w."FSS_CurrentYrCharges" + w."FSS_OBArrearAmount") AS "Net",
        SUM(w."FSS_ToBePaid") AS "Bal", 
        SUM(w."FSS_PaidAmount") AS "Paid", 
        x."FMT_Id", 
        r."FMT_Name"  
     FROM "Fee_Student_Status" w
     INNER JOIN "Adm_M_Student" z ON z."AMST_Id" = w."AMST_Id" 
     INNER JOIN "Fee_Master_Terms_FeeHeads" x ON x."FMH_Id" = w."FMH_Id"
     INNER JOIN "Fee_Master_Terms" r ON x."FMT_Id" = r."FMT_Id"
     WHERE x."FTI_Id" = w."FTI_Id" 
       AND w."AMST_Id" IN (
           SELECT DISTINCT a."AMST_Id" 
           FROM "Adm_M_Student" a
           INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"  
           INNER JOIN "Fee_Student_Status" c ON c."AMST_Id" = a."AMST_Id" AND b."asmay_id" = c."asmay_id"
           INNER JOIN "Fee_Master_Terms_FeeHeads" d ON c."FMH_Id" = d."FMH_Id"
           WHERE a."MI_Id" = ' || "@mi_id" || ' 
             AND a."ASMAY_Id" = ' || "@asmay_id" || ' 
             AND a."ASMCL_Id" IN (' || "@asmcl_id" || ') 
             AND b."ASMS_Id" IN (' || "@asms_id" || ') 
             AND c."FMG_Id" IN (' || "@fmg_id" || ') 
             AND c."FTI_Id" = d."FTI_Id"
       )
     GROUP BY x."FMT_Id", r."FMT_Name", z."AMST_AdmNo", z."AMST_Id"';
END;
$$;