# Lab 5: Write it up

**Level:** 1, Basics
**Time:** about an hour
**You need:** WS-DSP-01 and your notes from Labs [2](02-someone-is-guessing-passwords.md),
[3](03-a-new-account-appeared.md) and [4](04-something-runs-at-startup.md)

## The story

Over one morning, three things happened on Dana's computer: someone guessed at
her password, a new admin account appeared, and something was set to run every
time she signs in.

Your team lead has to brief the IT manager by the end of the day. The IT
manager isn't technical. Your team lead asks you for **one page: what
happened, how sure are we, and what should we do now?**

## What you'll learn

- How to turn log records into a story someone else can follow.
- How to build a **timeline** where every line points to its evidence.
- How to keep **what you know** apart from **what you can't tell**.
- How to write for a reader who doesn't know what a 4625 is.

## Words you'll see

| Word | What it means |
|---|---|
| **Timeline** | What happened, in time order, with the evidence for each step. |
| **Finding** | Something the evidence shows. |
| **Gap** | Something you can't tell from the evidence you have. |
| **Recommendation** | What you suggest doing, and why. |

## Keep notes like a responder

Same as before: copy the [notes template](notes-template.md), write times as
you go, and number screenshots `lab5-1.png`, `lab5-2.png`, and so on. This
time you'll also fill in the [report template](report-template.md).

---

## Part 1: Make one incident (15 minutes)

In Labs 2 to 4 you did each step on a different day, so your times don't
line up. This time you'll play all three in one go, so the page you write
tells one true story.

Revert WS-DSP-01: **VM → Snapshot → Revert to Snapshot**. Power it on and
sign in as Dana. Write down every time.

| # | Do this | Time |
|---|---|---|
| 1 | Open **Terminal (Admin)** and turn on task auditing (from Lab 4): <br>`auditpol /set /subcategory:"Other Object Access Events" /success:enable` | |
| 2 | Lock the screen: **Start**, **Dana**, **Lock** | |
| 3 | As the guesser, type **3 wrong passwords**, then sign in with the right one | first: &nbsp; last: |
| 4 | Open **Terminal (Admin)** and create the account: <br>`net user svc-backup2 "Lab-Only-2026!" /add` | |
| 5 | Make it an admin: <br>`net localgroup Administrators svc-backup2 /add` | |
| 6 | Create the task: <br>`schtasks /create /tn "PrintDriverUpdate" /tr "cmd.exe /c echo Lab 5 task ran >> C:\Users\Public\lab5-proof.txt" /sc onlogon /rl highest /f` | |
| 7 | Restart, sign in as Dana, and wait a minute | |

> Same rules as before: the account and the task are for this lab only, and
> you'll throw them away at the end by reverting the snapshot.

## Part 2: Collect the evidence (10 minutes)

1. In Event Viewer, filter the Security log for
   **4624,4625,4698,4720,4732**.
2. Find each of your steps from Part 1 in the list.

📸 **Screenshot 1:** the list, showing the failures, the account records and
the task record together. Save it as `lab5-1.png`.

3. Export it: **Save Filtered Log File As...**, named `lab5-incident.evtx`.
4. In **Terminal (Admin)**, save two more pieces of evidence as text files:

   ```
   net localgroup Administrators > C:\Users\Public\lab5-admins.txt
   schtasks /query /tn "PrintDriverUpdate" /v /fo list > C:\Users\Public\lab5-task.txt
   ```

5. Drag all three files (and `lab5-proof.txt`) to your real computer.

## Part 3: Write the page (30 minutes)

Copy the [report template](report-template.md) to your real computer and fill
it in. Some rules that make a page easy to trust:

- **One page.** If it doesn't fit, cut detail, not findings.
- **Plain words up top.** The first two sections are for the IT manager. Event
  IDs belong in the timeline and evidence table, not in "What happened".
- **Every timeline line points to evidence:** which log, which event ID, or
  which file.
- **Accounts, not people.** Write "Dana's account", not "Dana", unless someone
  has confirmed it was her. You learned why in Lab 2.
- **Say what you can't tell.** "We can't tell who typed the password" is a
  finding, not a failure.
- **Recommendations follow from findings.** Each one should answer something
  in your timeline or your gaps.
- **Give the time zone.** A time without one is a guess for the reader.

📸 **Screenshot 2:** your finished page. Save it as `lab5-2.png`, and keep the
page itself as `lab5-report.md` (or a PDF).

## Part 4: Clean up (5 minutes)

Once your evidence and your page are safe on your real computer, revert
WS-DSP-01 to its snapshot. That removes the account, the task and the files
in one step.

---

## Check your page

Read your page as the IT manager would, then check:

1. Could someone outside IT say, in one sentence, what happened?
2. Does every line in the timeline name its evidence?
3. Did you write "Dana's account" where you can't prove it was Dana?
4. Is there at least one honest gap in "What we can't tell yet"?
5. Does every recommendation connect to something you found?

<details>
<summary><strong>What a good page looks like</strong> (try first)</summary>

This is a shape to aim for, not the answer. Your times and wording will
differ.

**What happened.** On the morning of the lab, someone at Dana's desk tried
three wrong passwords on her account, then signed in with the right one.
Within minutes, that session created a new account called *svc-backup2*, made
it an administrator, and set up a task that runs a program every time anyone
signs in. Both the account and the task were still there when we checked.

**How sure we are.** The Security log shows every step, all from Dana's
account and the same sign-in. It can't show who was at the keyboard.

**Timeline** (a few rows):

| Time | What happened | Evidence |
|---|---|---|
| 10:02 to 10:03 | Three failed sign-ins to Dana's account, at the keyboard | Security log, 4625 |
| 10:03 | Successful sign-in to Dana's account | Security log, 4624 |
| 10:05 | Account svc-backup2 created | Security log, 4720 |
| 10:05 | svc-backup2 added to Administrators | Security log, 4732 |
| 10:06 | Task PrintDriverUpdate created, runs at every sign-in | Security log, 4698 |
| 10:09 | Task ran after a restart | `lab5-task.txt`, Last Run Time |

**What we can't tell yet.** Who was at the keyboard. What else the session did,
because this computer doesn't record which programs run.

**What we recommend.** Now: disable svc-backup2 and the task, and change Dana's
password. Next: ask Dana where she was at 10:02, and check other computers for
an account or task with the same names.

</details>

---

## What you learned

- A good write-up is a **story with receipts**: every claim points to a record.
- **Plain words** at the top, technical detail in the timeline.
- Gaps are findings. Saying what you can't tell builds trust.
- Recommendations should come straight from what you found.

That's the end of Level 1. You've read normal sign-ins, spotted guessing,
traced a new admin account, found something that survives a restart, and
written it all up.

**Compare notes:** the author's page from his own run will be added after he
runs this lab.

**Next:** Level 2, "A small company", is coming later.

## Sources

This lab adds no new technical claims. The event IDs and commands it uses are
sourced in [Lab 2](02-someone-is-guessing-passwords.md#sources),
[Lab 3](03-a-new-account-appeared.md#sources) and
[Lab 4](04-something-runs-at-startup.md#sources).
