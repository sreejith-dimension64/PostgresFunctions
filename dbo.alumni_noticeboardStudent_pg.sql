CREATE OR REPLACE FUNCTION "dbo"."alumni_noticeboardStudent"(p_Mi_Id bigint)
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
        a."ALNTB_Id", 
        a."ALNTB_Title", 
        a."ALNTB_Description", 
        a."ALNTB_StartDate", 
        a."ALNTB_EndDate", 
        a."ALNTB_ActiveFlag",
        (SELECT count(*) FROM "alu"."Alumni_NoticeBoard_Files" b WHERE b."ALNTB_Id" = a."ALNTB_Id") as "FileCount"
    FROM "ALU"."Alumni_NoticeBoard" a 
    WHERE a."MI_Id" = p_Mi_Id AND a."ALNTB_DisplayDate" IS NULL
    UNION 
    SELECT 
        a."ALNTB_Id", 
        a."ALNTB_Title", 
        a."ALNTB_Description", 
        a."ALNTB_StartDate", 
        a."ALNTB_EndDate", 
        a."ALNTB_ActiveFlag",
        (SELECT count(*) FROM "alu"."Alumni_NoticeBoard_Files" b WHERE b."ALNTB_Id" = a."ALNTB_Id") as "FileCount"
    FROM "ALU"."Alumni_NoticeBoard" a 
    WHERE a."MI_Id" = p_Mi_Id AND a."ALNTB_DisplayDate" <= CURRENT_TIMESTAMP;
END;
$$;