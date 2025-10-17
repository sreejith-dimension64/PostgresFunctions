CREATE OR REPLACE FUNCTION "Exm"."Exm_PromotionDetails_Delete"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" 
    WHERE "ESTMPPSG_Id" IN (
        SELECT "ESTMPPSG_Id" 
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" 
        WHERE "ESTMPPS_Id" IN (
            SELECT "ESTMPPS_Id" 
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id
        )
    );

    DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" 
    WHERE "ESTMPPS_Id" IN (
        SELECT "ESTMPPS_Id" 
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id
    );

    DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Examwise" 
    WHERE "ESTMPPS_Id" IN (
        SELECT "ESTMPPS_Id" 
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id
    );

    DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id;

END;
$$;