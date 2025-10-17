CREATE OR REPLACE FUNCTION "ADM_Canteen_CardInsert"(
    "p_MI_Id" bigint,
    "p_AMST_Idcan" TEXT,
    "p_AMCTST_IP" TEXT,
    "p_School_Flag" VARCHAR(10),
    "p_flag" VARCHAR(10)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_AMST_Id" bigint;
    "v_AlphaNumeric" bigint;
    "v_flag" VARCHAR(10);
    "v_SchoolCollegeFlag" CHAR(1);
    "v_PDA_Amount" DECIMAL(18,2);
    "v_ASMAY_ID" bigint;
    "v_School_Flag" VARCHAR(10);
BEGIN
    "v_flag" := "p_flag";
    "v_School_Flag" := "p_School_Flag";

    IF (CASE WHEN "p_AMST_Idcan" ~ '[A-Z]' THEN 1 ELSE 0 END) = 0 THEN
        "v_flag" := 'S';
        "v_AMST_Id" := "p_AMST_Idcan"::bigint;
    ELSE
        "v_flag" := SUBSTRING("p_AMST_Idcan", 1, 1);
        "v_AMST_Id" := REPLACE("p_AMST_Idcan", 'E', '')::bigint;
    END IF;

    SELECT "MI_SchoolCollegeFlag" INTO "v_School_Flag" 
    FROM "Master_Institution" 
    WHERE "mi_id" = "p_MI_Id";

    IF ("v_flag" = 'S') THEN
        SELECT "MI_SchoolCollegeFlag" INTO "v_SchoolCollegeFlag" 
        FROM "Master_Institution" 
        WHERE "MI_Id" = "p_MI_Id";
        
        SELECT "PDAS_CBExcessPaid" INTO "v_PDA_Amount" 
        FROM "PDA_Status" 
        WHERE "MI_Id" = "p_MI_Id" AND "AMST_Id" = "v_AMST_Id";
        
        SELECT "ASMAY_Id" INTO "v_ASMAY_ID" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = 50 
        AND "ASMAY_From_Date"::DATE <= CURRENT_DATE 
        AND "ASMAY_To_Date"::DATE >= CURRENT_DATE
        ORDER BY "ASMAY_Id"
        LIMIT 1;
        
        INSERT INTO "ADM_RF_CARDS" (
            "MI_Id", "AMST_Id", "AMCTST_IP", "AMCTST_STATUS", 
            "CreateDate", "UpdateDate", "SchoolCollegeFlag", 
            "PDA_amount", "ASMAY_Id", "StaffStudFlag"
        )
        VALUES (
            "p_MI_Id", "v_AMST_Id", "p_AMCTST_IP", 'A', 
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, "v_SchoolCollegeFlag", 
            "v_PDA_Amount", "v_ASMAY_ID", "v_flag"
        );
        
    ELSIF ("v_flag" = 'E') THEN
        SELECT "MI_SchoolCollegeFlag" INTO "v_SchoolCollegeFlag" 
        FROM "Master_Institution" 
        WHERE "MI_Id" = "p_MI_Id";
        
        SELECT "CMSTFWLT_BalanceAmount" INTO "v_PDA_Amount" 
        FROM "CM_Staff_Wallet" 
        WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_AMST_Id";
        
        SELECT "ASMAY_Id" INTO "v_ASMAY_ID" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = 50 
        AND "ASMAY_From_Date"::DATE <= CURRENT_DATE 
        AND "ASMAY_To_Date"::DATE >= CURRENT_DATE
        ORDER BY "ASMAY_Id"
        LIMIT 1;
        
        INSERT INTO "ADM_RF_CARDS" (
            "MI_Id", "AMST_Id", "AMCTST_IP", "AMCTST_STATUS", 
            "CreateDate", "UpdateDate", "SchoolCollegeFlag", 
            "PDA_amount", "ASMAY_Id", "StaffStudFlag"
        )
        VALUES (
            "p_MI_Id", "v_AMST_Id", "p_AMCTST_IP", 'A', 
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, "v_SchoolCollegeFlag", 
            "v_PDA_Amount", "v_ASMAY_ID", "v_flag"
        );
    END IF;

    RETURN;
END;
$$;