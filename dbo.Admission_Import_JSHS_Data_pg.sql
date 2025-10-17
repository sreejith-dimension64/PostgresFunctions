CREATE OR REPLACE FUNCTION "dbo"."Admission_Import_JSHS_Data"(p_MI_Id TEXT)
RETURNS TABLE(
    "ErrorNumber" TEXT,
    "ErrorState" TEXT,
    "ErrorSeverity" TEXT,
    "ErrorProcedure" TEXT,
    "ErrorLine" TEXT,
    "ErrorMessage" TEXT,
    "admno" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_FirstName TEXT;
    v_AMST_MiddleName TEXT;
    v_AMST_LastName TEXT;
    v_AMST_Date TEXT;
    v_AMST_RegistrationNo TEXT;
    v_AMST_AdmNo TEXT;
    v_AMC_Id TEXT;
    v_AMST_Sex TEXT;
    v_AMST_DOB TEXT;
    v_AMST_DOB_Words TEXT;
    v_PASR_Age TEXT;
    v_ASMCL_Id TEXT;
    v_AMST_BloodGroup TEXT;
    v_AMST_MotherTongue TEXT;
    v_AMST_BirthCertNO TEXT;
    v_IVRMMR_Id TEXT;
    v_IMCC_Id TEXT;
    v_IC_Id TEXT;
    v_AMST_PerStreet TEXT;
    v_AMST_PerArea TEXT;
    v_AMST_PerCity TEXT;
    v_AMST_PerAdd3 TEXT;
    v_AMST_PerState TEXT;
    v_AMST_PerCountry TEXT;
    v_AMST_PerPincode TEXT;
    v_AMST_ConStreet TEXT;
    v_AMST_ConArea TEXT;
    v_AMST_ConCity TEXT;
    v_AMST_ConState TEXT;
    v_AMST_ConCountry TEXT;
    v_AMST_ConPincode TEXT;
    v_AMST_AadharNo TEXT;
    v_AMST_MobileNo TEXT;
    v_AMST_emailId TEXT;
    v_AMST_FatherAliveFlag TEXT;
    v_AMST_FatherName TEXT;
    v_AMST_FatherSurname TEXT;
    v_AMST_FatherEducation TEXT;
    v_AMST_FatherOccupation TEXT;
    v_AMST_FatherAnnIncome DECIMAL(18,2);
    v_AMST_FatherMobleNo TEXT;
    v_AMST_FatheremailId TEXT;
    v_AMST_MotherAliveFlag TEXT;
    v_AMST_MotherName TEXT;
    v_AMST_MotherSurname TEXT;
    v_AMST_MotherEducation TEXT;
    v_AMST_MotherOccupation TEXT;
    v_AMST_MotherAnnIncome DECIMAL(18,2);
    v_AMST_TotalIncome DECIMAL(18,2);
    v_AMST_BirthPlace TEXT;
    v_AMST_Nationality TEXT;
    v_AMST_HostelReqdFlag TEXT;
    v_AMST_TransportReqdFlag TEXT;
    v_AMST_ECSFlag TEXT;
    v_AMST_SOL TEXT;
    v_AMST_Concession_Type TEXT;
    v_AMST_Photoname TEXT;
    v_AdmittedYear TEXT;
    v_bplcardno TEXT;
    v_MotherMobileNo TEXT;
    v_MotherEmailId TEXT;
    v_StudentBankAccNo TEXT;
    v_StudentBankIFSC_Code TEXT;
    v_StuCasteCertiNo TEXT;
    v_amst_id BIGINT;
    v_AMST_Admno_New TEXT;
    v_ASMAY_Id_New TEXT;
    v_ASMCL_Id_New TEXT;
    v_ASMS_Id_New TEXT;
    v_ASMAY_RollNo TEXT;
    v_ASMAY_Id_New1 BIGINT;
    v_ASMCL_Id_New1 BIGINT;
    v_ASMS_Id_New1 BIGINT;
    v_ASMAY_RollNo1 BIGINT;
    v_YStRcount BIGINT;
    rec_student RECORD;
    rec_yearwise RECORD;
BEGIN

    BEGIN
        FOR rec_student IN 
            SELECT p_MI_Id AS "MI_Id",
                (SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" WHERE "MI_Id"=p_MI_Id AND "asmay_year"=S."admittedyear") AS "admittedyear",
                TRIM(S."FirstName") AS "FirstName",
                TRIM(S."MiddleName") AS "MiddleName",
                TRIM(S."LastName") AS "LastName",
                TO_DATE(S."AdmittedDate",'DD/MM/YYYY') AS "AdmittedDate",
                S."AMSTRegistrationNo",
                S."AMSTAdmNo",
                0 AS "AMC_Id",
                S."Gender",
                TO_DATE(S."DOB",'DD/MM/YYYY') AS "DOB",
                S."AMSTDOBWords",
                (EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, TO_DATE(S."DOB",'DD/MM/YYYY')))) AS "AMST_Age",
                (SELECT DISTINCT "ASMCL_Id" FROM "Adm_School_M_Class" WHERE "MI_Id"=p_MI_Id AND TRIM("ASMCL_ClassName")=TRIM(S."AdmittedClass")) AS "AdmittedClass",
                '' AS "BloodGroup",
                S."MotherTongue",
                '' AS "AMST_BirthCertNO",
                (SELECT DISTINCT "IVRMMR_Id" FROM "IVRM_Master_Religion" WHERE "IVRMMR_Name"=S."Religion") AS "Religion",
                COALESCE((SELECT DISTINCT "IMCC_Id" FROM "IVRM_Master_Caste_Category" WHERE TRIM("IMCC_CategoryName")=TRIM(S."Caste")),1) AS "Caste",
                COALESCE((SELECT DISTINCT "IMC_Id" FROM "IVRM_Master_Caste" WHERE "IMC_CasteName"=COALESCE(S."Caste",'General') AND "MI_Id"=p_MI_Id),11) AS "COMMUNITY",
                S."PermanentStreet",
                S."PermanentArea",
                S."PermanentCity",
                '' AS "AMST_PerAdd3",
                COALESCE((SELECT DISTINCT "IVRMMS_Id" FROM "ivrm_master_State" WHERE "IVRMMS_Name"=S."Permanentstate"),17) AS "Permanentstate",
                COALESCE((SELECT DISTINCT "IVRMMC_Id" FROM "ivrm_master_Country" WHERE "IVRMMC_CountryName"=S."PermanentCountry"),101) AS "PermanentCountry",
                S."PermanentPincode",
                S."PresentStreet",
                S."PresentArea",
                S."PresentCity",
                COALESCE((SELECT DISTINCT "IVRMMS_Id" FROM "ivrm_master_State" WHERE "IVRMMS_Name"=S."Presentstate"),17) AS "Presentstate",
                COALESCE((SELECT DISTINCT "IVRMMC_Id" FROM "ivrm_master_Country" WHERE "IVRMMC_CountryName"=S."PresentCountry"),127) AS "PresentCountry",
                S."PresentPincode",
                (CASE WHEN S."AadharNo"='' OR LENGTH(REPLACE(S."AadharNo",' ',''))>12 THEN 0 
                    WHEN LENGTH(REPLACE(S."AadharNo",' ',''))=12 THEN CAST(REPLACE(S."AadharNo",' ','') AS BIGINT) END) AS "AadharNo",
                S."MobileNo",
                S."EmailID",
                0 AS "AMST_FatherAliveFlag",
                S."FatherName",
                S."Fathersurname",
                '' AS "AMST_FatherEducation",
                '' AS "AMST_FatherOccupation",
                0 AS "AMST_FatherAnnIncome",
                S."Fathermobileno",
                S."FatherEmailId",
                0 AS "AMST_MotherAliveFlag",
                S."MotherName",
                S."MotherSurname",
                '' AS "AMST_MotherEducation",
                '' AS "AMST_MotherOccupation",
                0 AS "AMST_MotherAnnIncome",
                0 AS "AMST_TotalIncome",
                '' AS "AMST_BirthPlace",
                101 AS "StudentNationality",
                0 AS "AMST_HostelReqdFlag",
                0 AS "AMST_TransportReqdFlag",
                0 AS "AMST_ECSFlag",
                'S' AS "AMST_SOL",
                '' AS "AMST_Concession_Type",
                '' AS "AMST_GovtAdmno",
                S."MotherMobileNo",
                S."MotherEmailId",
                S."StudentBankAccNo",
                S."StudentBankIFSC_Code",
                S."StuCasteCertiNo"
            FROM "Kusuma_StudentsData_Import" S 
            WHERE S."AMSTAdmNo" != '217914402'
        LOOP
            v_MI_Id := rec_student."MI_Id";
            v_AdmittedYear := rec_student."admittedyear";
            v_AMST_FirstName := rec_student."FirstName";
            v_AMST_MiddleName := rec_student."MiddleName";
            v_AMST_LastName := rec_student."LastName";
            v_AMST_Date := rec_student."AdmittedDate"::TEXT;
            v_AMST_RegistrationNo := rec_student."AMSTRegistrationNo";
            v_AMST_AdmNo := rec_student."AMSTAdmNo";
            v_AMC_Id := rec_student."AMC_Id"::TEXT;
            v_AMST_Sex := rec_student."Gender";
            v_AMST_DOB := rec_student."DOB"::TEXT;
            v_AMST_DOB_Words := rec_student."AMSTDOBWords";
            v_PASR_Age := rec_student."AMST_Age"::TEXT;
            v_ASMCL_Id := rec_student."AdmittedClass"::TEXT;
            v_AMST_BloodGroup := rec_student."BloodGroup";
            v_AMST_MotherTongue := rec_student."MotherTongue";
            v_AMST_BirthCertNO := rec_student."AMST_BirthCertNO";
            v_IVRMMR_Id := rec_student."Religion"::TEXT;
            v_IMCC_Id := rec_student."Caste"::TEXT;
            v_IC_Id := rec_student."COMMUNITY"::TEXT;
            v_AMST_PerStreet := rec_student."PermanentStreet";
            v_AMST_PerArea := rec_student."PermanentArea";
            v_AMST_PerCity := rec_student."PermanentCity";
            v_AMST_PerAdd3 := rec_student."AMST_PerAdd3";
            v_AMST_PerState := rec_student."Permanentstate"::TEXT;
            v_AMST_PerCountry := rec_student."PermanentCountry"::TEXT;
            v_AMST_PerPincode := rec_student."PermanentPincode";
            v_AMST_ConStreet := rec_student."PresentStreet";
            v_AMST_ConArea := rec_student."PresentArea";
            v_AMST_ConCity := rec_student."PresentCity";
            v_AMST_ConState := rec_student."Presentstate"::TEXT;
            v_AMST_ConCountry := rec_student."PresentCountry"::TEXT;
            v_AMST_ConPincode := rec_student."PresentPincode";
            v_AMST_AadharNo := rec_student."AadharNo"::TEXT;
            v_AMST_MobileNo := rec_student."MobileNo";
            v_AMST_emailId := rec_student."EmailID";
            v_AMST_FatherAliveFlag := rec_student."AMST_FatherAliveFlag"::TEXT;
            v_AMST_FatherName := rec_student."FatherName";
            v_AMST_FatherSurname := rec_student."Fathersurname";
            v_AMST_FatherEducation := rec_student."AMST_FatherEducation";
            v_AMST_FatherOccupation := rec_student."AMST_FatherOccupation";
            v_AMST_FatherAnnIncome := rec_student."AMST_FatherAnnIncome";
            v_AMST_FatherMobleNo := rec_student."Fathermobileno";
            v_AMST_FatheremailId := rec_student."FatherEmailId";
            v_AMST_MotherAliveFlag := rec_student."AMST_MotherAliveFlag"::TEXT;
            v_AMST_MotherName := rec_student."MotherName";
            v_AMST_MotherSurname := rec_student."MotherSurname";
            v_AMST_MotherEducation := rec_student."AMST_MotherEducation";
            v_AMST_MotherOccupation := rec_student."AMST_MotherOccupation";
            v_AMST_MotherAnnIncome := rec_student."AMST_MotherAnnIncome";
            v_AMST_TotalIncome := rec_student."AMST_TotalIncome";
            v_AMST_BirthPlace := rec_student."AMST_BirthPlace";
            v_AMST_Nationality := rec_student."StudentNationality"::TEXT;
            v_AMST_HostelReqdFlag := rec_student."AMST_HostelReqdFlag"::TEXT;
            v_AMST_TransportReqdFlag := rec_student."AMST_TransportReqdFlag"::TEXT;
            v_AMST_ECSFlag := rec_student."AMST_ECSFlag"::TEXT;
            v_AMST_SOL := rec_student."AMST_SOL";
            v_AMST_Concession_Type := rec_student."AMST_Concession_Type";
            v_bplcardno := rec_student."AMST_GovtAdmno";
            v_MotherMobileNo := rec_student."MotherMobileNo";
            v_MotherEmailId := rec_student."MotherEmailId";
            v_StudentBankAccNo := rec_student."StudentBankAccNo";
            v_StudentBankIFSC_Code := rec_student."StudentBankIFSC_Code";
            v_StuCasteCertiNo := rec_student."StuCasteCertiNo";

            RAISE NOTICE '%', v_AMST_MobileNo;
            RAISE NOTICE '%', v_AMST_emailId;
            RAISE NOTICE '%', v_AMST_FatheremailId;
            RAISE NOTICE '%', v_AMST_FatherMobleNo;
            RAISE NOTICE '%', v_MotherMobileNo;
            RAISE NOTICE '%', v_MotherEmailId;

            IF v_AMST_FatherMobleNo = '' THEN
                v_AMST_FatherMobleNo := NULL;
            END IF;

            IF v_AMST_emailId = '' THEN
                v_AMST_emailId := NULL;
            END IF;

            v_AMST_Concession_Type := '1';

            IF v_IMCC_Id = '' THEN
                v_IMCC_Id := '1';
            END IF;

            IF v_IC_Id = '' THEN
                v_IC_Id := '11';
            END IF;

            IF v_AMST_PerState = '' THEN
                v_AMST_PerState := '17';
            END IF;

            IF v_AMST_PerCountry = '' THEN
                v_AMST_PerCountry := '101';
            END IF;

            SELECT DISTINCT b."ASMCC_Id" INTO v_AMC_Id
            FROM "Adm_M_Category" a 
            INNER JOIN "Adm_School_M_Class_Category" b ON a."AMC_Id" = b."AMC_Id" 
            INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = b."ASMCL_Id"
            WHERE b."ASMAY_Id" = v_AdmittedYear::BIGINT 
                AND b."ASMCL_Id" = v_ASMCL_Id::BIGINT 
                AND b."Is_Active" = 1;

            INSERT INTO "Adm_M_Student" (
                "MI_Id","ASMAY_Id","AMST_FirstName","AMST_MiddleName","AMST_LastName","AMST_Date","AMST_RegistrationNo","AMST_AdmNo","AMC_Id","AMST_Sex","AMST_DOB","AMST_DOB_Words","PASR_Age",
                "ASMCL_Id","AMST_BloodGroup","AMST_MotherTongue","AMST_BirthCertNO","IVRMMR_Id","IMCC_Id","IC_Id","AMST_PerStreet","AMST_PerArea","AMST_PerCity","AMST_PerAdd3","AMST_PerState","AMST_PerCountry",
                "AMST_PerPincode","AMST_ConStreet","AMST_ConArea","AMST_ConCity","AMST_ConState","AMST_ConCountry","AMST_ConPincode","AMST_AadharNo","AMST_MobileNo","AMST_emailId","AMST_FatherAliveFlag",
                "AMST_FatherName","AMST_FatherSurname","AMST_FatherEducation","AMST_FatherOccupation","AMST_FatherAnnIncome","AMST_FatherMobleNo","AMST_FatheremailId","AMST_MotherAliveFlag",
                "AMST_MotherName","AMST_MotherSurname","AMST_MotherEducation","AMST_MotherOccupation","AMST_MotherAnnIncome","AMST_TotalIncome","AMST_BirthPlace","AMST_Nationality","AMST_HostelReqdFlag",
                "AMST_TransportReqdFlag","AMST_ECSFlag","AMST_SOL","AMST_Concession_Type","AMST_GovtAdmno","CreatedDate","UpdatedDate","AMST_ActiveFlag","AMST_StuBankAccNo","AMST_StuBankIFSC_Code","AMST_StuCasteCertiNo"
            )
            VALUES(
                p_MI_Id::BIGINT, v_AdmittedYear::BIGINT, v_AMST_FirstName, v_AMST_MiddleName, v_AMST_LastName, v_AMST_Date::TIMESTAMP, v_AMST_RegistrationNo, v_AMST_AdmNo, v_AMC_Id::BIGINT, v_AMST_Sex, 
                v_AMST_DOB::TIMESTAMP, v_AMST_DOB_Words, v_PASR_Age::INT, v_ASMCL_Id::BIGINT, v_AMST_BloodGroup, v_AMST_MotherTongue, v_AMST_BirthCertNO, v_IVRMMR_Id::BIGINT, v_IMCC_Id::BIGINT, v_IC_Id::BIGINT,
                v_AMST_PerStreet, v_AMST_PerArea, v_AMST_PerCity, v_AMST_PerAdd3, v_AMST_PerState::BIGINT, v_AMST_PerCountry::BIGINT, NULL, v_AMST_ConStreet, v_AMST_ConArea, v_AMST_ConCity, 
                v_AMST_ConState::BIGINT, v_AMST_ConCountry::BIGINT, NULL, v_AMST_AadharNo::BIGINT, v_AMST_MobileNo, v_AMST_emailId, v_AMST_FatherAliveFlag::INT, v_AMST_FatherName, v_AMST_FatherSurname,
                v_AMST_FatherEducation, v_AMST_FatherOccupation, v_AMST_FatherAnnIncome::DECIMAL(18,2), v_AMST_FatherMobleNo, v_AMST_FatheremailId, v_AMST_MotherAliveFlag::INT, v_AMST_MotherName,
                v_AMST_MotherSurname, v_AMST_MotherEducation, v_AMST_MotherOccupation, v_AMST_MotherAnnIncome::DECIMAL(18,2), v_AMST_TotalIncome::DECIMAL(18,2), v_AMST_BirthPlace, v_AMST_Nationality::BIGINT,
                v_AMST_HostelReqdFlag::INT, v_AMST_TransportReqdFlag::INT, v_AMST_ECSFlag::INT, v_AMST_SOL, v_AMST_Concession_Type, v_bplcardno, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1,
                v_StudentBankAccNo, v_StudentBankIFSC_Code, v_StuCasteCertiNo
            );

            SELECT "AMST_Id" INTO v_amst_id 
            FROM "Adm_M_Student" 
            WHERE "MI_Id" = p_MI_Id::BIGINT 
                AND "AMST_AdmNo" = v_AMST_AdmNo 
            ORDER BY "AMST_Id" DESC 
            LIMIT 1;

            INSERT INTO "Adm_Master_Student_SMSNo" ("AMST_Id","AMSTSMS_MobileNo","CreatedDate","UpdatedDate") 
            VALUES(v_amst_id, v_AMST_MobileNo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            IF LENGTH(v_AMST_emailId) > 0 THEN
                INSERT INTO "Adm_Master_Student_EmailId" ("AMST_Id","AMSTE_EmailId","CreatedDate","UpdatedDate") 
                VALUES(v_amst_id, v_AMST_emailId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
            END IF;

            IF LENGTH(v_AMST_FatheremailId) > 0 THEN
                INSERT INTO "Adm_Master_FatherEmail_Id"("AMST_Id","AMST_FatheremailId","CreatedDate","UpdatedDate","MI_Id") 
                VALUES(v_amst_id, v_AMST_FatheremailId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_MI_Id::BIGINT);
            END IF;

            IF LENGTH(v_AMST_FatherMobleNo) > 0 THEN
                INSERT INTO "Adm_Master_FatherMobileNo"("AMST_Id","AMST_FatherMobile_No","CreatedDate","UpdatedDate","MI_Id") 
                VALUES(v_amst_id, v_AMST_FatherMobleNo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_MI_Id::BIGINT);
            END IF;

            IF LENGTH(v_MotherEmailId) > 0 THEN
                INSERT INTO "Adm_Master_MotherEmail_Id"("AMST_Id","AMST_MotherEmailId","CreatedDate","UpdatedDate","MI_Id") 
                VALUES(v_amst_id, v_MotherEmailId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_MI_Id::BIGINT);
            END IF;

            IF LENGTH(v_MotherMobileNo) > 0 THEN
                INSERT INTO "Adm_Master_MotherMobileNo"("AMST_Id","AMST_MotherMobileNo","CreatedDate","UpdatedDate","MI_Id") 
                VALUES(v_amst_id, v_MotherMobileNo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_MI_Id::BIGINT);
            END IF;

            FOR rec_yearwise IN 
                SELECT DISTINCT "AMSTRegistrationNo",
                    (SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" WHERE "MI_Id"=p_MI_Id AND "asmay_year"="currentyear") AS "currentyear",
                    (SELECT DISTINCT "ASMCL_Id" FROM "Adm_School_M_Class" WHERE "MI_Id"=p_MI_Id AND TRIM("ASMCL_ClassName")=TRIM("currentclass")) AS "currentclass",
                    (SELECT DISTINCT "ASMS_Id" FROM "Adm_School_M_section" WHERE "MI_Id"=p_MI_Id AND TRIM("ASMC_SectionName")=TRIM("CurrentSection")) AS "currentsection" 
                FROM "Kusuma_StudentsData_Import"  
                WHERE "AMSTAdmNo" = v_AMST_AdmNo
            LOOP
                v_AMST_Admno_New := rec_yearwise."AMSTRegistrationNo";
                v_ASMAY_Id_New := rec_yearwise."currentyear"::TEXT;
                v_ASMCL_Id_New := rec_yearwise."currentclass"::TEXT;
                v_ASMS_Id_New := rec_yearwise."currentsection"::TEXT;

                v_ASMAY_Id_New1 := v_ASMAY_Id_New::BIGINT;
                v_ASMCL_Id_New1 := v_ASMCL_Id_New::BIGINT;
                v_ASMS_Id_New1 := v_ASMS_Id_New::BIGINT;

                v_YStRcount := 0;

                SELECT COUNT(*) INTO v_YStRcount 
                FROM "Adm_School_Y_Student" 
                WHERE "AMST_Id" = v_amst_id 
                    AND "ASMCL_Id" = v_ASMCL_Id_New1 
                    AND "ASMS_Id" = v_ASMS_Id_New1 
                    AND "ASMAY_Id" = v_ASMAY_Id_New1;

                IF v_YStRcount = 0 THEN
                    INSERT INTO "Adm_School_Y_Student" ("AMST_Id","ASMCL_Id","ASMS_Id","ASMAY_Id","AMAY_RollNo","AMAY_PassFailFlag","LoginId","AMAY_DateTime","AMAY_ActiveFlag","CreatedDate","UpdatedDate") 
                    VALUES(v_amst_id, v_ASMCL_Id_New1, v_ASMS_Id_New1, v_ASMAY_Id_New1, 1, 0, 6, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END IF;
            END LOOP;

        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 
                SQLSTATE::TEXT,
                ''::TEXT,
                ''::TEXT,
                'Admission_Import_JSHS_Data'::TEXT,
                ''::TEXT,
                SQLERRM::TEXT,
                v_AMST_AdmNo::TEXT;
            RETURN;
    END;

    RETURN;
END;
$$;