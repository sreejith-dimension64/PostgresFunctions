CREATE OR REPLACE FUNCTION "dbo"."DATEWISE_TRN_TERMWISE_FEE"(
   p_MI_Id bigint,
   p_ASMAY_Id bigint,
   p_frmdate date,
   p_todate date
)
RETURNS TABLE(
   "FMT_Id" bigint,
   "TRMR_Id" bigint,
   "FSS_ToBePaid" numeric,
   "FSS_PaidAmount" numeric,
   "FSS_TotalToBePaid" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
   RETURN QUERY
   SELECT DISTINCT 
      C."FMT_Id",
      B."TRMR_Id",
      SUM(A."FSS_ToBePaid") AS "FSS_ToBePaid",
      SUM(A."FSS_PaidAmount") + SUM(A."FSS_ConcessionAmount") AS "FSS_PaidAmount",
      SUM(A."FSS_TotalToBePaid") AS "FSS_TotalToBePaid"
   FROM "Fee_Student_Status" AS A
   INNER JOIN "TRN"."TR_Student_Route" AS B ON A."AMST_Id" = B."AMST_Id"
   INNER JOIN "Fee_Master_Group" AS D ON D."FMG_Id" = A."FMG_Id"
   INNER JOIN "Fee_Master_Terms_FeeHeads" AS C ON A."FMH_Id" = C."FMH_Id" AND C."FTI_Id" = A."FTI_Id"
   WHERE A."FMH_Id" IN (
      SELECT DISTINCT "FMH_Id" 
      FROM "Fee_Master_Terms_FeeHeads" 
      WHERE "FMH_Id" IN (
         SELECT "FMH_Id" 
         FROM "Fee_Master_Head" 
         WHERE "MI_Id" = p_MI_Id 
         AND "FMH_Flag" = 'T' 
         AND "FMH_RefundFlag" <> 1
      )
   )
   AND A."MI_Id" = p_MI_Id 
   AND A."asmay_id" = p_ASMAY_Id
   AND A."AMST_Id" IN (
      SELECT DISTINCT F."AMST_Id" 
      FROM "dbo"."Fee_Y_Payment_School_Student" F
      INNER JOIN "dbo"."Fee_Y_Payment" G ON G."MI_Id" = p_MI_Id 
         AND G."ASMAY_Id" = p_ASMAY_Id 
         AND G."fyp_id" = F."fyp_id"
      INNER JOIN "Fee_T_Payment" AS H ON H."FYP_Id" = G."FYP_Id"
      INNER JOIN "Fee_Master_Amount" AS E ON E."MI_Id" = p_MI_Id 
         AND E."ASMAY_Id" = p_ASMAY_Id 
         AND H."FMA_Id" = E."FMA_Id"
      WHERE G."FYP_Date"::date BETWEEN p_frmdate AND p_todate
   )
   GROUP BY C."FMT_Id", B."TRMR_Id"
   ORDER BY B."TRMR_Id";
END;
$$;