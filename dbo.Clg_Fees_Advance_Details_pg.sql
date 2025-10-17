CREATE OR REPLACE FUNCTION "dbo"."Clg_Fees_Advance_Details"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMCST_Id bigint,
    p_Type text
)
RETURNS TABLE(
    "AMCST_AdmNo" text,
    "StudentName" text,
    "AMB_BranchName" text,
    "AMSE_SEMName" text,
    "ACMS_SectionName" text,
    "AMCST_MobileNo" bigint,
    "AMCST_emailId" text,
    "AMCST_FatherName" text,
    "FTI_Name" text,
    "paid" numeric,
    "totalbalance" numeric,
    "FCMAS_DueDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EnableAdvnaceFeeFlg boolean;
    v_BtachwiseFeeGlg boolean;
    v_AMCST_AdmNo text;
    v_StudentName text;
    v_AMB_BranchName text;
    v_AMSE_SEMName text;
    v_ACMS_SectionName text;
    v_AMCST_MobileNo bigint;
    v_AMCST_emailId text;
    v_AMCST_FatherName text;
    v_FCMAS_DueDate timestamp;
    v_FTI_Name text;
    v_AMSE_Id bigint;
    v_AMSE_ID_N bigint;
    v_AMSE_SEMCode int;
    v_ASMAY_Id_N bigint;
    v_Rno int;
BEGIN

    SELECT DISTINCT COALESCE("FMC_EnableAdvnaceFeeFlg", false), COALESCE("FMC_BtachwiseFeeGlg", false)
    INTO v_EnableAdvnaceFeeFlg, v_BtachwiseFeeGlg
    FROM "Fee_Master_Configuration" 
    WHERE "MI_Id" = p_MI_Id;

    IF p_Type = 'All' THEN
        RETURN QUERY
        SELECT DISTINCT "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '') AS "StudentName",
            "AMB_BranchName",
            "AMSE_SEMName",
            "ACMS_SectionName",
            "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
            "AMCST_emailId",
            "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
            "FTI"."FTI_Name",
            SUM("FCSS_PaidAmount") AS paid,
            SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance,
            "FCMAS_DueDate"
        FROM "Fee_Master_Group" 
        INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
        INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id" 
            AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Student_Status"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id" 
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
        INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" "FCMAS" ON "FCMAS"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
        INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."FCMA_Id" = "FCMAS"."FCMA_Id" 
            AND "FCMA"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "FCMAS"."AMSE_Id"
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FCMA"."FTI_Id" 
        WHERE "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = p_ASMAY_Id 
            AND "CLG"."Fee_College_Student_Status"."MI_Id" = p_MI_Id 
            AND "CLG"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0 
            AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = p_AMCO_Id
            AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = p_AMB_Id
            AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
            AND "FCMA"."ASMAY_Id" = p_ASMAY_Id 
        GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", ''),
            "AMB_BranchName",
            "AMSE_SEMName",
            "ACMS_SectionName",
            "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
            "AMCST_emailId",
            "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
            "FTI"."FTI_Name",
            "FCMAS_DueDate";

    ELSIF p_Type = 'Ind' THEN
        RETURN QUERY
        SELECT DISTINCT "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '') AS "StudentName",
            "AMB_BranchName",
            "AMSE_SEMName",
            "ACMS_SectionName",
            "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
            "AMCST_emailId",
            "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
            "FTI"."FTI_Name",
            SUM("FCSS_PaidAmount") AS paid,
            SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance,
            "FCMAS_DueDate"
        FROM "Fee_Master_Group" 
        INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
        INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id" 
            AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Student_Status"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id" 
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
        INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" "FCMAS" ON "FCMAS"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
        INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."FCMA_Id" = "FCMAS"."FCMA_Id" 
            AND "FCMA"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "FCMAS"."AMSE_Id"
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FCMA"."FTI_Id" 
        WHERE "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = p_ASMAY_Id 
            AND "CLG"."Fee_College_Student_Status"."MI_Id" = p_MI_Id 
            AND "CLG"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0 
            AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = p_AMCO_Id
            AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = p_AMB_Id
            AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
            AND "FCMA"."ASMAY_Id" = p_ASMAY_Id 
            AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = p_AMCST_Id 
        GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
            COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", ''),
            "AMB_BranchName",
            "AMSE_SEMName",
            "ACMS_SectionName",
            "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
            "AMCST_emailId",
            "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
            "FTI"."FTI_Name",
            "FCMAS_DueDate";

    ELSIF p_Type = 'ind' AND v_EnableAdvnaceFeeFlg = true THEN

        IF v_BtachwiseFeeGlg = false THEN

            SELECT "AMSE_Id", "AMSE_SEMCode" 
            INTO v_AMSE_ID_N, v_AMSE_SEMCode
            FROM "CLG"."Adm_Master_Semester" 
            WHERE "MI_Id" = p_MI_Id 
                AND "AMSE_SEMOrder" = (
                    SELECT "AMSE_SEMOrder" + 1 
                    FROM "CLG"."Adm_Master_Semester" 
                    WHERE "MI_Id" = p_MI_Id AND "AMSE_Id" = p_AMCST_Id
                );

            v_Rno := v_AMSE_SEMCode;

            SELECT DISTINCT "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
                COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
                COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
                COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", ''),
                "AMB_BranchName",
                "AMSE"."AMSE_Id",
                "AMSE_SEMName",
                "ACMS_SectionName",
                "AMCST_MobileNo",
                "AMCST_emailId",
                "AMCST_FatherName",
                "FTI"."FTI_Name",
                "FCMAS_DueDate"
            INTO v_AMCST_AdmNo, v_StudentName, v_AMB_BranchName, v_AMSE_Id, v_AMSE_SEMName,
                v_ACMS_SectionName, v_AMCST_MobileNo, v_AMCST_emailId, v_AMCST_FatherName,
                v_FTI_Name, v_FCMAS_DueDate
            FROM "Fee_Master_Group" 
            INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
            INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
            INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
            INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id" 
            INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id" 
            INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
            INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" "FCMAS" ON "FCMAS"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
            INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."FCMA_Id" = "FCMAS"."FCMA_Id" 
                AND "FCMA"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "FCMAS"."AMSE_Id"
            INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FCMA"."FTI_Id" 
            INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FCMA"."FMH_Id" 
            WHERE "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = p_ASMAY_Id 
                AND "CLG"."Fee_College_Student_Status"."MI_Id" = p_MI_Id 
                AND "CLG"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0 
                AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = p_AMCO_Id
                AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = p_AMB_Id
                AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
                AND "FCMA"."ASMAY_Id" = p_ASMAY_Id 
                AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = p_AMCST_Id
            LIMIT 1;

            IF v_Rno % 2 = 0 THEN

                SELECT p_ASMAY_Id 
                INTO v_ASMAY_Id_N
                FROM "Adm_School_M_Academic_Year" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Order" = (
                        SELECT "ASMAY_Order" + 1 
                        FROM "Adm_School_M_Academic_Year" 
                        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id
                    );

                RETURN QUERY
                SELECT DISTINCT "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '') AS "StudentName",
                    "AMB_BranchName",
                    "AMSE_SEMName",
                    "ACMS_SectionName",
                    "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
                    "AMCST_emailId",
                    "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
                    "FTI"."FTI_Name",
                    SUM("FCSS_PaidAmount") AS paid,
                    SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance,
                    "FCMAS_DueDate"
                FROM "Fee_Master_Group" 
                INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
                INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id" 
                INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id" 
                INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
                INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" "FCMAS" ON "FCMAS"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
                INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."FCMA_Id" = "FCMAS"."FCMA_Id" 
                    AND "FCMA"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id"
                INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "FCMAS"."AMSE_Id"
                INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FCMA"."FTI_Id" 
                INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FCMA"."FMH_Id" 
                WHERE "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = p_ASMAY_Id 
                    AND "CLG"."Fee_College_Student_Status"."MI_Id" = p_MI_Id 
                    AND "CLG"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0 
                    AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = p_AMCO_Id
                    AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = p_AMB_Id
                    AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
                    AND "FCMA"."ASMAY_Id" = p_ASMAY_Id 
                    AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = p_AMCST_Id 
                GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", ''),
                    "AMB_BranchName",
                    "AMSE_SEMName",
                    "ACMS_SectionName",
                    "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
                    "AMCST_emailId",
                    "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
                    "FTI"."FTI_Name",
                    "FCMAS_DueDate"

                UNION ALL

                SELECT DISTINCT v_AMCST_AdmNo,
                    v_StudentName,
                    v_AMB_BranchName,
                    v_AMSE_SEMName,
                    v_ACMS_SectionName,
                    v_AMCST_MobileNo,
                    v_AMCST_emailId,
                    v_AMCST_FatherName,
                    "FTI"."FTI_Name",
                    0::numeric AS paid,
                    SUM("FCMAS_Amount") AS totalbalance,
                    "FCMAS"."FCMAS_DueDate"
                FROM "CLG"."Fee_College_Master_Amount" "FCMA"
                INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" "FCMAS" ON "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id"
                INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FCMA"."FMH_Id"
                INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FCMA"."FTI_Id"
                WHERE "FCMA"."MI_Id" = p_MI_Id 
                    AND "FCMA"."FCMA_ActiveFlg" = true 
                    AND "FCMA"."ASMAY_Id" = v_ASMAY_Id_N 
                    AND "FCMAS"."AMSE_Id" = v_AMSE_Id 
                    AND "FCMAS_ActiveFlg" = true
                GROUP BY "FTI"."FTI_Name", "FCMAS"."FCMAS_DueDate";

            ELSE

                RETURN QUERY
                SELECT DISTINCT "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '') || ' ' || 
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '') || ' ' || 
                    COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '') AS "StudentName",
                    "AMB_BranchName",
                    "AMSE_SEMName",
                    "ACMS_SectionName",
                    "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
                    "AMCST_emailId",
                    "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
                    "FTI"."FTI_Name",
                    SUM("FCSS_PaidAmount") AS paid,
                    SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance,
                    "FCMAS_DueDate"
                FROM "Fee_Master_Group" 
                INNER JOIN "CLG"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" 
                INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id" 
                INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id" 
                INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
                INNER JOIN "CLG"."Fee_College_Master_Amount_SemesterWise" "FCMAS" ON "FCMAS"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
                INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."FCMA_Id" = "FCMAS"."FCMA_Id" 
                    AND "FCMA"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id"
                INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "FCMAS"."AMSE_Id"
                INNER JOIN "Fee_T_Installment" "FTI" ON "F