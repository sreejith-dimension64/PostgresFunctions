CREATE OR REPLACE FUNCTION "dbo"."FEE_Group_STUDENTS_list_clg"(
    "p_MI_Id" VARCHAR(100),
    "p_AMCO_Id" TEXT,
    "p_ASMAY_Id" VARCHAR(100),
    "p_ASME_Id" TEXT,
    "p_fmg_id" TEXT,
    "p_flag" VARCHAR(10)
)
RETURNS TABLE(
    "amsT_Id" INTEGER,
    "studentname" TEXT,
    "AMST_AppDownloadedDeviceId" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_dynamicsql" TEXT;
BEGIN
    RETURN QUERY EXECUTE '';
END;
$$;