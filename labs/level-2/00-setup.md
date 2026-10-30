# Before you start: build Rimeport's network

**Time:** an afternoon or two, mostly waiting for installs and updates. You can
stop between parts.
**You do this once.** Every Level 2 lab uses the same network.

> **Not yet tested.** This guide is written but hasn't been run end to end on a
> real computer yet. If a screen or step doesn't match, pick the closest option
> and write down what you saw. It gets fixed after the first full run.

## The story

In Level 1 you looked after one computer. Now IT hands you the rest of
Rimeport's small network: the server that holds everyone's accounts, the file
server, a second staff computer, and a computer of your own for investigating.

## Words you'll see

| Word | What it means |
|---|---|
| **Domain** | One shared set of accounts for the whole company. Rimeport's is `corp.rimeport.internal`, short name **RIMEPORT**. |
| **Domain controller** | The server that holds the domain's accounts and checks every password. Rimeport's is **DC01**. |
| **Domain account** | An account that lives on DC01 and works on every Rimeport computer, written `RIMEPORT\dana.reyes`. |
| **Local account** | An account that lives on one computer only, like the `dana` account you made in Level 1. |
| **Shared folder** | A folder on one computer that other computers can open over the network, written `\\FS01\Dispatch`. |
| **LAN segment** | A private network in VMware that only the VMs you put on it can use. No internet, and no link to your real network. |
| **Fixed (static) address** | An address you type in yourself, instead of one handed out automatically. |

## What you'll build

| Name | What it is | Used by | Address |
|---|---|---|---|
| **DC01** | Domain controller | Every computer, every time someone signs in | 10.20.10.10 |
| **FS01** | File server with the shared folders | Everyone | 10.20.10.20 |
| **WS-DSP-01** | Dana's computer, the same VM as Level 1 | Dana Reyes, dispatcher | 10.20.20.11 |
| **WS-FIN-01** | Owen's computer | Owen Tran, accounts payable | 10.20.20.12 |
| **WS-IT-01** | Your computer, where the investigation tools live | You | 10.20.20.30 |

Every machine uses subnet mask **255.255.0.0** and DNS server **10.20.10.10**,
and has **no default gateway**, because the network has no way out. That mask
means only the first two numbers have to match, so every `10.20.x.x` address
is on the same network. Servers sit at `10.20.10.x` and staff computers at
`10.20.20.x`, so an address in a log tells you what kind of machine it was.

**Lab 7 adds one more machine:** a Kali Linux VM playing the attacker. Don't
connect it to the Rimeport network until Lab 7 says so.

## What you need

- Everything from [Level 1 setup](../level-1/00-setup.md): VMware Workstation
  Pro, the Windows 11 Enterprise evaluation ISO, and WS-DSP-01 with its
  **clean** snapshot.
- **Memory:** five VMs at 4 GB each is 20 GB, and your real computer needs
  room for itself on top of that. Plan for 32 GB or more.
- **Disk:** about 200 GB free, to be safe. Each new VM gets a 64 GB disk that
  grows as it fills.
- **Windows Server 2025**, free for a 180-day evaluation:
  <https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025>.
  Register, then download the **ISO**. The same ISO builds DC01 and FS01.

## How every machine gets built

Each machine follows the same rhythm:

1. Build it on **NAT**, so it can reach the internet.
2. Install updates and anything it needs from the internet.
3. Move it to the **Rimeport** LAN segment and give it its fixed address.
4. Join it to the domain (DC01 creates the domain instead).

Once a machine is on Rimeport it can't reach the internet, so step 2 has to be
finished first.

> **Evaluation copies activate online.** Before you move a machine to Rimeport,
> open PowerShell and run `slmgr /dli`. It should say **License Status:
> Licensed**. If it doesn't, run `slmgr /ato` while it's still on NAT, and
> check again.

---

## Part 1: Make the Rimeport network (5 minutes)

You create a LAN segment from any VM's settings. It then shows up for every
VM.

1. In VMware, select **WS-DSP-01** and open **VM**, then **Settings**.
2. On the **Hardware** tab, select **Network Adapter**.
3. Click **LAN Segments...**, then **Add**. Type **Rimeport** and click **OK**.
4. **Leave WS-DSP-01 on NAT for now.** Check that **NAT** is still selected,
   then click **OK**.

VMware doesn't hand out addresses on a LAN segment, which is why every machine
gets a fixed one.

## Part 2: Build DC01 (about 90 minutes)

### Create the VM

1. **File**, then **New Virtual Machine**. Choose **Typical**, then **Next**.
2. Choose **I will install the operating system later**, then **Next**.
3. **Guest operating system:** Microsoft Windows. **Version:** Windows Server
   2025, or the newest Windows Server in the list.
4. **Name:** DC01. **Location:** a folder next to WS-DSP-01.
5. **Disk size:** 64 GB.
6. Click **Customize Hardware** and set:
   - **Memory:** 4 GB (4096 MB)
   - **Processors:** 2
   - **New CD/DVD:** choose **Use ISO image file** and browse to the Windows
     Server 2025 ISO
   - **Network Adapter:** NAT
7. Click **Close**, then **Finish**.

### Install Windows Server

1. Power on DC01. **Watch for "Press any key to boot from CD or DVD"**, click
   inside the VM window and press a key. If you miss it: **VM**, **Power**,
   **Reset**, and try again.
2. Pick your language, choose to install Windows Server, and when it asks
   which one, pick **Windows Server 2025 Standard Evaluation (Desktop
   Experience)**. The versions without "Desktop Experience" have no desktop.
3. Accept the license, pick the empty drive, and wait.
4. Set a password for **Administrator** and write it in your lab notes.
5. To sign in, VMware needs Ctrl+Alt+Delete sent for you: open the **VM** menu
   and choose **Send Ctrl+Alt+Del**.

### Finish DC01

1. **VMware Tools:** **VM**, **Install VMware Tools**, then in the VM open the
   DVD drive in File Explorer and run **setup**. Choose **Typical** and restart.
2. **Time zone:** use the same one as WS-DSP-01. Right-click **Start**, choose
   **Windows PowerShell (Admin)** or **Terminal (Admin)**, and run this (the
   author's machines all use Eastern Time):

   ```
   Set-TimeZone -Id "Eastern Standard Time"
   ```

3. **Updates:** **Settings**, **Windows Update**, **Check for updates**. Install
   everything and restart. Repeat until it says you're up to date.
4. **Activation:** run `slmgr /dli` and check it says **Licensed**.
5. **The lab files:** open Edge in the VM, go to
   <https://github.com/UnderDogProfessor/coldchain-ir/archive/refs/heads/main.zip>
   and save the file. Then in PowerShell (Admin):

   ```
   Expand-Archive "$env:USERPROFILE\Downloads\coldchain-ir-main.zip" C:\Rimeport
   Get-ChildItem C:\Rimeport -Recurse | Unblock-File
   ```

   Windows marks downloaded files, and PowerShell won't run a marked script.
   `Unblock-File` removes the mark. Only do this for scripts you've read.
6. **Name:** in PowerShell (Admin), run this. The VM restarts.

   ```
   Rename-Computer -NewName DC01 -Restart
   ```

### Move DC01 to Rimeport

1. **VM**, **Settings**, **Network Adapter**. Choose **LAN segment**, pick
   **Rimeport**, click **OK**.
2. In the VM, right-click **Start**, choose **Run**, type `ncpa.cpl` and press
   Enter.
3. Right-click the network adapter, choose **Properties**, double-click
   **Internet Protocol Version 4 (TCP/IPv4)** and choose **Use the following IP
   address**:

   | Setting | Value |
   |---|---|
   | IP address | 10.20.10.10 |
   | Subnet mask | 255.255.0.0 |
   | Default gateway | *leave empty* |
   | Preferred DNS server | 127.0.0.1 |

   `127.0.0.1` means "this computer". DC01 is about to become Rimeport's DNS
   server, so it asks itself.
4. Click **OK** and **Close**.

### Make DC01 the domain controller

First check the name. In PowerShell (Admin):

```
hostname
```

It must say **DC01**. If it says anything else, run
`Rename-Computer -NewName DC01 -Restart` and check again after the restart. A
domain controller's name is hard to change later, so get it right now.

Then make it the domain controller:

```
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName corp.rimeport.internal -DomainNetbiosName RIMEPORT
```

The second command asks for a **Safe Mode Administrator Password**. It's a
spare password for repairing DC01, so write it in your lab notes too. Answer
**Y** when it asks to continue. Yellow warnings are normal here. DC01 restarts
on its own, and the first start takes a few minutes.

Without `-DomainNetbiosName`, Windows would make the short name **CORP** from
the first part of `corp.rimeport.internal`. Rimeport's is **RIMEPORT**.

> **Why `.internal`?** The rest of the series uses `.example` names, which are
> reserved for examples and never belong to a real website. But on the Windows
> Server 2025 used to test this guide, DNS refused to create a zone ending in
> `.example` (error 123, "The filename, directory name, or volume label syntax
> is incorrect"), and promotion finished without the domain's DNS. `.internal`
> is safe too: ICANN reserved it permanently in 2024 for private networks, so
> it will never be a real website either.

Sign in again as Administrator, with the same password. The sign-in screen
should now say **RIMEPORT\Administrator**.

### Check DC01's DNS

Every other machine finds DC01 through DNS, so check it before going on. Wait
a few minutes after signing in, then in PowerShell (Admin):

```
Get-DnsServerZone
Resolve-DnsName _ldap._tcp.dc._msdcs.corp.rimeport.internal -Type SRV -Server 127.0.0.1
```

- The zone list should include **corp.rimeport.internal** and
  **_msdcs.corp.rimeport.internal**.
- The second command should name **DC01.corp.rimeport.internal** on port
  **389**. That's the record a computer looks up to find DC01 when it joins
  the domain.

If either is missing, stop here. Nothing else can join the domain until this
works. See **If something doesn't work** at the end of this guide.

### Turn on the records Level 2 needs

DC01 can write down every password check and every ticket it hands out (Lab 6
explains tickets), but some of that is off by default. Check first, and write
down what it says **before** you change anything:

```
auditpol /get /category:"Account Logon"
```

Then turn on success and failure for three settings:

```
auditpol /set /subcategory:"Credential Validation" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
```

Run the first command again. All three should say **Success and Failure**.
In the story, Rimeport's IT turned these on when they built DC01.

### Add Rimeport's people

The script [`New-RimeportPeople.ps1`](scripts/New-RimeportPeople.ps1) makes
Rimeport's teams and staff accounts, your own account, and one leftover from
Rimeport's past. Read it first:

```
cd C:\Rimeport\coldchain-ir-main\labs\level-2\scripts
notepad .\New-RimeportPeople.ps1
```

Then run it:

```
.\New-RimeportPeople.ps1
```

It asks for two passwords. Windows will refuse a password that's too simple,
so use something like the Administrator one.

- **Staff password:** shared by all six staff accounts. That's a lab shortcut;
  real companies never do it.
- **responder password:** for **your** account. From now on you sign in as
  `RIMEPORT\responder`, not Administrator, so your own actions are easy to spot
  in the logs.

At the end it lists everyone it made:

| Account | Who | Team |
|---|---|---|
| dana.reyes | Dana Reyes, dispatcher, North Yard | Dispatch |
| luis.ferreira | Luis Ferreira, dispatcher, South Yard | Dispatch |
| owen.tran | Owen Tran, accounts payable clerk, HQ | Finance |
| grace.whitfield | Grace Whitfield, controller, HQ | Finance |
| sam.okafor | Sam Okafor, warehouse supervisor, North Yard | Warehouse |
| priya.raman | Priya Raman, IT manager, HQ | IT |
| responder | You | IT, Domain Admins |
| jordan.harlow | Jordan Harlow, former admin, left in 2025. Disabled. | Domain Admins |

## Part 3: Build FS01 (about 60 minutes)

Build FS01 exactly like DC01, from **Create the VM** to **Move DC01 to
Rimeport**, with these changes:

- **Name:** FS01 (in the VM wizard and in `Rename-Computer`).
- **IP address:** 10.20.10.20. **Preferred DNS server:** 10.20.10.10.

Skip **Make DC01 the domain controller**. Instead, with DC01 running, join FS01
to the domain. In PowerShell (Admin), run these three lines one at a time:

```
$pw = Read-Host -AsSecureString 'Password for RIMEPORT\Administrator (the one you use on DC01)'
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList 'RIMEPORT\Administrator', $pw
Add-Computer -DomainName corp.rimeport.internal -Credential $cred -Restart
```

The first line asks for **DC01's** Administrator password, the one you sign in
to DC01 with, not FS01's. It asks right there in the PowerShell window and
shows `*` as you type. The second puts the name and password together. The
third joins the domain, and FS01 restarts.

Now sign in to FS01 as **RIMEPORT\responder**: on the sign-in screen choose
**Other user** and type the name with the `RIMEPORT\` in front. Read and run
the shares script, in an admin PowerShell window:

```
cd C:\Rimeport\coldchain-ir-main\labs\level-2\scripts
notepad .\New-RimeportShares.ps1
.\New-RimeportShares.ps1
```

It makes three shared folders, each one open only to its team:

| Shared folder | For | What's in it |
|---|---|---|
| `\\FS01\Dispatch` | Dispatch | Route plans and reefer checks (made up) |
| `\\FS01\Finance` | Finance | Invoices and vendor payments (made up) |
| `\\FS01\Evidence` | IT | Empty. You'll collect evidence here in the labs. |

## Part 4: Bring WS-DSP-01 into the domain (about 30 minutes)

1. Revert WS-DSP-01 to **clean**: **VM**, **Snapshot**, **Snapshot Manager**,
   select **clean** (or **clean-updated**), click **Go To**. This only clears
   the VM. Your Level 1 notes and screenshots are on your real computer, and
   your Level 1 snapshots stay, so you can still redo Level 1 later.
2. Power it on, sign in as **dana**, and install all updates (it's still on
   NAT). Check `slmgr /dli` says **Licensed**.
3. Move it to **Rimeport** (**VM**, **Settings**, **Network Adapter**,
   **LAN segment**, **Rimeport**).
4. Set its address with `ncpa.cpl` as you did for DC01: IP **10.20.20.11**,
   mask **255.255.0.0**, no gateway, DNS **10.20.10.10**. The `20` in the
   third place is right: staff computers use `10.20.20.x`, and the mask puts
   them on the same network as DC01.
5. Open **Terminal (Admin)** and join the domain with the same three lines as
   FS01, one at a time:

   ```
   $pw = Read-Host -AsSecureString 'Password for RIMEPORT\Administrator (the one you use on DC01)'
   $cred = New-Object System.Management.Automation.PSCredential -ArgumentList 'RIMEPORT\Administrator', $pw
   Add-Computer -DomainName corp.rimeport.internal -Credential $cred -Restart
   ```

The local **dana** account from Level 1 is still on this computer, and it's
still an administrator. Dana now also has a domain account, **dana.reyes**,
which isn't. Lab 6 looks at the difference.

## Part 5: Build WS-FIN-01 (about 90 minutes)

Follow [Level 1 setup](../level-1/00-setup.md), Steps 3 to 7, with these
changes:

- **Name:** WS-FIN-01, in the VM wizard and in Step 6.
- **Local account (Step 4):** name it **itsetup** instead of dana. It's only
  for setting up the computer.
- **Step 7:** install the updates, but skip the snapshot. You take one at the
  end of this guide.

Check `slmgr /dli`, then move WS-FIN-01 to **Rimeport**, give it IP
**10.20.20.12** (mask 255.255.0.0, no gateway, DNS 10.20.10.10), and join it to
the domain with the same three lines as FS01.

## Part 6: Build WS-IT-01, your computer (about 2 hours)

Build it the same way as WS-FIN-01: name **WS-IT-01**, local account
**itsetup**, all updates installed. **Before** you move it to Rimeport, install
the investigation tools Lab 6 uses, while it can still reach the internet:

1. **.NET 10 Desktop Runtime.** In Edge, go to
   <https://dotnet.microsoft.com/en-us/download/dotnet/10.0>, find **.NET
   Desktop Runtime**, download the **Windows x64 installer** and run it.
   Timeline Explorer won't start without it.
2. **Eric Zimmerman's EvtxECmd and Timeline Explorer.** Download both:
   - <https://download.ericzimmermanstools.com/net/EvtxECmd.zip>
   - <https://download.ericzimmermanstools.com/net/TimelineExplorer.zip>
3. Unzip them into `C:\Tools` and find where the two programs landed. In
   PowerShell (Admin):

   ```
   Expand-Archive "$env:USERPROFILE\Downloads\EvtxECmd.zip" C:\Tools\EvtxECmd
   Expand-Archive "$env:USERPROFILE\Downloads\TimelineExplorer.zip" C:\Tools\TimelineExplorer
   Get-ChildItem C:\Tools -Recurse -Include EvtxECmd.exe, TimelineExplorer.exe | Select-Object FullName
   ```

   **Write both paths in your lab notes.** Lab 6 needs them.
4. **Update EvtxECmd's maps.** Maps tell EvtxECmd which parts of each record to
   pull out. Using the EvtxECmd path from step 3:

   ```
   & "C:\Tools\EvtxECmd\EvtxECmd.exe" --sync
   ```

   Change the path if yours is different.
5. Open Timeline Explorer once to check it starts.

Then check `slmgr /dli`, move WS-IT-01 to **Rimeport**, give it IP
**10.20.20.30** (mask 255.255.0.0, no gateway, DNS 10.20.10.10), and join the
domain with the same three lines as FS01.

> The tools are free downloads. If Microsoft Defender flags one, don't add an
> exclusion. Write down what it said, and open an issue on this repo.

## Part 7: Check it works, then snapshot (20 minutes)

**Start order matters.** Power on **DC01** first and wait until it shows the
sign-in screen. Then FS01. Then the three PCs. Every Level 2 lab starts this
way.

Sign in once as each person and open their shared folder. To open one, type
its name in File Explorer's address bar and press Enter.

| On | Sign in as | Open | Should |
|---|---|---|---|
| WS-DSP-01 | `RIMEPORT\dana.reyes` | `\\FS01\Dispatch` | Show two files |
| WS-FIN-01 | `RIMEPORT\owen.tran` | `\\FS01\Finance` | Show two files |
| WS-FIN-01 | (still Owen) | `\\FS01\Dispatch` | Say access is denied: Owen isn't in Dispatch |
| WS-IT-01 | `RIMEPORT\responder` | `\\FS01\Evidence` | Open, empty |

Each first sign-in takes a minute while Windows sets up the account. Sign
everyone out when you're done.

Then shut down all five: the PCs first, then FS01, then DC01 last. With every
VM off, take a snapshot of each one:

1. Select the VM, then **VM**, **Snapshot**, **Take Snapshot**.
2. **Name:** `rimeport-ready`, the same on all five.
3. **Description:** `Level 2 setup done, before Lab 6`.
4. Click **Take Snapshot**.

WS-DSP-01 still has its Level 1 snapshots. Keep them: `rimeport-ready` is
added next to them.

**Before every Level 2 lab:** go to **rimeport-ready** on **all five** with
**Snapshot Manager**, then start them in order, DC01 first. Always revert them
together. A domain controller and its computers that come from different
moments can stop trusting each other.

### If something doesn't work

- **"The domain could not be contacted"** when joining: check the machine's
  IP, mask and DNS (10.20.10.10), check it's on the **Rimeport** LAN segment,
  and check DC01 is running. Then run **Check DC01's DNS** on DC01 again.
- **Check DC01's DNS finds no zones:** promotion didn't set up DNS. Its log
  says why. On DC01:

  ```
  Select-String -Path C:\Windows\debug\dcpromoui.log -Pattern 'error configuring DNS' -Context 0,1
  ```

  Write down what it says and open an issue on this repo. A domain's name
  can't simply be changed afterward, so the fix may mean building DC01 again.
- **"Cannot validate argument on parameter 'Credential'. The argument is null
  or empty"** when joining: no password reached `Add-Computer`. Run the three
  lines again, one at a time, and type the password when the first one asks.
- **"The user name or password is incorrect"** when joining: the computer
  found DC01, so the network is fine. The password is wrong. Type DC01's
  Administrator password, not the password of the computer you're joining.
- **A shared folder won't open:** check FS01 is running, then run
  `New-RimeportShares.ps1` on FS01 again. It's safe to run twice.
- **Sign-in fails with a message about the time:** domain sign-ins need clocks
  that agree. Restart DC01, wait for its sign-in screen, then restart the
  computer that failed.

Still stuck? Write down exactly what you did and what it said, and open an
issue on this repo.

---

✅ **Done.** Make a notes folder for Level 2 on your real computer, for
example `Documents\Rimeport notes\level-2\`, with a copy of the
[Level 2 notes template](notes-template.md).

Next: [Lab 6: Meet the network](06-meet-the-network.md)

## Sources

- Microsoft Evaluation Center, Windows Server 2025 (180 days, ISO, Standard and
  Datacenter, Desktop Experience): <https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025>
- Microsoft, hardware requirements for Windows Server 2025 (2 GB minimum with
  Desktop Experience, 4 GB recommended; 32 GB disk minimum): <https://learn.microsoft.com/en-us/windows-server/get-started/hardware-requirements>
- Broadcom, create a new virtual machine (Typical, "install the guest
  operating system later" makes a blank disk): <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/17-0/using-vmware-workstation-pro/creating-virtual-machines-in-workstation-user-guide/create-a-new-virtual-machine-on-the-local-host.html>
- Broadcom, create a LAN segment: <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/17-0/using-vmware-workstation-pro/configuring-network-connections/configuring-lan-segments/create-a-lan-segment-for-a-virtual-machine.html>
- Broadcom, configure a VM to use a LAN segment (no DHCP server on LAN
  segments, so use fixed addresses): <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/17-0/using-vmware-workstation-pro/configuring-network-connections/configuring-lan-segments/configure-a-virtual-machine-to-use-a-lan-segment.html>
- Microsoft, install AD DS (Install-WindowsFeature, Install-ADDSForest, new
  forest needs the local Administrator): <https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100->
- Microsoft, Install-ADDSForest (DomainNetbiosName defaults from the domain
  name; DSRM password prompt; restarts on completion; DNS installed by
  default): <https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest>
- ICANN Board resolution 2024.07.29.06 (reserves `.INTERNAL` permanently for
  private use): <https://www.icann.org/en/board-activities-and-meetings/materials/approved-resolutions-special-meeting-of-the-icann-board-29-07-2024-en>
- Microsoft, Advanced Audit Policy Configuration settings (defaults for
  Credential Validation, Kerberos Authentication Service and Kerberos Service
  Ticket Operations): <https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/advanced-audit-policy-configuration>
- Microsoft, Add-Computer (`-Credential` takes a user name or a PSCredential
  object, and a user name makes it ask for a password): <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/add-computer?view=powershell-5.1>
- Microsoft, about_Execution_Policies (RemoteSigned and `Unblock-File` for
  downloaded scripts): <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies>
- Microsoft, .NET 10 downloads (.NET Desktop Runtime): <https://dotnet.microsoft.com/en-us/download/dotnet/10.0>
- Eric Zimmerman's tools (EvtxECmd and Timeline Explorer downloads, .NET 10
  Desktop runtime for GUI tools): <https://ericzimmerman.github.io/>
- EvtxECmd on GitHub (`--sync` updates the maps): <https://github.com/EricZimmerman/evtx>
