CREATE OR REPLACE FUNCTION "dbo"."ConsolidatedListForBusRoute_new_11" (
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
    v_2regcount bigint;
    v_2totalcount bigint;
    v_1picknewcount bigint;
    v_1pickregcount bigint;
    v_1picktotalcount bigint;
    v_1dropnewcount bigint;
    v_1dropregcount bigint;
    v_1droptotalcount bigint;
    v_totaltransport bigint;
    v_TRMR_order bigint;
    v_RouteName varchar(300);
    v_Pickupid bigint;
    v_Dropid bigint;
    v_routeid bigint;
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

    SELECT COUNT(DISTINCT "AMST_Id") INTO v_totaltransport
    FROM "TRN"."TR_Student_Route"
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "TRSR_ActiveFlg" = 1 
        AND "AMST_Id" IN (
            SELECT DISTINCT AA."AMST_Id"
            FROM "Adm_M_Student" AS AA
            INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id"
            WHERE AA."MI_Id" = p_MI_Id 
                AND BB."ASMAY_Id" = p_ASMAY_Id 
                AND AA."AMST_SOL" = 'S' 
                AND AA."AMST_ActiveFlag" = 1 
                AND BB."AMAY_ActiveFlag" = 1
        );

    FOR v_routeid, v_RouteName, v_TRMR_order IN
        SELECT DISTINCT "TRMR_Id", "TRMR_RouteName", "TRMR_order"
        FROM "TRN"."TR_Master_Route"
        WHERE "MI_Id" = p_MI_Id 
            AND "TRMR_ActiveFlg" = 1
        ORDER BY "TRMR_order"
    LOOP
        SELECT COUNT(DISTINCT "AMST_Id") INTO v_2totalcount
        FROM "TRN"."TR_Student_Route"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "TRSR_ActiveFlg" = 1 
            AND ("TRMR_Id" = v_routeid OR "TRMR_Drop_Route" = v_routeid) 
            AND ("TRMR_Id" <> 0 AND "TRMR_Drop_Route" <> 0);

        SELECT COUNT(DISTINCT "AMST_Id") INTO v_2regcount
        FROM "TRN"."TR_Student_Route"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_prevacademic 
            AND "TRSR_ActiveFlg" = 1
            AND "AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "TRN"."TR_Student_Route"
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "TRSR_ActiveFlg" = 1 
                    AND ("TRMR_Id" = v_routeid OR "TRMR_Drop_Route" = v_routeid) 
                    AND ("TRMR_Id" <> 0 AND "TRMR_Drop_Route" <> 0)
                    AND "AMST_Id" IN (
                        SELECT DISTINCT AA."AMST_Id"
                        FROM "Adm_M_Student" AS AA
                        INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id"
                        WHERE AA."MI_Id" = p_MI_Id 
                            AND BB."ASMAY_Id" = p_ASMAY_Id 
                            AND AA."AMST_SOL" = 'S' 
                            AND AA."AMST_ActiveFlag" = 1 
                            AND BB."AMAY_ActiveFlag" = 1
                    )
            );

        v_2newcount := v_2totalcount - v_2regcount;

        SELECT COUNT(DISTINCT "AMST_Id") INTO v_1picktotalcount
        FROM "TRN"."TR_Student_Route"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "TRSR_ActiveFlg" = 1 
            AND "TRMR_Id" = v_routeid 
            AND ("TRMR_Drop_Route" = 0 OR "TRMR_Drop_Route" IS NULL);

        SELECT COUNT(DISTINCT "AMST_Id") INTO v_1pickregcount
        FROM "TRN"."TR_Student_Route"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_prevacademic 
            AND "TRSR_ActiveFlg" = 1
            AND "AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "TRN"."TR_Student_Route"
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "TRSR_ActiveFlg" = 1 
                    AND "TRMR_Id" = v_routeid 
                    AND ("TRMR_Drop_Route" = 0 OR "TRMR_Drop_Route" IS NULL)
                    AND "AMST_Id" IN (
                        SELECT DISTINCT AA."AMST_Id"
                        FROM "Adm_M_Student" AS AA
                        INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id"
                        WHERE AA."MI_Id" = p_MI_Id 
                            AND BB."ASMAY_Id" = p_ASMAY_Id 
                            AND AA."AMST_SOL" = 'S' 
                            AND AA."AMST_ActiveFlag" = 1 
                            AND BB."AMAY_ActiveFlag" = 1
                    )
            );

        v_1picknewcount := v_1picktotalcount - v_1pickregcount;

        SELECT COUNT(DISTINCT "AMST_Id") INTO v_1droptotalcount
        FROM "TRN"."TR_Student_Route"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "TRSR_ActiveFlg" = 1 
            AND "TRMR_Drop_Route" = v_routeid 
            AND ("TRMR_Id" = 0 OR "TRMR_Id" IS NULL);

        SELECT COUNT(DISTINCT "AMST_Id") INTO v_1dropregcount
        FROM "TRN"."TR_Student_Route"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_prevacademic 
            AND "TRSR_ActiveFlg" = 1
            AND "AMST_Id" IN (
                SELECT DISTINCT "AMST_Id"
                FROM "TRN"."TR_Student_Route"
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "TRSR_ActiveFlg" = 1 
                    AND "TRMR_Drop_Route" = v_routeid 
                    AND ("TRMR_Id" = 0 OR "TRMR_Id" IS NULL)
                    AND "AMST_Id" IN (
                        SELECT DISTINCT AA."AMST_Id"
                        FROM "Adm_M_Student" AS AA
                        INNER JOIN "Adm_School_Y_Student" AS BB ON AA."AMST_Id" = BB."AMST_Id"
                        WHERE AA."MI_Id" = p_MI_Id 
                            AND BB."ASMAY_Id" = p_ASMAY_Id 
                            AND AA."AMST_SOL" = 'S' 
                            AND AA."AMST_ActiveFlag" = 1 
                            AND BB."AMAY_ActiveFlag" = 1
                    )
            );

        v_1dropnewcount := v_1droptotalcount - v_1dropregcount;

        INSERT INTO "StudentBusRoute_new" 
        VALUES (
            v_routeid, 
            v_RouteName, 
            v_2newcount, 
            v_2regcount, 
            v_2totalcount, 
            v_1picknewcount, 
            v_1pickregcount, 
            v_1picktotalcount, 
            v_1dropnewcount, 
            v_1dropregcount, 
            v_1droptotalcount, 
            v_totaltransport
        );
    END LOOP;

    RETURN QUERY SELECT * FROM "StudentBusRoute_new";
    
    DROP TABLE IF EXISTS "StudentBusRoute_new";
END;
$$;