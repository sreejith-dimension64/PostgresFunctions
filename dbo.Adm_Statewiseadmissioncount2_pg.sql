CREATE OR REPLACE FUNCTION "dbo"."Adm_Statewiseadmissioncount2"(
    "MI_ID" TEXT,
    "ASMAY_ID" TEXT,
    "IVRMMS_ID" TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "IVRMMS_Name" VARCHAR,
    "StudentCount" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "sqldynamic" TEXT;
BEGIN
    
    "sqldynamic" := 'SELECT ASMAY."ASMAY_Year", IMS."IVRMMS_Name", Count(DISTINCT ASYS."AMST_Id") AS "StudentCount"  
    FROM "dbo"."Adm_M_Student" AMS 
    INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id"     
    INNER JOIN "Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = ASYS."ASMAY_Id" AND ASMAY."MI_Id" = AMS."MI_Id"
    INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = ASYS."ASMCL_Id" AND ASMC."MI_Id" = ASMAY."MI_Id"   
    INNER JOIN "IVRM_Master_State" IMS ON IMS."IVRMMS_Id" = AMS."AMST_State"   
    WHERE ASYS."ASMAY_ID" IN (' || "ASMAY_ID" || ') AND AMS."MI_Id" = ' || "MI_ID" || ' AND AMS."AMST_State" IN (' || "IVRMMS_ID" || ')  
    GROUP BY ASMAY."ASMAY_Year", IMS."IVRMMS_Name"  
    ORDER BY ASMAY."ASMAY_Year"';
    
    RETURN QUERY EXECUTE "sqldynamic";
    
END;
$$;