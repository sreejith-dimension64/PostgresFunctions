CREATE OR REPLACE FUNCTION "dbo"."GetStudentStatusOverallCountReport_clg"(
    "p_ASMAY_Ids" TEXT,
    "p_AMCO_Ids" TEXT,
    "p_Mi_id" BIGINT,
    "p_type_" TEXT,
    "p_all" TEXT
)
RETURNS TABLE(
    "applAll" BIGINT,
    "applWaiting" BIGINT,
    "applRejected" BIGINT,
    "applAccepted" BIGINT,
    "admAll" BIGINT,
    "admWaiting" BIGINT,
    "admSelected" BIGINT,
    "admInprogress" BIGINT,
    "admRejected" BIGINT,
    "admConfirm" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqlexec" TEXT;
    "v_payment_flag" INT;
    "v_applRejected" BIGINT;
    "v_applWaiting" BIGINT;
    "v_applAccepted" BIGINT;
    "v_applAll" BIGINT;
    "v_admRejected" BIGINT;
    "v_admWaiting" BIGINT;
    "v_admConfirm" BIGINT;
    "v_admInprogress" BIGINT;
    "v_admSelected" BIGINT;
    "v_admAll" BIGINT;
BEGIN

    SELECT COALESCE("ISPAC_ApplFeeFlag", 0) INTO "v_payment_flag"
    FROM "IVRM_School_Preadmission_Configuration"
    WHERE "MI_Id" = "p_Mi_id" AND "ASMAY_Id" = "p_ASMAY_Ids";

    IF "p_type_" = 'Appsts' THEN
        IF "v_payment_flag" = 1 THEN
            IF "p_all" = 'ALL' THEN
                SELECT COUNT("r"."paca_id") INTO "v_applAll"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787926' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787927' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applAccepted"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787928' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            ELSE
                SELECT COUNT("r"."paca_id") INTO "v_applWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787926' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787927' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applAccepted"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787928' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            END IF;
        ELSE
            IF "p_all" = 'ALL' THEN
                SELECT COUNT("r"."paca_id") INTO "v_applAll"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids";

                SELECT COUNT("r"."paca_id") INTO "v_applWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787926' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787927' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applAccepted"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787928' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            ELSE
                SELECT COUNT("r"."paca_id") INTO "v_applWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787926' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787927' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_applAccepted"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_ApplStatus" = '787928' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            END IF;
        END IF;
    ELSIF "p_type_" = 'admsts' THEN
        IF "v_payment_flag" = 1 THEN
            IF "p_all" = 'ALL' THEN
                SELECT COUNT("r"."paca_id") INTO "v_admInprogress"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admInprogress"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '1' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admSelected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '2' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '3' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '4' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admConfirm"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '5' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            ELSE
                SELECT COUNT("r"."paca_id") INTO "v_admInprogress"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '1' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admSelected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '2' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '3' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '4' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admConfirm"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '5' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            END IF;
        ELSE
            IF "p_all" = 'ALL' THEN
                SELECT COUNT("r"."paca_id") INTO "v_admAll"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids";

                SELECT COUNT("r"."paca_id") INTO "v_admInprogress"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '1' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admSelected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '2' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '3' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '4' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admConfirm"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '5' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            ELSE
                SELECT COUNT("r"."paca_id") INTO "v_admInprogress"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '1' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admSelected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '2' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admWaiting"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '3' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admRejected"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '4' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";

                SELECT COUNT("r"."paca_id") INTO "v_admConfirm"
                FROM "clg"."PA_College_Application" "r"
                LEFT JOIN "CLG"."Adm_Master_Course" "c" ON "r"."AMCO_Id" = "c"."AMCO_Id"
                LEFT JOIN "CLG"."Fee_Y_Payment_PA_Application" "f" ON "f"."PACA_Id" = "r"."PACA_Id"
                WHERE "r"."PACA_AdmStatus" = '5' AND "r"."AMCO_Id" = "p_AMCO_Ids" AND "r"."ASMAY_Id" = "p_ASMAY_Ids" AND "r"."MI_Id" = "p_Mi_id";
            END IF;
        END IF;
    END IF;

    IF "p_type_" = 'Appsts' THEN
        RETURN QUERY SELECT "v_applAll", "v_applWaiting", "v_applRejected", "v_applAccepted", NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT;
    ELSIF "p_type_" = 'admsts' THEN
        RETURN QUERY SELECT NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, "v_admAll", "v_admWaiting", "v_admSelected", "v_admInprogress",