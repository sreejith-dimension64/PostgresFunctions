CREATE OR REPLACE FUNCTION "dbo"."Adm_Generating_Admno_New"(
    p_MI_Id bigint,
    p_Year bigint,
    p_AMST_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_IMN_Flag text;
    v_IMN_AutoManualFlag text;
    v_IMN_WidthNumeric text;
    v_IMN_ZeroPrefixFlag text;
    v_IMN_PrefixAcadYearCode text;
    v_IMN_PrefixParticular text;
    v_IMN_StartingNo text;
    v_IMN_RestartNumFlag text;
    v_AMST_Admno text;
    v_AMST_RegistrationNo text;
    v_admno text;
    v_yearname text;
    v_admnoexisting text;
    v_maxamstid text;
    v_maxadmno text;
    v_row_count integer;
    v_temp_items text;
    exmcursor CURSOR FOR
        SELECT "IMN_Flag", "IMN_AutoManualFlag", "IMN_WidthNumeric", "IMN_ZeroPrefixFlag", 
               "IMN_PrefixAcadYearCode", "IMN_PrefixParticular", "IMN_StartingNo", "IMN_RestartNumFlag"
        FROM "IVRM_Master_Numbering"
        WHERE "MI_Id" = p_MI_Id;
BEGIN

    SELECT "ASMAY_Year" INTO v_yearname
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_Year;

    FOR v_IMN_Flag, v_IMN_AutoManualFlag, v_IMN_WidthNumeric, v_IMN_ZeroPrefixFlag,
        v_IMN_PrefixAcadYearCode, v_IMN_PrefixParticular, v_IMN_StartingNo, v_IMN_RestartNumFlag IN
        SELECT "IMN_Flag", "IMN_AutoManualFlag", "IMN_WidthNumeric", "IMN_ZeroPrefixFlag", 
               "IMN_PrefixAcadYearCode", "IMN_PrefixParticular", "IMN_StartingNo", "IMN_RestartNumFlag"
        FROM "IVRM_Master_Numbering"
        WHERE "MI_Id" = p_MI_Id
    LOOP

        IF v_IMN_Flag = 'Admission' THEN
        
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
                            v_admno := v_admno || '/' || LPAD(RTRIM(v_IMN_StartingNo), v_IMN_WidthNumeric::integer, '0');
                        ELSE
                            v_IMN_StartingNo := '0';
                            v_admno := v_admno || '/' || LPAD(RTRIM(v_IMN_StartingNo), v_IMN_WidthNumeric::integer, '0');
                        END IF;
                    END IF;
                ELSE
                    IF (v_IMN_StartingNo IS NOT NULL AND LENGTH(v_IMN_StartingNo) > 0) THEN
                        v_admno := v_admno || '/' || v_IMN_StartingNo;
                    END IF;
                END IF;

                IF v_IMN_RestartNumFlag = 'Never' THEN
                    SELECT COUNT(*) INTO v_row_count
                    FROM "Adm_M_Student"
                    WHERE "MI_Id" = p_MI_Id AND "AMST_AdmNo" = v_admno;
                ELSE
                    SELECT COUNT(*) INTO v_row_count
                    FROM "Adm_M_Student"
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_Year AND "AMST_AdmNo" = v_admno;
                END IF;

                IF v_row_count > 0 THEN
                    
                    IF v_IMN_RestartNumFlag = 'Never' THEN
                        SELECT MAX("amst_id")::text, "Amst_Admno" INTO v_maxamstid, v_admnoexisting
                        FROM "Adm_M_Student"
                        WHERE "MI_Id" = p_MI_Id
                        GROUP BY "Amst_Admno"
                        ORDER BY MAX("amst_id") DESC
                        LIMIT 1;
                    ELSE
                        SELECT MAX("amst_id")::text, "Amst_Admno" INTO v_maxamstid, v_admnoexisting
                        FROM "Adm_M_Student"
                        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_Year
                        GROUP BY "Amst_Admno"
                        ORDER BY MAX("amst_id") DESC
                        LIMIT 1;
                    END IF;

                    SELECT "items" INTO v_maxadmno
                    FROM (
                        SELECT unnest(string_to_array(v_admnoexisting, '/')) AS "items",
                               ROW_NUMBER() OVER (ORDER BY generate_series(1, array_length(string_to_array(v_admnoexisting, '/'), 1))) AS "row"
                    ) AS temp
                    WHERE "row" = 2;

                    v_maxadmno := (v_maxadmno::integer + 1)::text;
                    v_maxadmno := LPAD(RTRIM(v_maxadmno), v_IMN_WidthNumeric::integer, '0');
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

    RETURN;

END;
$$;