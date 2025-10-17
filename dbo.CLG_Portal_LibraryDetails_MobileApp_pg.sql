CREATE OR REPLACE FUNCTION "dbo"."CLG_Portal_LibraryDetails_MobileApp"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCST_Id" BIGINT,
    "Flag" VARCHAR(50)
)
RETURNS TABLE (
    "AMCST_Id" BIGINT,
    "LMBANO_AccessionNo" TEXT,
    "LMB_BookTitle" TEXT,
    "LBTR_IssuedDate" TIMESTAMP,
    "LMBANO_Id" BIGINT,
    "LBTR_Status" TEXT,
    "LBTR_DueDate" TIMESTAMP,
    "LBTR_ReturnedDate" TIMESTAMP,
    "LBTR_TotalFine" NUMERIC,
    "LBTR_FineCollected" NUMERIC,
    "LBTR_FineWaived" NUMERIC,
    "LBTR_Renewalcounter" INTEGER,
    "LMB_BookImage" TEXT,
    "IVRM_Month_Id" INTEGER,
    "IVRM_Month_Name" TEXT,
    "Bookcount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "Flag" = 'Libarary' THEN
        RETURN QUERY
        SELECT DISTINCT c."AMCST_Id", e."LMBANO_AccessionNo", f."LMB_BookTitle", d."LBTR_IssuedDate", d."LMBANO_Id", d."LBTR_Status", d."LBTR_DueDate",
            d."LBTR_ReturnedDate", d."LBTR_TotalFine", d."LBTR_FineCollected", d."LBTR_FineWaived", d."LBTR_Renewalcounter", f."LMB_BookImage",
            NULL::INTEGER, NULL::TEXT, NULL::BIGINT
        FROM "CLG"."Adm_Master_College_Student" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" c ON b."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction" d ON c."LBTR_Id" = d."LBTR_Id"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" e ON e."LMBANO_Id" = d."LMBANO_Id"
        INNER JOIN "LIB"."LIB_Master_Book" f ON f."LMB_Id" = e."LMB_Id"
        WHERE d."MI_Id" = "MI_Id" AND b."ASMAY_Id" = "ASMAY_Id" AND b."AMCST_Id" = "AMCST_Id"
        ORDER BY d."LBTR_IssuedDate" DESC;

    ELSIF "Flag" = 'LGraph' THEN
        RETURN QUERY
        SELECT DISTINCT c."AMCST_Id", NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, NULL::BIGINT, d."LBTR_Status", NULL::TIMESTAMP,
            NULL::TIMESTAMP, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::INTEGER, NULL::TEXT,
            g."IVRM_Month_Id", g."IVRM_Month_Name", COUNT(f."LMB_Id")
        FROM "CLG"."Adm_Master_College_Student" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" c ON b."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction" d ON c."LBTR_Id" = d."LBTR_Id"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" e ON e."LMBANO_Id" = d."LMBANO_Id"
        INNER JOIN "LIB"."LIB_Master_Book" f ON f."LMB_Id" = e."LMB_Id"
        INNER JOIN "IVRM_Month" g ON g."IVRM_Month_Id" = EXTRACT(MONTH FROM d."LBTR_IssuedDate")
        WHERE d."MI_Id" = "MI_Id" AND b."ASMAY_Id" = "ASMAY_Id" AND b."AMCST_Id" = "AMCST_Id"
        GROUP BY c."AMCST_Id", g."IVRM_Month_Id", g."IVRM_Month_Name", d."LBTR_Status";

    ELSIF "Flag" = 'Reciept' THEN
        RETURN QUERY
        SELECT DISTINCT c."AMCST_Id", e."LMBANO_AccessionNo", f."LMB_BookTitle", d."LBTR_IssuedDate", d."LMBANO_Id", d."LBTR_Status", d."LBTR_DueDate",
            d."LBTR_ReturnedDate", d."LBTR_TotalFine", d."LBTR_FineCollected", d."LBTR_FineWaived", d."LBTR_Renewalcounter", f."LMB_BookImage",
            NULL::INTEGER, NULL::TEXT, NULL::BIGINT
        FROM "CLG"."Adm_Master_College_Student" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" c ON b."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction" d ON c."LBTR_Id" = d."LBTR_Id"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" e ON e."LMBANO_Id" = d."LMBANO_Id"
        INNER JOIN "LIB"."LIB_Master_Book" f ON f."LMB_Id" = e."LMB_Id"
        WHERE d."MI_Id" = "MI_Id" AND b."ASMAY_Id" = "ASMAY_Id" AND b."AMCST_Id" = "AMCST_Id"
        ORDER BY d."LBTR_IssuedDate" DESC;

    ELSIF "Flag" = 'FineReciept' THEN
        RETURN QUERY
        SELECT DISTINCT c."AMCST_Id", e."LMBANO_AccessionNo", f."LMB_BookTitle", d."LBTR_IssuedDate", d."LMBANO_Id", d."LBTR_Status", d."LBTR_DueDate",
            d."LBTR_ReturnedDate", d."LBTR_TotalFine", d."LBTR_FineCollected", d."LBTR_FineWaived", d."LBTR_Renewalcounter", f."LMB_BookImage",
            NULL::INTEGER, NULL::TEXT, NULL::BIGINT
        FROM "CLG"."Adm_Master_College_Student" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" c ON b."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "LIB"."LIB_Book_Transaction" d ON c."LBTR_Id" = d."LBTR_Id"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" e ON e."LMBANO_Id" = d."LMBANO_Id"
        INNER JOIN "LIB"."LIB_Master_Book" f ON f."LMB_Id" = e."LMB_Id"
        WHERE d."MI_Id" = "MI_Id" AND b."ASMAY_Id" = "ASMAY_Id" AND b."AMCST_Id" = "AMCST_Id" AND d."LBTR_Status" != 'Return'
        ORDER BY d."LBTR_IssuedDate" DESC;

    END IF;

    RETURN;

END;
$$;