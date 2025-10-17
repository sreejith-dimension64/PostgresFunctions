CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMappingnew_others_College"(
    p_MI_Id bigint,
    p_FMCOST_Id bigint,
    p_ASMAY_Id bigint,
    p_FMG_Id bigint,
    p_FMH_Id bigint,
    p_FTI_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Rcount bigint;
    v_Rcount1 bigint;
BEGIN
    v_Rcount := 0;
    v_Rcount1 := 0;
    
    SELECT COUNT(*) INTO v_Rcount
    FROM "Clg"."Fee_College_Student_Status_OthStu" a
    INNER JOIN "Clg"."Fee_Master_College_OthStudents_GH" b 
        ON a."FMCOST_Id" = b."FMCOST_Id" 
        AND a."ASMAY_Id" = b."ASMAY_Id" 
        AND a."MI_Id" = b."MI_Id" 
        AND a."FMG_Id" = b."FMG_Id"
    INNER JOIN "Clg"."Fee_Master_College_OthStudents_GH_Instl" c 
        ON b."FMCOSTGH_Id" = c."FMCOSTGH_Id" 
        AND a."FMH_Id" = c."FMH_ID" 
        AND a."FTI_Id" = c."FTI_ID"
    WHERE b."MI_Id" = p_MI_Id 
        AND b."ASMAY_Id" = p_ASMAY_Id 
        AND b."FMCOST_Id" = p_FMCOST_Id 
        AND b."FMG_Id" = p_FMG_Id 
        AND c."FMH_ID" = p_FMH_Id 
        AND c."FTI_ID" = p_FTI_Id 
        AND a."FCSSOST_PaidAmount" = 0;
    
    IF v_Rcount > 0 THEN
        
        DELETE FROM "Clg"."Fee_Master_College_OthStudents_GH_Instl" c
        USING "Clg"."Fee_College_Student_Status_OthStu" a
        INNER JOIN "Clg"."Fee_Master_College_OthStudents_GH" b 
            ON a."FMCOST_Id" = b."FMCOST_Id" 
            AND a."ASMAY_Id" = b."ASMAY_Id" 
            AND a."MI_Id" = b."MI_Id" 
            AND a."FMG_Id" = b."FMG_Id"
        WHERE c."FMCOSTGH_Id" = b."FMCOSTGH_Id" 
            AND a."FMH_Id" = c."FMH_ID" 
            AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_MI_Id 
            AND b."ASMAY_Id" = p_ASMAY_Id 
            AND b."FMCOST_Id" = p_FMCOST_Id 
            AND b."FMG_Id" = p_FMG_Id 
            AND c."FMH_ID" = p_FMH_Id 
            AND c."FTI_ID" = p_FTI_Id 
            AND a."FCSSOST_PaidAmount" = 0;
        
        DELETE FROM "Clg"."Fee_College_Student_Status_OthStu" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "FMCOST_Id" = p_FMCOST_Id 
            AND "FMG_Id" = p_FMG_Id 
            AND "FMH_ID" = p_FMH_Id 
            AND "FTI_ID" = p_FTI_Id 
            AND "FCSSOST_PaidAmount" = 0;
        
        SELECT COUNT(*) INTO v_Rcount1
        FROM "Clg"."Fee_Master_College_OthStudents_GH_Instl" 
        WHERE "FMCOSTGH_Id" IN (
            SELECT "FMCOSTGH_Id" 
            FROM "Clg"."Fee_Master_College_OthStudents_GH" 
            WHERE "FMG_Id" = p_FMG_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "MI_Id" = p_MI_Id 
                AND "FMCOST_Id" = p_FMCOST_Id
        );
        
        IF v_Rcount1 = 0 THEN
            DELETE FROM "Clg"."Fee_Master_College_OthStudents_GH" 
            WHERE "FMG_Id" = p_FMG_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "MI_Id" = p_MI_Id 
                AND "FMCOST_Id" = p_FMCOST_Id;
        END IF;
        
    END IF;
    
    RETURN;
END;
$$;