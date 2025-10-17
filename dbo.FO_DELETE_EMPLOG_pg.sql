CREATE OR REPLACE FUNCTION "FO_DELETE_EMPLOG"(p_FOEPD_Id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_COUNT INT;
    v_FOEP_Id BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_COUNT 
    FROM "FO"."FO_Emp_Punch_Details" 
    WHERE "FOEP_Id" = p_FOEPD_Id;

    IF (v_COUNT = 1) THEN
        SELECT "FOEP_Id" INTO v_FOEP_Id 
        FROM "FO"."FO_Emp_Punch_Details" 
        WHERE "FOEP_Id" = p_FOEPD_Id;

        DELETE FROM "FO"."FO_Emp_Punch_Details" 
        WHERE "FOEPD_Id" = p_FOEPD_Id;

        DELETE FROM "FO"."FO_Emp_Punch" 
        WHERE "FOEP_Id" = v_FOEP_Id;
    ELSE
        DELETE FROM "FO"."FO_Emp_Punch_Details" 
        WHERE "FOEPD_Id" = p_FOEPD_Id;
    END IF;

    RETURN;
END;
$$;