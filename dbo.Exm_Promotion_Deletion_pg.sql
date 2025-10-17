CREATE OR REPLACE FUNCTION "dbo"."Exm_Promotion_Deletion"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_EYC_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMCA_Id int;
BEGIN
    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id 
        AND "asmay_id" = p_ASMAY_Id 
        AND "EYC_ActiveFlg" = true 
        AND "EYC_Id" = p_EYC_Id;

    PERFORM DISTINCT "ASMCL_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "EMCA_Id" = v_EMCA_Id 
        AND "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ECAC_ActiveFlag" = true;

    DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" 
    WHERE "ESTMPPSG_Id" IN (
        SELECT DISTINCT "ESTMPPSG_Id" 
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" 
        WHERE "ESTMPPS_Id" IN (
            SELECT DISTINCT "ESTMPPS_Id" 
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "ASMCL_Id" IN (
                    SELECT DISTINCT "ASMCL_Id" 
                    FROM "Exm"."Exm_Category_Class" 
                    WHERE "EMCA_Id" = v_EMCA_Id 
                        AND "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "ECAC_ActiveFlag" = true
                )
        )
        AND "EMPSG_Id" IN (
            SELECT DISTINCT "EMPSG_Id" 
            FROM "Exm"."Exm_M_Prom_Subj_Group" 
            WHERE "EMPS_Id" IN (
                SELECT DISTINCT "EMPS_Id" 
                FROM "Exm"."Exm_M_Promotion_Subjects" 
                WHERE "EMP_Id" IN (
                    SELECT DISTINCT "EMP_Id" 
                    FROM "Exm"."Exm_M_Promotion" 
                    WHERE "EYC_Id" = p_EYC_Id 
                        AND "MI_Id" = p_MI_Id
                )
            )
        )
    );

    DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" 
    WHERE "ESTMPPS_Id" IN (
        SELECT DISTINCT "ESTMPPS_Id" 
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" IN (
                SELECT DISTINCT "ASMCL_Id" 
                FROM "Exm"."Exm_Category_Class" 
                WHERE "EMCA_Id" = v_EMCA_Id 
                    AND "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "ECAC_ActiveFlag" = true
            )
    )
    AND "EMPSG_Id" IN (
        SELECT DISTINCT "EMPSG_Id" 
        FROM "Exm"."Exm_M_Prom_Subj_Group" 
        WHERE "EMPS_Id" IN (
            SELECT DISTINCT "EMPS_Id" 
            FROM "Exm"."Exm_M_Promotion_Subjects" 
            WHERE "EMP_Id" IN (
                SELECT DISTINCT "EMP_Id" 
                FROM "Exm"."Exm_M_Promotion" 
                WHERE "EYC_Id" = p_EYC_Id 
                    AND "MI_Id" = p_MI_Id
            )
        )
    );

    DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" IN (
            SELECT DISTINCT "ASMCL_Id" 
            FROM "Exm"."Exm_Category_Class" 
            WHERE "EMCA_Id" = v_EMCA_Id 
                AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "ECAC_ActiveFlag" = true
        );

    DELETE FROM "Exm"."Exm_Student_MP_Promotion" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" IN (
            SELECT DISTINCT "ASMCL_Id" 
            FROM "Exm"."Exm_Category_Class" 
            WHERE "EMCA_Id" = v_EMCA_Id 
                AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "ECAC_ActiveFlag" = true
        );

    DELETE FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
    WHERE "EMPSG_Id" IN (
        SELECT DISTINCT "EMPSG_Id"  
        FROM "Exm"."Exm_M_Prom_Subj_Group" 
        WHERE "EMPS_Id" IN (
            SELECT DISTINCT "EMPS_Id" 
            FROM "Exm"."Exm_M_Promotion_Subjects" 
            WHERE "EMP_Id" IN (
                SELECT DISTINCT "EMP_Id" 
                FROM "Exm"."Exm_M_Promotion" 
                WHERE "EYC_Id" = p_EYC_Id 
                    AND "MI_Id" = p_MI_Id
            )
        )
    );

    DELETE FROM "Exm"."Exm_M_Prom_Subj_Group" 
    WHERE "EMPS_Id" IN (
        SELECT DISTINCT "EMPS_Id" 
        FROM "Exm"."Exm_M_Promotion_Subjects" 
        WHERE "EMP_Id" IN (
            SELECT DISTINCT "EMP_Id" 
            FROM "Exm"."Exm_M_Promotion" 
            WHERE "EYC_Id" = p_EYC_Id 
                AND "MI_Id" = p_MI_Id
        )
    );

    DELETE FROM "Exm"."Exm_M_Promotion_Subjects" 
    WHERE "EMP_Id" IN (
        SELECT DISTINCT "EMP_Id" 
        FROM "Exm"."Exm_M_Promotion" 
        WHERE "EYC_Id" = p_EYC_Id 
            AND "MI_Id" = p_MI_Id
    );

    DELETE FROM "Exm"."Exm_M_Promotion" 
    WHERE "EYC_Id" = p_EYC_Id;

    RETURN;
END;
$$;