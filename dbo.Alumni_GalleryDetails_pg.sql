CREATE OR REPLACE FUNCTION "dbo"."Alumni_GalleryDetails"(
    "MI_Id" BIGINT,
    "IVRMRT_Id" BIGINT
)
RETURNS TABLE (
    "ALGA_Id" BIGINT,
    "ALGA_GalleryName" VARCHAR,
    "ALGA_ActiveFlag" BOOLEAN,
    "ALGA_Date" DATE,
    "ALGA_Time" TIME
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ALGA_Id", 
        a."ALGA_GalleryName", 
        a."ALGA_ActiveFlag", 
        a."ALGA_Date", 
        a."ALGA_Time"
    FROM "ALU"."Alumni_Gallery" a 
    LEFT JOIN "ALU"."Alumni_Gallery_Photos" b ON b."ALGA_Id" = a."ALGA_Id"
    LEFT JOIN "ALU"."Alumni_Gallery_Videos" c ON c."ALGA_Id" = c."ALGA_Id"
    WHERE a."MI_Id" = "MI_Id"
    ORDER BY a."ALGA_Id" DESC;
END;
$$;