CREATE OR REPLACE FUNCTION "Hostel_Studentscount_details"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "ASYST_Id" bigint,
    "AMST_Id" bigint,
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "AMAY_RollNo" bigint,
    "AMAY_ActiveFlag" integer,
    "AMAY_DateTime" timestamp,
    "LoginId" bigint,
    "AMAY_PassFailFlag" varchar,
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Prcount bigint;
    v_JoinStudents bigint;
BEGIN
    
    SELECT COUNT(*) INTO v_Prcount 
    FROM "Preadmission_School_Registration" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

    SELECT COUNT(*) INTO v_JoinStudents 
    FROM "Adm_School_Y_Student" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
    AND "AMST_Id" IN (
        SELECT "AMST_Id" 
        FROM "Adm_M_Student" 
        WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "AMST_SOL" = 'S' 
        AND "AMST_ActiveFlag" = 1
    ) 
    AND "AMAY_ActiveFlag" = 1;

    RETURN QUERY
    SELECT * 
    FROM "Adm_School_Y_Student" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
    AND "AMST_Id" IN (
        SELECT "AMST_Id" 
        FROM "Adm_M_Student" 
        WHERE "MI_Id" = p_MI_Id
    ) 
    AND "AMAY_ActiveFlag" = 1;

    RETURN QUERY
    SELECT * 
    FROM "Adm_School_Y_Student" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
    AND "AMST_Id" IN (
        SELECT "AMST_Id" 
        FROM "Adm_M_Student" 
        WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "AMST_SOL" = 'L' 
        AND "AMST_ActiveFlag" = 0
    ) 
    AND "AMAY_ActiveFlag" = 0;

    RETURN;
END;
$$;