CREATE OR REPLACE FUNCTION "dbo"."AlumniStudentRequestsearch"(
    "p_Where" TEXT,
    "p_MI_Id" TEXT,
    "p_Type" VARCHAR(50),
    "p_ALMST_Id" BIGINT
)
RETURNS TABLE(
    "studentname" TEXT,
    "ALMST_Id" BIGINT,
    "ASMAY_Year" VARCHAR,
    "ALSFRND_RequestDate" TIMESTAMP,
    "ALSFRND_AcceptedDate" TIMESTAMP,
    "ALSFRND_AcceptFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql" TEXT;
BEGIN
    IF "p_Type" = 'Search' THEN
        "v_sql" := '
        SELECT DISTINCT (COALESCE("ALMST_FirstName", '''')||COALESCE("ALMST_MiddleName",'''')||COALESCE("ALMST_LastName",'''')) as studentname,
        "a"."ALMST_Id", "e"."ASMAY_Year", "f"."ALSFRND_RequestDate", "f"."ALSFRND_AcceptedDate", "f"."ALSFRND_AcceptFlag"
        FROM "ALU"."Alumni_Master_Student" "a"
        INNER JOIN "Adm_School_M_Academic_Year" "e" ON "e"."ASMAY_Id" = "a"."ASMAY_Id_Left"
        LEFT JOIN "ALU"."Alumni_Student_Friends" "f" ON "f"."ALSFRND_FriendsId" = "a"."ALMST_Id" AND "f"."ALMST_Id" = ' || "p_ALMST_Id"::TEXT || '
        WHERE "a"."MI_Id" = ' || "p_MI_Id" || ' AND ' || "p_Where" || ' AND "a"."ALMST_Id" <> ' || "p_ALMST_Id"::TEXT || ' 
        AND "a"."ALMST_Id" NOT IN (SELECT "ALSFRNDREQ_FriendsReqId" FROM "ALU"."Alumni_Student_FriendRequest" 
        WHERE "ALMST_Id" = ' || "p_ALMST_Id"::TEXT || ' AND "ALSFRNDREQ_AcceptFlg" = TRUE)';
        
        RETURN QUERY EXECUTE "v_sql";
        
    ELSIF "p_Type" = 'All' THEN
        RETURN QUERY
        SELECT DISTINCT (COALESCE("a"."ALMST_FirstName", '')||COALESCE("a"."ALMST_MiddleName",'')||COALESCE("a"."ALMST_LastName",'')) as studentname,
        "a"."ALMST_Id", "e"."ASMAY_Year", "f"."ALSFRND_RequestDate", "f"."ALSFRND_AcceptedDate", "f"."ALSFRND_AcceptFlag"
        FROM "ALU"."Alumni_Master_Student" "a"
        INNER JOIN "Adm_School_M_Academic_Year" "e" ON "e"."ASMAY_Id" = "a"."ASMAY_Id_Left"
        LEFT JOIN "ALU"."Alumni_Student_Friends" "f" ON "f"."ALSFRND_FriendsId" = "a"."ALMST_Id" AND "f"."ALMST_Id" = "p_ALMST_Id"
        WHERE "a"."MI_Id" = "p_MI_Id"::BIGINT AND "a"."ALMST_Id" <> "p_ALMST_Id" 
        AND "a"."ALMST_Id" NOT IN (SELECT "ALSFRNDREQ_FriendsReqId" FROM "ALU"."Alumni_Student_FriendRequest" 
        WHERE "ALMST_Id" = "p_ALMST_Id" AND "ALSFRNDREQ_AcceptFlg" = TRUE)
        ORDER BY "f"."ALSFRND_RequestDate" DESC;
    END IF;
    
    RETURN;
END;
$$;