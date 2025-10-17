CREATE OR REPLACE FUNCTION "dbo"."Fee_Installmentwise_RouteLocation_July12"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMST_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_COUNT BIGINT;
    v_TRSR_PickUpLocation VARCHAR(200);
    v_TRSR_DropLocation VARCHAR(200);
    v_TRMR_Id BIGINT;
    v_FMA_Amount DECIMAL(18,2);
    v_FLAG VARCHAR(200);
    v_ASMCL_Id BIGINT;
    v_FMCC_Id BIGINT;
    v_FMA_Id BIGINT;
    v_FMG_Id BIGINT;
    v_FMH_Id BIGINT;
    v_FTI_Id BIGINT;
    v_TRMLAMTI_OneWayAmount DECIMAL(18,2);
    v_TRMLAMTI_TwoWayAmount DECIMAL(18,2);
    v_FMSG_Id BIGINT;
    v_TRML_Id BIGINT;
    v_UserId BIGINT;
    v_GroupCount BIGINT;
    v_OldGroupCount BIGINT;
    v_OldFMSG_Id BIGINT;
    rec RECORD;
BEGIN

    SELECT COUNT(1) INTO v_COUNT
    FROM "TRN"."TR_Student_Route" 
    WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_PickUpLocation" != '' AND "TRSR_DropLocation" != '';
    
    SELECT "TRSR_PickUpLocation", "TRMR_Id" INTO v_TRSR_PickUpLocation, v_TRMR_Id
    FROM "TRN"."TR_Student_Route" 
    WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_Id;
    
    SELECT "TRSR_DropLocation", "TRMR_Id" INTO v_TRSR_DropLocation, v_TRMR_Id
    FROM "TRN"."TR_Student_Route" 
    WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_Id;

    RAISE NOTICE '%', v_TRSR_DropLocation;
    RAISE NOTICE '%', v_TRMR_Id;

    SELECT "FMG_Id" INTO v_FMG_Id
    FROM "TRN"."TR_Location_Amount" 
    WHERE "ASMAY_Id" = p_ASMAY_Id AND "TRML_Id" = v_TRSR_PickUpLocation AND "TRMR_Id" = v_TRMR_Id;

    RAISE NOTICE '%', v_FMG_Id;

    IF v_COUNT > 0 THEN
    BEGIN

        SELECT C."ASMCL_Id" INTO v_ASMCL_Id
        FROM "TRN"."TR_Student_Route" A 
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id" AND C."ASMAY_Id" = A."ASMAY_Id"
        WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id AND C."AMST_Id" = p_AMST_ID;

        SELECT B."FMCC_Id" INTO v_FMCC_Id
        FROM "Fee_Yearly_Class_Category_Classes" A 
        INNER JOIN "Fee_Yearly_Class_Category" B ON A."FYCC_Id" = B."FYCC_Id" AND B."FYCC_ActiveFlag" = 1
        WHERE A."ASMCL_Id" = v_ASMCL_Id AND B."ASMAY_Id" = p_ASMAY_Id;

        SELECT COUNT(1) INTO v_GroupCount
        FROM "Fee_Master_Student_Group" 
        WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_Id AND "FMG_Id" = v_FMG_Id;

        IF v_GroupCount = 0 THEN
        BEGIN

            FOR rec IN 
                SELECT A."FMA_Id", A."FMG_Id", A."FMH_Id", A."FTI_Id", C."TRMLAMTI_OneWayAmount", C."TRMLAMTI_TwoWayAmount", A."FMA_CreatedBy"
                FROM "Fee_Master_Amount" A 
                INNER JOIN "TRN"."TR_Location_Amount" B ON A."FMG_Id" = B."FMG_Id" AND A."ASMAY_Id" = B."ASMAY_Id"
                INNER JOIN "TRN"."TR_Location_Amount_Installment" C ON C."TRMLAMT_Id" = B."TRMLAMT_Id" AND C."TRMLAMTI_ActiveFlg" = 1
                    AND C."FMH_Id" = A."FMH_Id" AND C."FTI_Id" = A."FTI_Id"
                WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id AND A."FMCC_Id" = v_FMCC_Id 
                    AND B."TRMR_Id" = v_TRMR_Id AND B."TRML_Id" = v_TRSR_DropLocation
            LOOP
                v_FMA_Id := rec."FMA_Id";
                v_FMG_Id := rec."FMG_Id";
                v_FMH_Id := rec."FMH_Id";
                v_FTI_Id := rec."FTI_Id";
                v_TRMLAMTI_OneWayAmount := rec."TRMLAMTI_OneWayAmount";
                v_TRMLAMTI_TwoWayAmount := rec."TRMLAMTI_TwoWayAmount";
                v_UserId := rec."FMA_CreatedBy";

                SELECT "FMSG_Id" INTO v_FMSG_Id
                FROM "Fee_Master_Student_Group"  
                WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_Id AND "FMG_Id" = v_FMG_Id;

                RAISE NOTICE '%', v_FMSG_Id;

            END LOOP;

        END;
        ELSIF v_GroupCount > 0 THEN
        BEGIN

            RAISE NOTICE 'GroupCount:%', v_GroupCount;

            SELECT COUNT(1) INTO v_OldGroupCount
            FROM "Fee_Student_Status" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "AMST_Id" = p_AMST_ID 
                AND "FMG_Id" = v_FMG_Id AND "FSS_PaidAmount" = 0 AND "FSS_CurrentYrCharges" > 0;

            RAISE NOTICE 'OldGroupCount:%', v_OldGroupCount;
            
            IF v_OldGroupCount = 0 THEN
            BEGIN

                DELETE FROM "Fee_Master_Student_Group" 
                WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "FMG_Id" = v_FMG_Id AND "FMSG_ActiveFlag" = 'Y';

                INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
                VALUES (p_MI_Id, p_AMST_ID, p_ASMAY_Id, v_FMG_Id, 'Y');

                FOR rec IN 
                    SELECT A."FMA_Id", A."FMG_Id", A."FMH_Id", A."FTI_Id", C."TRMLAMTI_OneWayAmount", C."TRMLAMTI_TwoWayAmount", A."FMA_CreatedBy"
                    FROM "Fee_Master_Amount" A 
                    INNER JOIN "TRN"."TR_Location_Amount" B ON A."FMG_Id" = B."FMG_Id" AND A."ASMAY_Id" = B."ASMAY_Id"
                    INNER JOIN "TRN"."TR_Location_Amount_Installment" C ON C."TRMLAMT_Id" = B."TRMLAMT_Id" AND C."TRMLAMTI_ActiveFlg" = 1
                        AND C."FMH_Id" = A."FMH_Id" AND C."FTI_Id" = A."FTI_Id"
                    WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id AND A."FMCC_Id" = v_FMCC_Id 
                        AND B."TRMR_Id" = v_TRMR_Id AND B."TRML_Id" = v_TRSR_DropLocation
                LOOP
                    v_FMA_Id := rec."FMA_Id";
                    v_FMG_Id := rec."FMG_Id";
                    v_FMH_Id := rec."FMH_Id";
                    v_FTI_Id := rec."FTI_Id";
                    v_TRMLAMTI_OneWayAmount := rec."TRMLAMTI_OneWayAmount";
                    v_TRMLAMTI_TwoWayAmount := rec."TRMLAMTI_TwoWayAmount";
                    v_UserId := rec."FMA_CreatedBy";

                    SELECT "FMSG_Id" INTO v_FMSG_Id
                    FROM "Fee_Master_Student_Group"  
                    WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_Id AND "FMG_Id" = v_FMG_Id;

                    RAISE NOTICE '%', v_FMSG_Id;

                    INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID", "FMSGI_CreatedDate", "FMSGI_UpdatedDate")
                    VALUES(v_FMSG_Id, v_FMH_Id, v_FTI_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                    INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount")              
                    VALUES(p_MI_Id, p_ASMAY_Id, p_AMST_ID, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id, 0, 0, v_TRMLAMTI_TwoWayAmount, v_TRMLAMTI_TwoWayAmount, v_TRMLAMTI_TwoWayAmount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, v_TRMLAMTI_TwoWayAmount, 0, 0, 0, 1, v_UserId, 0);

                END LOOP;

            END;
            END IF;

        END;
        END IF;

    END;
    END IF;

    RETURN;

END;
$$;