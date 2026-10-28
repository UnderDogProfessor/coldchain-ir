# Incident summary: new admin account and a startup task on WS-DSP-01

**Computer:** WS-DSP-01 (Dana, dispatcher, North Yard)
**Written by:** Shreyas Lipare
**Date written:** October 28, 2026, 1:15 PM
**Time zone used below:** Eastern Daylight Time (Toronto, UTC−4)

---

## What happened

Three failed sign-in attempts on Dana's account were spotted between 12:57 and
1:01 PM, followed by a successful unlock with the right password at 1:02 PM.
A minute later, Dana's account added an unusual account, svc-backup2, to the
computer and gave it administrator rights. It then set up a scheduled task,
PrintDriverUpdate, to run any time any user signs in, with the highest rights
the signed-in account has. After a restart, Dana's account signed in at 1:09 PM
and the task's proof file confirms it ran. The account and the task were both
still on the computer when I collected the evidence.

## How sure we are

The failed and successful sign-ins, the new account, its addition to the
Administrators group and the scheduled task are all in the Security log, and
the task's own file shows it ran. What the log can't show is who was at the
keyboard. It also doesn't link the guessing to the new account: the account
and the task were made by the session Dana's account started at 12:52 PM,
before the guessing, not by the 1:02 PM unlock. The timing lines up, but that
isn't proof.

## Timeline

Every line points to the record that shows it.

| Time | What happened | Evidence |
|---|---|---|
| 12:52:06 PM | Dana's account signs in (admin session `0xA5B67`) | Security log, 4624 |
| 12:55:27 PM | Dana's account turns on task auditing | Security log, 4719 |
| 12:57:17, 12:58:30, 1:01:30 PM | Three failed sign-ins to Dana's account at the keyboard: right account, wrong password | Security log, 4625 (Logon Type 2, Sub Status `0xC000006A`) |
| 1:02:09 PM | Unlocked with the right password | Security log, 4624 (Logon Type 2) |
| 1:03:10 PM | Account svc-backup2 created by session `0xA5B67` | Security log, 4720 (with 4722, 4724, 4738, 4728) |
| 1:03:20 PM | svc-backup2 added to Administrators | Security log, 4732 |
| 1:05:12 PM | Task PrintDriverUpdate created: runs `cmd.exe` at every sign-in, HighestAvailable | Security log, 4698 |
| 1:08:52 PM | Dana's account signs out for the restart | Security log, 4647, then 1100 |
| 1:09:07 PM | Computer starts | Security log, 4608 |
| 1:09:09 PM | Dana's account signs in | Security log, 4624 |
| 1:09 PM | Task runs and writes one line | `lab5-proof.txt` |

## Evidence collected

| File | What it shows |
|---|---|
| `lab5-incident.evtx` | 164 records filtered to 4624, 4625, 4698, 4720 and 4732 |
| `lab5-complete-log.evtx` | The whole Security log, 915 records, including 4719, 4647, 1100 and 4608 |
| `lab5-admins.txt` | Administrators: Administrator, Dana and svc-backup2 |
| `lab5-proof.txt` | One line, "Lab 5 task ran": the task ran once |
| `lab5-1.png`, `lab5-2.png` | Creating the account and the task |
| `lab5-3.png` | The filtered Security log |

## What we can't tell yet

- Who typed the passwords or ran the commands. The log shows Dana's account,
  not a person.
- Whether the guessing and the new account are connected. The account and the
  task came from the 12:52 PM session, not the 1:02 PM unlock.
- What else that session did. I only looked at sign-ins, account changes and
  scheduled tasks.
- The task's Last Run Time from Windows. I didn't save `lab5-task.txt`, so the
  proof file is the only evidence it ran.

## What we recommend

**Now:**

- Disable svc-backup2 and remove it from Administrators.
- Disable and delete the PrintDriverUpdate task. Its 4698 record is already
  exported.
- Reset Dana's password, and ask her where she was between 12:52 and 1:09 PM.

**Next:**

- Check other computers for an svc-backup2 account or a PrintDriverUpdate task.
- Turn on task auditing everywhere. It was off on this computer until 12:55 PM.
- Review who can sign in at Dana's desk, and whether three wrong passwords in
  four minutes should raise an alert.
