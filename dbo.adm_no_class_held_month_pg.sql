CREATE OR REPLACE FUNCTION "dbo"."adm_no_class_held_month"(
    "@yearid" VARCHAR(100),
    "@miid" TEXT,
    "@classid" TEXT,
    "@secid" TEXT,
    "@flag" TEXT,
    "@monthid" TEXT
)
RETURNS TABLE("classheld" NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "a"."ASCH_ClassHeld" AS "classheld"
    FROM "Adm_School_Attendance_EntryType" "a"
    INNER JOIN "Adm_School_Class_Held" "b" ON "a"."ASMCL_Id" = "b"."ASMCL_Id"
    WHERE "b"."ASMAY_Id" = "@yearid"
        AND "a"."ASMAY_Id" = "@yearid"
        AND "b"."ASMCL_Id" = "@classid"
        AND "b"."ASMS_Id" = "@secid"
        AND "IVRM_Month_Id" = "@monthid"
        AND "ASAET_Att_Type" = "@flag"
        AND "a"."MI_Id" = "@miid";
END;
$$;