CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Master_Student_Group"(
    "@mi_id" BIGINT,
    "@amst_id" BIGINT,
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
    SELECT * FROM "Fee_Master_Student_Group" 
    WHERE "ASMAY_Id" = "@asmay_id" 
    AND "FMG_Id" = "@fmg_id" 
    AND "MI_Id" = "@mi_id" 
    AND "AMST_Id" = "@amst_id";
    
    GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
    
    IF "v_rowcount" = 0 THEN
        INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
        VALUES ("@mi_id", "@amst_id", "@asmay_id", "@fmg_id", "@FMSG_ActiveFlag");
    END IF;
    
    SELECT MAX("FMSG_Id") INTO "@fmsgid" FROM "Fee_Master_Student_Group";
    
    RETURN "@fmsgid";
END;
$$;