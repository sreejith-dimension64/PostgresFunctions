CREATE OR REPLACE FUNCTION "dbo"."findroutes"()
RETURNS TABLE(
    "amst_id" BIGINT,
    "AMST_AdmNo" VARCHAR(100),
    "STUDENTNAME" VARCHAR(100),
    "ASMCL_ClassName" VARCHAR(100),
    "ASMC_SectionName" VARCHAR(100),
    "FMG_GroupName" VARCHAR(100),
    "PickUp_RouteName" TEXT,
    "Drop_RouteName" TEXT,
    "PickUp_Location" TEXT,
    "Drop_Location" TEXT,
    "StudentMobileNo" TEXT,
    "FatherMobileNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_routeids BIGINT;
    v_amst_id BIGINT;
    v_AMST_AdmNo VARCHAR(100);
    v_STUDENTNAME VARCHAR(100);
    v_ASMCL_ClassName VARCHAR(100);
    v_ASMC_SectionName VARCHAR(100);
    v_FMG_GroupName VARCHAR(100);
    v_PickUp_RouteName TEXT;
    v_Drop_RouteName TEXT;
    v_PickUp_Location TEXT;
    v_Drop_Location TEXT;
    v_StudentMobileNo TEXT;
    v_FatherMobileNo TEXT;
    rec RECORD;
BEGIN
    DROP TABLE IF EXISTS "Allroutenames";
    
    CREATE TEMP TABLE "Allroutenames"(
        "amst_id" BIGINT,
        "AMST_AdmNo" VARCHAR(100),
        "STUDENTNAME" VARCHAR(100),
        "ASMCL_ClassName" VARCHAR(100),
        "ASMC_SectionName" VARCHAR(100),
        "FMG_GroupName" VARCHAR(100),
        "PickUp_RouteName" TEXT,
        "Drop_RouteName" TEXT,
        "PickUp_Location" TEXT,
        "Drop_Location" TEXT,
        "StudentMobileNo" TEXT,
        "FatherMobileNo" TEXT
    );

    FOR v_routeids IN 
        SELECT DISTINCT "TRMR_Id" 
        FROM "Trn"."TR_Master_Route" 
        WHERE "MI_Id" = 6 AND "TRMR_ActiveFlg" = 1
    LOOP
        FOR rec IN
            SELECT DISTINCT "OneWay"."amst_id", "AMST_AdmNo", "STUDENTNAME", "ASMCL_ClassName", "ASMC_SectionName", "FMG_GroupName",
            (CASE WHEN "ASTA_PickUp_TRMR_Id" != 0 THEN 
                (SELECT "TRMR_RouteName" FROM "Trn"."TR_Master_Route" WHERE "TRMR_Id" = "ASTA_PickUp_TRMR_Id")
            ELSE '-' END) AS "PickUp_RouteName",
            (CASE WHEN "TRMR_Drop_Route" != 0 THEN 
                (SELECT "TRMR_RouteName" FROM "Trn"."TR_Master_Route" WHERE "TRMR_Id" = "TRMR_Drop_Route") 
            ELSE '-' END) AS "Drop_RouteName",
            (CASE WHEN "TRSR_PickUpLocation" != 0 THEN 
                (SELECT "TRML_LocationName" FROM "Trn"."TR_Master_Location" WHERE "TRML_Id" = "TRSR_PickUpLocation") 
            ELSE '-' END) AS "PickUp_Location",
            (CASE WHEN "TRSR_DropLocation" != 0 THEN 
                (SELECT "TRML_LocationName" FROM "Trn"."TR_Master_Location" WHERE "TRML_Id" = "TRSR_DropLocation") 
            ELSE '-' END) AS "Drop_Location",
            "SM"."AMSTSMS_MobileNo",
            "FM"."AMST_FatherMobile_No"
            FROM (
                SELECT DISTINCT "A"."amst_id", "AMST_AdmNo",
                (COALESCE("AMST_FirstName", '') || COALESCE("AMST_MiddleName", '') || COALESCE("AMST_LastName", '')) AS "STUDENTNAME",
                "CL"."ASMCL_ClassName", "SC"."ASMC_SectionName", "FG"."FMG_GroupName",
                "TRMR_Id" AS "ASTA_PickUp_TRMR_Id", "TRMR_Drop_Route", "TRSR_PickUpLocation", "TRSR_DropLocation"
                FROM "TRN"."TR_Student_Route" "A"
                INNER JOIN "Adm_M_Student" AS "B" ON "A"."AMST_Id" = "B"."AMST_Id" AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1
                INNER JOIN "Adm_School_Y_Student" AS "Z" ON "A"."AMST_Id" = "Z"."AMST_Id" AND "Z"."ASMAY_Id" = 14 AND "Z"."AMAY_ActiveFlag" = 1
                INNER JOIN "Adm_School_M_Class" "CL" ON "CL"."ASMCL_Id" = "Z"."ASMCL_Id" AND "CL"."ASMCL_ActiveFlag" = 1
                INNER JOIN "Adm_School_M_Section" "SC" ON "SC"."ASMS_Id" = "Z"."ASMS_Id" AND "SC"."ASMC_ActiveFlag" = 1
                INNER JOIN "Fee_Master_Group" "FG" ON "FG"."FMG_Id" = "A"."FMG_Id" AND "FG"."FMG_ActiceFlag" = 1
                WHERE "TRSR_ActiveFlg" = 1 
                AND ("TRMR_Id" <> 0 OR "TRMR_Drop_Route" <> 0) 
                AND "A"."MI_Id" = 6 
                AND "A"."ASMAY_Id" = 14
                AND ("TRMR_Id" = v_routeids OR "TRMR_Drop_Route" = v_routeids)
            ) AS "OneWay"
            LEFT JOIN "Adm_Master_Student_SMSNo" "SM" ON "SM"."AMST_Id" = "OneWay"."amst_id"
            LEFT JOIN "Adm_Master_FatherMobileNo" "FM" ON "FM"."AMST_Id" = "OneWay"."amst_id"
            ORDER BY "PickUp_RouteName", "Drop_RouteName"
        LOOP
            INSERT INTO "Allroutenames" VALUES(
                rec."amst_id", rec."AMST_AdmNo", rec."STUDENTNAME", rec."ASMCL_ClassName", 
                rec."ASMC_SectionName", rec."FMG_GroupName", rec."PickUp_RouteName",
                rec."Drop_RouteName", rec."PickUp_Location", rec."Drop_Location", 
                rec."AMSTSMS_MobileNo", rec."AMST_FatherMobile_No"
            );
        END LOOP;
    END LOOP;

    RETURN QUERY SELECT * FROM "Allroutenames";
END;
$$;