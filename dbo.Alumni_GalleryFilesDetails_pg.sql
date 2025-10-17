CREATE OR REPLACE FUNCTION "dbo"."Alumni_GalleryFilesDetails" (
    "MI_Id" BIGINT,
    "ALGA_Id" BIGINT
)
RETURNS TABLE (
    "ALGA_Id" BIGINT,
    "ALGA_GalleryName" VARCHAR,
    "ALGA_ActiveFlag" BOOLEAN,
    "ALGA_Date" DATE,
    "ALGA_Time" TIME,
    "ALGAP_Id" BIGINT,
    "ALGAP_Photos" TEXT,
    "ALGAV_Id" BIGINT,
    "ALGAV_Videos" TEXT
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
        a."ALGA_Time",
        b."ALGAP_Id", 
        b."ALGAP_Photos", 
        c."ALGAV_Id",
        c."ALGAV_Videos"
    FROM "ALU"."Alumni_Gallery" a 
    LEFT JOIN "ALU"."Alumni_Gallery_Photos" b ON b."ALGA_Id" = a."ALGA_Id"
    LEFT JOIN "ALU"."Alumni_Gallery_Videos" c ON c."ALGA_Id" = a."ALGA_Id"
    WHERE a."MI_Id" = "MI_Id" AND a."ALGA_Id" = "ALGA_Id" 
    ORDER BY a."ALGA_Id" DESC;
END;
$$;