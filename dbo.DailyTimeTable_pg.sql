CREATE OR REPLACE FUNCTION "DailyTimeTable"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_TTMD_Id bigint,
    p_HRME_Id bigint
)
RETURNS TABLE(
    period varchar,
    asmcL_ClassName varchar,
    asmC_SectionName varchar,
    ttmdpT_StartTime time,
    ttmdpT_EndTime time
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."TTMP_PeriodName" as period,
        d."ASMCL_ClassName" as asmcL_ClassName,
        e."ASMC_SectionName" as asmC_SectionName,
        f."TTMDPT_StartTime" as ttmdpT_StartTime,
        f."TTMDPT_EndTime" as ttmdpT_EndTime
    FROM "TT_Final_Generation" a
    INNER JOIN "TT_Final_Generation_Detailed" b ON a."TTFG_Id" = b."TTFG_Id"
    INNER JOIN "TT_Master_Period" c ON b."TTMP_Id" = c."TTMP_Id"
    INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
    INNER JOIN "TT_Master_Day_Period_Time" f ON b."TTMD_Id" = f."TTMD_Id" 
        AND a."TTMC_Id" = f."TTMC_Id" 
        AND b."TTMP_Id" = f."TTMP_Id" 
        AND a."ASMAY_Id" = f."ASMAY_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND b."TTMD_Id" = p_TTMD_Id 
        AND b."HRME_Id" = p_HRME_Id
    ORDER BY period;
END;
$$;