CREATE OR REPLACE FUNCTION "dbo"."Admission_Get_ECS_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_DATE" VARCHAR(20)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "STUDENTNAME" TEXT,
    "ADMNO" TEXT,
    "ACCOUNTHOLDERNAME" TEXT,
    "ACCOUNTNO" TEXT,
    "ACCOUNTTYPE" TEXT,
    "BANKNAME" TEXT,
    "BRANCH" TEXT,
    "MICRNO" TEXT,
    "CLASSNAME" TEXT,
    "SECTIONNAME" TEXT,
    "ASMCL_Order" INT,
    "ASMC_Order" INT,
    "AMOUNT" DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_QUERYASMCLID" TEXT;
    "v_QUERYASMSID" TEXT;
    "v_QUERY" TEXT;
    "v_STUDENTNAME" TEXT;
    "v_ADMNO" TEXT;
    "v_ACCOUNTHOLDERNAME" TEXT;
    "v_ACCOUNTNO" TEXT;
    "v_ACCOUNTTYPE" TEXT;
    "v_BANKNAME" TEXT;
    "v_BRANCH" TEXT;
    "v_MICRNO" TEXT;
    "v_CLASSNAME" TEXT;
    "v_SECTIONNAME" TEXT;
    "v_DUEDATE" TEXT;
    "v_ASMCL_Order" INT;
    "v_ASMC_Order" INT;
    "v_AMST_Id" BIGINT;
    "v_TOTALDUEAMOUNT" DOUBLE PRECISION;
    "v_TOTALAMOUNT" DOUBLE PRECISION;
    "v_blance" BIGINT;
    "v_FMA_Id" BIGINT;
    "v_amt" DOUBLE PRECISION;
    "v_flgArr" INT;
    "rec" RECORD;
    "fee_rec" RECORD;
BEGIN
    DROP TABLE IF EXISTS "ECS_REPORT_DETAILS_Temp";

    IF "p_ASMCL_Id" = '0' THEN
        "v_QUERYASMCLID" := 'SELECT DISTINCT "ASMCL_Id" FROM "ADM_SCHOOL_M_CLASS" WHERE "MI_Id"=' || "p_MI_Id" || ' AND "ASMCL_ActiveFlag"=1';
    ELSE
        "v_QUERYASMCLID" := 'SELECT DISTINCT "ASMCL_Id" FROM "ADM_SCHOOL_M_CLASS" WHERE "MI_Id"=' || "p_MI_Id" || ' AND "ASMCL_Id"=' || "p_ASMCL_Id" || ' AND "ASMCL_ActiveFlag"=1';
    END IF;

    IF "p_ASMS_Id" = '0' THEN
        "v_QUERYASMSID" := 'SELECT DISTINCT "ASMS_Id" FROM "ADM_SCHOOL_M_SECTION" WHERE "MI_Id"=' || "p_MI_Id" || ' AND "ASMC_ActiveFlag"=1';
    ELSE
        "v_QUERYASMSID" := 'SELECT DISTINCT "ASMS_Id" FROM "ADM_SCHOOL_M_SECTION" WHERE "MI_Id"=' || "p_MI_Id" || ' AND "ASMS_Id"=' || "p_ASMS_Id" || ' AND "ASMC_ActiveFlag"=1';
    END IF;

    "v_QUERY" := '
    CREATE TEMP TABLE "ECS_REPORT_DETAILS_Temp" AS
    SELECT B."AMST_Id",
    (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName"='''' THEN '''' ELSE A."AMST_FirstName" END ||
    CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName"='''' THEN '''' ELSE '' '' || A."AMST_MiddleName" END ||
    CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName"='''' THEN '''' ELSE '' '' || A."AMST_LastName" END) AS "STUDENTNAME",
    A."AMST_AdmNo" AS "ADMNO",
    C."ASECS_AccountHolderName" AS "ACCOUNTHOLDERNAME",
    C."ASECS_AccountNo" AS "ACCOUNTNO",
    C."ASECS_AccountType" AS "ACCOUNTTYPE",
    C."ASECS_BankName" AS "BANKNAME",
    C."ASECS_Branch" AS "BRANCH",
    C."ASECS_MICRNo" AS "MICRNO",
    E."ASMCL_ClassName" AS "CLASSNAME",
    F."ASMC_SectionName" AS "SECTIONNAME",
    E."ASMCL_Order",
    F."ASMC_Order"
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id"=B."AMST_Id"
    INNER JOIN "Adm_Student_ECS" C ON C."AMST_Id"=A."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id"=B."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id"=B."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id"=B."ASMS_Id"
    WHERE B."ASMAY_Id"=' || "p_ASMAY_Id" || ' AND A."MI_Id"=' || "p_MI_Id" || ' 
    AND A."AMST_SOL"=''S'' AND A."AMST_ActiveFlag"=1 AND B."AMAY_ActiveFlag"=1
    AND C."ASECS_ActiveFlg"=1 AND B."ASMCL_Id" IN (' || "v_QUERYASMCLID" || ') 
    AND B."ASMS_Id" IN (' || "v_QUERYASMSID" || ') AND A."AMST_ECSFlag"=1
    ORDER BY E."ASMCL_Order", F."ASMC_Order", "ADMNO", "STUDENTNAME"';

    EXECUTE "v_QUERY";

    ALTER TABLE "ECS_REPORT_DETAILS_Temp" ADD COLUMN "AMOUNT" DOUBLE PRECISION NULL;

    FOR "rec" IN 
        SELECT "AMST_Id", "STUDENTNAME", "ADMNO", "ACCOUNTHOLDERNAME", "ACCOUNTNO", 
               "ACCOUNTTYPE", "BANKNAME", "BRANCH", "MICRNO", "CLASSNAME", 
               "SECTIONNAME", "ASMCL_Order", "ASMC_Order" 
        FROM "ECS_REPORT_DETAILS_Temp"
    LOOP
        "v_AMST_Id" := "rec"."AMST_Id";
        "v_STUDENTNAME" := "rec"."STUDENTNAME";
        "v_ADMNO" := "rec"."ADMNO";
        "v_ACCOUNTHOLDERNAME" := "rec"."ACCOUNTHOLDERNAME";
        "v_ACCOUNTNO" := "rec"."ACCOUNTNO";
        "v_ACCOUNTTYPE" := "rec"."ACCOUNTTYPE";
        "v_BANKNAME" := "rec"."BANKNAME";
        "v_BRANCH" := "rec"."BRANCH";
        "v_MICRNO" := "rec"."MICRNO";
        "v_CLASSNAME" := "rec"."CLASSNAME";
        "v_SECTIONNAME" := "rec"."SECTIONNAME";
        "v_ASMCL_Order" := "rec"."ASMCL_Order";
        "v_ASMC_Order" := "rec"."ASMC_Order";

        "v_TOTALDUEAMOUNT" := 0;
        "v_blance" := 0;

        SELECT COALESCE(SUM("FSS_ToBePaid"), 0) INTO "v_blance"
        FROM "Fee_Student_Status"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."fti_id"
        INNER JOIN "Fee_T_Installment_DueDate" ON "Fee_T_Installment_DueDate"."fti_Id" = "Fee_T_Installment"."FTI_Id"
        WHERE "AMST_Id" = "v_AMST_Id"
        AND CAST("FTIDD_DueDate" AS DATE) < CAST("p_DATE" AS DATE)
        AND "Fee_T_Installment_DueDate"."ASMAY_Id" = CAST("p_ASMAY_Id" AS BIGINT);

        IF "v_blance" > 0 THEN
            FOR "fee_rec" IN 
                SELECT DISTINCT "FMA_Id" 
                FROM "Fee_Student_Status" 
                WHERE "FTI_Id" IN (
                    SELECT "FTI_Id" 
                    FROM "Fee_T_Installment_DueDate" 
                    WHERE "FTIDD_DueDate" <= CAST("p_DATE" AS DATE)
                    AND "MI_Id" = CAST("p_MI_Id" AS BIGINT)
                    AND "ASMAY_Id" = CAST("p_ASMAY_Id" AS BIGINT)
                ) 
                AND "AMST_Id" = "v_AMST_Id" 
                AND "FSS_ToBePaid" > 0 
                AND "FMH_Id" IN (
                    SELECT "FMH_Id" 
                    FROM "Fee_Yearly_Group_Head_Mapping" 
                    WHERE "FYGHM_FineApplicableFlag" = 'Y'
                )
            LOOP
                "v_FMA_Id" := "fee_rec"."FMA_Id";
                
                SELECT * INTO "v_amt", "v_flgArr"
                FROM "Sp_Calculate_Fine_ECS"(
                    CAST("p_DATE" AS DATE),
                    "v_FMA_Id",
                    CAST("p_ASMAY_Id" AS BIGINT)
                );

                "v_TOTALDUEAMOUNT" := "v_TOTALDUEAMOUNT" + COALESCE("v_amt", 0);
            END LOOP;

            "v_TOTALAMOUNT" := "v_TOTALDUEAMOUNT" + CAST("v_blance" AS DOUBLE PRECISION);

            UPDATE "ECS_REPORT_DETAILS_Temp" 
            SET "AMOUNT" = "v_TOTALAMOUNT" 
            WHERE "AMST_Id" = "v_AMST_Id";
        END IF;
    END LOOP;

    RETURN QUERY 
    SELECT t."AMST_Id", t."STUDENTNAME", t."ADMNO", t."ACCOUNTHOLDERNAME", 
           t."ACCOUNTNO", t."ACCOUNTTYPE", t."BANKNAME", t."BRANCH", 
           t."MICRNO", t."CLASSNAME", t."SECTIONNAME", t."ASMCL_Order", 
           t."ASMC_Order", t."AMOUNT"
    FROM "ECS_REPORT_DETAILS_Temp" t
    WHERE t."AMOUNT" IS NOT NULL
    ORDER BY t."ASMCL_Order", t."ASMC_Order", t."STUDENTNAME";

    DROP TABLE IF EXISTS "ECS_REPORT_DETAILS_Temp";

    RETURN;
END;
$$;