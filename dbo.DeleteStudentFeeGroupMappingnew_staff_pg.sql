CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMappingnew_staff"(
    p_mi_id BIGINT,
    p_HRME_Id BIGINT,
    p_asmay_id BIGINT,
    p_fmg_id BIGINT,
    p_fmsg_id BIGINT,
    p_fmh_id BIGINT,
    p_fti_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount INTEGER;
    v_check_rowcount INTEGER;
BEGIN

    SELECT COUNT(*) INTO v_rowcount
    FROM "Fee_Student_Status_Staff" a
    INNER JOIN "Fee_Master_Staff_GroupHead" b ON a."HRME_Id" = b."HRME_Id" 
        AND a."ASMAY_Id" = b."ASMAY_Id" 
        AND a."MI_Id" = b."MI_Id" 
        AND a."FMG_Id" = b."FMG_Id"
    INNER JOIN "Fee_Master_Staff_GroupHead_Installments" c ON b."FMSTGH_Id" = c."FMSTGH_Id" 
        AND a."FMH_Id" = c."FMH_ID" 
        AND a."FTI_Id" = c."FTI_ID"
    WHERE b."MI_Id" = p_mi_id 
        AND b."ASMAY_Id" = p_asmay_id 
        AND b."HRME_Id" = p_HRME_Id 
        AND b."FMG_Id" = p_fmg_id 
        AND c."FMH_ID" = p_fmh_id 
        AND c."FTI_ID" = p_fti_id 
        AND "FSSST_PaidAmount" = 0;

    IF v_rowcount > 0 THEN

        DELETE FROM "Fee_Master_Staff_GroupHead_Installments" c
        USING "Fee_Student_Status_Staff" a
        INNER JOIN "Fee_Master_Staff_GroupHead" b ON a."HRME_Id" = b."HRME_Id" 
            AND a."ASMAY_Id" = b."ASMAY_Id" 
            AND a."MI_Id" = b."MI_Id" 
            AND a."FMG_Id" = b."FMG_Id"
        WHERE c."FMSTGH_Id" = b."FMSTGH_Id" 
            AND a."FMH_Id" = c."FMH_ID" 
            AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_mi_id 
            AND b."ASMAY_Id" = p_asmay_id 
            AND b."HRME_Id" = p_HRME_Id 
            AND b."FMG_Id" = p_fmg_id 
            AND c."FMH_ID" = p_fmh_id 
            AND c."FTI_ID" = p_fti_id 
            AND a."FSSST_PaidAmount" = 0;

        DELETE FROM "Fee_Student_Status_Staff" 
        WHERE "MI_Id" = p_mi_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "HRME_Id" = p_HRME_Id 
            AND "FMG_Id" = p_fmg_id 
            AND "FMH_ID" = p_fmh_id 
            AND "FTI_ID" = p_fti_id 
            AND "FSSST_PaidAmount" = 0;

        SELECT COUNT(*) INTO v_check_rowcount
        FROM "Fee_Master_Staff_GroupHead_Installments" 
        WHERE "FMSTGH_Id" IN (
            SELECT "FMSTGH_Id" 
            FROM "Fee_Master_Staff_GroupHead" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "HRME_Id" = p_HRME_Id
        );

        IF v_check_rowcount = 0 THEN
            DELETE FROM "Fee_Master_Staff_GroupHead" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "HRME_Id" = p_HRME_Id;
        END IF;

    END IF;

    RETURN;

END;
$$;