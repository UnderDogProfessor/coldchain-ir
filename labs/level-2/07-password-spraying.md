# Lab 7: Password spraying over the network

**Level:** 2, A small company
**Time:** about 90 minutes
**You need:** the five machines at their **rimeport-ready** snapshot, a Kali
Linux VM in VMware Workstation (Part 3 says where to get one), and your notes
from [Lab 6](06-meet-the-network.md)

> **Tested on November 18, 2026,** on the author's Rimeport network, with
> Kali attacking from `10.20.99.50`. The answers say what the test run showed,
> including two things the documentation didn't predict. If yours differs,
> write down what you saw.

## The story

Late one evening, FS01 writes a burst of failed sign-ins: one for almost every
person at Rimeport, a few seconds apart. Nobody was at work.

Priya, the IT manager, asks:

> "Was someone guessing passwords? Which accounts, from which machine, and did
> any guess work? And why didn't a single account lock?"

First you play the attacker, from a Kali Linux VM plugged into Rimeport's
network. Then you investigate.

## What you'll learn

- What **password spraying** looks like in Windows logs, and how it differs
  from the guessing in [Lab 2](../level-1/02-someone-is-guessing-passwords.md).
- What the **file server** writes down for each guess (**4625**), including
  the attacker's address.
- What the **domain controller** writes down for each guess (**4776**), and
  what it leaves out.
- How a code in the record tells a **wrong password** from an account that
  **doesn't exist**.
- Why "accounts never lock" didn't change this attack, and what would.

## Words you'll see

| Word | What it means |
|---|---|
| **Password spraying** | Trying one common password against many accounts, instead of many passwords against one account. One guess per account stays under almost any lockout limit. |
| **Brute force** | Many passwords against one account, like Lab 2. |
| **Lockout threshold** | How many wrong passwords an account can take before it locks. **0** means never. |
| **NTLM** | An older way Windows checks a password over the network. The computer being signed in to asks the domain controller to check it. |
| **4625** | "An account failed to log on," written by the computer being signed in to. |
| **4776** | The domain controller checking a password with NTLM. |
| **Sub Status / Error Code** | A code that says exactly why a sign-in failed. |
| **Kali Linux** | A Linux system full of security testing tools. Here it plays the attacker. |
| **NetExec (`nxc`)** | The Kali tool the attacker uses to try sign-ins over the network. |

> **Before you start,** read [Things to remember](quick-reference.md#things-to-remember)
> in the quick reference. Each item there came from a real run going wrong:
> the wrong account, a typo in a command, a missing time zone, a screenshot
> that was never saved.

## Keep notes like a responder

Copy the [Level 2 notes template](notes-template.md) into
`Documents\Rimeport notes\level-2\lab-7\`. Write the time, its time zone and
the machine for every step, like `10:42 PM ET, Kali`. Number screenshots
`lab7-1.png`, `lab7-2.png`, and so on, and take them from your real computer,
as in [Lab 6](06-meet-the-network.md#keep-notes-like-a-responder).

**Write down Kali's times too.** Kali is the attacker's machine. Your notes are
the only record of what it did.

## Which account, where

| When you're | On | Sign in as |
|---|---|---|
| Setting things up and investigating | DC01, FS01, WS-IT-01 | `RIMEPORT\responder` |
| Being the attacker | Kali | your own Kali account. Kali isn't part of the domain. |

On the Windows machines, choose **Other user** and type the full name. Check
with `whoami` if you're not sure.

> **Stay safe.** Kali attacks **only** while it's on the **Rimeport** LAN
> segment. Never run the attack while Kali is on NAT or bridged, because then
> it could reach your real network. This lab attacks only your own lab
> machines.

---

## Part 1: Get ready (15 minutes)

1. Revert **all five** Windows machines to **rimeport-ready**, then start them
   in order: DC01, then FS01, then the three PCs.
2. On **each** of the five, starting with DC01, sign in as
   `RIMEPORT\responder` and run the readiness check from the
   [quick reference](quick-reference.md#check-every-machine-is-ready) in an
   admin PowerShell window:

   ```
   powershell -ExecutionPolicy Bypass -File \\DC01\NETLOGON\Test-Rimeport.ps1
   ```

   Each should finish with no FAIL lines. Pay attention to the time zone: this
   lab lines up times from DC01, FS01 and Kali.
3. Write down the time. That's your **starting line**.

## Part 2: Set up the weakness (10 minutes)

Rimeport's helpdesk once reset Luis Ferreira's password to a "temporary" one,
and Luis never changed it. Make that happen. On **DC01**, as
`RIMEPORT\responder`, in an admin PowerShell window:

```
Set-ADAccountPassword luis.ferreira -Reset -NewPassword (Read-Host -AsSecureString 'New password for luis.ferreira')
```

When it asks, type `Rimeport2026!` and press Enter. Write down the time.

DC01 should record your reset as a **4724**, "an attempt was made to reset an
account's password," the same record you met in Lab 3. That one is yours, not
the attacker's, and your notes are what say so.

Now check whether Rimeport locks accounts after wrong passwords:

```
Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold, LockoutDuration, LockoutObservationWindow
```

Write down **LockoutThreshold**. **0** means accounts never lock. Microsoft's
documentation lists 0 as the default.

📸 **Screenshot 1:** the lockout settings on DC01. Save it as `lab7-1.png`.

## Part 3: Get the attacker ready (30 minutes, longer if you're new to Kali)

### Get Kali (skip this if you already have it)

Kali offers a ready-made VMware virtual machine, so you don't have to install
it from scratch. Follow Kali's own pages rather than a copy here, because they
stay up to date:

- **Download:** on Kali's download page, under **Pre-built Virtual
  Machines**, pick the **VMware** image: <https://www.kali.org/get-kali/>
- **Open it in VMware:** Kali's guide, "Import Pre-Made Kali VMware VM":
  <https://www.kali.org/docs/virtualization/import-premade-vmware/>. In
  short, you extract the download, then in VMware choose **Open a Virtual
  Machine** and pick the `.vmx` file.
- **Sign in:** Kali's documentation lists `kali` / `kali` as the user and
  password for its pre-built VMs:
  <https://www.kali.org/docs/introduction/default-credentials/>. Everyone
  knows that password, so change it after you first sign in, and add the new
  one to your password list.

Kali's other installation guides are at <https://www.kali.org/docs/installation/>.
If a screen doesn't match, search Kali's documentation for that step.

### Install NetExec while Kali is still on NAT

In VMware, select Kali and open **VM**, **Settings**. Check it has exactly
**one** **Network Adapter**, set to **NAT**. A second adapter could connect
Kali to two networks at once.

Start Kali so it can reach the internet. Open a terminal and run:

```
sudo apt update
sudo apt install -y netexec
```

If NetExec is already installed, the second line just says so.

**Kali's clock:** on Kali, `date` prints the time with its time zone. Use it
for every Kali time in your notes, or use your real computer's clock, and
write down which.

### Save Kali as it is now

Shut Kali down. With it off, take a snapshot named **kali-nat** (**VM**,
**Snapshot**, **Take Snapshot**). Going back to it after the lab puts Kali's
network settings back the way they are now.

### Move Kali onto Rimeport

Kali is on NAT right now, a different network from Rimeport. Until you move
it, it can't see DC01 or FS01 at all. Three things have to be right: the
VMware network, Kali's address, and the mask.

1. With Kali still off, select it in VMware and open **VM**, **Settings**,
   **Network Adapter**:
   - Under **Device status**, tick **Connect at power on**.
   - Under **Network connection**, choose **LAN segment** and pick
     **Rimeport** from the list. It's the same segment the five Windows
     machines use, made in setup Part 1.
   - Click **OK**.
2. Start Kali and open a terminal. List its network connections:

   ```
   nmcli connection show
   ```

   Note the **NAME** of the wired connection. It's usually
   `Wired connection 1`.
3. Give Kali a fixed address on Rimeport. Change the name if yours is
   different:

   ```
   sudo nmcli connection modify "Wired connection 1" ipv4.method manual ipv4.addresses 10.20.99.50/16 ipv4.dns 10.20.10.10
   sudo nmcli connection up "Wired connection 1"
   ```

   `10.20.99.50` isn't in any of Rimeport's ranges: servers are `10.20.10.x`
   and staff PCs are `10.20.20.x`. That's on purpose. It's a machine nobody at
   Rimeport owns.
4. Check the address took:

   ```
   ip -4 address show
   ```

   Look for `10.20.99.50/16` on the wired device, usually `eth0`. The `/16`
   matters: it's the same 255.255.0.0 mask the Windows machines use, and it's
   what puts `10.20.99.50` on the same network as `10.20.10.x` and
   `10.20.20.x`.

### Check Kali can reach Rimeport

With DC01 and FS01 running, from Kali:

```
ping -c 3 10.20.10.20
ping -c 3 10.20.10.10
```

`-c 3` sends three pings and stops. **FS01 should answer**: the shares script
in setup turned on FS01's File and Printer Sharing firewall rules, which let
it answer ping. On the test build, DC01 answered ping from FS01 too. The PCs
may not answer ping at all, and that's fine: this lab only needs FS01.

**If Kali can't reach FS01:**

| What you see | What to check |
|---|---|
| `ip -4 address show` has no `10.20.99.50` | Run the `nmcli connection modify` and `nmcli connection up` lines again, with the NAME that `nmcli connection show` lists |
| The address ends in `/24`, not `/16` | With `/24`, Kali only treats `10.20.99.x` as its own network and can't reach `10.20.10.x`. Run the `modify` line again with `10.20.99.50/16`, then the `up` line |
| `ping` says the host is unreachable | Kali isn't on the Rimeport segment. Check its **Network Adapter** settings in VMware: **Connected**, **LAN segment**, **Rimeport** |
| No reply, but the address and segment are right | Check FS01 is running and still has `10.20.10.20`: run `Test-Rimeport.ps1` on FS01 |

**Once it works, Kali has no way out.** Rimeport has no gateway to the
internet, so from now until you go back to the **kali-nat** snapshot, Kali can
only reach the lab.

### Check the target answers

FS01 is the file server, and it answers sign-ins over the network. From Kali:

```
nxc smb 10.20.10.20
```

It prints one line about FS01. On the test run it was:

```
Windows 11 / Server 2025 Build 26100 x64 (name:FS01) (domain:corp.rimeport.internal) (signing:True) (SMBv1:None)
```

Before trying a single password, the attacker now knows FS01's name, its
domain and its version of Windows. Write down the time: this touched FS01 too.

📸 **Screenshot 2:** NetExec's line about FS01. Save it as `lab7-2.png`.

## Part 4: The spray (5 minutes)

An attacker who knows Rimeport's staff from its website can guess the
first.last pattern. Make the list on Kali:

```
printf '%s\n' dana.reyes luis.ferreira owen.tran grace.whitfield sam.okafor priya.raman jordan.harlow mike.chen > users.txt
cat users.txt
```

`mike.chen` doesn't work at Rimeport. `jordan.harlow` left in 2025, and the
account is disabled. Both are on the list on purpose.

Now try one password against every name. **Write down the time just before
you press Enter:**

```
nxc smb 10.20.10.20 -u users.txt -p 'Rimeport2026!' --continue-on-success
```

NetExec prints one line per account. Normally it stops at the first password
that works. `--continue-on-success` makes it try the rest too. Look for the
line that's different from the others.

It won't be instant. Windows Server 2025 waits 2 seconds after each failed
NTLM sign-in over SMB, to slow down exactly this kind of guessing. Write down
the time it finishes, too.

**What the test run printed:** the line for `luis.ferreira` started with
`[+]` and showed the password. Every other line said
`Connection Error: The NETBIOS connection with the remote host timed out.`,
not a failed sign-in. FS01's 2-second pause most likely outlasted how long
NetExec waits for an answer. So NetExec reported timeouts, but FS01 still
wrote down every attempt, with the reason it failed, as Part 5 shows. The
attacker's screen and the defender's log don't tell the same story.

📸 **Screenshot 3:** NetExec's output. Save it as `lab7-3.png`.

You're done being the attacker. Leave Kali running, but don't run anything
else on it.

## Part 5: What FS01 saw (20 minutes)

Sign in to **FS01** as `RIMEPORT\responder` and write down the time. Open
**Event Viewer**, **Windows Logs**, **Security**, and **Filter Current Log...**
for **4625, 4624**.

Click the **top** record in the list first, then use **Find...** to search
for `10.20.99.50`. **Find...** searches down from the record you've selected,
so if you start below the spray, it won't find it. For each record from that
address, note:

- the event ID, and the time
- **Account Name** under **Account For Which Logon Failed** (or **New Logon**,
  for a 4624)
- **Logon Type**, **Authentication Package**
- **Workstation Name** and **Source Network Address**
- for a 4625, **Failure Reason**, **Status** and **Sub Status**

Find the **4624** from `10.20.99.50` for a Rimeport person. That's the guess
that worked. If you also see an **ANONYMOUS LOGON** from that address, it may
be NetExec's check from Part 3: compare its time with your notes and write
down what you find. On the test run, none appeared.

📸 **Screenshot 4:** one 4625 from `10.20.99.50`, with **Sub Status** visible.
Save it as `lab7-4.png`.
📸 **Screenshot 5:** the 4624 from `10.20.99.50`. Save it as `lab7-5.png`.

Microsoft notes that for a sign-in over the network, the record is written on
the computer that holds what was being opened. That's why FS01 has these, not
the PCs.

## Part 6: What DC01 saw (10 minutes)

FS01 couldn't check the passwords itself. It asked DC01. Sign in to **DC01** as
`RIMEPORT\responder` if you aren't already, write down the time, and in Event
Viewer filter the Security log for **4776**.

Find the records from the time of the spray. For each one, note **Logon
Account**, **Source Workstation** and **Error Code**.

📸 **Screenshot 6:** one 4776 from the spray, with **Error Code** visible.
Save it as `lab7-6.png`.

Look closely at what a 4776 **doesn't** have.

**Why 4776 and not 4771?** When someone types a wrong password at a Rimeport
PC, DC01 writes a **4771**, because signing in at a PC uses Kerberos. The
Lab 6 hints mention it. NetExec signs in to FS01 with **NTLM**, so DC01 writes
a **4776** instead. Same wrong password, a different record, depending on how
the sign-in happened.

## Part 7: Same answer, another tool (15 minutes)

Count the spray a second way, with the tools from Lab 6.

On **FS01** and **DC01**, as `RIMEPORT\responder`, open **Windows PowerShell
(Admin)** and collect the Security log. **Write down each hash.**

```
whoami
$dir = "$env:USERPROFILE\Documents\Evidence"
New-Item -ItemType Directory $dir -Force | Out-Null
wevtutil epl Security "$dir\$env:COMPUTERNAME-Security-lab7.evtx" /ow:true
Get-FileHash "$dir\$env:COMPUTERNAME-Security-lab7.evtx"
Copy-Item "$dir\$env:COMPUTERNAME-Security-lab7.evtx" \\FS01\Evidence\
```

`whoami` should say `rimeport\responder`. The file name ends in `-lab7`, so it
never mixes with an export from another lab. It's saved in `responder`'s
**Documents\Evidence** folder on that machine: on the Lab 8 run, DC01
refused to save into `C:\Evidence` (Access is denied, even as `responder`
in an admin window), but saved into Documents without trouble. If `wevtutil` says **Access is
denied**, see the [quick reference](quick-reference.md#quick-fixes).

On **WS-IT-01**, as `RIMEPORT\responder`, copy the logs, check the hashes and
make the timeline:

```
New-Item -ItemType Directory C:\Cases\lab7 -Force | Out-Null
Copy-Item \\FS01\Evidence\FS01-Security-lab7.evtx, \\FS01\Evidence\DC01-Security-lab7.evtx C:\Cases\lab7\
Get-FileHash C:\Cases\lab7\*.evtx
$evtx = (Get-ChildItem C:\Tools -Recurse -Filter EvtxECmd.exe | Select-Object -First 1).FullName
& $evtx -d C:\Cases\lab7 --csv C:\Cases\lab7\csv --csvf lab7-security.csv
$tle = (Get-ChildItem C:\Tools -Recurse -Filter TimelineExplorer.exe | Select-Object -First 1).FullName
Start-Process $tle
```

In Timeline Explorer, open `C:\Cases\lab7\csv\lab7-security.csv`. Then:

1. In the box under **Event Id**, type `4625`.
2. Drag the **Payload Data1** column title up to the bar that says "Drag a
   column header here to group by that column." Timeline Explorer groups the
   rows by account, with a count for each.
3. Do the same for **4776**. This time also drag **Payload Data2** and then
   **Payload Data3** up after it. Each account then opens into its
   workstation, then its result, with a count at every level.

For 4625, the account is in **Payload Data1** (after `Target:`), and the
workstation name and address are together in **Remote Host**. For 4776,
**Payload Data1** is the account, **Payload Data2** the workstation and
**Payload Data3** the result in words. **Time Created** is in UTC.

You'll see accounts the spray never touched, too. On the test run, 4776 showed
20 checks for **Administrator**, from the domain joins in setup, and 2 for
**FS01$**. Count only the rows from the time of the spray.

📸 **Screenshot 7:** Timeline Explorer with the 4625 or 4776 rows grouped by
account. Save it as `lab7-7.png`.

Fill in the **Same answer, another tool** table in your notes: did both
methods find the same number of guesses for each account?

---

## Questions

Write your answers in your notes, and say where you found each one: which
machine, which record.

1. Which accounts were tried, in what order, and how many seconds from the
   first guess to the last?
2. On FS01, what **Source Network Address** and **Workstation Name** do the
   failures show? Is that one of Rimeport's machines? (Check the table in
   [setup](00-setup.md#what-youll-build).)
3. Which **Sub Status** codes did the failures have? Which accounts got a
   different code from the rest, and what does that tell you?
4. Did any guess work? Which account, at what time, and which record proves it
   on FS01? What does DC01 show for the same moment?
5. What does DC01's 4776 tell you that FS01's 4625 doesn't? And what does it
   leave out?
6. Why didn't any account lock? If Rimeport had used Microsoft's recommended
   threshold of 10, would this spray have locked any account? Why or why not?
7. How is this different from the guessing in Lab 2? What would the same
   attack look like if it used 10 passwords instead of 1?
8. Did Event Viewer and Timeline Explorer count the same guesses for each
   account?
9. In two sentences for Priya: what happened, and the first thing Rimeport
   should do about it.

📸 For any answer that isn't already in a screenshot, capture the record that
proves it and number it from 8 on.

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- Kali's commands left no record on Kali that you'll look at. Your notes are
  the attacker's side of the timeline.
- In Event Viewer, **Find...** searches only the records the filter shows, and
  only down from the record you've selected. Click the top record first.
- If you can't find the spray on DC01, check the time zone on both machines,
  then look again at the time from your notes.
- `mike.chen` and `jordan.harlow` are on the list on purpose. Compare their
  records with everyone else's.
- Kali's times may be in a different time zone from Rimeport's. Check with
  `date` on Kali before you compare.
- If you chose `Rimeport2026!` as the staff password during setup, every staff
  account will "work." Use a different spray password in Part 2 and Part 4.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

These come from Microsoft's and the tools' documentation and from the
author's test run on November 18, 2026. Times are Eastern. Wherever yours
differs, yours is the evidence: write it down.

**1. The eight names in `users.txt`, in that order, 12 seconds from first to
last on the test run.**

| Time on FS01 | Account | Result |
|---|---|---|
| 8:13:38 PM | dana.reyes | 4625 |
| 8:13:40 PM | luis.ferreira | **4624** |
| 8:13:40 PM | owen.tran | 4625 |
| 8:13:42 PM | grace.whitfield | 4625 |
| 8:13:44 PM | sam.okafor | 4625 |
| 8:13:46 PM | priya.raman | 4625 |
| 8:13:48 PM | jordan.harlow | 4625 |
| 8:13:50 PM | mike.chen | 4625 |

Every failure is followed by a 2-second gap: that's Windows Server 2025's SMB
authentication rate limiter, which Microsoft says waits 2 seconds after each
failed NTLM sign-in. Look at Luis and Owen, though: the same second. The pause
comes only after a **failure**, so a success stands out by having no gap after
it. Without the pause, a tool could go much faster: Lab 2 warned that guessing
programs can try many times a second. One guess per account, from one
address, in a steady rhythm, is what password spraying looks like.

**2. `10.20.99.50`, which isn't one of Rimeport's machines.** Servers are
`10.20.10.x` and staff PCs are `10.20.20.x`. Microsoft describes Source Network
Address as the address of the machine the attempt came from, and Workstation
Name as that machine's name. On the test run, **Workstation Name was empty**
on every record from the spray: NetExec didn't send a name. The address is the
only clue to where it came from.

**3. `0xC000006A` for every account except `mike.chen`, who got
`0xC0000064`.** Microsoft's table says `0xC000006A` means a bad password, and
`0xC0000064` an account name that doesn't exist. So the records show which
names are real accounts at Rimeport, which is useful to the attacker as well
as to you. **`jordan.harlow` got `0xC000006A` too**, the same as any real
account with a wrong password. Microsoft lists `0xC0000072` for a disabled
account, but it didn't appear on the test run, most likely because the
password was wrong anyway. So the record gives away that the account exists,
but not that it's disabled.

**4. Yes: `luis.ferreira`, at 8:13:40 PM on the test run.** FS01 wrote a
**4624** with Logon Type **3**, Authentication Package **NTLM**, from
`10.20.99.50`, with no Workstation Name. DC01 wrote a **4776** for
`luis.ferreira` in the same second, with Error Code **`0x0`**: no error. One
working guess is all an attacker needs. Lab 8 follows what an account like
this does next.

**5. DC01 confirms which accounts were checked and the result of each, but
not where the attempt came from.** Microsoft's page for 4776 shows only the
computer name (Source Workstation), with no address field. On the test run,
**Source Workstation was empty** on every 4776 from the spray, because
NetExec sent no name. So DC01 couldn't say which machine it was at all. Only
FS01's 4625s and 4624 had the address. You need both logs.

**6. Rimeport's lockout threshold is 0, so accounts never lock.** But a
threshold of 10 wouldn't have stopped this spray either: it made one guess per
account, far under 10. That's exactly why attackers spray. Lockout stops
guessing many passwords against one account, as in Lab 2. Against spraying,
what helps is strong passwords, so the one common guess doesn't work, and
someone watching for many failures from one address. Microsoft's security
baselines recommend a threshold of 10, and its documentation says 0 should be
chosen only in specific cases. Windows Server 2025's 2-second pause after each
failed SMB sign-in slows a spray down, but it doesn't stop one.

**7. Lab 2 was one account and many passwords. This was many accounts and one
password.** Lab 2's guesses were at the keyboard (Logon Type 2, from
`127.0.0.1`) and piled up on one account. Here they came over the network
(Logon Type 3, from `10.20.99.50`) and spread across everyone, one each. With
10 passwords, each of the 8 accounts would get up to 10 failures: about 80
tries, which at 2 seconds per failure would take around two and a half
minutes. With a threshold of 10, every account would lock. That's why
sprayers keep to a few passwords and wait between rounds.

**8. They should match, and on the test run they did:** one 4776 for each of
the eight names, the same as Event Viewer. Grouped by Payload Data1, Data2 and
Data3, Timeline Explorer also showed what the spray left out, at a glance: an
empty workstation and the result for each account. If yours don't match, check
the time window, the filter,
and whether you grouped on the column that holds the account.

**9. Something like:** "At [time], a machine that isn't ours, at 10.20.99.50,
tried one password against eight Rimeport accounts on the file server, and it
worked for Luis Ferreira's account. Reset Luis's password now, then check what
his account did after [time]."

Watch the order of events. The spray is what **found** Luis's password. It
wasn't run from an account that was already compromised. Luis's account only
became compromised at the moment the one guess worked.

</details>

---

## When you're done

- Your notes and screenshots are already on your real computer. Check every
  time has its time zone.
- **Kali:** shut it down. It's still on Rimeport with `10.20.99.50`. Before
  you ever put it back on NAT, go back to its **kali-nat** snapshot, which puts
  its network settings back.
- **The Windows machines:** Luis's password is still `Rimeport2026!` until you
  go back to **rimeport-ready**. Lab 8 will say where to start from.

## What you learned

- **Password spraying** is one password against many accounts. In the logs
  it's a burst of failures, one per account, from one address.
- The **file server** recorded each guess with the attacker's address
  (**4625**), and the one that worked (**4624**).
- The **domain controller** checked each password (**4776**) but recorded only
  a computer name, not an address. A wrong password typed at a PC (Kerberos)
  leaves a **4771** there instead.
- Windows Server 2025 waits **2 seconds** after each failed sign-in over SMB.
  It slows a spray, but doesn't stop it, and the missing gap after a success
  makes the success stand out.
- **The attacker's screen isn't the log.** NetExec reported timeouts, while
  FS01 wrote down every guess and why it failed.
- The **Sub Status** code tells a wrong password from an account that doesn't
  exist.
- A **lockout threshold** stops guessing against one account, not spraying.
  Strong passwords and watching for failures from one address do.

**Compare notes:** [Shreyas's notes from his own run](../../notes/level-2/07-password-spraying.md).
Spoilers, so finish the lab first.

**Writeup:** [Lab 7 on cyberneticsintern.com](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/level-2/lab-7/)

**Tool bench:** add your comparison to the [tool bench](../tool-bench.md).

**Next:** Lab 8: Moving sideways, coming next. It follows an account as it
moves between machines.

## Sources

- MITRE ATT&CK, "Brute Force: Password Spraying" (T1110.003): one password, or
  a few common ones, against many accounts, to avoid account lockouts; names
  Windows event 4625: <https://attack.mitre.org/techniques/T1110/003/>
- Microsoft, "4625(F): An account failed to log on" (Logon Type 3, Workstation
  Name, Source Network Address, NTLM, and the codes `0xC000006D`,
  `0xC000006A`, `0xC0000064` and `0xC0000072`):
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4625>
- Microsoft, "4624(S): An account was successfully logged on" (Logon Type 3,
  NTLM): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
- Microsoft, "4776(S, F): The computer attempted to validate the credentials
  for an account" (written where the credentials are checked, the domain
  controller for domain accounts; NTLM; Source Workstation is a computer name
  only; error codes): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4776>
- Microsoft, "4771(F): Kerberos pre-authentication failed" (domain controllers
  only; `0x18` is a wrong password): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4771>
- Microsoft, "4724(S, F): An attempt was made to reset an account's password":
  <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4724>
- Microsoft, configure the SMB authentication rate limiter (on by default in
  Windows Server 2025; the SMB server waits 2 seconds after each failed NTLM
  sign-in; doesn't affect Kerberos): <https://learn.microsoft.com/en-us/windows-server/storage/file-server/configure-smb-authentication-rate-limiter>
- Broadcom, "Take a Snapshot of a Virtual Machine": <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/17-0/using-vmware-workstation-pro/using-virtual-machines-in-workstation-pro-user-guide/taking-snapshots-of-virtual-machines/take-a-snapshot-of-a-virtual-machine.html>
- Broadcom, "Revert to a Snapshot": <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/26H1/using-vmware-workstation-pro/using-virtual-machines-in-workstation-pro-user-guide/taking-snapshots-of-virtual-machines/revert-to-a-snapshot.html>
- Microsoft, "Audit Logon" (for a network sign-in, events are written on the
  computer that hosts the resource): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/audit-logon>
- Microsoft, "Account lockout threshold" (default 0, which never locks;
  security baselines recommend 10): <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/account-lockout-threshold>
- Microsoft, Set-ADAccountPassword (`-Reset` with `-NewPassword`):
  <https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-adaccountpassword>
- Microsoft, Get-ADDefaultDomainPasswordPolicy (gets the domain's default
  password policy): <https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-addefaultdomainpasswordpolicy>
- Kali Linux, netexec package (`sudo apt install netexec`, provides `nxc`,
  version 1.5.1 when opened): <https://www.kali.org/tools/netexec/>
- NetExec wiki, SMB password spraying (`-u` with a list, `-p`,
  `--continue-on-success` keeps going after a valid password):
  <https://www.netexec.wiki/smb-protocol/password-spraying>
- NetExec on GitHub (BSD-2-Clause license): <https://github.com/Pennyw0rth/NetExec>
- NetworkManager, nmcli manual (`connection show`, `connection modify` with
  `ipv4.method manual`, `connection up`): <https://networkmanager.dev/docs/api/latest/nmcli.html>
- Linux man pages: `ip address show` lists addresses, and `-4` limits it to
  IPv4 (<https://man7.org/linux/man-pages/man8/ip-address.8.html>,
  <https://man7.org/linux/man-pages/man8/ip.8.html>); `ping -c` stops after
  that many pings (<https://man7.org/linux/man-pages/man8/ping.8.html>)
- Kali Linux, "Get Kali" (pre-built VMware virtual machine):
  <https://www.kali.org/get-kali/>
- Kali Linux, "Import Pre-Made Kali VMware VM" (extract, then **Open a Virtual
  Machine** and pick the `.vmx`): <https://www.kali.org/docs/virtualization/import-premade-vmware/>
- Kali Linux, default credentials (`kali` / `kali` for pre-built VMs):
  <https://www.kali.org/docs/introduction/default-credentials/>
- Kali Linux, installation guides: <https://www.kali.org/docs/installation/>
- Broadcom, configure a VM to use a LAN segment: <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/17-0/using-vmware-workstation-pro/configuring-network-connections/configuring-lan-segments/configure-a-virtual-machine-to-use-a-lan-segment.html>
- Eric Zimmerman's tools (Timeline Explorer filters, groups and sorts):
  <https://ericzimmerman.github.io/>
- EvtxECmd on GitHub (`-d`, `--csv`, `--csvf`): <https://github.com/EricZimmerman/evtx>
