CREATE OR REPLACE FUNCTION "dbo"."FMS_Correspondance_RefernceNo_Details_Report"(
    p_MI_Id TEXT,
    p_FMSCOR_Id TEXT,
    p_FLAG TEXT
)
RETURNS TABLE(
    "FMSMFCBT_FileCabinetName" VARCHAR,
    "FMSMFCR_CabinetRowName" VARCHAR,
    "FMSMFCC_CabinetColumnName" VARCHAR,
    "FMSMPFN_PhysicalFileName" VARCHAR,
    "FMSCOR_Id" BIGINT,
    "FMSCOR_RefernceNo" VARCHAR,
    "FMSCORFL_SoftCopyFileName" VARCHAR,
    "FMSCORFL_SoftCopyFilePath" VARCHAR,
    "FMSCORMD_SentDate" TIMESTAMP,
    "FMSCORMD_ReferenceNo" VARCHAR,
    "FMSCORMD_FileName" VARCHAR,
    "FMSCORMD_FilePath" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT 
            C."FMSMFCBT_FileCabinetName",
            E."FMSMFCR_CabinetRowName",
            D."FMSMFCC_CabinetColumnName",
            F."FMSMPFN_PhysicalFileName",
            A."FMSCOR_Id",
            A."FMSCOR_RefernceNo",
            NULL::VARCHAR AS "FMSCORFL_SoftCopyFileName",
            NULL::VARCHAR AS "FMSCORFL_SoftCopyFilePath",
            NULL::TIMESTAMP AS "FMSCORMD_SentDate",
            NULL::VARCHAR AS "FMSCORMD_ReferenceNo",
            NULL::VARCHAR AS "FMSCORMD_FileName",
            NULL::VARCHAR AS "FMSCORMD_FilePath"
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_Files" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "FMS_Master_FileCabinet" C ON C."FMSMFCBT_Id" = B."FMSMFCBT_Id"
        INNER JOIN "FMS_Master_FileCabinet_Column" D ON D."FMSMFCC_Id" = B."FMSMFCC_Id"
        INNER JOIN "FMS_Master_FileCabinet_Row" E ON E."FMSMFCR_Id" = B."FMSMFCR_Id"
        INNER JOIN "FMS_Master_PhysicalFileName" F ON F."FMSMPFN_Id" = B."FMSMPFN_Id"
        WHERE A."FMSCOR_Id" = p_FMSCOR_Id::BIGINT 
        AND B."FMSCOR_Id" = p_FMSCOR_Id::BIGINT 
        AND A."MI_Id" = p_MI_Id::BIGINT
        AND B."FMSCORFL_ActiveFlg" = TRUE;
        
    ELSIF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT 
            NULL::VARCHAR AS "FMSMFCBT_FileCabinetName",
            NULL::VARCHAR AS "FMSMFCR_CabinetRowName",
            NULL::VARCHAR AS "FMSMFCC_CabinetColumnName",
            NULL::VARCHAR AS "FMSMPFN_PhysicalFileName",
            A."FMSCOR_Id",
            A."FMSCOR_RefernceNo",
            B."FMSCORFL_SoftCopyFileName",
            B."FMSCORFL_SoftCopyFilePath",
            NULL::TIMESTAMP AS "FMSCORMD_SentDate",
            NULL::VARCHAR AS "FMSCORMD_ReferenceNo",
            NULL::VARCHAR AS "FMSCORMD_FileName",
            NULL::VARCHAR AS "FMSCORMD_FilePath"
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_Files_SoftCopy" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        WHERE A."FMSCOR_Id" = p_FMSCOR_Id::BIGINT 
        AND B."FMSCOR_Id" = p_FMSCOR_Id::BIGINT 
        AND A."MI_Id" = p_MI_Id::BIGINT
        AND B."FMSCORFLSC_ActiveFlg" = TRUE;
        
    ELSIF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT 
            NULL::VARCHAR AS "FMSMFCBT_FileCabinetName",
            NULL::VARCHAR AS "FMSMFCR_CabinetRowName",
            NULL::VARCHAR AS "FMSMFCC_CabinetColumnName",
            NULL::VARCHAR AS "FMSMPFN_PhysicalFileName",
            A."FMSCOR_Id",
            A."FMSCOR_RefernceNo",
            NULL::VARCHAR AS "FMSCORFL_SoftCopyFileName",
            NULL::VARCHAR AS "FMSCORFL_SoftCopyFilePath",
            B."FMSCORMD_SentDate",
            B."FMSCORMD_ReferenceNo",
            B."FMSCORMD_FileName",
            B."FMSCORMD_FilePath"
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_Mode" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "FMS_Master_DispatchMode" C ON C."FMSMDMD_Id" = B."FMSMDMD_Id"
        WHERE A."FMSCOR_Id" = p_FMSCOR_Id::BIGINT 
        AND B."FMSCOR_Id" = p_FMSCOR_Id::BIGINT 
        AND A."MI_Id" = p_MI_Id::BIGINT
        AND B."FMSCORMD_ActiveFlg" = TRUE;
        
    END IF;
    
    RETURN;
END;
$$;