# My notes: Lab 3, A new account appeared

> ⚠️ Spoilers. Try [the lab](../../labs/level-1/03-a-new-account-appeared.md)
> first.

**Date done:**
**Lab computer:** WS-DSP-01, Windows 11 Enterprise Evaluation (build 26100), VMware Workstation

Screenshots are numbered in the order the lab asks for them (`lab3-1.png`,
`lab3-2.png`, ...). Each one sits under the part where the lab first asks for
it.

---

## Part 1: Is Windows recording account changes?

| Setting | What auditpol said |
|---|---|
| User Account Management | |
| Security Group Management | |

📸 Screenshot 1 (`lab3-1.png`): both auditpol results

## Part 2: What I did as the intruder

| # | What I did | Time |
|---|---|---|
| 1 | Created svc-backup2 | |
| 2 | Added it to Administrators | |
| 3 | Checked with `net user` and `net localgroup Administrators` | |

📸 Screenshot 2 (`lab3-2.png`): svc-backup2 in the Administrators list

## Part 3: What I found

| Record | Time | Subject (who did it) | Subject Logon ID | Object (who it was done to) |
|---|---|---|---|---|
| 4720 created | | | | |
| 4732 added to group | | | | |

📸 Screenshot 3 (`lab3-3.png`): the 4720 record

📸 Screenshot 4 (`lab3-4.png`): the 4732 record

Do the two Security IDs match? 

Other event IDs I saw next to them:

📸 Screenshot 5 (`lab3-5.png`): the neighboring records

Matching sign-in (4624) for the Logon ID, Elevated Token Yes or No?

📸 Screenshot 6 (`lab3-6.png`): the matching 4624 record

## Part 4: After cleanup

Time I deleted the account:

Is the creation still in the log? What new record appeared?

📸 Screenshot 7 (`lab3-7.png`): the list after the delete

## Questions

**1. Account name and creation time?**

**2. Who created it, and what can't the record prove?**

**3. Admin rights: which record, and how do I know it's the same account?**

**4. Which sign-in did it?**

**5. After the delete, what's still in the log? Two sentences for my team lead:**

---

## What surprised me

## What I missed, and noticed later

Compare my notes with my saved log after finishing, and write down what I
missed, so readers can learn from it.

## What didn't match the lab page

Anything here gets fixed in the lab.

## Evidence files

## Screenshots

| # | File | What it shows |
|---|---|---|
| 1 | `lab3-1.png` | auditpol results |
| 2 | `lab3-2.png` | svc-backup2 in Administrators |
| 3 | `lab3-3.png` | 4720, account created |
| 4 | `lab3-4.png` | 4732, added to group |
| 5 | `lab3-5.png` | neighboring records |
| 6 | `lab3-6.png` | matching 4624 |
| 7 | `lab3-7.png` | after the delete |
