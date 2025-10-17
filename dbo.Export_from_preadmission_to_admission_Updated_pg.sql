CREATE OR REPLACE FUNCTION "dbo"."Export_from_preadmission_to_admission_Updated"(
    p_PASR_Id bigint,
    p_ASMAY_Id bigint,
    p_MI_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$

DECLARE
    v_StudentStatus varchar(20);
    v_MaxAmst_Id bigint;
    v_Activeflag bigint;
    v_Concesseion bigint;
    v_pasrcount bigint;
    v_ASMSCL_Id bigint;
    v_ASMS_Id bigint;
    v_Fypid bigint;
    v_TotalAmount bigint;
    v_Fmaid bigint;
    v_PendingAmount bigint;
    v_TotalAmountReg bigint;
    v_AMC_Id bigint;
    v_userid bigint;
    v_TotaltAmount bigint;
    v_CONCESSIONCATEGORY varchar(10);
    v_PRECONCESSIONCATEGORY varchar(10);
    v_Admno varchar;
    v_regno varchar;
    v_Admno1 varchar;
    v_regno1 varchar;
    v_rowcount integer;
    rec_feeinsert RECORD;
    rec_feetinsert RECORD;

BEGIN

    v_studentstatus := 'S';
    v_activeflag := 1;
    v_concesseion := 1;

    BEGIN
        
        SELECT "ASMCC"."ASMCC_Id" INTO v_AMC_Id
        FROM "Preadmission_School_Registration" "PSR" 
        INNER JOIN "Adm_School_M_Class_Category" "ASMCC" 
            ON "PSR"."AMC_Id" = "ASMCC"."AMC_Id" 
            AND "PSR"."ASMCL_Id" = "ASMCC"."ASMCL_Id" 
            AND "PSR"."MI_Id" = "ASMCC"."MI_Id"  
        WHERE "PASR_Id" = p_PASR_Id 
            AND "PSR"."MI_Id" = p_MI_Id 
            AND "ASMCC"."ASMAY_Id" = p_ASMAY_Id;

        SELECT "a"."Id" INTO v_userid
        FROM "ApplicationUser" AS "a" 
        INNER JOIN "ApplicationUserRole" AS "b" ON "a"."Id" = "b"."UserId" 
        INNER JOIN "IVRM_Role_Type" AS "c" ON "c"."IVRMRT_Id" = "b"."RoleTypeId" 
        WHERE "c"."IVRMRT_Role" = 'ADMIN'
        LIMIT 1;

        SELECT count(*) INTO v_pasrcount 
        FROM "Adm_Master_Student_PA" 
        WHERE "PASR_Id" = p_PASR_Id;

        IF (v_pasrcount = 0) THEN
            
            INSERT INTO "Adm_M_Student" (
                "MI_Id","ASMAY_Id","AMST_FirstName","AMST_MiddleName","AMST_LastName","AMST_Date","AMST_Sex","AMST_DOB","PASR_Age","ASMCL_Id",
                "AMST_BloodGroup","AMST_MotherTongue","AMST_PerStreet","AMST_PerArea","AMST_PerCity","AMST_PerState","AMST_PerCountry","AMST_PerPincode",
                "AMST_ConStreet","AMST_ConArea","AMST_ConCity","AMST_ConState","AMST_ConCountry","AMST_ConPincode","AMST_AadharNo","AMST_MobileNo",
                "AMST_emailId","AMST_FatherAliveFlag","AMST_FatherName","AMST_FatherAadharNo","AMST_FatherSurname","AMST_FatherEducation",
                "AMST_FatherOccupation","AMST_FatherDesignation","AMST_FatherMonIncome","AMST_FatherMobleNo","AMST_FatheremailId","AMST_MotherAliveFlag",
                "AMST_MotherName","AMST_MotherAadharNo","AMST_MotherSurname","AMST_MotherEducation","AMST_MotherOccupation","AMST_MotherDesignation",
                "AMST_MotherMonIncome","AMST_MotherMobileNo","AMST_MotherEmailId","AMST_TotalIncome","AMST_BirthPlace","AMST_Nationality",
                "AMST_HostelReqdFlag","AMST_TransportReqdFlag","AMST_GymReqdFlag","AMST_ECSFlag","AMST_PaymentFlag","AMST_AmountPaid","AMST_PaymentType",
                "AMST_PaymentDate","AMST_ReceiptNo","AMST_ActiveFlag","AMST_ApplStatus","AMST_FinalpaymentFlag","AMST_FatherOfficeAdd",
                "AMST_FatherNationality","AMST_MotherNationality","AMST_BirthCertNO","AMST_PerAdd3","AMST_MotherOfficeAdd","AMST_SOL",
                "AMST_Concession_Type","IVRMMR_Id","IMCC_Id","IC_Id","AMST_Noofsisters","AMST_Noofbrothers","AMC_Id","AMST_Photoname",
                "AMST_DOB_Words","AMST_LanguageSpoken","CreatedDate","UpdatedDate"
            )
            SELECT 
                "MI_Id",p_ASMAY_Id,"PASR_FirstName","PASR_MiddleName","PASR_LastName",CURRENT_TIMESTAMP,"PASR_Sex","PASR_DOB","PASR_Age","ASMCL_Id",
                "PASR_BloodGroup","PASR_MotherTongue","PASR_PerStreet","PASR_PerArea","PASR_PerCity","PASR_PerState","PASR_PerCountry","PASR_PerPincode",
                "PASR_ConStreet","PASR_ConArea","PASR_ConCity","PASR_ConState","PASR_ConCountry","PASR_ConPincode","PASR_AadharNo","PASR_MobileNo",
                "PASR_emailId","PASR_FatherAliveFlag","PASR_FatherName","PASR_FatherAadharNo","PASR_FatherSurname","PASR_FatherEducation",
                "PASR_FatherOccupation","PASR_FatherDesignation","PASR_FatherIncome","PASR_FatherMobleNo","PASR_FatheremailId","PASR_MotherAliveFlag",
                "PASR_MotherName","PASR_MotherAadharNo","PASR_MotherSurname","PASR_MotherEducation","PASR_MotherOccupation","PASR_MotherDesignation",
                "PASR_MotherIncome","PASR_MotherMobleNo","PASR_MotheremailId","PASR_TotalIncome","PASR_BirthPlace","PASR_Nationality",
                "PASR_HostelReqdFlag","PASR_TransportReqdFlag","PASR_GymReqdFlag","PASR_ECSFlag","PASR_PaymentFlag","PASR_AmountPaid","PASR_PaymentType",
                "PASR_PaymentDate","PASR_ReceiptNo",v_activeflag,"PASR_ApplStatus","PASR_FinalpaymentFlag","PASR_FatherOfficeAddr",
                "PASR_FatherNationality","PASR_MotherNationality","PASR_BirthCertificateNo","PASR_OtherPermanentAddr","PASR_MotherOfficeAddr",v_studentstatus,
                "FMCC_ID","Religion_Id","CasteCategory_Id","Caste_Id","PASR_Noofbrothers","PASR_Noofsisters",v_AMC_Id,"PASR_Student_Pic_Path",
                "PASR_DOBwords","PASR_MotherTongue",CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
            FROM "Preadmission_School_Registration" 
            WHERE "PASR_Id" = p_PASR_Id;
                                      
            SELECT max("amst_id") INTO v_MaxAmst_Id 
            FROM "adm_m_student"
            LIMIT 1;
            
            INSERT INTO "Adm_Master_Student_PA" 
            VALUES(v_MaxAmst_Id, p_PASR_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            UPDATE "Adm_M_Student" 
            SET "AMST_MiddleName" = '' 
            WHERE "AMST_MiddleName" IS NULL 
                AND "AMST_Id" = v_MaxAmst_Id;
                
            UPDATE "Adm_M_Student" 
            SET "AMST_LastName" = '' 
            WHERE "AMST_LastName" IS NULL 
                AND "AMST_Id" = v_MaxAmst_Id;
                                       
            UPDATE "Preadmission_School_Registration" 
            SET "PASR_Adm_Confirm_Flag" = 1 
            WHERE "PASR_Id" = p_PASR_Id 
                AND "MI_Id" = p_MI_Id;

            SELECT "AMST_Id", "ASMCL_Id", "asmay_id" 
            INTO v_MaxAmst_Id, v_ASMSCL_Id, p_ASMAY_Id
            FROM "Adm_M_Student" 
            WHERE "amst_id" = v_MaxAmst_Id 
            ORDER BY "AMST_Id" DESC
            LIMIT 1;

            PERFORM "dbo"."Auto_Fee_Group_mapping"(p_MI_Id, p_ASMAY_Id, v_MaxAmst_Id, v_userid);

            FOR rec_feeinsert IN 
                SELECT DISTINCT "FYPAR"."fyp_id", "FYPPA_TotalPaidAmount" 
                FROM "Fee_Y_Payment_PA_Application" "FYPAR" 
                WHERE "PASA_Id" = p_PASR_Id 
                    AND ("FYPPA_Type" = 'A' OR "FYPPA_Type" = 'R')
            LOOP
                v_Fypid := rec_feeinsert."fyp_id";
                v_TotalAmount := rec_feeinsert."FYPPA_TotalPaidAmount";

                INSERT INTO "Fee_Y_Payment_School_Student" (
                    "FYP_Id","AMST_Id","ASMAY_Id","FTP_TotalPaidAmount","FTP_TotalWaivedAmount","FTP_TotalConcessionAmount","FTP_TotalFineAmount"
                ) 
                VALUES (v_Fypid, v_MaxAmst_Id, p_ASMAY_Id, v_TotalAmount, 0, 0, 0);

                FOR rec_feetinsert IN 
                    SELECT "FYPAR"."FYP_Id", "FTP_Paid_Amt", "FMA_Id" 
                    FROM "Fee_Y_Payment_PA_Application" "FYPAR" 
                    INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPAR"."FYP_Id" 
                    WHERE "PASA_Id" = p_PASR_Id 
                        AND "FTP"."fyp_id" = v_Fypid
                LOOP
                    v_Fypid := rec_feetinsert."FYP_Id";
                    v_TotaltAmount := rec_feetinsert."FTP_Paid_Amt";
                    v_Fmaid := rec_feetinsert."FMA_Id";

                    SELECT "FSS_ToBePaid" INTO v_PendingAmount
                    FROM "Fee_Student_Status" 
                    WHERE "AMST_Id" = v_MaxAmst_Id 
                        AND "FMA_Id" = v_Fmaid 
                        AND "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id;
                        
                    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
                    
                    IF v_rowcount > 0 THEN
                        UPDATE "Fee_Student_Status" 
                        SET "FSS_ToBePaid" = 0, "FSS_PaidAmount" = v_TotaltAmount 
                        WHERE "AMST_Id" = v_MaxAmst_Id 
                            AND "FMA_Id" = v_Fmaid 
                            AND "MI_Id" = p_MI_Id 
                            AND "ASMAY_Id" = p_ASMAY_Id;
                    END IF;

                END LOOP;

            END LOOP;

            SELECT "b"."FMCC_ConcessionFlag" INTO v_PRECONCESSIONCATEGORY
            FROM "Preadmission_School_Registration" AS "a" 
            INNER JOIN "Fee_Master_Concession" AS "b" ON "a"."FMCC_ID" = "b"."FMCC_Id"  
            WHERE "PASR_Id" = p_PASR_Id;

            IF (v_PRECONCESSIONCATEGORY = 'E') THEN
                RAISE NOTICE 'insert into employee table';
            ELSIF (v_PRECONCESSIONCATEGORY = 'G' OR v_PRECONCESSIONCATEGORY = 'R') THEN
                RAISE NOTICE 'insert into student table';
            END IF;

            SELECT "FMCC_ConcessionFlag" INTO v_CONCESSIONCATEGORY
            FROM "Adm_M_Student" 
            INNER JOIN "Fee_Master_Concession" ON "Adm_M_Student"."AMST_Concession_Type" = "Fee_Master_Concession"."FMCC_Id"
            WHERE "AMST_Id" = v_MaxAmst_Id 
                AND "Adm_M_Student"."MI_Id" = p_MI_Id;

            IF v_CONCESSIONCATEGORY = 'G' OR v_CONCESSIONCATEGORY = 'R' THEN
                PERFORM "dbo"."SAVE_CONCESSION_FOR_SIBLINGS_PREADMISSION"(p_MI_Id, p_ASMAY_Id, v_MaxAmst_Id, 0, 'Stud');
            ELSIF v_CONCESSIONCATEGORY = 'E' THEN
                PERFORM "dbo"."SAVE_CONCESSION_FOR_SIBLINGS_PREADMISSION"(p_MI_Id, p_ASMAY_Id, v_MaxAmst_Id, 0, 'stfoth');
            END IF;

            SELECT "PASR_Applicationno" INTO v_regno
            FROM "Preadmission_School_Registration" 
            WHERE "PASR_Id" = p_PASR_Id;

            UPDATE "Adm_M_Student" 
            SET "AMST_AdmNo" = v_regno, "AMST_RegistrationNo" = v_regno 
            WHERE "MI_Id" = p_MI_Id 
                AND "AMST_Id" = v_MaxAmst_Id;

            PERFORM "dbo"."StudentDetails"(v_MaxAmst_Id, p_PASR_Id, p_MI_Id);
            
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error occurred: %', SQLERRM;
            RAISE;
    END;

END;
$$;