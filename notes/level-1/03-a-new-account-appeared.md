# My notes: Lab 3, A new account appeared

> ⚠️ Spoilers. Try [the lab](../../labs/level-1/03-a-new-account-appeared.md)
> first.

**Date done:**
**Lab computer:** WS-DSP-01, Windows 11 Enterprise Evaluation (build 26100), VMware Workstation

---

## Part 1: Is Windows recording account changes?

| Setting | What auditpol said |
|---|---|
| User Account Management | |
| Security Group Management | |

## Part 2: What I did as the intruder

| # | What I did | Time |
|---|---|---|
| 1 | Created svc-backup2 | |
| 2 | Added it to Administrators | |
| 3 | Checked with `net user` and `net localgroup Administrators` | |

## Part 3: What I found

| Record | Time | Subject (who did it) | Subject Logon ID | Object (who it was done to) |
|---|---|---|---|---|
| 4720 created | | | | |
| 4732 added to group | | | | |

Do the two Security IDs match? 

Other event IDs I saw next to them:

Matching sign-in (4624) for the Logon ID, Elevated Token Yes or No?

## Part 4: After cleanup

Time I deleted the account:

Is the creation still in the log? What new record appeared?

## Questions

**1. Account name and creation time?**

**2. Who created it, and what can't the record prove?**

**3. Admin rights: which record, and how do I know it's the same account?**

**4. Which sign-in did it?**

**5. After the delete, what's still in the log? Two sentences for my team lead:**

---

## What surprised me

## What didn't match the lab page

Anything here gets fixed in the lab.

## Evidence files

## Screenshots

`lab3-audit.png`, `lab3-now.png`, `lab3-created.png`, `lab3-admin-add.png`
