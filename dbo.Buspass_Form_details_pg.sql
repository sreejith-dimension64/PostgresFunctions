CREATE OR REPLACE FUNCTION "dbo"."Buspass_Form_details"(
    p_amst TEXT,
    p_asta TEXT,
    p_mi_id TEXT,
    p_asmay_id BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "AMST_AdmNo" VARCHAR,
    "AMST_Photoname" VARCHAR,
    "ASTA_Landmark" VARCHAR,
    "ASTA_Regnew" VARCHAR,
    "ASTA_Phoneoff" VARCHAR,
    "ASTA_PhoneRes" VARCHAR,
    "ASTA_Id" BIGINT,
    "stuname" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASTA_AreaZoneName" VARCHAR,
    "AMST_PerStreet" VARCHAR,
    "AMST_ConCity" VARCHAR,
    "AMST_PerArea" VARCHAR,
    "AMST_PerPincode" VARCHAR,
    "AMST_BloodGroup" VARCHAR,
    "AMST_FatherName" VARCHAR,
    "ASTA_FatherMobileNo" VARCHAR,
    "ASTA_MotherMobileNo" VARCHAR,
    "AMST_emailId" VARCHAR,
    "IVRMMC_Id" BIGINT,
    "IVRMMC_CountryName" VARCHAR,
    "IVRMMS_Id" BIGINT,
    "IVRMMS_Name" VARCHAR,
    "fuyear" VARCHAR,
    "cuyear" VARCHAR,
    "fclass" VARCHAR,
    "appno" VARCHAR,
    "PickUp_Route" TEXT,
    "PickUp_Route_no" TEXT,
    "PickUp_Location" TEXT,
    "DropUp_Location" TEXT,
    "Drop_Route" TEXT,
    "Drop_Route_no" TEXT,
    "ASTA_ApplicationDate" TIMESTAMP,
    "ANST_MotherPhoto" VARCHAR,
    "ANST_FatherPhoto" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id",
        b."AMST_AdmNo",
        b."AMST_Photoname",
        a."ASTA_Landmark",
        a."ASTA_Regnew",
        a."ASTA_Phoneoff",
        a."ASTA_PhoneRes",
        a."ASTA_Id",
        (b."AMST_FirstName" || ' ' || b."AMST_MiddleName" || ' ' || b."AMST_LastName") as stuname,
        e."ASMCL_ClassName",
        a."ASTA_AreaZoneName",
        b."AMST_ConStreet" as "AMST_PerStreet",
        b."AMST_ConCity" as "AMST_ConCity",
        b."AMST_ConArea" as "AMST_PerArea",
        b."AMST_ConPincode" as "AMST_PerPincode",
        b."AMST_BloodGroup",
        b."AMST_FatherName",
        a."ASTA_FatherMobileNo",
        a."ASTA_MotherMobileNo",
        b."AMST_emailId",
        c."IVRMMC_Id",
        c."IVRMMC_CountryName",
        d."IVRMMS_Id",
        d."IVRMMS_Name",
        fyear."ASMAY_Year" as fuyear,
        cyear."ASMAY_Year" as cuyear,
        fclass."ASMCL_ClassName" as fclass,
        a."ASTA_ApplicationNo" as appno,
        (CASE 
            WHEN a."ASTA_PickUp_TRMR_Id" != 0 THEN 
                (SELECT DISTINCT r."TRMR_RouteName" 
                 FROM "trn"."tr_master_route" r 
                 WHERE r."mi_id" = p_mi_id AND r."trmr_id" = a."ASTA_PickUp_TRMR_Id")
            ELSE '--' 
        END) AS "PickUp_Route",
        (CASE 
            WHEN a."ASTA_PickUp_TRMR_Id" != 0 THEN 
                (SELECT DISTINCT r."TRMR_RouteNo" 
                 FROM "trn"."tr_master_route" r 
                 WHERE r."mi_id" = p_mi_id AND r."trmr_id" = a."ASTA_PickUp_TRMR_Id")
            ELSE '--' 
        END) AS "PickUp_Route_no",
        (CASE 
            WHEN a."ASTA_PickUp_TRML_Id" != 0 THEN 
                (SELECT DISTINCT l."TRML_LocationName" 
                 FROM "trn"."TR_Master_Location" l 
                 WHERE l."mi_id" = p_mi_id AND l."TRML_Id" = a."ASTA_PickUp_TRML_Id")
            ELSE '--' 
        END) AS "PickUp_Location",
        (CASE 
            WHEN a."ASTA_Drop_TRML_Id" != 0 THEN 
                (SELECT DISTINCT l."TRML_LocationName" 
                 FROM "trn"."TR_Master_Location" l 
                 WHERE l."mi_id" = p_mi_id AND l."TRML_Id" = a."ASTA_Drop_TRML_Id")
            ELSE '--' 
        END) AS "DropUp_Location",
        (CASE 
            WHEN a."ASTA_Drop_TRMR_Id" != 0 THEN 
                (SELECT DISTINCT r."TRMR_RouteName" 
                 FROM "trn"."tr_master_route" r 
                 WHERE r."mi_id" = p_mi_id AND r."trmr_id" = a."ASTA_Drop_TRMR_Id")
            ELSE '--' 
        END) AS "Drop_Route",
        (CASE 
            WHEN a."ASTA_Drop_TRMR_Id" != 0 THEN 
                (SELECT DISTINCT r."TRMR_RouteNo" 
                 FROM "trn"."tr_master_route" r 
                 WHERE r."mi_id" = p_mi_id AND r."trmr_id" = a."ASTA_Drop_TRMR_Id")
            ELSE '--' 
        END) AS "Drop_Route_no",
        a."ASTA_ApplicationDate" AS "ASTA_ApplicationDate",
        b."ANST_MotherPhoto",
        b."ANST_FatherPhoto"
    FROM "Adm_Student_Transport_Application" AS a
    INNER JOIN "adm_m_student" AS b ON a."amst_id" = b."amst_id"
    INNER JOIN "IVRM_Master_Country" AS c ON c."IVRMMC_Id" = b."AMST_ConCountry"
    INNER JOIN "IVRM_Master_State" AS d ON d."IVRMMS_Id" = b."AMST_ConState"
    INNER JOIN "Adm_School_M_Class" AS e ON e."ASMCL_Id" = a."ASTA_CurrentClass"
    INNER JOIN "Adm_School_M_Academic_Year" AS cyear ON cyear."ASMAY_Id" = a."ASTA_CurrentAY"
    INNER JOIN "Adm_School_M_Academic_Year" AS fyear ON fyear."ASMAY_Id" = a."ASTA_FutureAY"
    INNER JOIN "Adm_School_M_Class" AS fclass ON fclass."ASMCL_Id" = a."ASTA_FutureClass"
    WHERE a."MI_Id" = p_mi_id 
        AND b."MI_Id" = p_mi_id 
        AND b."AMST_ActiveFlag" = 1 
        AND b."amst_sol" = 'S'
        AND a."amst_id" = p_amst::BIGINT
        AND a."ASTA_Id" = p_asta::BIGINT;
END;
$$;