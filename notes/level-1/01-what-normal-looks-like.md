# My notes: Lab 1, What normal looks like

> ⚠️ Spoilers. Try [the lab](../../labs/level-1/01-what-normal-looks-like.md)
> first.

**Date done:**
**Lab computer:** WS-DSP-01, Windows 11 Enterprise Evaluation (build 26100), VMware Workstation

## Attempts

**Attempt 1:** I completely forgot to note down timestamps for when I signed
in, when I locked my screen and when I restarted the computer. Without them I
had nothing to check the log against, so I'm doing it again.

**Attempt 2 (2026-10-21):** I'll start noting timestamps right after all the
Windows updates finish and the PC restarts. Updates done, snapshot taken and
named **WS-DSP-01 Clean**, then I started the PC. Before the snapshot I set the
VM's time zone to Eastern Time (US & Canada), so the VM's clock and my own
match.

---

## Part 1: What I did

| # | What I did | Time |
|---|---|---|
| 1 | Signed in as dana | 09:50 AM Eastern (my computer's clock) |
| 2 | Locked the screen | 09:52 AM Eastern |
| 3a | Typed the wrong password by accident while unlocking | 09:54 AM Eastern |
| 3 | Unlocked it | 09:55 AM Eastern |
| 4 | Restarted (clicked Restart) | 09:57 AM Eastern |
| 5 | Signed in again after the restart | 09:58 AM Eastern |

## Part 2: Was Windows recording sign-ins?

What `auditpol` said on the **Logon** line: **Success and Failure** (checked
around 10:00 AM Eastern). I didn't change any settings, so this is the
default on a fresh install. Windows records both successful and failed
sign-ins here.

![auditpol showing Logon: Success and Failure](images/lab1-auditpol.webp)

## Part 3: My answers

Filtering the Security log to event 4624 left **153** records. I see at least
**8** of them around my 09:50 sign-in (09:50:15 to 09:50:34).

![Security log filtered to 4624](images/lab1-filtered-list.png)

### The 8 records from my 09:50 sign-in

| Time | Account Name | Logon Type | Elevated Token | Process |
|---|---|---|---|---|
| 09:50:15 | Dana | 2 | Yes | svchost.exe |
| 09:50:15 | Dana | 2 | No | svchost.exe |
| 09:50:15 | SYSTEM | 5 | Yes | services.exe |
| 09:50:20 | SYSTEM | 5 | Yes | services.exe |
| 09:50:27 | SYSTEM | 5 | Yes | services.exe |
| 09:50:28 | SYSTEM | 5 | Yes | services.exe |
| 09:50:28 | SYSTEM | 5 | Yes | services.exe |
| 09:50:34 | SYSTEM | 5 | Yes | services.exe |

The two Dana records point at each other. Logon ID `0xF2FC3` has Linked
Logon ID `0xF3008`, and `0xF3008` links back to `0xF2FC3`.

**1. My two sign-ins: logon type, and did the times match?**

First sign-in (09:50): two Dana records at 09:50:15, both Logon Type 2. That
matches my note.

**2. My unlock: logon type?**

**3. A sign-in that wasn't me: which account?**

**4. Roughly how many 4624 records after the restart, and why so many?**

**5. Normal on WS-DSP-01, in three sentences:**

---

## What surprised me

## What didn't match the lab page

Anything here gets fixed in the lab.

- The lab said DWM- and UMFD- accounts start whenever someone signs in. None
  of my eight 09:50 records were DWM or UMFD, only Dana and SYSTEM.

## Screenshots

Save them in `images/` next to this file, using the names from the lab:
`lab1-auditpol.png`, `lab1-filtered-list.png`, `lab1-q1-signin.png`,
`lab1-q2-unlock.png`, `lab1-q3-not-me.png`. Then add each one here like this:
`![What it shows](images/lab1-q2-unlock.png)`

Crop each screenshot to the VM window only.
