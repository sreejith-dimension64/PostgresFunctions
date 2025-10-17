CREATE OR REPLACE FUNCTION "dbo"."Fee_GMChairman_Overall_Report"(
    p_Asmay_year VARCHAR(200),
    p_userId BIGINT
)
RETURNS TABLE(
    "Institution_Name" VARCHAR,
    "TotalCharges" NUMERIC,
    "TotalPaidAmount" NUMERIC,
    "TotalDue" NUMERIC,
    "TotalConcession" NUMERIC,
    "Waived" NUMERIC,
    "Rebate" NUMERIC,
    "Fine" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS temp_GMFEE;

    CREATE TEMP TABLE temp_GMFEE AS
    SELECT DISTINCT a."mi_id", a."ASMAY_Id"
    FROM "dbo"."Adm_School_M_Academic_Year" a 
    INNER JOIN "dbo"."IVRM_User_Login_Institutionwise" b
        ON a."MI_Id" = b."MI_Id"
    WHERE b."Id" = p_userId AND a."ASMAY_Year" = p_Asmay_year;

    RETURN QUERY
    SELECT DISTINCT 
        "MI"."MI_Name" AS "Institution_Name",
        SUM("FSS"."FSS_CurrentYrCharges") AS "TotalCharges",
        (SUM("FSS"."FSS_PaidAmount") - SUM("FSS"."FSS_FineAmount")) AS "TotalPaidAmount",
        SUM("FSS"."FSS_ToBePaid") AS "TotalDue",
        SUM("FSS"."FSS_ConcessionAmount") AS "TotalConcession",
        SUM("FSS"."FSS_WaivedAmount") AS "Waived",
        SUM("FSS"."FSS_RebateAmount") AS "Rebate",
        SUM("FSS"."FSS_FineAmount") AS "Fine"
    FROM "dbo"."fee_student_status" "FSS"
    INNER JOIN temp_GMFEE "Y" ON "Y"."mi_id" = "FSS"."MI_Id" AND "FSS"."ASMAY_Id" = "Y"."ASMAY_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "FSS"."Amst_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
        AND "Y"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id"
    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."master_institution" "MI" ON "MI"."MI_ID" = "FSS"."MI_ID"
    INNER JOIN "dbo"."Fee_Master_Group" ON "FSS"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "FSS"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "FSS"."FTI_Id"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "FSS"."FMH_Id" 
        AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "FSS"."FTI_Id"
    WHERE "FSS"."AMST_Id" IN (
        SELECT b."AMST_Id" 
        FROM "dbo"."Adm_M_Student" a
        INNER JOIN "dbo"."Adm_school_y_student" b ON b."amst_id" = a."amst_id"
        WHERE "MI_Id" IN (SELECT "mi_id" FROM temp_GMFEE) 
        AND b."ASMAY_Id" IN (SELECT "ASMAY_Id" FROM temp_GMFEE)
    )
    GROUP BY "MI"."MI_Name";

    DROP TABLE IF EXISTS temp_GMFEE;

END;
$$;