# Lab 4: Something runs at startup

**Level:** 1, Basics
**Time:** about 45 minutes
**You need:** WS-DSP-01 and your notes from [Lab 3](03-a-new-account-appeared.md)

## The story

Dana says her computer "does something" every time she signs in. A black
window flashes up for a moment, then disappears. Nobody in IT installed
anything new.

Your team lead asks: **is something set up to run every time someone signs
in? If so, what is it, who set it up, and when?**

## What you'll learn

- A **scheduled task** can make a program run at every sign-in or restart.
  Attackers use this to stay on a computer after it reboots.
- Creating a scheduled task leaves its own record: event **4698**.
- That record holds the **whole task**: what it runs, when, and who made it.
- How to prove a task actually ran, not just that it exists.
- Deleting a task doesn't delete the trail: event **4699** keeps a copy.

## Words you'll see

| Word | What it means |
|---|---|
| **Scheduled task** | A job Windows runs by itself: at a set time, at startup, or when someone signs in. |
| **Task Scheduler** | The Windows app that lists every scheduled task on the computer. |
| **Trigger** | *When* a task runs, such as "at log on". |
| **Action** | *What* a task runs, such as a program and its arguments. |
| **Persistence** | Anything that lets an attacker's program survive a restart. |
| **4698** | The event ID for "a scheduled task was created." |
| **4699** | The event ID for "a scheduled task was deleted." |

## Keep notes like a responder

Copy the [notes template](notes-template.md) and write times as you go. Take
a screenshot wherever you see 📸, numbered in the order the lab asks:
`lab4-1.png`, `lab4-2.png`, and so on. **Export the records** before you clean
anything up.

> **Don't clear the Security log.** Lab 3 showed why: clearing it can erase
> the very record you need later.

---

## Part 1: Start clean, and check Windows is recording (10 minutes)

Put WS-DSP-01 back to its clean state first, so the setting you change below
isn't undone: **VM → Snapshot → Revert to Snapshot**. Power it on and sign in
as Dana.

Scheduled tasks are recorded by a different audit setting from the one you
checked in Lab 3, and it may well be off.

1. Right-click **Start** and choose **Terminal (Admin)**. Click **Yes**.
2. Type:

   ```
   auditpol /get /subcategory:"Other Object Access Events"
   ```

3. If it says **No Auditing**, turn it on, then run the command from step 2
   again to check:

   ```
   auditpol /set /subcategory:"Other Object Access Events" /success:enable
   ```

📸 **Screenshot 1:** the result after it says **Success**. Save it as
`lab4-1.png`. Write down what it said *before* you changed it, too.

**Why this matters:** Microsoft's audit-policy table lists no Windows default
for this setting, so on many computers nobody ever turned it on. If it was off
when an attacker made a task, there is no 4698 to find. The task itself would
still be sitting in Task Scheduler, though, and that's evidence too.

## Part 2: Play the intruder (10 minutes)

Stay in **Terminal (Admin)**. Write down every time.

| # | Do this | Time |
|---|---|---|
| 1 | Note the time, then create the task: <br>`schtasks /create /tn "PrintDriverUpdate" /tr "cmd.exe /c echo Lab 4 task ran >> C:\Users\Public\lab4-proof.txt" /sc onlogon /rl highest /f` | |
| 2 | Check it's there: <br>`schtasks /query /tn "PrintDriverUpdate"` | |
| 3 | Restart the VM: **Start**, **Power**, **Restart** | |
| 4 | Sign in as Dana and note the time. Watch the screen as you sign in. | |
| 5 | Open **File Explorer** and go to `C:\Users\Public`. Is `lab4-proof.txt` there? Open it. | |

> The task only writes one line to a text file each time someone signs in.
> You'll delete it at the end. The name *PrintDriverUpdate* is made up to look
> like something IT would install, the same trick as *svc-backup2* in Lab 3.

What the command means: `/sc onlogon` runs it whenever anyone signs in,
`/rl highest` runs it with the highest rights the account has, and `/tr` is
the program it runs.

📸 **Screenshot 2:** `lab4-proof.txt` open, with the folder showing its
**Date modified**. Save it as `lab4-2.png`.

## Part 3: Find it (20 minutes)

### Where it lives: Task Scheduler

1. Click **Start**, type **Task Scheduler**, and open it.
2. In the left pane, click **Task Scheduler Library**, the top folder.
3. Find **PrintDriverUpdate** in the list. Notice where it sits: in the top
   folder itself, not inside one of the folders below it.
4. Click it, then look at the tabs at the bottom: **General** (who it runs
   as, and whether "Run with highest privileges" is ticked), **Triggers**
   (when), and **Actions** (what).

📸 **Screenshot 3:** the **Actions** or **Triggers** tab for the task. Save it
as `lab4-3.png`.

While you're here, look at the right-hand pane. Does it offer **Enable All
Tasks History** or **Disable All Tasks History**? That tells you whether Task
Scheduler is keeping its own history of runs on this computer. Write down which
one you see. Don't change it.

### When, and by whom: 4698

1. Open **Event Viewer**, then **Windows Logs**, then **Security**.
2. Click **Filter Current Log...**, type **4698**, and click **OK**.
3. Click the record from your step 1 and scroll down in the bottom half.

```
Subject:
    Account Name:    Dana                   ← WHO created it
    Logon ID:        0x....                 ← WHICH sign-in they used

Task Information:
    Task Name:       \PrintDriverUpdate     ← WHAT (the \ means the top folder)
    Task Content:    <?xml ...              ← the whole task, written out
```

**Task Content** is one long block of text. Look inside it for these parts:

- `<Author>`: the account that made it
- `<LogonTrigger>`: the *when*, at sign-in
- `<RunLevel>`: the rights it runs with
- `<Command>` and `<Arguments>`: the *what*

📸 **Screenshot 4:** the 4698 record with **Subject** and the start of **Task
Content** visible. Save it as `lab4-4.png`.

### Did it actually run?

A task that exists isn't proof that it ran. You already have one piece of
evidence: the proof file. Get a second one from Windows itself. In **Terminal
(Admin)**, type:

```
schtasks /query /tn "PrintDriverUpdate" /v /fo list
```

Find **Last Run Time** and **Task To Run**. Does the last run time match the
time you signed in after the restart?

📸 **Screenshot 5:** that output, with **Last Run Time** visible. Save it as
`lab4-5.png`.

### Export the evidence

Set the filter to **4624,4698-4702** and use **Save Filtered Log File As...**.
Name it `lab4-startup-task.evtx` and drag it to your real computer.

## Part 4: Clean up, then look again (5 minutes)

1. In **Terminal (Admin)**, delete the task and note the time:
   `schtasks /delete /tn "PrintDriverUpdate" /f`
2. Delete `C:\Users\Public\lab4-proof.txt`.
3. In Event Viewer, click **Refresh** and filter for **4698,4699**.

**Is the creation still in the log?** Click the new **4699** record. Microsoft
documents that its **Task Content** is the full task that was deleted. Is it
the same as in the 4698?

📸 **Screenshot 6:** the 4699 record. Save it as `lab4-6.png`.

---

## Questions

Write your answers in your notes. For each answer, say where you found it.

1. What was set up to run, what's it called, and where does it sit in Task
   Scheduler? Why might that place stand out?
2. When was it created, and by which account? What does the record prove, and
   what can't it prove?
3. What does it run, when, and with what rights? Quote the parts of **Task
   Content** that tell you.
4. Did it actually run after the restart? Give two separate pieces of
   evidence.
5. After you deleted it, what did the log still show? Write two sentences for
   your team lead: who, what, when.

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- Use the times from your notes to jump to the right place.
- In 4698 and 4699, **Subject** is the account that *did* it. The task's own
  details are in **Task Content**.
- For question 4, one piece of evidence is a file and the other comes from
  Windows itself.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

**1. A task named PrintDriverUpdate, in the top folder of the Task Scheduler
Library.** Most of Windows' own tasks live in folders underneath. Microsoft's
guidance for event 4698 says tasks made by hand or by malware are often in
that top folder, so a task there is worth a closer look.

**2. At the time of your step 1, by Dana's account.** The 4698 **Subject** and
the `<Author>` in **Task Content** both name it. Same lesson as Labs 2 and 3:
the log shows the *account*, not the *person*.

**3. It runs `cmd.exe` with the arguments that write a line to
`lab4-proof.txt`.** It runs at every sign-in (`<LogonTrigger>`) with the
highest rights the account has (the `<RunLevel>` line). A real attacker would
point the action at their own program instead of a text file.

**4. Yes, and you can show it two ways.** The proof file gained a line when you
signed in, and `schtasks /query /v` shows a **Last Run Time** close to your
sign-in time. Two separate sources agreeing is stronger than one.

**5. The log kept both the creation (4698) and the deletion (4699).** Microsoft
documents that the 4699 carries the deleted task's full content, so even after
it's gone you can still say exactly what it did. Something like: "Dana's account
created a task called PrintDriverUpdate at 10:12 that ran a command at every
sign-in. It ran at 10:15 after a restart and was deleted at 10:40."

</details>

---

## What you learned

- A scheduled task with a sign-in or startup trigger is a simple way to
  survive a restart. That's **persistence**.
- Task creation is **4698** and deletion is **4699**, but only if "Other Object
  Access Events" auditing is on.
- **Task Content** is the whole task: author, trigger, rights and action.
- A task existing isn't proof it ran. Look for the run itself.
- A name can look official and still be the problem. Check what a task *does*,
  not what it's called.

**Compare notes:** the author's notes from his own run will be added after he
runs this lab.

**Next:** [Lab 5: Write it up](05-write-it-up.md).

## Sources

- Microsoft, "4698(S): A scheduled task was created" (fields, Task Content, and the monitoring advice about tasks in the root folder): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4698>
- Microsoft, "4699(S): A scheduled task was deleted" (Task Content holds the deleted task): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4699>
- Microsoft, "Audit Other Object Access Events" (which events it generates): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/audit-other-object-access-events>
- Microsoft, "System Audit Policy recommendations" (no Windows default listed for this subcategory): <https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/audit-policy-recommendations>
- Microsoft, "schtasks create" (`/sc onlogon`, `/rl highest`, `/tr`, and the verbose query fields): <https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-create>
- MITRE ATT&CK, "Scheduled Task/Job: Scheduled Task" (T1053.005, used for persistence): <https://attack.mitre.org/techniques/T1053/005/>
