CREATE OR REPLACE FUNCTION "dbo"."AddVisitor_Grid"(
    "mi_id" BIGINT
)
RETURNS TABLE(
    "vmmV_Id" BIGINT,
    "vmmV_VisitorName" TEXT,
    "vmmV_CardNo" TEXT,
    "vmmV_CkeckedInOutStatus" TEXT,
    "empname" TEXT,
    "vmmV_IdentityCardType" TEXT,
    "vmmV_FromAddress" TEXT,
    "vmmV_FromPlace" TEXT,
    "vmmV_MeetingDateTime" TIMESTAMP,
    "vmmV_MeetingLocation" TEXT,
    "vmmV_MeetingPurpose" TEXT,
    "vmmV_Remarks" TEXT,
    "vmmV_VisitorContactNo" TEXT,
    "vmmV_VisitorEmailid" TEXT,
    "vmmV_MeetingDuration" TEXT,
    "createddate" TIMESTAMP,
    "vmmV_BlocekFlg" TEXT,
    "count_subvisitors" BIGINT,
    "count_documents" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        SELECT DISTINCT 
            a."VMMV_Id" as "vmmV_Id",
            a."VMMV_VisitorName" as "vmmV_VisitorName",
            a."VMMV_CardNo" as "vmmV_CardNo",
            a."VMMV_CkeckedInOutStatus" as "vmmV_CkeckedInOutStatus",
            (COALESCE(e."HRME_EmployeeFirstName", '') || ' ' || COALESCE(e."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(e."HRME_EmployeeLastName", '')) as "empname",
            a."VMMV_IdentityCardType" as "vmmV_IdentityCardType",
            a."VMMV_FromAddress" as "vmmV_FromAddress",
            a."VMMV_FromPlace" as "vmmV_FromPlace",
            a."VMMV_MeetingDateTime" as "vmmV_MeetingDateTime",
            a."VMMV_MeetingLocation" as "vmmV_MeetingLocation",
            a."VMMV_MeetingPurpose" as "vmmV_MeetingPurpose",
            a."VMMV_Remarks" as "vmmV_Remarks",
            a."VMMV_VisitorContactNo" as "vmmV_VisitorContactNo",
            a."VMMV_VisitorEmailid" as "vmmV_VisitorEmailid",
            a."VMMV_MeetingDuration" as "vmmV_MeetingDuration",
            a."CreatedDate" as "createddate",
            a."VMMV_BlocekFlg" as "vmmV_BlocekFlg",
            (SELECT count(*) FROM "vm"."Visitor_Management_Visitor_Visitors" b WHERE b."VMMV_Id" = a."VMMV_Id") as "count_subvisitors",
            (SELECT count(*) FROM "vm"."VM_Master_Visitor_File" C WHERE C."VMMV_Id" = a."VMMV_Id") as "count_documents"
        FROM "vm"."Visitor_Management_MasterVisitor" a
        INNER JOIN "HR_Master_Employee" e ON a."VMMV_ToMeet" = e."HRME_Id"
        WHERE a."MI_Id" = "mi_id"
        
        UNION ALL
        
        SELECT DISTINCT 
            a."VMMV_Id" as "vmmV_Id",
            a."VMMV_VisitorName" as "vmmV_VisitorName",
            a."VMMV_CardNo" as "vmmV_CardNo",
            a."VMMV_CkeckedInOutStatus" as "vmmV_CkeckedInOutStatus",
            a."VMMV_PersonToMeet" as "empname",
            a."VMMV_IdentityCardType" as "vmmV_IdentityCardType",
            a."VMMV_FromAddress" as "vmmV_FromAddress",
            a."VMMV_FromPlace" as "vmmV_FromPlace",
            a."VMMV_MeetingDateTime" as "vmmV_MeetingDateTime",
            a."VMMV_MeetingLocation" as "vmmV_MeetingLocation",
            a."VMMV_MeetingPurpose" as "vmmV_MeetingPurpose",
            a."VMMV_Remarks" as "vmmV_Remarks",
            a."VMMV_VisitorContactNo" as "vmmV_VisitorContactNo",
            a."VMMV_VisitorEmailid" as "vmmV_VisitorEmailid",
            a."VMMV_MeetingDuration" as "vmmV_MeetingDuration",
            a."CreatedDate" as "createddate",
            a."VMMV_BlocekFlg" as "vmmV_BlocekFlg",
            (SELECT count(*) FROM "vm"."Visitor_Management_Visitor_Visitors" b WHERE b."VMMV_Id" = a."VMMV_Id") as "count_subvisitors",
            (SELECT count(*) FROM "vm"."VM_Master_Visitor_File" C WHERE C."VMMV_Id" = a."VMMV_Id") as "count_documents"
        FROM "vm"."Visitor_Management_MasterVisitor" a 
        WHERE a."VMMV_PersonToMeet" != ''
        AND a."MI_Id" = "mi_id"
    ) d
    ORDER BY d."vmmV_Id";
    
    RETURN;
END;
$$;