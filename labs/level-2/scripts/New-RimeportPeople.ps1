<#
COLD CHAIN, Level 2 setup: Rimeport's people.

Run this on DC01, in an admin PowerShell window, signed in as
RIMEPORT\Administrator, after DC01 has become a domain controller.

What it does, in order:
  1. Makes two folders in Active Directory: Rimeport\Staff and Rimeport\Groups.
  2. Makes four team groups: Dispatch, Finance, Warehouse and IT.
  3. Makes six staff accounts and puts each person in their team.
  4. Makes your own account, responder, in IT and in Domain Admins.
  5. Adds one piece of history: Jordan Harlow, a former IT admin who left in
     2025. The account was disabled but never taken out of Domain Admins.

It asks for two passwords: one shared by all six staff (a lab shortcut, never
do this for real) and one for responder. Write both in your lab notes.

Running it twice is safe: anything that already exists is skipped.
Read it before you run it.
#>

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$domain   = Get-ADDomain
$domainDN = $domain.DistinguishedName   # DC=corp,DC=rimeport,DC=internal
$dnsName  = $domain.DNSRoot             # corp.rimeport.internal

$staffPassword     = Read-Host -AsSecureString 'Password for all six staff accounts'
$responderPassword = Read-Host -AsSecureString 'Password for your responder account'

function New-FolderIfMissing($Name, $Parent) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Parent -SearchScope OneLevel)) {
        New-ADOrganizationalUnit -Name $Name -Path $Parent
        Write-Host "Made folder $Name"
    }
}

function Add-ToGroup($Group, $Sam) {
    $members = Get-ADGroupMember -Identity $Group | Select-Object -ExpandProperty SamAccountName
    if ($members -notcontains $Sam) {
        Add-ADGroupMember -Identity $Group -Members $Sam
        Write-Host "  added $Sam to $Group"
    }
}

function New-Person($Person, $Password, $Folder) {
    $sam = $Person.Sam
    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Host "$sam already exists, skipped"
        return
    }
    $details = @{
        Name                 = "$($Person.First) $($Person.Last)"
        GivenName            = $Person.First
        Surname              = $Person.Last
        DisplayName          = "$($Person.First) $($Person.Last)"
        SamAccountName       = $sam
        UserPrincipalName    = "$sam@$dnsName"
        Title                = $Person.Title
        Department           = $Person.Team
        Office               = $Person.Site
        Company              = 'Rimeport Cold Logistics'
        Path                 = $Folder
        AccountPassword      = $Password
        Enabled              = $Person.Enabled
        PasswordNeverExpires = $true   # so the lab keeps working for months
    }
    if ($Person.Note) { $details.Description = $Person.Note }
    New-ADUser @details
    Write-Host "Made $sam"
}

# 1. Folders (organizational units)
New-FolderIfMissing 'Rimeport' $domainDN
$rimeportDN = "OU=Rimeport,$domainDN"
New-FolderIfMissing 'Staff'  $rimeportDN
New-FolderIfMissing 'Groups' $rimeportDN
$staffDN  = "OU=Staff,$rimeportDN"
$groupsDN = "OU=Groups,$rimeportDN"

# 2. Team groups
foreach ($team in 'Dispatch', 'Finance', 'Warehouse', 'IT') {
    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$team'")) {
        New-ADGroup -Name $team -SamAccountName $team -GroupScope Global -GroupCategory Security -Path $groupsDN
        Write-Host "Made group $team"
    }
}

# 3. Staff. Dana and Owen have their own PCs in Level 2; the rest exist as
#    accounts so Rimeport looks like a real company.
$staff = @(
    @{ Sam = 'dana.reyes';      First = 'Dana';  Last = 'Reyes';     Title = 'Dispatcher';             Team = 'Dispatch';  Site = 'North Yard'; Enabled = $true }
    @{ Sam = 'luis.ferreira';   First = 'Luis';  Last = 'Ferreira';  Title = 'Dispatcher';             Team = 'Dispatch';  Site = 'South Yard'; Enabled = $true }
    @{ Sam = 'owen.tran';       First = 'Owen';  Last = 'Tran';      Title = 'Accounts payable clerk'; Team = 'Finance';   Site = 'HQ';         Enabled = $true }
    @{ Sam = 'grace.whitfield'; First = 'Grace'; Last = 'Whitfield'; Title = 'Controller';             Team = 'Finance';   Site = 'HQ';         Enabled = $true }
    @{ Sam = 'sam.okafor';      First = 'Sam';   Last = 'Okafor';    Title = 'Warehouse supervisor';   Team = 'Warehouse'; Site = 'North Yard'; Enabled = $true }
    @{ Sam = 'priya.raman';     First = 'Priya'; Last = 'Raman';     Title = 'IT manager';             Team = 'IT';        Site = 'HQ';         Enabled = $true }
)
foreach ($person in $staff) {
    New-Person $person $staffPassword $staffDN
    Add-ToGroup $person.Team $person.Sam
}

# 4. You
$you = @{ Sam = 'responder'; First = 'IT'; Last = 'Responder'; Title = 'Incident responder'; Team = 'IT'; Site = 'HQ'; Enabled = $true
          Note = 'You. Write down every time you sign in, so you can tell yourself apart in the logs.' }
New-Person $you $responderPassword $staffDN
Add-ToGroup 'IT' 'responder'
Add-ToGroup 'Domain Admins' 'responder'

# 5. History: a former admin, disabled but still in Domain Admins.
#    Its password is random and nobody knows it.
$randomPassword = ConvertTo-SecureString ('Aa1!' + [guid]::NewGuid().ToString('N')) -AsPlainText -Force
$former = @{ Sam = 'jordan.harlow'; First = 'Jordan'; Last = 'Harlow'; Title = 'Systems administrator'; Team = 'IT'; Site = 'HQ'; Enabled = $false
             Note = 'Left Rimeport in 2025.' }
New-Person $former $randomPassword $staffDN
Add-ToGroup 'Domain Admins' 'jordan.harlow'

Write-Host ''
Write-Host 'Rimeport staff:'
Get-ADUser -Filter * -SearchBase $staffDN -Properties Title |
    Sort-Object SamAccountName |
    Format-Table SamAccountName, Name, Title, Enabled -AutoSize
Write-Host 'Domain Admins:'
Get-ADGroupMember -Identity 'Domain Admins' | Format-Table SamAccountName, Name -AutoSize
