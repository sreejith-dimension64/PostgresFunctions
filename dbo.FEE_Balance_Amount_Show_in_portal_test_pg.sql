CREATE OR REPLACE FUNCTION dbo."FEE_Balance_Amount_Show_in_portal_test"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMAY_ID bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Dynamic1 text;
    v_Dynamic2 text;
    v_Dynamic3 text;
    v_Fineamt float;
    v_flgarr1 int;
    v_FMA_Id_F bigint;
    v_Duedate_fine date;
    v_flgarr int;
    v_amt float;
    v_AMST_Id_F bigint;
    v_Fcount bigint;
    v_DueDate_N date;
    v_TODAY_DATE timestamp;
    v_ondate date;
BEGIN

    RAISE NOTICE '%', NOW();

END;
$$;