CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPositionCollege_AsonDate"(
    "MI_Id" VARCHAR,
    "ASMAY_Id" VARCHAR,
    "AMCO_Id" VARCHAR,
    "AMB_Id" VARCHAR,
    "AMSE_Id" VARCHAR,
    "FMGG_Id" VARCHAR,
    "FMG_Id" VARCHAR,
    "Date" VARCHAR,
    "Fromdate" VARCHAR,
    "todate" VARCHAR,
    "Type" VARCHAR,
    "FTI_Id" VARCHAR,
    "status" VARCHAR,
    "AsOnduedate" VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "aa" VARCHAR;
    "where_condition" VARCHAR;
    "sqlquery" TEXT;
    "OnAnyDate" VARCHAR;
    "ASMAY_From_Date" VARCHAR;
    "SqlqueryC" TEXT;
    "trmr_id" BIGINT;
    "RouteName" VARCHAR(100);
    "Charges" BIGINT;
    "Concession" BIGINT;
    "Rebate" BIGINT;
    "Waive" BIGINT;
    "Fine" BIGINT;
    "Collection" BIGINT;
    "Debit" BIGINT;
    "LastYear" BIGINT;
    "routecursor" REFCURSOR;
    "IndRoute_College" REFCURSOR;
    "DynamicD1" TEXT;
    "DynamicD2" TEXT;
BEGIN

    IF "Fromdate" != '' AND "todate" != '' AND "Date" = '' THEN
        "where_condition" := ' and "FYP_DOE" between TO_TIMESTAMP(''' || "Fromdate" || ''', ''DD/MM/YYYY'') and TO_TIMESTAMP(''' || "todate" || ''', ''DD/MM/YYYY'') ';
    ELSIF "Date" != '' THEN
        SELECT TO_CHAR("ASMAY_From_Date", 'DD/MM/YYYY') INTO "ASMAY_From_Date" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = "MI_Id" AND "ASMAY_Id" = "ASMAY_Id";
        
        "where_condition" := ' and "FYP_Date" between TO_TIMESTAMP(''' || "ASMAY_From_Date" || ''', ''DD/MM/YYYY'') and TO_TIMESTAMP(''' || "Date" || ''', ''DD/MM/YYYY'')';
    ELSE
        "where_condition" := '';
    END IF;

    DROP TABLE IF EXISTS "IndRoute_College_Temp";

    CREATE TEMP TABLE "IndRoute_College_Temp"(
        "RouteName" VARCHAR(100),
        "Charges" BIGINT,
        "Concession" BIGINT,
        "Rebate" BIGINT,
        "Waive" BIGINT,
        "Fine" BIGINT,
        "Collection" BIGINT,
        "Debit" BIGINT,
        "LastYear" BIGINT
    );

    IF "Type" = 'headwise' THEN

        "sqlquery" := ';WITH cte AS (
            SELECT DISTINCT "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "FMH_FeeName" AS "FeeName", "FTI_Name",
                SUM("FCSS_NetAmount") AS "NetAmt", SUM("FCSS_ConcessionAmount") AS "ConcessAmt", 
                SUM("FCSS_RebateAmount") AS "RebateAmt", SUM("FCSS_WaivedAmount") AS "WaivedAmt",
                SUM("FCSS_FineAmount") AS "FineAmt", SUM("FCSS_PaidAmount") AS "CollectionAmt",
                SUM("FCSS_OBArrearAmount") AS "OBArrearAmt", SUM("FCSS_ToBePaid") AS "tobepaid"
            FROM "Fee_Master_Group" 
            INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                AND "Fee_Master_Group"."MI_Id" = ' || "MI_Id" || ' 
            INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                AND "Fee_Master_Head"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Collge_Student" ON "CLG"."Adm_Master_Collge_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
                AND "CLG"."Adm_Master_Collge_Student"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_Collge_Student"."AMCST_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id" = "CLG"."Adm_College_Yearly_Student"."AMCO_Id" 
                AND "CLG"."Adm_Master_Course"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id" 
                AND "CLG"."Adm_Master_Branch"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
                AND "CLG"."Adm_Master_Semester"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" ON "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id" 
                AND "CLG"."Fee_College_Master_Amount_SemesterWise"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id"
            INNER JOIN "CLG"."Fee_College_Master_Amount" ON "CLG"."Fee_College_Master_Amount"."FCMA_Id" = "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMA_Id" 
                AND "CLG"."Fee_College_Master_Amount"."ASMAY_Id" = ' || "ASMAY_Id" || '
                AND "CLG"."Fee_College_Master_Amount"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                AND "CLG"."Fee_College_Master_Amount"."FMH_Id" = "CLG"."Fee_College_Student_Status"."FMH_Id"
                AND "CLG"."Fee_College_Master_Amount"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Fee_College_Master_Amount"."AMCO_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Fee_College_Master_Amount"."AMB_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Fee_College_Master_Amount"."AMSE_Id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "CLG"."Fee_College_Master_Amount"."FTI_Id" 
                AND "Fee_T_Installment"."MI_Id" = ' || "MI_Id" || '
            WHERE "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
                AND "CLG"."Fee_College_Student_Status"."FMG_Id" IN (' || "FMG_Id" || ')
                AND "CLG"."Fee_College_Student_Status"."MI_Id" = ' || "MI_Id" || ' 
                AND "CLG"."Fee_College_Student_Status"."FMG_Id" IN (
                    SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups" 
                    WHERE "FMGG_Id" IN (
                        SELECT DISTINCT "FMGG_Id" FROM "Fee_Master_Group_Grouping" 
                        WHERE "MI_Id" = ' || "MI_Id" || ' AND "FMGG_Id" IN (' || "FMGG_Id" || ')
                    )
                )
                AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_Id" || '
            GROUP BY "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "Fee_Master_Head"."FMH_FeeName", "Fee_T_Installment"."FTI_Name"
        )
        SELECT "FeeName", SUM("NetAmt") AS "Charges", SUM("ConcessAmt") AS "Concession", 
            SUM("RebateAmt") AS "Rebate/Schlorship", SUM("WaivedAmt") AS "Waive Off", 
            SUM("FineAmt") AS "Fine", (SUM("CollectionAmt") - SUM("FineAmt")) AS "Collection", 
            SUM("tobepaid") AS "Debit Balance", SUM("OBArrearAmt") AS "Last Year Due" 
        FROM cte 
        GROUP BY "FeeName"';

        EXECUTE "sqlquery";

    ELSIF "Type" = 'route' THEN

        OPEN "routecursor" FOR 
            SELECT DISTINCT "MR"."TRMR_Id", "MR"."TRMR_RouteName" 
            FROM "TRN"."TR_Master_Route" "MR" 
            INNER JOIN "TRN"."TR_Student_Route_College" "SR" ON "MR"."MI_Id" = "SR"."MI_Id" 
                AND "SR"."ASMAY_Id" = "ASMAY_Id"
            WHERE "MR"."MI_Id" = "MI_Id" AND "TRMR_ActiveFlg" = TRUE;

        LOOP
            FETCH "routecursor" INTO "trmr_id", "RouteName";
            EXIT WHEN NOT FOUND;

            "sqlquery" := '
                SELECT SUM("Charges") "Charges", SUM("Concession") "Concession", SUM("Rebate/Schlorship") "Rebate/Schlorship", 
                    SUM("Waive Off") "Waive Off", SUM("Fine") "Fine", SUM("Collection") "Collection", 
                    SUM("Debit Balance") "Debit Balance", SUM("Last Year Due") "Last Year Due" 
                FROM (
                    SELECT SUM("FSS_NetAmount") "Charges", SUM("FSS_ConcessionAmount") AS "Concession", 
                        SUM("FSS_RebateAmount") AS "Rebate/Schlorship", SUM("FSS_WaivedAmount") AS "Waive Off", 
                        SUM("FSS_FineAmount") AS "Fine", SUM("FSS_PaidAmount") AS "Collection", 
                        SUM("FSS_ToBePaid") AS "Debit Balance", SUM("FSS_OBArrearAmount") AS "Last Year Due", 
                        "Fee_Master_Group"."FMG_GroupName"
                    FROM "Fee_Master_Group" 
                    INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id"
                    INNER JOIN "Fee_Master_Group_Grouping_Groups" ON "CLG"."Fee_College_Student_Status"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                    INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id" = "CLG"."Adm_College_Yearly_Student"."AMCO_Id" 
                        AND "CLG"."Adm_Master_Course"."MI_Id" = ' || "MI_Id" || '
                    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id" 
                        AND "CLG"."Adm_Master_Branch"."MI_Id" = ' || "MI_Id" || '
                    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
                        AND "CLG"."Adm_Master_Semester"."MI_Id" = ' || "MI_Id" || '
                    INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" ON "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id" 
                        AND "CLG"."Fee_College_Master_Amount_SemesterWise"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id"
                    INNER JOIN "CLG"."Fee_College_Master_Amount" ON "CLG"."Fee_College_Master_Amount"."FCMA_Id" = "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMA_Id" 
                        AND "CLG"."Fee_College_Master_Amount"."ASMAY_Id" = ' || "ASMAY_Id" || '
                        AND "CLG"."Fee_College_Master_Amount"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                        AND "CLG"."Fee_College_Master_Amount"."FMH_Id" = "CLG"."Fee_College_Student_Status"."FMH_Id"
                        AND "CLG"."Fee_College_Master_Amount"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id" 
                        AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Fee_College_Master_Amount"."AMCO_Id" 
                        AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Fee_College_Master_Amount"."AMB_Id" 
                        AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Fee_College_Master_Amount"."AMSE_Id" 
                    INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" 
                        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "CLG"."Fee_College_Student_Status"."ASMAY_Id" 
                    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "CLG"."Fee_College_Master_Amount"."FTI_Id" 
                        AND "Fee_T_Installment"."MI_Id" = ' || "MI_Id" || '
                    WHERE "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
                        AND "CLG"."Fee_College_Student_Status"."MI_Id" = ' || "MI_Id" || ' 
                        AND "Fee_T_Installment"."FTI_Id" IN (' || "FTI_Id" || ')
                        AND "CLG"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" = TRUE 
                        AND "CLG"."Adm_Master_College_Student"."AMCST_SOL" = ''S'' 
                        AND "CLG"."Adm_Master_College_Student"."AMCST_ActiveFlag" = TRUE 
                        AND "CLG"."Fee_College_Student_Status"."FMG_Id" IN (' || "FMG_Id" || ') 
                        AND "FMGG_Id" IN (' || "FMGG_Id" || ')
                        AND "CLG"."Fee_College_Student_Status"."AMCST_Id" IN (
                            SELECT DISTINCT "AMCST_Id" FROM "TRN"."TR_Student_Route_College" 
                            WHERE "MI_Id" = ' || "MI_Id" || ' 
                                AND "TRSRCO_PickUpRoute" IN (
                                    SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" 
                                    WHERE "MI_Id" = ' || "MI_Id" || ' AND "TRMR_Id" = ' || "trmr_id" || '
                                ) 
                                AND "ASMAY_Id" = ' || "ASMAY_Id" || ' AND "TRRSCO_ActiveFlg" = TRUE
                            UNION
                            SELECT DISTINCT "AMCST_Id" FROM "TRN"."TR_Student_Route_College" 
                            WHERE "MI_Id" = ' || "MI_Id" || ' 
                                AND "TRSRCO_DropRoute" IN (
                                    SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" 
                                    WHERE "MI_Id" = ' || "MI_Id" || ' AND "TRMR_Id" = ' || "trmr_id" || '
                                )
                                AND "ASMAY_Id" = ' || "ASMAY_Id" || ' AND "TRRSCO_ActiveFlg" = TRUE 
                                AND "AMCST_Id" NOT IN (
                                    SELECT DISTINCT "AMCST_Id" FROM "TRN"."TR_Student_Route_College" 
                                    WHERE "MI_Id" = ' || "MI_Id" || ' 
                                        AND "TRSRCO_PickUpRoute" IN (
                                            SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" 
                                            WHERE "MI_Id" = ' || "MI_Id" || ' AND "TRMR_Id" <> 0
                                        ) 
                                        AND "ASMAY_Id" = ' || "ASMAY_Id" || ' AND "TRRSCO_ActiveFlg" = TRUE
                                )
                        )
                    GROUP BY "Fee_Master_Group"."FMG_GroupName"
                ) "New"';

            OPEN "IndRoute_College" FOR EXECUTE "sqlquery";

            LOOP
                FETCH "IndRoute_College" INTO "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear";
                EXIT WHEN NOT FOUND;

                INSERT INTO "IndRoute_College_Temp" 
                VALUES ("RouteName", "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear");
            END LOOP;

            CLOSE "IndRoute_College";
        END LOOP;

        CLOSE "routecursor";

        PERFORM * FROM (
            SELECT "RouteName", SUM("Charges") AS "Charges", SUM("Concession") AS "Concession", 
                SUM("Rebate") AS "Rebate/Schlorship", SUM("Waive") AS "Waive Off", SUM("Fine") AS "Fine", 
                (SUM("Collection") - SUM("Fine")) AS "Collection", SUM("Debit") AS "Debit Balance", 
                SUM("LastYear") AS "Last Year Due" 
            FROM "IndRoute_College_Temp" 
            GROUP BY "RouteName" 
            HAVING SUM("Charges") > 0
        ) result;

    ELSIF "Type" = 'All' THEN

        "sqlquery" := ';WITH cte AS (
            SELECT DISTINCT "AMCO_CourseName", "AMB_BranchName", 
                SUM("CLG"."Fee_College_Student_Status"."FCSS_NetAmount") AS "NetAmt",
                SUM("FCSS_ConcessionAmount") AS "ConcessAmt", SUM("FCSS_RebateAmount") AS "RebateAmt",
                SUM("FCSS_WaivedAmount") AS "WaivedAmt", SUM("FCSS_FineAmount") AS "FineAmt",
                SUM("FCSS_PaidAmount") AS "CollectionAmt", SUM("FCSS_OBArrearAmount") AS "OBArrearAmt",
                SUM("FCSS_ToBePaid") AS "tobepaid"
            FROM "Fee_Master_Group" 
            INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                AND "Fee_Master_Group"."MI_Id" = ' || "MI_Id" || ' 
            INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                AND "Fee_Master_Head"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Collge_Student" ON "CLG"."Adm_Master_Collge_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
                AND "CLG"."Adm_Master_Collge_Student"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_Collge_Student"."AMCST_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id" = "CLG"."Adm_College_Yearly_Student"."AMCO_Id" 
                AND "CLG"."Adm_Master_Course"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id" 
                AND "CLG"."Adm_Master_Branch"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
                AND "CLG"."Adm_Master_Semester"."MI_Id" = ' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" ON "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id" 
                AND "CLG"."Fee_College_Master_Amount_SemesterWise"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id"
            INNER JOIN "CLG"."Fee_College_Master_Amount" ON "CLG"."Fee_College_Master_Amount"."FCMA_Id" = "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMA_Id" 
                AND "CLG"."Fee_College_Master_Amount"."ASMAY_Id" = ' || "ASMAY_Id" || '
                AND "CLG"."Fee_College_Master_Amount"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                AND "CLG"."Fee_College_Master_Amount"."FMH_Id" = "CLG"."Fee_College_Student_Status"."FMH_Id"
                AND "CLG"."Fee_College_Master_Amount"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Fee_College_Master_Amount"."AMCO_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Fee_College_Master_Amount"."AMB_Id" 
                AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Fee_College_Master_Amount"."AMSE_Id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "CLG"."Fee_College_Master_Amount"."FTI_Id" 
                AND "Fee_T_Installment"."MI_Id" = ' || "MI_Id" || '
            WHERE "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
                AND "CLG"."Fee_College_Student_Status"."FMG_Id" IN (' || "FMG_Id" || ')
                AND "CLG"."Fee_College_Student_Status"."MI_Id" = ' || "MI_Id" || ' 
                AND "CLG"."Fee_College_Student_Status"."FMG_Id" IN (
                    SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups" 
                    WHERE "FMGG_Id" IN (
                        SELECT DISTINCT "FMGG_Id" FROM "Fee_Master_Group_Grouping" 
                        WHERE "MI_Id" = ' || "MI_Id" || ' AND "FMGG_Id" IN (' || "FMGG_Id" || ')
                    )
                )
                AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_Id" || '
            GROUP BY "AMCO_CourseName", "AMB_BranchName"
        )
        SELECT "AMCO_CourseName", "AMB_BranchName", SUM("NetAmt") "Charges", SUM("ConcessAmt") "Concession", 
            SUM("RebateAmt") "Rebate/Schlorship", SUM("WaivedAmt") "Waive Off", SUM("FineAmt") "Fine",
            (SUM("CollectionAmt") - SUM("FineAmt")) "Collection", SUM("tobepaid") "Debit Balance", 
            SUM("OBArrearAmt") "Last Year Due" 
        FROM cte 
        GROUP BY "AMCO_CourseName", "AMB_BranchName"';

        EXECUTE "sqlquery";

    ELSIF "Type" = 'individual' AND "status" = 'true' THEN

        "sqlquery" := ';WITH cte AS (
            SELECT DISTINCT "AMCST_Admno" AS "admno",
                (COALESCE("AMCST_FirstName", '''') || '' '' || COALESCE("AMCST_MiddleName", '''') || '' '' || COALESCE("AMCST_LastName", '''')) AS "StudentName",
                "FMH_FeeName" "FeeName", "FTI_Name" "TName", "FCSS_NetAmount" AS "NetAmt",
                "FCSS_ConcessionAmount" AS "ConcessAmt", "FCSS_RebateAmount" AS "RebateAmt",
                "FCSS_WaivedAmount" AS "WaivedAmt", "FCSS_FineAmount" AS "FineAmt",
                "FCSS_PaidAmount" AS "CollectionAmt", "FCSS_OBArrearAmount" AS "OBArrearAmt",
                "FCSS_ToBePaid" AS "tobepaid", "FCSS_CurrentYrCharges" AS "Currentamt"
            FROM "Fee_Master_Group" 
            INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" =