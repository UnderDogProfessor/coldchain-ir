# My notes: Lab 1, What normal looks like

> ⚠️ Spoilers. Try [the lab](../../labs/level-1/01-what-normal-looks-like.md)
> first.

**Date done:**
**Lab computer:** WS-DSP-01, Windows 11 Enterprise evaluation, VMware Workstation

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

What `auditpol` said on the **Logon** line:

## Part 3: My answers

**1. My two sign-ins: logon type, and did the times match?**

**2. My unlock: logon type?**

**3. A sign-in that wasn't me: which account?**

**4. Roughly how many 4624 records after the restart, and why so many?**

**5. Normal on WS-DSP-01, in three sentences:**

---

## What surprised me

## What didn't match the lab page

Anything here gets fixed in the lab.

## Screenshots

Save them in `images/` next to this file, using the names from the lab:
`lab1-auditpol.png`, `lab1-filtered-list.png`, `lab1-q1-signin.png`,
`lab1-q2-unlock.png`, `lab1-q3-not-me.png`. Then add each one here like this:
`![What it shows](images/lab1-q2-unlock.png)`

Crop each screenshot to the VM window only.
