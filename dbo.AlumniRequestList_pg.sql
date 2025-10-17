CREATE OR REPLACE FUNCTION "dbo"."AlumniRequestList"(
    p_MI_Id bigint,
    p_ALMST_Id bigint,
    p_Type varchar(50)
)
RETURNS TABLE (
    studentname text,
    "ASMAY_Year" varchar,
    "ALMST_Id" bigint,
    "ALSFRND_RequestDate" timestamp,
    "ALSFRND_AcceptedDate" timestamp,
    "ALSFRND_AcceptFlag" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_Type = 'Request' THEN
        RETURN QUERY
        SELECT DISTINCT 
            (COALESCE("a"."ALMST_FirstName", '') || COALESCE("a"."ALMST_MiddleName", '') || COALESCE("a"."ALMST_LastName", ''))::text AS studentname,
            "c"."ASMAY_Year",
            "a"."ALMST_Id",
            "b"."ALSFRND_RequestDate",
            "b"."ALSFRND_AcceptedDate",
            "b"."ALSFRND_AcceptFlag"
        FROM "alu"."Alumni_Master_Student" "a"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id_Left"
        LEFT JOIN "ALU"."Alumni_Student_Friends" "b" ON "a"."ALMST_Id" = "b"."ALMST_Id"
        WHERE "b"."ALSFRND_FriendsId" = p_ALMST_Id 
          AND "c"."MI_Id" = p_MI_Id;
    END IF;
    
    RETURN;
END;
$$;