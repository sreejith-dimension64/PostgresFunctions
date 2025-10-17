CREATE OR REPLACE FUNCTION "dbo"."123"()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst_id BIGINT;
    v_amst_name TEXT;
    v_amst_class TEXT;
    v_amst_section TEXT;
    v_fti_id BIGINT;
    v_monthyearsd TEXT;
    v_monthids1 TEXT;
    v_cols TEXT;
    v_temp BIGINT;
    v_waivedoff TEXT;
    v_netamount TEXT;
    v_paidamount TEXT;
    v_balance TEXT;
    v_concession TEXT;
    v_fine TEXT;
    v_AllDays123 TEXT;
    v_dquery TEXT;
BEGIN

    v_temp := 0;
    /*
    FOR students_rec IN
        SELECT "Adm_M_Student"."AMST_FirstName", 
               "Adm_School_M_Class"."ASMCL_ClassName", 
               "Adm_School_M_Section"."ASMC_SectionName", 
               "Adm_M_Student"."AMST_Id" 
        FROM "dbo"."Adm_M_Student" 
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
        INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
        INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Class"."ASMCL_Id" 
        INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_M_Class_Category"."ASMCL_Id" 
        INNER JOIN "dbo"."Adm_M_Category" ON "Adm_School_M_Class_Category"."AMC_Id" = "Adm_M_Category"."AMC_Id" 
        WHERE "Adm_School_M_Section"."ASMS_Id" = 1 
          AND "Adm_School_Y_Student"."ASMCL_Id" = 1 
          AND "Adm_M_Student"."ASMAY_Id" = 10 
        GROUP BY "Adm_M_Student"."AMST_FirstName", 
                 "Adm_School_M_Class"."ASMCL_ClassName", 
                 "Adm_School_M_Section"."ASMC_SectionName", 
                 "Adm_School_Y_Student"."ASMCL_Id", 
                 "Adm_M_Student"."ASMAY_Id", 
                 "Adm_M_Student"."AMST_Id"
    LOOP
        v_amst_name := students_rec."AMST_FirstName";
        v_amst_class := students_rec."ASMCL_ClassName";
        v_amst_section := students_rec."ASMC_SectionName";
        v_amst_id := students_rec."AMST_Id";

        FOR installments_rec IN
            SELECT "fti_id",
                   SUM("ftp_waived_Amt") AS waivedoff,
                   SUM("Net_amount") AS netamount,
                   SUM("paidamount") AS paidamount,
                   SUM("ftp_tobepaid_amt") AS balance,
                   SUM("ftp_concession_amt") AS concession,
                   SUM("ftp_fine_amt") AS fine  
            FROM "fee_T_stud_feestatus" 
            WHERE "Amst_Id" = v_amst_id 
              AND "fti_Id" IN (1,2,3)  
            GROUP BY "fti_id"
        LOOP
            v_fti_id := installments_rec."fti_id";
            v_waivedoff := installments_rec.waivedoff::TEXT;
            v_netamount := installments_rec.netamount::TEXT;
            v_paidamount := installments_rec.paidamount::TEXT;
            v_balance := installments_rec.balance::TEXT;
            v_concession := installments_rec.concession::TEXT;
            v_fine := installments_rec.fine::TEXT;

            IF v_temp = 0 THEN
                DROP TABLE IF EXISTS "temp_installment";
                CREATE TABLE "temp_installment"(
                    "amst_id" BIGINT NULL,
                    "fti_id" BIGINT NULL,
                    "waivedoff" TEXT NULL,
                    "netamount" TEXT NULL,
                    "paidamount" TEXT NULL,
                    "balance" TEXT NULL,
                    "concession" TEXT NULL,
                    "fine" TEXT NULL
                );
                v_temp := v_temp + 1;

            ELSIF v_temp > 0 THEN
                FOR clmns_rec IN
                    SELECT TO_CHAR(CURRENT_TIMESTAMP + (ROW_NUMBER() OVER (ORDER BY oid) || ' DAY')::INTERVAL, 'YYYYMMDD') AS "AllDays"
                    FROM pg_class
                    LIMIT 4
                LOOP
                    v_AllDays123 := clmns_rec."AllDays";
                    
                    v_dquery := 'ALTER TABLE "temp_installment" ADD COLUMN "' || v_AllDays123 || '" TEXT NULL';
                    
                    EXECUTE v_dquery;
                    
                END LOOP;

                v_temp := v_temp + 1;
            END IF;

        END LOOP;

    END LOOP;
    */
    
    RETURN;
END;
$$;