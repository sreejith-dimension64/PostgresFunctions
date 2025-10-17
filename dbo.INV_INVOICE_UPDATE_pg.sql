CREATE OR REPLACE FUNCTION "dbo"."INV_INVOICE_UPDATE"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    INOUT p_StudentAdmnoOP TEXT DEFAULT ''
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_SchNo TEXT;
    v_StuCount int;
    v_StudentAdmno TEXT;
    v_AdmPrefix TEXT;
    v_AMST_Id bigint;
    v_ASMAY_Year TEXT;
BEGIN

    IF (p_MI_Id = 16) THEN
        v_AdmPrefix := 'VKS';
    ELSIF (p_MI_Id = 17) THEN
        v_AdmPrefix := 'VTS';
    ELSIF (p_MI_Id = 20) THEN
        v_AdmPrefix := 'Unnathi';
    ELSIF (p_MI_Id = 21) THEN
        v_AdmPrefix := 'Smart';
    ELSIF (p_MI_Id = 22) THEN
        v_AdmPrefix := 'Marga';
    ELSIF (p_MI_Id = 23) THEN
        v_AdmPrefix := 'VTS';
    ELSIF (p_MI_Id = 24) THEN
        v_AdmPrefix := 'VTS';
    ELSIF (p_MI_Id = 27) THEN
        v_AdmPrefix := 'VTS';
    END IF;

    SELECT "ASMAY_Year" INTO v_ASMAY_Year 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

    SELECT COUNT(*) INTO v_StuCount
    FROM "ISM_Invoice" AMS
    WHERE AMS."MI_Id" = p_MI_Id 
        AND (LENGTH(COALESCE("ISMINC_PrInviceNo", '')) > 0 
            OR LENGTH(COALESCE("ISMINC_PrInviceNo", '')) > 0);

    IF (v_StuCount <> 0) THEN
        SELECT COUNT(*) INTO v_SchNo
        FROM "ISM_Invoice" AMS
        WHERE AMS."MI_Id" = p_MI_Id 
            AND (LENGTH(COALESCE("ISMINC_PrInviceNo", '')) > 0 
                OR LENGTH(COALESCE("ISMINC_PrInviceNo", '')) > 0);

        v_SchNo := (v_SchNo + 1)::TEXT;
    ELSE
        v_SchNo := '1';
    END IF;

    v_StudentAdmno := v_AdmPrefix || '/' || 
                      LPAD(v_SchNo, 4, '0') || '/' || 
                      v_ASMAY_Year;

    p_StudentAdmnoOP := v_StudentAdmno;

    RETURN;

END;
$$;