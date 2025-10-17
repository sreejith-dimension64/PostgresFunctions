CREATE OR REPLACE FUNCTION "dbo"."ConsolidatedListForBusRoute_new_Collage"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    routeid bigint,
    RouteName varchar(300),
    twonewcount bigint,
    tworegcount bigint,
    twototalcount bigint,
    Onepicknewcount bigint,
    Onepickregcount bigint,
    onepicktotalcount bigint,
    Onedropnewcount bigint,
    Onedropregcount bigint,
    onedroptotalcount bigint,
    totaltransport bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_prevacademic bigint;
    v_2newcount bigint;
    v_2newcount1 bigint;
    v_2regcount bigint;
    v_2regcount1 bigint;
    v_2totalcount bigint;
    v_2totalcount1 bigint;
    v_1picknewcount bigint;
    v_1picknewcount1 bigint;
    v_1pickregcount bigint;
    v_1pickregcount1 bigint;
    v_1picktotalcount bigint;
    v_1picktotalcount1 bigint;
    v_1dropnewcount bigint;
    v_1dropnewcount1 bigint;
    v_1dropregcount bigint;
    v_1dropregcount1 bigint;
    v_1droptotalcount bigint;
    v_1droptotalcount1 bigint;
    v_totaltransport bigint;
    v_totaltransport1 bigint;
    v_TRMR_order bigint;
    v_RouteName varchar(300);
    v_Pickupid bigint;
    v_Dropid bigint;
    v_routeid bigint;
    route_rec RECORD;
BEGIN
    SELECT DISTINCT "ASMAY_Id" INTO v_prevacademic
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_MI_Id 
        AND "Is_Active" = 1 
        AND "ASMAY_ActiveFlag" = 1 
        AND "ASMAY_Order" IN (
            SELECT DISTINCT "ASMAY_Order" - 1
            FROM "Adm_School_M_Academic_Year"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "Is_Active" = 1 
                AND "ASMAY_ActiveFlag" = 1
        );

    DROP TABLE IF EXISTS "StudentBusRoute_Collage_Temp";

    CREATE TEMP TABLE "StudentBusRoute_Collage_Temp"(
        routeid bigint,
        RouteName varchar(300),
        twonewcount bigint,
        tworegcount bigint,
        twototalcount bigint,
        Onepicknewcount bigint,
        Onepickregcount bigint,
        onepicktotalcount bigint,
        Onedropnewcount bigint,
        Onedropregcount bigint,
        onedroptotalcount bigint,
        totaltransport bigint
    );

    IF p_MI_Id <> 4 THEN
        SELECT COUNT(DISTINCT "AMCST_Id") INTO v_totaltransport
        FROM "TRN"."TR_Student_Route_College"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "TRRSCO_ActiveFlg" = 1 
            AND "AMCST_Id" IN (
                SELECT DISTINCT amcs."AMCST_Id" 
                FROM "CLG"."Adm_Master_College_Student" amcs
                WHERE amcs."MI_Id" = p_MI_Id 
                    AND amcs."AMCST_SOL" = 'S' 
                    AND amcs."AMCST_ActiveFlag" = 1
            );

        SELECT COUNT(DISTINCT "AMCST_Id") INTO v_totaltransport1
        FROM "Adm_Student_Trans_Appl_College"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASTACO_ForAY" = p_ASMAY_Id 
            AND "ASTACO_ActiveFlag" = 1 
            AND "ASTACO_Amount" > 0 
            AND "ASTACO_ApplStatus" = 'Approved'
            AND "AMCST_Id" IN (
                SELECT DISTINCT AA."AMCST_Id" 
                FROM "CLG"."Adm_Master_College_Student" AS AA
                INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                WHERE AA."MI_Id" = p_MI_Id 
                    AND BB."ASMAY_Id" = p_ASMAY_Id 
                    AND AA."AMCST_SOL" = 'S' 
                    AND AA."AMCST_ActiveFlag" = 1 
                    AND BB."ACYST_ActiveFlag" = 1
            )
            AND "AMCST_Id" NOT IN (
                SELECT DISTINCT "AMCST_Id" 
                FROM "TRN"."TR_Student_Route_College" tsrc
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "TRRSCO_ActiveFlg" = 1 
                    AND "AMCST_Id" IN (
                        SELECT DISTINCT AA."AMCST_Id" 
                        FROM "CLG"."Adm_Master_College_Student" AS AA
                        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                        WHERE AA."MI_Id" = p_MI_Id 
                            AND BB."ASMAY_Id" = p_ASMAY_Id 
                            AND AA."AMCST_SOL" = 'S' 
                            AND AA."AMCST_ActiveFlag" = 1 
                            AND BB."ACYST_ActiveFlag" = 1
                    )
            );

        v_totaltransport := v_totaltransport + v_totaltransport1;

        FOR route_rec IN 
            SELECT DISTINCT "TRMR_Id", "TRMR_RouteName", "TRMR_order"
            FROM "TRN"."TR_Master_Route"
            WHERE "MI_Id" = p_MI_Id 
                AND "TRMR_ActiveFlg" = 1
            ORDER BY "TRMR_order"
        LOOP
            v_routeid := route_rec."TRMR_Id";
            v_RouteName := route_rec."TRMR_RouteName";
            v_TRMR_order := route_rec."TRMR_order";

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_2totalcount
            FROM "TRN"."TR_Student_Route_College" tsrc
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "TRRSCO_ActiveFlg" = 1 
                AND ("TRSRCO_PickUpRoute" = v_routeid OR "TRSRCO_DropRoute" = v_routeid)
                AND ("TRSRCO_PickUpRoute" <> 0 AND "TRSRCO_DropRoute" <> 0)
                AND "AMCST_Id" IN (
                    SELECT DISTINCT AA."AMCST_Id" 
                    FROM "CLG"."Adm_Master_College_Student" AS AA
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                    WHERE AA."MI_Id" = p_MI_Id 
                        AND BB."ASMAY_Id" = p_ASMAY_Id 
                        AND AA."AMCST_SOL" = 'S' 
                        AND AA."AMCST_ActiveFlag" = 1 
                        AND BB."ACYST_ActiveFlag" = 1
                );

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_2totalcount1
            FROM "Adm_Student_Trans_Appl_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASTACO_ForAY" = p_ASMAY_Id 
                AND "ASTACO_ActiveFlag" = 1 
                AND ("ASTACO_PickUp_TRMR_Id" = v_routeid OR "ASTACO_Drop_TRMR_Id" = v_routeid)
                AND ("ASTACO_PickUp_TRMR_Id" <> 0 AND "ASTACO_Drop_TRMR_Id" <> 0)
                AND "ASTACO_Amount" > 0 
                AND "ASTACO_ApplStatus" = 'Approved'
                AND "AMCST_Id" NOT IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND ("TRSRCO_PickUpRoute" = v_routeid OR "TRSRCO_DropRoute" = v_routeid)
                        AND ("TRSRCO_PickUpRoute" <> 0 AND "TRSRCO_DropRoute" <> 0)
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT AA."AMCST_Id" 
                            FROM "CLG"."Adm_Master_College_Student" AS AA
                            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                            WHERE AA."MI_Id" = p_MI_Id 
                                AND BB."ASMAY_Id" = p_ASMAY_Id 
                                AND AA."AMCST_SOL" = 'S' 
                                AND AA."AMCST_ActiveFlag" = 1 
                                AND BB."ACYST_ActiveFlag" = 1
                        )
                );

            v_2totalcount := v_2totalcount + v_2totalcount1;

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_2regcount
            FROM "TRN"."TR_Student_Route_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = v_prevacademic 
                AND "TRRSCO_ActiveFlg" = 1 
                AND "AMCST_Id" IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND ("TRSRCO_PickUpRoute" = v_routeid OR "TRSRCO_DropRoute" = v_routeid)
                        AND ("TRSRCO_PickUpRoute" <> 0 AND "TRSRCO_DropRoute" <> 0)
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT AA."AMCST_Id" 
                            FROM "CLG"."Adm_Master_College_Student" AS AA
                            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                            WHERE AA."MI_Id" = p_MI_Id 
                                AND BB."ASMAY_Id" = p_ASMAY_Id 
                                AND AA."AMCST_SOL" = 'S' 
                                AND AA."AMCST_ActiveFlag" = 1 
                                AND BB."ACYST_ActiveFlag" = 1
                        )
                );

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_2regcount1
            FROM "Adm_Student_Trans_Appl_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASTACO_ForAY" = p_ASMAY_Id 
                AND "ASTACO_ActiveFlag" = 1 
                AND ("ASTACO_PickUp_TRMR_Id" = v_routeid OR "ASTACO_Drop_TRMR_Id" = v_routeid)
                AND ("ASTACO_PickUp_TRMR_Id" <> 0 AND "ASTACO_Drop_TRMR_Id" <> 0)
                AND "ASTACO_Amount" > 0 
                AND "ASTACO_ApplStatus" = 'Approved'
                AND "ASTACO_Regnew" = 'Regular'
                AND "AMCST_Id" NOT IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = v_prevacademic 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT "AMCST_Id" 
                            FROM "TRN"."TR_Student_Route_College" tsrc
                            WHERE "MI_Id" = p_MI_Id 
                                AND "ASMAY_Id" = p_ASMAY_Id 
                                AND "TRRSCO_ActiveFlg" = 1 
                                AND ("TRSRCO_PickUpRoute" = v_routeid OR "TRSRCO_PickUpRoute" = v_routeid)
                                AND ("TRSRCO_PickUpRoute" <> 0 AND "TRSRCO_DropRoute" <> 0)
                                AND "AMCST_Id" IN (
                                    SELECT DISTINCT AA."AMCST_Id" 
                                    FROM "CLG"."Adm_Master_College_Student" AS AA
                                    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                                    WHERE AA."MI_Id" = p_MI_Id 
                                        AND BB."ASMAY_Id" = p_ASMAY_Id 
                                        AND AA."AMCST_SOL" = 'S' 
                                        AND AA."AMCST_ActiveFlag" = 1 
                                        AND BB."ACYST_ActiveFlag" = 1
                                )
                        )
                );

            v_2newcount := v_2newcount + v_2regcount1;
            v_2newcount := v_2totalcount - v_2regcount;

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1picktotalcount
            FROM "TRN"."TR_Student_Route_College" tsrc
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "TRRSCO_ActiveFlg" = 1 
                AND "TRSRCO_PickUpRoute" = v_routeid 
                AND ("TRSRCO_DropRoute" = 0 OR "TRSRCO_DropRoute" IS NULL)
                AND "AMCST_Id" IN (
                    SELECT DISTINCT AA."AMCST_Id" 
                    FROM "CLG"."Adm_Master_College_Student" AS AA
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                    WHERE AA."MI_Id" = p_MI_Id 
                        AND BB."ASMAY_Id" = p_ASMAY_Id 
                        AND AA."AMCST_SOL" = 'S' 
                        AND AA."AMCST_ActiveFlag" = 1 
                        AND BB."ACYST_ActiveFlag" = 1
                );

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1picktotalcount1
            FROM "Adm_Student_Trans_Appl_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASTACO_ForAY" = p_ASMAY_Id 
                AND "ASTACO_ActiveFlag" = 1 
                AND "ASTACO_ApplStatus" = 'Approved'
                AND "ASTACO_PickUp_TRMR_Id" = v_routeid 
                AND ("ASTACO_Drop_TRMR_Id" = 0 OR "ASTACO_Drop_TRMR_Id" IS NULL)
                AND "AMCST_Id" NOT IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND "TRSRCO_PickUpRoute" = v_routeid 
                        AND ("TRSRCO_DropRoute" = 0 OR "TRSRCO_DropRoute" IS NULL)
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT AA."AMCST_Id" 
                            FROM "CLG"."Adm_Master_College_Student" AS AA
                            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                            WHERE AA."MI_Id" = p_MI_Id 
                                AND BB."ASMAY_Id" = p_ASMAY_Id 
                                AND AA."AMCST_SOL" = 'S' 
                                AND AA."AMCST_ActiveFlag" = 1 
                                AND BB."ACYST_ActiveFlag" = 1
                        )
                );

            v_1picktotalcount := v_1picktotalcount + v_1picktotalcount1;

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1pickregcount
            FROM "TRN"."TR_Student_Route_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = v_prevacademic 
                AND "TRRSCO_ActiveFlg" = 1 
                AND "AMCST_Id" IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND "TRSRCO_PickUpRoute" = v_routeid 
                        AND ("TRSRCO_DropRoute" = 0 OR "TRSRCO_DropRoute" IS NULL)
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT AA."AMCST_Id" 
                            FROM "CLG"."Adm_Master_College_Student" AS AA
                            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                            WHERE AA."MI_Id" = p_MI_Id 
                                AND BB."ASMAY_Id" = p_ASMAY_Id 
                                AND AA."AMCST_SOL" = 'S' 
                                AND AA."AMCST_ActiveFlag" = 1 
                                AND BB."ACYST_ActiveFlag" = 1
                        )
                );

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1pickregcount1
            FROM "Adm_Student_Trans_Appl_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASTACO_ForAY" = p_ASMAY_Id 
                AND "ASTACO_ActiveFlag" = 1 
                AND "ASTACO_PickUp_TRMR_Id" = v_routeid 
                AND ("ASTACO_Drop_TRMR_Id" = 0 OR "ASTACO_Drop_TRMR_Id" IS NULL)
                AND "ASTACO_ApplStatus" = 'Approved'
                AND "ASTACO_Regnew" = 'Regular'
                AND "AMCST_Id" NOT IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College" tsrc
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = v_prevacademic 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT "AMCST_Id" 
                            FROM "TRN"."TR_Student_Route_College" tsrc1
                            WHERE "MI_Id" = p_MI_Id 
                                AND "ASMAY_Id" = p_ASMAY_Id 
                                AND "TRRSCO_ActiveFlg" = 1 
                                AND "TRSRCO_PickUpRoute" = v_routeid 
                                AND ("TRSRCO_DropRoute" = 0 OR "TRSRCO_DropRoute" IS NULL)
                                AND "AMCST_Id" IN (
                                    SELECT DISTINCT AA."AMCST_Id" 
                                    FROM "CLG"."Adm_Master_College_Student" AS AA
                                    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                                    WHERE AA."MI_Id" = p_MI_Id 
                                        AND BB."ASMAY_Id" = p_ASMAY_Id 
                                        AND AA."AMCST_SOL" = 'S' 
                                        AND AA."AMCST_ActiveFlag" = 1 
                                        AND BB."ACYST_ActiveFlag" = 1
                                )
                        )
                );

            v_1pickregcount := v_1pickregcount + v_1pickregcount1;
            v_1picknewcount := v_1picktotalcount - v_1pickregcount;

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1droptotalcount
            FROM "TRN"."TR_Student_Route_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "TRRSCO_ActiveFlg" = 1 
                AND "TRSRCO_DropRoute" = v_routeid 
                AND ("TRSRCO_PickUpRoute" = 0 OR "TRSRCO_PickUpRoute" IS NULL)
                AND "AMCST_Id" IN (
                    SELECT DISTINCT AA."AMCST_Id" 
                    FROM "CLG"."Adm_Master_College_Student" AS AA
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                    WHERE AA."MI_Id" = p_MI_Id 
                        AND BB."ASMAY_Id" = p_ASMAY_Id 
                        AND AA."AMCST_SOL" = 'S' 
                        AND AA."AMCST_ActiveFlag" = 1 
                        AND BB."ACYST_ActiveFlag" = 1
                );

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1droptotalcount1
            FROM "Adm_Student_Trans_Appl_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASTACO_ForAY" = p_ASMAY_Id 
                AND "ASTACO_ActiveFlag" = 1 
                AND "ASTACO_ApplStatus" = 'Approved'
                AND "ASTACO_Drop_TRMR_Id" = v_routeid 
                AND ("ASTACO_PickUp_TRMR_Id" = 0 OR "ASTACO_PickUp_TRMR_Id" IS NULL)
                AND "AMCST_Id" NOT IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND "TRSRCO_DropRoute" = v_routeid 
                        AND ("TRSRCO_PickUpRoute" = 0 OR "TRSRCO_PickUpRoute" IS NULL)
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT AA."AMCST_Id" 
                            FROM "CLG"."Adm_Master_College_Student" AS AA
                            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                            WHERE AA."MI_Id" = p_MI_Id 
                                AND BB."ASMAY_Id" = p_ASMAY_Id 
                                AND AA."AMCST_SOL" = 'S' 
                                AND AA."AMCST_ActiveFlag" = 1 
                                AND BB."ACYST_ActiveFlag" = 1
                        )
                );

            v_1droptotalcount := v_1droptotalcount + v_1droptotalcount1;

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1dropregcount
            FROM "TRN"."TR_Student_Route_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = v_prevacademic 
                AND "TRRSCO_ActiveFlg" = 1 
                AND "AMCST_Id" IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND "TRSRCO_DropRoute" = v_routeid 
                        AND ("TRSRCO_PickUpRoute" = 0 OR "TRSRCO_PickUpRoute" IS NULL)
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT AA."AMCST_Id" 
                            FROM "CLG"."Adm_Master_College_Student" AS AA
                            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                            WHERE AA."MI_Id" = p_MI_Id 
                                AND BB."ASMAY_Id" = p_ASMAY_Id 
                                AND AA."AMCST_SOL" = 'S' 
                                AND AA."AMCST_ActiveFlag" = 1 
                                AND BB."ACYST_ActiveFlag" = 1
                        )
                );

            SELECT COUNT(DISTINCT "AMCST_Id") INTO v_1dropregcount1
            FROM "Adm_Student_Trans_Appl_College"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASTACO_ForAY" = p_ASMAY_Id 
                AND "ASTACO_ActiveFlag" = 1 
                AND "ASTACO_PickUp_TRMR_Id" = v_routeid 
                AND ("ASTACO_Drop_TRMR_Id" = 0 OR "ASTACO_Drop_TRMR_Id" IS NULL)
                AND "ASTACO_ApplStatus" = 'Approved'
                AND "ASTACO_Regnew" = 'Regular'
                AND "AMCST_Id" NOT IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "TRN"."TR_Student_Route_College"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = v_prevacademic 
                        AND "TRRSCO_ActiveFlg" = 1 
                        AND "AMCST_Id" IN (
                            SELECT DISTINCT "AMCST_Id" 
                            FROM "TRN"."TR_Student_Route_College"
                            WHERE "MI_Id" = p_MI_Id 
                                AND "ASMAY_Id" = p_ASMAY_Id 
                                AND "TRRSCO_ActiveFlg" = 1 
                                AND "TRSRCO_DropRoute" = v_routeid 
                                AND ("TRSRCO_PickUpRoute" = 0 OR "TRSRCO_PickUpRoute" IS NULL)
                                AND "AMCST_Id" IN (
                                    SELECT DISTINCT AA."AMCST_Id" 
                                    FROM "CLG"."Adm_Master_College_Student" AS AA
                                    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS BB ON AA."AMCST_Id" = BB."AMCST_Id"
                                    WHERE AA."MI_Id" = p_MI_Id 
                                        AND BB."ASMAY_Id" = p_ASMAY_Id 
                                        AND AA."AMCST_SOL" = 'S' 
                                        AND AA."AMCST_ActiveFlag" = 1 
                                        AND BB."ACYST_ActiveFlag" = 1
                                )
                        )
                );

            v_1dropregcount := v_1dropregcount + v_1dropregcount1;
            v_1dropnewcount := v_1droptotalcount - v_1dropregcount;

            INSERT INTO "StudentBusRoute_Collage