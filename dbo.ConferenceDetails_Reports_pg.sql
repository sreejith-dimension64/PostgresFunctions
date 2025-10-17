CREATE OR REPLACE FUNCTION "dbo"."ConferenceDetails_Reports"(
    "p_MI_Id" bigint,
    "p_PRMTY_Id" text,
    "p_HRMD_Id" text,
    "p_PRMTLE_Id" text,
    "p_PRYR_StartDate" varchar(10),
    "p_PRYR_EndDate" varchar(10)
)
RETURNS TABLE(
    "ASMAY_Year" varchar,
    "PRYR_ProgramName" varchar,
    "PRMTY_ProgramType" varchar,
    "PRMTLE_ProgramLevel" varchar,
    "HRMD_DepartmentName" varchar,
    "PRYR_TotalParticipants" integer,
    "PRYR_Faculty" integer,
    "PRYR_IntParticipants" integer,
    "PRYR_ResearchScholars" integer,
    "PRYR_OurCollStudents" integer,
    "PRYR_NatParticipants" integer,
    "PRYR_LecturesNo" integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
BEGIN
    v_sqldynamic := '
    SELECT c."ASMAY_Year", a."PRYR_ProgramName", e."PRMTY_ProgramType", d."PRMTLE_ProgramLevel", f."HRMD_DepartmentName",
    a."PRYR_TotalParticipants", a."PRYR_Faculty", a."PRYR_IntParticipants", a."PRYR_ResearchScholars",
    a."PRYR_OurCollStudents", a."PRYR_NatParticipants", a."PRYR_LecturesNo"
    FROM "Programs_Yearly" a 
    JOIN "Programs_Yearly_Activities" b ON a."PRYR_Id" = b."PRYR_Id"
    JOIN "Adm_School_M_Academic_Year" c ON c."asmay_id" = a."asmay_id"
    JOIN "Programs_Master_Level" d ON d."mi_id" = a."mi_id"
    JOIN "Programs_Master_Type" e ON e."mi_id" = d."mi_id"
    JOIN "HR_Master_Department" f ON f."mi_id" = e."mi_id"
    WHERE a."MI_Id" = ' || "p_MI_Id"::text || ' 
    AND a."PRYR_IntParticipants" IS NOT NULL 
    AND e."PRMTY_Id" IN (' || "p_PRMTY_Id" || ') 
    AND f."HRMD_Id" = a."HRMD_Id" 
    AND f."HRMD_Id" IN (' || "p_HRMD_Id" || ') 
    AND d."PRMTLE_Id" IN (' || "p_PRMTLE_Id" || ') 
    AND a."PRYR_PrgramLevel" = d."PRMTLE_Id" 
    AND a."PRYR_ProgramInvitation" IS NULL 
    AND a."PRYR_ProgramTypeId" = e."PRMTY_Id"
    AND a."PRYR_StartDate" >= TO_DATE(''' || "p_PRYR_StartDate" || ''', ''DD/MM/YYYY'') 
    AND a."PRYR_EndDate" <= TO_DATE(''' || "p_PRYR_EndDate" || ''', ''DD/MM/YYYY'')';

    RETURN QUERY EXECUTE v_sqldynamic;
END;
$$;