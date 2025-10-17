CREATE OR REPLACE FUNCTION "dbo"."Fee_Summarized_Report"(
    "@amay_id" BIGINT,
    "@asmcl_id" BIGINT,
    "@amcl_id" BIGINT,
    "@amst_id" BIGINT,
    "@fmt_id" BIGINT,
    "@mi_id" BIGINT,
    "@User_Id" BIGINT
)
RETURNS TABLE(
    "FMH_FeeName" VARCHAR,
    "FTI_Name" VARCHAR,
    "FMT_Id" BIGINT,
    "FMG_Id" BIGINT,
    "FMA_Id" BIGINT,
    "FTI_Id" BIGINT,
    "FMH_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "FSS_ToBePaid" NUMERIC,
    "FSS_PaidAmount" NUMERIC,
    "FSS_ConcessionAmount" NUMERIC,
    "FSS_NetAmount" NUMERIC,
    "FSS_FineAmount" NUMERIC,
    "FSS_RefundAmount" NUMERIC,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "Name" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        "dbo"."Fee_Master_Head"."FMH_FeeName",
        "dbo"."Fee_T_Installment"."FTI_Name",
        "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id",
        "dbo"."Fee_Student_Status"."FMG_Id",
        "dbo"."Fee_Student_Status"."FMA_Id",
        "dbo"."Fee_Student_Status"."FTI_Id",
        "dbo"."Fee_Student_Status"."FMH_Id",
        "dbo"."Fee_Student_Status"."ASMAY_Id",
        "dbo"."Fee_Student_Status"."FSS_ToBePaid",
        "dbo"."Fee_Student_Status"."FSS_PaidAmount",
        "dbo"."Fee_Student_Status"."FSS_ConcessionAmount",
        "dbo"."Fee_Student_Status"."FSS_NetAmount",
        "dbo"."Fee_Student_Status"."FSS_FineAmount",
        "dbo"."Fee_Student_Status"."FSS_RefundAmount",
        "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
        "dbo"."Adm_School_M_Section"."ASMC_SectionName",
        "dbo"."Adm_M_Student"."AMST_FirstName" || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "Name",
        "dbo"."Adm_M_Student"."AMST_AdmNo",
        "dbo"."Adm_M_Student"."AMST_Id",
        "dbo"."Adm_School_M_Class"."ASMCL_Id",
        "dbo"."Adm_School_M_Section"."ASMS_Id"
    FROM
        "dbo"."Adm_M_Student"
    INNER JOIN "dbo"."Fee_Student_Status"
        INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads"
            ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id"
            AND "dbo"."Fee_Student_Status"."FTI_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "dbo"."Fee_Master_Head"
            ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id"
        INNER JOIN "dbo"."Fee_T_Installment"
            ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
        INNER JOIN "dbo"."Fee_Group_Login_Previledge"
            ON "dbo"."Fee_Group_Login_Previledge"."FMG_ID" = "dbo"."Fee_Student_Status"."FMG_Id"
            AND "dbo"."Fee_Group_Login_Previledge"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id"
        ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student"
        ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class"
        ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section"
        ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
    WHERE
        "dbo"."Fee_Student_Status"."AMST_Id" IN (
            SELECT DISTINCT "AMST_Id"
            FROM "dbo"."Adm_School_Y_Student"
            WHERE "AMST_Id" = "@amst_id"
                AND "dbo"."Fee_Student_Status"."ASMAY_Id" = "@amay_id"
        )
        AND "dbo"."Fee_Student_Status"."FSS_ActiveFlag" = 1
        AND "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" = "@fmt_id"
        AND "dbo"."Fee_Student_Status"."MI_Id" = "@mi_id"
        AND "dbo"."Fee_Group_Login_Previledge"."User_Id" = "@User_Id"
        AND "dbo"."Adm_School_M_Class"."ASMCL_Id" = "@asmcl_id"
        AND "dbo"."Adm_School_M_Section"."ASMS_Id" = "@amcl_id"
        AND "dbo"."Fee_Student_Status"."FSS_ToBePaid" > 0
    ORDER BY "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id"
    LIMIT 100;
    
    RETURN;
END;
$$;