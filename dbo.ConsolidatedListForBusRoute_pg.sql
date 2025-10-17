CREATE OR REPLACE FUNCTION "dbo"."ConsolidatedListForBusRoute" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE (
    routeid bigint,
    "RouteName" varchar(300),
    "TwoWayRegularCount" bigint,
    "TwoWayNewCount" bigint,
    "OneWayNewCount" bigint,
    "OneWayRegularPickupCount" bigint,
    "OneWayRegularDropCount" bigint,
    "Total" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TwoWayReggularPickupCount bigint;
    v_TwoWayReggularDropCount bigint;
    v_TwoWayNewPickupCount bigint;
    v_TwoWayNewDropCount bigint;
    v_OneWayReggularPickupCount bigint;
    v_OneWayReggularDropCount bigint;
    v_OneWayNewPickupCount bigint;
    v_OneWayNewDropCount bigint;
    v_TwoWayReggularTotalCount bigint;
    v_TwoWayNewTotalCount bigint;
    v_OneWayNewTotalCount bigint;
    v_RouteName varchar(300);
    v_Pickupid bigint;
    v_Dropid bigint;
    v_routeid bigint;
    route_rec RECORD;
BEGIN
    DROP TABLE IF EXISTS "StudentBusRoute";
    
    CREATE TEMP TABLE "StudentBusRoute"(
        routeid bigint,
        "RouteName" varchar(300),
        "TwoWayRegularCount" bigint,
        "TwoWayNewCount" bigint,
        "OneWayNewCount" bigint,
        "OneWayRegularPickupCount" bigint,
        "OneWayRegularDropCount" bigint,
        "Total" bigint
    );
    
    FOR route_rec IN 
        SELECT DISTINCT "TRMR"."TRMR_Id", "TRMR"."TRMR_RouteName", "ASTA"."ASTA_PickUp_TRMR_Id", "ASTA"."ASTA_Drop_TRMR_Id" 
        FROM "dbo"."Adm_Student_Transport_Application" "ASTA"
        INNER JOIN "TRN"."TR_Master_Route" "TRMR" ON "ASTA"."ASTA_PickUp_TRMR_Id" = "TRMR"."TRMR_Id"
            AND "ASTA"."ASTA_Drop_TRMR_Id" = "TRMR"."TRMR_Id"
        WHERE "ASTA"."ASTA_FutureAY" = p_ASMAY_Id AND "ASTA"."MI_Id" = p_MI_Id
    LOOP
        v_routeid := route_rec."TRMR_Id";
        v_RouteName := route_rec."TRMR_RouteName";
        v_Pickupid := route_rec."ASTA_PickUp_TRMR_Id";
        v_Dropid := route_rec."ASTA_Drop_TRMR_Id";
        
        SELECT COUNT("ASTA_PickUp_TRMR_Id"), COUNT("ASTA_Drop_TRMR_Id") 
        INTO v_TwoWayReggularPickupCount, v_TwoWayReggularDropCount
        FROM "dbo"."Adm_Student_Transport_Application" 
        WHERE "ASTA_FutureAY" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'Regular' 
            AND "ASTA_PickUp_TRMR_Id" <> 0
            AND "ASTA_Drop_TRMR_Id" <> 0 
            AND "ASTA_PickUp_TRMR_Id" = v_Pickupid 
            AND "ASTA_Drop_TRMR_Id" = v_Dropid;
        
        v_TwoWayReggularTotalCount := v_TwoWayReggularPickupCount;
        
        SELECT COUNT("ASTA_PickUp_TRMR_Id"), COUNT("ASTA_Drop_TRMR_Id") 
        INTO v_TwoWayNewPickupCount, v_TwoWayNewDropCount
        FROM "dbo"."Adm_Student_Transport_Application" 
        WHERE "ASTA_FutureAY" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'New' 
            AND "ASTA_PickUp_TRMR_Id" <> 0
            AND "ASTA_Drop_TRMR_Id" <> 0 
            AND "ASTA_PickUp_TRMR_Id" = v_Pickupid 
            AND "ASTA_Drop_TRMR_Id" = v_Dropid;
        
        v_TwoWayNewTotalCount := v_TwoWayNewPickupCount;
        
        SELECT COUNT("ASTA_PickUp_TRMR_Id") 
        INTO v_OneWayReggularPickupCount
        FROM "dbo"."Adm_Student_Transport_Application" 
        WHERE "ASTA_FutureAY" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'Regular' 
            AND "ASTA_PickUp_TRMR_Id" <> 0 AND "ASTA_Drop_TRMR_Id" = 0 
            AND "ASTA_PickUp_TRMR_Id" = v_Pickupid;
        
        SELECT COUNT("ASTA_Drop_TRMR_Id") 
        INTO v_OneWayReggularDropCount
        FROM "dbo"."Adm_Student_Transport_Application" 
        WHERE "ASTA_FutureAY" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'Regular' 
            AND "ASTA_PickUp_TRMR_Id" = 0 AND "ASTA_Drop_TRMR_Id" <> 0 
            AND "ASTA_Drop_TRMR_Id" = v_Dropid;
        
        SELECT COUNT("ASTA_PickUp_TRMR_Id") 
        INTO v_OneWayNewPickupCount
        FROM "dbo"."Adm_Student_Transport_Application" 
        WHERE "ASTA_FutureAY" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'New' 
            AND "ASTA_PickUp_TRMR_Id" <> 0 AND "ASTA_Drop_TRMR_Id" = 0 
            AND "ASTA_PickUp_TRMR_Id" = v_Pickupid;
        
        SELECT COUNT("ASTA_Drop_TRMR_Id") 
        INTO v_OneWayNewDropCount
        FROM "dbo"."Adm_Student_Transport_Application" 
        WHERE "ASTA_FutureAY" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "ASTA_ApplStatus" = 'Approved' AND "ASTA_Regnew" = 'New' 
            AND "ASTA_PickUp_TRMR_Id" = 0 AND "ASTA_Drop_TRMR_Id" <> 0 
            AND "ASTA_Drop_TRMR_Id" = v_Dropid;
        
        v_OneWayNewTotalCount := v_OneWayNewPickupCount + v_OneWayNewDropCount;
        
        INSERT INTO "StudentBusRoute" VALUES(
            v_routeid,
            v_RouteName,
            v_TwoWayReggularTotalCount,
            v_TwoWayNewPickupCount,
            v_OneWayNewTotalCount,
            v_OneWayReggularPickupCount,
            v_OneWayReggularDropCount,
            v_TwoWayReggularTotalCount + v_TwoWayNewPickupCount + v_OneWayNewTotalCount + v_OneWayReggularPickupCount + v_OneWayReggularDropCount
        );
        
    END LOOP;
    
    RETURN QUERY SELECT * FROM "StudentBusRoute";
    
    DROP TABLE IF EXISTS "StudentBusRoute";
    
END;
$$;