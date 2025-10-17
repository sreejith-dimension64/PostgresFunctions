CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Master_Staff_Group"(
    "@mi_id" BIGINT,
    "@hrme_id" BIGINT,
    "@asmay_id" BIGINT,
    "@fmg_id" BIGINT,
    "@FMSG_ActiveFlag" VARCHAR(150)
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    "@fmsgid" BIGINT;
    "v_rowcount" INTEGER;
BEGIN
    
    SELECT * FROM "dbo"."Fee_Master_Staff_GroupHead" 
    WHERE "ASMAY_Id" = "@asmay_id" 
    AND "FMG_Id" = "@fmg_id" 
    AND "MI_Id" = "@mi_id" 
    AND "HRME_Id" = "@hrme_id";
    
    GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
    
    IF "v_rowcount" = 0 THEN
        
        INSERT INTO "dbo"."Fee_Master_Staff_GroupHead" 
        ("MI_Id", "HRME_Id", "ASMAY_Id", "FMG_Id", "FMSTGH_ActiveFlag") 
        VALUES ("@mi_id", "@hrme_id", "@asmay_id", "@fmg_id", "@FMSG_ActiveFlag");
        
    END IF;
    
    SELECT MAX("FMSTGH_Id") INTO "@fmsgid" FROM "dbo"."Fee_Master_Staff_GroupHead";
    
    RETURN "@fmsgid";
    
END;
$$;