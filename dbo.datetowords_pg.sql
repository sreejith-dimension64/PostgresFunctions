CREATE OR REPLACE FUNCTION datetowords(mydate VARCHAR(100))
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_yr INT;
    v_dateval INT;
    v_thousand INT;
    v_hundred INT;
    v_tens INT;
    v_tensword VARCHAR(10);
    v_onesword VARCHAR(10);
    v_thousandsword VARCHAR(20);
    v_hundredsword VARCHAR(20);
    v_datevalsword VARCHAR(20);
BEGIN

    v_yr := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    v_dateval := EXTRACT(DAY FROM CURRENT_TIMESTAMP);

    --/* DAY TO WORDS */

    --SELECT CASE v_dateval
    --WHEN 1 THEN 'First'
    --WHEN 2 THEN 'Second'
    --WHEN 3 THEN 'Third'
    --WHEN 4 THEN 'Fourth'
    --WHEN 5 THEN 'Fifth'
    --WHEN 6 THEN 'Sixth'
    --WHEN 7 THEN 'Seventh'
    --WHEN 8 THEN 'Eighth'
    --WHEN 9 THEN 'Ninth'
    --WHEN 10 THEN 'Tenth'
    --WHEN 11 THEN 'Eleventh'
    --WHEN 12 THEN 'Twelfth'
    --WHEN 13 THEN 'Thirteenth'
    --WHEN 14 THEN 'Fourteenth'
    --WHEN 15 THEN 'Fifteenth'
    --WHEN 16 THEN 'Sixteenth'
    --WHEN 17 THEN 'Seventeenth'
    --WHEN 18 THEN 'Eighteenth'
    --WHEN 19 THEN 'Nineteenth'
    --WHEN 20 THEN 'Twentieth'
    --WHEN 21 THEN 'Twenty-first'
    --WHEN 22 THEN 'Twenty-second'
    --WHEN 23 THEN 'Twenty-third'
    --WHEN 24 THEN 'Twenty-fourth'
    --WHEN 25 THEN 'Twenty-fifth'
    --WHEN 26 THEN 'Twenty-sixth'
    --WHEN 27 THEN 'Twenty-seventh'
    --WHEN 28 THEN 'Twenty-eighth'
    --WHEN 29 THEN 'Twenty-ninth'
    --WHEN 30 THEN 'Thirtieth'
    --WHEN 31 THEN 'Thirty-first'
    --END INTO v_datevalsword;

    --/* YEAR TO WORDS */
    --v_thousand := FLOOR(v_yr/1000);
    --v_yr := v_yr - v_thousand * 1000;
    --v_hundred := FLOOR(v_yr / 100);
    --v_yr := v_yr - v_hundred * 100;

    --IF (v_yr > 19) THEN
    --    v_tens := FLOOR(v_yr / 10);
    --    v_yr := v_yr % 10;
    --ELSE
    --    v_tens := 0;
    --END IF;

    --SELECT CASE v_thousand
    --WHEN 1 THEN 'One'
    --WHEN 2 THEN 'Two'
    --WHEN 3 THEN 'Three'
    --WHEN 4 THEN 'Four'
    --WHEN 5 THEN 'Five'
    --WHEN 6 THEN 'Six'
    --WHEN 7 THEN 'Seven'
    --WHEN 8 THEN 'Eight'
    --WHEN 9 THEN 'Nine'
    --END INTO v_thousandsword;
    --v_thousandsword := CONCAT(v_thousandsword, ' Thousand ');

    --SELECT CASE v_hundred
    --WHEN 0 THEN ''
    --WHEN 1 THEN 'One'
    --WHEN 2 THEN 'Two'
    --WHEN 3 THEN 'Three'
    --WHEN 4 THEN 'Four'
    --WHEN 5 THEN 'Five'
    --WHEN 6 THEN 'Six'
    --WHEN 7 THEN 'Seven'
    --WHEN 8 THEN 'Eight'
    --WHEN 9 THEN 'Nine'
    --END INTO v_hundredsword;
    --IF (v_hundredsword <> '') THEN
    --    v_hundredsword := CONCAT(v_hundredsword, ' Hundred ');
    --ELSE
    --    v_hundredsword := '';
    --END IF;

    --/*TENS To WORDS*/
    --SELECT CASE v_tens
    --WHEN 2 THEN 'Twenty'
    --WHEN 3 THEN 'Thirty'
    --WHEN 4 THEN 'Fourty'
    --WHEN 5 THEN 'Fifty'
    --WHEN 6 THEN 'Sixty'
    --WHEN 7 THEN 'Seventy'
    --WHEN 8 THEN 'Eigthy'
    --WHEN 9 THEN 'Ninety'
    --ELSE ''
    --END INTO v_tensword;

    --/*ONES To WORDS*/
    --SELECT CASE v_yr
    --WHEN 0 THEN ''
    --WHEN 1 THEN 'One'
    --WHEN 2 THEN 'Two'
    --WHEN 3 THEN 'Three'
    --WHEN 4 THEN 'Four'
    --WHEN 5 THEN 'Five'
    --WHEN 6 THEN 'Six'
    --WHEN 7 THEN 'Seven'
    --WHEN 8 THEN 'Eight'
    --WHEN 9 THEN 'Nine'
    --WHEN 10 THEN 'Ten'
    --WHEN 11 THEN 'Eleven'
    --WHEN 12 THEN 'Twelve'
    --WHEN 13 THEN 'Thirteen'
    --WHEN 14 THEN 'Fourteen'
    --WHEN 15 THEN 'Fifteen'
    --WHEN 16 THEN 'Sixteen'
    --WHEN 17 THEN 'Seventeen'
    --WHEN 18 THEN 'Eighteen'
    --WHEN 19 THEN 'Nineteen'
    --END INTO v_onesword;

    --RETURN CONCAT(v_datevalsword, ' Day of ', TO_CHAR(mydate::TIMESTAMP, 'Month'), ' ', v_thousandsword, v_hundredsword, v_tensword, ' ', v_onesword);

    RETURN NULL;

END;
$$;