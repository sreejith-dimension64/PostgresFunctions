CREATE OR REPLACE FUNCTION "dbo"."InsertstudentRouteDup"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_scount bigint;
    v_AMST_Id bigint;
    v_TRMR_Id bigint;
    v_FMG_Id bigint;
    v_AMST_IdN bigint;
    firstcursor_rec RECORD;
    secondcur_rec RECORD;
BEGIN
    FOR firstcursor_rec IN 
        SELECT COUNT("TRSR_Id") as scount, "AMST_Id" 
        FROM "trn"."TR_Student_Route" 
        WHERE "MI_Id" = 4 AND "ASMAY_Id" = 11 
        GROUP BY "AMST_Id" 
        HAVING COUNT("TRSR_Id") > 1
    LOOP
        v_scount := firstcursor_rec.scount;
        v_AMST_Id := firstcursor_rec."AMST_Id";
        
        FOR secondcur_rec IN 
            SELECT "TRMR_Id", "FMG_Id", "AMST_Id" 
            FROM "trn"."TR_Student_Route" 
            WHERE "MI_Id" = 4 AND "ASMAY_Id" = 11 AND "AMST_Id" = v_AMST_Id
        LOOP
            v_TRMR_Id := secondcur_rec."TRMR_Id";
            v_FMG_Id := secondcur_rec."FMG_Id";
            v_AMST_IdN := secondcur_rec."AMST_Id";
            
            INSERT INTO "StudentRoute_Dup" VALUES (v_TRMR_Id, v_FMG_Id, v_AMST_IdN);
        END LOOP;
    END LOOP;
    
    RETURN;
END;
$$;