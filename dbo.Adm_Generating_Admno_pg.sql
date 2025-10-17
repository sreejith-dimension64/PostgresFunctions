CREATE OR REPLACE FUNCTION "dbo"."Adm_Generating_Admno"(
    p_MI_Id TEXT,
    p_Year TEXT,
    p_AMST_Id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_IMN_Flag TEXT;
    v_IMN_AutoManualFlag TEXT;
    v_IMN_WidthNumeric TEXT;
    v_IMN_ZeroPrefixFlag TEXT;
    v_IMN_PrefixAcadYearCode TEXT;
    v_IMN_PrefixParticular TEXT;
    v_IMN_StartingNo TEXT;
    v_IMN_RestartNumFlag TEXT;
    v_AMST_Admno TEXT;
    v_AMST_RegistrationNo TEXT;
    v_admno TEXT;
    v_yearname TEXT;
    v_admnoexisting TEXT;
    v_maxamstid TEXT;
    v_maxadmno TEXT;
    v_rowcount INTEGER;
    v_split_result TEXT;
    exmcursor CURSOR FOR
        SELECT "IMN_Flag", "IMN_AutoManualFlag", "IMN_WidthNumeric", "IMN_ZeroPrefixFlag", 
               "IMN_PrefixAcadYearCode", "IMN_PrefixParticular", "IMN_StartingNo", "IMN_RestartNumFlag" 
        FROM "IVRM_Master_Numbering" 
        WHERE "MI_Id" = p_MI_Id;
BEGIN

    SELECT "ASMAY_Year" INTO v_yearname 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_Year;

    OPEN exmcursor;

    LOOP
        FETCH exmcursor INTO v_IMN_Flag, v_IMN_AutoManualFlag, v_IMN_WidthNumeric, v_IMN_ZeroPrefixFlag, 
                             v_IMN_PrefixAcadYearCode, v_IMN_PrefixParticular, v_IMN_StartingNo, v_IMN_RestartNumFlag;
        
        EXIT WHEN NOT FOUND;

        IF v_IMN_Flag = 'Fee end user' THEN

            IF v_IMN_AutoManualFlag = 'Manual' THEN
                v_admno := '';
            ELSE
                IF v_IMN_PrefixAcadYearCode = '1' THEN
                    v_admno := v_yearname;
                ELSE
                    v_admno := v_IMN_PrefixParticular;
                END IF;

                IF (v_IMN_WidthNumeric IS NOT NULL AND LENGTH(v_IMN_WidthNumeric) > 0) THEN
                    IF v_IMN_ZeroPrefixFlag = 'Yes' THEN
                        IF (v_IMN_StartingNo IS NOT NULL AND LENGTH(v_IMN_StartingNo) > 0) THEN
                            v_admno := v_admno || '/' || LPAD(RTRIM(v_IMN_StartingNo), v_IMN_WidthNumeric::INTEGER, '0');
                        ELSE
                            v_IMN_StartingNo := '0';
                            v_admno := v_admno || '/' || LPAD(RTRIM(v_IMN_StartingNo), v_IMN_WidthNumeric::INTEGER, '0');
                        END IF;
                    END IF;
                ELSE
                    IF (v_IMN_StartingNo IS NOT NULL AND LENGTH(v_IMN_StartingNo) > 0) THEN
                        v_admno := v_admno || '/' || v_IMN_StartingNo;
                    END IF;
                END IF;

                IF v_IMN_RestartNumFlag = 'Never' THEN
                    SELECT COUNT(*) INTO v_rowcount 
                    FROM "Adm_M_Student" 
                    WHERE "MI_Id" = p_MI_Id AND "AMST_AdmNo" = v_admno;
                ELSE
                    SELECT COUNT(*) INTO v_rowcount 
                    FROM "Adm_M_Student" 
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_Year AND "AMST_AdmNo" = v_admno;
                END IF;

                IF v_rowcount > 0 THEN
                    IF v_IMN_RestartNumFlag = 'Never' THEN
                        SELECT MAX("amst_id"), "Amst_Admno" INTO v_maxamstid, v_admnoexisting 
                        FROM "Adm_M_Student" 
                        WHERE "MI_Id" = p_MI_Id 
                        GROUP BY "Amst_Admno"
                        ORDER BY MAX("amst_id") DESC
                        LIMIT 1;
                    ELSE
                        SELECT MAX("amst_id"), "Amst_Admno" INTO v_maxamstid, v_admnoexisting 
                        FROM "Adm_M_Student" 
                        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_Year 
                        GROUP BY "Amst_Admno"
                        ORDER BY MAX("amst_id") DESC
                        LIMIT 1;
                    END IF;

                    SELECT items INTO v_maxadmno 
                    FROM (
                        SELECT items, ROW_NUMBER() OVER(ORDER BY id) AS row 
                        FROM "Split"(v_admnoexisting, '/')
                    ) AS temp 
                    WHERE row = 2;

                    v_maxadmno := (v_maxadmno::INTEGER + 1)::TEXT;
                    v_maxadmno := LPAD(RTRIM(v_maxadmno), v_IMN_WidthNumeric::INTEGER, '0');
                    v_AMST_Admno := v_yearname || '/' || v_maxadmno;
                ELSE
                    v_AMST_Admno := v_admno;
                END IF;
            END IF;

            UPDATE "Adm_M_Student" 
            SET "AMST_AdmNo" = v_AMST_Admno 
            WHERE "AMST_Id" = p_AMST_Id AND "MI_Id" = p_MI_Id;

        END IF;

    END LOOP;

    CLOSE exmcursor;

    RETURN;
END;
$$;