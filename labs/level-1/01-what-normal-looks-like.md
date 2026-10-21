# Lab 1: What normal looks like

**Level:** 1, Basics
**Time:** about 45 minutes
**You need:** the lab computer from [Before you start](00-setup.md)

## The story

Nothing has gone wrong at Rimeport yet. Before anything does, your team lead
asks you to learn what a normal day looks like on Dana's computer,
**WS-DSP-01**.

> "You can't spot strange until you know normal."

## What you'll learn

- Where Windows writes down who signed in.
- How to read one sign-in record.
- That most sign-ins on a computer aren't people. They're Windows itself.

## Words you'll see

| Word | What it means |
|---|---|
| **Event log** | Windows' diary. It writes a short record every time certain things happen. |
| **Event** | One record in that diary. |
| **Event ID** | A number that says what kind of record it is. **4624** means "someone or something signed in successfully." |
| **Logon type** | A number inside a 4624 record that says *how* it signed in: at the keyboard, by unlocking, as a background service, and so on. |

---

## Part 1: Make some "normal" (10 minutes)

Before starting, put WS-DSP-01 back to its clean state: in VMware, open the
**VM** menu, choose **Snapshot**, then **Revert to Snapshot**. Then power the
VM on.

Do the following, and **write down the time of each step on paper.** Your
notes are your answer key: you know exactly what happened because you did it.

| # | Do this | Time you did it |
|---|---|---|
| 1 | Sign in as **dana** with your password | |
| 2 | Lock the screen: click **Start**, click **dana** at the bottom left, then **Lock** | |
| 3 | Wait 1 minute, then unlock it with your password | |
| 4 | Restart: **Start**, **Power**, **Restart** | |
| 5 | Sign in again as **dana** | |

> Don't use the **Windows key + L** shortcut to lock. Inside a VM window it can
> lock your *real* computer instead.

## Part 2: Is Windows writing any of this down? (5 minutes)

Not every computer records sign-ins. Recording is a setting, so check it first.

1. In the VM, right-click **Start** and choose **Terminal (Admin)**. Click
   **Yes** if Windows asks.
2. Type this and press Enter:

   ```
   auditpol /get /subcategory:"Logon"
   ```

3. Look at the line that says **Logon**. It should say **Success**, or
   **Success and Failure**.

If it says **No Auditing**, Windows isn't recording sign-ins and Part 3 will
come up empty. That's a real finding too: you'd have no evidence if something
happened. Note it down and tell your team lead (or open an issue on this repo).

## Part 3: Find your sign-ins in the log (20 minutes)

### Open the log

1. In the VM, right-click **Start** and choose **Event Viewer**.
2. On the left, open **Windows Logs** and click **Security**.

You'll see a long list. That's normal, and it's partly the point of this lab.

### Show only sign-ins

1. On the right, click **Filter Current Log...**
2. Click in the box that says **<All Event IDs>**, type **4624**, and click
   **OK**.

Now every line is a successful sign-in.

### Read one record

Click any line. The bottom half shows the record in words. Scroll down and find
these two parts:

```
Logon Information:
    Logon Type:        2            ← HOW it signed in

New Logon:
    Account Name:      dana         ← WHO signed in
```

Those two lines are most of what you need today.

**Common logon types**

| Number | Means |
|---|---|
| **2** | Someone signed in at the keyboard |
| **5** | Windows started a background service |
| **7** | Someone unlocked a locked screen |
| **10** | Someone signed in over Remote Desktop |

Times in the list are shown in this computer's own time zone.

---

## Questions

Write your answers next to your notes from Part 1.

1. Find both of your sign-ins (steps 1 and 5). What **Logon Type** do they
   show? Do the times match what you wrote down?
2. Find your unlock (step 3). What **Logon Type** does it show?
3. Find a sign-in that **wasn't you**. What's the **Account Name**?
4. Roughly how many 4624 records appeared after your restart? You signed in
   once, so why are there so many?
5. In three sentences, write what a normal sign-in to WS-DSP-01 looks like.
   Keep this, because Lab 2 uses it.

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- The newest records are at the top. Use the times from your notes to jump to
  the right place.
- For question 3, look at the **Account Name** under **New Logon**, not under
  **Subject**.
- For question 4, you don't need an exact number. Scroll and estimate.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

**1. Logon Type 2.** You were at the keyboard. The time should match your
notes to within a minute.
*If you see **10** instead:* you connected with Remote Desktop rather than
signing in through the VMware window. Use the VMware window for this lab.

**2. Usually Logon Type 7, "Unlock."** If yours shows something else, write
down what you saw. On *this* computer, that's what normal looks like. That's
the whole idea of the lab.

**3. You'll find accounts that aren't people.** The most common one is
**SYSTEM**, usually with Logon Type **5**: Windows starting its own background
services. You'll probably also see names starting with **DWM-** or **UMFD-**.
Those are parts of Windows that draw your screen and handle fonts, and they
start every time someone signs in.

**4. Lots, maybe dozens.** Windows and its services sign in all the time. Only
a few records were *you*. That's the most important lesson here: **most
sign-ins on a computer aren't people.** When you hunt for something bad later,
you'll be looking for one strange line among many normal ones.

**5. Something like:** "Dana signs in at the keyboard (type 2) during her
shift. She locks and unlocks her screen (type 7). Everything else is Windows
signing itself in (SYSTEM, type 5, plus DWM and UMFD accounts)."

</details>

---

## What you learned

- Windows keeps a **Security** event log, and **4624** means a successful
  sign-in.
- **Logon Type** tells you *how*, and **Account Name** tells you *who*.
- Recording sign-ins is a **setting**, so always check that it's on.
- Normal is noisy. Most sign-ins are Windows, not people.

**Compare notes:** [Shreyas's notes from his own run](../../notes/level-1/01-what-normal-looks-like.md).
Spoilers, so finish the lab first.

**Next:** Lab 2, "Someone is guessing passwords." Coming soon.

## Sources

- Microsoft, "4624(S): An account was successfully logged on" (logon types and
  field meanings): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
