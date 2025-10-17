CREATE OR REPLACE FUNCTION "dbo"."AUTOCALCULATIONAMOUNT_CLG"(
    p_MI_Id bigint,
    p_AMCST_Id bigint,
    p_ASMAY_Id bigint,
    p_PAYABLEAMOUNT bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_studreceiptno varchar(250);
    v_studpaidamount decimal;
    v_studpaiddate timestamp;
    v_fmaid bigint;
    v_statamount bigint;
    v_tobepaid bigint;
    v_netamount bigint;
    v_ftiid bigint;
    v_fypid bigint;
    v_ftpconcessionamt bigint;
    v_paidamt bigint;
    v_feeheadname varchar(250);
    v_remarks varchar(250);
    v_fmgid text;
    v_totconcessionamt bigint;
    v_newlfmaidd bigint;
    v_Rowcount bigint;
    v_Receiptno text;
    v_fmttrm bigint;
    v_fmt_id bigint;
    v_Rcount int;
    v_SRcount int;
    v_tobepaidT bigint;
    v_tobepaidf bigint;
    v_tobepaidf1 bigint;
    v_FMA_IdF bigint;
    v_FMH_Order int;
    v_paidamount decimal(18,2);
    v_FMH_Id bigint;
    v_rec RECORD;
BEGIN

    v_tobepaid := 0;
    v_ASMAY_Id := p_ASMAY_Id;
    v_paidamount := p_PAYABLEAMOUNT;

    -- fetch student id
    SELECT count(*) INTO v_SRcount 
    FROM "CLG"."Adm_College_Yearly_Student" A 
    INNER JOIN "CLG"."Adm_Master_College_Student" B ON A."AMCST_Id"=B."AMCST_Id" 
        AND A."ASMAY_Id"=v_ASMAY_Id AND B."MI_Id"=p_MI_Id;
 
    IF (v_SRcount <> 0) THEN

        -- fetch fmgids orderwise
        FOR v_rec IN (
            SELECT DISTINCT "FMG_Id" 
            FROM (
                SELECT "Fee_Master_Group"."FMG_Id", "FMG_Order" 
                FROM "CLG"."Fee_College_Student_Status" FCSS
                INNER JOIN "CLG"."Fee_College_Master_Amount" FCMA 
                    ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id"
                INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id"=FCMA."FMG_Id" 
                WHERE "AMCST_Id"=p_AMCST_Id AND FCSS."ASMAY_Id"=v_ASMAY_Id 
                    AND FCSS."MI_Id"=p_MI_Id AND FCMA."MI_Id"=p_MI_Id 
                    AND "FMG_CompulsoryFlag"!='R' AND FCSS."FCSS_ToBePaid">0 
                ORDER BY "FMG_Order"
                LIMIT 100
            ) AS New
        )
        LOOP
            v_fmgid := v_rec."FMG_Id";

            -- fetch Head orderwise
            FOR v_rec IN (
                SELECT DISTINCT "FMH_Id" 
                FROM (
                    SELECT "Fee_Master_Head"."FMH_Id", "FMH_Order" 
                    FROM "CLG"."Fee_College_Student_Status" FCSS
                    INNER JOIN "CLG"."Fee_College_Master_Amount" FCMA 
                        ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"=FCMA."FMH_Id" 
                    WHERE "AMCST_Id"=p_AMCST_Id AND FCSS."ASMAY_Id"=v_ASMAY_Id 
                        AND FCSS."MI_Id"=p_MI_Id AND FCMA."MI_Id"=p_MI_Id 
                        AND FCSS."FMG_Id"=v_fmgid::bigint AND FCSS."FCSS_ToBePaid">0 
                    ORDER BY "FMH_Order"
                    LIMIT 100
                ) AS New
            )
            LOOP
                v_FMH_Id := v_rec."FMH_Id";

                IF (v_paidamount > 0) THEN

                    -- check head wise pending amount
                    SELECT COUNT(*) INTO v_Rcount 
                    FROM "CLG"."Fee_College_Master_Amount" FCMA
                    INNER JOIN "CLG"."Fee_College_Student_Status" FCSS 
                        ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id"
                    WHERE "AMCST_Id"=p_AMCST_Id AND FCSS."FMH_Id"=v_FMH_Id 
                        AND FCSS."FMG_Id"=v_fmgid::bigint AND "FCSS_ToBePaid">0 
                        AND "FCSS_CurrentYrCharges">0 AND FCSS."MI_Id"=p_MI_Id;

                    IF (v_Rcount > 0) THEN
                        -- fetch balance head wise
                        v_tobepaid := 0;

                        SELECT COALESCE(SUM("FCSS_ToBePaid"), 0) INTO v_tobepaid
                        FROM "CLG"."Fee_College_Master_Amount" FCMA 
                        INNER JOIN "CLG"."Fee_College_Student_Status" FCSS 
                            ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id"
                        WHERE "AMCST_Id"=p_AMCST_Id AND FCSS."FMH_Id"=v_FMH_Id 
                            AND FCSS."FMG_Id"=v_fmgid::bigint AND "FCSS_ToBePaid">0 
                            AND "FCSS_CurrentYrCharges">0 AND FCSS."MI_Id"=p_MI_Id;

                        IF (v_tobepaid > 0) AND (v_paidamount <= v_tobepaid) THEN

                            FOR v_rec IN (
                                SELECT FCMAS."FCMAS_Id", FMH."FMH_Order" 
                                FROM "CLG"."Fee_College_Master_Amount" FCMA 
                                INNER JOIN "CLG"."Fee_College_Student_Status" FCSS 
                                    ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id"
                                INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FCMAS 
                                    ON FCMAS."FCMAS_Id"=FCSS."FCMAS_Id" AND FCMAS."FCMA_Id"=FCMA."FCMA_Id" 
                                    AND FCMAS."FCMAS_ActiveFlg"=1 AND FCMAS."MI_Id"=p_MI_Id
                                INNER JOIN "Fee_Master_Head" FMH ON FMH."FMH_Id"=FCMA."FMH_Id" AND FMH."MI_Id"=p_MI_Id
                                WHERE "AMCST_Id"=p_AMCST_Id AND FCSS."FMH_Id"=v_FMH_Id 
                                    AND FCMA."FMG_Id"=v_fmgid::bigint AND "FCSS_ToBePaid">0 
                                    AND FCSS."FCMAS_Id"<>0 AND FCSS."ASMAY_Id"=v_ASMAY_Id 
                                    AND FCSS."MI_Id"=p_MI_Id 
                                ORDER BY FMH."FMH_Order"
                            )
                            LOOP
                                v_fmaid := v_rec."FCMAS_Id";
                                v_FMH_Order := v_rec."FMH_Order";

                                SELECT COALESCE(SUM("FCSS_ToBePaid"), 0) INTO v_tobepaidf1
                                FROM "CLG"."Fee_College_Master_Amount" FCMA  
                                INNER JOIN "CLG"."Fee_College_Student_Status" FCSS 
                                    ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id"
                                WHERE "AMCST_Id"=p_AMCST_Id AND "FCSS_ToBePaid">0 
                                    AND "FCSS_CurrentYrCharges">0 AND FCSS."MI_Id"=p_MI_Id 
                                    AND FCSS."FCMAS_Id"=v_fmaid AND FCSS."FMH_Id"=v_FMH_Id 
                                    AND FCMA."FMG_Id"=v_fmgid::bigint AND FCSS."ASMAY_Id"=v_ASMAY_Id;

                                IF (v_paidamount >= v_tobepaidf1) THEN

                                    INSERT INTO "CLG"."Fee_T_College_Payment" 
                                        ("FYP_Id", "FCMAS_Id", "FTCP_PaidAmount", "FTCP_FineAmount", 
                                         "FTCP_ConcessionAmount", "FTCP_WaivedAmount", "FTCP_Remarks", "FTCP_RebateAmount") 
                                    VALUES (v_fypid, v_fmaid, v_tobepaidf1, 0, 0, 0, 'PAYMENT', 0);

                                    UPDATE "CLG"."Fee_College_Student_Status" 
                                    SET "FCSS_ToBePaid"=0, "FCSS_PaidAmount"=v_tobepaidf1 
                                    WHERE "ASMAY_Id"=v_ASMAY_Id AND "AMCST_Id"=p_AMCST_Id 
                                        AND "FCMAS_Id"=v_fmaid AND "MI_Id"=p_MI_Id;
                                    
                                    v_paidamount := v_paidamount - v_tobepaidf1;

                                    RAISE NOTICE 'paid amount002 : %', v_paidamount;

                                    v_tobepaidf1 := 0;

                                ELSIF (v_paidamount <= v_tobepaidf1) AND (v_paidamount <> 0 AND v_tobepaidf1 <> 0) THEN

                                    INSERT INTO "CLG"."Fee_T_College_Payment" 
                                        ("FYP_Id", "FCMAS_Id", "FTCP_PaidAmount", "FTCP_FineAmount", 
                                         "FTCP_ConcessionAmount", "FTCP_WaivedAmount", "FTCP_Remarks", "FTCP_RebateAmount") 
                                    VALUES (v_fypid, v_fmaid, v_paidamount, 0, 0, 0, ' PAYMENT', 0);

                                    UPDATE "CLG"."Fee_College_Student_Status" 
                                    SET "FCSS_ToBePaid"="FCSS_ToBePaid"-v_paidamount, "FCSS_PaidAmount"=v_paidamount 
                                    WHERE "ASMAY_Id"=v_ASMAY_Id AND "AMCST_Id"=p_AMCST_Id 
                                        AND "FCMAS_Id"=v_fmaid AND "MI_Id"=p_MI_Id;

                                    RAISE NOTICE 'paid amount003 : %', v_paidamount;
                                    
                                    v_paidamount := 0;
                                    v_tobepaidf1 := 0;

                                END IF;

                            END LOOP;

                            RAISE NOTICE 'paid amount004 last : %', v_paidamount;

                        ELSIF (v_tobepaid > 0) AND (v_paidamount >= v_tobepaid) THEN

                            FOR v_rec IN (
                                SELECT FCMAS."FCMAS_Id", FMH."FMH_Order" 
                                FROM "CLG"."Fee_College_Master_Amount" FCMA 
                                INNER JOIN "CLG"."Fee_College_Student_Status" FCSS 
                                    ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id"
                                INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FCMAS 
                                    ON FCMAS."FCMAS_Id"=FCSS."FCMAS_Id" AND FCMAS."FCMA_Id"=FCMA."FCMA_Id" 
                                    AND FCMAS."FCMAS_ActiveFlg"=1 AND FCMAS."MI_Id"=p_MI_Id
                                INNER JOIN "Fee_Master_Head" FMH ON FMH."FMH_Id"=FCMA."FMH_Id" AND FMH."MI_Id"=p_MI_Id
                                WHERE "AMCST_Id"=p_AMCST_Id AND FCSS."FMH_Id"=v_FMH_Id 
                                    AND FCMA."FMG_Id"=v_fmgid::bigint AND "FCSS_ToBePaid">0 
                                    AND FCSS."FCMAS_Id"<>0 AND FCSS."ASMAY_Id"=v_ASMAY_Id 
                                    AND FCSS."MI_Id"=p_MI_Id 
                                ORDER BY FMH."FMH_Order"
                            )
                            LOOP
                                v_fmaid := v_rec."FCMAS_Id";
                                v_FMH_Order := v_rec."FMH_Order";

                                v_tobepaidf := 0;

                                SELECT COALESCE(SUM("FCSS_ToBePaid"), 0) INTO v_tobepaidf
                                FROM "CLG"."Fee_College_Master_Amount" FCMA  
                                INNER JOIN "CLG"."Fee_College_Student_Status" FCSS 
                                    ON FCMA."FMH_Id"=FCSS."FMH_Id" AND FCMA."FTI_Id"=FCSS."FTI_Id" AND FCMA."FMG_Id"=FCSS."FMG_Id"
                                WHERE "AMCST_Id"=p_AMCST_Id AND "FCSS_ToBePaid">0 
                                    AND "FCSS_CurrentYrCharges">0 AND FCSS."MI_Id"=p_MI_Id 
                                    AND FCSS."FCMAS_Id"=v_fmaid AND FCSS."ASMAY_Id"=v_ASMAY_Id 
                                    AND FCSS."FMH_Id"=v_FMH_Id AND FCMA."FMG_Id"=v_fmgid::bigint;

                                IF (v_paidamount >= v_tobepaidf) THEN

                                    INSERT INTO "CLG"."Fee_T_College_Payment" 
                                        ("FYP_Id", "FCMAS_Id", "FTCP_PaidAmount", "FTCP_FineAmount", 
                                         "FTCP_ConcessionAmount", "FTCP_WaivedAmount", "FTCP_Remarks", "FTCP_RebateAmount")  
                                    VALUES (v_fypid, v_fmaid, v_tobepaidf, 0, 0, 0, 'PAYMENT', 0);

                                    UPDATE "CLG"."Fee_College_Student_Status" 
                                    SET "FCSS_ToBePaid"=0, "FCSS_PaidAmount"=v_tobepaidf  
                                    WHERE "ASMAY_Id"=v_ASMAY_Id AND "AMCST_Id"=p_AMCST_Id 
                                        AND "FCMAS_Id"=v_fmaid AND "MI_Id"=p_MI_Id;
                                    
                                    v_paidamount := v_paidamount - v_tobepaidf;

                                    RAISE NOTICE 'paid amount001 : %', v_paidamount;

                                END IF;

                            END LOOP;

                        END IF;

                    END IF;

                END IF;

            END LOOP;

        END LOOP;

    ELSE

        RAISE NOTICE 'student Record not exist';

    END IF;

END;
$$;