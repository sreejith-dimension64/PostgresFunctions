CREATE OR REPLACE FUNCTION "dbo"."BCEHSLastYearBalance_Report"()
RETURNS TABLE (
    "AMST_Id" bigint,
    "StudentName" text,
    "AMST_AdmNo" text,
    "FMG_GroupName" text,
    "FMH_FeeName" text,
    "FTI_Name" text,
    "HeadWiseBal" bigint,
    "FSS_PaidAmount" bigint,
    "CYBalance" bigint,
    "FTI_Name_Current" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_Id bigint;
    v_HeadWiseBal bigint;
    v_FSS_PaidAmount bigint;
    v_FMA_Id_CY bigint;
    v_MFMA_Id bigint;
    v_CYBalance bigint;
    student_rec RECORD;
    head_rec RECORD;
BEGIN

    FOR student_rec IN 
        SELECT "AMST_Id" 
        FROM "BCEHSLastYearBalance_Temp"
        ORDER BY "AMST_Id"
    LOOP
        v_AMST_Id := student_rec."AMST_Id";

        FOR head_rec IN 
            SELECT sum("FSS_tobepaid") AS "HeadWiseBal", MAX("FMA_Id") AS "FMA_Id" 
            FROM "BCEHSLastYearBalance_Temp" 
            WHERE "AMST_Id" = v_AMST_Id 
            GROUP BY "FMH_Id"
        LOOP
            v_HeadWiseBal := head_rec."HeadWiseBal";
            v_MFMA_Id := head_rec."FMA_Id";

            SELECT "FSS_PaidAmount", "FMA_Id", "FSS_tobepaid"
            INTO v_FSS_PaidAmount, v_FMA_Id_CY, v_CYBalance
            FROM "Fee_Student_Status"
            WHERE "MI_Id" = 5 
                AND "ASMAY_Id" = 75 
                AND "FSS_OBArrearAmount" <> 0
                AND "AMST_Id" = v_AMST_Id 
                AND "FSS_OBArrearAmount" = v_HeadWiseBal 
                AND "FSS_CurrentYrCharges" = v_HeadWiseBal
            LIMIT 1;

            UPDATE "BCEHSLastYearBalance_Temp" 
            SET "HeadWiseBal" = v_HeadWiseBal,
                "FSS_PaidAmount" = v_FSS_PaidAmount,
                "FMA_Id_CY" = v_FMA_Id_CY,
                "CYBalance" = v_CYBalance
            WHERE "AMST_Id" = v_AMST_Id 
                AND "FMA_Id" = v_MFMA_Id;

        END LOOP;

    END LOOP;

    RETURN QUERY
    SELECT 
        T."AMST_Id",
        (COALESCE(AMS."AMST_FirstName", '') || ' ' || COALESCE(AMS."AMST_MiddleName", '') || ' ' || COALESCE(AMS."AMST_LastName", ''))::text AS "StudentName",
        AMS."AMST_AdmNo"::text,
        FMG."FMG_GroupName"::text,
        FMH."FMH_FeeName"::text,
        FTI."FTI_Name"::text,
        sum(T."HeadWiseBal") AS "HeadWiseBal",
        sum(T."FSS_PaidAmount") AS "FSS_PaidAmount",
        sum(T."CYBalance") AS "CYBalance",
        FTIN."FTI_Name"::text AS "FTI_Name_Current"
    FROM "BCEHSLastYearBalance_Temp" T
    INNER JOIN "Fee_Master_Group" FMG ON FMG."FMG_Id" = T."FMG_Id"
    INNER JOIN "Fee_Master_Head" FMH ON FMH."FMH_Id" = T."FMH_Id"
    INNER JOIN "Fee_T_Installment" FTI ON FTI."FTI_Id" = T."FTI_Id"
    INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id" = T."AMST_Id"
    INNER JOIN "Fee_Master_Amount" FMA ON FMA."FMA_Id" = T."FMA_Id_CY"
    INNER JOIN "Fee_T_Installment" FTIN ON FTIN."FTI_Id" = FMA."FTI_Id"
    GROUP BY 
        T."AMST_Id",
        COALESCE(AMS."AMST_FirstName", '') || ' ' || COALESCE(AMS."AMST_MiddleName", '') || ' ' || COALESCE(AMS."AMST_LastName", ''),
        AMS."AMST_AdmNo",
        FMG."FMG_GroupName",
        FMH."FMH_FeeName",
        FTI."FTI_Name",
        FTIN."FTI_Name"
    HAVING sum(T."HeadWiseBal") > 0
    ORDER BY T."AMST_Id";

    RETURN;
END;
$$;