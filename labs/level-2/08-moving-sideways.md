# Lab 8: Moving sideways

**Level:** 2, A small company
**Time:** about 90 minutes
**You need:** the five machines at their **rimeport-ready** snapshot, your
Kali VM, and your notes from [Lab 6](06-meet-the-network.md) and
[Lab 7](07-password-spraying.md)

> **Not yet tested.** This lab is written but hasn't been run on the real
> network yet. Where it says what a record "should" show, that comes from
> Microsoft's and the tools' documentation and from the Lab 6 and Lab 7 runs.
> If yours differs, write down what you saw.

## The story

In Lab 7, an attacker at `10.20.99.50` sprayed one password at Rimeport and
got into Luis Ferreira's account. Priya has reset nothing yet. She asks:

> "They had Luis's password. Where did they go with it, and what could they
> see?"

First you play the attacker again, using Luis's account to look around. Then
you follow that one account across Rimeport's machines.

## What you'll learn

- A stolen password makes **successful** sign-ins (**4624**), not failures.
  The attacker looks like Luis.
- How to follow **one account** across machines: the account name, the
  address it came from, and the time.
- What an ordinary user's account can see on a domain: shared folders, and
  the list of everyone's accounts.
- How to tell the attacker's use of Luis's account from a real Rimeport PC's,
  using what you learned in Labs 6 and 7.
- What the logs **don't** show yet: which shared folders were opened.

## Words you'll see

| Word | What it means |
|---|---|
| **Moving sideways** | Using an account you already have to reach more machines and more data. Responders call it lateral movement. |
| **Share** | A shared folder, like `\\FS01\Dispatch`. |
| **NETLOGON** and **SYSVOL** | Shared folders on the domain controller. Every Rimeport machine reads from them: your readiness check runs from NETLOGON. |
| **`Pwn3d!`** | What NetExec prints when the account it used is most likely an administrator on that machine. |
| **Kerberos** and **NTLM** | Two ways Windows checks who you are. Rimeport's PCs use Kerberos with DC01 (Lab 6). The attacker's tool used NTLM (Lab 7). |

> **Before you start,** read [Things to remember](quick-reference.md#things-to-remember)
> in the quick reference. Each item there came from a real run going wrong:
> the wrong account, a typo in a command, a missing time zone, a screenshot
> that was never saved.

## Keep notes like a responder

Copy the [Level 2 notes template](notes-template.md) into
`Documents\Rimeport notes\level-2\lab-8\`. Write the time, its time zone and
the machine for every step, including every command you run on Kali. Number
screenshots `lab8-1.png`, `lab8-2.png`, and so on, and **save each one as a
file** on your real computer as you take it.

## Which account, where

| When you're | On | Sign in as |
|---|---|---|
| Setting things up and investigating | DC01, FS01, the PCs, WS-IT-01 | `RIMEPORT\responder` |
| Being the attacker | Kali | your own Kali account |

**On every Windows machine in this lab, sign in as `RIMEPORT\responder`.** On
the sign-in screen, don't click the account it offers (often Administrator).
Choose **Other user** instead, and type `RIMEPORT\responder` in full, with
`RIMEPORT\` and a backslash. To check, open PowerShell and run `whoami`. It
should say `rimeport\responder`.

> **Stay safe.** Kali works **only** while it's on the **Rimeport** LAN
> segment, never on NAT or bridged. Everything here stays inside your own lab.

---

## Part 1: Get ready (15 minutes)

1. Revert **all five** Windows machines to **rimeport-ready**, then start them
   in order: DC01, then FS01, then the three PCs.
2. Run the readiness check on **each** of the five, as in Lab 7 Part 1:

   ```
   powershell -ExecutionPolicy Bypass -File \\DC01\NETLOGON\Test-Rimeport.ps1
   ```

3. Going back to **rimeport-ready** also put back Luis's old password, so give
   him the weak one again. On **DC01**, as `RIMEPORT\responder`, in an admin
   PowerShell window, run the line from Lab 7 Part 2 and type `Rimeport2026!`:

   ```
   Set-ADAccountPassword luis.ferreira -Reset -NewPassword (Read-Host -AsSecureString 'New password for luis.ferreira')
   ```

   Write down the time. This is your own step, not the attacker's.
4. Put Kali on Rimeport at `10.20.99.50`. If you went back to **kali-nat**
   after Lab 7, follow
   [Put Kali on Rimeport](quick-reference.md#put-kali-on-rimeport-from-lab-7)
   in the quick reference. Either way, check:

   ```
   ip -4 address show
   ping -c 3 10.20.10.20
   ```

5. Write down the time. That's your **starting line**.

## Part 2: Use Luis's account (15 minutes)

Everything in this part happens on **Kali**. Write down the time just before
each command, with its time zone (`date` prints both).

### Where does the password work?

Try Luis's account on all five Windows machines at once:

```
nxc smb 10.20.10.10 10.20.10.20 10.20.20.11 10.20.20.12 10.20.20.30 -u luis.ferreira -p 'Rimeport2026!'
```

For each address, note what NetExec printed: a line with `[+]` (the sign-in
worked), `Pwn3d!` after it (the account is most likely an administrator
there), something else, or **nothing at all**.

📸 **Screenshot 1:** NetExec's answer for all five machines. Save it as
`lab8-1.png`.

### What can Luis open?

List the shared folders on the two servers, and what Luis can do in each:

```
nxc smb 10.20.10.10 10.20.10.20 -u luis.ferreira -p 'Rimeport2026!' --shares
```

Note each share's name and whether it says **READ**, **WRITE**, both, or
nothing.

📸 **Screenshot 2:** the share lists for DC01 and FS01. Save it as
`lab8-2.png`.

### Who works here?

Ask DC01 for every account in the domain:

```
nxc smb 10.20.10.10 -u luis.ferreira -p 'Rimeport2026!' --users
```

Read the list. In Lab 7 the attacker had to guess names, and `mike.chen`
didn't exist. Now there's no guessing.

📸 **Screenshot 3:** the user list. Save it as `lab8-3.png`.

You're done being the attacker. Leave Kali running, but don't run anything
else on it.

## Part 3: Follow Luis on FS01 (15 minutes)

Sign in to **FS01** as `RIMEPORT\responder` and write down the time. In Event
Viewer, filter the Security log for **4624**. Click the top record, then use
**Find...** to search for `luis.ferreira`.

For each sign-in by `luis.ferreira` from `10.20.99.50`, note:

- the time
- **Logon Type** and **Authentication Package**
- **Workstation Name** and **Source Network Address**

Match each one to a command in your notes. How many are there, and which
command made each?

📸 **Screenshot 4:** one of Luis's sign-ins on FS01 from `10.20.99.50`. Save it
as `lab8-4.png`.

Now compare it with Dana's sign-in to FS01 in **Lab 6**. Her PC opened
`\\FS01\Dispatch` too. Look at **Authentication Package** in both.

## Part 4: Follow Luis on DC01 (15 minutes)

Sign in to **DC01** as `RIMEPORT\responder` and write down the time.

1. Filter for **4624** and find `luis.ferreira`'s sign-ins from
   `10.20.99.50`. These are Kali signing in to DC01 itself.
2. Filter for **4776** and find the checks for `luis.ferreira` from the time
   of Part 2. These are DC01 checking Luis's password, for its own sign-ins
   and for FS01's.

Count both. Line them up with FS01's sign-ins and your Kali notes.

📸 **Screenshot 5:** one of Luis's 4624s on DC01 from `10.20.99.50`. Save it as
`lab8-5.png`.

## Part 5: Check the PCs (10 minutes)

Sign in to **WS-DSP-01** as `RIMEPORT\responder`, write down the time, and
filter its Security log for **4624** and **4625**. Search for `luis.ferreira`
and for `10.20.99.50`.

Is there anything from the attacker? Compare what you find with what NetExec
printed for `10.20.20.11` in Part 2. If you have time, check WS-FIN-01 the
same way.

📸 **Screenshot 6:** what the PC's log shows for the time of Part 2, even if
it's nothing from `10.20.99.50`. Save it as `lab8-6.png`.

## Part 6: Same answer, another tool (15 minutes)

On **FS01** and **DC01**, as `RIMEPORT\responder`, open **Windows PowerShell
(Admin)** and collect the Security log. **Write down each hash.**

```
whoami
$dir = "$env:USERPROFILE\Documents\Evidence"
New-Item -ItemType Directory $dir -Force | Out-Null
wevtutil epl Security "$dir\$env:COMPUTERNAME-Security-lab8.evtx" /ow:true
Get-FileHash "$dir\$env:COMPUTERNAME-Security-lab8.evtx"
Copy-Item "$dir\$env:COMPUTERNAME-Security-lab8.evtx" \\FS01\Evidence\
```

`whoami` should say `rimeport\responder`. The file name ends in `-lab8`, so it
never mixes with an export from another lab. It's saved in `responder`'s
**Documents\Evidence** folder on that machine: on the Lab 8 run, DC01
refused to save into `C:\Evidence` (Access is denied, even as `responder`
in an admin window), but saved into Documents without trouble. If `wevtutil` says **Access is
denied**, see the [quick reference](quick-reference.md#quick-fixes).

On **WS-IT-01**, as `RIMEPORT\responder`:

```
New-Item -ItemType Directory C:\Cases\lab8 -Force | Out-Null
Copy-Item \\FS01\Evidence\FS01-Security-lab8.evtx, \\FS01\Evidence\DC01-Security-lab8.evtx C:\Cases\lab8\
Get-FileHash C:\Cases\lab8\*.evtx
$evtx = (Get-ChildItem C:\Tools -Recurse -Filter EvtxECmd.exe | Select-Object -First 1).FullName
& $evtx -d C:\Cases\lab8 --csv C:\Cases\lab8\csv --csvf lab8-security.csv
$tle = (Get-ChildItem C:\Tools -Recurse -Filter TimelineExplorer.exe | Select-Object -First 1).FullName
Start-Process $tle
```

Check each hash matches the one you wrote down. In Timeline Explorer, open
`C:\Cases\lab8\csv\lab8-security.csv`, then:

1. Type `luis.ferreira` in the box under **Payload Data1**.
2. Click **Time Created** to sort by time.
3. Drag **Computer** up to the grouping bar, then **Event Id**.

You now have Luis's whole evening in one list, grouped by machine and kind of
record. **Time Created** is in UTC.

📸 **Screenshot 7:** Timeline Explorer with Luis's records grouped by
computer. Save it as `lab8-7.png`.

---

## Questions

Write your answers in your notes, and say where you found each one: which
machine, which record.

1. Which machines accepted Luis's password from Kali? Did any say `Pwn3d!`?
   What would that have meant?
2. Which shared folders could Luis read or write on FS01 and DC01? Which
   couldn't he open?
3. What did the user list give the attacker that the spray in Lab 7 didn't
   have?
4. On FS01, how many times did `luis.ferreira` sign in from `10.20.99.50`, and
   which of your commands made each one? What were the Logon Type and
   Authentication Package?
5. On DC01, which records show Luis's account, and what does each kind tell
   you?
6. Did the PCs record anything from `10.20.99.50`? Why do you think so?
7. Every one of these sign-ins **worked**. How could you tell they weren't
   from a Rimeport PC? Use Lab 6 to compare.
8. Did Event Viewer and Timeline Explorer show the same sign-ins?
9. In two sentences for Priya: where did the attacker go with Luis's account,
   and what should Rimeport do first?

📸 For any answer that isn't already in a screenshot, capture the record that
proves it and number it from 8 on.

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- In Event Viewer, **Find...** searches only the records the filter shows, and
  only down from the record you've selected. Click the top record first.
- Each NetExec command opens its own connections, so one command can leave
  more than one sign-in. Match by time.
- For question 7, put Luis's 4624 on FS01 next to Dana's from Lab 6 and read
  them line by line.
- If something doesn't line up, check the time zone on Kali and on each
  machine.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

These come from Microsoft's and NetExec's documentation and from the Lab 6
and Lab 7 runs. They'll be checked against a real run and updated. Wherever
yours differs, yours is the evidence: write it down.

**1. Most likely DC01 and FS01, with no `Pwn3d!`, and probably nothing from
the PCs.** NetExec's documentation says `Pwn3d!` means the account is most
likely a local administrator. Luis isn't an administrator anywhere, so there
shouldn't be one. That's good news for Rimeport: Luis's account can sign in,
but can't take over a machine. Microsoft says Windows Firewall blocks
connections coming in unless a rule allows them. Setup opened file sharing on
FS01 with the shares script, and DC01 serves NETLOGON to every machine, but
nothing opened it on the PCs. So the PCs probably didn't answer at all. Write
down what yours showed.

**2. On FS01, most likely `Dispatch` (read and write), and not `Finance` or
`Evidence`. On DC01, `NETLOGON` and `SYSVOL` (read).** The shares script lets
only each team into its own folder, and Luis is a dispatcher. You may also see
Windows' own shares, such as `IPC$`. Whatever the attacker could read in
Dispatch, they could also change, because Luis can. And NETLOGON holds
whatever scripts Rimeport keeps there, including `Test-Rimeport.ps1`.

**3. The real account names.** In Lab 7 the attacker guessed names, and one
(`mike.chen`) didn't exist. Microsoft's documentation says a domain
controller lets everyone read its list of accounts by default, to stay
compatible with older systems. So any account at all, even Luis's, can hand
an attacker the full list for the next spray, including `jordan.harlow` and
`responder`.

**4. At least one per command that touched FS01: Logon Type 3, Authentication
Package NTLM, from `10.20.99.50`, most likely with no Workstation Name** (as
in Lab 7). Match each to your notes. Each NetExec command makes its own
connections, so the count depends on what NetExec does inside.

**5. Two kinds.** A **4624**, Logon Type 3 from `10.20.99.50`, is Kali signing
in to DC01 itself: once for each command that touched DC01. A **4776** is DC01
checking Luis's password with NTLM: for its own sign-ins, and for every
sign-in to FS01, because FS01 asks DC01 to check. As in Lab 7, a 4776 has no
address. The 4624s on DC01 and FS01 are what put `10.20.99.50` on the record.

**6. Most likely not.** If the PCs didn't accept the connection, there was no
sign-in to write down. That's useful to know: the attacker's own screen
(nothing for those addresses) and the PCs' logs (nothing from `10.20.99.50`)
agree. Before you rely on "nothing in the log", though, check the time range
and the filter.

**7. Three things, compared with Dana in Lab 6.**

| | Dana from her PC (Lab 6) | Luis's account from Kali (this lab) |
|---|---|---|
| Source address | `10.20.20.11`, a Rimeport PC | `10.20.99.50`, not in any Rimeport range |
| Authentication Package | **Kerberos** | most likely **NTLM** |
| Workstation Name | empty | most likely empty |

Rimeport's own PCs sign in to FS01 with Kerberos, using a ticket from DC01.
NTLM from an address that isn't a Rimeport machine stands out, even when the
password was right. The empty Workstation Name doesn't help here, because
Dana's Kerberos sign-in in Lab 6 had none either.

**8. They should match.** If they don't, check the filter and the time range.
Grouping by Computer shows at a glance which machines Luis's account touched.

**9. Something like:** "Using Luis's stolen password, a machine that isn't
ours, at 10.20.99.50, signed in to the file server and the domain controller,
listed the shared folders Luis can open, and downloaded the list of every
Rimeport account. Reset Luis's password, and find out what in Dispatch was
opened or changed, which needs the file server to start recording it (Lab 9)."

**What these logs don't show:** which folders and files were opened. That
needs **Audit File Share**, which records event **5140** with the share's name
and the address it was opened from. Rimeport doesn't have it turned on yet.
Lab 9 turns it on.

</details>

---

## When you're done

- Check every time in your notes has its time zone, and every screenshot is
  saved as a file.
- **Kali:** shut it down. Before you put it back on NAT, go back to its
  **kali-nat** snapshot.
- **The Windows machines:** Luis's password is still `Rimeport2026!` until you
  go back to **rimeport-ready**.

## What you learned

- A stolen password makes **successful** sign-ins. To the logs, the attacker
  is Luis.
- You can follow one account across machines by its **name**, the **address**
  it came from, and the **time**.
- An ordinary account can see a lot: its team's shared folders, NETLOGON and
  SYSVOL, and the list of every account in the domain.
- **NTLM from an unknown address** stands out against Rimeport's own PCs,
  which use **Kerberos**.
- No `Pwn3d!` means no administrator rights, but the account can still read
  and change what its owner can.
- Without file share auditing, nobody can say which files were opened.

**Compare notes:** Shreyas's notes from his own run will be linked here once
he's run it.

**Tool bench:** add your comparison to the [tool bench](../tool-bench.md).

**Next:** Lab 9: Who touched the files, coming next. It turns on file share
auditing and finds out what was opened.

## Sources

- NetExec wiki, using credentials (`Pwn3d!` on SMB means most likely local
  admin; quote passwords with special characters):
  <https://www.netexec.wiki/getting-started/using-credentials>
- NetExec wiki, target formats (several IP addresses on one line):
  <https://www.netexec.wiki/getting-started/target-formats>
- NetExec wiki, enumerate shares and access (`--shares`, READ and WRITE):
  <https://www.netexec.wiki/smb-protocol/enumeration/enumerate-shares-and-access>
- NetExec wiki, enumerate domain users (`--users`):
  <https://www.netexec.wiki/smb-protocol/enumeration/enumerate-domain-users>
- Microsoft, "Network access: Restrict clients allowed to make remote calls to
  SAM" (on domain controllers, everyone has read access by default, for
  compatibility): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/network-access-restrict-clients-allowed-to-make-remote-sam-calls>
- Microsoft, Windows Firewall rules (inbound connections are blocked by
  default unless a rule allows them): <https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/rules>
- Microsoft, "4624(S): An account was successfully logged on" (Logon Type 3,
  Authentication Package, Workstation Name, Source Network Address):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
- Microsoft, "4776(S, F): The computer attempted to validate the credentials
  for an account" (the domain controller for domain accounts; NTLM; no address
  field): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4776>
- Microsoft, "Audit Logon" (for a network sign-in, events are written on the
  computer that hosts the resource): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/audit-logon>
- Microsoft, "Audit File Share" (event 5140, a network share object was
  accessed): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/audit-file-share>
- Microsoft, "5140(S, F): A network share object was accessed" (once per
  session; share name and source address):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-5140>
- Microsoft, Set-ADAccountPassword (`-Reset` with `-NewPassword`):
  <https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-adaccountpassword>
- Eric Zimmerman's tools (Timeline Explorer filters, groups and sorts):
  <https://ericzimmerman.github.io/>
- EvtxECmd on GitHub (`-d`, `--csv`, `--csvf`): <https://github.com/EricZimmerman/evtx>
