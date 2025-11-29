# capstoneproject_sql
SQL Murder Mystery: “Who Killed the CEO?
## **1. Story / Background**
The CEO of **TechNova Inc.** has been found dead in their office on **October 15, 2025, at 9:00 PM**.
You are the **lead data analyst** tasked with solving this case using SQL. All the clues you need are hidden in the company’s databases:
- Keycard logs
- Phone call records
- Alibis
- Evidence found in different rooms
Your mission is simple but challenging:
👉 **Find out who the killer is, where and when the crime took place, and how it happened — using only SQL queries.**
## 2. Database Schema & Dataset
tables:
1.employees:employee_id, name, department, role
2.keycard_logs: log_id, employee_id, room, entry_time, exit_time 
 3.calls: call_id, caller_id, receiver_id, call_time, duration_sec 
4.alibis: alibi_id, employee_id, claimed_location, claim_time
5.evidence: evidence_id, room, description, found_time
## 3.Investigation Objectives
1.Identify where and when the crime happened
2.Analyze who accessed critical areas at the time
3.Cross-check alibis with actual logs
4.Investigate suspicious calls made around the time
5.Match evidence with movements and claims
6.Combine all findings to identify the killer
## 4 Hints
- Use `WHERE` and `BETWEEN` to filter logs.
- Use `JOIN` to connect tables like `employees` and `keycard_logs`.
- Compare **claimed locations** with **actual locations** to find lies.
- Look for **unusual access patterns** and **timing overlaps**.
- Cross-check **evidence** to narrow down suspect.
## **5. Expected Deliverables**
By the end of this mystery, you should submit:
- ✅ SQL queries for each investigation step
- 📝 A final **“Case Solved”** query that reveals the killer in below single column table format
