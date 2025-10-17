CREATE OR REPLACE FUNCTION "dbo"."Alumni_Aniversary_Proc"(
    "@MI_Id" bigint,
    "@UserID" bigint,
    "@template" text,
    "@type" varchar(50)
)
RETURNS TABLE(
    "[NAME]" varchar,
    "[Address1]" varchar,
    "[Address2]" varchar,
    "[Address3]" varchar,
    "[Address4]" varchar,
    "[PINCODE]" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "MI_Name" AS "[NAME]",
        "MI_Address1" AS "[Address1]",
        "MI_Address2" AS "[Address2]",
        "MI_Address3" AS "[Address3]",
        "IVRMMCT_Name" AS "[Address4]",
        "MI_Pincode" AS "[PINCODE]"
    FROM "Master_Institution"
    WHERE "MI_Id" = "@MI_Id";
END;
$$;