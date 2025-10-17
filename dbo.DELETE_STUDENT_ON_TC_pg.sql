CREATE OR REPLACE FUNCTION "dbo"."DELETE_STUDENT_ON_TC"(
    "p_MI_ID" BIGINT,
    "p_ASMAY_ID" BIGINT,
    "p_AMST_ID" BIGINT,
    "p_flag" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_siblingamstid" BIGINT;
    "v_siblingamstidorder" BIGINT;
    "v_AMSTS_Siblings_AMST_ID" BIGINT;
    "v_revisedorder" BIGINT;
    "v_AMSTS_SiblingsOrder" BIGINT;
    "v_SIBLINGAMOUNT" BIGINT;
    "v_AMST_Concession_Type" BIGINT;
    "v_FMCCD_PerOrAmtFlag" TEXT;
    "v_FSCI_ID" BIGINT;
    "v_FMG_ID" BIGINT;
    "v_FMH_ID" BIGINT;
    "v_FTI_ID" BIGINT;
    "v_FSS_CurrentYrCharges" BIGINT;
    "v_CONCESSIONAMOUNT" BIGINT;
    "v_COMMONAMSTID" BIGINT;
    "v_ACTUALAMSTID" BIGINT;
    "v_UPDATEAMSTTCORDER" BIGINT;
    "v_COMMONHRMEID" BIGINT;
    "v_HRME_ID" BIGINT;
    "v_sibordernew" BIGINT;
    "v_newcomonamst" BIGINT;
    "rec_FeeYearlyConcession" RECORD;
    "rec_deletestuconInst" RECORD;
    "rec_yearly_fee" RECORD;
BEGIN

    SELECT "AMSTS_SiblingsOrder", "AMST_Id" 
    INTO "v_sibordernew", "v_newcomonamst"
    FROM "Adm_Master_Student_SiblingsDetails" 
    WHERE "AMSTS_Siblings_AMST_ID" = "p_AMST_ID";

    IF ("p_flag" = 'S' OR "p_flag" = 'R') THEN
    
        FOR "rec_FeeYearlyConcession" IN
            SELECT "FMG_Id", "FMH_Id", "FTI_Id", "FSS_ConcessionAmount", "AMSTS_Siblings_AMST_ID" 
            FROM "Fee_Student_Status" 
            INNER JOIN "Adm_Master_Student_SiblingsDetails" ON 
                "Fee_Student_Status"."AMST_Id" = "Adm_Master_Student_SiblingsDetails"."AMSTS_Siblings_AMST_ID" 
            WHERE "Fee_Student_Status"."MI_Id" = "p_MI_ID" 
                AND "ASMAY_Id" = "p_ASMAY_ID" 
                AND "Adm_Master_Student_SiblingsDetails"."AMST_Id" = "v_newcomonamst" 
                AND "FSS_PaidAmount" = 0 
                AND "FSS_ConcessionAmount" > 0 
            ORDER BY "Adm_Master_Student_SiblingsDetails"."AMST_Id"
        LOOP
            "v_FMG_ID" := "rec_FeeYearlyConcession"."FMG_Id";
            "v_FMH_ID" := "rec_FeeYearlyConcession"."FMH_Id";
            "v_FTI_ID" := "rec_FeeYearlyConcession"."FTI_Id";
            "v_CONCESSIONAMOUNT" := "rec_FeeYearlyConcession"."FSS_ConcessionAmount";
            "v_ACTUALAMSTID" := "rec_FeeYearlyConcession"."AMSTS_Siblings_AMST_ID";

            FOR "rec_deletestuconInst" IN
                SELECT "FSCI_ID" 
                FROM "Fee_Student_Concession_Installments" 
                WHERE "FTI_Id" = "v_FTI_ID" 
                    AND "FSCI_FSC_Id" IN (
                        SELECT DISTINCT "FSC_ID" 
                        FROM "Fee_Student_Concession" 
                        WHERE "AMST_Id" = "v_ACTUALAMSTID" 
                            AND "FMG_Id" = "v_FMG_ID" 
                            AND "FMH_Id" = "v_FMH_ID" 
                            AND "MI_Id" = "p_MI_ID" 
                            AND "ASMAY_ID" = "p_ASMAY_ID"
                    )
            LOOP
                "v_FSCI_ID" := "rec_deletestuconInst"."FSCI_ID";
                DELETE FROM "Fee_Student_Concession_Installments" WHERE "FSCI_ID" = "v_FSCI_ID";
            END LOOP;

            DELETE FROM "Fee_Student_Concession" 
            WHERE "AMST_Id" = "v_ACTUALAMSTID" 
                AND "FMG_ID" = "v_FMG_ID" 
                AND "FMH_ID" = "v_FMH_ID" 
                AND "MI_Id" = "p_MI_ID" 
                AND "ASMAY_ID" = "p_ASMAY_ID";

            UPDATE "Fee_Student_Status" 
            SET "FSS_ConcessionAmount" = "FSS_ConcessionAmount" - "v_CONCESSIONAMOUNT",
                "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + "v_CONCESSIONAMOUNT",
                "FSS_ToBePaid" = "FSS_ToBePaid" + "v_CONCESSIONAMOUNT" 
            WHERE "AMST_Id" = "v_ACTUALAMSTID" 
                AND "FMG_Id" = "v_FMG_ID" 
                AND "FMH_Id" = "v_FMH_ID" 
                AND "FTI_Id" = "v_FTI_ID" 
                AND "MI_Id" = "p_MI_ID" 
                AND "ASMAY_Id" = "p_ASMAY_ID";
        END LOOP;

        "v_revisedorder" := 0;

        UPDATE "Adm_Master_Student_SiblingsDetails" 
        SET "AMSTS_TCIssuesFlag" = 1 
        WHERE "AMSTS_Siblings_AMST_ID" = "p_AMST_ID";

        SELECT "AMST_Id", "AMSTS_SiblingsOrder" 
        INTO "v_siblingamstid", "v_siblingamstidorder"
        FROM "Adm_Master_Student_SiblingsDetails" 
        WHERE "AMSTS_Siblings_AMST_ID" = "p_AMST_ID";

        "v_revisedorder" := "v_siblingamstidorder";

        FOR "rec_yearly_fee" IN
            SELECT "AMSTS_Siblings_AMST_ID" 
            FROM "Adm_Master_Student_SiblingsDetails" 
            WHERE "AMST_Id" = "v_siblingamstid" 
                AND "AMSTS_TCIssuesFlag" = 0 
                AND "AMSTS_SiblingsOrder" > "v_siblingamstidorder" 
            ORDER BY "AMSTS_SiblingsOrder"
        LOOP
            "v_AMSTS_Siblings_AMST_ID" := "rec_yearly_fee"."AMSTS_Siblings_AMST_ID";

            UPDATE "Adm_Master_Student_SiblingsDetails" 
            SET "AMSTS_SiblingsOrder" = "v_revisedorder" 
            WHERE "AMSTS_Siblings_AMST_ID" = "v_AMSTS_Siblings_AMST_ID" 
                AND "MI_Id" = "p_MI_ID";

            "v_revisedorder" := "v_revisedorder" + 1;
        END LOOP;

        IF "v_sibordernew" = 1 THEN
            SELECT "AMSTS_Siblings_AMST_ID" 
            INTO "v_COMMONAMSTID"
            FROM "Adm_Master_Student_SiblingsDetails" 
            WHERE "AMSTS_SiblingsOrder" = 1 
                AND "AMSTS_TCIssuesFlag" = 0  
                AND "AMST_Id" = "p_AMST_ID";
                
            UPDATE "Adm_Master_Student_SiblingsDetails" 
            SET "AMST_Id" = "v_COMMONAMSTID" 
            WHERE "AMST_Id" = "p_AMST_ID" 
                AND "AMSTS_TCIssuesFlag" = 0;

            PERFORM "dbo"."SAVE_CONCESSION_FOR_SIBLINGS_FIRST"("p_MI_ID", "p_ASMAY_ID", "v_COMMONAMSTID", 0, 'stud');

        ELSIF "v_sibordernew" > 1 THEN
            SELECT "AMST_Id" 
            INTO "v_COMMONAMSTID"
            FROM "Adm_Master_Student_SiblingsDetails" 
            WHERE "AMSTS_Siblings_AMST_ID" = "p_AMST_ID";

            SELECT "AMSTS_Siblings_AMST_ID" 
            INTO "v_UPDATEAMSTTCORDER"
            FROM "Adm_Master_Student_SiblingsDetails" 
            WHERE "AMST_Id" = "v_COMMONAMSTID" 
                AND "AMSTS_SiblingsOrder" = 1;

            UPDATE "Adm_Master_Student_SiblingsDetails" 
            SET "AMST_Id" = "v_UPDATEAMSTTCORDER" 
            WHERE "AMST_Id" = "v_COMMONAMSTID" 
                AND "AMSTS_TCIssuesFlag" = 0;

            RAISE NOTICE '%', "v_siblingamstid";
            PERFORM "dbo"."SAVE_CONCESSION_FOR_SIBLINGS"("p_MI_ID", "p_ASMAY_ID", "v_siblingamstid", 0, 'stud');
        END IF;

    END IF;

    IF ("p_flag" = 'E') THEN
        UPDATE "Adm_M_Student_EmployeeDetails" 
        SET "AMSTE_Left" = 1 
        WHERE "AMST_Id" = "p_AMST_ID";

        SELECT "AMST_Id", "AMSTE_SiblingsOrder", "HRME_Id" 
        INTO "v_siblingamstid", "v_siblingamstidorder", "v_HRME_ID"
        FROM "Adm_M_Student_EmployeeDetails" 
        WHERE "AMST_Id" = "p_AMST_ID";

        "v_revisedorder" := "v_siblingamstidorder";

        FOR "rec_yearly_fee" IN
            SELECT "AMST_Id" 
            FROM "Adm_M_Student_EmployeeDetails" 
            WHERE "AMST_Id" = "v_siblingamstid" 
                AND "AMSTE_Left" = 0 
                AND "AMSTE_SiblingsOrder" > "v_siblingamstidorder" 
            ORDER BY "AMSTE_SiblingsOrder"
        LOOP
            "v_AMSTS_Siblings_AMST_ID" := "rec_yearly_fee"."AMST_Id";

            UPDATE "Adm_M_Student_EmployeeDetails" 
            SET "AMSTE_SiblingsOrder" = "v_revisedorder" 
            WHERE "AMST_Id" = "v_AMSTS_Siblings_AMST_ID";

            "v_revisedorder" := "v_revisedorder" + 1;
        END LOOP;

        SELECT "HRME_Id" 
        INTO "v_COMMONHRMEID"
        FROM "Adm_M_Student_EmployeeDetails" 
        WHERE "AMST_Id" = "p_AMST_ID";

        FOR "rec_FeeYearlyConcession" IN
            SELECT "FMG_Id", "FMH_Id", "FTI_Id", "FSS_ConcessionAmount", "Adm_M_Student_EmployeeDetails"."AMST_Id" 
            FROM "Fee_Student_Status" 
            INNER JOIN "Adm_M_Student_EmployeeDetails" ON 
                "Fee_Student_Status"."AMST_Id" = "Adm_M_Student_EmployeeDetails"."AMST_Id" 
            WHERE "Fee_Student_Status"."MI_Id" = "p_MI_ID" 
                AND "ASMAY_Id" = "p_ASMAY_ID" 
                AND "Adm_M_Student_EmployeeDetails"."AMST_Id" = "p_AMST_ID" 
                AND "FSS_PaidAmount" = 0 
                AND "FSS_ConcessionAmount" > 0
        LOOP
            "v_FMG_ID" := "rec_FeeYearlyConcession"."FMG_Id";
            "v_FMH_ID" := "rec_FeeYearlyConcession"."FMH_Id";
            "v_FTI_ID" := "rec_FeeYearlyConcession"."FTI_Id";
            "v_CONCESSIONAMOUNT" := "rec_FeeYearlyConcession"."FSS_ConcessionAmount";
            "v_ACTUALAMSTID" := "rec_FeeYearlyConcession"."AMST_Id";

            FOR "rec_deletestuconInst" IN
                SELECT "FSCI_ID" 
                FROM "Fee_Student_Concession_Installments" 
                WHERE "FTI_Id" = "v_FTI_ID" 
                    AND "FSCI_FSC_Id" IN (
                        SELECT DISTINCT "FSC_ID" 
                        FROM "Fee_Student_Concession" 
                        WHERE "AMST_Id" = "v_ACTUALAMSTID" 
                            AND "FMG_Id" = "v_FMG_ID" 
                            AND "FMH_Id" = "v_FMH_ID" 
                            AND "MI_Id" = "p_MI_ID" 
                            AND "ASMAY_ID" = "p_ASMAY_ID"
                    )
            LOOP
                "v_FSCI_ID" := "rec_deletestuconInst"."FSCI_ID";
                DELETE FROM "Fee_Student_Concession_Installments" WHERE "FSCI_ID" = "v_FSCI_ID";
            END LOOP;

            DELETE FROM "Fee_Student_Concession" 
            WHERE "AMST_Id" = "v_ACTUALAMSTID" 
                AND "FMG_ID" = "v_FMG_ID" 
                AND "FMH_ID" = "v_FMH_ID" 
                AND "MI_Id" = "p_MI_ID" 
                AND "ASMAY_ID" = "p_ASMAY_ID";

            UPDATE "Fee_Student_Status" 
            SET "FSS_ConcessionAmount" = "FSS_ConcessionAmount" - "v_CONCESSIONAMOUNT",
                "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + "v_CONCESSIONAMOUNT",
                "FSS_ToBePaid" = "FSS_ToBePaid" + "v_CONCESSIONAMOUNT" 
            WHERE "AMST_Id" = "v_ACTUALAMSTID" 
                AND "FMG_Id" = "v_FMG_ID" 
                AND "FMH_Id" = "v_FMH_ID" 
                AND "FTI_Id" = "v_FTI_ID" 
                AND "MI_Id" = "p_MI_ID" 
                AND "ASMAY_Id" = "p_ASMAY_ID";
        END LOOP;

    END IF;

END;
$$;