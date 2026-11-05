# Lab 6: Meet the network

**Level:** 2, A small company
**Time:** about 90 minutes
**You need:** the five machines from [Level 2 setup](00-setup.md), at their
**rimeport-ready** snapshot

> **Tested on November 4, 2026,** on the author's Rimeport network. Where the
> logs didn't match what Microsoft's documentation suggests, the answers say
> what the test run showed. If yours differs, write down what you saw.

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
`Documents\Rimeport notes\level-2\lab-6\`. Write the time, **its time zone**
and **the machine** for every step, like `10:42 ET, DC01`. Number screenshots
`lab6-1.png`, `lab6-2.png`, and so on, and save them on your real computer, not
inside a VM.

**Take screenshots from your real computer**, the same way as in
[Lab 1](../level-1/01-what-normal-looks-like.md): press **Ctrl + Alt** to get
your mouse and keyboard back, then press **Windows key + Shift + S** and drag a
box around the VM window. Don't take them inside a VM and try to copy them
out. Copying pictures out of a VM may not work, and a revert wipes anything
left inside.

**This time you're in the logs too.** Every time you sign in as `responder`,
write it down. By the end you'll see why.

## Which account, where

Every step names the machine and the account. Sign in with exactly that one.

| When you're | Sign in as |
|---|---|
| Investigating: reading logs or collecting evidence, on any machine | `RIMEPORT\responder` |
| Being Dana, on WS-DSP-01 | `RIMEPORT\dana.reyes` |
| Being Owen, on WS-FIN-01 | `RIMEPORT\owen.tran` |

**Administrator**, **itsetup** and the local **dana** were for building the
network. Don't use them unless a lab tells you to.

The sign-in screen may offer the last account used, which is often
Administrator. Don't click it. Choose **Other user** and type the full name,
with `RIMEPORT\` in front. To check who you are, run `whoami` in PowerShell.
It prints the domain and the account, like `rimeport\responder`.

**Signed in as the wrong account?** Sign out, sign in as the right one, and
write down both times. The wrong sign-in is in the logs now, and your notes
explain it.

---

## Part 1: Get ready (10 minutes)

1. Revert **all five** machines to **rimeport-ready**: for each one, **VM**,
   **Snapshot**, **Snapshot Manager**, select **rimeport-ready**, **Go To**.
2. Power on **DC01** and wait for its sign-in screen. Then **FS01**. Then
   **WS-DSP-01**, **WS-FIN-01** and **WS-IT-01**.
3. Write down the time. That's your **starting line**. Anything in the logs
   before it is setup, not this lab.

## Part 2: Check what's being written down (10 minutes)

1. Sign in to **DC01** as `RIMEPORT\responder`: choose **Other user**, not
   the Administrator tile if the screen offers one. Write down the time.
2. Right-click **Start**, open **Terminal (Admin)** or **Windows PowerShell
   (Admin)**, and run:

   ```
   whoami
   auditpol /get /category:"Account Logon"
   ```

   `whoami` should say `rimeport\responder`. If it doesn't, see **Which
   account, where**.

3. **Credential Validation**, **Kerberos Authentication Service** and
   **Kerberos Service Ticket Operations** should each say **Success and
   Failure**. You turned them on during setup.

📸 **Screenshot 1:** the `auditpol` result on DC01. Save it as `lab6-1.png`.

If any of them says **No Auditing**, the setting didn't survive. That's a real
finding: write it down, turn it back on with the `auditpol /set` commands from
[setup](00-setup.md#turn-on-the-records-level-2-needs), and after this lab,
take a new **rimeport-ready** snapshot of all five together, with every VM
off.

**Why check:** Microsoft lists **Kerberos Service Ticket Operations** as "Not
configured" by default. That's the setting behind 4769, the record that
shows which computer someone was about to use. Without it, DC01 would know
Dana signed in but not where she went next.

Leave DC01 signed in.

## Part 3: Make a normal morning (15 minutes)

Do these steps and **write down each time**. Your notes are your answer key.
Sign in with **Other user** and the full name each time.

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

Dana's morning touched three machines: **WS-DSP-01** (her computer), **DC01**
and **FS01**. You don't need WS-FIN-01 or WS-IT-01 for this part. Read each
one's own log with **Event Viewer**, the tool you used in Level 1. On each of
the three:

- Sign in as `RIMEPORT\responder` (**Other user**, then the full name) and
  **write down the time**. On DC01 you should still be signed in from Part 2.
  If you're not sure, run `whoami`.
- Right-click **Start**, open **Event Viewer**, then **Windows Logs**,
  **Security**.
- Use **Filter Current Log...** for the event IDs below. Then on the right,
  click **Find...**, type `dana.reyes`, and click **Find Next** to jump between
  her records.

### Her computer: WS-DSP-01

Filter for **4624**. Find Dana's sign-in at the time of step 1. There may be
two records in the same second. For each one, note the **Logon Type**,
**Account Name**, **Account Domain** and **Authentication Package**.

📸 **Screenshot 2:** Dana's sign-in on WS-DSP-01. Save it as `lab6-2.png`, or
as `lab6-2.1.png` and `lab6-2.2.png` if there are two records.

### The domain controller: DC01

Filter for **4768, 4769** (type both, with a comma). Then:

- Find a **4768** for `dana.reyes` close to step 1. Note the **Client
  Address**.
- Dana gets several **4769**s, each with its own **Service Name**. Find the
  one closest to the time of step 2 and note its Service Name. Note the
  Service Names on her other 4769s too.

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

On **WS-DSP-01**, **DC01** and **FS01**, still signed in as
`RIMEPORT\responder`, open an admin PowerShell window and run:

```
New-Item -ItemType Directory C:\Evidence -Force | Out-Null
wevtutil epl Security "C:\Evidence\$env:COMPUTERNAME-Security.evtx" /ow:true
Get-FileHash "C:\Evidence\$env:COMPUTERNAME-Security.evtx"
Copy-Item "C:\Evidence\$env:COMPUTERNAME-Security.evtx" \\FS01\Evidence\
```

- `wevtutil epl` saves a copy of the Security log as a file. Write down the
  time and time zone: anything after it isn't in the copy.
- `Get-FileHash` prints the file's SHA-256 fingerprint. Copy it into the
  evidence table in your notes.
- `Copy-Item` puts the copy on the Evidence share, where only IT can reach it.

📸 **Screenshot 6.1:** the hash on one of the three machines. Save it as
`lab6-6.1.png`.

### Check the copies on your computer

Sign in to **WS-IT-01** as `RIMEPORT\responder` and write down the time. Open
PowerShell and run:

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

In the same PowerShell window on WS-IT-01:

```
$evtx = (Get-ChildItem C:\Tools -Recurse -Filter EvtxECmd.exe | Select-Object -First 1).FullName
$evtx
& $evtx -d C:\Cases\lab6 --csv C:\Cases\lab6\csv --csvf lab6-security.csv
```

The first line finds EvtxECmd in `C:\Tools`, so you don't need to remember
where it is. The second prints the path, which should match your setup notes.
In the third, `-d` reads every log in the folder, and `--csv` says where to
save the result.

Then start **Timeline Explorer** the same way:

```
$tle = (Get-ChildItem C:\Tools -Recurse -Filter TimelineExplorer.exe | Select-Object -First 1).FullName
Start-Process $tle
```

In Timeline Explorer, choose **File**, **Open**, and pick
`C:\Cases\lab6\csv\lab6-security.csv`. Every row is one
record, and the **Computer** column says which machine wrote it.

1. Click the **Time Created** column title to sort by time.
2. In the empty row just under the column titles, type `dana` in the box under
   **User Name**. If nothing shows, press **Ctrl+F** and search for
   `dana.reyes` instead.

You should now see Dana's whole morning from all three machines, in time order,
in one list.

**Check which time zone it shows.** Event Viewer shows each record in the time
zone of the machine it's on. EvtxECmd's documentation says its JSON output
uses UTC, but it doesn't say which zone the CSV's **Time Created** uses. On
the test run it was UTC: Dana's sign-in at 8:41:29 PM Eastern showed as
01:41:29 the next day, five hours later (four in summer, when Eastern is on
daylight time). Check yours the same way: find Dana's sign-in on WS-DSP-01,
compare the time here with the time Event Viewer showed you in Part 4, and
write down the difference. Notice that the date can change too.

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
   step 1? Now find your own `responder` sign-in on the same machine. Is its
   Logon Type the same as Dana's?
2. On **DC01**, what **Client Address** is on Dana's 4768? Which machine has
   that address? (The table in [setup](00-setup.md#what-youll-build) tells
   you.)
3. On **DC01**, Dana has several 4769s. Which **Service Names** did you see?
   Which one matches step 2, and what does it tell you Dana was about to do?
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

- Every machine shows times in its own time zone. Setup sets them all to
  Eastern, but if one machine's times look a few hours off, run `Get-TimeZone`
  on it. If it's different, convert its times before you compare, and write
  down that you did.
- In Event Viewer, **Find...** searches only the records the filter shows.
  If it finds nothing, check the filter first.
- On DC01, Dana's records may show her name as `dana.reyes@CORP.RIMEPORT.INTERNAL`.
  That's still her.
- For question 7, remember the `Copy-Item` to `\\FS01\Evidence`. That was you
  signing in to FS01 over the network.
- Mistyped a name or password? That's in the logs too: a **4625** on the
  computer you typed it into and, for a domain account, a **4771** on DC01.
  Lab 7 is about those.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

These come from Microsoft's documentation and from the author's test run on
November 4, 2026. Times are Eastern. Wherever yours differs, yours is the
evidence: write it down.

**1. Account Domain RIMEPORT and Authentication Package Negotiate. The Logon
Type is the surprise.** **RIMEPORT** means a domain account. The local `dana`
from Level 1 would show **WS-DSP-01** as its domain, because a local account
belongs to the computer it lives on. Microsoft explains that **Negotiate**
picks Kerberos unless Kerberos can't be used.

You'd expect Logon Type **2**, which Microsoft describes as someone signing in
at this computer. On the test run, Dana's sign-in at 8:41:29 PM wasn't a 2. It
was two records in the same second:

- **Type 11**, which Microsoft calls *CachedInteractive*: signing in with
  credentials saved on the computer, without asking the domain controller.
- **Type 7**, which Microsoft calls an *unlock*, though nothing was locked.

Yet DC01 handed Dana her first ticket one second later (question 2), so DC01
was involved after all. Her second sign-in, at 8:50 PM, looked the same.

The author's own `responder` sign-ins on WS-DSP-01, at 8:52 and 9:09 PM, were
each a pair of **Type 2** records, like the administrator pairs you saw in
Level 1. `responder` is an administrator and Dana isn't. Why Dana's came out as
11 and 7 isn't confirmed. Write down what yours shows: on this network, that's
what normal looks like.

**2. `::ffff:10.20.20.11`, which is WS-DSP-01.** Microsoft lists three forms
for Client Address: a plain IPv4 address, an IPv6 address, or `::ffff:`
followed by an IPv4 address, which is IPv4 written the IPv6 way. The test run
showed the third form. The 4768's **Service Name** is **krbtgt**, the part of
DC01 that hands out first tickets.

**3. FS01$, at 8:42:49 PM on the test run.** Microsoft describes Service Name
as the account or computer the ticket was for. So DC01 knew Dana was about to
use something on FS01, and FS01 recorded her sign-in in the same second. DC01
doesn't know which folder or which file.

Her other 4769s were for **WS-DSP-01$**, at the moment she signed in, which is
a ticket for her own computer, and for **DC01$**, several times, which are
tickets for something on DC01 itself. That's why the time matters: the first
4769 you find for Dana is probably not the one for step 2.

**4. Logon Type 3, Source Network Address 10.20.20.11.** Type 3 is a network
sign-in: Dana used FS01 from her own computer. **Workstation Name** was empty
(`-`) on the test run, and the Authentication Package was **Kerberos**.
Microsoft notes that network sign-ins with Kerberos usually don't record the
workstation. On FS01 the address is how you tell which
computer she came from. And she didn't need a password, because her computer
showed FS01 the ticket DC01 had given her.

Notice what FS01 **didn't** write down: which file she opened. That needs file
auditing, which Rimeport doesn't have turned on yet. Lab 9 deals with it.

**5. The same pattern, from 10.20.20.12.** On the test run, Owen's 4768 came
from `::ffff:10.20.20.12` at 8:44:20 PM, his 4769 for **FS01$** at 8:46:06
PM, and FS01 recorded a Type 3 sign-in from 10.20.20.12 in the same second.
Which method you prefer is your call. Say why in your notes.

**6. Computers, like `WS-DSP-01$` or `FS01$`.** Microsoft notes that computer
account names end in **$**. Computers sign in to the domain and ask for
tickets all day. On the test run, between 8:30 and 9:30 PM, 83 of DC01's 138
4768 and 4769 records were for computers, about three in five. That's the
Level 1 lesson again, now across the whole network.

**7. More than you'd think.** On the test run, `responder` showed up dozens of
times in one hour: a sign-in at the keyboard of each machine, network sign-ins
to DC01 and FS01, and five failed sign-ins on WS-DSP-01 from mistyped
passwords. Each failure left a 4625 on WS-DSP-01 and a 4771 on DC01, which
Microsoft says DC01 writes when the wrong password is given. One admin
account signing in to machine after machine within a few minutes, with a few
wrong passwords along the way, looks a lot like an attacker moving between
computers. Lab 8 is about exactly that. Your notes, with times, are what
separates you from them.

**8. They should match.** If they don't, that's the most useful finding in the
lab. Work out which one is wrong and why: a filter that hid something, a
search that missed a different spelling of the name, or a column the tool
didn't fill in.

**9. Something like:** "When Dana signs in at WS-DSP-01, her computer records
her sign-in (Types 11 and 7 on the test run), and DC01 records a 4768 from her
computer's address. When
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
- **Time zones matter.** The same moment can show up hours apart on two
  machines. Check each machine's zone, and write it next to every time.
- **The logs don't always match the documentation.** Dana's sign-in wasn't
  the Type 2 you'd expect. Write down what yours shows, because that's what
  normal looks like on your network.
- Collect, fingerprint, then analyze a copy. Matching hashes prove the copy is
  the original.
- Two tools, one answer. When they agree, you can trust it more. When they
  don't, you've learned something about one of them.

**Tool bench:** add your comparison to the [tool bench](../tool-bench.md).

**Next:** Lab 7: Password spraying over the network, coming next. It adds your
Kali VM as the attacker.

## Sources

- Microsoft, "4624(S): An account was successfully logged on" (Logon Types 2,
  3, 7 and 11, Account Domain for local accounts, Source Network Address,
  Workstation Name often empty for Kerberos network sign-ins, Negotiate):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
- Microsoft, "4768(S, F): A Kerberos authentication ticket (TGT) was
  requested" (domain controllers only, Client Address formats, krbtgt,
  computer accounts end in $):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4768>
- Microsoft, "4769(S, F): A Kerberos service ticket was requested" (domain
  controllers only, Service Name is the account or computer the ticket was
  for, account shown as name@DOMAIN):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4769>
- Microsoft, "4771(F): Kerberos pre-authentication failed" (domain controllers
  only; failure code 0x18 means the wrong password was given):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4771>
- Microsoft, Advanced Audit Policy Configuration settings (Kerberos Service
  Ticket Operations "Not configured" by default):
  <https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/advanced-audit-policy-configuration>
- Microsoft, whoami (with no parameters, prints the current domain and user
  name): <https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/whoami>
- Microsoft, wevtutil (`epl` exports a log to a file, `/ow` overwrites):
  <https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil>
- Microsoft, Get-FileHash (SHA-256 by default; identical hashes mean identical
  contents): <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash>
- Eric Zimmerman's tools (EvtxECmd and Timeline Explorer):
  <https://ericzimmerman.github.io/>
- EvtxECmd on GitHub (`-d`, `--csv`, `--csvf`; maps; MIT license; JSON
  output time stamps in UTC, with no zone given for the CSV):
  <https://github.com/EricZimmerman/evtx>
- Microsoft, Get-TimeZone (shows the current time zone): <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-timezone?view=powershell-5.1>
