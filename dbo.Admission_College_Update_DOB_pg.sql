CREATE OR REPLACE FUNCTION "dbo"."Admission_College_Update_DOB"(@MI_Id TEXT)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_dobdate TEXT;
    v_dobwords TEXT;
    v_amst_id TEXT;
    v_month TEXT;
    v_date TEXT;
    v_year TEXT;
    v_monthname TEXT;
    v_datename TEXT;
    v_yearname TEXT;
    v_dob TEXT;
    v_yearname12 TEXT;
    v_yearname1 TEXT;
    v_yearname123 TEXT;
    v_dob1 TEXT;
    v_finaldob TEXT;
    student_rec RECORD;
BEGIN

    FOR student_rec IN
        SELECT "AMCST_Id", 
               TO_CHAR("AMCST_DOB", 'DD/MM/YYYY') as amst_dob, 
               "AMCST_DOBin_words"
        FROM "clg"."Adm_Master_College_Student" 
        WHERE "MI_Id" = @MI_Id
        AND "AMCST_DOBin_words" IS NULL
    LOOP
        v_amst_id := student_rec."AMCST_Id"::TEXT;
        v_dobdate := student_rec.amst_dob;
        v_dobwords := student_rec."AMCST_DOBin_words";

        v_month := SUBSTRING(v_dobdate, 4, 2);
        v_date := SUBSTRING(v_dobdate, 1, 2);
        v_year := SUBSTRING(v_dobdate, 7, 4);

        v_monthname := TO_CHAR(TO_DATE(v_dobdate, 'DD/MM/YYYY'), 'Month');
        v_monthname := TRIM(v_monthname);

        v_date := CASE WHEN v_date = '01' THEN 'FIRST' WHEN v_date = '02' THEN 'SECOND' WHEN v_date = '03' THEN 'THIRD' WHEN v_date = '04' THEN 'FOURTH' WHEN v_date = '05' THEN 'FIFTH'
        WHEN v_date = '06' THEN 'SIXTH' WHEN v_date = '07' THEN 'SEVENTH' WHEN v_date = '08' THEN 'EIGHTH' WHEN v_date = '09' THEN 'NINTH' WHEN v_date = '10' THEN 'TENTH' WHEN v_date = '11' THEN 'ELEVENTH'
        WHEN v_date = '12' THEN 'TWELFTH' WHEN v_date = '13' THEN 'THIRTEENTH' WHEN v_date = '14' THEN 'FOURTEENTH' WHEN v_date = '15' THEN 'FIFTEENTH' WHEN v_date = '16' THEN 'SIXTEENTH'
        WHEN v_date = '17' THEN 'SEVENTEENTH' WHEN v_date = '18' THEN 'EIGHTEENTH' WHEN v_date = '19' THEN 'NINTEENTH' WHEN v_date = '20' THEN 'TWENTY' WHEN v_date = '21' THEN 'TWENTY FIRST'
        WHEN v_date = '22' THEN 'TWENTY SECOND' WHEN v_date = '23' THEN 'TWENTY THIRD' WHEN v_date = '24' THEN 'TWENTY FOURTH' WHEN v_date = '25' THEN 'TWENTY FIFTH' WHEN v_date = '26' THEN 'TWENTY SIXTH'
        WHEN v_date = '27' THEN 'TWENTY SEVENTH' WHEN v_date = '28' THEN 'TWENTY EIGHTH' WHEN v_date = '29' THEN 'TWENTY NINTH' WHEN v_date = '30' THEN 'THIRTY' WHEN v_date = '31' THEN 'THIRTY FIRST' ELSE '' END;

        v_dob := SUBSTRING(v_year, 1, 2);
        v_dob1 := SUBSTRING(v_year, 3, 2);

        IF (v_dob::INTEGER >= 20) THEN
            v_yearname12 := 'TWO THOUSAND';
        ELSE
            v_yearname12 := 'NINTEEN';
        END IF;

        v_yearname123 := CASE WHEN v_dob1 = '01' THEN 'ONE' WHEN v_dob1 = '02' THEN 'TWO'
        WHEN v_dob1 = '03' THEN 'THREE' WHEN v_dob1 = '04' THEN 'FOUR' WHEN v_dob1 = '05' THEN 'FIVE' WHEN v_dob1 = '06' THEN 'SIX' WHEN v_dob1 = '07' THEN 'SEVEN' WHEN v_dob1 = '08' THEN 'EIGHT'
        WHEN v_dob1 = '09' THEN 'NINE' WHEN v_dob1 = '10' THEN 'TEN' WHEN v_dob1 = '11' THEN 'ELEVEN' WHEN v_dob1 = '12' THEN 'TWELFTH' WHEN v_dob1 = '13' THEN 'THIRTEEN' WHEN v_dob1 = '14' THEN 'FOURTEEN'
        WHEN v_dob1 = '15' THEN 'FIFTEEN' WHEN v_dob1 = '16' THEN 'SIXTEEN' WHEN v_dob1 = '17' THEN 'SEVENTEEN' WHEN v_dob1 = '18' THEN 'EIGHTEEN' WHEN v_dob1 = '19' THEN 'NINTEEN' WHEN v_dob1 = '20' THEN 'TWENTY'
        WHEN v_dob1 = '21' THEN 'TWENTY ONE' WHEN v_dob1 = '22' THEN 'TWENTY TWO' WHEN v_dob1 = '23' THEN 'TWENTY THREE' WHEN v_dob1 = '24' THEN 'TWENTY FOUR' WHEN v_dob1 = '25' THEN 'TWENTY FIVE'
        WHEN v_dob1 = '26' THEN 'TWENTY SIX' WHEN v_dob1 = '27' THEN 'TWENTY SEVEN' WHEN v_dob1 = '28' THEN 'TWENTY EIGHT' WHEN v_dob1 = '29' THEN 'TWENTY NINE' WHEN v_dob1 = '30' THEN 'THIRTY'
        WHEN v_dob1 = '31' THEN 'THIRTY ONE' WHEN v_dob1 = '32' THEN 'THIRTY TWO' WHEN v_dob1 = '33' THEN 'THIRTY THREE' WHEN v_dob1 = '34' THEN 'THIRTY FOUR' WHEN v_dob1 = '35' THEN 'THIRTY FIVE'
        WHEN v_dob1 = '36' THEN 'THIRTY SIX' WHEN v_dob1 = '37' THEN 'THIRTY SEVEN' WHEN v_dob1 = '38' THEN 'THIRTY EIGHT' WHEN v_dob1 = '39' THEN 'THIRTY NINE' WHEN v_dob1 = '40' THEN 'FOURTY'
        WHEN v_dob1 = '41' THEN 'FOURTY ONE' WHEN v_dob1 = '42' THEN 'FOURTY TWO' WHEN v_dob1 = '43' THEN 'FOURTY THREE' WHEN v_dob1 = '44' THEN 'FOURTY FOUR' WHEN v_dob1 = '45' THEN 'FOURTY FIVE'
        WHEN v_dob1 = '46' THEN 'FOURTY SIX' WHEN v_dob1 = '47' THEN 'FOURTY SEVEN' WHEN v_dob1 = '48' THEN 'FOURTY EIGHT' WHEN v_dob1 = '49' THEN 'FOURTY NINE' WHEN v_dob1 = '50' THEN 'FIFTY'
        WHEN v_dob1 = '51' THEN 'FIFTY ONE' WHEN v_dob1 = '52' THEN 'FIFTY TWO' WHEN v_dob1 = '53' THEN 'FIFTY THREE' WHEN v_dob1 = '54' THEN 'FIFTY FOUR' WHEN v_dob1 = '55' THEN 'FIFTY FIVE'
        WHEN v_dob1 = '56' THEN 'FIFTY SIX' WHEN v_dob1 = '57' THEN 'FIFTY SEVEN' WHEN v_dob1 = '58' THEN 'FIFTY EIGHT' WHEN v_dob1 = '59' THEN 'FIFTY NINE' WHEN v_dob1 = '60' THEN 'SIXTY'
        WHEN v_dob1 = '61' THEN 'SIXTY ONE' WHEN v_dob1 = '62' THEN 'SIXTY TWO' WHEN v_dob1 = '63' THEN 'SIXTY THREE' WHEN v_dob1 = '64' THEN 'SIXTY FOUR' WHEN v_dob1 = '65' THEN 'SIXTY FIVE'
        WHEN v_dob1 = '66' THEN 'SIXTY SIX' WHEN v_dob1 = '67' THEN 'SIXTY SEVEN' WHEN v_dob1 = '68' THEN 'SIXTY EIGHT' WHEN v_dob1 = '69' THEN 'SIXTY NINE' WHEN v_dob1 = '70' THEN 'SEVENTY'
        WHEN v_dob1 = '71' THEN 'SEVENTY ONE' WHEN v_dob1 = '72' THEN 'SEVENTY TWO' WHEN v_dob1 = '73' THEN 'SEVENTY THREE' WHEN v_dob1 = '74' THEN 'SEVENTY FOUR' WHEN v_dob1 = '75' THEN 'SEVENTY FIVE'
        WHEN v_dob1 = '76' THEN 'SEVENTY SIX' WHEN v_dob1 = '77' THEN 'SEVENTY SEVEN' WHEN v_dob1 = '78' THEN 'SEVENTY EIGHT' WHEN v_dob1 = '79' THEN 'SEVENTY NINE' WHEN v_dob1 = '80' THEN 'EIGHTY'
        WHEN v_dob1 = '81' THEN 'EIGHTY ONE' WHEN v_dob1 = '82' THEN 'EIGHTY TWO' WHEN v_dob1 = '83' THEN 'EIGHTY THREE' WHEN v_dob1 = '84' THEN 'EIGHTY FOUR' WHEN v_dob1 = '85' THEN 'EIGHTY FIVE'
        WHEN v_dob1 = '86' THEN 'EIGHTY SIX' WHEN v_dob1 = '87' THEN 'EIGHTY SEVEN' WHEN v_dob1 = '88' THEN 'EIGHTY EIGHT' WHEN v_dob1 = '89' THEN 'EIGHTY NINE' WHEN v_dob1 = '90' THEN 'NINTY'
        WHEN v_dob1 = '91' THEN 'NINTY ONE' WHEN v_dob1 = '92' THEN 'NINTY TWO' WHEN v_dob1 = '93' THEN 'NINTY THREE' WHEN v_dob1 = '94' THEN 'NINTY FOUR' WHEN v_dob1 = '95' THEN 'NINTY FIVE'
        WHEN v_dob1 = '96' THEN 'NINTY SIX' WHEN v_dob1 = '97' THEN 'NINTY SEVEN' WHEN v_dob1 = '98' THEN 'NINTY EIGHT' WHEN v_dob1 = '99' THEN 'NINTY NINE'
        WHEN v_dob1 = '00' THEN 'ZERO' ELSE '' END;

        v_finaldob := v_date || ' ' || UPPER(v_monthname) || ' ' || v_yearname12 || ' ' || v_yearname123;

        UPDATE "clg"."Adm_Master_College_Student" 
        SET "AMCST_DOBin_words" = v_finaldob 
        WHERE "AMCST_Id" = v_amst_id;

        v_finaldob := '';

    END LOOP;

    RETURN;
END;
$$;