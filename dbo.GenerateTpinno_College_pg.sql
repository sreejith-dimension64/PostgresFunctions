CREATE OR REPLACE FUNCTION "dbo"."GenerateTpinno_College"(p_MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_i bigint;
    v_n bigint;
    v_Generatetpin varchar(100);
    v_AMCST_Id bigint;
    v_Dob varchar(100);
    v_Dob_New varchar(100);
    v_scount int;
    rec_outer RECORD;
    rec_inner RECORD;
BEGIN
    v_i := 1;
    
    DROP TABLE IF EXISTS generatetpno_clg;
    
    CREATE TEMP TABLE generatetpno_clg (
        "AMCST_Id" bigint,
        "Dob" varchar(20),
        "Generatetpin" varchar(30)
    );
    
    FOR rec_outer IN
        SELECT dob, scount 
        FROM (
            SELECT DISTINCT (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS varchar(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) END)
            ) AS Dob,
            COUNT(*) AS scount 
            FROM "CLG"."Adm_Master_College_Student"  
            WHERE "MI_Id" = p_MI_Id 
            GROUP BY (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS varchar(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) END)
            )
            HAVING COUNT(*) >= 1
        ) AS new 
        ORDER BY scount DESC
    LOOP
        v_Dob := rec_outer.dob;
        v_scount := rec_outer.scount;
        
        FOR rec_inner IN
            SELECT DISTINCT "AMCST_Id", (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS varchar(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) END)
            ) AS Dob
            FROM "CLG"."Adm_Master_College_Student"  
            WHERE "MI_Id" = p_MI_Id  
            AND (
                SUBSTRING(CAST(EXTRACT(YEAR FROM "AMCST_DOB") AS varchar(10)), 3, 4) +
                (CASE WHEN EXTRACT(MONTH FROM "AMCST_DOB") BETWEEN 0 AND 9 
                    THEN '0' || CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10))
                    ELSE CAST(EXTRACT(MONTH FROM "AMCST_DOB") AS varchar(10)) END) +
                (CASE WHEN EXTRACT(DAY FROM "AMCST_DOB") BETWEEN 0 AND 9
                    THEN '0' || CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) 
                    ELSE CAST(EXTRACT(DAY FROM "AMCST_DOB") AS varchar(10)) END)
            ) = v_Dob
        LOOP
            v_AMCST_Id := rec_inner."AMCST_Id";
            v_Dob_New := rec_inner.Dob;
            
            v_Generatetpin := v_Dob_New || LPAD(v_i::VARCHAR(10), 3, '0');
            
            INSERT INTO generatetpno_clg VALUES(v_AMCST_Id, v_Dob_New, v_Generatetpin);
            
            v_i := v_i + 1;
        END LOOP;
        
        v_i := 1;
    END LOOP;
    
    UPDATE "CLG"."Adm_Master_College_Student" B 
    SET "AMCST_TPINNO" = A."Generatetpin" 
    FROM generatetpno_clg A 
    WHERE A."AMCST_Id" = B."AMCST_Id" 
    AND B."MI_Id" = p_MI_Id;
    
    RETURN;
END;
$$;