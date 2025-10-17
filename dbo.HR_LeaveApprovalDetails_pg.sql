CREATE OR REPLACE FUNCTION "dbo"."HR_LeaveApprovalDetails"(
    p_MI_Id bigint,
    p_Userid bigint
)
RETURNS TABLE (
    "HRELAP_Id" bigint,
    "MI_Id" bigint,
    "HRME_Id" bigint,
    "HRELAP_ApplicationDate" timestamp,
    "HRELAP_FromDate" timestamp,
    "HRELAP_ToDate" timestamp,
    "HRELAP_TotalDays" numeric,
    "HRELAP_LeaveReason" text,
    "HRELAP_ContactNoOnLeave" varchar,
    "HRELAP_ApplicationStatus" varchar,
    "HRELAP_SanctioningLevel" varchar,
    "HRELAP_FinalFlag" boolean,
    "HRELAP_ActiveFlag" boolean,
    "HRELAP_CreatedBy" bigint,
    "HRELAP_UpdatedBy" bigint,
    "HRELAP_CreatedDate" timestamp,
    "HRELAP_UpdatedDate" timestamp,
    "HRELT_Id" bigint,
    "HRELT_LeaveId" bigint,
    "HRELT_FromDate" timestamp,
    "HRELT_ToDate" timestamp,
    "HRELT_TotDays" numeric,
    "HRELT_LeaveDate" timestamp,
    "HRELT_Status" varchar,
    "HRELT_ActiveFlag" boolean,
    "HRELT_CreatedBy" bigint,
    "HRELT_UpdatedBy" bigint,
    "HRELT_CreatedDate" timestamp,
    "HRELT_UpdatedDate" timestamp,
    "HRME_EmployeeFirstName" varchar,
    "HRME_EmployeeMiddleName" varchar,
    "HRME_EmployeeLastName" varchar,
    "HRME_EmployeeCode" varchar,
    "HRME_BiometricCode" varchar,
    "HRME_RFCardId" varchar,
    "HRME_PerStreet" varchar,
    "HRME_PerArea" varchar,
    "HRME_PerCity" varchar,
    "HRME_PerStateId" bigint,
    "HRME_PerCountryId" bigint,
    "HRME_PerPincode" int,
    "HRME_LocStreet" varchar,
    "HRME_LocArea" varchar,
    "HRME_LocCity" varchar,
    "HRME_LocStateId" bigint,
    "HRME_LocCountryId" bigint,
    "HRME_LocPincode" int,
    "IVRMMMS_Id" bigint,
    "IVRMMG_Id" bigint,
    "CasteCategoryId" bigint,
    "HRME_FatherName" varchar,
    "HRME_MotherName" varchar,
    "HRME_SpouseName" varchar,
    "HRME_SpouseOccupation" varchar,
    "HRME_SpouseMobileNo" bigint,
    "HRME_SpouseEmailId" varchar,
    "HRME_SpouseAddress" varchar,
    "HRME_DOB" timestamp,
    "HRME_DOJ" timestamp,
    "HRME_ExpectedRetirementDate" timestamp,
    "HRME_PFDate" timestamp,
    "HRME_ESIDate" timestamp,
    "HRME_MobileNo" bigint,
    "HRME_EmailId" varchar,
    "HRME_BloodGroup" varchar,
    "HRME_PaymentType" varchar,
    "HRME_BankAccountNo" varchar,
    "HRME_PFApplicableFlag" boolean,
    "HRME_PFMaxFlag" boolean,
    "HRME_PFFixedFlag" boolean,
    "HRME_PFAccNo" varchar,
    "HRME_ESIAccNo" varchar,
    "HRME_GratuityAccNo" varchar,
    "HRME_ESIApplicableFlag" boolean,
    "HRME_Photo" varchar,
    "HRME_LeftFlag" boolean,
    "HRME_LeavingReason" varchar,
    "HRME_Height" numeric,
    "HRME_HeightUOM" varchar,
    "HRME_Weight" numeric,
    "HRME_WeightUOM" varchar,
    "HRME_IdentificationMark" varchar,
    "HRME_ApprovalNo" varchar,
    "HRME_PANCardNo" varchar,
    "HRME_AadharCardNo" varchar,
    "HRME_SubstituteFlag" boolean,
    "HRME_NationalSSN" varchar,
    "HRME_SalaryType" varchar,
    "HRME_EmployeeOrder" int,
    "HRME_ActiveFlag" boolean,
    "HRMDES_Id" bigint,
    "HRMG_Id" bigint,
    "HRMGT_Id" bigint,
    "HRMD_Id" bigint,
    "HRME_CreatedBy" bigint,
    "HRME_UpdatedBy" bigint,
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp,
    "HRML_Id" bigint,
    "HRML_LeaveName" varchar,
    "HRML_LeaveCode" varchar,
    "HRML_LeaveDetails" varchar,
    "HRML_LeaveCreditFlg" boolean,
    "HRML_LeaveType" varchar,
    "HRML_LeaveAbbr" varchar,
    "HRML_CreatedBy" bigint,
    "HRML_UpdatedBy" bigint,
    "HRML_ActiveFlag" boolean,
    "HRLA_Id" bigint,
    "HRLAON_Id" bigint,
    "HRLAON_SanctionLevelNo" int,
    "HRLAON_FinalFlg" boolean,
    "HRLAON_ActiveFlg" boolean,
    "Id" bigint,
    "Emp_Code" bigint,
    "IVRMSTAUL_UserName" varchar,
    "IVRMSTAUL_Password" varchar,
    "IVRMSTAUL_EmailId" varchar,
    "IVRMSTAUL_ActiveFlag" int,
    "IVRMSTAUL_CreatedBy" bigint,
    "IVRMSTAUL_UpdatedBy" bigint,
    "IVRMSTAUL_CreatedDate" timestamp,
    "IVRMSTAUL_UpdatedDate" timestamp,
    "HRELAP_ApplicationStatus_1" varchar
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "a".*,
        "a"."HRELAP_ApplicationStatus" AS "HRELAP_ApplicationStatus_1"
    FROM "HR_Emp_Leave_Application" AS "a"
    INNER JOIN "HR_Emp_Leave_Trans" AS "b" 
        ON "b"."HRELT_FromDate" = "a"."HRELAP_FromDate" 
        AND "b"."HRELT_ToDate" = "a"."HRELAP_ToDate"  
        AND "a"."MI_Id" = "b"."MI_Id" 
        AND "a"."HRME_Id" = "b"."HRME_Id"
    INNER JOIN "HR_Master_Employee" AS "c" 
        ON "c"."HRME_Id" = "a"."HRME_Id"
    INNER JOIN "HR_Master_Leave" AS "d" 
        ON "d"."HRML_Id" = "b"."HRELT_LeaveId"
    INNER JOIN "HR_Leave_Authorisation" AS "e" 
        ON "e"."HRMGT_Id" = "c"."HRMGT_Id" 
        AND "e"."HRMG_Id" = "c"."HRMG_Id" 
        AND "e"."HRML_Id" = "b"."HRELT_LeaveId"
    INNER JOIN "HR_Leave_Auth_OrderNo" AS "f" 
        ON "f"."HRLA_Id" = "e"."HRLA_Id"
    INNER JOIN "IVRM_Staff_User_Login" AS "g" 
        ON "g"."Emp_Code" = "f"."HRME_Id"
    WHERE 
        (("a"."HRELAP_ApplicationStatus" <> 'Approved') OR "a"."HRELAP_ApplicationStatus" IS NULL)
        AND (("a"."HRELAP_ApplicationStatus" <> 'Rejected') OR "a"."HRELAP_ApplicationStatus" IS NULL) 
        AND "c"."HRME_ActiveFlag" = true  
        AND "a"."HRELAP_ActiveFlag" = true 
        AND "b"."HRELT_ActiveFlag" = true
        AND "c"."MI_Id" = p_MI_Id 
        AND "d"."MI_Id" = p_MI_Id
        AND "g"."Id" = p_Userid  
        AND "a"."MI_Id" = p_MI_Id 
        AND "b"."MI_Id" = p_MI_Id;
END;
$$;