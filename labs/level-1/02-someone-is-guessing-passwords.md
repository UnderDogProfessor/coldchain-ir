# Lab 2: Someone is guessing passwords

**Level:** 1, Basics
**Time:** about 45 minutes
**You need:** WS-DSP-01 and your notes from [Lab 1](01-what-normal-looks-like.md)

## The story

Dana comes back from lunch. Her screen says her password was wrong several
times while she was away, but she didn't type anything.

Your team lead asks: **did someone try to guess Dana's password?** If so,
when, how many times, from where, and did they get in?

## What you'll learn

- Failed sign-ins have their own record: event **4625**.
- How to read *which* account was tried, *why* it failed, and *from where*.
- How to tell an honest typo from someone guessing.
- Why you save evidence **before** you clean anything up.

## Words you'll see

| Word | What it means |
|---|---|
| **4625** | The event ID for "an account failed to sign in." |
| **Failure Reason** | The plain-words reason in a 4625 record, such as a bad password. |
| **Sub Status** | A code that says more exactly why it failed. |
| **Source Network Address** | Where the attempt came from. `127.0.0.1` means "this computer itself." |
| **Export** | Saving log records to a file so you keep them even if the computer is wiped. |

## Keep notes like a responder

Same as Lab 1: copy the [notes template](notes-template.md) into a new
`lab-2` folder on your real computer, write down times as you go, and take a
screenshot wherever you see 📸.

**New habit: export the records.** In Event Viewer, **Save Filtered Log File
As...** saves exactly the records you're looking at into an `.evtx` file that
anyone can open later. A screenshot shows a record; an export *is* the record.

---

## Part 1: Save the evidence you already have (10 minutes)

**Don't revert your snapshot yet.** If you typed a wrong password during
Lab 1, that record is still in the log. Reverting the snapshot would erase it
for good. Responders call this **preserving evidence**: collect first, clean
up later.

1. In the VM, open **Event Viewer**, then **Windows Logs**, then **Security**.
2. Click **Filter Current Log...**, type **4625**, and click **OK**.
3. Did you find any? If you typed a wrong password in Lab 1, there should be
   one at that time.
4. Click it and note the **time**, the **Account Name** (under **Account For
   Which Logon Failed**), and the **Failure Reason**.
5. Export it: **Save Filtered Log File As...**, name it `lab2-old-typo.evtx`,
   then drag the file out of the VM window onto your real computer.

📸 **Screenshot:** the record. Save it as `lab2-old-typo.png`.

**Found nothing?** That's fine. It means you didn't make a typo in Lab 1.
Carry on to Part 2.

## Part 2: Play the guesser (10 minutes)

Now put WS-DSP-01 back to its clean state: **VM → Snapshot → Revert to
Snapshot**, then power it on.

You'll play two people: the **guesser** sitting at Dana's desk, and then
**Dana** coming back. Write down every time.

| # | Do this | Time |
|---|---|---|
| 1 | As Dana, sign in with the right password | |
| 2 | Lock the screen: **Start**, **Dana**, **Lock** | |
| 3 | As the guesser, type **5 wrong passwords** in a row, such as `Password1`, `Summer2026`, `Rimeport1`, `Dispatch1`, `Welcome1` | first: &nbsp; last: |
| 4 | Wait 2 minutes while Dana walks back | |
| 5 | As Dana, unlock with the right password | |

> **Stop at 5.** Many computers lock an account after too many wrong tries
> in a row (Microsoft recommends 10), and you don't want to lock Dana out.

## Part 3: Find the guesses (15 minutes)

### See the whole story in one list

1. In Event Viewer, click **Refresh**, then **Filter Current Log...**
2. This time type **4624,4625** (with the comma) and click **OK**.

Now successes and failures sit together, in time order. Find your guesses
and Dana's unlock.

📸 **Screenshot:** the list showing the failures and the unlock after them.
Save it as `lab2-guesses.png`.

### Read one failed sign-in

Click one of the 4625 records. Scroll down and find these parts:

```
Logon Type:                 2                  ← HOW they tried (at the keyboard)

Account For Which Logon Failed:
    Account Name:           Dana               ← WHO they tried

Failure Information:
    Failure Reason:         (a plain-words reason)
    Sub Status:             0xC000006A         ← WHY, more exactly

Network Information:
    Workstation Name:       WS-DSP-01
    Source Network Address: 127.0.0.1          ← FROM WHERE
```

**What the Sub Status codes mean**

| Sub Status | Means |
|---|---|
| `0xC000006A` | The account is real, but the password was wrong |
| `0xC0000064` | That account doesn't exist |
| `0xC0000234` | The account is locked out |

📸 **Screenshot:** one failed record with these parts visible. Save it as
`lab2-one-guess.png`.

**Export the evidence:** with the **4624,4625** filter still on, use **Save
Filtered Log File As...**, name it `lab2-guesses.evtx`, and drag it to your
real computer.

---

## Questions

Write your answers in your notes. For each answer, say where you found it.

1. How many failed sign-ins did the guesser make, and how long from the first
   to the last?
2. Which account were they trying? What does the **Sub Status** tell you about
   that account?
3. Where did the guesses come from? In a 4625 record, write down the
   **Logon Type**, **Workstation Name** and **Source Network Address**
   exactly as they appear (`127.0.0.1` means "this computer itself"). Then say
   in one sentence whether the guesser was at this computer's keyboard or
   somewhere else on the network.
4. Compare your Lab 1 typo (if you had one) with the guesses in Part 2. Write
   a rule of thumb, in your own words, for telling a typo from guessing.
5. When was Dana's next successful sign-in after the guesses? Can the log
   prove it was really Dana who typed it?

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- Use the times from your notes to jump to the right place in the list.
- For question 2, the account that was tried is under **Account For Which
  Logon Failed**, not under **Subject**.
- For question 5, think about what Windows actually checks when someone signs
  in.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

**1. Five, and your times will vary.** Both the count and the timing matter.
In the author's run the five guesses were spread over about 4 minutes 40
seconds, because he typed slowly and checked the screen between tries. A
person typing takes seconds to minutes per try. Guessing *programs* can try
many times a second, which is something to watch for in later labs.

**2. Dana. `0xC000006A` means the account is real and only the password was
wrong.** So the guesser already knew Dana's account name. If you saw
`0xC0000064`, they'd be guessing account names too.

**3. From this computer itself.** Logon Type **2** means at the keyboard, and
`127.0.0.1` with Workstation **WS-DSP-01** means the attempt came from this
same machine. Someone was physically at Dana's desk. A guess over the network
would show a different Logon Type and another computer's address. That's a
later lab.

**4. Something like:** "One failure followed by a success within a minute is
probably a typo. Several failures in a row, close together, is guessing."
Then look at what comes **next**: a success straight after a run of failures
could mean the guess worked.

**5. At your unlock time, a few minutes after the last guess. But no, the log
can't prove it was Dana.** Windows checks the *password*, not the *person*.
Whoever typed the right password became "Dana" as far as the log is
concerned. That's why responders also talk to people: Dana can tell you
whether she was back at her desk at that time.

</details>

---

## What you learned

- A failed sign-in is event **4625**, and the **Sub Status** says why it
  failed.
- **Logon Type** and **Source Network Address** tell you where an attempt came
  from.
- The count, the timing and **what happened next** separate a typo from
  guessing.
- The log shows **accounts**, not people.
- **Collect evidence before you clean up.** Reverting, rebooting or
  reinstalling can wipe the very records you need.

**Compare notes:** [Shreyas's notes from his own run](../../notes/level-1/02-someone-is-guessing-passwords.md).
Spoilers, so finish the lab first.

**Next:** [Lab 3: A new account appeared](03-a-new-account-appeared.md).

## Sources

- Microsoft, "4625(F): An account failed to log on" (fields, logon types, and
  status codes including `0xC000006A`, `0xC0000064` and `0xC0000234`): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4625>
- Microsoft, "4624(S): An account was successfully logged on": <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
- Microsoft KB5020282, account lockout baseline recommendation of 10 attempts: <https://support.microsoft.com/en-us/topic/kb5020282-account-lockout-available-for-local-administrators-bce45c4d-f28d-43ad-b6fe-70156cb2dc00>
