CREATE OR REPLACE FUNCTION "dbo"."HOD_Classwise_fee_collaction"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "User_Id" TEXT
)
RETURNS TABLE(
    "callected" NUMERIC,
    "ballance" NUMERIC,
    "concession" NUMERIC,
    "waived" NUMERIC,
    "rebate" NUMERIC,
    "fine" NUMERIC,
    "class" VARCHAR,
    "classid" BIGINT,
    "ASMCL_Order" INTEGER,
    "receivable" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "JSH_FeesClasswise_Temp";

    CREATE TEMP TABLE "JSH_FeesClasswise_Temp" AS
    SELECT DISTINCT e."ASMCL_Id", d."IHOD_Id", c."HRME_Id", a."Id"
    FROM "ApplicationUser" a 
    INNER JOIN "IVRM_Staff_User_Login" b ON a."Id" = b."Id" 
    INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = b."Emp_Code"
    INNER JOIN "IVRM_HOD" d ON d."HRME_Id" = c."HRME_Id"
    INNER JOIN "IVRM_HOD_Class" e ON e."IHOD_Id" = d."IHOD_Id"
    WHERE a."Id" = "User_Id" AND c."MI_Id" = "MI_Id";

    RETURN QUERY
    SELECT 
        (SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount"))::NUMERIC AS "callected",
        SUM("fee_student_status"."FSS_ToBePaid")::NUMERIC AS "ballance",
        SUM("fee_student_status"."FSS_ConcessionAmount")::NUMERIC AS "concession",
        SUM("fee_student_status"."FSS_WaivedAmount")::NUMERIC AS "waived",
        SUM("fee_student_status"."FSS_RebateAmount")::NUMERIC AS "rebate",
        SUM("fee_student_status"."FSS_FineAmount")::NUMERIC AS "fine",
        "Adm_School_M_Class"."ASMCL_ClassName"::VARCHAR AS "class",
        "Adm_School_M_Class"."ASMCL_Id"::BIGINT AS "classid",
        "Adm_School_M_Class"."ASMCL_Order",
        SUM("fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS "receivable"
    FROM "dbo"."fee_student_status" 
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
    INNER JOIN "dbo"."Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
    INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
    INNER JOIN "dbo"."Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id"  
    INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id"  
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE "Adm_School_Y_Student"."ASMAY_Id" = "HOD_Classwise_fee_collaction"."ASMAY_Id" 
        AND "fee_student_status"."MI_Id" = "HOD_Classwise_fee_collaction"."MI_Id"  
        AND "fee_student_status"."ASMAY_Id" = "HOD_Classwise_fee_collaction"."ASMAY_Id" 
        AND "Adm_School_M_Class"."ASMCL_Id" IN (SELECT DISTINCT "ASMCL_Id" FROM "JSH_FeesClasswise_Temp") 
    GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Class"."ASMCL_Id", "Adm_School_M_Class"."ASMCL_Order" 
    ORDER BY "Adm_School_M_Class"."ASMCL_Order";

END;
$$;