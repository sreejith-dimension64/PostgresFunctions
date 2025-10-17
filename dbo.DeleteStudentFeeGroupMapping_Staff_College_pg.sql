CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMapping_Staff_College"(
    "MI_Id" bigint,
    "HRME_Id" bigint,
    "ASMAY_Id" bigint,
    "FMG_Id" bigint,
    "FMH_Id" bigint,
    "FTI_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "Rcount" bigint;
    "Rcount1" bigint;
BEGIN
    "Rcount" := 0;
    "Rcount1" := 0;
    
    SELECT COUNT(*) INTO "Rcount"
    FROM "clg"."Fee_College_Student_Status_Staff" a
    INNER JOIN "clg"."Fee_Master_College_Staff_GroupHead" b 
        ON a."HRME_Id" = b."HRME_Id" 
        AND a."ASMAY_Id" = b."ASMAY_Id" 
        AND a."MI_Id" = b."MI_Id" 
        AND a."FMG_Id" = b."FMG_Id"
    INNER JOIN "clg"."Fee_Master_College_Staff_GroupHead_Installments" c 
        ON b."FMCSTGH_Id" = c."FMCSTGH_Id" 
        AND a."FMH_Id" = c."FMH_ID" 
        AND a."FTI_Id" = c."FTI_Id"
    WHERE b."MI_Id" = "MI_Id" 
        AND b."ASMAY_Id" = "ASMAY_Id" 
        AND b."HRME_Id" = "HRME_Id" 
        AND b."FMG_Id" = "FMG_Id" 
        AND c."FMH_ID" = "FMH_Id" 
        AND c."FTI_Id" = "FTI_Id" 
        AND a."FCSSST_PaidAmount" = 0;
    
    IF "Rcount" > 0 THEN
        
        DELETE FROM "clg"."Fee_Master_College_Staff_GroupHead_Installments" c
        USING "clg"."Fee_College_Student_Status_Staff" a
        INNER JOIN "clg"."Fee_Master_College_Staff_GroupHead" b 
            ON a."HRME_Id" = b."HRME_Id" 
            AND a."ASMAY_Id" = b."ASMAY_Id" 
            AND a."MI_Id" = b."MI_Id" 
            AND a."FMG_Id" = b."FMG_Id"
        WHERE c."FMCSTGH_Id" = b."FMCSTGH_Id" 
            AND a."FMH_Id" = c."FMH_ID" 
            AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = "MI_Id" 
            AND b."ASMAY_Id" = "ASMAY_Id" 
            AND b."HRME_Id" = "HRME_Id" 
            AND b."FMG_Id" = "FMG_Id" 
            AND c."FMH_ID" = "FMH_Id" 
            AND c."FTI_ID" = "FTI_Id" 
            AND a."FCSSST_PaidAmount" = 0;
        
        DELETE FROM "clg"."Fee_College_Student_Status_Staff" 
        WHERE "MI_Id" = "MI_Id" 
            AND "ASMAY_Id" = "ASMAY_Id" 
            AND "HRME_Id" = "HRME_Id" 
            AND "FMG_Id" = "FMG_Id" 
            AND "FMH_ID" = "FMH_Id" 
            AND "FTI_ID" = "FTI_Id" 
            AND "FCSSST_PaidAmount" = 0;
        
        SELECT COUNT(*) INTO "Rcount1"
        FROM "clg"."Fee_Master_College_Staff_GroupHead_Installments"
        WHERE "FMCSTGH_Id" IN (
            SELECT "FMCSTGH_Id" 
            FROM "clg"."Fee_Master_College_Staff_GroupHead" 
            WHERE "FMG_Id" = "FMG_Id" 
                AND "ASMAY_Id" = "ASMAY_Id" 
                AND "MI_Id" = "MI_Id" 
                AND "HRME_Id" = "HRME_Id"
        );
        
        IF "Rcount1" = 0 THEN
            DELETE FROM "clg"."Fee_Master_College_Staff_GroupHead" 
            WHERE "FMG_Id" = "FMG_Id" 
                AND "ASMAY_Id" = "ASMAY_Id" 
                AND "MI_Id" = "MI_Id" 
                AND "HRME_Id" = "HRME_Id";
        END IF;
        
    END IF;
    
    RETURN;
END;
$$;