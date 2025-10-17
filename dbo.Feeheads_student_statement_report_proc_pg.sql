CREATE OR REPLACE FUNCTION "dbo"."Feeheads_student_statement_report_proc"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint,
    p_FMH_Id text,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_typeflag varchar(50),
    p_Studying bigint,
    p_Left bigint
)
RETURNS TABLE(
    "FSS_NetAmount" numeric,
    "FSS_ConcessionAmount" numeric,
    "FSS_TotalToBePaid" numeric,
    "FSS_ToBePaid" numeric,
    "FSS_PaidAmount" numeric,
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "FMH_Id" bigint,
    "AMST_Id" bigint,
    "AMST_FirstName" varchar,
    "AMST_MiddleName" varchar,
    "AMST_LastName" varchar,
    "AMST_FatherName" varchar,
    "ASMCL_ClassName" varchar,
    "ASMAY_Year" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlexec text;
    v_Studying1 text;
    v_Left1 text;
    v_DeActive1 text;
BEGIN
    IF p_Studying = 1 AND p_Left = 1 THEN
        v_Studying1 := '';
    ELSIF p_Studying = 1 AND p_Left = 0 THEN
        v_Studying1 := 'and adm."AMST_ActiveFlag"=1';
    ELSIF p_Studying = 0 AND p_Left = 1 THEN
        v_Studying1 := 'and adm."AMST_ActiveFlag"=0';
    ELSIF p_Studying = 0 AND p_Left = 0 THEN
        v_Studying1 := '';
    END IF;

    IF p_typeflag = 'All' THEN
        v_sqlexec := '
        select distinct SUM("FSS_NetAmount") as "FSS_NetAmount",SUM("FSS_ConcessionAmount") as "FSS_ConcessionAmount",SUM("FSS_TotalToBePaid") as "FSS_TotalToBePaid",SUM("FSS_ToBePaid") as "FSS_ToBePaid",SUM("FSS_PaidAmount") as "FSS_PaidAmount","Fee_Student_Status"."MI_Id",adm."ASMAY_Id","Fee_Master_Head"."FMH_Id",adm."AMST_Id",adm."AMST_FirstName",adm."AMST_MiddleName",adm."AMST_LastName",adm."AMST_FatherName",cl."ASMCL_ClassName",y."ASMAY_Year" from "Fee_Student_Status" 
        inner join "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
        inner join "Adm_M_Student" adm on "Fee_Student_Status"."AMST_Id"=adm."AMST_Id"
        left join "Adm_School_M_Class" cl on adm."ASMCL_Id"=cl."ASMCL_Id"
        left join "Adm_School_M_Academic_Year" y on adm."ASMAY_Id"=y."ASMAY_Id"
        where "Fee_Student_Status"."MI_Id"=' || p_MI_Id || ' and adm."ASMAY_Id"=' || p_ASMAY_Id || '  and "Fee_Master_Head"."FMH_Id" in  (' || p_FMH_Id || ') ' || v_Studying1 || '   group by "Fee_Student_Status"."MI_Id",adm."ASMAY_Id","Fee_Master_Head"."FMH_Id",adm."AMST_Id",adm."AMST_FirstName",adm."AMST_MiddleName",adm."AMST_LastName",adm."AMST_FatherName",cl."ASMCL_ClassName",y."ASMAY_Year"';
        
        RAISE NOTICE '1111';
        RETURN QUERY EXECUTE v_sqlexec;
        
    ELSIF p_typeflag = 'Individual' THEN
        v_sqlexec := '
        select distinct SUM("FSS_NetAmount") as "FSS_NetAmount",SUM("FSS_ConcessionAmount") as "FSS_ConcessionAmount",SUM("FSS_TotalToBePaid") as "FSS_TotalToBePaid",SUM("FSS_ToBePaid") as "FSS_ToBePaid",SUM("FSS_PaidAmount") as "FSS_PaidAmount","Fee_Student_Status"."MI_Id",adm."ASMAY_Id","Fee_Master_Head"."FMH_Id",adm."AMST_Id",adm."AMST_FirstName",adm."AMST_MiddleName",adm."AMST_LastName",adm."AMST_FatherName",cl."ASMCL_ClassName",y."ASMAY_Year"  from "Fee_Student_Status" 
        inner join "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
        inner join "Adm_M_Student" adm on "Fee_Student_Status"."AMST_Id"=adm."AMST_Id"
        left join "Adm_School_M_Class" cl on adm."ASMCL_Id"=cl."ASMCL_Id"
        left join "Adm_School_M_Academic_Year" y on adm."ASMAY_Id"=y."ASMAY_Id"
        where "Fee_Student_Status"."MI_Id"=' || p_MI_Id || ' and adm."ASMAY_Id"=' || p_ASMAY_Id || ' and adm."AMST_Id"=' || p_AMST_Id || ' and "Fee_Master_Head"."FMH_Id" in  (' || p_FMH_Id || ')  group by "Fee_Student_Status"."MI_Id",adm."ASMAY_Id","Fee_Master_Head"."FMH_Id",adm."AMST_Id",adm."AMST_FirstName",adm."AMST_MiddleName",adm."AMST_LastName",adm."AMST_FatherName",cl."ASMCL_ClassName",y."ASMAY_Year"';
        
        RAISE NOTICE '222';
        RETURN QUERY EXECUTE v_sqlexec;
        
    ELSIF p_typeflag = 'CS' THEN
        v_sqlexec := '
        select distinct SUM("FSS_NetAmount") as "FSS_NetAmount",SUM("FSS_ConcessionAmount") as "FSS_ConcessionAmount",SUM("FSS_TotalToBePaid") as "FSS_TotalToBePaid",SUM("FSS_ToBePaid") as "FSS_ToBePaid",SUM("FSS_PaidAmount") as "FSS_PaidAmount","Fee_Student_Status"."MI_Id",adm."ASMAY_Id","Fee_Master_Head"."FMH_Id",adm."AMST_Id",adm."AMST_FirstName",adm."AMST_MiddleName",adm."AMST_LastName",adm."AMST_FatherName",cl."ASMCL_ClassName",y."ASMAY_Year" from "Fee_Student_Status"
        inner join "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
        inner join "Adm_M_Student" adm on "Fee_Student_Status"."AMST_Id"=adm."AMST_Id" 
        left join "Adm_School_M_Class" cl on adm."ASMCL_Id"=cl."ASMCL_Id"
        left join "Adm_School_M_Academic_Year" y on adm."ASMAY_Id"=y."ASMAY_Id"
        inner join "Adm_School_Y_Student" sy on sy."AMST_Id"=adm."AMST_Id"
        where "Fee_Student_Status"."MI_Id"=' || p_MI_Id || ' and adm."ASMAY_Id"=' || p_ASMAY_Id || ' and sy."ASMCL_Id"=' || p_ASMCL_Id || ' and  sy."ASMS_Id"=' || p_ASMS_Id || ' and "Fee_Master_Head"."FMH_Id" in (' || p_FMH_Id || ') group by "Fee_Student_Status"."MI_Id",adm."ASMAY_Id","Fee_Master_Head"."FMH_Id",adm."AMST_Id",adm."AMST_FirstName",adm."AMST_MiddleName",adm."AMST_LastName",adm."AMST_FatherName",cl."ASMCL_ClassName",y."ASMAY_Year"';
        
        RAISE NOTICE '333';
        RETURN QUERY EXECUTE v_sqlexec;
    END IF;
    
    RETURN;
END;
$$;