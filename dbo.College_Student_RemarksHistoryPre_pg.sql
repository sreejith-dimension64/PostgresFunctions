CREATE OR REPLACE FUNCTION "dbo"."College_Student_RemarksHistoryPre"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@FLAG" TEXT,
    "@PACA_Id" TEXT
)
RETURNS TABLE(
    "statustype" VARCHAR,
    "paca_id" BIGINT,
    "statusremark" VARCHAR,
    "studentname" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@FLAG" = 'Appsts' THEN
        RETURN QUERY
        SELECT 
            "b"."PACA_ApplStatus" as "statustype",
            "b"."paca_id",
            "a"."PASSHC_Status" as "statusremark",
            (COALESCE("b"."PACA_FirstName", '') || ' ' || COALESCE("b"."PACA_MiddleName", '') || ' ' || COALESCE("b"."PACA_LastName", '')) as "studentname"
        FROM "clg"."PA_Student_Status_History_College" "a"
        INNER JOIN "clg"."PA_College_Application" "b" ON "a"."PACA_Id" = "b"."PACA_Id"
        WHERE "b"."MI_Id" = "@MI_Id"
        AND "b"."AMCO_Id" = "@AMCO_Id"
        AND "a"."paca_id" = "@PACA_Id"
        AND "b"."ASMAY_Id" = "@ASMAY_Id";

    ELSIF "@FLAG" = 'admsts' THEN
        RETURN QUERY
        SELECT 
            "b"."PACA_AdmStatus" as "statustype",
            "b"."paca_id",
            "a"."PASSHC_Status" as "statusremark",
            (COALESCE("b"."PACA_FirstName", '') || ' ' || COALESCE("b"."PACA_MiddleName", '') || ' ' || COALESCE("b"."PACA_LastName", '')) as "studentname"
        FROM "clg"."PA_Student_Status_History_College" "a"
        INNER JOIN "clg"."PA_College_Application" "b" ON "a"."PACA_Id" = "b"."PACA_Id"
        WHERE "b"."MI_Id" = "@MI_Id"
        AND "b"."AMCO_Id" = "@AMCO_Id"
        AND "a"."paca_id" = "@PACA_Id"
        AND "b"."ASMAY_Id" = "@ASMAY_Id";

    END IF;

    RETURN;

END;
$$;