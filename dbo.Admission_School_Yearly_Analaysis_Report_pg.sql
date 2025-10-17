CREATE OR REPLACE FUNCTION "dbo"."Admission_School_Yearly_Analaysis_Report"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "Noofyears" VARCHAR(20),
    "TCflag" INT,
    "Deactiveflag" INT,
    "Reporttype" TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMCL_Order" INT,
    "ASMAY_Order" INT,
    "ASMCL_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "totalcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SQLQUERY" TEXT;
    "ASMAY_Order" INT;
BEGIN

    SELECT "Adm_School_M_Academic_Year"."ASMAY_Order" INTO "ASMAY_Order"
    FROM "Adm_School_M_Academic_Year"
    WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = "Admission_School_Yearly_Analaysis_Report"."ASMAY_Id"::BIGINT
    AND "Adm_School_M_Academic_Year"."MI_Id" = "Admission_School_Yearly_Analaysis_Report"."MI_Id"::BIGINT;

    IF "Reporttype" = 'new' THEN
    
        "SQLQUERY" := '
        SELECT DISTINCT "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", A."ASMCL_Id", A."ASMAY_Id", COUNT(*) as totalcount 
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_M_Academic_Year" B ON A."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = A."ASMCL_Id" 
        WHERE A."MI_Id" = ' || "MI_Id" || ' AND A."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = ' || "MI_Id" || '  
            AND "ASMAY_Order" <= ' || "ASMAY_Order" || ' 
            ORDER BY "ASMAY_Order" DESC
            LIMIT ' || "Noofyears" || '
        )
        GROUP BY "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", A."ASMCL_Id", A."ASMAY_Id"
        ORDER BY "ASMCL_Order", "ASMAY_Order"';

    ELSIF "Reporttype" = 'total' THEN
    
        IF "TCflag" = 1 AND "Deactiveflag" = 1 THEN
        
            "SQLQUERY" := '
            SELECT DISTINCT "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id", COUNT(*) as totalcount  
            FROM "Adm_M_Student" A 
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
            WHERE A."MI_Id" = ' || "MI_Id" || ' AND B."ASMAY_Id" IN (
                SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" 
                WHERE "MI_Id" = ' || "MI_Id" || ' 
                AND "ASMAY_Order" <= ' || "ASMAY_Order" || '
                ORDER BY "ASMAY_Order" DESC
                LIMIT ' || "Noofyears" || '
            )
            GROUP BY "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id"
            ORDER BY "ASMCL_Order", "ASMAY_Order"';

        ELSIF "TCflag" = 1 AND "Deactiveflag" = 0 THEN
        
            "SQLQUERY" := '
            SELECT DISTINCT "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id", COUNT(*) as totalcount 
            FROM "Adm_M_Student" A 
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
            WHERE A."MI_Id" = ' || "MI_Id" || ' AND "AMST_SOL" IN (''L'', ''S'') AND "AMST_ActiveFlag" IN (1, 0) AND B."AMAY_ActiveFlag" IN (1, 0)
            AND B."ASMAY_Id" IN (
                SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" 
                WHERE "MI_Id" = ' || "MI_Id" || ' 
                AND "ASMAY_Order" <= ' || "ASMAY_Order" || '
                ORDER BY "ASMAY_Order" DESC
                LIMIT ' || "Noofyears" || '
            )
            GROUP BY "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id"
            ORDER BY "ASMCL_Order", "ASMAY_Order"';

        ELSIF "TCflag" = 0 AND "Deactiveflag" = 1 THEN
        
            "SQLQUERY" := '
            SELECT DISTINCT "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id", COUNT(*) as totalcount 
            FROM "Adm_M_Student" A 
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
            WHERE A."MI_Id" = ' || "MI_Id" || ' AND "AMST_SOL" IN (''D'', ''S'') AND "AMST_ActiveFlag" IN (1) AND B."AMAY_ActiveFlag" IN (1)
            AND B."ASMAY_Id" IN (
                SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" 
                WHERE "MI_Id" = ' || "MI_Id" || ' 
                AND "ASMAY_Order" <= ' || "ASMAY_Order" || '
                ORDER BY "ASMAY_Order" DESC
                LIMIT ' || "Noofyears" || '
            )
            GROUP BY "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id"
            ORDER BY "ASMCL_Order", "ASMAY_Order"';

        ELSE
        
            "SQLQUERY" := '
            SELECT DISTINCT "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id", COUNT(*) as totalcount 
            FROM "Adm_M_Student" A 
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
            WHERE A."MI_Id" = ' || "MI_Id" || ' AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND B."AMAY_ActiveFlag" = 1
            AND B."ASMAY_Id" IN (
                SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" 
                WHERE "MI_Id" = ' || "MI_Id" || ' 
                AND "ASMAY_Order" <= ' || "ASMAY_Order" || '
                ORDER BY "ASMAY_Order" DESC
                LIMIT ' || "Noofyears" || '
            )
            GROUP BY "ASMAY_Year", "ASMCL_ClassName", "ASMCL_Order", "ASMAY_Order", B."ASMCL_Id", B."ASMAY_Id"
            ORDER BY "ASMCL_Order", "ASMAY_Order"';

        END IF;

    END IF;

    RETURN QUERY EXECUTE "SQLQUERY";

END;
$$;