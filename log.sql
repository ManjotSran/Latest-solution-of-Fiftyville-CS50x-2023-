-- Keep a log of any SQL queries you execute as you solve the mystery.
-- Finding description about the Crimes that took place on 28/7/2021 from the crime_scene_reports table
SELECT description FROM crime_scene_reports WHERE year = 2021 AND month = 7 AND day = 28;

-- Finding the name and descriptions of the people who talked about the Bakery in their descriptions of the crime that took place on 28/7/2021
SELECT name, transcript FROM interviews WHERE year = 2021 AND month = 7 AND transcript LIKE '%Bakery%';

-- Finding license_plate, activity from bakery_security_logs on 28/7/2021 within the time frame of 10:15 AM to 10:25 AM
SELECT license_plate, activity FROM bakery_security_logs WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >=15 AND minute <=25;

-- Finding information from the people table based on the licence_plate of the cars that exit the  bakery on 28/7/2021 within the time frame of 10:15 AM to 10:25 AM
SELECT * FROM people WHERE license_plate IN (
  SELECT license_plate FROM bakery_security_logs
  WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25
);

-- Suspicious people = ['Vanessa','Barry','Iman','Sofia','Luca','Diana','Kelsey','Bruce']
-- Now checking who took flight

-- Finding information about the flights that took place on 29/7/2021 to locate the earliest flight
SELECT * FROM flights WHERE day = 29 ORDER BY hour;

-- Verifying that the earliest flight is actually the one that left Fiftyville airport
SELECT flights.id, origin.abbreviation AS origin_airport, origin.full_name AS origin_full_name,
   ...> destination.abbreviation AS destination_airport, destination.full_name AS destination_full_name
   ...> FROM flights
   ...> JOIN airports AS origin ON flights.origin_airport_id = origin.id
   ...> JOIN airports AS destination ON flights.destination_airport_id = destination.id
   ...> WHERE origin.full_name = 'Fiftyville Regional Airport' AND flights.day = 29 AND flights.hour = 8 AND flights.minute = 20;


-- Finding information of the passengers who boarded the earliest flight out of fiftyville on 29/7/2021
SELECT * FROM passengers WHERE flight_id = 36 AND passport_number IN (
  SELECT passport_number FROM people
  WHERE license_plate IN (
    SELECT license_plate FROM bakery_security_logs
    WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25
  )
);

-- Finding names of the suspicious people from the people's table
SELECT * FROM people WHERE passport_number IN (SELECT passport_number FROM passengers
  WHERE flight_id = 36 AND passport_number IN (
    SELECT passport_number FROM people
    WHERE license_plate IN (
      SELECT license_plate FROM bakery_security_logs
      WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25
    )
  )
);
-- Crime Suspects: Sofia, Luca, Kelsey, Bruce
-- Now we know from the interviewer's that suspect called a person for about 30 minutes, so let's check about phone calls tableSELECT * FROM phone_calls

SELECT * FROM phone_calls WHERE caller IN ( SELECT phone_number FROM people WHERE name IN ('Sofia', 'Luca', 'Kelsey', 'Bruce'));

-- Lets' see who made a phone call on 28/7/2021.

SELECT * FROM phone_calls WHERE caller IN (SELECT phone_number FROM people
  WHERE name IN ('Sofia', 'Luca', 'Kelsey', 'Bruce')
) AND year = 2021 AND month = 7 AND day = 28;

-- Let's find the name of the peoplw who did the phone call on 28/7/2021 using info. in the previous query.
SELECT name FROM people WHERE phone_number IN (SELECT caller FROM phone_calls WHERE caller IN (
    SELECT phone_number FROM people
    WHERE name IN (
      'Sofia', 'Luca', 'Kelsey', 'Bruce')
    ) AND year = 2021 AND month = 7 AND day = 28
);
-- Now our suspects are norrowed to 3: Sofia, Kelsey, Bruce

-- Now we know that the suspect did a phone call for about 30 minutes. SO let's find who did that.
SELECT name FROM people WHERE phone_number = '(499) 555-9472';
-- Suspect till now: Kelsey
--We also know from the one of the interviewer that the suspect had withdrawn some money from an ATM at Leggett Street.
--Let's see who withdrawn money from ATM located on Leggett Street.
SELECT account_number FROM atm_transactions WHERE atm_location = 'Leggett Street' AND year = 2021 AND month = 7 AND day = 28 AND transaction_type = 'withdraw';
SELECT name FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
WHERE account_number IN (
  SELECT account_number FROM atm_transactions
  WHERE atm_location = 'Leggett Street' AND year = 2021 AND month = 7 AND day = 28 AND transaction_type = 'withdraw'
);

-- Oh No!!, Kelsey did't withdrawn money. So, let's see if Bruce is the suspect
SELECT * FROM people WHERE name = 'Bruce';

-- Let's verify if Bruce see the suspect
SELECT * FROM bakery_security_logs WHERE license_plate = (SELECT license_plate FROM people WHERE name = 'Bruce');

SELECT * FROM flights
JOIN passengers ON passengers.flight_id = flights.id
WHERE passengers.passport_number = (SELECT passport_number FROM people WHERE name = 'Bruce');
-- So, Bruce is the suspect

-- Now, let's check who is the accomplice
SELECT * FROM people WHERE phone_number = '(375) 555-8161';

-- So, Robin is the accomplice who helped the Suspect (Bruce) Flee.
