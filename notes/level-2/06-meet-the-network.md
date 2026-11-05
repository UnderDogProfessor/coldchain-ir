# My notes: Lab 6, Meet the network

> ⚠️ Spoilers. Try [the lab](../../labs/level-2/06-meet-the-network.md) first.

**Date done:** 2026-11-04
**Machines:** DC01 and FS01 (Windows Server 2025 Standard Evaluation, build
26100), WS-DSP-01, WS-FIN-01 and WS-IT-01 (Windows 11 Enterprise Evaluation),
on the Rimeport LAN segment in VMware Workstation

Screenshots are numbered in the order the lab asks for them. Each one sits
under the part where the lab first asks for it. Times are Eastern (EST).

---

## Part 1: Get ready

| Machine | Started |
|---|---|
| DC01 | 8:36 PM |
| FS01 | 8:37 PM |
| WS-DSP-01 | 8:38 PM |
| WS-FIN-01 | 8:38 PM |
| WS-IT-01 | 8:38 PM |

## Part 2: Check what's being written down

📸 Screenshot 1: not taken.

## Part 3: A normal morning

At 8:40 PM I typed `RIMEPORT/dana.reyes` and entered the password twice,
maybe three times. It didn't work until I realized it's `RIMEPORT\dana.reyes`,
with a backslash, not a forward slash.

| # | Machine | Signed in as | What I did | Time |
|---|---|---|---|---|
| 1 | WS-DSP-01 | `RIMEPORT\dana.reyes` | Signed in | 8:41 PM |
| 2 | WS-DSP-01 | `RIMEPORT\dana.reyes` | Opened `\\FS01\Dispatch` in File Explorer | 8:43 PM |
| 3 | WS-DSP-01 | `RIMEPORT\dana.reyes` | Opened `route-plan-north-yard.csv` in Notepad, read it, closed it | 8:43 PM |
| 4 | WS-DSP-01 | `RIMEPORT\dana.reyes` | Signed out | 8:43 PM |
| 5 | WS-FIN-01 | `RIMEPORT\owen.tran` | Signed in | 8:44 PM |
| 6 | WS-FIN-01 | `RIMEPORT\owen.tran` | Opened `\\FS01\Finance` and `invoices-october.csv` in Notepad | 8:45 to 8:46 PM |
| 7 | WS-FIN-01 | `RIMEPORT\owen.tran` | Signed out | 8:46 PM |

## Part 4: Follow Dana across three machines

I had a failed sign-in at 8:50 PM, then signed in successfully as Dana again.
Then I realized I should have signed in as responder on WS-DSP-01, so I signed
out as Dana at 8:51 PM.

I typed the wrong password for `RIMEPORT\responder` on WS-DSP-01 four times
before I signed in successfully at 8:53 PM.

### Her computer: WS-DSP-01

Dana's sign-in showed up as two 4624 records:

| Field | First record | Second record |
|---|---|---|
| Logon Type | **11** | **7** |
| Account Name | dana.reyes | dana.reyes |
| Account Domain | RIMEPORT | RIMEPORT |
| Logon ID | `0xA30E7` | `0xA321B` |
| Process Name | `C:\Windows\System32\svchost.exe` | `C:\Windows\System32\lsass.exe` |
| Logon Process | User32 | Negotiat |
| Authentication Package | Negotiate | Negotiate |
| Workstation Name | WS-DSP-01 | WS-DSP-01 |
| Source Network Address | 127.0.0.1 | - |

![Event Viewer on WS-DSP-01: Dana's 4624 at 8:41:29 PM, Logon Type 11, Process svchost.exe](images/lab6-2.1.png)

📸 Screenshot 2.1 (`lab6-2.1.png`): the Logon Type 11 record

![Event Viewer on WS-DSP-01: Dana's 4624 at 8:41:29 PM, Logon Type 7, Process lsass.exe](images/lab6-2.2.png)

📸 Screenshot 2.2 (`lab6-2.2.png`): the Logon Type 7 record

### The domain controller: DC01

Signed in as `RIMEPORT\responder` at 9:00 PM on DC01. Reviewed 4768 and 4769.

- 4768 for dana.reyes: Client Address `::ffff:10.20.20.11`
- 4769 for Dana: Service Name `WS-DSP-01$`

![Event Viewer on DC01: Dana's 4768 at 8:41:30 PM, Service Name krbtgt, Client Address ::ffff:10.20.20.11](images/lab6-3.png)

📸 Screenshot 3 (`lab6-3.png`): Dana's 4768

![Event Viewer on DC01: Dana's 4769 at 8:41:30 PM, Service Name WS-DSP-01$, Client Address ::ffff:10.20.20.11](images/lab6-4.png)

📸 Screenshot 4 (`lab6-4.png`): a 4769 for Dana, Service Name `WS-DSP-01$`

### The file server: FS01

Signed in as `RIMEPORT\responder` at 9:06 PM on FS01. Reviewed 4624.

![Event Viewer on FS01: Dana's 4624 at 8:42:49 PM, Logon Type 3, Source Network Address 10.20.20.11, Workstation Name -, Kerberos](images/lab6-5.png)

📸 Screenshot 5 (`lab6-5.png`): Dana's sign-in on FS01

## Part 5: Same answer, another tool

### Collect the logs

| File | From | SHA-256 when collected | SHA-256 on WS-IT-01 | Match? |
|---|---|---|---|---|
| `DC01-Security.evtx` | DC01 | `0DA0CDCDBE68C58B47E7C614705F9BDAF24E35E55E73B038277EA98015B4AD11` | `0DA0CDCDBE68C58B47E7C614705F9BDAF24E35E55E73B038277EA98015B4AD11` | Yes |
| `FS01-Security.evtx` | FS01 | `60C3895314C459F7B6FF6EEDFD18CCD2F317DCE2F410717E61B65A71ED030424` | `60C3895314C459F7B6FF6EEDFD18CCD2F317DCE2F410717E61B65A71ED030424` | Yes |
| `WS-DSP-01-Security.evtx` | WS-DSP-01 | `FB4EC14CBD66874FFB1B3A46825613683B4F5236DA334F6FB438F8015FD78833` | `8784A4937AF6E5523D87D8AA268B1F24DDF27537AC829158017C796F3BC9B7C6` | **No** |

Why WS-DSP-01's didn't match:

![PowerShell on WS-DSP-01: export and Get-FileHash, SHA256 FB4EC14C...D78833](images/lab6-6.1.png)

📸 Screenshot 6.1 (`lab6-6.1.png`): WS-DSP-01's export and hash

![PowerShell on FS01: export, hash 60C38953...030424 and copy to \\FS01\Evidence](images/lab6-6.1.1.png)

📸 Screenshot 6.1.1 (`lab6-6.1.1.png`): FS01's export, hash and copy

![PowerShell on DC01: export, hash 0DA0CDCD...B4AD11 and copy to \\FS01\Evidence](images/lab6-6.1.3.png)

📸 Screenshot 6.1.3 (`lab6-6.1.3.png`): DC01's export, hash and copy

### Check the copies on my computer

![PowerShell on WS-IT-01: the three copies in C:\Cases\lab6 and their hashes](images/lab6-6.2.png)

📸 Screenshot 6.2 (`lab6-6.2.png`): the three hashes on WS-IT-01

### Turn the logs into one timeline

![Timeline Explorer: lab6-security.csv filtered to User Name contains dana.reyes, 248 of 70,735 lines](images/lab6-7.png)

📸 Screenshot 7 (`lab6-7.png`): Timeline Explorer filtered to `dana.reyes`

### Compare the two methods

| Method | Same answer? | Time it took | What was easy | What was annoying |
|---|---|---|---|---|
| Event Viewer, on each machine | | | | |
| EvtxECmd and Timeline Explorer | | | | |

## Questions

**1.**

**2.**

**3.**

**4.**

**5.**

**6.**

**7.**

**8.**

**9.**

---

## What surprised me

## What I'd do differently next time

## Evidence files

- [lab6-security-logs.zip](evidence/lab6-security-logs.zip): the three
  Security logs exactly as they reached WS-IT-01 (`DC01-Security.evtx`,
  `FS01-Security.evtx` and `WS-DSP-01-Security.evtx`). Unzip them and run
  `Get-FileHash`. Each should match the "on WS-IT-01" column above.

The timeline CSV isn't here. At 76 MB it's too big, and EvtxECmd makes it again
from these three logs in under a minute.

## Screenshots

| # | File | Lab part | What it shows |
|---|---|---|---|
| 1 | not taken | Part 2 | |
| 2.1 | `lab6-2.1.png` | Part 4, WS-DSP-01 | Dana's 4624, Logon Type 11, 8:41:29 PM |
| 2.2 | `lab6-2.2.png` | Part 4, WS-DSP-01 | Dana's 4624, Logon Type 7, 8:41:29 PM |
| 3 | `lab6-3.png` | Part 4, DC01 | Dana's 4768, Client Address `::ffff:10.20.20.11` |
| 4 | `lab6-4.png` | Part 4, DC01 | a 4769 for Dana, Service Name `WS-DSP-01$` |
| 5 | `lab6-5.png` | Part 4, FS01 | Dana's 4624, Logon Type 3 from 10.20.20.11 |
| 6.1 | `lab6-6.1.png` | Part 5, collect | WS-DSP-01's export and hash |
| 6.1.1 | `lab6-6.1.1.png` | Part 5, collect | FS01's export, hash and copy |
| 6.1.3 | `lab6-6.1.3.png` | Part 5, collect | DC01's export, hash and copy |
| 6.2 | `lab6-6.2.png` | Part 5, check | the three hashes on WS-IT-01 |
| 7 | `lab6-7.png` | Part 5, timeline | Timeline Explorer filtered to `dana.reyes` |
