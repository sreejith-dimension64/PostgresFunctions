CREATE OR REPLACE FUNCTION "dbo"."Get_due_dates"(
    p_mi_id bigint,
    p_asmayid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_DueDate varchar(10);
    v_NoOfDays int;
    v_Emon int;
    v_Smon int;
    v_Syear int;
    v_Eyear int;
    v_FMA_Id bigint;
    v_FTI_Id bigint;
    v_ftdd_day float;
    v_ftdd_month float;
    v_frm_day int;
    v_fmfs_from_day int;
    v_FMH_Id bigint;
    v_fmfs_to_day int;
    v_FMH_FeeName varchar(70);
    v_FTFS_Amount float;
    v_from_day int;
    v_FMT_Name varchar(70);
    v_FMT_Id bigint;
    v_On_Date TIMESTAMP;
BEGIN

    RAISE NOTICE 'aa';

END;
$$;