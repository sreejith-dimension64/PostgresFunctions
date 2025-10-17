CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_NoticeBoard_Details"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@AMCST_Id" BIGINT,
    "@AMCO_Id" BIGINT,
    "@AMB_Id" BIGINT,
    "@AMSE_Id" BIGINT
)
RETURNS TABLE(
    "INTB_Id" BIGINT,
    "INTB_Title" TEXT,
    "INTB_Description" TEXT,
    "INTB_Attachment" TEXT,
    "INTB_FilePath" TEXT,
    "INTB_DisplayDate" TIMESTAMP,
    "INTB_StartDate" TIMESTAMP,
    "INTB_EndDate" TIMESTAMP,
    "INTB_ActiveFlag" BOOLEAN,
    "NTB_TTSylabusFlg" BOOLEAN,
    "INTB_DispalyDisableFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT a."INTB_Id", a."INTB_Title", a."INTB_Description", a."INTB_Attachment", a."INTB_FilePath", a."INTB_DisplayDate",
a."INTB_StartDate", a."INTB_EndDate", a."INTB_ActiveFlag", a."NTB_TTSylabusFlg", a."INTB_DispalyDisableFlg"
FROM "IVRM_NoticeBoard" a
INNER JOIN "CLG"."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
INNER JOIN "CLG"."Adm_College_Yearly_Student" c ON b."AMCO_Id" = c."AMCO_Id" AND b."AMB_Id" = c."AMB_Id" AND b."AMSE_Id" = c."AMSE_Id"
INNER JOIN "Adm_School_M_Academic_Year" d ON c."ASMAY_Id" = d."ASMAY_Id"
WHERE a."MI_Id" = "@MI_Id" AND c."ASMAY_Id" = "@ASMAY_Id" AND a."INTB_ActiveFlag" = TRUE AND c."AMCST_Id" = "@AMCST_Id" AND b."AMCO_Id" = "@AMCO_Id" AND b."AMB_Id" = "@AMB_Id" AND b."AMSE_Id" = "@AMSE_Id"
ORDER BY a."INTB_StartDate" ASC;

END;
$$;