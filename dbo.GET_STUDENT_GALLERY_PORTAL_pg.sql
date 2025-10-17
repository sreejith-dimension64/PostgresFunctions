CREATE OR REPLACE FUNCTION "dbo"."GET_STUDENT_GALLERY_PORTAL"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "IGA_Id" bigint,
    "IGA_GalleryName" varchar,
    "IGAP_Photos" text,
    "IGAP_Id" bigint,
    "IGAP_CoverPhotoFlag" boolean,
    "IGAV_Id" bigint,
    "IGAV_Videos" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        C."IGA_Id",
        C."IGA_GalleryName",
        E."IGAP_Photos",
        E."IGAP_Id",
        E."IGAP_CoverPhotoFlag",
        F."IGAV_Id",
        F."IGAV_Videos"
    FROM "Adm_M_Student" AS A
    INNER JOIN "Adm_School_Y_Student" AS B ON B."AMST_Id" = A."AMST_Id"
    INNER JOIN "IVRM_Gallery" AS C ON C."MI_Id" = A."MI_Id"
    INNER JOIN "IVRM_Gallery_Class" AS D ON D."IGA_Id" = C."IGA_Id" 
        AND D."ASMCL_Id" = B."ASMCL_Id" 
        AND D."ASMS_Id" = B."ASMS_Id"
    LEFT JOIN "IVRM_Gallery_Photos" AS E ON E."IGA_Id" = C."IGA_Id" 
        AND E."IGAP_ActiveFlag" = true
    LEFT JOIN "IVRM_Gallery_Videos" AS F ON F."IGA_Id" = C."IGA_Id" 
        AND F."IGAV_ActiveFlag" = true
    WHERE B."ASMAY_Id" = p_ASMAY_Id 
        AND B."AMST_Id" = p_AMST_Id 
        AND A."MI_Id" = p_MI_Id 
        AND C."IGA_ActiveFlag" = true;
END;
$$;