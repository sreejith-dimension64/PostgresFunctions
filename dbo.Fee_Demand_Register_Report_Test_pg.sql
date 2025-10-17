CREATE OR REPLACE FUNCTION "dbo"."Fee_Demand_Register_Report_Test"(
    "mi_id" BIGINT,
    "asmay_Id" BIGINT,
    "asmcl_id" BIGINT,
    "amsc_id" BIGINT,
    "amst_id" BIGINT,
    "fmgg_id" TEXT,
    "fmg_id" TEXT,
    "FeeName" TEXT,
    "FT_Name" TEXT,
    "date" VARCHAR(10),
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "type" VARCHAR(10)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "aa" TEXT;
    "where_condition" TEXT;
    "sqlquery" TEXT;
    "FName" TEXT;
    "TName" TEXT;
BEGIN

    IF "fromdate" != '' AND "todate" != '' THEN
        "where_condition" := ' and TO_CHAR("FYP_Date"::DATE, ''DD-MM-YYYY'') between ''' || "fromdate" || ''' and ''' || "todate" || '''';
    ELSIF "date" != '' THEN
        "where_condition" := ' and TO_CHAR("FYP_Date"::DATE, ''DD-MM-YYYY'') = ''' || "date" || '''';
    ELSE
        "where_condition" := '';
    END IF;

    "FName" := REPLACE("FeeName", ',', ''',''');
    "TName" := REPLACE("FT_Name", ',', ''',''');

    IF "type" = 'All' THEN
        
        "sqlquery" := '
        WITH cte AS (
            SELECT 
                COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '''') AS "StudentName",
                "dbo"."Adm_M_Student"."AMST_AdmNo" AS "adm_no",
                "Fee_Y_Payment"."mi_id",
                "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
                "dbo"."Adm_School_M_Section"."ASMC_SectionName",
                "dbo"."Fee_Master_Head"."FMH_FeeName",
                "dbo"."Fee_T_Installment"."FTI_Name",
                "dbo"."Fee_Master_Group"."FMG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Id",
                "dbo"."Fee_Y_Payment_School_Student"."FYPS_Id",
                "dbo"."Fee_Master_Group_Grouping"."FMGG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
                "dbo"."Fee_Y_Payment"."FYP_Date",
                "dbo"."Fee_Y_Payment"."user_id",
                "dbo"."Fee_T_Payment"."FTP_Paid_Amt",
                "dbo"."Fee_T_Payment"."FTP_Fine_Amt",
                "dbo"."Fee_T_Payment"."FTP_Concession_Amt",
                "dbo"."Fee_Student_Status"."FSS_ToBePaid",
                "dbo"."Fee_T_Payment"."FTP_Paid_Amt" AS "Paid_AmtN"
            FROM "dbo"."Fee_Master_Group"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" 
                INNER JOIN "dbo"."Fee_Master_Group_Grouping" 
                    ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping"."FMGG_Id"
                ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head"
                INNER JOIN "dbo"."Fee_Y_Payment"
                    INNER JOIN "dbo"."Fee_Y_Payment_School_Student"
                        INNER JOIN "dbo"."Fee_Student_Status"
                            INNER JOIN "dbo"."Adm_School_Y_Student"
                                INNER JOIN "dbo"."Adm_M_Student" 
                                    ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
                                INNER JOIN "dbo"."Adm_School_M_Class" 
                                    ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
                                INNER JOIN "dbo"."Adm_School_M_Section" 
                                    ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
                            ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
                        ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id"
                    ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id"
                    INNER JOIN "dbo"."Fee_T_Payment" 
                        ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_T_Payment"."FYP_Id"
                ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id"
            ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_T_Installment" 
                ON "dbo"."Fee_Student_Status"."FTI_Id" = "dbo"."Fee_T_Installment"."FTI_Id"
            WHERE "Fee_Y_Payment"."mi_id" = ' || "mi_id"::TEXT || '
                AND "Fee_Y_Payment"."ASMAY_ID" = ' || "asmay_Id"::TEXT || '
                AND "dbo"."Adm_School_Y_Student"."ASMCL_Id" = ' || "asmcl_id"::TEXT || '
                AND "dbo"."Adm_School_Y_Student"."ASMS_Id" = ' || "amsc_id"::TEXT || '
                AND "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" IN (' || "fmgg_id" || ')
                AND "dbo"."Fee_Master_Head"."FMH_FeeName" IN (''' || "FeeName" || ''')
                AND "dbo"."Fee_T_Installment"."FTI_Name" IN (''' || "FT_Name" || ''')
                AND "dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')' || "where_condition" || '
            GROUP BY 
                "dbo"."Adm_M_Student"."AMST_FirstName",
                "dbo"."Adm_M_Student"."AMST_MiddleName",
                "dbo"."Adm_M_Student"."AMST_LastName",
                "dbo"."Adm_M_Student"."AMST_AdmNo",
                "Fee_Y_Payment"."mi_id",
                "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
                "dbo"."Adm_School_M_Section"."ASMC_SectionName",
                "dbo"."Fee_Master_Head"."FMH_FeeName",
                "dbo"."Fee_T_Installment"."FTI_Name",
                "dbo"."Fee_Master_Group"."FMG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Id",
                "dbo"."Fee_Y_Payment_School_Student"."FYPS_Id",
                "dbo"."Fee_Master_Group_Grouping"."FMGG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
                "dbo"."Fee_Y_Payment"."FYP_Date",
                "dbo"."Fee_Y_Payment"."user_id",
                "dbo"."Fee_T_Payment"."FTP_Paid_Amt",
                "dbo"."Fee_T_Payment"."FTP_Fine_Amt",
                "dbo"."Fee_T_Payment"."FTP_Concession_Amt",
                "dbo"."Fee_Student_Status"."FSS_ToBePaid"
        )
        SELECT * FROM cte';

        RETURN QUERY EXECUTE "sqlquery";

    ELSIF "type" = 'Indi' THEN

        "sqlquery" := '
        WITH cte AS (
            SELECT 
                COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '''') AS "StudentName",
                "dbo"."Adm_M_Student"."AMST_AdmNo" AS "adm_no",
                "Fee_Y_Payment"."mi_id",
                "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
                "dbo"."Adm_School_M_Section"."ASMC_SectionName",
                "dbo"."Fee_Master_Head"."FMH_FeeName",
                "dbo"."Fee_T_Installment"."FTI_Name",
                "dbo"."Fee_Master_Group"."FMG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Id",
                "dbo"."Fee_Y_Payment_School_Student"."FYPS_Id",
                "dbo"."Fee_Master_Group_Grouping"."FMGG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
                "dbo"."Fee_Y_Payment"."FYP_Date",
                "dbo"."Fee_Y_Payment"."user_id",
                "dbo"."Fee_T_Payment"."FTP_Paid_Amt",
                "dbo"."Fee_T_Payment"."FTP_Fine_Amt",
                "dbo"."Fee_T_Payment"."FTP_Concession_Amt",
                "dbo"."Fee_Student_Status"."FSS_ToBePaid",
                "dbo"."Fee_T_Payment"."FTP_Paid_Amt" AS "Paid_AmtN"
            FROM "dbo"."Fee_Master_Group"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups"
                INNER JOIN "dbo"."Fee_Master_Group_Grouping"
                    ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping"."FMGG_Id"
                ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head"
                INNER JOIN "dbo"."Fee_Y_Payment"
                    INNER JOIN "dbo"."Fee_Y_Payment_School_Student"
                        INNER JOIN "dbo"."Fee_Student_Status"
                            INNER JOIN "dbo"."Adm_School_Y_Student"
                                INNER JOIN "dbo"."Adm_M_Student"
                                    ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
                                INNER JOIN "dbo"."Adm_School_M_Class"
                                    ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
                                INNER JOIN "dbo"."Adm_School_M_Section"
                                    ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
                            ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
                        ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id"
                    ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id"
                    INNER JOIN "dbo"."Fee_T_Payment"
                        ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_T_Payment"."FYP_Id"
                ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id"
            ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_T_Installment"
                ON "dbo"."Fee_Student_Status"."FTI_Id" = "dbo"."Fee_T_Installment"."FTI_Id"
            WHERE "dbo"."Fee_Y_Payment"."mi_id" = ' || "mi_id"::TEXT || '
                AND "dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || "asmay_Id"::TEXT || '
                AND "dbo"."Adm_School_Y_Student"."ASMCL_Id" = ' || "asmcl_id"::TEXT || '
                AND "dbo"."Adm_School_Y_Student"."ASMS_Id" = ' || "amsc_id"::TEXT || '
                AND "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" IN (' || "fmgg_id" || ')
                AND "dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')
                AND "dbo"."Fee_Master_Head"."FMH_FeeName" IN (''' || "FeeName" || ''')
                AND "dbo"."Fee_T_Installment"."FTI_Name" IN (''' || "FT_Name" || ''')
                AND "dbo"."Fee_Student_Status"."amst_id" = ' || "amst_id"::TEXT || ' ' || "where_condition" || '
            GROUP BY 
                "dbo"."Adm_M_Student"."AMST_FirstName",
                "dbo"."Adm_M_Student"."AMST_MiddleName",
                "dbo"."Adm_M_Student"."AMST_LastName",
                "dbo"."Adm_M_Student"."AMST_AdmNo",
                "Fee_Y_Payment"."mi_id",
                "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
                "dbo"."Adm_School_M_Section"."ASMC_SectionName",
                "dbo"."Fee_Master_Head"."FMH_FeeName",
                "dbo"."Fee_T_Installment"."FTI_Name",
                "dbo"."Fee_Master_Group"."FMG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Id",
                "dbo"."Fee_Y_Payment_School_Student"."FYPS_Id",
                "dbo"."Fee_Master_Group_Grouping"."FMGG_GroupName",
                "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
                "dbo"."Fee_Y_Payment"."FYP_Date",
                "dbo"."Fee_Y_Payment"."user_id",
                "dbo"."Fee_T_Payment"."FTP_Paid_Amt",
                "dbo"."Fee_T_Payment"."FTP_Fine_Amt",
                "dbo"."Fee_T_Payment"."FTP_Concession_Amt",
                "dbo"."Fee_Student_Status"."FSS_ToBePaid"
        )
        SELECT * FROM cte';

        RETURN QUERY EXECUTE "sqlquery";

    END IF;

    RETURN;

END;
$$;