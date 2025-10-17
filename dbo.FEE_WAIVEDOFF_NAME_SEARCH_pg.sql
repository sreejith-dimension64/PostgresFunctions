CREATE OR REPLACE FUNCTION "dbo"."FEE_WAIVEDOFF_NAME_SEARCH"(
    "@Mi_Id" bigint,
    "@searchtext" text,
    "@ASMAY_ID" bigint,
    "@USERID" bigint
)
RETURNS TABLE(
    "FSWO_Id" bigint,
    "FMH_FeeName" text,
    "FTI_Name" text,
    "FSWO_WaivedOffAmount" numeric,
    "FSWO_Date" timestamp,
    "AMST_Id" bigint,
    "AMST_FirstName" text,
    "AMST_MiddleName" text,
    "AMST_LastName" text,
    "AMST_AdmNo" text,
    "AMST_RegistrationNo" text,
    "AMST_MobileNo" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        A."FSWO_Id",
        B."FMH_FeeName",
        C."FTI_Name",
        A."FSWO_WaivedOffAmount",
        A."FSWO_Date",
        A."AMST_Id",
        D."AMST_FirstName",
        D."AMST_MiddleName",
        D."AMST_LastName",
        D."AMST_AdmNo",
        D."AMST_RegistrationNo",
        D."AMST_MobileNo"
    FROM "Fee_Student_Waived_Off" AS A
    INNER JOIN "Fee_Master_Head" AS B ON B."FMH_Id" = A."FMH_Id" AND A."MI_Id" = B."MI_Id"
    INNER JOIN "Adm_M_Student" AS D ON D."AMST_Id" = A."AMST_Id"
    INNER JOIN "Fee_T_Installment" AS C ON C."FTI_Id" = A."FTI_Id"
    WHERE A."MI_Id" = "@Mi_Id" 
        AND C."MI_Id" = "@Mi_Id" 
        AND B."User_Id" = "@USERID"
        AND (
            D."AMST_FirstName" LIKE '%' || "@searchtext" || '%' 
            OR D."AMST_MiddleName" LIKE '%' || "@searchtext" || '%' 
            OR D."AMST_LastName" LIKE '%' || "@searchtext" || '%'
        )
    ORDER BY D."AMST_FirstName";
END;
$$;