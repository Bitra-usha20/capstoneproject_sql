use capstone_project;
/* -----------------------------------------------------------
   SQL Murder Mystery — Investigation 
   File: SQL_Murder_Mystery_documented.sql
   Author: usha 
   Date: 2025-11-29
   ------------------------------------------------------- */
   /* ----------------------------------------------------------------
   Ivestigation Steps:
   STEP 1: Identify where and when the crime happened
   Objective:
     Find any presence in the CEO Office near the crime window 
   Approach:
     Use keycard_logs and filter logs that overlap the crime window.
------------------------------------------------------------------ */
SELECT  room as place, description, found_time as crime_time
FROM evidence
ORDER BY found_time ASC
LIMIT 1;
/* ----------------------------------------
-- Insight:
--   AT The CEO Office at the exact moment of the crime (21:50) got this from evidence.
------------------------------- */
/* ----------------------------------------------------------------
   STEP 2: Analyze who accessed critical areas at the time
   Objective:
     Identify employees who were in the CEO Office or Server Room at 20:50.
   Approach:
     JOIN employees to keycard_logs; check if 2025-10-15 20:50:00 is between entry and exit.*/
SELECT k.log_id, k.employee_id, e.name, k.room, k.entry_time, k.exit_time
FROM keycard_logs k
JOIN employees e ON k.employee_id = e.employee_id
WHERE k.room IN ('CEO Office', 'Server Room')
  AND k.entry_time <= TIMESTAMP '2025-10-15 21:10'
  AND k.exit_time  >= TIMESTAMP '2025-10-15 20:40'
ORDER BY k.entry_time;
/* ------------------------------------------------------------
Insights:
1.emp_id 4 and name is David kumar at ceo office 
2.The time and the place exactly matchings 
3.we can keep him as primary suspect
/* ----------------------------------------------------------------
   STEP 3: Cross-check alibis with actual logs
   Objective:
     Find alibis (claimed locations at a specific claim_time) that are not supported by keycard logs.
   Approach:
     LEFT JOIN alibis to keycard_logs using the claim_time and claimed_location; where no matching keycard record exists -> potential false alibi.*/

SELECT a.alibi_id,a.employee_id,emp.name,a.claimed_location,a.claim_time
FROM alibis AS a
JOIN employees AS emp 
  ON a.employee_id = emp.employee_id
LEFT JOIN keycard_logs AS k
  ON k.employee_id = a.employee_id
     AND a.claim_time BETWEEN k.entry_time AND k.exit_time
     AND k.room = a.claimed_location
WHERE k.employee_id IS NULL;
 /*-----------------------------------------------------------------------------------
 Insights:
 Four employees provided alibis at 20:50 that were not supported by keycard activity.
 David Kumar claimed he was in the Server Room, but there is no Server Room entry at 20:50.he was in ceo office
 This makes David’s alibi provably false, having more suspicion on him.
----------------------------------------------------------------------------------------*/
/* -------------------------------------------------------------------------------------------
   STEP 4: Investigate suspicious calls made around 20:50–21:00
   Objective:
     Identify calls that overlap the window 20:50–21:00 (incoming or outgoing).
   Approach:
     compute call end time with DATE_ADD(call_time, INTERVAL duration_sec SECOND).
     Join caller/receiver IDs to employees for names.
-------------------------------------------------------------------------------------------------- */
SELECT c.call_id,c.caller_id,caller.name AS caller_name,c.receiver_id,receiver.name AS receiver_name,c.call_time,c.duration_sec,
       DATE_ADD(c.call_time, INTERVAL c.duration_sec SECOND) AS call_end_time
FROM calls AS c
JOIN employees AS caller   ON c.caller_id   = caller.employee_id
JOIN employees AS receiver ON c.receiver_id = receiver.employee_id
WHERE c.call_time <= '2025-10-15 21:00:00'
  AND DATE_ADD(c.call_time, INTERVAL c.duration_sec SECOND) >= '2025-10-15 20:50:00';
  /*---------------------------------------------------------------------------------------------
  Insight:
  we got only one record of call overlap that is David kumar and Alice which is 45 sec.
  he spoken with Alice in ceooffice as the time matches here .
  ----------------------------------------------------------------------------------------------*/
  /* ----------------------------------------------------------------
   STEP 5: Match evidence with movements and claims
   Objective:
     For each piece of evidence, find the last recorded person in that room before the evidence was found.
	---------------------------------------------------------------------*/
  -- Query:
WITH movements AS (
    SELECT k.employee_id,
           k.room,
           k.entry_time,
           k.exit_time,
           e.evidence_id,
           e.found_time,
           ROW_NUMBER() OVER (
               PARTITION BY e.room, e.evidence_id
               ORDER BY k.entry_time DESC
           ) AS rn
    FROM evidence AS e
    JOIN keycard_logs AS k
      ON e.room = k.room
     AND k.entry_time <= e.found_time
)
SELECT m.evidence_id,
       m.room,
       m.found_time,
       m.employee_id,
       emp.name,
       m.entry_time,
       m.exit_time
FROM movements AS m
JOIN employees AS emp 
  ON emp.employee_id = m.employee_id
WHERE m.rn = 1
ORDER BY m.evidence_id;
/*----------------------------------------------------
Insights:
Every piece of evidence was last associated with David Kumar.
Evidence #1 and #2 directly connect him to the CEO Office immediately .
Evidence #3 links back to his earlier Server Room access in the morning, which is false.
----------------------------------------------------------*/
/* ----------------------------------------------------------------
   STEP 6: Combine all findings to identify the killer
   Objective:
     Find employees who satisfy all three suspicious conditions:
       - Were in CEO Office at 20:50 (movement_match)
       - Gave an alibi at 20:50 that claims a different location (alibi_mismatch)
       - Had a call overlapping 20:50–21:00 (call_overlap)
	--------------------------------------------------------------*/
-- Query:
WITH movement_match AS (
    SELECT DISTINCT employee_id
    FROM keycard_logs
    WHERE room = 'CEO Office'
      AND '2025-10-15 20:50:00' BETWEEN entry_time AND exit_time
),
alibi_mismatch AS (
    SELECT DISTINCT employee_id
    FROM alibis
    WHERE claim_time = '2025-10-15 20:50:00'
      AND claimed_location <> 'CEO Office'
),
call_overlap AS (
    SELECT DISTINCT employee_id
    FROM (
        SELECT caller_id AS employee_id,
               call_time,
               DATE_ADD(call_time, INTERVAL duration_sec SECOND) AS call_end
        FROM calls
        UNION ALL
        SELECT receiver_id AS employee_id,
               call_time,
               DATE_ADD(call_time, INTERVAL duration_sec SECOND)
        FROM calls
    ) AS c
    WHERE call_time <= '2025-10-15 21:00:00'
      AND call_end >= '2025-10-15 20:50:00'
)
SELECT e.name AS killer
FROM employees AS e
JOIN movement_match AS mm  ON e.employee_id = mm.employee_id
JOIN alibi_mismatch AS am ON e.employee_id = am.employee_id
JOIN call_overlap AS co   ON e.employee_id = co.employee_id;
/*-------------------------------------------------------------------------
Insights:
As all the three conditions like location,alibis false,call overlaps are succesfully meet by one person that is David Kumar  
The CEO of TechNova Inc. has been found dead in their office on October 15, 2025, at 9:00 PM was killed by David Kumar.
we found the killer that is David Kumar
---------------------------------------------------------------------------*





