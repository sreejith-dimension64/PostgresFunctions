CREATE OR REPLACE FUNCTION "dbo"."Alumniusename"(
    p_MI_Id bigint,
    p_UserName varchar(50),
    p_PWD varchar(50),
    p_template text,
    p_StudentName varchar(50)
)
RETURNS TABLE (
    "USR" varchar(50),
    "PWD" varchar(50),
    "STUDENT_NAME" varchar,
    "AMOUNT" numeric
) 
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_template = 'AlumniUser' THEN
        RETURN QUERY
        SELECT 
            p_UserName as "USR",
            p_PWD as "PWD",
            p_StudentName as "STUDENT_NAME",
            NULL::numeric as "AMOUNT";
    END IF;

    IF p_template = 'AlumniDonation' THEN
        RETURN QUERY
        SELECT 
            NULL::varchar(50) as "USR",
            NULL::varchar(50) as "PWD",
            a."ALSREG_MemberName" as "STUDENT_NAME",
            b."ALDON_Amount" as "AMOUNT"
        FROM 
            "alu"."Alumni_Student_Registration" a,
            "alu"."Alumni_Donation" b
        WHERE 
            a."ALSREG_Id" = p_PWD
            AND a."MI_Id" = p_MI_Id
            AND a."ALSREG_Id" = b."ALSREG_Id"
            AND b."ALDON_ReceiptNo" = p_UserName
            AND b."ALDON_ReferenceNo" = p_StudentName;
    END IF;

    RETURN;
END;
$$;