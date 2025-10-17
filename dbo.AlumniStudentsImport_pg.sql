CREATE OR REPLACE FUNCTION "dbo"."AlumniStudentsImport"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMAY_ID_Join TEXT;
    v_AMAY_ID_Left TEXT;
    v_AMCL_ID_JOIN TEXT;
    v_AMCL_ID_LEFT TEXT;
    v_IVRMMR_Id TEXT;
    v_Joinyear BIGINT;
    v_leftyear BIGINT;
    v_JoinClass BIGINT;
    v_LeftClass BIGINT;
    v_RegId BIGINT;
    rec RECORD;
BEGIN

    FOR rec IN 
        SELECT DISTINCT "AMAY_ID_Join", "AMAY_ID_Left", "AMCL_ID_JOIN", "AMCL_ID_LEFT", "IVRMMR_Id" 
        FROM "SRKVS_ALUMNI_M_STUDENT_Temp04June2020"
    LOOP
        v_AMAY_ID_Join := rec."AMAY_ID_Join";
        v_AMAY_ID_Left := rec."AMAY_ID_Left";
        v_AMCL_ID_JOIN := rec."AMCL_ID_JOIN";
        v_AMCL_ID_LEFT := rec."AMCL_ID_LEFT";
        v_IVRMMR_Id := rec."IVRMMR_Id";

        v_Joinyear := 0;
        v_leftyear := 0;
        v_RegId := 0;
        v_JoinClass := 0;
        v_LeftClass := 0;

        SELECT "ASMAY_Id" INTO v_Joinyear 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = 10 AND "ASMAY_Year" = v_AMAY_ID_Join;

        SELECT "ASMAY_Id" INTO v_leftyear 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = 10 AND "ASMAY_Year" = v_AMAY_ID_Left;

        UPDATE "SRKVS_ALUMNI_M_STUDENT_Temp04June2020" 
        SET "AMAY_ID_Join_New" = v_Joinyear 
        WHERE "AMAY_ID_Join" = v_AMAY_ID_Join;

        UPDATE "SRKVS_ALUMNI_M_STUDENT_Temp04June2020" 
        SET "AMAY_ID_Left_New" = v_leftyear 
        WHERE "AMAY_ID_Left" = v_AMAY_ID_Left;

        SELECT "IVRMMR_Id" INTO v_RegId 
        FROM "IVRM_Master_Religion" 
        WHERE "IVRMMR_name" = v_IVRMMR_Id;

        SELECT "ASMCL_Id" INTO v_JoinClass 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = 10 AND "ASMCL_ClassName" = v_AMCL_ID_JOIN;

        SELECT "ASMCL_Id" INTO v_LeftClass 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = 10 AND "ASMCL_ClassName" = v_AMCL_ID_LEFT;

        UPDATE "SRKVS_ALUMNI_M_STUDENT_Temp04June2020" 
        SET "AMCL_ID_JOIN_New" = v_JoinClass 
        WHERE "AMCL_ID_JOIN" = v_AMCL_ID_JOIN;

        UPDATE "SRKVS_ALUMNI_M_STUDENT_Temp04June2020" 
        SET "AMCL_ID_LEFT_New" = v_LeftClass 
        WHERE "AMCL_ID_LEFT" = v_AMCL_ID_LEFT;

        UPDATE "SRKVS_ALUMNI_M_STUDENT_Temp04June2020" 
        SET "IVRMMR_Id_New" = v_RegId 
        WHERE "IVRMMR_Id" = v_IVRMMR_Id;

    END LOOP;

    RETURN;
END;
$$;