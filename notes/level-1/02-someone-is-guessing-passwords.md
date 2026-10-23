# My notes: Lab 2, Someone is guessing passwords

> ⚠️ Spoilers. Try [the lab](../../labs/level-1/02-someone-is-guessing-passwords.md)
> first.

**Date done:** 2026-10-23
**Lab computer:** WS-DSP-01, Windows 11 Enterprise Evaluation (build 26100), VMware Workstation

---

## Part 1: The evidence I already had

My accidental wrong password from Lab 1 was at **09:54 AM Eastern** on
2026-10-21.

| What I looked for | What I found |
|---|---|
| 4625 record at 09:54? | Yes, at 09:54:07 AM (event 4625) |
| Account Name (Account For Which Logon Failed) | Dana |
| Logon Type | 2 |
| Failure Reason | Unknown user name or bad password. |
| Sub Status | 0xC000006A |
| Next successful sign-in for Dana after it | 10/21/2026 9:55:17 AM |

![The 4625 at 09:54:07 and the sign-in records at 09:55:17](images/lab2-old-typo.png)

## Part 2: What I did as the guesser

Done on 2026-10-23. Times are Eastern.

Before this part I saved the Security log and then cleared it, so Part 2 starts
with a fresh log (my screenshot shows 134 events in total, compared with
22,273 in the Part 1 screenshot). My attempt at about 02:27 PM was me starting
from scratch, so I'm ignoring it.

| # | What I did | Time |
|---|---|---|
| 1 | Signed in as Dana | 02:29 PM |
| 2 | Locked the screen from the Start menu | 02:30 PM |
| 3 | Typed 5 wrong passwords | 1st: 2:30 PM, 2nd: 2:30 PM, 3rd: 2:32 PM, 4th: 2:34 PM, 5th: 2:35 PM |
| 4 | Waited 2 minutes | |
| 5 | Unlocked as Dana with the right password | 02:38 PM |

## Part 3: My answers

![Security log filtered to 4624 and 4625: five failures and the records around them](images/lab2-guesses.png)

**1. How many failed sign-ins, and how long from first to last?**

5 wrong passwords, at 2:30 PM, 2:30 PM, 2:32 PM, 2:34 PM and 2:35 PM.

Exact times from my screenshot: **2:30:26, 2:30:31, 2:32:12, 2:34:17 and
2:35:05 PM**. That's 4 minutes 39 seconds from the first to the last.

**2. Which account, and what does the Sub Status say?**

All the failed logins were for the account Dana, with Sub Status 0xC000006A.

I also saw several successful logins during the time I was entering the 5
wrong passwords. All of them were Logon Type 5 and the account SYSTEM. So even
though I didn't sign in, I see these SYSTEM successful logins with Logon Type 5.

(Checked against my saved log: there are 6 of them between the first and last
guess, at 2:32:02 (three), 2:32:03, 2:32:09 and 2:34:11 PM.)

**3. Where did the guesses come from?**

(Read three fields in a 4625 record, exactly as they appear: **Logon Type** =
how they tried, 2 means at the keyboard; **Workstation Name** = which
computer; **Source Network Address** = which address, `127.0.0.1` means this
computer itself. Then answer in one sentence: at this computer's keyboard, or
somewhere else on the network. The process name isn't needed.)

- Workstation Name: WS-DSP-01
- Source Network Address: 127.0.0.1
- Logon Type: 2 (all five guesses, read from my saved log
  [evidence/lab2-complete-log.evtx](evidence/lab2-complete-log.evtx); the
  records also show Status `0xc000006d`, Sub Status `0xc000006a`, Source Port
  0 and Process `svchost.exe`)
- One-sentence answer: the guesses came from this computer itself
  (WS-DSP-01, 127.0.0.1), not from the network, and I typed them at the
  keyboard of WS-DSP-01.

**4. My rule of thumb for a typo vs. guessing:**

One failure followed by a successful sign-in about a minute later looks like a
typo (my Lab 1 typo: 1 failure, success 1 min 10 s later). Several failures in
a row, close together, before a success looks like guessing (my Part 2: 5
failures within 4 min 39 s, then a success).

*(Drafted from the table below at my request. My first note was "typo rather
keyboard hits".)*

| | Failures | Time from first to last failure | Next success |
|---|---|---|---|
| Lab 1 typo | 1 | not applicable | 1 min 10 s later (09:54:07 → 09:55:17) |
| Part 2 guesses | 5 | 4 min 39 s | 3 min 17 s later (2:35:05 → 2:38:22) |

**5. Dana's next successful sign-in, and can the log prove it was her?**

Yes. It came after my last failed login at 2:35 PM. I see 7 successful logins
(event 4624, which I first wrote as 4654) for SYSTEM with Logon Type 5 before
it. Then at **2:38:22 PM**, exactly my time, I see Logon Type 2 for Account
Name Dana, which proves my successful sign-in.

Details of that record (screenshot below): Logon Type 2, Elevated Token Yes,
Account Name Dana, Logon ID `0x1827A47`, Linked Logon ID `0x1827A75`.

Checked against my saved log: the 7 SYSTEM, Logon Type 5 records are at
2:36:39, 2:37:09 (two), 2:37:10, 2:37:11, 2:37:21 and 2:37:47 PM. At 2:38:22 PM
there is a Dana pair (Elevated Token Yes and No, linked to each other) plus one
more SYSTEM record. One thing the log can't tell me: whether the person typing
the password was really Dana. It only shows that the account's password was
typed correctly.

![The 4624 for Dana at 2:38:22 PM: Logon Type 2, Elevated Token Yes](images/lab2-unlock.png)

---

## What surprised me

In Lab 2 I saw so many successful login records that I didn't do myself. All
of them were from the account SYSTEM with Logon Type 5.

## What didn't match the lab page

Anything here gets fixed in the lab.

- The lab said the five guesses would take "about a minute". Mine took 4
  minutes 39 seconds, because I typed slowly while checking the screen. The
  lab's wording is being changed.
- The unlock at 2:38:22 PM was Logon Type 2 again, the third time I've seen an
  unlock logged as type 2 on this computer, not type 7.

## What I missed, and noticed later

After finishing, I compared my notes against my saved log. My times and counts
were right, but I missed or got wrong the things below. I'm leaving them here
so you can learn from my misses instead of repeating them.

1. **I said the log "proves my successful sign-in."** It doesn't. It proves
   that *the account's password was typed correctly*. It can't show who was
   typing. I only noticed when I re-read the lab's own question.
2. **I didn't notice the lock isn't in the log.** My 2:30 PM lock appears
   nowhere in my saved log (there are no lock or unlock events). The only
   record of it is the time I wrote down. Notes can be the only evidence for
   something that happened.
3. **I missed the fingerprint of a real sign-in.** At 2:29:30 and 2:38:22 PM
   the log has, besides the Dana pair of 4624 records, one **4648** (a sign-in
   using explicit credentials) and one **4672** (special privileges assigned,
   which is the admin key). My failed guesses left only a 4625 each. That's
   how you can tell "someone got it right" from "someone got it wrong."
4. **I didn't notice that clearing the log was itself recorded.** I cleared
   the log to start fresh, and the very first record in my saved log is event
   **1102**, "the audit log was cleared," at 2:25:27 PM. I only saw it when I
   looked for it. Clearing doesn't hide that it happened.
5. **I didn't write down the Logon Type of the guesses, or how long they
   took.** I recorded the times but didn't work out the span (4 min 39 s) or
   check the Logon Type (2). A rule of thumb needs numbers.
6. **I wrote the wrong event ID.** I typed "4654" when I meant **4624**.
   Double-check event IDs before you share them.
7. **I wrote a rule of thumb that wasn't a rule.** My first attempt was "typo
   rather keyboard hits." A better rule uses the count and the timing: one
   failure then a success a minute later looks like a typo, five failures in
   under five minutes looks like guessing.
8. **I didn't dig into the extra records.** My log has 431 events, and I only
   looked at the sign-in ones. There were 260 records of event 4799 that I
   haven't looked into. One 4798 record from `LogonUI.exe` (the sign-in
   screen) at 2:27:38 PM may be my "starting from scratch" attempt, but I'm
   not sure.

**Tip for next time:** put my notes next to the log. For each note I wrote,
write the exact log time and what the log can and can't prove.

## Evidence files

- [lab2-complete-log.evtx](evidence/lab2-complete-log.evtx): my whole Security
  log from when I cleared it until I finished the lab. 431 events, from
  2:25:27 PM to 3:09:11 PM on 2026-10-23.

**The log clear left a mark.** The very first record in the file is event
**1102**, "The audit log was cleared," at 2:25:27 PM. That's my own clear
before Part 2. Clearing a log doesn't hide that it happened.

Counts in the file: 45 successful sign-ins (4624), of which 41 are SYSTEM and
4 are Dana (two pairs: 2:29:30 PM and 2:38:22 PM), and 5 failed sign-ins
(4625). The rest are other event types, such as 4672, 4798, 4799 and 5379,
which I haven't looked into.

## Screenshots

- `lab2-old-typo.png`: the Lab 1 typo (4625 at 09:54:07 AM) and the sign-in at
  09:55:17 AM
- `lab2-guesses.png`: the five failures between 2:30:26 PM and 2:35:05 PM
- `lab2-unlock.png`: Dana's sign-in record at 2:38:22 PM
