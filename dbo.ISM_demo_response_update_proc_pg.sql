CREATE OR REPLACE FUNCTION "dbo"."ISM_demo_response_update_proc"(
    p_ISMSLEDM_Id bigint,
    p_ISMSLEDMPR_Id bigint,
    p_MI_Id bigint,
    p_ISMSMST_Id bigint,
    p_ISMSLEDMPR_Remarks varchar(50)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_count_1 bigint;
    v_count_2 bigint;
BEGIN
    UPDATE "dbo"."ISM_Sales_Lead_Demo_Products" 
    SET "ISMSMST_Id" = p_ISMSMST_Id,
        "ISMSLEDMPR_Remarks" = p_ISMSLEDMPR_Remarks 
    WHERE "ISMSLEDMPR_Id" = p_ISMSLEDMPR_Id 
        AND "ISMSLEDM_Id" = p_ISMSLEDM_Id;

    SELECT COUNT("ISMSLEDM_Id") 
    INTO v_count_1
    FROM "dbo"."ISM_Sales_Lead_Demo_Products" 
    WHERE "ISMSLEDM_Id" = p_ISMSLEDM_Id;

    SELECT COUNT("ISMSMST_Id") 
    INTO v_count_2
    FROM "dbo"."ISM_Sales_Lead_Demo_Products" 
    WHERE "ISMSLEDM_Id" = p_ISMSLEDM_Id 
        AND "ISMSMST_Id" IS NOT NULL;

    IF (v_count_1 = v_count_2) THEN
        UPDATE "dbo"."ISM_Sales_Lead_Demo" 
        SET "ISMSLEDM_Status_Flg" = 1 
        WHERE "ISMSLEDM_Id" = p_ISMSLEDM_Id;
    END IF;

    RETURN;
END;
$$;