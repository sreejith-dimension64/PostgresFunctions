CREATE OR REPLACE FUNCTION "dbo"."BCEHS_IVInstallmentConcessionRecords_Insert"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_AMST_Id" bigint;
    "v_SGCount" bigint;
    "v_FMSG_Id" bigint;
    "v_SGICount" bigint;
    "v_ASMCL_Id" bigint;
    "v_FMA_Id" bigint;
    "v_FMA_Amount" bigint;
    "v_StatusRcount" bigint;
    "v_Rcount" bigint;
    "v_FMC_Id" bigint;
    "v_Rcount1" bigint;
    "v_FSC_Id" bigint;
    "v_FMH_Id" bigint;
    "v_FTI_Id" bigint;
    "v_FSS_TotalTobePaid" bigint;
    "v_ConcessionAmount" bigint;
    "v_FYCC_Id" bigint;
    "v_FMCC_Id" bigint;
    "v_Term1" bigint;
    "v_Term2" bigint;
    "v_Term3" bigint;
    "v_Term4" bigint;
    "v_CY_FYCC_Id" bigint;
    "v_GConStudent" bigint;
    "v_ConcessionAmount_H" integer;
    "v_ConcessionAmount_N" bigint;
    "rec_class_category" RECORD;
    "rec_studentlist" RECORD;
    "rec_studentwise" RECORD;
BEGIN

    "v_FSS_TotalTobePaid" := 0;

    FOR "rec_studentlist" IN 
        SELECT DISTINCT "AMST_Id" 
        FROM "Adm_M_Student" 
        WHERE "Admissionno" IN (
            SELECT DISTINCT "Admissionno" 
            FROM "dbo"."BCEHS_9thAlltermsPaidStudents_Temp"
        ) 
        AND "MI_Id" = 5 
        AND "amst_sol" = 'S' 
        AND "AMST_ActiveFlag" = 1 
        AND "AMST_Id" = 3290
    LOOP
        "v_AMST_Id" := "rec_studentlist"."AMST_Id";

        "v_ConcessionAmount" := 10000;

        SELECT DISTINCT "FYCC"."FYCC_Id" INTO "v_CY_FYCC_Id"
        FROM "Adm_School_Y_Student" "ASYS"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" "FYCCC" ON "ASYS"."ASMCL_Id" = "FYCCC"."ASMCL_Id"
        INNER JOIN "Fee_Yearly_Class_Category" "FYCC" ON "FYCC"."FYCC_Id" = "FYCCC"."FYCC_Id"
        WHERE "ASYS"."AMST_Id" = "v_AMST_Id" 
        AND "ASYS"."ASMAY_Id" = 75 
        AND "FYCC"."ASMAY_Id" = 75;

        RAISE NOTICE '%', "v_CY_FYCC_Id";

        FOR "rec_studentwise" IN
            SELECT DISTINCT "SS"."FMH_Id", "SS"."FTI_Id", "SS"."FSS_TotalTobePaid"
            FROM "Fee_Student_Status" "SS"
            INNER JOIN "Fee_master_Terms_FeeHeads" "FMTF" ON "FMTF"."FMH_Id" = "SS"."FMH_Id" 
                AND "FMTF"."FTI_Id" = "SS"."FTI_Id" 
                AND "FMTF"."MI_Id" = 5
            WHERE "SS"."MI_Id" = 5 
            AND "SS"."ASMAY_Id" = 75 
            AND "SS"."FSS_PaidAmount" = 0 
            AND "FMTF"."FMT_Id" = 9 
            AND "FSS_CurrentYrCharges" <> 0 
            AND "FSS_ConcessionAmount" = 0
            AND "AMST_Id" IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "adm_school_y_student" 
                WHERE "ASMAY_Id" = 75 
                AND "amay_activeflag" = 1 
                AND "ASMCL_Id" IN (
                    SELECT DISTINCT "ASMCL_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "FYCC_Id" = "v_CY_FYCC_Id"
                )
            )
            AND "FMG_Id" IN (21) 
            AND "SS"."AMST_Id" = "v_AMST_Id"
        LOOP
            "v_FMH_Id" := "rec_studentwise"."FMH_Id";
            "v_FTI_Id" := "rec_studentwise"."FTI_Id";
            "v_FSS_TotalTobePaid" := "rec_studentwise"."FSS_TotalTobePaid";

            "v_Term1" := 0;
            "v_Term2" := 0;
            "v_Term3" := 0;
            "v_Term4" := 0;

            SELECT COUNT(*) INTO "v_Term1"
            FROM "Fee_Student_Status" "SS"
            INNER JOIN "Fee_master_Terms_FeeHeads" "FMTF" ON "FMTF"."FMH_Id" = "SS"."FMH_Id" 
                AND "FMTF"."FTI_Id" = "SS"."FTI_Id" 
                AND "FMTF"."MI_Id" = 5
            WHERE "SS"."MI_Id" = 5 
            AND "SS"."ASMAY_Id" = 63 
            AND "SS"."FSS_PaidAmount" <> 0 
            AND "FSS_CurrentYrCharges" <> 0 
            AND "FSS_TobePaid" = 0
            AND "FMG_Id" IN (21) 
            AND "SS"."AMST_Id" = "v_AMST_Id" 
            AND "FMTF"."FMT_Id" IN (9);

            SELECT COUNT(*) INTO "v_Term2"
            FROM "Fee_Student_Status" "SS"
            INNER JOIN "Fee_master_Terms_FeeHeads" "FMTF" ON "FMTF"."FMH_Id" = "SS"."FMH_Id" 
                AND "FMTF"."FTI_Id" = "SS"."FTI_Id" 
                AND "FMTF"."MI_Id" = 5
            WHERE "SS"."MI_Id" = 5 
            AND "SS"."ASMAY_Id" = 63 
            AND "SS"."FSS_PaidAmount" <> 0 
            AND "FSS_CurrentYrCharges" <> 0 
            AND "FSS_TobePaid" = 0
            AND "FMG_Id" IN (21) 
            AND "SS"."AMST_Id" = "v_AMST_Id" 
            AND "FMTF"."FMT_Id" IN (10);

            SELECT COUNT(*) INTO "v_Term3"
            FROM "Fee_Student_Status" "SS"
            INNER JOIN "Fee_master_Terms_FeeHeads" "FMTF" ON "FMTF"."FMH_Id" = "SS"."FMH_Id" 
                AND "FMTF"."FTI_Id" = "SS"."FTI_Id" 
                AND "FMTF"."MI_Id" = 5
            WHERE "SS"."MI_Id" = 5 
            AND "SS"."ASMAY_Id" = 63 
            AND "SS"."FSS_PaidAmount" <> 0 
            AND "FSS_CurrentYrCharges" <> 0 
            AND "FSS_TobePaid" = 0
            AND "FMG_Id" IN (21) 
            AND "SS"."AMST_Id" = "v_AMST_Id" 
            AND "FMTF"."FMT_Id" IN (11);

            SELECT COUNT(*) INTO "v_Term4"
            FROM "Fee_Student_Status" "SS"
            INNER JOIN "Fee_master_Terms_FeeHeads" "FMTF" ON "FMTF"."FMH_Id" = "SS"."FMH_Id" 
                AND "FMTF"."FTI_Id" = "SS"."FTI_Id" 
                AND "FMTF"."MI_Id" = 5
            WHERE "SS"."MI_Id" = 5 
            AND "SS"."ASMAY_Id" = 63 
            AND "SS"."FSS_PaidAmount" <> 0 
            AND "FSS_CurrentYrCharges" <> 0 
            AND "FSS_TobePaid" = 0
            AND "FMG_Id" IN (21) 
            AND "SS"."AMST_Id" = "v_AMST_Id" 
            AND "FMTF"."FMT_Id" IN (12);

            "v_GConStudent" := 0;

            SELECT COUNT(*) INTO "v_GConStudent" 
            FROM "Adm_M_Student" 
            WHERE "MI_Id" = 5 
            AND "AMST_SOL" = 'S' 
            AND "AMST_ActiveFlag" = 1 
            AND "AMST_Id" = "v_AMST_Id";

            IF ("v_GConStudent" <> 0) THEN
                IF ("v_FSS_TotalTobePaid" > "v_ConcessionAmount") AND "v_ConcessionAmount" <> 0 THEN
                    UPDATE "Fee_Student_Status" 
                    SET "FSS_ConcessionAmount" = "v_ConcessionAmount",
                        "FSS_ToBePaid" = "FSS_ToBePaid" - "v_ConcessionAmount" 
                    WHERE "AMST_Id" = "v_AMST_Id" 
                    AND "MI_Id" = 5 
                    AND "asmay_id" = 75 
                    AND "FMG_Id" = 21 
                    AND "FMH_Id" = "v_FMH_Id" 
                    AND "FTI_Id" = "v_FTI_Id";
                    
                    "v_ConcessionAmount" := 0;
                ELSE
                    IF ("v_ConcessionAmount" > "v_FSS_TotalTobePaid") AND "v_ConcessionAmount" <> 0 THEN
                        UPDATE "Fee_Student_Status" 
                        SET "FSS_ConcessionAmount" = "v_FSS_TotalTobePaid",
                            "FSS_ToBePaid" = "FSS_ToBePaid" - "v_FSS_TotalTobePaid" 
                        WHERE "AMST_Id" = "v_AMST_Id" 
                        AND "MI_Id" = 5 
                        AND "asmay_id" = 75 
                        AND "FMG_Id" = 21 
                        AND "FMH_Id" = "v_FMH_Id" 
                        AND "FTI_Id" = "v_FTI_Id";
                        
                        "v_ConcessionAmount" := "v_ConcessionAmount" - "v_FSS_TotalTobePaid";
                    END IF;
                END IF;

                "v_Rcount" := 0;

                SELECT COUNT(*) INTO "v_Rcount" 
                FROM "Fee_Student_Concession" 
                WHERE "MI_Id" = 5 
                AND "FMC_Id" = 1 
                AND "AMST_Id" = "v_AMST_Id" 
                AND "ASMAY_Id" = 75 
                AND "FMG_Id" = 21 
                AND "FMH_Id" = "v_FMH_Id";

                RAISE NOTICE '%', "v_Rcount";

                "v_ConcessionAmount_H" := 0;

                SELECT COALESCE(SUM("FSS_ConcessionAmount"), 0) INTO "v_ConcessionAmount_H"
                FROM "Fee_Student_Status" "SS"
                INNER JOIN "Fee_master_Terms_FeeHeads" "FMTF" ON "FMTF"."FMH_Id" = "SS"."FMH_Id" 
                    AND "FMTF"."FTI_Id" = "SS"."FTI_Id" 
                    AND "FMTF"."MI_Id" = 5
                WHERE "SS"."MI_Id" = 5 
                AND "SS"."ASMAY_Id" = 75 
                AND "SS"."FSS_PaidAmount" = 0 
                AND "FMTF"."FMT_Id" = 9 
                AND "FSS_CurrentYrCharges" <> 0
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "adm_school_y_student" 
                    WHERE "ASMAY_Id" = 75 
                    AND "amay_activeflag" = 1 
                    AND "ASMCL_Id" IN (
                        SELECT DISTINCT "ASMCL_Id" 
                        FROM "Fee_Yearly_Class_Category_Classes" 
                        WHERE "FYCC_Id" = "v_CY_FYCC_Id"
                    )
                )
                AND "FMG_Id" IN (21) 
                AND "SS"."AMST_Id" = "v_AMST_Id" 
                AND "SS"."FMH_Id" = "v_FMH_Id";

                IF ("v_Rcount" = 0) AND ("v_ConcessionAmount_H" <> 0) THEN
                    INSERT INTO "Fee_Student_Concession"(
                        "MI_Id", "FMC_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMH_Id", 
                        "FSC_ConcessionReason", "FSC_ConcessionType", "FMSG_ActiveFlag", 
                        "CreatedDate", "UpdatedDate"
                    ) 
                    VALUES(5, 1, "v_AMST_Id", 75, 21, "v_FMH_Id", 
                           'FEE CONCESSION', 'Amount', 1, 
                           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END IF;

                SELECT "FSC_Id" INTO "v_FSC_Id" 
                FROM "Fee_Student_Concession" 
                WHERE "MI_Id" = 5 
                AND "FMC_Id" = 1 
                AND "AMST_Id" = "v_AMST_Id" 
                AND "ASMAY_Id" = 75 
                AND "FMG_Id" = 21 
                AND "FMH_Id" = "v_FMH_Id" 
                ORDER BY "FSC_Id" DESC 
                LIMIT 1;

                "v_Rcount1" := 0;
                "v_ConcessionAmount_N" := 0;

                SELECT COALESCE("FSS_ConcessionAmount", 0) INTO "v_ConcessionAmount_N"
                FROM "Fee_Student_Status" "SS"
                INNER JOIN "Fee_master_Terms_FeeHeads" "FMTF" ON "FMTF"."FMH_Id" = "SS"."FMH_Id" 
                    AND "FMTF"."FTI_Id" = "SS"."FTI_Id" 
                    AND "FMTF"."MI_Id" = 5
                WHERE "SS"."MI_Id" = 5 
                AND "SS"."ASMAY_Id" = 75 
                AND "SS"."FSS_PaidAmount" = 0 
                AND "FMTF"."FMT_Id" = 9 
                AND "FSS_CurrentYrCharges" <> 0
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "adm_school_y_student" 
                    WHERE "ASMAY_Id" = 75 
                    AND "amay_activeflag" = 1 
                    AND "ASMCL_Id" IN (
                        SELECT DISTINCT "ASMCL_Id" 
                        FROM "Fee_Yearly_Class_Category_Classes" 
                        WHERE "FYCC_Id" = "v_CY_FYCC_Id"
                    )
                )
                AND "FMG_Id" IN (21) 
                AND "SS"."AMST_Id" = "v_AMST_Id" 
                AND "SS"."FMH_Id" = "v_FMH_Id" 
                AND "SS"."FTI_Id" = "v_FTI_Id";

                SELECT COUNT(*) INTO "v_Rcount1" 
                FROM "Fee_Student_Concession_Installments" 
                WHERE "FSCI_FSC_Id" = "v_FSC_Id" 
                AND "FTI_Id" = "v_FTI_Id" 
                AND "FSCI_ConcessionAmount" = "v_ConcessionAmount";

                RAISE NOTICE '%', "v_Rcount1";

                IF ("v_Rcount1" = 0) AND "v_ConcessionAmount_N" <> 0 THEN
                    INSERT INTO "Fee_Student_Concession_Installments" (
                        "FSCI_FSC_Id", "FTI_Id", "FSCI_ConcessionAmount", 
                        "CreatedDate", "UpdatedDate"
                    )
                    VALUES("v_FSC_Id", "v_FTI_Id", "v_ConcessionAmount_N", 
                           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END IF;

            END IF;

        END LOOP;

    END LOOP;

    RETURN;
END;
$$;