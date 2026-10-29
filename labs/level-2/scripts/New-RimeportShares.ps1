<#
COLD CHAIN, Level 2 setup: Rimeport's shared drives.

Run this on FS01, in an admin PowerShell window, signed in as
RIMEPORT\responder, after FS01 has joined the domain and
New-RimeportPeople.ps1 has run on DC01.

What it does:
  1. Makes three shared folders under C:\Shares:
       Dispatch   for the Dispatch team (route plans)
       Finance    for the Finance team (invoices)
       Evidence   for IT, to collect evidence during an incident
  2. Lets only that team, plus administrators, open each one.
  3. Puts a few made-up files in Dispatch and Finance.
  4. Turns on the firewall rules that let other machines reach the shares.

Running it twice is safe. Read it before you run it.
#>

$ErrorActionPreference = 'Stop'
$root = 'C:\Shares'

$shares = @(
    @{ Name = 'Dispatch'; Team = 'RIMEPORT\Dispatch'; About = 'Route plans and reefer checks' }
    @{ Name = 'Finance';  Team = 'RIMEPORT\Finance';  About = 'Invoices and vendor payments' }
    @{ Name = 'Evidence'; Team = 'RIMEPORT\IT';       About = 'Evidence collected by IT during an incident' }
)

foreach ($share in $shares) {
    $path = Join-Path $root $share.Name
    New-Item -ItemType Directory -Path $path -Force | Out-Null

    # Folder permissions. Drop the inherited ones, then allow only SYSTEM
    # (S-1-5-18), the local Administrators group (S-1-5-32-544, which holds
    # Domain Admins) and the team.
    icacls $path /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' "$($share.Team):(OI)(CI)M" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "icacls could not set permissions on $path" }

    if (-not (Get-SmbShare -Name $share.Name -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $share.Name -Path $path -Description $share.About `
            -FullAccess 'RIMEPORT\Domain Admins' -ChangeAccess $share.Team | Out-Null
        Write-Host "Shared $path as \\$env:COMPUTERNAME\$($share.Name)"
    }
}

# Made-up work files. Nothing real: truck numbers and vendor IDs only.
$files = @{
    'Dispatch\route-plan-north-yard.csv' = @(
        'truck,departs,stops,setpoint_f,load'
        'NY-07,05:30,6,34,dairy'
        'NY-11,06:15,4,0,frozen meals'
        'NY-14,07:00,8,36,produce'
    )
    'Dispatch\reefer-checks.csv' = @(
        'trailer,checked_at,reading_f,ok'
        'RT-203,05:10,34,yes'
        'RT-219,05:14,-1,yes'
        'RT-224,05:20,41,no - sent to maintenance'
    )
    'Finance\invoices-october.csv' = @(
        'invoice,vendor_id,amount_usd,due'
        'INV-20431,V-1042,18250.00,2026-11-14'
        'INV-20432,V-1107,4380.50,2026-11-21'
        'INV-20440,V-0988,962.75,2026-11-30'
    )
    'Finance\vendor-payments.csv' = @(
        'vendor_id,last_paid,method'
        'V-0988,2026-09-30,ACH'
        'V-1042,2026-10-14,ACH'
        'V-1107,2026-10-21,check'
    )
}
foreach ($name in $files.Keys) {
    $file = Join-Path $root $name
    if (-not (Test-Path $file)) {
        Set-Content -Path $file -Value $files[$name] -Encoding ASCII
        Write-Host "Wrote $file"
    }
}

# Let the PCs reach the shares (and answer ping).
Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing'

Write-Host ''
Get-SmbShare | Where-Object { $_.Name -in 'Dispatch', 'Finance', 'Evidence' } |
    Format-Table Name, Path, Description -AutoSize
