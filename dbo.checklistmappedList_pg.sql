CREATE OR REPLACE FUNCTION checklistmappedList(
    p_HRMF_Id bigint,
    p_Mi_Id bigint,
    p_UserId bigint,
    p_ISMCLT_Id bigint
)
RETURNS TABLE(
    "ISMCLD_Id" bigint,
    "ISMCL_Name" VARCHAR,
    "HRMF_Id" bigint,
    "ISMCLD_Qty" numeric,
    "Apprvl_qty" numeric,
    "ISMCLT_Remarks" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."ISMCLD_Id", 
        b."ISMCL_Name", 
        b."HRMF_Id", 
        b."ISMCLD_Qty",
        (SELECT A."ISMCLT_Qty" 
         FROM "ISM_Checklist_Approval" A 
         WHERE A."ISMCLD_Id" = b."ISMCLD_Id" 
           AND A."ISMCLT_UserId" = p_UserId 
           AND DATE(A."ISMCLT_Date") = CURRENT_DATE) AS "Apprvl_qty",
        (SELECT A."ISMCLT_Remarks" 
         FROM "ISM_Checklist_Approval" A 
         WHERE A."ISMCLD_Id" = b."ISMCLD_Id" 
           AND A."ISMCLT_UserId" = p_UserId 
           AND DATE(A."ISMCLT_Date") = CURRENT_DATE) AS "ISMCLT_Remarks"
    FROM "ISM_Checklist_Details" b
    WHERE b."ISMCLT_Id" = p_ISMCLT_Id 
      AND b."HRMF_Id" = p_HRMF_Id 
      AND b."ISMCL_ActiveFlag" = 1;
END;
$$;