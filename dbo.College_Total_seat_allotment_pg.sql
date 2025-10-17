CREATE OR REPLACE FUNCTION "clg"."College_Total_seat_allotment" (
    "p_mi_id" bigint, 
    "p_asmay_id" bigint, 
    "p_amco_id" bigint, 
    "p_amse_id" bigint, 
    "p_acqq_id" varchar(50)
)
RETURNS TABLE (
    "result_set" int,
    "ACSCD_SeatNos" int,
    "ACQ_Id" int,
    "ACQ_QuotaName" text,
    "AMCO_CourseName" text,
    "AMB_Id" int,
    "AMB_BranchName" text,
    "AMSE_SEMName" text,
    "AMB_Order" int,
    "admitted_seats" bigint,
    "acqid" int,
    "totalseats" int,
    "admitted" int,
    "vac" int,
    "amb" int
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ACSCD_SeatNos" int;
    "v_ACQ_Id" int;
    "v_AMB_Id" int;
    "v_admsets" bigint;
    "v_seats" int := 0;
    "v_first" int := 0;
    "v_rowcount" int;
    "v_rowcount1" int;
    "v_admitt" int := 0;
    "v_seats1" int := 0;
    "v_admitt1" int := 0;
    "rec" record;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS "temp_ttt" (
        "acqid" int,
        "totalseats" int,
        "admitted" int,
        "vac" int
    ) ON COMMIT DROP;
    
    CREATE TEMP TABLE IF NOT EXISTS "temp_ttt1" (
        "amb" int,
        "totalseats" int,
        "admitted" int,
        "vac" int
    ) ON COMMIT DROP;

    RETURN QUERY EXECUTE 
    'SELECT 1 as result_set, a."ACSCD_SeatNos", b."ACQ_Id", b."ACQ_QuotaName", c."AMCO_CourseName", d."AMB_Id", d."AMB_BranchName",   
    f."AMSE_SEMName", d."AMB_Order", Count(*)::bigint as admitted_seats, 
    null::int as acqid, null::int as totalseats, null::int as admitted, null::int as vac, null::int as amb
    FROM "clg"."Adm_Master_College_Student" z  
    INNER JOIN "clg"."Adm_College_Seat_Distribution" a ON a."AMB_Id" = z."AMB_Id"  
    INNER JOIN "clg"."Adm_College_Quota" b ON a."ACQ_Id" = b."ACQ_Id"  
    INNER JOIN "clg"."Adm_Master_Course" c ON a."AMCO_Id" = c."AMCO_Id"  
    INNER JOIN "clg"."Adm_Master_Branch" d ON a."AMB_Id" = d."AMB_Id"  
    INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = a."AMSE_Id"  
    WHERE a."MI_Id" = ' || "p_mi_id" || ' AND a."ASMAY_Id" = ' || "p_asmay_id" || ' AND a."AMCO_Id" = ' || "p_amco_id" || 
    ' AND a."AMSE_Id" = ' || "p_amse_id" || ' AND a."ACQ_Id" IN (' || "p_acqq_id" || ') 
    AND z."AMCO_Id" = c."AMCO_Id" AND z."AMSE_Id" = f."AMSE_Id" AND z."AMB_Id" = d."AMB_Id"   
    AND b."ACQ_Id" = z."ACQ_Id"   
    GROUP BY b."ACQ_Id", a."ACSCD_SeatNos", b."ACQ_QuotaName", c."AMCO_CourseName", d."AMB_BranchName", f."AMSE_SEMName", d."AMB_Id", d."AMB_Order" 
    ORDER BY d."AMB_Order"';

    FOR "rec" IN EXECUTE
        'SELECT DISTINCT a."ACSCD_SeatNos", b."ACQ_Id", d."AMB_Id", Count(*)::bigint as admitted_seats 
        FROM "clg"."Adm_Master_College_Student" z  
        INNER JOIN "clg"."Adm_College_Seat_Distribution" a ON a."AMB_Id" = z."AMB_Id"  
        INNER JOIN "clg"."Adm_College_Quota" b ON a."ACQ_Id" = b."ACQ_Id"  
        INNER JOIN "clg"."Adm_Master_Course" c ON a."AMCO_Id" = c."AMCO_Id"  
        INNER JOIN "clg"."Adm_Master_Branch" d ON a."AMB_Id" = d."AMB_Id"  
        INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = a."AMSE_Id"  
        WHERE a."MI_Id" = ' || "p_mi_id" || ' AND a."ASMAY_Id" = ' || "p_asmay_id" || ' AND a."AMCO_Id" = ' || "p_amco_id" || 
        ' AND a."AMSE_Id" = ' || "p_amse_id" || ' AND a."ACQ_Id" IN (' || "p_acqq_id" || ') 
        AND z."AMCO_Id" = c."AMCO_Id" AND z."AMSE_Id" = f."AMSE_Id" AND z."AMB_Id" = d."AMB_Id"   
        AND b."ACQ_Id" = z."ACQ_Id"   
        GROUP BY b."ACQ_Id", a."ACSCD_SeatNos", d."AMB_Id" 
        ORDER BY b."ACQ_Id"'
    LOOP
        "v_ACSCD_SeatNos" := "rec"."ACSCD_SeatNos";
        "v_ACQ_Id" := "rec"."ACQ_Id";
        "v_AMB_Id" := "rec"."AMB_Id";
        "v_admsets" := "rec"."admitted_seats";

        SELECT count(*) INTO "v_rowcount1" FROM "temp_ttt1" WHERE "amb" = "v_AMB_Id";
        
        IF "v_rowcount1" > 0 THEN
            SELECT "totalseats", "admitted" INTO "v_seats1", "v_admitt1" FROM "temp_ttt1" WHERE "amb" = "v_AMB_Id";
            UPDATE "temp_ttt1" 
            SET "totalseats" = ("v_seats1" + "v_ACSCD_SeatNos"),
                "admitted" = ("v_admitt1" + "v_admsets"),
                "vac" = "vac" + ("v_ACSCD_SeatNos" - "v_admsets") 
            WHERE "amb" = "v_AMB_Id";
        ELSE
            INSERT INTO "temp_ttt1"("amb", "totalseats", "admitted", "vac")
            VALUES ("v_AMB_Id", "v_ACSCD_SeatNos", "v_admsets", ("v_ACSCD_SeatNos" - "v_admsets"));
        END IF;

        IF "v_first" = 0 THEN
            "v_first" := "v_ACQ_Id";
        END IF;

        IF "v_ACQ_Id" = "v_first" THEN
            "v_seats" := "v_seats" + "v_ACSCD_SeatNos";
            "v_admitt" := "v_admitt" + "v_admsets";
        ELSE
            "v_first" := "v_ACQ_Id";
            "v_seats" := 0;
            "v_admitt" := 0;
            "v_seats" := "v_seats" + "v_ACSCD_SeatNos";
            "v_admitt" := "v_admitt" + "v_admsets";
        END IF;

        SELECT count(*) INTO "v_rowcount" FROM "temp_ttt" WHERE "acqid" = "v_ACQ_Id";
        
        IF "v_rowcount" > 0 THEN
            UPDATE "temp_ttt" 
            SET "totalseats" = "v_seats",
                "admitted" = "v_admitt",
                "vac" = ("v_seats" - "v_admitt") 
            WHERE "acqid" = "v_ACQ_Id";
        ELSE
            INSERT INTO "temp_ttt"("acqid", "totalseats", "admitted", "vac")
            VALUES ("v_ACQ_Id", "v_seats", "v_admitt", ("v_seats" - "v_admitt"));
        END IF;
    END LOOP;

    RETURN QUERY 
    SELECT 2 as result_set, null::int, null::int, null::text, null::text, null::int, null::text, null::text, null::int, null::bigint,
           t."acqid", t."totalseats", t."admitted", t."vac", null::int
    FROM "temp_ttt" t;

    RETURN QUERY 
    SELECT 3 as result_set, null::int, null::int, null::text, null::text, null::int, null::text, null::text, null::int, null::bigint,
           null::int, t1."totalseats", t1."admitted", t1."vac", t1."amb"
    FROM "temp_ttt1" t1;

    DROP TABLE IF EXISTS "temp_ttt";
    DROP TABLE IF EXISTS "temp_ttt1";

    RETURN;
END;
$$;