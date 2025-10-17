CREATE OR REPLACE FUNCTION "dbo"."CLG_Portal_LibraryDetails" (
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCST_Id" BIGINT
)
RETURNS TABLE (
    "AMCST_Id" BIGINT,
    "LMBANO_AccessionNo" VARCHAR,
    "LMB_BookTitle" VARCHAR,
    "LMB_BookSubTitle" VARCHAR,
    "LBTR_IssuedDate" TIMESTAMP,
    "LMBANO_Id" BIGINT,
    "LBTR_Status" VARCHAR,
    "LBTR_DueDate" TIMESTAMP,
    "LBTR_ReturnedDate" TIMESTAMP,
    "LBTR_RenewedDate" TIMESTAMP,
    "LBTR_TotalFine" NUMERIC,
    "LBTR_FineCollected" NUMERIC,
    "LBTR_FineWaived" NUMERIC,
    "LBTR_Renewalcounter" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT c."AMCST_Id",
        e."LMBANO_AccessionNo",
        f."LMB_BookTitle",
        f."LMB_BookSubTitle",
        d."LBTR_IssuedDate",
        d."LMBANO_Id",
        d."LBTR_Status",
        d."LBTR_DueDate",
        d."LBTR_ReturnedDate",
        d."LBTR_RenewedDate",
        d."LBTR_TotalFine",
        d."LBTR_FineCollected",
        d."LBTR_FineWaived",
        d."LBTR_Renewalcounter"
    FROM "CLG"."Adm_Master_College_Student" a 
    INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
    INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" c ON b."AMCST_Id" = c."AMCST_Id"
    INNER JOIN "LIB"."LIB_Book_Transaction" d ON c."LBTR_Id" = d."LBTR_Id"
    INNER JOIN "LIB"."LIB_Master_Book_AccnNo" e ON e."LMBANO_Id" = d."LMBANO_Id"
    INNER JOIN "LIB"."LIB_Master_Book" f ON f."LMB_Id" = e."LMB_Id"
    WHERE d."MI_Id" = "MI_Id" 
        AND b."ASMAY_Id" = "ASMAY_Id" 
        AND b."AMCST_Id" = "AMCST_Id"
    ORDER BY d."LBTR_IssuedDate" DESC;
END;
$$;