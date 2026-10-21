# Before you start: set up your lab computer

**Time:** about an hour, mostly waiting for downloads and installs.
**You do this once.** Every Level 1 lab uses the same lab computer.

> Screens can look a little different depending on your version. If something
> doesn't match, pick the closest option and make a note of it.

## The story

You've just joined the IT team at **Rimeport Cold Logistics**, a company that
stores and delivers chilled and frozen food. Rimeport is made up for this lab.

Your first job is to look after one computer: **WS-DSP-01**. It belongs to
**Dana**, a dispatcher at the North Yard warehouse who plans which truck goes
where.

You'll build that computer yourself, as a virtual machine.

## Words you'll see

| Word | What it means |
|---|---|
| **Virtual machine (VM)** | A computer running inside your computer. If you break it, your real computer is fine. |
| **VMware Workstation** | The program that runs VMs. It's free. |
| **ISO** | One file that holds a whole Windows installer, like a DVD in a single file. |
| **Snapshot** | A saved copy of the VM at one moment. You can jump back to it anytime. |

## What you need

- A Windows PC. Any edition works, including Home.
- At least 8 GB of memory (16 GB is more comfortable). The VM uses 4 GB.
- About 80 GB of free disk space.

---

## Step 1: Install VMware Workstation Pro

Skip this if you already have it.

VMware Workstation Pro is free. You download it from Broadcom (VMware's owner)
after making a free account at <https://support.broadcom.com>. Once you're
signed in, look under **My Downloads** for **VMware Workstation Pro**, then
install it like any other program.

## Step 2: Download Windows 11 Enterprise

Microsoft gives a free **90-day evaluation** for testing:
<https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise>

Fill in the short form and download the **ISO**. It's a few gigabytes.

> After 90 days the evaluation expires. That's fine for a lab: you just build
> a new VM.

## Step 3: Create the VM

1. Open VMware Workstation and choose **File**, then **New Virtual Machine**.
2. Choose **Typical** and click **Next**.
3. Choose **Installer disc image file (iso)**, browse to the ISO you
   downloaded, and click **Next**.
4. If it asks for the operating system, choose **Windows 11 x64**.
5. **Name:** type **WS-DSP-01**. **Location:** pick a folder on a drive with
   room to spare. Click **Next**.
6. **Encryption:** Windows 11 needs a security chip called a TPM, and VMware
   only adds one to an encrypted VM.
   - Choose the option that encrypts **only the files needed for the TPM**.
     It's quicker than encrypting everything.
   - Click **Generate** to make a password, then **Copy**, and **paste it
     somewhere safe**, like your password manager. VMware can't recover it if
     it's lost.
   - Tick the box to **remember the password** on this computer.
7. **Disk size:** at least **64 GB**. Leave the other disk options as they
   are, and click **Next**.
8. Click **Customize Hardware** and set:
   - **Memory:** 4 GB (4096 MB)
   - **Processors:** 2
   - **Network Adapter:** NAT
9. Click **Close**, then **Finish**.

## Step 4: Install Windows

1. Select **WS-DSP-01** and click **Power on this virtual machine**.
2. **Watch for "Press any key to boot from CD or DVD" and click inside the VM
   window, then press a key straight away.** If you miss it, open the **VM**
   menu, choose **Power**, then **Reset**, and try again.
3. Follow the installer: pick your language, choose to install Windows 11,
   accept the license, choose a **Custom** install, and pick the empty drive.
4. Wait for it to copy files and restart a few times.

When Windows asks how you want to sign in:

- Create a **local account** named **dana**. Don't use a Microsoft account.
- On Enterprise, the local-account option is usually under **Sign-in options**,
  then **Domain join instead**. This is the screen most likely to look
  different on your version. If it does, pick whatever option creates a local
  account.
- Pick a password you'll remember, and write it down for the lab.

## Step 5: Install VMware Tools

VMware Tools makes the screen, mouse and copy-paste work properly.

1. In the **VM** menu, choose **Install VMware Tools**.
2. Inside the VM, open **File Explorer**, open the **DVD drive**, and run
   **setup**.
3. Choose **Typical**, finish, and restart when it asks.

## Step 6: Give the computer its name

Inside the VM:

1. Open **Settings**, then **System**, then **About**.
2. Click **Rename this PC** and type **WS-DSP-01**.
3. Restart when it asks.

## Step 7: Take a "clean" snapshot

1. Inside the VM, shut down Windows: **Start**, **Power**, **Shut down**.
2. When the VM is off, open the **VM** menu and choose **Snapshot**, then
   **Take Snapshot**.
3. Name it **clean** and click **OK**.

**Before each lab:** open the **VM** menu, choose **Snapshot**, then **Revert
to Snapshot**. WS-DSP-01 goes back to exactly how it is right now.

---

✅ **Done.** Next: [Lab 1: What normal looks like](01-what-normal-looks-like.md)

## Sources

- Broadcom KB 323903, Workstation Pro is free with a Broadcom account: <https://knowledge.broadcom.com/external/article/323903>
- Broadcom, "Install Windows 11 on a Virtual Machine in Workstation Pro" (wizard steps, vTPM, encryption choices): <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/17-0/using-vmware-workstation-pro/creating-virtual-machines-in-workstation-user-guide/create-a-new-virtual-machine-on-the-local-host/install-windows-11-on-a-virtual-machine-in-workstation.html>
- Broadcom, "Take a Snapshot of a Virtual Machine": <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/17-0/using-vmware-workstation-pro/using-virtual-machines-in-workstation-pro-user-guide/taking-snapshots-of-virtual-machines/take-a-snapshot-of-a-virtual-machine.html>
- Broadcom, "Revert to a Snapshot": <https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/workstation-pro/26H1/using-vmware-workstation-pro/using-virtual-machines-in-workstation-pro-user-guide/taking-snapshots-of-virtual-machines/revert-to-a-snapshot.html>
- Microsoft, Windows 11 requirements for VMs (4 GB, 2 processors, 64 GB disk, TPM): <https://learn.microsoft.com/en-us/windows/whats-new/windows-11-requirements>
- Windows 11 Enterprise evaluation: <https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise>
