<#
COLD CHAIN, Level 2: check that Rimeport is ready for a lab.

Run it on each of the five Rimeport machines, signed in as RIMEPORT\responder,
in an admin PowerShell window. Start with DC01.

It only reads settings. It changes nothing, so it's safe to run as often as
you like. It knows which machine it's on and checks what that machine needs:

  Every machine  who you're signed in as, the computer name, address, mask,
                 gateway, DNS server, domain, network profile, time zone and
                 Windows activation
  Not DC01       the clock compared with DC01, that DC01 answers, and that
                 this computer's trust with the domain works
  DC01           the DNS zones, the three audit settings, the people and
                 Domain Admins, each computer's account and DNS record, and
                 the lockout policy (for your notes)
  FS01           the three shared folders
  WS-IT-01       EvtxECmd and Timeline Explorer under C:\Tools

Every line starts with PASS, FAIL or INFO. A FAIL line says how to fix it.
Read it before you run it.
#>

$expected = @{
    'DC01'      = '10.20.10.10'
    'FS01'      = '10.20.10.20'
    'WS-DSP-01' = '10.20.20.11'
    'WS-FIN-01' = '10.20.20.12'
    'WS-IT-01'  = '10.20.20.30'
}
$domainName = 'corp.rimeport.internal'
$zone       = 'Eastern Standard Time'
$name       = $env:COMPUTERNAME.ToUpper()
$script:fails = 0

function Pass($text) { Write-Host "[PASS] $text" -ForegroundColor Green }
function Info($text) { Write-Host "[INFO] $text" -ForegroundColor Gray }
function Fail($text, $fix) {
    $script:fails++
    Write-Host "[FAIL] $text" -ForegroundColor Red
    if ($fix) { Write-Host "       Fix: $fix" -ForegroundColor Yellow }
}
function Check($ok, $passText, $failText, $fix) {
    if ($ok) { Pass $passText } else { Fail $failText $fix }
}

Write-Host ''
Write-Host "Rimeport check on $name, $(Get-Date -Format 'yyyy-MM-dd h:mm:ss tt')"
Write-Host ''

# --- Who and where ---------------------------------------------------------

$me = (whoami).Trim()
Check ($me -eq 'rimeport\responder') "Signed in as $me" "Signed in as $me, not rimeport\responder" `
    'Sign out, choose Other user, and sign in as RIMEPORT\responder.'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
Check $isAdmin 'Running as administrator' 'Not running as administrator, so some checks are skipped' `
    'Right-click Start, open Terminal (Admin) or Windows PowerShell (Admin), and run this again.'

if (-not $expected.ContainsKey($name)) {
    Fail "This computer is named $name, which isn't one of Rimeport's five" 'Setup gives each machine its name with Rename-Computer.'
    return
}
Pass "Computer name $name"

# --- Network ---------------------------------------------------------------

$ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -like '10.20.*' } | Select-Object -First 1
if (-not $ip) {
    Fail 'No 10.20.x.x address on this computer' `
        'Check the VM is on the Rimeport LAN segment and has its fixed address, as setup shows.'
} else {
    Check ($ip.IPAddress -eq $expected[$name]) "Address $($ip.IPAddress)" `
        "Address is $($ip.IPAddress), expected $($expected[$name])" 'Set the address in ncpa.cpl, as setup shows.'
    Check ($ip.PrefixLength -eq 16) 'Subnet mask 255.255.0.0' `
        "Subnet mask is /$($ip.PrefixLength), expected 255.255.0.0 (/16)" 'Set the mask to 255.255.0.0 in ncpa.cpl.'

    $gateway = (Get-NetIPConfiguration -InterfaceIndex $ip.InterfaceIndex).IPv4DefaultGateway
    Check (-not $gateway) 'No default gateway' "A default gateway is set: $($gateway.NextHop)" `
        'Clear the default gateway in ncpa.cpl. Rimeport has no way out.'

    # DC01 asks itself; everyone else asks DC01
    if ($name -eq 'DC01') { $wantDns = '127.0.0.1' } else { $wantDns = '10.20.10.10' }
    $dns = @((Get-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -AddressFamily IPv4).ServerAddresses)
    Check ($dns.Count -ge 1 -and $dns[0] -eq $wantDns) "DNS server $wantDns" `
        "DNS server is $($dns -join ', '), expected $wantDns" "Set the preferred DNS server to $wantDns in ncpa.cpl."

    $category = (Get-NetConnectionProfile -InterfaceIndex $ip.InterfaceIndex -ErrorAction SilentlyContinue).NetworkCategory
    Check ($category -eq 'DomainAuthenticated') 'Network profile DomainAuthenticated' `
        "Network profile is $category, not DomainAuthenticated" 'Restart this machine once DC01 is running, then run this again.'
}

$computer = Get-CimInstance Win32_ComputerSystem
Check ($computer.PartOfDomain -and $computer.Domain -eq $domainName) "Member of $domainName" `
    "Domain is '$($computer.Domain)', expected $domainName" 'Join the domain with the three lines in setup, using DC01''s Administrator password.'

# --- Time ------------------------------------------------------------------

$tz = Get-TimeZone
Check ($tz.Id -eq $zone) "Time zone $($tz.Id)" "Time zone is $($tz.Id), expected $zone" "Set-TimeZone -Id '$zone'"

if ($name -ne 'DC01') {
    # w32tm measures how far this computer's clock is from DC01's
    $sample = w32tm /stripchart /computer:"DC01.$domainName" /samples:1 /dataonly 2>&1 |
        Where-Object { $_ -match '[+-]\d+\.\d+s' } | Select-Object -First 1
    if ("$sample" -match '([+-]\d+\.\d+)s') {
        $offset = [math]::Abs([double]::Parse($Matches[1], [Globalization.CultureInfo]::InvariantCulture))
        Check ($offset -lt 60) ('Clock within {0:N1} seconds of DC01' -f $offset) ('Clock is {0:N0} seconds off DC01' -f $offset) `
            'Run w32tm /resync. Domain sign-ins fail when clocks drift too far apart.'
    } else {
        Fail 'Could not compare the clock with DC01' 'Check DC01 is running, then run this again.'
    }
}

# --- Activation ------------------------------------------------------------

$license = Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'" `
    -ErrorAction SilentlyContinue | Select-Object -First 1
if ($license) {
    $days = [math]::Floor($license.GracePeriodRemaining / 1440)
    Check ($license.LicenseStatus -eq 1) "Windows activated, about $days days left" `
        "Windows isn't activated (status $($license.LicenseStatus))" 'See "Evaluation copies activate online" in setup.'
}

# --- The domain, from a member's side ---------------------------------------

if ($name -ne 'DC01') {
    $ldap = Test-NetConnection "DC01.$domainName" -Port 389 -InformationLevel Quiet -WarningAction SilentlyContinue
    Check $ldap 'DC01 answers on port 389 (LDAP)' 'DC01 does not answer on port 389' `
        'Start DC01 first and wait for its sign-in screen, then run this again.'
    if ($isAdmin) {
        $trust = Test-ComputerSecureChannel -ErrorAction SilentlyContinue
        Check $trust 'Trust with the domain works' 'Trust with the domain is broken' `
            'Revert all five machines to the same snapshot, together, and start DC01 first.'
    }
}

# --- DC01 only ---------------------------------------------------------------

if ($name -eq 'DC01') {
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    Import-Module DnsServer -ErrorAction SilentlyContinue

    $zones = @((Get-DnsServerZone -ErrorAction SilentlyContinue).ZoneName)
    foreach ($z in $domainName, "_msdcs.$domainName") {
        Check ($zones -contains $z) "DNS zone $z" "DNS zone $z is missing" "See Check DC01's DNS in setup."
    }

    if ($isAdmin) {
        # /r prints CSV; drop blank lines before reading it
        $audit = auditpol /get /category:"Account Logon" /r | Where-Object { $_ -match '\S' } | ConvertFrom-Csv
        foreach ($sub in 'Credential Validation', 'Kerberos Authentication Service', 'Kerberos Service Ticket Operations') {
            $setting = ($audit | Where-Object { $_.Subcategory -eq $sub }).'Inclusion Setting'
            Check ($setting -eq 'Success and Failure') "Audit $sub`: $setting" "Audit $sub is '$setting'" `
                "auditpol /set /subcategory:`"$sub`" /success:enable /failure:enable"
        }
    }

    foreach ($p in 'dana.reyes', 'luis.ferreira', 'owen.tran', 'grace.whitfield', 'sam.okafor', 'priya.raman', 'responder') {
        $user = Get-ADUser -Filter "SamAccountName -eq '$p'" -ErrorAction SilentlyContinue
        Check ($user -and $user.Enabled) "Account $p, enabled" "Account $p is missing or disabled" `
            'Run New-RimeportPeople.ps1 on DC01 again. It skips what already exists.'
    }
    $former = Get-ADUser -Filter "SamAccountName -eq 'jordan.harlow'" -ErrorAction SilentlyContinue
    Check ($former -and -not $former.Enabled) 'Account jordan.harlow, disabled (the leftover from 2025)' `
        'Account jordan.harlow is missing or enabled' 'Run New-RimeportPeople.ps1 on DC01 again.'

    $admins = @(Get-ADGroupMember 'Domain Admins' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SamAccountName)
    Check ($admins -contains 'responder' -and $admins -contains 'jordan.harlow') 'Domain Admins has responder and jordan.harlow' `
        "Domain Admins is: $($admins -join ', ')" 'Run New-RimeportPeople.ps1 on DC01 again.'

    foreach ($c in ($expected.Keys | Sort-Object)) {
        $account = Get-ADComputer -Filter "Name -eq '$c'" -ErrorAction SilentlyContinue
        Check $account "Computer account $c" "Computer account $c is missing" "Join $c to the domain, as setup shows."
        $record = Resolve-DnsName "$c.$domainName" -Type A -Server 127.0.0.1 -ErrorAction SilentlyContinue |
            Where-Object { $_.Type -eq 'A' } | Select-Object -First 1
        Check ($record -and $record.IPAddress -eq $expected[$c]) "DNS record $c -> $($expected[$c])" `
            "DNS record for $c says '$($record.IPAddress)', expected $($expected[$c])" "On $c, run ipconfig /registerdns"
    }

    $policy = Get-ADDefaultDomainPasswordPolicy -ErrorAction SilentlyContinue
    if ($policy) {
        Info ("Accounts lock after {0} wrong passwords (0 means never), for {1}. Write this in your notes." -f `
            $policy.LockoutThreshold, $policy.LockoutDuration)
    }
}

# --- FS01 only ---------------------------------------------------------------

if ($name -eq 'FS01') {
    $shares = @(Get-SmbShare -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
    foreach ($s in 'Dispatch', 'Finance', 'Evidence') {
        Check ($shares -contains $s) "Shared folder \\FS01\$s" "Shared folder \\FS01\$s is missing" `
            'Run New-RimeportShares.ps1 on FS01 again. It is safe to run twice.'
    }
}

# --- WS-IT-01 only -------------------------------------------------------------

if ($name -eq 'WS-IT-01') {
    foreach ($tool in 'EvtxECmd.exe', 'TimelineExplorer.exe') {
        $found = Get-ChildItem C:\Tools -Recurse -Filter $tool -ErrorAction SilentlyContinue | Select-Object -First 1
        Check $found "$tool at $($found.FullName)" "$tool not found under C:\Tools" `
            'See Part 6 of setup. The tools have to be downloaded while the machine is still on NAT.'
    }
}

# --- Summary -------------------------------------------------------------------

Write-Host ''
if ($script:fails -eq 0) {
    Write-Host "$name is ready: no problems found." -ForegroundColor Green
} else {
    Write-Host "$name has $($script:fails) problem(s). Fix the FAIL lines, then run this again." -ForegroundColor Red
}
Write-Host ''
