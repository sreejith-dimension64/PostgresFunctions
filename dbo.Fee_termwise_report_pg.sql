CREATE OR REPLACE FUNCTION "dbo"."Fee_termwise_report" (
    p_mi_id bigint, 
    p_asmay_id bigint, 
    p_asmcl_id varchar(50), 
    p_asms_id varchar(50), 
    p_fmg_id varchar(50), 
    p_user_id bigint
)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS $$
DECLARE
    ref1 refcursor := 'cursor1';
    ref2 refcursor := 'cursor2';
    ref3 refcursor := 'cursor3';
BEGIN

    OPEN ref1 FOR EXECUTE 
    'SELECT DISTINCT a."AMST_Id", CONCAT(a."AMST_FirstName",'' '',a."AMST_MiddleName",'' '',a."AMST_LastName") as std_name, a."AMST_AdmNo" 
    FROM "Adm_M_Student" a
    INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Fee_Student_Status" c ON c."AMST_Id" = a."AMST_Id"
    WHERE a."MI_Id" = ' || p_mi_id || ' AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."ASMCL_Id" IN(' || p_asmcl_id || ') AND b."ASMS_Id" IN (' || p_asms_id || ') AND c."FMG_Id" IN(' || p_fmg_id || ')';
    
    RETURN NEXT ref1;

    OPEN ref2 FOR EXECUTE 
    'SELECT DISTINCT z."AMST_Id", z."AMST_AdmNo", sum(w."FSS_ToBePaid") as "Bal", sum(w."FSS_PaidAmount") as "Paid", x."FMT_Id", r."FMT_Name"  
    FROM "Fee_Student_Status" w
    INNER JOIN "Adm_M_Student" z ON z."AMST_Id" = w."AMST_Id" 
    INNER JOIN "Fee_Master_Terms_FeeHeads" x ON x."FMH_Id" = w."FMH_Id"
    INNER JOIN "Fee_Master_Terms" r ON x."FMT_Id" = r."FMT_Id"
    WHERE x."FTI_Id" = w."FTI_Id" AND w."AMST_Id" IN( 
        SELECT DISTINCT a."AMST_Id" FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id" 
        INNER JOIN "Fee_Student_Status" c ON c."AMST_Id" = a."AMST_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" d ON c."FMH_Id" = d."FMH_Id"
        WHERE a."MI_Id" = ' || p_mi_id || ' AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."ASMCL_Id" IN(' || p_asmcl_id || ') AND b."ASMS_Id" IN (' || p_asms_id || ') AND c."FMG_Id" IN(' || p_fmg_id || ') AND c."FTI_Id" = d."FTI_Id")
    GROUP BY x."FMT_Id", r."FMT_Name", z."AMST_AdmNo", z."AMST_Id"';
    
    RETURN NEXT ref2;

    OPEN ref3 FOR EXECUTE 
    'SELECT DISTINCT a."FMT_Id", a."FMT_Name" 
    FROM "Fee_Master_Terms" a
    INNER JOIN "Fee_Master_Terms_FeeHeads" b ON a."FMT_Id" = b."FMT_Id"
    INNER JOIN "Fee_Student_Status" c ON c."FMH_Id" = b."FMH_Id"
    INNER JOIN "Fee_Master_Group" d ON d."FMG_Id" = c."FMG_Id"
    WHERE a."MI_Id" = ' || p_mi_id || ' AND c."ASMAY_Id" = ' || p_asmay_id || ' AND c."FMG_Id" IN(' || p_fmg_id || ') AND d."user_id" = ' || p_user_id;
    
    RETURN NEXT ref3;

    RETURN;

END;
$$;