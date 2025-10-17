CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Student_Mapnew_others"(
    "fmg_id" bigint,
    "FMOST_Id" bigint,
    "MI_ID" bigint,
    "fti_id_new" bigint,
    "FMH_ID_new" bigint,
    "userid" bigint,
    "asmay_id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "fyghm_id" bigint;
    "fmcc_id" bigint;
    "amcl_id" bigint;
    "fma_id" bigint;
    "fti_name" varchar(100);
    "fma_amount" numeric;
    "fmh_name" varchar(100);
    "fmg_id_new" bigint;
    "fmsgid" bigint;
    "ftp_concession_amt" bigint;
    "fmh_id" bigint;
    "fti_id" bigint;
    "previousacademicyear" bigint;
    "v_rowcount" integer;
    "yearly_fee_rec" RECORD;
    "fee_det_rec" RECORD;
BEGIN
    "amcl_id" := 0;
    "fmcc_id" := 0;
    "fma_id" := 0;
    "fti_name" := '';
    "fma_amount" := 0;
    "fmh_name" := '';
    "ftp_concession_amt" := 0;

    SELECT "ASMAY_Id" INTO "previousacademicyear" 
    FROM "Adm_School_M_Academic_Year"
    WHERE EXTRACT(year FROM "ASMAY_From_Date") BETWEEN 
        (SELECT (EXTRACT(year FROM "ASMAY_From_Date")-1) AS year 
         FROM "Adm_School_M_Academic_Year" 
         WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
         AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
         AND "MI_Id" = "MI_ID") 
    AND 
        (SELECT (EXTRACT(year FROM "ASMAY_From_Date")-1) AS year 
         FROM "Adm_School_M_Academic_Year" 
         WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
         AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
         AND "MI_Id" = "MI_ID");

    RAISE NOTICE '%', "previousacademicyear";

    PERFORM * FROM "Fee_Master_OthStudents_GH" 
    WHERE "ASMAY_Id" = "asmay_id" 
    AND "FMG_Id" = "fmg_id" 
    AND "MI_Id" = "MI_ID" 
    AND "FMOST_Id" = "FMOST_Id";

    GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;

    IF "v_rowcount" = 0 THEN
        RAISE NOTICE 'a';
        INSERT INTO "Fee_Master_OthStudents_GH" ("MI_Id", "FMOST_Id", "ASMAY_Id", "FMG_Id", "FMOSTGH_ActiveFlag") 
        VALUES ("MI_ID", "FMOST_Id", "asmay_id", "fmg_id", 'Y');
    END IF;

    BEGIN
        SELECT "FMOSTGH_Id" INTO "fmsgid" 
        FROM "Fee_Master_OthStudents_GH" 
        WHERE "ASMAY_Id" = "asmay_id" 
        AND "FMG_Id" = "fmg_id" 
        AND "MI_Id" = "MI_ID" 
        AND "FMOST_Id" = "FMOST_Id";

        RAISE NOTICE '%', "fmsgid";
        RAISE NOTICE 'e';
        RAISE NOTICE '%;%;%', "fmsgid", "FMH_ID_new", "fti_id_new";

        INSERT INTO "Fee_Master_OthStudents_GH_Instl" ("FMOSTGH_Id", "FMH_ID", "FTI_ID") 
        VALUES ("fmsgid", "FMH_ID_new", "fti_id_new");

        SELECT "FMOSTGHI_Id" INTO "fmsgid" 
        FROM "Fee_Master_OthStudents_GH_Instl" 
        WHERE "FMOSTGH_Id" = "fmsgid";

        RAISE NOTICE '%', "fmsgid";
        RAISE NOTICE 'd';

        FOR "yearly_fee_rec" IN 
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" 
            WHERE "FMG_Id" = "fmg_id" 
            AND "FYGHM_ActiveFlag" = 1 
            AND "ASMAY_Id" = "asmay_id" 
            AND "FMH_Id" = "FMH_ID_new" 
            AND "FMI_Id" IN (SELECT "FMI_Id" FROM "Fee_T_Installment" WHERE "FTI_Id" = "fti_id_new")
        LOOP
            "fyghm_id" := "yearly_fee_rec"."FYGHM_Id";
            "fmg_id_new" := "yearly_fee_rec"."FMG_Id";
            "fmh_id" := "yearly_fee_rec"."FMH_Id";

            RAISE NOTICE 'b';

            FOR "fee_det_rec" IN 
                SELECT "Fee_Master_Amount_OthStaffs"."FMAOST_Id", 
                       "Fee_Master_Amount_OthStaffs"."FTI_Id", 
                       "fee_t_installment"."fti_name", 
                       "Fee_Master_Amount_OthStaffs"."FMAOST_Amount" 
                FROM "Fee_Master_Amount_OthStaffs" 
                INNER JOIN "fee_t_installment" 
                    ON "Fee_Master_Amount_OthStaffs"."fti_id" = "fee_t_installment"."fti_id"
                WHERE "FMG_Id" = "fmg_id_new" 
                AND "FMH_Id" = "FMH_ID_new" 
                AND "Fee_Master_Amount_OthStaffs"."FTI_Id" = "fti_id_new" 
                AND "ASMAY_Id" = "asmay_id" 
                AND "FMAOST_OthStaffFlag" = 'S'
            LOOP
                "fma_id" := "fee_det_rec"."FMAOST_Id";
                "fti_id" := "fee_det_rec"."FTI_Id";
                "fti_name" := "fee_det_rec"."fti_name";
                "fma_amount" := "fee_det_rec"."FMAOST_Amount";

                SELECT "FMH_FeeName" INTO "fmh_name" 
                FROM "Fee_Master_Head" 
                WHERE "fmh_id" = "FMH_ID_new";

                PERFORM * FROM "Fee_Student_Status_OthStu" 
                WHERE "FMOST_Id" = "FMOST_Id" 
                AND "fmg_id" = "fmg_id_new" 
                AND "fmh_id" = "FMH_ID_new" 
                AND "FMA_Id" = "fma_id";

                INSERT INTO "Fee_Student_Status_OthStu"(
                    "MI_Id", "ASMAY_Id", "FMOST_Id", "FMG_Id", "FSSOST_OBArrearAmount", 
                    "FSSOST_OBExcessAmount", "FSSOST_CurrentYrCharges", "FSSOST_TotalCharges", 
                    "FSSOST_ConcessionAmount", "FSSOST_WaivedAmount", "FSSOST_ToBePaid", 
                    "FSSOST_PaidAmount", "FSSOST_ExcessPaidAmount", "FSSOST_ExcessAdjustedAmount", 
                    "FSSOST_RunningExcessAmount", "FSSOST_AdjustedAmount", "FSSOST_RebateAmount", 
                    "FSSOST_FineAmount", "FSSOST_RefundAmount", "FSSOST_RefundAmountAdjusted", 
                    "FSSOST_NetAmount", "FSSOST_ChequeBounceAmount", "FSSOST_ArrearFlag", 
                    "FSSOST_RefundOverFlag", "FSSOST_ActiveFlag", "CreatedDate", "UpdatedDate", 
                    "FMH_Id", "FTI_Id", "FMA_Id"
                ) VALUES (
                    "MI_ID", "asmay_id", "FMOST_Id", "fmg_id", 0, 
                    0, "fma_amount", "fma_amount", 
                    0, 0, "fma_amount", 
                    0, 0, 0, 
                    0, 0, 0, 
                    0, 0, 0, 
                    "fma_amount", 0, 0, 
                    0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                    "FMH_ID_new", "fti_id_new", "fma_id"
                );

                PERFORM "dbo"."UpdateStudPaidAmt"("FMOST_Id", "fma_id", "MI_ID");

            END LOOP;

        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'ErrorNumber: %', SQLSTATE;
            RAISE NOTICE 'ErrorMessage: %', SQLERRM;
            RAISE;
    END;

    RETURN;
END;
$$;