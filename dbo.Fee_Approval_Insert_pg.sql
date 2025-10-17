CREATE OR REPLACE FUNCTION "dbo"."Fee_Approval_Insert" (
    p_MI_Id bigint,
    p_AMST_Id bigint
)
RETURNS TABLE(count1 integer)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMAY_Id bigint;
    v_countfee bigint;
    v_countstu bigint;
    v_councheck bigint;
BEGIN
    SELECT "ASMAY_Id" INTO v_ASMAY_Id 
    FROM "Adm_School_Y_Student" 
    WHERE "AMST_Id" = p_AMST_Id 
    ORDER BY "ASMAY_Id" DESC 
    LIMIT 1;

    SELECT COUNT(*) INTO v_councheck
    FROM "Fee_Student_Status"
    INNER JOIN "Fee_Master_Group" ON "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
    WHERE "Fee_Student_Status"."MI_Id" = p_MI_Id 
        AND "AMST_Id" = p_AMST_Id 
        AND "ASMAY_Id" = v_ASMAY_Id 
        AND "Fee_Student_Status"."FMG_Id" NOT IN (
            SELECT "ATCFAPP_FeeGroupId" 
            FROM "Adm_TC_Fee_Approval" 
            WHERE "MI_Id" = p_MI_Id 
                AND "AMST_Id" = p_AMST_Id
        )
    GROUP BY "Fee_Master_Group"."FMG_Id", "Fee_Master_Group"."FMG_GroupName";

    IF COALESCE(v_councheck, 0) = 0 THEN
        UPDATE "Adm_TC_Fee_Approval" 
        SET "ATCFAPP_ApprovalFlg" = 1 
        WHERE "AMST_Id" = p_AMST_Id 
            AND "MI_Id" = p_MI_Id;
        
        RETURN QUERY SELECT 1::integer;
    ELSE
        RETURN QUERY SELECT 0::integer;
    END IF;

END;
$$;