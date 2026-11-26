# Level 2 quick reference

Keep this open on your **real computer** while the VMs run. Everything here is
from the [setup guide](00-setup.md) and [Lab 6](06-meet-the-network.md),
gathered in one place so you can copy commands into a VM.

**Passwords don't go here.** This page is public. Keep yours in the password
list from setup, in your password manager or a file you never publish.

## The machines

| Machine | Address | What it is | Sign in as |
|---|---|---|---|
| DC01 | 10.20.10.10 | Domain controller | `RIMEPORT\responder` |
| FS01 | 10.20.10.20 | File server | `RIMEPORT\responder` |
| WS-DSP-01 | 10.20.20.11 | Dana's PC | `RIMEPORT\dana.reyes` when you're Dana, `RIMEPORT\responder` when you investigate |
| WS-FIN-01 | 10.20.20.12 | Owen's PC | `RIMEPORT\owen.tran` when you're Owen, `RIMEPORT\responder` when you investigate |
| WS-IT-01 | 10.20.20.30 | Your PC, with the tools | `RIMEPORT\responder` |
| Kali | 10.20.99.50 | The attacker, from Lab 7. Only on Rimeport while attacking. | Your own Kali account |

All of them: mask 255.255.0.0, no gateway, DNS 10.20.10.10 (DC01 uses
127.0.0.1). Domain `corp.rimeport.internal`, short name `RIMEPORT`. Time zone
Eastern.

**Administrator**, **itsetup** and the local **dana** are for building only.

## Signing in

1. In VMware: **VM**, **Send Ctrl+Alt+Del**.
2. Choose **Other user**. Don't click the tile the screen offers.
3. Type the full name, with `RIMEPORT\` and a **backslash**.
4. Write down the machine, the account and the time, with its time zone.

Not sure who you are? In PowerShell:

```
whoami
```

## Start, stop and go back

- **Start:** DC01, and wait for its sign-in screen. Then FS01. Then the three
  PCs.
- **Stop:** the PCs, then FS01, then DC01 last.
- **Before every lab:** go back to **rimeport-ready** on **all five** (**VM**,
  **Snapshot**, **Snapshot Manager**, **Go To**), then start them in order.
  Never revert one machine on its own.

## Check every machine is ready

Once, on DC01, put the check where every machine can read it (admin
PowerShell):

```
Copy-Item C:\Rimeport\coldchain-ir-main\labs\level-2\scripts\Test-Rimeport.ps1 \\DC01\NETLOGON\
```

If DC01's copy of the repo is older than the script, paste
[`Test-Rimeport.ps1`](scripts/Test-Rimeport.ps1) into Notepad on DC01, save it
to the Desktop as `Test-Rimeport.ps1` (**Save as type: All files**), and copy
that instead:

```
Copy-Item "$env:USERPROFILE\Desktop\Test-Rimeport.ps1" \\DC01\NETLOGON\
```

Then on each machine, DC01 first, as `RIMEPORT\responder` in an admin
PowerShell window:

```
powershell -ExecutionPolicy Bypass -File \\DC01\NETLOGON\Test-Rimeport.ps1
```

Every FAIL line says how to fix it. Run it again until the last line says the
machine is ready.

## Put Kali on Rimeport (from Lab 7)

1. Kali off, then in VMware: **VM**, **Settings**, **Network Adapter**:
   **Connect at power on**, **LAN segment**, **Rimeport**. Take a **kali-nat**
   snapshot first, so you can go back.
2. In a Kali terminal (use the NAME from the first line):

   ```
   nmcli connection show
   sudo nmcli connection modify "Wired connection 1" ipv4.method manual ipv4.addresses 10.20.99.50/16 ipv4.dns 10.20.10.10
   sudo nmcli connection up "Wired connection 1"
   ip -4 address show
   ping -c 3 10.20.10.20
   ```

   Look for `10.20.99.50/16`, then replies from FS01. Kali attacks **only**
   while it's on Rimeport. To put it back on NAT, go back to **kali-nat**.

## Collect a machine's Security log

On the machine, as `RIMEPORT\responder`, in **Windows PowerShell (Admin)**.
**Change `lab8` in the first line to the lab you're on.** Each lab's file
then gets its own name, so an export from an earlier lab never gets in the
way or gets copied by mistake. Write down the time and the hash it prints.

```
$lab = 'lab8'
whoami
New-Item -ItemType Directory C:\Evidence -Force | Out-Null
wevtutil epl Security "C:\Evidence\$env:COMPUTERNAME-Security-$lab.evtx" /ow:true
Get-FileHash "C:\Evidence\$env:COMPUTERNAME-Security-$lab.evtx"
Copy-Item "C:\Evidence\$env:COMPUTERNAME-Security-$lab.evtx" \\FS01\Evidence\
```

`whoami` should say `rimeport\responder`. Run the lines together. If you
export again, the file and its hash change, so hash the copy you keep.

## On WS-IT-01: one timeline from all the logs

Copy that lab's logs over and check the hashes. Change `lab8` in the first
line to the lab you're on:

```
$lab = 'lab8'
New-Item -ItemType Directory "C:\Cases\$lab" -Force | Out-Null
Copy-Item "\\FS01\Evidence\*-Security-$lab.evtx" "C:\Cases\$lab\"
Get-FileHash "C:\Cases\$lab\*.evtx"
```

Make the timeline, then open Timeline Explorer:

```
$evtx = (Get-ChildItem C:\Tools -Recurse -Filter EvtxECmd.exe | Select-Object -First 1).FullName
& $evtx -d "C:\Cases\$lab" --csv "C:\Cases\$lab\csv" --csvf "$lab-security.csv"
$tle = (Get-ChildItem C:\Tools -Recurse -Filter TimelineExplorer.exe | Select-Object -First 1).FullName
Start-Process $tle
```

In Timeline Explorer, filter **Payload Data1** for a person's name, not
**User Name**. **Time Created** is UTC.

## Quick fixes

| Problem | Fix |
|---|---|
| Wrong time zone | `Set-TimeZone -Id "Eastern Standard Time"` |
| Clock off from DC01 | `w32tm /resync` |
| A machine's name doesn't resolve | On that machine: `ipconfig /registerdns` |
| Sign-in fails | **Other user**, full name with a backslash, password from your list. Check Caps Lock and Num Lock. |
| Trust with the domain is broken | Go back to **rimeport-ready** on all five, together, and start DC01 first |
| A shared folder won't open | Check FS01 is running, then run `New-RimeportShares.ps1` on FS01 again |
| `wevtutil` says **Access is denied** | 1. `whoami` must say `rimeport\responder`. 2. `whoami /groups \| Select-String "High Mandatory"` must print a line; if it prints nothing, the window isn't elevated, so open **Windows PowerShell (Admin)**. 3. If both are right, save under a name you haven't used yet, such as this lab's `$lab` name, and write down what happened. |
| A command says "not recognized" | Check the spelling, or paste it instead of typing |
| "Running scripts is disabled on this system" | Windows 11 blocks scripts by default. Start it with `powershell -ExecutionPolicy Bypass -File` and the script's path, as above |
| Screenshot | **Ctrl + Alt**, then **Windows key + Shift + S** on your real computer, and drag around the VM window |
