CREATE OR REPLACE FUNCTION "dbo"."InstituwiseFeeCollection"(
    "MI_Id" TEXT,
    "monthid" TEXT
)
RETURNS TABLE(
    "MI_Id" VARCHAR,
    "IVRM_Month_Name" VARCHAR,
    "IVRM_Month_Id" INTEGER,
    "MI_Name" VARCHAR,
    "callected" NUMERIC,
    "ballance" NUMERIC,
    "concession" NUMERIC,
    "waived" NUMERIC,
    "rebate" NUMERIC,
    "fine" NUMERIC,
    "receivable" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN

    "query" := ' SELECT "Master_Institution"."MI_Id",
                       "IVRM_Month"."IVRM_Month_Name",
                       "IVRM_Month"."IVRM_Month_Id",
                       "Master_Institution"."MI_Name",
                       (SUM(COALESCE("dbo"."fee_student_status"."FSS_PaidAmount",0)) - SUM(COALESCE("dbo"."fee_student_status"."FSS_FineAmount",0))) AS "callected",
                       SUM(COALESCE("dbo"."fee_student_status"."FSS_ToBePaid",0)) AS "ballance",
                       SUM(COALESCE("dbo"."Fee_Student_Status"."FSS_ConcessionAmount",0)) AS "concession",
                       SUM(COALESCE("dbo"."Fee_Student_Status"."FSS_WaivedAmount",0)) AS "waived",
                       SUM(COALESCE("dbo"."Fee_Student_Status"."FSS_RebateAmount",0)) AS "rebate",
                       SUM(COALESCE("dbo"."Fee_Student_Status"."FSS_FineAmount",0)) AS "fine",
                       SUM(COALESCE("dbo"."fee_student_status"."FSS_CurrentYrCharges",0)) AS "receivable"
                FROM "dbo"."fee_student_status"
                INNER JOIN "Master_Institution" ON "dbo"."fee_student_status"."MI_Id" = "Master_Institution"."MI_Id"
                LEFT JOIN "IVRM_Month" ON "IVRM_Month"."IVRM_Month_Id" IN (' || "monthid" || ')
                WHERE ("Master_Institution"."MI_Id" IN (' || "MI_Id" || ') AND "dbo"."fee_student_status"."MI_Id" IN (' || "MI_Id" || '))
                GROUP BY "Master_Institution"."MI_Name", "IVRM_Month"."IVRM_Month_Name", "IVRM_Month"."IVRM_Month_Id", "Master_Institution"."MI_Id"
                ORDER BY "IVRM_Month"."IVRM_Month_Id"';

    RETURN QUERY EXECUTE "query";

END;
$$;