CREATE OR REPLACE FUNCTION "dbo"."DELETEEMPCONCESSION"(
    p_MI_ID BIGINT,
    p_EMPCDE BIGINT,
    p_ASMAY_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMPCNT BIGINT;
    v_AMST_ID BIGINT;
    v_FMG_ID BIGINT;
    v_FMH_ID BIGINT;
    v_FTI_ID BIGINT;
    v_FSS_CurrentYrCharges BIGINT;
    v_FSS_CONCESSIONAMOUNT BIGINT;
    v_ASMCL_ID BIGINT;
    v_AMSTS_SiblingsOrder BIGINT;
    v_COMMONAMST BIGINT;
    v_AMST_FIRSTNAME TEXT;
    v_SIBLINGRELATION TEXT;
    v_FSCI_ID BIGINT;
    v_FMCC_ID BIGINT;
    rec_fee_emp_con RECORD;
    rec_fee_emp_con_DEL RECORD;
    rec_deletestuconInst RECORD;
    rec_fee_emp_con_INS_STU RECORD;
    rec_fee_emp_con1 RECORD;
    rec_fee_emp_con_DEL1 RECORD;
    rec_deletestuconInst1 RECORD;
BEGIN

    SELECT COUNT(*) INTO v_EMPCNT 
    FROM "Adm_M_Student_EmployeeDetails" 
    WHERE "HRME_Id" = p_EMPCDE;

    UPDATE "Adm_M_Student_EmployeeDetails" 
    SET "AMSTE_Left" = 1 
    WHERE "HRME_Id" = p_EMPCDE;

    -- DELETE EMPLOYEE CONCESSION AND CHANGE THE CATEGORY TO GENERAL IF MORE THAN ONE SIBLING

    IF v_EMPCNT > 1 THEN
        
        FOR rec_fee_emp_con IN 
            SELECT "AMST_ID" 
            FROM "Adm_M_Student_EmployeeDetails" 
            WHERE "HRME_ID" = p_EMPCDE
        LOOP
            v_AMST_ID := rec_fee_emp_con."AMST_ID";

            FOR rec_fee_emp_con_DEL IN 
                SELECT "FMG_Id", "FMH_Id", "FTI_Id", "FSS_CurrentYrCharges", "FSS_ConcessionAmount" 
                FROM "Fee_Student_Status" 
                WHERE "AMST_Id" = v_AMST_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "ASMAY_Id" = p_ASMAY_ID 
                    AND "FSS_PaidAmount" = 0 
                    AND "FSS_ConcessionAmount" > 0
            LOOP
                v_FMG_ID := rec_fee_emp_con_DEL."FMG_Id";
                v_FMH_ID := rec_fee_emp_con_DEL."FMH_Id";
                v_FTI_ID := rec_fee_emp_con_DEL."FTI_Id";
                v_FSS_CurrentYrCharges := rec_fee_emp_con_DEL."FSS_CurrentYrCharges";
                v_FSS_CONCESSIONAMOUNT := rec_fee_emp_con_DEL."FSS_ConcessionAmount";

                FOR rec_deletestuconInst IN 
                    SELECT "FSCI_ID" 
                    FROM "Fee_Student_Concession_Installments" 
                    WHERE "FTI_Id" = v_FTI_ID 
                        AND "FSCI_FSC_Id" IN (
                            SELECT DISTINCT "FSC_ID" 
                            FROM "Fee_Student_Concession" 
                            WHERE "AMST_Id" = v_AMST_ID 
                                AND "FMG_Id" = v_FMG_ID 
                                AND "FMH_Id" = v_FMH_ID 
                                AND "MI_Id" = p_MI_ID 
                                AND "ASMAY_ID" = p_ASMAY_ID
                        )
                LOOP
                    v_FSCI_ID := rec_deletestuconInst."FSCI_ID";
                    
                    DELETE FROM "Fee_Student_Concession_Installments" 
                    WHERE "FSCI_ID" = v_FSCI_ID;
                    
                END LOOP;

                DELETE FROM "Fee_Student_Concession" 
                WHERE "FMG_Id" = v_FMG_ID 
                    AND "FMH_Id" = v_FMH_ID 
                    AND "AMST_Id" = v_AMST_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "ASMAY_ID" = p_ASMAY_ID;

                UPDATE "Fee_Student_Status" 
                SET "FSS_ConcessionAmount" = "FSS_ConcessionAmount" - v_FSS_CONCESSIONAMOUNT,
                    "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_FSS_CONCESSIONAMOUNT,
                    "FSS_ToBePaid" = "FSS_ToBePaid" + v_FSS_CONCESSIONAMOUNT 
                WHERE "AMST_Id" = v_AMST_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "ASMAY_Id" = p_ASMAY_ID 
                    AND "FMG_Id" = v_FMG_ID 
                    AND "FMH_Id" = v_FMH_ID 
                    AND "FTI_Id" = v_FTI_ID;

            END LOOP;

        END LOOP;

        -- DELETE EMPLOYEE CONCESSION AND CHANGE THE CATEGORY TO GENERAL IF MORE THAN ONE SIBLING

        FOR rec_fee_emp_con_INS_STU IN 
            SELECT "Adm_M_Student_EmployeeDetails"."AMST_Id", 
                   "AMST_FirstName", 
                   'SIBLING' AS "SIBLINGRELATION", 
                   "Adm_M_Student_EmployeeDetails"."ASMCL_Id", 
                   "AMSTE_SiblingsOrder" 
            FROM "Adm_M_Student_EmployeeDetails" 
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_ID" = "Adm_M_Student_EmployeeDetails"."AMST_Id" 
            WHERE "HRME_Id" = p_EMPCDE
        LOOP
            v_AMST_ID := rec_fee_emp_con_INS_STU."AMST_Id";
            v_AMST_FIRSTNAME := rec_fee_emp_con_INS_STU."AMST_FirstName";
            v_SIBLINGRELATION := rec_fee_emp_con_INS_STU."SIBLINGRELATION";
            v_ASMCL_ID := rec_fee_emp_con_INS_STU."ASMCL_Id";
            v_AMSTS_SiblingsOrder := rec_fee_emp_con_INS_STU."AMSTE_SiblingsOrder";

            SELECT "AMST_Id" INTO v_COMMONAMST 
            FROM "Adm_M_Student_EmployeeDetails" 
            WHERE "HRME_Id" = p_EMPCDE 
                AND "AMSTE_SiblingsOrder" = 1;

            INSERT INTO "Adm_Master_Student_SiblingsDetails" (
                "MI_Id", "AMST_Id", "AMSTS_SiblingsName", "AMSTS_SiblingsRelation", 
                "AMCL_Id", "AMSTS_Siblings_AMST_ID", "AMSTS_SiblingsOrder", 
                "AMSTS_TCIssuesFlag", "CreatedDate", "UpdatedDate"
            ) 
            VALUES (
                p_MI_ID, v_COMMONAMST, v_AMST_FIRSTNAME, v_SIBLINGRELATION, 
                v_ASMCL_ID, v_AMST_ID, v_AMSTS_SiblingsOrder, 
                0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );

        END LOOP;

        -- UPDATE FEE CATEGORY FROM EMPLOYEE TO SIBLING
        SELECT "FMCC_Id" INTO v_FMCC_ID 
        FROM "Fee_Master_Concession" 
        WHERE "FMCC_ConcessionFlag" = 'S';
        
        UPDATE "Adm_M_Student" 
        SET "AMST_Concession_Type" = v_FMCC_ID 
        WHERE "AMST_Id" IN (
            SELECT "AMST_ID" 
            FROM "Adm_M_Student_EmployeeDetails" 
            WHERE "HRME_ID" = p_EMPCDE
        );
        -- UPDATE FEE CATEGORY FROM EMPLOYEE TO SIBLING

        -- SAVE CONCESSION AS GENERAL SIBLING
        PERFORM "dbo"."SAVE_CONCESSION_FOR_SIBLINGS_AFTER_EMPLOYEE_LEFT"(
            p_MI_ID, p_ASMAY_ID, v_COMMONAMST, 0, 'stud'
        );
        -- SAVE CONCESSION AS GENERAL SIBLING

    ELSIF v_EMPCNT = 1 THEN

        -- DELETE EMPLOYEE CONCESSION  IF ONLY ONE SIBLING

        FOR rec_fee_emp_con1 IN 
            SELECT "AMST_ID" 
            FROM "Adm_M_Student_EmployeeDetails" 
            WHERE "HRME_ID" = p_EMPCDE
        LOOP
            v_AMST_ID := rec_fee_emp_con1."AMST_ID";

            FOR rec_fee_emp_con_DEL1 IN 
                SELECT "FMG_Id", "FMH_Id", "FTI_Id", "FSS_CurrentYrCharges", "FSS_ConcessionAmount" 
                FROM "Fee_Student_Status" 
                WHERE "AMST_Id" = v_AMST_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "ASMAY_Id" = p_ASMAY_ID 
                    AND "FSS_PaidAmount" = 0 
                    AND "FSS_ConcessionAmount" > 0
            LOOP
                v_FMG_ID := rec_fee_emp_con_DEL1."FMG_Id";
                v_FMH_ID := rec_fee_emp_con_DEL1."FMH_Id";
                v_FTI_ID := rec_fee_emp_con_DEL1."FTI_Id";
                v_FSS_CurrentYrCharges := rec_fee_emp_con_DEL1."FSS_CurrentYrCharges";
                v_FSS_CONCESSIONAMOUNT := rec_fee_emp_con_DEL1."FSS_ConcessionAmount";

                FOR rec_deletestuconInst1 IN 
                    SELECT "FSCI_ID" 
                    FROM "Fee_Student_Concession_Installments" 
                    WHERE "FTI_Id" = v_FTI_ID 
                        AND "FSCI_FSC_Id" IN (
                            SELECT DISTINCT "FSC_ID" 
                            FROM "Fee_Student_Concession" 
                            WHERE "AMST_Id" = v_AMST_ID 
                                AND "FMG_Id" = v_FMG_ID 
                                AND "FMH_Id" = v_FMH_ID 
                                AND "MI_Id" = p_MI_ID 
                                AND "ASMAY_ID" = p_ASMAY_ID
                        )
                LOOP
                    v_FSCI_ID := rec_deletestuconInst1."FSCI_ID";
                    
                    DELETE FROM "Fee_Student_Concession_Installments" 
                    WHERE "FSCI_ID" = v_FSCI_ID;
                    
                END LOOP;

                DELETE FROM "Fee_Student_Concession" 
                WHERE "FMG_Id" = v_FMG_ID 
                    AND "FMH_Id" = v_FMH_ID 
                    AND "AMST_Id" = v_AMST_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "ASMAY_ID" = p_ASMAY_ID;

                UPDATE "Fee_Student_Status" 
                SET "FSS_ConcessionAmount" = "FSS_ConcessionAmount" - v_FSS_CONCESSIONAMOUNT,
                    "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_FSS_CONCESSIONAMOUNT,
                    "FSS_ToBePaid" = "FSS_ToBePaid" + v_FSS_CONCESSIONAMOUNT 
                WHERE "AMST_Id" = v_AMST_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "ASMAY_Id" = p_ASMAY_ID 
                    AND "FMG_Id" = v_FMG_ID 
                    AND "FMH_Id" = v_FMH_ID 
                    AND "FTI_Id" = v_FTI_ID;

            END LOOP;

        END LOOP;

    END IF;

    -- DELETE EMPLOYEE CONCESSION  IF ONLY ONE SIBLING

    -- UPDATE FEE CATEGORY FROM EMPLOYEE TO SIBLING

    SELECT "FMCC_Id" INTO v_FMCC_ID 
    FROM "Fee_Master_Concession" 
    WHERE "FMCC_ConcessionFlag" = 'S';
    
    UPDATE "Adm_M_Student" 
    SET "AMST_Concession_Type" = v_FMCC_ID 
    WHERE "AMST_Id" IN (
        SELECT "AMST_ID" 
        FROM "Adm_M_Student_EmployeeDetails" 
        WHERE "HRME_ID" = p_EMPCDE
    );

    -- UPDATE FEE CATEGORY FROM EMPLOYEE TO SIBLING

END;
$$;