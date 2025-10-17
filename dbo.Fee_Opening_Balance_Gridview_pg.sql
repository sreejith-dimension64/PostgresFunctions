CREATE OR REPLACE FUNCTION "dbo"."Fee_Opening_Balance_Gridview"(
    "Type" VARCHAR(50),
    "Mi_Id" TEXT,
    "Amay_Id" TEXT,
    "Asmcl_Id" TEXT,
    "Asms_Id" TEXT,
    "fmcC_Id" TEXT,
    "Amst_Id" TEXT,
    "Status" VARCHAR(50),
    "fmgid" TEXT,
    "fmhid" TEXT,
    "ftiid" TEXT,
    "userid" TEXT
)
RETURNS TABLE(
    "ID" BIGINT,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR,
    "FMOB_Student_Due" NUMERIC,
    "FMOB_Institution_Due" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    IF "Type" = 'All' THEN
        IF "Status" = 'Active' THEN
            v_query := 'SELECT DISTINCT "ID", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", COALESCE("FMOB_Student_Due", 0) AS "FMOB_Student_Due", COALESCE("FMOB_Institution_Due", 0) AS "FMOB_Institution_Due"
            FROM (SELECT * FROM "Fee_Master_Opening_Balance" WHERE "MI_Id" = ' || "Mi_Id" || ' AND "asmay_id" = ' || "Amay_Id" || ' AND "FMH_Id" = ' || "fmhid" || ' AND "FMG_Id" = ' || "fmgid" || ' AND "FTI_Id" IN (' || "ftiid" || ')) "BAL"
            RIGHT OUTER JOIN (SELECT stu."AMST_Id" AS "ID", stu."AMST_FirstName", stu."AMST_MiddleName", stu."AMST_LastName" FROM "Adm_M_Student" stu, "Adm_School_Y_Student" ystu
            WHERE stu."AMST_Id" = ystu."AMST_Id" AND stu."MI_Id" = ' || "Mi_Id" || ' AND ystu."asmay_id" = ' || "Amay_Id" || '
            AND ystu."ASMCL_Id" = ' || "Asmcl_Id" || ' AND ystu."ASMS_Id" = ' || "Asms_Id" || ' AND stu."AMST_SOL" = ''S'' AND ystu."AMAY_ActiveFlag" = 1) student ON "BAL"."AMST_Id" = student."ID"';
        ELSIF "Status" = 'Left' THEN
            v_query := 'SELECT DISTINCT "ID", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", COALESCE("FMOB_Student_Due", 0) AS "FMOB_Student_Due", COALESCE("FMOB_Institution_Due", 0) AS "FMOB_Institution_Due"
            FROM (SELECT * FROM "Fee_Master_Opening_Balance" WHERE "MI_Id" = ' || "Mi_Id" || ' AND "asmay_id" = ' || "Amay_Id" || ' AND "FMH_Id" = ' || "fmhid" || ' AND "FMG_Id" = ' || "fmgid" || ' AND "FTI_Id" IN (' || "ftiid" || ')) "BAL"
            RIGHT OUTER JOIN (SELECT stu."AMST_Id" AS "ID", stu."AMST_FirstName", stu."AMST_MiddleName", stu."AMST_LastName" FROM "Adm_M_Student" stu, "Adm_School_Y_Student" ystu WHERE stu."AMST_Id" = ystu."AMST_Id"
            AND stu."MI_Id" = ' || "Mi_Id" || ' AND ystu."asmay_id" = ' || "Amay_Id" || '
            AND ystu."ASMCL_Id" = ' || "Asmcl_Id" || ' AND ystu."ASMS_Id" = ' || "Asms_Id" || ' AND stu."AMST_SOL" = ''L'' AND ystu."AMAY_ActiveFlag" = 0) student ON "BAL"."AMST_Id" = student."ID"';
        END IF;
    END IF;

    IF "Type" = 'Individual' THEN
        IF "Status" = 'Active' THEN
            v_query := 'SELECT DISTINCT "ID", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", COALESCE("FMOB_Student_Due", 0) AS "FMOB_Student_Due", COALESCE("FMOB_Institution_Due", 0) AS "FMOB_Institution_Due"
            FROM (SELECT * FROM "Fee_Master_Opening_Balance" WHERE "MI_Id" = ' || "Mi_Id" || ' AND "asmay_id" = ' || "Amay_Id" || ' AND "FMH_Id" = ' || "fmhid" || ' AND "FMG_Id" = ' || "fmgid" || ' AND "FTI_Id" IN (' || "ftiid" || ')) "BAL"
            RIGHT OUTER JOIN (SELECT stu."AMST_Id" AS "ID", stu."AMST_FirstName", stu."AMST_MiddleName", stu."AMST_LastName" FROM "Adm_M_Student" stu, "Adm_School_Y_Student" ystu WHERE stu."AMST_Id" = ystu."AMST_Id"
            AND stu."MI_Id" = ' || "Mi_Id" || ' AND ystu."ASMAY_Id" = ' || "Amay_Id" || '
            AND ystu."ASMCL_Id" = ' || "Asmcl_Id" || ' AND ystu."ASMS_Id" = ' || "Asms_Id" || ' AND stu."AMST_SOL" = ''S'' AND ystu."AMAY_ActiveFlag" = 1 AND STU."AMST_Id" = ' || "Amst_Id" || ') student ON "BAL"."AMST_Id" = student."ID"';
        ELSIF "Status" = 'Left' THEN
            v_query := 'SELECT DISTINCT "ID", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", COALESCE("FMOB_Student_Due", 0) AS "FMOB_Student_Due", COALESCE("FMOB_Institution_Due", 0) AS "FMOB_Institution_Due"
            FROM (SELECT * FROM "Fee_Master_Opening_Balance" WHERE "MI_Id" = ' || "Mi_Id" || ' AND "asmay_id" = ' || "Amay_Id" || ' AND "FMH_Id" = ' || "fmhid" || ' AND "FMG_Id" = ' || "fmgid" || ' AND "FTI_Id" IN (' || "ftiid" || ')) "BAL"
            RIGHT OUTER JOIN (SELECT stu."AMST_Id" AS "ID", stu."AMST_FirstName", stu."AMST_MiddleName", stu."AMST_LastName" FROM "Adm_M_Student" stu, "Adm_School_Y_Student" ystu WHERE stu."AMST_Id" = ystu."AMST_Id"
            AND stu."MI_Id" = ' || "Mi_Id" || ' AND ystu."ASMAY_Id" = ' || "Amay_Id" || '
            AND ystu."ASMCL_Id" = ' || "Asmcl_Id" || ' AND ystu."ASMS_Id" = ' || "Asms_Id" || ' AND stu."AMST_SOL" != ''L'' AND ystu."AMAY_ActiveFlag" = 0 AND STU."AMST_Id" = ' || "Amst_Id" || ') student ON "BAL"."AMST_Id" = student."ID"';
        END IF;
    END IF;

    IF "Type" = 'Category' THEN
        IF "Status" = 'Active' THEN
            v_query := 'SELECT DISTINCT "ID", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", COALESCE("FMOB_Student_Due", 0) AS "FMOB_Student_Due", COALESCE("FMOB_Institution_Due", 0) AS "FMOB_Institution_Due"
            FROM (SELECT * FROM "Fee_Master_Opening_Balance" WHERE "MI_Id" = ' || "Mi_Id" || ' AND "asmay_id" = ' || "Amay_Id" || ' AND "FMH_Id" = ' || "fmhid" || ' AND "FMG_Id" = ' || "fmgid" || ' AND "FTI_Id" IN (' || "ftiid" || ')) "BAL" RIGHT OUTER JOIN
            (SELECT e."AMST_Id" AS "ID", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName" FROM "Fee_Master_Class_Category" a INNER JOIN
            "Fee_Yearly_Class_Category" b ON a."FMCC_Id" = b."FMCC_Id" INNER JOIN
            "Fee_Yearly_Class_Category_Classes" c ON b."FYCC_Id" = c."FYCC_Id" INNER JOIN
            "Adm_School_Y_Student" d ON c."ASMCL_Id" = d."ASMCL_Id" INNER JOIN
            "Adm_M_Student" e ON d."AMST_Id" = e."AMST_Id"
            WHERE e."MI_Id" = ' || "Mi_Id" || ' AND d."asmay_id" = ' || "Amay_Id" || '
            AND b."FMCC_Id" = ' || "fmcC_Id" || ' AND e."AMST_SOL" = ''S'' AND d."AMAY_ActiveFlag" = 1) student ON "BAL"."AMST_Id" = student."ID"';
        ELSIF "Status" = 'Left' THEN
            v_query := 'SELECT DISTINCT "ID", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", COALESCE("FMOB_Student_Due", 0) AS "FMOB_Student_Due", COALESCE("FMOB_Institution_Due", 0) AS "FMOB_Institution_Due"
            FROM (SELECT * FROM "Fee_Master_Opening_Balance" WHERE "MI_Id" = ' || "Mi_Id" || ' AND "asmay_id" = ' || "Amay_Id" || ' AND "FMH_Id" = ' || "fmhid" || ' AND "FMG_Id" = ' || "fmgid" || ' AND "FTI_Id" IN (' || "ftiid" || ')) "BAL" RIGHT OUTER JOIN
            (SELECT e."AMST_Id" AS "ID", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName" FROM "Fee_Master_Class_Category" a INNER JOIN
            "Fee_Yearly_Class_Category" b ON a."FMCC_Id" = b."FMCC_Id" INNER JOIN
            "Fee_Yearly_Class_Category_Classes" c ON b."FYCC_Id" = c."FYCC_Id" INNER JOIN
            "Adm_School_Y_Student" d ON c."ASMCL_Id" = d."ASMCL_Id" INNER JOIN
            "Adm_M_Student" e ON d."AMST_Id" = e."AMST_Id"
            WHERE e."MI_Id" = ' || "Mi_Id" || ' AND d."asmay_id" = ' || "Amay_Id" || '
            AND b."FMCC_Id" = ' || "fmcC_Id" || ' AND e."AMST_SOL" = ''L'' AND d."AMAY_ActiveFlag" = 0) student ON "BAL"."AMST_Id" = student."ID"';
        END IF;
    END IF;

    RAISE NOTICE '%', v_query;
    
    RETURN QUERY EXECUTE v_query;
END;
$$;