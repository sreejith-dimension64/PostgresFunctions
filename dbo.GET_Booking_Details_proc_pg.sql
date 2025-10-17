CREATE OR REPLACE FUNCTION "dbo"."GET_Booking_Details_proc"(
    "MI_Id" TEXT,
    "HRMR_Id" TEXT,
    "OSSPBOOK_Status" TEXT,
    "OSSPBOOK_DurationType" TEXT,
    "fromdate1" VARCHAR(10),
    "fromdate2" VARCHAR(10)
)
RETURNS TABLE(
    "HRMR_RoomName" TEXT,
    "OSSPBOOK_Status" TEXT,
    "OSSPBOOK_DurationType" TEXT,
    "OSSPBOOK_StartDate" TIMESTAMP,
    "OSSPBOOK_EndDate" TIMESTAMP,
    "OSSPBOOK_StartTime" TIME,
    "OSSPBOOK_EndTime" TIME,
    "HRMR_Capacity" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "CONTENT" TEXT;
    "CONTENT1" TEXT;
    "QUERY" TEXT;
BEGIN
    "CONTENT1" := 'WHERE A."MI_Id" = ' || "MI_Id" || '';
    
    IF "HRMR_Id" <> '0' THEN
        "CONTENT1" := "CONTENT1" || ' AND B."HRMR_Id" = ''' || "HRMR_Id" || '''';
    END IF;
    
    IF "OSSPBOOK_DurationType" <> '0' THEN
        "CONTENT1" := "CONTENT1" || ' AND B."OSSPBOOK_DurationType" = ''' || "OSSPBOOK_DurationType" || '''';
    END IF;
    
    IF "OSSPBOOK_Status" <> '0' THEN
        "CONTENT1" := "CONTENT1" || ' AND B."OSSPBOOK_Status" = ''' || "OSSPBOOK_Status" || '''';
    END IF;
    
    IF "fromdate1" <> '' AND "fromdate2" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND CAST(B."OSSPBOOK_EndDate" AS DATE) BETWEEN ''' || "fromdate1" || ''' AND ''' || "fromdate2" || '''';
    END IF;
    
    "QUERY" := 'SELECT DISTINCT A."HRMR_RoomName", B."OSSPBOOK_Status", B."OSSPBOOK_DurationType", B."OSSPBOOK_StartDate", B."OSSPBOOK_EndDate", B."OSSPBOOK_StartTime", B."OSSPBOOK_EndTime", A."HRMR_Capacity" FROM "HR_Master_Room" A INNER JOIN "OS_Space_Booking" B ON A."HRMR_Id" = B."HRMR_Id" ' || "CONTENT1";
    
    RETURN QUERY EXECUTE "QUERY";
    
END;
$$;