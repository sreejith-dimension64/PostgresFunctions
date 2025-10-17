CREATE OR REPLACE FUNCTION "dbo"."ConsolidatedListForBusRoute_new_alter" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE (
    routeid bigint,
    "RouteName" varchar(300),
    twonewcount bigint,
    tworegcount bigint,
    twototalcount bigint,
    "Onepicknewcount" bigint,
    "Onepickregcount" bigint,
    onepicktotalcount bigint,
    "Onedropnewcount" bigint,
    "Onedropregcount" bigint,
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
    WHERE "MI_Id" = p_MI_Id AND "Is_Active" = 1 AND "ASMAY_ActiveFlag" = 1 
    AND "ASMAY_Order" IN (
        SELECT DISTINCT "ASMAY_Order" - 1  
        FROM "Adm_School_M_Academic_Year"  
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "Is_Active" = 1 AND "ASMAY_ActiveFlag" = 1
    );

    DROP TABLE IF EXISTS "StudentBusRoute_new";

    CREATE TEMP TABLE "StudentBusRoute_new" (
        routeid bigint,
        "RouteName" varchar(300),
        twonewcount bigint,
        tworegcount bigint,
        twototalcount bigint,
        "Onepicknewcount" bigint,
        "Onepickregcount" bigint,
        onepicktotalcount bigint,
        "Onedropnewcount" bigint,
        "Onedropregcount" bigint,
        onedroptotalcount bigint,
        totaltransport bigint
    );

    IF p_MI_Id <> 4 THEN
    
        SELECT count(DISTINCT "AMST_Id") INTO v_totaltransport
        FROM "TRN"."TR_Student_Route" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
        AND "AMST_Id" IN (
            SELECT DISTINCT AA."AMST_Id" 
            FROM "Adm_M_Student" AS AA 
            INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
            WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
            AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
        );

        SELECT count(DISTINCT "AMST_Id") INTO v_totaltransport1
        FROM "Adm_Student_Transport_Application" 
        WHERE "MI_Id" = p_MI_Id AND "ASTA_FutureAY" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
        AND "ASTA_Amount" > 0 AND "ASTA_ApplStatus" = 'Approved'
        AND "AMST_Id" IN (
            SELECT DISTINCT AA."AMST_Id" 
            FROM "Adm_M_Student" AS AA 
            INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
            WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
            AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
        ) 
        AND "AMST_Id" NOT IN (
            SELECT DISTINCT "AMST_Id" 
            FROM "TRN"."TR_Student_Route" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
            AND "AMST_Id" IN (
                SELECT DISTINCT AA."AMST_Id" 
                FROM "Adm_M_Student" AS AA 
                INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
            )
        );

        v_totaltransport := COALESCE(v_totaltransport, 0) + COALESCE(v_totaltransport1, 0);

        FOR route_rec IN 
            SELECT DISTINCT "TRMR_Id", "TRMR_RouteName", "TRMR_order" 
            FROM "TRN"."TR_Master_Route"
            WHERE "MI_Id" = p_MI_Id AND "TRMR_ActiveFlg" = 1 
            ORDER BY "TRMR_order"
        LOOP
            v_routeid := route_rec."TRMR_Id";
            v_RouteName := route_rec."TRMR_RouteName";
            v_TRMR_order := route_rec."TRMR_order";

            SELECT count(DISTINCT "AMST_Id") INTO v_2totalcount
            FROM "TRN"."TR_Student_Route" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
            AND ("TRMR_Id" = v_routeid OR "TRMR_Drop_Route" = v_routeid) 
            AND ("TRMR_Id" <> 0 AND "TRMR_Drop_Route" <> 0) 
            AND "AMST_Id" IN (
                SELECT DISTINCT AA."AMST_Id" 
                FROM "Adm_M_Student" AS AA 
                INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
            );

            SELECT count(DISTINCT "AMST_Id") INTO v_2totalcount1
            FROM "Adm_Student_Transport_Application" 
            WHERE "MI_Id" = p_MI_Id AND "ASTA_FutureAY" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
            AND ("ASTA_PickUp_TRMR_Id" = v_routeid OR "ASTA_Drop_TRMR_Id" = v_routeid) 
            AND ("ASTA_PickUp_TRMR_Id" <> 0 AND "ASTA_Drop_TRMR_Id" <> 0) 
            AND "ASTA_Amount" > 0 AND "ASTA_ApplStatus" = 'Approved' 
            AND "AMST_Id" NOT IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                AND ("TRMR_Id" = v_routeid OR "TRMR_Drop_Route" = v_routeid) 
                AND ("TRMR_Id" <> 0 AND "TRMR_Drop_Route" <> 0) 
                AND "AMST_Id" IN (
                    SELECT DISTINCT AA."AMST_Id" 
                    FROM "Adm_M_Student" AS AA 
                    INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                    WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                    AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                )
            );

            v_2totalcount := COALESCE(v_2totalcount, 0) + COALESCE(v_2totalcount1, 0);

            SELECT count(DISTINCT "AMST_Id") INTO v_2regcount
            FROM "TRN"."TR_Student_Route" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_prevacademic AND "TRSR_ActiveFlg" = 1 
            AND "AMST_Id" IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                AND ("TRMR_Id" = v_routeid OR "TRMR_Drop_Route" = v_routeid) 
                AND ("TRMR_Id" <> 0 AND "TRMR_Drop_Route" <> 0) 
                AND "AMST_Id" IN (
                    SELECT DISTINCT AA."AMST_Id" 
                    FROM "Adm_M_Student" AS AA 
                    INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                    WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                    AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                )
            );

            SELECT count(DISTINCT "AMST_Id") INTO v_2regcount1
            FROM "Adm_Student_Transport_Application" 
            WHERE "MI_Id" = p_MI_Id AND "ASTA_FutureAY" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
            AND ("ASTA_PickUp_TRMR_Id" = v_routeid OR "ASTA_Drop_TRMR_Id" = v_routeid) 
            AND ("ASTA_PickUp_TRMR_Id" <> 0 AND "ASTA_Drop_TRMR_Id" <> 0) 
            AND "ASTA_Amount" > 0 AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'Regular' 
            AND "AMST_Id" NOT IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_prevacademic AND "TRSR_ActiveFlg" = 1 
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "TRN"."TR_Student_Route" 
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                    AND ("TRMR_Id" = v_routeid OR "TRMR_Drop_Route" = v_routeid) 
                    AND ("TRMR_Id" <> 0 AND "TRMR_Drop_Route" <> 0) 
                    AND "AMST_Id" IN (
                        SELECT DISTINCT AA."AMST_Id" 
                        FROM "Adm_M_Student" AS AA 
                        INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                        WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                        AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                    )
                )
            );

            v_2newcount := COALESCE(v_2regcount1, 0);
            v_2regcount := COALESCE(v_2regcount, 0) + COALESCE(v_2regcount1, 0);
            v_2newcount := COALESCE(v_2totalcount, 0) - v_2regcount;

            SELECT count(DISTINCT "AMST_Id") INTO v_1picktotalcount
            FROM "TRN"."TR_Student_Route" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
            AND "TRMR_Id" = v_routeid AND ("TRMR_Drop_Route" = 0 OR "TRMR_Drop_Route" IS NULL) 
            AND "AMST_Id" IN (
                SELECT DISTINCT AA."AMST_Id" 
                FROM "Adm_M_Student" AS AA 
                INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
            );

            SELECT count(DISTINCT "AMST_Id") INTO v_1picktotalcount1
            FROM "Adm_Student_Transport_Application" 
            WHERE "MI_Id" = p_MI_Id AND "ASTA_FutureAY" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_PickUp_TRMR_Id" = v_routeid 
            AND ("ASTA_Drop_TRMR_Id" = 0 OR "ASTA_Drop_TRMR_Id" IS NULL) 
            AND "AMST_Id" NOT IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                AND "TRMR_Id" = v_routeid AND ("TRMR_Drop_Route" = 0 OR "TRMR_Drop_Route" IS NULL) 
                AND "AMST_Id" IN (
                    SELECT DISTINCT AA."AMST_Id" 
                    FROM "Adm_M_Student" AS AA 
                    INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                    WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                    AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                )
            );

            v_1picktotalcount := COALESCE(v_1picktotalcount, 0) + COALESCE(v_1picktotalcount1, 0);

            SELECT count(DISTINCT "AMST_Id") INTO v_1pickregcount
            FROM "TRN"."TR_Student_Route" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_prevacademic AND "TRSR_ActiveFlg" = 1 
            AND "AMST_Id" IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                AND "TRMR_Id" = v_routeid AND ("TRMR_Drop_Route" = 0 OR "TRMR_Drop_Route" IS NULL) 
                AND "AMST_Id" IN (
                    SELECT DISTINCT AA."AMST_Id" 
                    FROM "Adm_M_Student" AS AA 
                    INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                    WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                    AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                )
            );

            SELECT count(DISTINCT "AMST_Id") INTO v_1pickregcount1
            FROM "Adm_Student_Transport_Application" 
            WHERE "MI_Id" = p_MI_Id AND "ASTA_FutureAY" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
            AND "ASTA_PickUp_TRMR_Id" = v_routeid AND ("ASTA_Drop_TRMR_Id" = 0 OR "ASTA_Drop_TRMR_Id" IS NULL) 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'Regular' 
            AND "AMST_Id" NOT IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_prevacademic AND "TRSR_ActiveFlg" = 1 
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "TRN"."TR_Student_Route" 
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                    AND "TRMR_Id" = v_routeid AND ("TRMR_Drop_Route" = 0 OR "TRMR_Drop_Route" IS NULL) 
                    AND "AMST_Id" IN (
                        SELECT DISTINCT AA."AMST_Id" 
                        FROM "Adm_M_Student" AS AA 
                        INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                        WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                        AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                    )
                )
            );

            v_1pickregcount := COALESCE(v_1pickregcount, 0) + COALESCE(v_1pickregcount1, 0);
            v_1picknewcount := COALESCE(v_1picktotalcount, 0) - v_1pickregcount;

            SELECT count(DISTINCT "AMST_Id") INTO v_1droptotalcount
            FROM "TRN"."TR_Student_Route" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
            AND "TRMR_Drop_Route" = v_routeid AND ("TRMR_Id" = 0 OR "TRMR_Id" IS NULL) 
            AND "AMST_Id" IN (
                SELECT DISTINCT AA."AMST_Id" 
                FROM "Adm_M_Student" AS AA 
                INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
            );

            SELECT count(DISTINCT "AMST_Id") INTO v_1droptotalcount1
            FROM "Adm_Student_Transport_Application" 
            WHERE "MI_Id" = p_MI_Id AND "ASTA_FutureAY" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Drop_TRMR_Id" = v_routeid 
            AND ("ASTA_PickUp_TRMR_Id" = 0 OR "ASTA_PickUp_TRMR_Id" IS NULL) 
            AND "AMST_Id" NOT IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                AND "TRMR_Drop_Route" = v_routeid AND ("TRMR_Id" = 0 OR "TRMR_Id" IS NULL) 
                AND "AMST_Id" IN (
                    SELECT DISTINCT AA."AMST_Id" 
                    FROM "Adm_M_Student" AS AA 
                    INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                    WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                    AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                )
            );

            v_1droptotalcount := COALESCE(v_1droptotalcount, 0) + COALESCE(v_1droptotalcount1, 0);

            SELECT count(DISTINCT "AMST_Id") INTO v_1dropregcount
            FROM "TRN"."TR_Student_Route" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_prevacademic AND "TRSR_ActiveFlg" = 1 
            AND "AMST_Id" IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                AND "TRMR_Drop_Route" = v_routeid AND ("TRMR_Id" = 0 OR "TRMR_Id" IS NULL) 
                AND "AMST_Id" IN (
                    SELECT DISTINCT AA."AMST_Id" 
                    FROM "Adm_M_Student" AS AA 
                    INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                    WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                    AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                )
            );

            SELECT count(DISTINCT "AMST_Id") INTO v_1dropregcount1
            FROM "Adm_Student_Transport_Application" 
            WHERE "MI_Id" = p_MI_Id AND "ASTA_FutureAY" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
            AND "ASTA_PickUp_TRMR_Id" = v_routeid AND ("ASTA_Drop_TRMR_Id" = 0 OR "ASTA_Drop_TRMR_Id" IS NULL) 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'Regular' 
            AND "AMST_Id" NOT IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "TRN"."TR_Student_Route" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_prevacademic AND "TRSR_ActiveFlg" = 1 
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "TRN"."TR_Student_Route" 
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1 
                    AND "TRMR_Drop_Route" = v_routeid AND ("TRMR_Id" = 0 OR "TRMR_Id" IS NULL) 
                    AND "AMST_Id" IN (
                        SELECT DISTINCT AA."AMST_Id" 
                        FROM "Adm_M_Student" AS AA 
                        INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id" 
                        WHERE AA."MI_Id" = p_MI_Id AND BB."ASMAY_Id" = p_ASMAY_Id 
                        AND AA."AMST_SOL" = 'S' AND AA."AMST_ActiveFlag" = 1 AND BB."AMAY_ActiveFlag" = 1
                    )
                )
            );

            v_1dropregcount := COALESCE(v_1dropregcount, 0) + COALESCE(v_1dropregcount1, 0);
            v_1dropnewcount := COALESCE(v_1droptotalcount, 0) - v_1dropregcount;

            INSERT INTO "StudentBusRoute_new" 
            VALUES (v_routeid, v_RouteName, v_2newcount, v_2regcount, v_2totalcount, 
                    v_1picknewcount, v_1pickregcount, v_1picktotalcount, 
                    v_1dropnewcount, v_1dropregcount, v_1droptotalcount, v_totaltransport);

        END LOOP;

        RETURN QUERY SELECT * FROM "StudentBusRoute_new";

    ELSIF p_MI_Id = 4 THEN

        SELECT count(DISTINCT "AMST_Id") INTO v_totaltransport
        FROM "TRN"."TR_Student_Route" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "TRSR_ActiveFlg" = 1;

        FOR route_rec IN 
            SELECT DISTINCT "TRMR_Id", "TRMR_RouteName", "TRMR_order" 
            FROM "TRN"."TR_Master_Route"
            WHERE "MI_Id" = p_MI_Id AND "TRMR_ActiveFlg" = 1 
            ORDER BY "TRMR_order"
        LOOP
            v_routeid := route_rec."TRMR_Id";
            v_RouteName := route_rec."TRMR_RouteName";
            v_TRMR_order := route_rec."TRMR_order";

            SELECT count(DISTINCT A."AMST_Id") INTO v_2totalcount
            FROM "Adm_Student_Transport_Application" AS A
            LEFT JOIN "Adm_M_Student" AS B ON A."AMST_Id" = B."AMST_Id" 
                AND A."ASTA_FutureAY" = p_ASMAY_Id AND B."AMST_ActiveFlag" = 1 AND B."AMST_SOL" = 'S'
            LEFT JOIN "Adm_School_Y_Student" AS C ON C."AMST_Id" = B."AMST_Id" 
            WHERE A."MI_Id" = p_MI_Id AND C."ASMAY_Id" = p_ASMAY_Id AND "ASTA_ActiveFlag" = 1 
            AND ("ASTA_PickUp_TRMR_Id" = v_routeid OR "ASTA_Drop_TRMR_Id" = v_routeid) 
            AND ("ASTA_PickUp_TRMR_Id" <> 0 AND "