CREATE OR REPLACE FUNCTION "dbo"."Dashboard_Mobile_Disable_Alertmessage" (
    p_mi_id bigint,
    p_flag text
)
RETURNS TABLE("messag" text)
LANGUAGE plpgsql
AS $$
DECLARE
    v_msg text;
BEGIN
    IF p_flag = 'INT' THEN
        v_msg := 'Sorry Institution is Deactivated...Kindly contact Administrator';
    ELSIF p_flag = 'ORG' THEN
        v_msg := 'Sorry Organization is Deactivated...Kindly contact Administrator';
    ELSIF p_flag = 'SUBACTIVE' THEN
        v_msg := 'Technical Upgradation in progress Regret inconvenience caused.

For help and assistance kindly contact School Office.';
    ELSIF p_flag = 'SUBDIS' THEN
        v_msg := 'Sorry Your Subscription date is been crossed...Kindly contact Administrator';
    END IF;

    RETURN QUERY SELECT v_msg;
END;
$$;