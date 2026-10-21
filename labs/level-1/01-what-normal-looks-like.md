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

## Keep notes like a responder

Real incident responders write down what they did and when, and they capture
what they saw. Those notes become the report, and they're how someone else can
check the work. Start the habit now, in every lab.

1. **Make a notes folder on your real computer**, for example
   `Documents\Rimeport notes\lab-1\`.
2. **Copy the [notes template](notes-template.md)** into it and fill it in
   *as you go*, not afterward.
3. **Wherever you see 📸, take a screenshot** and save it in the same folder.

**How to screenshot the VM:**

1. Press **Ctrl + Alt** to give your mouse and keyboard back to your real
   computer.
2. Press **Windows key + Shift + S** and drag a box around the VM window.
3. Click the pop-up that appears and **save** the picture into your notes
   folder. Windows usually also keeps a copy in **Pictures > Screenshots**.

> Save screenshots on your **real computer**, not inside the VM. Reverting the
> snapshot wipes everything inside the VM, screenshots included. Crop to the VM
> window so nothing personal from your real computer shows.

Want to share your notes? Put them in your own GitHub repo, the way the author
does in [`notes/`](../../notes/README.md).

---

## Part 1: Make some "normal" (10 minutes)

Before starting, put WS-DSP-01 back to its clean state: in VMware, open the
**VM** menu, choose **Snapshot**, then **Revert to Snapshot**. Then power the
VM on.

Do the following, and **write down the time of each step in your notes.** Your
notes are your answer key: you know exactly what happened because you did it.

Your first time is your **starting line**. Anything in the log before it, like
updates or an earlier try, isn't part of this run. If you forget a time, start
Part 1 again. Without times, there's nothing to check the log against.

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

📸 **Screenshot:** the `auditpol` result. Save it as `lab1-auditpol.png`.

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

📸 **Screenshot:** the filtered list. Save it as `lab1-filtered-list.png`.

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

This list comes from Microsoft's documentation. Your computer won't always
match it exactly, as Question 2 shows.

Times in the list are shown in this computer's own time zone.

---

## Questions

Write your answers in your notes. For each answer, say where you found it.

1. Find both of your sign-ins (steps 1 and 5). What **Logon Type** do they
   show? Do the times match what you wrote down?
2. Find your unlock (step 3). What **Logon Type** does it show?
3. Find a sign-in that **wasn't you**. What's the **Account Name**?
4. Roughly how many 4624 records appeared after your restart? You signed in
   once, so why are there so many?
5. In three sentences, write what a normal sign-in to WS-DSP-01 looks like.
   Keep this, because Lab 2 uses it.

📸 **Screenshots:** for questions 1 to 3, capture the record that proves your
answer, with **Logon Type** and **Account Name** visible:
`lab1-q1-signin.png`, `lab1-q2-unlock.png`, `lab1-q3-not-me.png`.

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- The newest records are at the top. Use the times from your notes to jump to
  the right place.
- For question 2, look at your **unlock** time, not your lock time. Locking
  doesn't create a sign-in record, because nobody signs in when you lock.
- For question 3, look at the **Account Name** under **New Logon**, not under
  **Subject**.
- For question 4, you don't need an exact number. Scroll and estimate.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

**1. Logon Type 2.** You were at the keyboard. The time should match your
notes to within a minute.

You'll probably see **two** records for your account in the same second. Look
at **Elevated Token**: one says **Yes** and the other **No**. Each one's
**Linked Logon ID** points at the other's **Logon ID**. That's still one
sign-in. Because dana is an administrator, Windows gives her two keys at once:
an everyday key, and an admin key that's only used when you approve a "Run as
administrator" prompt.

*If you see **10** instead:* you connected with Remote Desktop rather than
signing in through the VMware window. Use the VMware window for this lab.

**2. It depends, so check yours.** Microsoft's list says Logon Type **7** means
"Unlock." But on the computer this lab was tested on (Windows 11 Enterprise
Evaluation, build 26100), the unlock showed up as **Logon Type 2** in two
separate tests: a fresh pair of records for Dana, exactly like a sign-in.

Whatever yours shows, write it down. On *this* computer, that's what normal
looks like. And notice what told you it was an unlock, not a sign-in: **your
notes.** The log alone didn't say. That's why responders write down times.

**3. You'll find accounts that aren't people.** The most common one is
**SYSTEM**, usually with Logon Type **5**: Windows starting its own background
services. The **Process Name** in these records is `services.exe`, the part of
Windows that starts services.

Look right after your **restart** and you'll find a few more, in the first
second or two after Windows starts, before anyone signs in:

| Account Name | Account Domain | What it is |
|---|---|---|
| **UMFD-0**, **UMFD-1** | Font Driver Host | The part of Windows that handles fonts |
| **DWM-1** | Window Manager | The part of Windows that draws the screen |

They're Logon Type 2, the same as you, but they aren't people. That's why
you always check the **Account Name** as well as the Logon Type.

**4. Lots, maybe dozens.** Windows and its services sign in all the time. Only
a few records were *you*. That's the most important lesson here: **most
sign-ins on a computer aren't people.** When you hunt for something bad later,
you'll be looking for one strange line among many normal ones.

**5. Something like:** "Dana signs in at the keyboard (type 2) during her
shift, and each sign-in leaves a pair of records. Unlocking her screen looks
the same as signing in. Everything else is Windows signing itself in (SYSTEM,
type 5)."

</details>

---

## What you learned

- Windows keeps a **Security** event log, and **4624** means a successful
  sign-in.
- **Logon Type** tells you *how*, and **Account Name** tells you *who*.
- Recording sign-ins is a **setting**, so always check that it's on.
- Normal is noisy. Most sign-ins are Windows, not people.
- Write down what you did and when, and screenshot what you found. Notes are
  a responder's memory.

**Compare notes:** [Shreyas's notes from his own run](../../notes/level-1/01-what-normal-looks-like.md).
Spoilers, so finish the lab first.

**Next:** Lab 2, "Someone is guessing passwords." Coming soon.

## Sources

- Microsoft, "4624(S): An account was successfully logged on" (logon types and
  field meanings): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
