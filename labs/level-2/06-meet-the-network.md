# Lab 6: Meet the network

**Level:** 2, A small company
**Time:** about 90 minutes
**You need:** the five machines from [Level 2 setup](00-setup.md), at their
**rimeport-ready** snapshot

> **Not yet tested.** This lab is written but hasn't been run on the real
> network yet. If something doesn't match, write down what you saw. That's
> how the Level 1 labs got better.

## The story

Rimeport has a real network now. Before anything goes wrong, your team lead
wants you to know what a normal morning looks like across it.

> "When Dana signs in and opens the dispatch folder, which machines write it
> down? And what does each one see?"

In Level 1, one computer kept one diary. Now one sign-in gets written down in
more than one place.

## What you'll learn

- A domain sign-in is recorded on **more than one machine**.
- What the domain controller writes down (**4768** and **4769**), and what the
  file server writes down (**4624**, Logon Type **3**).
- How to tell people from computers, and **your own** footprint from everyone
  else's.
- How to collect logs and prove your copies weren't changed.
- How to get the **same answer with a second tool**: Eric Zimmerman's EvtxECmd
  and Timeline Explorer.

## Words you'll see

| Word | What it means |
|---|---|
| **Kerberos** | How Rimeport's computers check who you are. You prove yourself to DC01 once, and DC01 gives you tickets. |
| **Ticket** | A pass from DC01. Your computer shows it to another computer instead of your password. |
| **4768** | DC01 handed someone their first ticket, usually when they sign in. |
| **4769** | DC01 handed someone a ticket for one particular computer or service. |
| **Logon Type 3** | A network sign-in: someone used this computer *from another computer*, for example by opening a shared folder. |
| **Computer account** | Computers have accounts too. Their names end in **$**, like `WS-DSP-01$`. |
| **Hash** | A fingerprint of a file. Change one byte and the fingerprint changes. |

## Keep notes like a responder

Copy the [Level 2 notes template](notes-template.md) into
`Documents\Rimeport notes\level-2\lab-6\`. Write the time **and the machine**
for every step. Number screenshots `lab6-1.png`, `lab6-2.png`, and so on, and
save them on your real computer, not inside a VM.

**This time you're in the logs too.** Every time you sign in as `responder`,
write it down. By the end you'll see why.

---

## Part 1: Get ready (10 minutes)

1. Revert **all five** machines to **rimeport-ready**: for each one, **VM**,
   **Snapshot**, **Snapshot Manager**, select **rimeport-ready**, **Go To**.
2. Power on **DC01** and wait for its sign-in screen. Then **FS01**. Then
   **WS-DSP-01**, **WS-FIN-01** and **WS-IT-01**.
3. Write down the time. That's your **starting line**. Anything in the logs
   before it is setup, not this lab.

## Part 2: Check what's being written down (10 minutes)

1. Sign in to **DC01** as `RIMEPORT\responder` (on the sign-in screen, choose
   **Other user**). Write down the time.
2. Right-click **Start**, open **Terminal (Admin)** or **Windows PowerShell
   (Admin)**, and run:

   ```
   auditpol /get /category:"Account Logon"
   ```

3. **Credential Validation**, **Kerberos Authentication Service** and
   **Kerberos Service Ticket Operations** should each say **Success and
   Failure**. You turned them on during setup.

📸 **Screenshot 1:** the `auditpol` result on DC01. Save it as `lab6-1.png`.

If any of them says **No Auditing**, the setting didn't survive. That's a real
finding: write it down, turn it back on with the `auditpol /set` commands from
[setup](00-setup.md#turn-on-the-records-level-2-needs), and take a new
**rimeport-ready** snapshot of DC01 after this lab.

**Why check:** Microsoft lists **Kerberos Service Ticket Operations** as "Not
configured" by default. That's the setting behind 4769, the record that
shows which computer someone was about to use. Without it, DC01 would know
Dana signed in but not where she went next.

Leave DC01 signed in.

## Part 3: Make a normal morning (15 minutes)

Do these steps and **write down each time**. Your notes are your answer key.

| # | Machine | Do this | Time |
|---|---|---|---|
| 1 | WS-DSP-01 | Sign in as `RIMEPORT\dana.reyes` | |
| 2 | WS-DSP-01 | Open File Explorer, type `\\FS01\Dispatch` in the address bar, press Enter | |
| 3 | WS-DSP-01 | Right-click `route-plan-north-yard.csv`, **Open with**, **Notepad**. Read it, close it. | |
| 4 | WS-DSP-01 | Sign out: **Start**, **Dana**, **Sign out** | |
| 5 | WS-FIN-01 | Sign in as `RIMEPORT\owen.tran` | |
| 6 | WS-FIN-01 | Open `\\FS01\Finance` and open `invoices-october.csv` in Notepad | |
| 7 | WS-FIN-01 | Sign out | |

## Part 4: Follow Dana across three machines (30 minutes)

Dana's morning touched three machines. Read each one's own log with **Event
Viewer**, the tool you used in Level 1. On each machine:

- Sign in as `RIMEPORT\responder` if you aren't already, and **write down the
  time**.
- Right-click **Start**, open **Event Viewer**, then **Windows Logs**,
  **Security**.
- Use **Filter Current Log...** for the event IDs below. Then on the right,
  click **Find...**, type `dana.reyes`, and click **Find Next** to jump between
  her records.

### Her computer: WS-DSP-01

Filter for **4624**. Find Dana's sign-in at the time of step 1. Note the
**Logon Type**, **Account Name**, **Account Domain** and **Authentication
Package**.

📸 **Screenshot 2:** Dana's sign-in on WS-DSP-01. Save it as `lab6-2.png`.

### The domain controller: DC01

Filter for **4768, 4769** (type both, with a comma). Then:

- Find a **4768** for `dana.reyes` close to step 1. Note the **Client
  Address**.
- Find a **4769** for Dana close to step 2. Note the **Service Name**.

📸 **Screenshot 3:** Dana's 4768 on DC01. Save it as `lab6-3.png`.
📸 **Screenshot 4:** the 4769 near step 2, with **Service Name** visible. Save
it as `lab6-4.png`.

### The file server: FS01

Filter for **4624**. Find a sign-in for `dana.reyes` at the time of step 2.
Note the **Logon Type**, **Source Network Address** and **Workstation Name**.

📸 **Screenshot 5:** Dana's sign-in on FS01. Save it as `lab6-5.png`.

## Part 5: Same answer, another tool (30 minutes)

Event Viewer made you visit three machines and search each one separately.
Responders usually collect the logs first and read them all in one place. Do
that now with **EvtxECmd**, which turns event logs into a spreadsheet file
(CSV), and **Timeline Explorer**, which opens it. Both are free tools by Eric
Zimmerman, and you installed them on WS-IT-01 during setup.

### Collect the logs

On **WS-DSP-01**, **DC01** and **FS01**, still signed in as `responder`, open
an admin PowerShell window and run:

```
New-Item -ItemType Directory C:\Evidence -Force | Out-Null
wevtutil epl Security "C:\Evidence\$env:COMPUTERNAME-Security.evtx" /ow:true
Get-FileHash "C:\Evidence\$env:COMPUTERNAME-Security.evtx"
Copy-Item "C:\Evidence\$env:COMPUTERNAME-Security.evtx" \\FS01\Evidence\
```

- `wevtutil epl` saves a copy of the Security log as a file. Write down the
  time: anything after it isn't in the copy.
- `Get-FileHash` prints the file's SHA-256 fingerprint. Copy it into the
  evidence table in your notes.
- `Copy-Item` puts the copy on the Evidence share, where only IT can reach it.

📸 **Screenshot 6.1:** the hash on one of the three machines. Save it as
`lab6-6.1.png`.

### Check the copies on your computer

Sign in to **WS-IT-01** as `responder`, open PowerShell, and run:

```
New-Item -ItemType Directory C:\Cases\lab6 -Force | Out-Null
Copy-Item \\FS01\Evidence\*-Security.evtx C:\Cases\lab6\
Get-FileHash C:\Cases\lab6\*.evtx
```

Each fingerprint should match the one you wrote down on the machine it came
from. If they match, your copies are exactly what each machine saved.

📸 **Screenshot 6.2:** the three hashes on WS-IT-01. Save it as
`lab6-6.2.png`.

### Turn the logs into one timeline

Use the EvtxECmd path you wrote down during setup:

```
& "C:\Tools\EvtxECmd\EvtxECmd.exe" -d C:\Cases\lab6 --csv C:\Cases\lab6\csv --csvf lab6-security.csv
```

`-d` reads every log in the folder, and `--csv` says where to save the result.

Open **Timeline Explorer** (the other path from setup), then **File**,
**Open**, and pick `C:\Cases\lab6\csv\lab6-security.csv`. Every row is one
record, and the **Computer** column says which machine wrote it.

1. Click the **Time Created** column title to sort by time.
2. In the empty row just under the column titles, type `dana` in the box under
   **User Name**. If nothing shows, press **Ctrl+F** and search for
   `dana.reyes` instead.

You should now see Dana's whole morning from all three machines, in time order,
in one list.

📸 **Screenshot 7:** Timeline Explorer showing Dana's records from more than
one machine. Save it as `lab6-7.png`.

### Compare the two methods

Fill in the **Same answer, another tool** table in your notes, one row each
for Event Viewer and for EvtxECmd with Timeline Explorer: did it find the same
records, how long did it take, what was easy, and what was annoying?

---

## Questions

Write your answers in your notes, and say where you found each one: which
machine, which record.

1. On **WS-DSP-01**, what **Logon Type**, **Account Domain** and
   **Authentication Package** does Dana's sign-in show? Does the time match
   step 1?
2. On **DC01**, what **Client Address** is on Dana's 4768? Which machine has
   that address? (The table in [setup](00-setup.md#what-youll-build) tells
   you.)
3. On **DC01**, what **Service Name** is on the 4769 near step 2? What does it
   tell you Dana was about to do?
4. On **FS01**, what **Logon Type**, **Source Network Address** and
   **Workstation Name** does Dana's sign-in show? Dana never typed her password
   on FS01. So how did FS01 know who she was?
5. Find **Owen's** morning, using whichever method you like. Which one did you
   pick, and why?
6. On DC01, find a 4768 or 4769 whose account name ends in **$**. What is it?
   About how many of DC01's 4768 and 4769 records are people, and how many are
   computers?
7. How many times does `responder` show up across the three logs, and when?
   If you didn't have your notes, how might someone reading these logs mistake
   you for an attacker?
8. Did both methods find the same records for Dana? If not, which one missed
   something, and why?
9. In three sentences, write what a normal sign-in plus a shared folder looks
   like at Rimeport, machine by machine. Keep it, because Lab 7 uses it.

📸 For any answer that isn't already in a screenshot, capture the record that
proves it and number it from 8 on.

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- Every machine shows times in its own time zone. Setup gave them all the same
  one, so the times should line up across machines.
- In Event Viewer, **Find...** searches only the records the filter shows.
  If it finds nothing, check the filter first.
- On DC01, Dana's records may show her name as `dana.reyes@CORP.RIMEPORT.INTERNAL`.
  That's still her.
- For question 7, remember the `Copy-Item` to `\\FS01\Evidence`. That was you
  signing in to FS01 over the network.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

These come from Microsoft's documentation. They'll be checked against a real
run and updated. Wherever yours differs, yours is the evidence: write it down.

**1. Logon Type 2, Account Domain RIMEPORT.** Type 2 means she was at the
keyboard. **RIMEPORT** means a domain account. The local `dana` from Level 1
would show **WS-DSP-01** as its domain, because a local account belongs to the
computer it lives on. For **Authentication Package**, write down what yours
says. Microsoft explains that **Negotiate** picks Kerberos unless Kerberos
can't be used.

In Level 1 you saw each sign-in as a *pair* of records, because local `dana`
was an administrator. `dana.reyes` isn't an administrator, so you may see one
record instead of two. Check yours.

**2. Most likely `::ffff:10.20.20.11`, which is WS-DSP-01.** Microsoft lists
three forms for Client Address: a plain IPv4 address, an IPv6 address, or
`::ffff:` followed by an IPv4 address, which is IPv4 written the IPv6 way. If
yours starts with `fe80`, that's an IPv6 address. Write it down; the test run
will show whether that happens here. The 4768's **Service Name** is
**krbtgt**, the part of DC01 that hands out first tickets.

**3. FS01$.** Microsoft describes Service Name as the account or computer the
ticket was for. So DC01 knew Dana was about to use something on FS01, just
before she did. It doesn't know which folder or which file.

**4. Logon Type 3, Source Network Address 10.20.20.11.** Type 3 is a network
sign-in: Dana used FS01 from her own computer. **Workstation Name** is probably
empty, because Microsoft notes that network sign-ins with Kerberos usually
don't record the workstation. On FS01 the address is how you tell which
computer she came from. And she didn't need a password, because her computer
showed FS01 the ticket DC01 had given her.

Notice what FS01 **didn't** write down: which file she opened. That needs file
auditing, which Rimeport doesn't have turned on yet. Lab 9 deals with it.

**5. The same pattern, from 10.20.20.12.** Owen's 4768 comes from WS-FIN-01,
his 4769 near step 6 is for **FS01$**, and FS01 records a type 3 sign-in from
10.20.20.12. Which method you prefer is your call. Say why in your notes.

**6. Computers, like `WS-DSP-01$` or `FS01$`.** Microsoft notes that computer
account names end in **$**. Computers sign in to the domain and ask for
tickets all day. You'll probably find more computer records than people
records, which is the Level 1 lesson again, now across the whole network.

**7. More than you'd think.** You signed in to each machine at the keyboard,
and every `Copy-Item` to `\\FS01\Evidence` was a network sign-in to FS01. One
admin account signing in to machine after machine within a few minutes looks
a lot like an attacker moving between computers. Lab 8 is about exactly that.
Your notes, with times, are what separates you from them.

**8. They should match.** If they don't, that's the most useful finding in the
lab. Work out which one is wrong and why: a filter that hid something, a
search that missed a different spelling of the name, or a column the tool
didn't fill in.

**9. Something like:** "When Dana signs in at WS-DSP-01, her computer records
a type 2 sign-in, and DC01 records a 4768 from her computer's address. When
she opens `\\FS01\Dispatch`, DC01 records a 4769 for FS01$, and FS01 records a
type 3 sign-in from her computer's address. Neither DC01 nor FS01 records
which file she opened."

</details>

---

## What you learned

- One domain sign-in is written down on **several machines**, and each one sees
  a different piece.
- **DC01** sees every sign-in and every ticket, with the address it came from.
- **FS01** sees who connected and from where, but not which file they opened.
- Names ending in **$** are computers. Most records are machines, not people.
- **You** are in the logs too. Write down your own times.
- Collect, fingerprint, then analyze a copy. Matching hashes prove the copy is
  the original.
- Two tools, one answer. When they agree, you can trust it more. When they
  don't, you've learned something about one of them.

**Tool bench:** add your comparison to the [tool bench](../tool-bench.md).

**Next:** Lab 7: Password spraying over the network, coming next. It adds your
Kali VM as the attacker.

## Sources

- Microsoft, "4624(S): An account was successfully logged on" (Logon Types 2
  and 3, Account Domain for local accounts, Source Network Address, Workstation
  Name often empty for Kerberos network sign-ins, Negotiate):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
- Microsoft, "4768(S, F): A Kerberos authentication ticket (TGT) was
  requested" (domain controllers only, Client Address formats, krbtgt,
  computer accounts end in $):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4768>
- Microsoft, "4769(S, F): A Kerberos service ticket was requested" (domain
  controllers only, Service Name is the account or computer the ticket was
  for, account shown as name@DOMAIN):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4769>
- Microsoft, Advanced Audit Policy Configuration settings (Kerberos Service
  Ticket Operations "Not configured" by default):
  <https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/advanced-audit-policy-configuration>
- Microsoft, wevtutil (`epl` exports a log to a file, `/ow` overwrites):
  <https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil>
- Microsoft, Get-FileHash (SHA-256 by default; identical hashes mean identical
  contents): <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash>
- Eric Zimmerman's tools (EvtxECmd and Timeline Explorer):
  <https://ericzimmerman.github.io/>
- EvtxECmd on GitHub (`-d`, `--csv`, `--csvf`; maps; MIT license):
  <https://github.com/EricZimmerman/evtx>
