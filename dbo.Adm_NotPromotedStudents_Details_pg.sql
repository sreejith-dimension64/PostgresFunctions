CREATE OR REPLACE FUNCTION "dbo"."Adm_NotPromotedStudents_Details"(
    "MI_Id" bigint,
    "PrevASMAY_Id" bigint,
    "ASMAY_Id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "StudentName" text,
    "AMST_Admno" varchar,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "BalanceAmount" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
select "YS"."AMST_Id",
COALESCE("c"."AMST_FirstName",'')||' '||COALESCE("c"."AMST_Middlename",'')||' '||COALESCE("c"."AMST_LastName",'') AS "StudentName",
"c"."AMST_Admno",
"ASMC"."ASMCL_ClassName",
"ASMS"."ASMC_SectionName",
sum("FSS"."FSS_ToBePaid") as "BalanceAmount"
from (
select distinct "b"."AMST_Id" from "adm_M_student" "a" 
inner join "Adm_School_Y_Student" "b" on "a"."AMST_Id"="b"."AMST_Id"
where "b"."ASMAY_Id"="PrevASMAY_Id" and "a"."MI_Id"="MI_Id"

except

select distinct "b"."AMST_Id" from "adm_M_student" "a" 
inner join "Adm_School_Y_Student" "b" on "a"."AMST_Id"="b"."AMST_Id"
where "b"."ASMAY_Id"="ASMAY_Id" and "a"."MI_Id"="MI_Id"
) as "d" 
inner join "Adm_M_Student" "c" on "d"."AMST_Id"="c"."AMST_Id" and "c"."AMST_SOL"='S' and "c"."MI_Id"="MI_Id"
inner join "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id"="c"."AMST_Id" and "YS"."ASMAY_Id"="PrevASMAY_Id"
inner join "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id"="YS"."ASMCL_Id"
inner join "Adm_School_M_section" "ASMS" ON "ASMS"."ASMS_Id"="YS"."ASMS_Id"
left join "fee_student_status" "fss" on "fss"."AMST_Id"="c"."AMST_Id" and "fss"."ASMAY_Id"="PrevASMAY_Id"
group by "YS"."AMST_Id",
COALESCE("c"."AMST_FirstName",'')||' '||COALESCE("c"."AMST_Middlename",'')||' '||COALESCE("c"."AMST_LastName",''),
"c"."AMST_Admno","ASMC"."ASMCL_ClassName","ASMS"."ASMC_SectionName";

END;
$$;