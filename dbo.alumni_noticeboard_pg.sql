CREATE OR REPLACE FUNCTION "dbo"."alumni_noticeboard"(
    "Mi_Id" bigint
)
RETURNS TABLE(
    "ALNTB_Id" bigint,
    "ALNTB_Title" text,
    "ALNTB_Description" text,
    "ALNTB_StartDate" timestamp,
    "ALNTB_EndDate" timestamp,
    "ALNTB_ActiveFlag" boolean,
    "FileCount" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "a"."ALNTB_Id", 
        "a"."ALNTB_Title", 
        "a"."ALNTB_Description", 
        "a"."ALNTB_StartDate", 
        "a"."ALNTB_EndDate", 
        "a"."ALNTB_ActiveFlag",
        (SELECT COUNT(*) FROM "alu"."Alumni_NoticeBoard_Files" "b" WHERE "b"."ALNTB_Id" = "a"."ALNTB_Id") AS "FileCount"
    FROM "ALU"."Alumni_NoticeBoard" "a" 
    WHERE "a"."MI_Id" = "Mi_Id" 
    ORDER BY "a"."ALNTB_Id" DESC;
END;
$$;