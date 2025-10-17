CREATE OR REPLACE FUNCTION "dbo"."Fee_Arrear_Report_Format1"(
    p_year bigint,
    p_miid bigint,
    p_fromdate text,
    p_groupids text,
    p_headids text,
    p_class bigint,
    p_section bigint,
    p_allorindi text,
    p_chckdate varchar(100),
    p_amstid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_UserID varchar(100);
    v_sqlstatement text;
    v_flag varchar(10);
    v_cols text;
    v_query text;
    v_monthyearsd bigint;
    v_monthids text;
    v_monthids1 text;
    v_recno text;
    v_Date text;
    v_total varchar(100);
    v_sql text;
    v_id text;
    v_sqlall text;
    v_todate timestamp;
    v_sql1 text;
    v_classid1 varchar(100);
    v_sysname text;
    rec RECORD;
BEGIN
    v_monthyearsd := 0;
    v_flag := 'L';
    v_todate := TO_TIMESTAMP('11/12/2016', 'DD/MM/YYYY');
    
    v_sql1 := 'SELECT "FYGHM_ID" FROM "Fee_Yearly_Group_Head_Mapping" WHERE "FMG_Id" IN (' || p_groupids || ') and "FMH_ID" In(' || p_headids || ')';
    
    v_monthids := '';
    
    FOR rec IN EXECUTE v_sql1
    LOOP
        v_id := rec."FYGHM_ID"::text;
        IF v_monthyearsd = 0 THEN
            v_monthids := v_id;
            v_monthyearsd := v_monthyearsd + 1;
        ELSE
            v_monthids := v_monthids || ',' || v_id;
        END IF;
    END LOOP;
    
    v_classid1 := p_class::varchar;
    
    IF p_allorindi = 'all' THEN
        PERFORM "dbo"."sp_Arrear_Calc_Multi_Years_All_Students"(p_class, p_miid, p_year, v_todate, 0, 0, 0, 0);
        
        IF p_chckdate = '0' THEN
            v_sqlall := 'SELECT "dbo"."Adm_M_Student"."AMST_RegistrationNo", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_Id",
"dbo"."Adm_M_Student"."AMST_FatherName", "dbo"."adm_M_student"."AMST_MobileNo","dbo"."V_StudentPendingAll"."fyg_id", "dbo"."V_StudentPendingAll"."fmh_id", 
"dbo"."V_StudentPendingAll"."fti_id", "dbo"."V_StudentPendingAll"."AyCl_id", "dbo"."V_StudentPendingAll"."fmh_name", "dbo"."V_StudentPendingAll"."fma_id", 
"dbo"."V_StudentPendingAll"."amay_id", "dbo"."V_StudentPendingAll"."fti_name","FMG_GroupName", "dbo"."V_StudentPendingAll"."ftp_tobepaid_amt", "dbo"."V_StudentPendingAll"."paidamount", 
"dbo"."V_StudentPendingAll"."ftp_concession_amt",  "dbo"."V_StudentPendingAll"."Net_amount" , "dbo"."V_StudentPendingAll"."ftp_fine_amt", "dbo"."V_StudentPendingAll"."reason",
"dbo"."Fee_Master_Group"."FMG_Id","FMG_ActiceFlag" , "aycl_id","dbo"."Fee_Yearly_Group"."FYG_Id" FROM "dbo"."Fee_Yearly_Group" INNER JOIN "dbo"."Fee_Master_Group" ON 
"dbo"."Fee_Yearly_Group"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN  "dbo"."V_StudentPendingAll" INNER JOIN "dbo"."Adm_M_Student" ON 
"dbo"."V_StudentPendingAll"."amst_id" = "dbo"."Adm_M_Student"."AMST_Id" ON "dbo"."Fee_Yearly_Group"."FYG_Id" = "dbo"."V_StudentPendingAll"."fyg_id"  and "AMST_SOL"<>''' || v_flag || ''' 
and  "dbo"."Fee_Yearly_Group"."FYG_Id" in (select "FYG_Id" from "Fee_Yearly_Group_Head_Mapping" inner join "Fee_Yearly_Group" on 
"Fee_Yearly_Group"."FMG_Id"="Fee_Yearly_Group_Head_Mapping"."FMG_Id" where "FYGHM_Id" in(' || v_monthids || ')) and "dbo"."v_studentpendingAll"."fmh_id" in
(select "fmh_id" from "Fee_Yearly_Group_Head_Mapping" where "FYGHM_Id" in (' || v_monthids || ')) and "AyCl_id" in(' || v_classid1 || ') UNION  
SELECT "dbo"."Adm_M_Student"."AMST_RegistrationNo", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_Id",
"dbo"."Adm_M_Student"."AMST_FatherName", "dbo"."adm_M_student"."AMST_MobileNo","dbo"."V_StudentPendingAll"."fyg_id", "dbo"."V_StudentPendingAll"."fmh_id", 
"dbo"."V_StudentPendingAll"."fti_id", "dbo"."V_StudentPendingAll"."AyCl_id", "dbo"."V_StudentPendingAll"."fmh_name", "dbo"."V_StudentPendingAll"."fma_id", 
"dbo"."V_StudentPendingAll"."amay_id", "dbo"."V_StudentPendingAll"."fti_name","FMG_GroupName",  "dbo"."V_StudentPendingAll"."ftp_tobepaid_amt", 
"dbo"."V_StudentPendingAll"."paidamount", "dbo"."V_StudentPendingAll"."ftp_concession_amt",  "dbo"."V_StudentPendingAll"."Net_amount" , "dbo"."V_StudentPendingAll"."ftp_fine_amt", 
"dbo"."V_StudentPendingAll"."reason","dbo"."Fee_Master_Group"."FMG_Id","FMG_ActiceFlag", "aycl_id", "dbo"."Fee_Yearly_Group"."FYG_Id"  FROM "dbo"."Fee_Yearly_Group" INNER JOIN 
"dbo"."Fee_Master_Group" ON "dbo"."Fee_Yearly_Group"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN  "dbo"."V_StudentPendingAll" INNER JOIN "dbo"."Adm_M_Student" ON 
"dbo"."V_StudentPendingAll"."amst_id" = "dbo"."Adm_M_Student"."AMST_Id" ON "dbo"."Fee_Yearly_Group"."FYG_Id" = "dbo"."V_StudentPendingAll"."fyg_id"  and "AMST_SOL"<>''' || v_flag || ''' and  
"dbo"."Fee_Yearly_Group"."FYG_Id" in (select "FYG_Id" from "Fee_Yearly_Group_Head_Mapping" inner join "Fee_Yearly_Group" on 
"Fee_Yearly_Group"."FMG_Id"="Fee_Yearly_Group_Head_Mapping"."FMG_Id" where "FYGHM_Id" in(' || v_monthids || ')) and "dbo"."v_studentpendingAll"."fmh_id" in
(select "fmh_id" from "Fee_Yearly_Group_Head_Mapping" where "FYGHM_Id" in (' || v_monthids || ')) and "AyCl_id" in (' || v_classid1 || ' ) and "dbo"."v_studentpendingAll"."fyg_id" in  
(select "fyg_id" from "Fee_Yearly_Group_Head_Mapping" inner join "Fee_Yearly_Group" on  "Fee_Yearly_Group"."FMG_Id"="Fee_Yearly_Group_Head_Mapping"."FMG_Id" where "FYGHM_Id" 
in(' || v_monthids || ')) and "dbo"."v_studentpendingAll"."fmh_id" in(select "fmh_id" from "Fee_Yearly_Group_Head_Mapping" where "FYGHM_Id" in(' || v_monthids || '))';
        END IF;
        
        EXECUTE v_sqlall;
    ELSIF p_allorindi = 'indi' THEN
        v_sysname := '';
        v_flag := 'S';
        
        IF p_chckdate = '0' THEN
            v_sqlall := 'SELECT DISTINCT "dbo"."Adm_M_Student"."AMST_RegistrationNo" , "dbo"."Adm_M_Student"."AMST_FirstName" , "dbo"."Adm_M_Student"."AMST_MiddleName" , 
"dbo"."Adm_M_Student"."AMST_LastName" , "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_M_Student"."AMST_FatherName",  "dbo"."Adm_M_Student"."AMST_MobileNo", "dbo"."V_StudentPending"."fyg",
"Adm_School_Y_Student"."asmcl_id","dbo"."V_StudentPending"."Fmh_id", "dbo"."V_StudentPending"."fti_id","dbo"."V_StudentPending"."fmh_name","dbo"."V_StudentPending"."fma_id", 
"dbo"."Fee_Master_Group"."FMG_GroupName", "dbo"."V_StudentPending"."ftp_tobepaid_amt", "dbo"."V_StudentPending"."paidamount","dbo"."V_StudentPending"."ftp_concession_amt", 
"dbo"."V_StudentPending"."Net_amount", "dbo"."V_StudentPending"."ftp_fine_amt","dbo"."Fee_Master_Group"."FMG_ActiceFlag","dbo"."Fee_Yearly_Group"."FMG_Id", 
"dbo"."Adm_M_Student"."AMST_SOL", "dbo"."Adm_School_Y_Student"."AMST_Id", "dbo"."Adm_School_Y_Student"."ASYST_Id","dbo"."V_StudentPending"."fti_name" , "dbo"."V_StudentPending"."amay_id" 
FROM "dbo"."Adm_School_M_Academic_Year" INNER JOIN "dbo"."Adm_M_Student" on "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"="dbo"."Adm_M_Student"."ASMAY_Id" inner join 
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" inner join  "dbo"."V_StudentPending" on 
"dbo"."V_StudentPending"."amst_id"="dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Fee_Master_Group" INNER JOIN "dbo"."Fee_Yearly_Group" ON 
"dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" ON "dbo"."V_StudentPending"."fyg" = "dbo"."Fee_Yearly_Group"."FYG_Id" 
WHERE ("dbo"."Adm_M_Student"."AMST_SOL" = ''' || v_flag || ''')AND ("dbo"."V_StudentPending"."fyg" IS NOT NULL) and "dbo"."v_studentpending"."fmh_id" in(' || p_headids || ') 
and "Adm_School_Y_Student"."ASMCL_Id" in (' || v_classid1 || ') and "dbo"."V_StudentPending"."fyg" in( select "FYG_Id" from "Fee_Yearly_Group"  where "FMG_Id" in(' || p_groupids || ')) 
Order by "Adm_School_Y_Student"."asmcl_id", "dbo"."V_StudentPending"."fyg","dbo"."V_StudentPending"."Fmh_id"';
        END IF;
        
        EXECUTE v_sqlall;
    END IF;
    
    RETURN;
END;
$$;