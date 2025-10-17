CREATE OR REPLACE FUNCTION "dbo"."Export_from_preadmission_to_admission_Update"(
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
    v_ASMSCL_Id bigint;
    v_ASMS_Id bigint;
    v_Fypid bigint;
    v_TotalAmount bigint;
    v_Fmaid bigint;
    v_PendingAmount bigint;
    v_TotalAmountReg bigint;
    v_row_count integer;
    fee_record RECORD;
BEGIN
    v_studentstatus := 'S';
    v_activeflag := 1;
    v_concesseion := 0;

    BEGIN
        INSERT INTO "dbo"."Adm_M_Student_New"("PASR_ID","MI_Id","ASMAY_Id","AMST_FirstName","AMST_MiddleName","AMST_LastName","AMST_Date","AMST_RegistrationNo","AMST_Sex","AMST_DOB","PASR_Age","ASMCL_Id","AMST_BloodGroup","AMST_MotherTongue","AMST_PerStreet","AMST_PerArea","AMST_PerCity","AMST_PerState","AMST_PerCountry","AMST_PerPincode","AMST_ConStreet","AMST_ConArea","AMST_ConCity","AMST_ConState","AMST_ConCountry","AMST_ConPincode","AMST_AadharNo","AMST_MobileNo","AMST_emailId","AMST_FatherAliveFlag","AMST_FatherName","AMST_FatherAadharNo","AMST_FatherSurname","AMST_FatherEducation","AMST_FatherOccupation","AMST_FatherDesignation","AMST_FatherAnnIncome","AMST_FatherMobleNo","AMST_FatheremailId","AMST_MotherAliveFlag","AMST_MotherName","AMST_MotherAadharNo","AMST_MotherSurname","AMST_MotherEducation","AMST_MotherOccupation","AMST_MotherDesignation","AMST_MotherAnnIncome","AMST_MotherMobileNo","AMST_MotherEmailId","AMST_TotalIncome","AMST_BirthPlace","AMST_Nationality","AMST_HostelReqdFlag","AMST_TransportReqdFlag","AMST_GymReqdFlag","AMST_ECSFlag","AMST_PaymentFlag","AMST_AmountPaid","AMST_PaymentType","AMST_PaymentDate","AMST_ReceiptNo","AMST_ActiveFlag","AMST_ApplStatus","AMST_FinalpaymentFlag","AMST_FatherOfficeAdd","AMST_FatherNationality","AMST_MotherNationality","AMST_BirthCertNO","AMST_PerAdd3","AMST_MotherOfficeAdd","AMST_SOL","AMST_Concession_Type","IVRMMR_Id","IMCC_Id","IC_Id","AMST_Noofsisters","AMST_Noofbrothers")
        SELECT "PASR_Id","MI_Id","ASMAY_Id","PASR_FirstName","PASR_MiddleName","PASR_LastName",CURRENT_TIMESTAMP,"PASR_RegistrationNo","PASR_Sex","PASR_DOB","PASR_Age","ASMCL_Id","PASR_BloodGroup","PASR_MotherTongue","PASR_PerStreet","PASR_PerArea","PASR_PerCity","PASR_PerState","PASR_PerCountry","PASR_PerPincode","PASR_ConStreet","PASR_ConArea","PASR_ConCity","PASR_ConState","PASR_ConCountry","PASR_ConPincode","PASR_AadharNo","PASR_MobileNo","PASR_emailId","PASR_FatherAliveFlag","PASR_FatherName","PASR_FatherAadharNo","PASR_FatherSurname","PASR_FatherEducation","PASR_FatherOccupation","PASR_FatherDesignation","PASR_FatherIncome","PASR_FatherMobleNo","PASR_FatheremailId","PASR_MotherAliveFlag","PASR_MotherName","PASR_MotherAadharNo","PASR_MotherSurname","PASR_MotherEducation","PASR_MotherOccupation","PASR_MotherDesignation","PASR_MotherIncome","PASR_MotherMobleNo","PASR_MotheremailId","PASR_TotalIncome","PASR_BirthPlace","PASR_Nationality","PASR_HostelReqdFlag","PASR_TransportReqdFlag","PASR_GymReqdFlag","PASR_ECSFlag","PASR_PaymentFlag","PASR_AmountPaid","PASR_PaymentType","PASR_PaymentDate","PASR_ReceiptNo",v_activeflag,"PASR_ApplStatus","PASR_FinalpaymentFlag","PASR_FatherOfficeAddr","PASR_FatherNationality","PASR_MotherNationality","PASR_BirthCertificateNo","PASR_OtherPermanentAddr","PASR_MotherOfficeAddr",v_studentstatus,v_concesseion,"Religion_Id","CasteCategory_Id","Caste_Id","PASR_Noofbrothers","PASR_Noofsisters"
        FROM "dbo"."Preadmission_School_Registration_New" WHERE "PASR_Id" = p_PASR_Id;

        UPDATE "dbo"."Preadmission_School_Registration_New" 
        SET "PASR_Adm_Confirm_Flag" = 1 
        WHERE "PASR_Id" = p_PASR_Id AND "MI_Id" = p_MI_Id;

        SELECT "AMST_Id" INTO v_MaxAmst_Id 
        FROM "dbo"."Adm_M_Student_New" 
        WHERE "PASR_ID" = p_PASR_Id;

        PERFORM "dbo"."Auto_Fee_Group_mapping_Update"(p_MI_Id, p_ASMAY_Id, v_MaxAmst_Id, v_MaxAmst_Id);

        SELECT "FYPPAA"."FYP_Id", "FMA_Id", "FYPPA_TotalPaidAmount" 
        INTO v_Fypid, v_Fmaid, v_TotalAmountReg
        FROM "dbo"."Fee_Y_Payment_PA_Application_New" "FYPPAA" 
        INNER JOIN "dbo"."Fee_T_Payment_New" "FTP" ON "FTP"."FYP_Id" = "FYPPAA"."FYP_Id" 
        WHERE "PASA_Id" = p_PASR_Id;
        
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        
        IF v_row_count > 0 THEN
            INSERT INTO "dbo"."Fee_Y_Payment_School_Student_New" ("FYP_Id","AMST_Id","ASMAY_Id","FTP_TotalPaidAmount","FTP_TotalWaivedAmount","FTP_TotalConcessionAmount","FTP_TotalFineAmount") 
            VALUES (v_Fypid, v_MaxAmst_Id, p_ASMAY_Id, v_TotalAmountReg, 0, 0, 0);

            SELECT "FSS_ToBePaid" INTO v_PendingAmount 
            FROM "dbo"."Fee_Student_Status_New" 
            WHERE "AMST_Id" = v_MaxAmst_Id AND "FMA_Id" = v_Fmaid AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;
            
            GET DIAGNOSTICS v_row_count = ROW_COUNT;
            
            IF v_row_count > 0 THEN
                v_PendingAmount := v_PendingAmount - v_TotalAmount;
                UPDATE "dbo"."Fee_Student_Status_New" 
                SET "FSS_ToBePaid" = v_PendingAmount, "FSS_PaidAmount" = v_TotalAmount 
                WHERE "AMST_Id" = v_MaxAmst_Id AND "FMA_Id" = v_Fmaid AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;
            END IF;
        END IF;

        FOR fee_record IN 
            SELECT "FYPAR"."FYP_Id", "FYPPR_TotalPaidAmount", "FMA_Id" 
            FROM "dbo"."Fee_Y_Payment_PA_Registration_New" "FYPAR" 
            INNER JOIN "dbo"."Fee_T_Payment_New" "FTP" ON "FTP"."FYP_Id" = "FYPAR"."FYP_Id" 
            WHERE "PASR_Id" = p_PASR_Id
        LOOP
            v_Fypid := fee_record."FYP_Id";
            v_TotalAmount := fee_record."FYPPR_TotalPaidAmount";
            v_Fmaid := fee_record."FMA_Id";

            INSERT INTO "dbo"."Fee_Y_Payment_School_Student_New" ("FYP_Id","AMST_Id","ASMAY_Id","FTP_TotalPaidAmount","FTP_TotalWaivedAmount","FTP_TotalConcessionAmount","FTP_TotalFineAmount") 
            VALUES (v_Fypid, v_MaxAmst_Id, p_ASMAY_Id, v_TotalAmount, 0, 0, 0);

            SELECT "FSS_ToBePaid" INTO v_PendingAmount 
            FROM "dbo"."Fee_Student_Status_New" 
            WHERE "AMST_Id" = v_MaxAmst_Id AND "FMA_Id" = v_Fmaid AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;
            
            GET DIAGNOSTICS v_row_count = ROW_COUNT;
            
            IF v_row_count > 0 THEN
                v_PendingAmount := v_PendingAmount - v_TotalAmount;
                UPDATE "dbo"."Fee_Student_Status_New" 
                SET "FSS_ToBePaid" = v_PendingAmount, "FSS_PaidAmount" = v_TotalAmount 
                WHERE "AMST_Id" = v_MaxAmst_Id AND "FMA_Id" = v_Fmaid AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    RETURN;
END;
$$;