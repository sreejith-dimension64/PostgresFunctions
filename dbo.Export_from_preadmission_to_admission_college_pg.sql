CREATE OR REPLACE FUNCTION "dbo"."Export_from_preadmission_to_admission_college"(
    p_PACA_Id bigint,
    p_ASMAY_Id bigint,
    p_MI_Id bigint,
    p_user_id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_StudentStatus varchar(20);
    v_insertAMCST_Id text;
    v_MaxAMCST_Id bigint;
    v_Activeflag bigint;
    v_Concesseion bigint;
    v_pasrcount bigint;
    v_AMCO_Id bigint;
    v_AMB_Id bigint;
    v_AMSE_Id bigint;
    v_ACST_Id bigint;
    v_ACSS_Id bigint;
    v_Fypid bigint;
    v_TotalAmount bigint;
    v_Fmaid bigint;
    v_PendingAmount bigint;
    v_TotalAmountReg bigint;
    v_AMC_Id bigint;
    v_userid bigint;
    v_TotaltAmount bigint;
    v_Admno text;
    v_regno text;
    v_Admno1 text;
    v_regno1 text;
    v_FCMAS_Id bigint;
    v_ACMS_Id bigint;
    v_ACMB_Id bigint;
    v_ACQ_Id bigint;
    v_ACQC_Id bigint;
    v_rowcount integer;
    rec_feeinsert record;
    rec_feetinsert record;
BEGIN

    v_studentstatus := 'S';
    v_activeflag := 1;
    v_concesseion := 1;

    BEGIN

        SELECT "ASMCC"."AMCOC_Id" INTO v_AMC_Id
        FROM "CLG"."PA_College_Application" "PSR" 
        INNER JOIN "CLG"."Adm_Master_College_Category" "ASMCC" 
            ON "PSR"."AMCOC_Id" = "ASMCC"."AMCOC_Id" 
            AND "PSR"."MI_Id" = "ASMCC"."MI_Id"  
        WHERE "PACA_Id" = p_PACA_Id 
            AND "PSR"."MI_Id" = p_MI_Id 
            AND "PSR"."ASMAY_Id" = p_ASMAY_Id;

        RAISE NOTICE 'AMC_Id: %', v_AMC_Id;

        SELECT "a"."Id" INTO v_userid
        FROM "ApplicationUser" AS "a" 
        INNER JOIN "ApplicationUserRole" AS "b" ON "a"."Id" = "b"."UserId" 
        INNER JOIN "IVRM_Role_Type" AS "c" ON "c"."IVRMRT_Id" = "b"."RoleTypeId" 
        WHERE "c"."IVRMRT_Role" = 'ADMIN'
        LIMIT 1;

        IF (COALESCE(v_userid, 0) = 0) THEN
            SELECT "a"."Id" INTO v_userid
            FROM "ApplicationUser" AS "a" 
            INNER JOIN "ApplicationUserRole" AS "b" ON "a"."Id" = "b"."UserId" 
            INNER JOIN "IVRM_Role_Type" AS "c" ON "c"."IVRMRT_Id" = "b"."RoleTypeId" 
            WHERE "c"."IVRMRT_Role" = 'Staff'
            LIMIT 1;
        END IF;

        SELECT count(*) INTO v_pasrcount 
        FROM "Adm_Master_College_Student_PA" 
        WHERE "PACA_Id" = p_PACA_Id;

        IF (v_pasrcount = 0) THEN

            RAISE NOTICE '21';

            SELECT "ACMS_Id" INTO v_ACMS_Id 
            FROM "clg"."Adm_College_Master_Section" 
            WHERE "MI_Id" = p_MI_Id AND "ACMS_ActiveFlag" = 1 
            LIMIT 1;

            SELECT "ACST_Id" INTO v_ACST_Id 
            FROM "clg"."Adm_College_SchemeType" 
            WHERE "MI_Id" = p_MI_Id AND "ACST_ActiveFlg" = 1 
            LIMIT 1;

            SELECT "ACSS_Id" INTO v_ACSS_Id 
            FROM "clg"."Adm_College_SubjectScheme" 
            WHERE "MI_Id" = p_MI_Id AND "ACST_ActiveFlg" = 1 
            LIMIT 1;

            SELECT "ACQ_Id" INTO v_ACQ_Id 
            FROM "clg"."Adm_College_Quota" 
            WHERE "MI_Id" = p_MI_Id AND "ACQ_ActiveFlg" = 1 
            LIMIT 1;

            SELECT "ACQC_Id" INTO v_ACQC_Id 
            FROM "clg"."Adm_College_Quota_Category" 
            WHERE "MI_Id" = p_MI_Id AND "ACQC_ActiveFlg" = 1 
            LIMIT 1;

            SELECT "ACMB_Id" INTO v_ACMB_Id 
            FROM "clg"."Adm_College_Master_Batch" 
            WHERE "MI_Id" = p_MI_Id AND "ACMSN_ActiveFlag" = 1 
            LIMIT 1;

            RAISE NOTICE 'ACMS_Id: %', v_ACMS_Id;
            RAISE NOTICE 'ACST_Id: %', v_ACST_Id;
            RAISE NOTICE 'ACSS_Id: %', v_ACSS_Id;
            RAISE NOTICE 'ACQ_Id: %', v_ACQ_Id;
            RAISE NOTICE 'ACQC_Id: %', v_ACQC_Id;
            RAISE NOTICE 'ACMB_Id: %', v_ACMB_Id;

            SELECT max("AMCST_Id") INTO v_MaxAMCST_Id 
            FROM "CLG"."Adm_Master_College_Student" 
            LIMIT 1;

            INSERT INTO "CLG"."Adm_Master_College_Student" (
                "MI_Id","ASMAY_Id","AMCST_FirstName","AMCST_MiddleName","AMCST_LastName","AMCST_Date","AMCST_Sex","AMCST_DOB","AMCST_Age",
                "AMCO_Id","AMB_Id","AMSE_Id","ACST_Id","ACSS_Id","AMCST_BloodGroup","AMCST_PerStreet","AMCST_PerArea","AMCST_PerCity",
                "AMCST_PerState","IVRMMC_Id","AMCST_PerPincode","AMCST_ConStreet","AMCST_ConArea","AMCST_ConCity","AMCST_ConState","AMCST_ConCountryId","AMCST_ConPincode","AMCST_AadharNo","AMCST_MobileNo",
                "AMCST_emailId","AMCST_FatherAliveFlag","AMCST_FatherName","AMCST_FatherAadharNo","AMCST_FatherSurname","AMCST_FatherEducation","AMCST_FatherOccupation","AMCST_FatherDesignation",
                "AMCST_FatherMonIncome","AMCST_FatherAnnIncome","AMCST_FatherMobleNo","AMCST_FatheremailId","AMCST_MotherAliveFlag","AMCST_MotherName","AMCST_MotherAadharNo","AMCST_MotherSurname",
                "AMCST_MotherEducation","AMCST_MotherOccupation","AMCST_MotherDesignation","AMCST_MotherMonIncome","AMCST_MotherAnnIncome",
                "AMCST_MotherMobleNo","AMCST_MotherEmailId","AMCST_TotalIncome","AMCST_BirthPlace","AMCST_Nationality","AMCST_HostelReqdFlag","AMCST_TransportReqdFlag","AMCST_GymReqdFlag","AMCST_ECSFlag",
                "AMCST_PaymentFlag","AMCST_AmountPaid","AMCST_PaymentType","AMCST_PaymentDate","AMCST_ReceiptNo","AMCST_ActiveFlag","AMCST_ApplStatus","AMCST_FinalpaymentFlag","AMCST_FatherOfficeAdd",
                "AMCST_FatherNationality","AMCST_MotherNationality","AMCST_BirthCertNO","AMCST_PerAdd3","AMCST_MotherOfficeAdd","AMCST_SOL","IVRMMR_Id","IMCC_Id","IMC_Id","AMCST_Noofsisters","AMCST_Noofbrothers",
                "AMCOC_Id","AMCST_StudentPhoto","AMCST_DOBin_words","AMCST_MotherTongue","CreatedDate","UpdatedDate","AMCST_FatherPhoto","AMCST_MotherPhoto","ACMB_Id","ACQ_Id","ACQC_Id"
            )     
            SELECT 
                "MI_Id","ASMAY_Id","PACA_FirstName","PACA_MiddleName","PACA_LastName",CURRENT_TIMESTAMP AS "PACA_Date","PACA_Sex","PACA_DOB","PACA_Age",
                "AMCO_Id","AMB_Id","AMSE_Id",v_ACST_Id,v_ACSS_Id,"PACA_BloodGroup","PACA_PerStreet","PACA_PerArea","PACA_PerCity",
                CASE WHEN COALESCE("PACA_PerState", 0) = 0 THEN 17 ELSE "PACA_PerState" END AS "PACA_PerState",
                CASE WHEN COALESCE("IVRMMC_Id", 0) = 0 THEN 101 ELSE "IVRMMC_Id" END AS "IVRMMC_Id","PACA_PerPincode",
                "PACA_ConStreet","PACA_ConArea","PACA_ConCity",
                CASE WHEN COALESCE("PACA_ConState", 0) = 0 THEN 17 ELSE "PACA_ConState" END AS "PACA_ConState",
                "PACA_ConCountryId","PACA_ConPincode","PACA_AadharNo","PACA_MobileNo",
                "PACA_emailId","PACA_FatherAliveFlag","PACA_FatherName","PACA_FatherAadharNo","PACA_FatherSurname","PACA_FatherEducation","PACA_FatherOccupation","PACA_FatherDesignation",
                "PACA_FatherMonIncome","PACA_FatherAnnIncome","PACA_FatherMobleNo","PACA_FatheremailId","PACA_MotherAliveFlag","PACA_MotherName","PACA_MotherAadharNo","PACA_MotherSurname",
                "PACA_MotherEducation","PACA_MotherOccupation","PACA_MotherDesignation","PACA_MotherMonIncome","PACA_MotherAnnIncome",
                "PACA_MotherMobleNo","PACA_MotheremailId","PACA_TotalIncome","PACA_BirthPlace","PACA_Nationality","PACA_HostelReqdFlag","PACA_TransportReqdFlag","PACA_GymReqdFlag","PACA_ECSFlag",
                "PACA_PaymentFlag","PACA_AmountPaid","PACA_PaymentType","PACA_PaymentDate","PACA_ReceiptNo",v_activeflag AS "PACA_ActiveFlag","PACA_ApplStatus","PACA_FinalpaymentFlag","PACA_FatherOfficeAdd",
                "PACA_FatherNationality","PACA_MotherNationality","PACA_BirthCertNo","PACA_PerAdd3","PACA_MotherOfficeAdd",v_studentstatus AS studentstatus,"IVRMMR_Id","IMCC_Id","IMC_Id","PACA_Noofsisters","PACA_Noofbrothers",
                v_AMC_Id AS "AMC_Id","PACA_StudentPhoto","PACA_DOB_inwords","PACA_MotherTongue",CURRENT_TIMESTAMP AS createddate,CURRENT_TIMESTAMP AS updateddate,"PACA_FatherPhoto","PACA_MotherPhoto",
                v_ACMB_Id AS "ACMB_Id",COALESCE("ACQ_Id", v_ACQ_Id) AS "ACQ_Id",COALESCE("ACQC_Id", v_ACQC_Id) AS "ACQC_Id"
            FROM "CLG"."PA_College_Application" 
            WHERE "PACA_Id" = p_PACA_Id;

            RAISE NOTICE '1';

            SELECT max("AMCST_Id") INTO v_MaxAMCST_Id 
            FROM "CLG"."Adm_Master_College_Student" 
            LIMIT 1;

            RAISE NOTICE 'MaxAMCST_Id: %', v_MaxAMCST_Id;
            RAISE NOTICE 'PACA_Id: %', p_PACA_Id;
            RAISE NOTICE 'user_id: %', p_user_id;

            INSERT INTO "Adm_Master_College_Student_PA"(
                "AMCST_Id","PACA_Id","CreatedDate","UpdatedDate","AMCSTPA_CreatedBy","AMCSTPA_UpdatedBy"
            ) 
            VALUES (v_MaxAMCST_Id, p_PACA_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_user_id, p_user_id);

            RAISE NOTICE 'MaxAMCST_Id: %', v_MaxAMCST_Id;

            UPDATE "CLG"."Adm_Master_College_Student" 
            SET "AMCST_MiddleName" = '' 
            WHERE "AMCST_MiddleName" IS NULL AND "AMCST_Id" = v_MaxAMCST_Id;

            UPDATE "CLG"."Adm_Master_College_Student" 
            SET "AMCST_LastName" = '' 
            WHERE "AMCST_LastName" IS NULL AND "AMCST_Id" = v_MaxAMCST_Id;

            UPDATE "CLG"."PA_College_Application" 
            SET "PACA_AdmStatus" = (
                SELECT "PAMST_Id" 
                FROM "Preadmission_Master_Status" 
                WHERE "PAMST_StatusFlag" = 'CNF' AND "mi_id" = p_MI_Id
            ) 
            WHERE "PACA_Id" = p_PACA_Id AND "MI_Id" = p_MI_Id;

            RAISE NOTICE 'hi';

            SELECT "AMCST_Id","AMCO_Id","AMB_Id","AMSE_Id","ACST_Id","ACSS_Id","ASMAY_Id" 
            INTO v_MaxAMCST_Id, v_AMCO_Id, v_AMB_Id, v_AMSE_Id, v_ACST_Id, v_ACSS_Id, p_ASMAY_Id
            FROM "CLG"."Adm_Master_College_Student" 
            WHERE "AMCST_Id" = v_MaxAMCST_Id 
            ORDER BY "AMCST_Id" DESC 
            LIMIT 1;

            INSERT INTO "CLG"."Adm_College_Yearly_Student"(
                "AMCST_Id","ASMAY_Id","AMCO_Id","AMB_Id","AMSE_Id","ACMS_Id","ACYST_RollNo","AYST_PassFailFlag","LoginId","ACYST_DateTime","ACYST_ActiveFlag","CreatedDate","UpdatedDate"
            )
            VALUES(v_MaxAMCST_Id, p_ASMAY_Id, v_AMCO_Id, v_AMB_Id, v_AMSE_Id, v_ACMS_Id, 1, 0, p_user_id, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            SELECT "PACA_RegistrationNo" INTO v_regno
            FROM "CLG"."PA_College_Application" 
            WHERE "PACA_Id" = p_PACA_Id;

            RAISE NOTICE 'regno: %', v_regno;

            UPDATE "CLG"."Adm_Master_College_Student" 
            SET "AMCST_AdmNo" = v_regno,
                "AMCST_RegistrationNo" = v_regno,
                "AMCST_BPLCardFlag" = 0,
                "AMCST_NoofSiblingsSchool" = 0,
                "AMCST_NoofSiblings" = 0,
                "AMCST_NoofDependencies" = 0
            WHERE "MI_Id" = p_MI_Id AND "AMCST_Id" = v_MaxAMCST_Id;

            FOR rec_feeinsert IN
                SELECT DISTINCT "FYPAR"."fyp_id", "FYPPA_TotalPaidAmount" 
                FROM "CLG"."Fee_Y_Payment_PA_Application" "FYPAR" 
                WHERE "PACA_Id" = p_PACA_Id AND ("FYPPA_Type" = 'A' OR "FYPPA_Type" = 'R')
            LOOP
                v_Fypid := rec_feeinsert."fyp_id";
                v_TotalAmount := rec_feeinsert."FYPPA_TotalPaidAmount";

                INSERT INTO "CLG"."Fee_Y_Payment_College_Student" (
                    "FYP_Id","AMCST_Id","ASMAY_Id","FYPCS_TotalPaidAmount","FYPCS_TotalWaivedAmount","FYPCS_TotalConcessionAmount","FYPCS_TotalFineAmount"
                ) 
                VALUES (v_Fypid, v_MaxAMCST_Id, p_ASMAY_Id, v_TotalAmount, 0, 0, 0);

                FOR rec_feetinsert IN
                    SELECT "FYPAR"."FYP_Id", "FTCP_PaidAmount", "FTP"."FCMAS_Id" 
                    FROM "CLG"."Fee_Y_Payment_PA_Application" "FYPAR" 
                    INNER JOIN "CLG"."Fee_T_College_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPAR"."FYP_Id" 
                    WHERE "PACA_Id" = p_PACA_Id AND "FTP"."fyp_id" = v_Fypid
                LOOP
                    v_Fypid := rec_feetinsert."FYP_Id";
                    v_TotaltAmount := rec_feetinsert."FTCP_PaidAmount";
                    v_FCMAS_Id := rec_feetinsert."FCMAS_Id";

                    SELECT "FCSS_ToBePaid" INTO v_PendingAmount
                    FROM "CLG"."Fee_College_Student_Status" 
                    WHERE "AMCST_Id" = v_MaxAMCST_Id 
                        AND "FCMAS_Id" = v_FCMAS_Id 
                        AND "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id;

                    GET DIAGNOSTICS v_rowcount = ROW_COUNT;

                    IF v_rowcount > 0 THEN
                        UPDATE "CLG"."Fee_College_Student_Status" 
                        SET "FCSS_ToBePaid" = 0,
                            "FCSS_PaidAmount" = v_TotaltAmount 
                        WHERE "AMCST_Id" = v_MaxAMCST_Id 
                            AND "FCMAS_Id" = v_FCMAS_Id 
                            AND "MI_Id" = p_MI_Id 
                            AND "ASMAY_Id" = p_ASMAY_Id;
                    END IF;

                END LOOP;

            END LOOP;

            PERFORM "dbo"."StudentDetails_College"(v_MaxAMCST_Id, p_PACA_Id, p_MI_Id);
            PERFORM "dbo"."College_Admission_Generate_Tpin"(p_MI_Id, v_MaxAMCST_Id);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

END;
$$;