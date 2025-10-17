CREATE OR REPLACE FUNCTION "dbo"."date_to_words"(
    "mydate" VARCHAR(50),
    OUT "finalstring" VARCHAR(250)
)
RETURNS VARCHAR(250)
LANGUAGE plpgsql
AS $$
DECLARE
    "yr" BIGINT;
    "dateval" BIGINT;
    "thousand" BIGINT;
    "hundred" BIGINT;
    "tens" BIGINT;
    "month" BIGINT;
    "tensword" VARCHAR(10);
    "onesword" VARCHAR(10);
    "thousandsword" VARCHAR(20);
    "hundredsword" VARCHAR(20);
    "datevalsword" VARCHAR(20);
    "monthvalsword" VARCHAR(20);
BEGIN

    "yr" := SUBSTRING("mydate", 5, 4)::BIGINT;
    "datevalsword" := SUBSTRING("mydate", 1, 2);
    "month" := SUBSTRING("mydate", 3, 2)::BIGINT;

    /* DAY TO WORDS */

    "datevalsword" := CASE "datevalsword"::INTEGER
        WHEN 1 THEN 'First'
        WHEN 2 THEN 'Second'
        WHEN 3 THEN 'Third'
        WHEN 4 THEN 'Fourth'
        WHEN 5 THEN 'Fifth'
        WHEN 6 THEN 'Sixth'
        WHEN 7 THEN 'Seventh'
        WHEN 8 THEN 'Eighth'
        WHEN 9 THEN 'Ninth'
        WHEN 10 THEN 'Tenth'
        WHEN 11 THEN 'Eleventh'
        WHEN 12 THEN 'Twelfth'
        WHEN 13 THEN 'Thirteenth'
        WHEN 14 THEN 'Fourteenth'
        WHEN 15 THEN 'Fifteenth'
        WHEN 16 THEN 'Sixteenth'
        WHEN 17 THEN 'Seventeenth'
        WHEN 18 THEN 'Eighteenth'
        WHEN 19 THEN 'Nineteenth'
        WHEN 20 THEN 'Twentieth'
        WHEN 21 THEN 'Twenty-first'
        WHEN 22 THEN 'Twenty-second'
        WHEN 23 THEN 'Twenty-third'
        WHEN 24 THEN 'Twenty-fourth'
        WHEN 25 THEN 'Twenty-fifth'
        WHEN 26 THEN 'Twenty-sixth'
        WHEN 27 THEN 'Twenty-seventh'
        WHEN 28 THEN 'Twenty-eighth'
        WHEN 29 THEN 'Twenty-ninth'
        WHEN 30 THEN 'Thirtieth'
        WHEN 31 THEN 'Thirty-first'
        ELSE NULL
    END;

    /* Month TO WORDS */

    "monthvalsword" := CASE "month"
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'Febrauy'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE NULL
    END;

    /* YEAR TO WORDS */
    "thousand" := FLOOR("yr" / 1000);
    "yr" := "yr" - "thousand" * 1000;
    "hundred" := FLOOR("yr" / 100);
    "yr" := "yr" - "hundred" * 100;

    IF ("yr" > 19) THEN
        "tens" := FLOOR("yr" / 10);
        "yr" := "yr" % 10;
    ELSE
        "tens" := 0;
    END IF;

    "thousandsword" := CASE "thousand"
        WHEN 1 THEN 'One'
        WHEN 2 THEN 'Two'
        WHEN 3 THEN 'Three'
        WHEN 4 THEN 'Four'
        WHEN 5 THEN 'Five'
        WHEN 6 THEN 'Six'
        WHEN 7 THEN 'Seven'
        WHEN 8 THEN 'Eight'
        WHEN 9 THEN 'Nine'
        ELSE NULL
    END;

    "thousandsword" := COALESCE("thousand"::VARCHAR, '') || 'Thousand ';

    "hundredsword" := CASE "hundred"
        WHEN 0 THEN ''
        WHEN 1 THEN 'One'
        WHEN 2 THEN 'Two'
        WHEN 3 THEN 'Three'
        WHEN 4 THEN 'Four'
        WHEN 5 THEN 'Five'
        WHEN 6 THEN 'Six'
        WHEN 7 THEN 'Seven'
        WHEN 8 THEN 'Eight'
        WHEN 9 THEN 'Nine'
        ELSE ''
    END;

    IF ("hundredsword" <> '') THEN
        "hundredsword" := "hundredsword" || ' Hundred ';
    ELSE
        "hundredsword" := '';
    END IF;

    /*TENS To WORDS*/
    "tensword" := CASE "tens"
        WHEN 2 THEN 'Twenty'
        WHEN 3 THEN 'Thirty'
        WHEN 4 THEN 'Fourty'
        WHEN 5 THEN 'Fifty'
        WHEN 6 THEN 'Sixty'
        WHEN 7 THEN 'Seventy'
        WHEN 8 THEN 'Eigthy'
        WHEN 9 THEN 'Ninety'
        ELSE ''
    END;

    /*ONES To WORDS*/
    "onesword" := CASE "yr"
        WHEN 0 THEN ''
        WHEN 1 THEN 'One'
        WHEN 2 THEN 'Two'
        WHEN 3 THEN 'Three'
        WHEN 4 THEN 'Four'
        WHEN 5 THEN 'Five'
        WHEN 6 THEN 'Six'
        WHEN 7 THEN 'Seven'
        WHEN 8 THEN 'Eight'
        WHEN 9 THEN 'Nine'
        WHEN 10 THEN 'Ten'
        WHEN 11 THEN 'Eleven'
        WHEN 12 THEN 'Twelve'
        WHEN 13 THEN 'Thirteen'
        WHEN 14 THEN 'Fourteen'
        WHEN 15 THEN 'Fifteen'
        WHEN 16 THEN 'Sixteen'
        WHEN 17 THEN 'Seventeen'
        WHEN 18 THEN 'Eighteen'
        WHEN 19 THEN 'Nineteen'
        ELSE ''
    END;

    "finalstring" := COALESCE("dateval"::VARCHAR, '') || '' || 
                     COALESCE("month"::VARCHAR, '') || '' || 
                     COALESCE("thousandsword", '') || '' || 
                     COALESCE("yr"::VARCHAR, '');

END;
$$;