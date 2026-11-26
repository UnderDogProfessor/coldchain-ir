# Tool bench

**Same task, different tools.** Before an answer goes into a report,
responders often check it with a second tool. If two tools agree, you can
trust the answer more. If they don't, one of them, or you, has it wrong, and
it's much better to find that out before the report goes out.

From Level 2 on, wherever a second tool fits naturally, a lab does the same
task twice. Each lab keeps one main path of about an hour using free tools.
The second tool is an extra part on top.

## Results

One row per task per tool, from a real run of the lab. "Same answer?" means:
did it find what your notes say happened?

| Task | Lab | Tool | Same answer? | Time | Setup effort | Pros | Cons | Run |
|---|---|---|---|---|---|---|---|---|
| Find one person's sign-in and shared-folder records on three machines | [6](level-2/06-meet-the-network.md) | Event Viewer, on each machine | Yes | About 17 minutes | None, built in | Every field of each record, on the machine itself | One machine at a time, signing in to each | 2026-11-04 |
| Find one person's sign-in and shared-folder records on three machines | [6](level-2/06-meet-the-network.md) | EvtxECmd + Timeline Explorer, on collected copies | Not at first: filtering **User Name** missed every sign-in. Yes with **Payload Data1** | About 27 minutes, with collecting and hashing | Install on WS-IT-01 before it joins Rimeport | All three machines in one list | You have to know which column holds the name; times are UTC | 2026-11-04 |
| Count a password spray's guesses per account on the file server and the domain controller | [7](level-2/07-password-spraying.md) | Event Viewer, on each machine | Yes: every guess, with its result | Not recorded | None, built in | Shows the full reason for each failure | **Find** searches only down from the selected record | 2026-11-18 |
| Count a password spray's guesses per account on the file server and the domain controller | [7](level-2/07-password-spraying.md) | EvtxECmd + Timeline Explorer, grouped by account | Yes: one 4776 per sprayed name | Not recorded | Same as Lab 6 | Grouping by three columns gives account, workstation and result counts at once | Older records for other accounts (20 for Administrator) sit in the same list, so you have to narrow the time | 2026-11-18 |
| Follow one account's sign-ins across the file server and the domain controller | [8](level-2/08-moving-sideways.md) | Event Viewer, on each machine | Yes: 2 sign-ins on FS01, 4 on DC01, 6 password checks | 25 to 30 minutes | None, built in | Its filters were as good as Timeline Explorer's | Scrolling up and down to find each record, one machine at a time | 2026-11-25 |
| Follow one account's sign-ins across the file server and the domain controller | [8](level-2/08-moving-sideways.md) | EvtxECmd + Timeline Explorer, grouped by computer | Yes: the same counts, plus a logoff (4634) after each sign-in | 10 minutes at most | Same as Lab 6 | Both machines in one list, grouped by computer, with the logoffs and older records Event Viewer's filter hid | Combining the two `.evtx` files; DC01 refused to save its export into `C:\Evidence` | 2026-11-25 |

## Tools so far

| Tool | What it does | Cost and license | First used |
|---|---|---|---|
| Event Viewer | Reads Windows event logs, one machine at a time | Built into Windows | [Lab 1](level-1/01-what-normal-looks-like.md) |
| `auditpol` | Shows and changes what Windows writes to the Security log | Built into Windows | [Lab 1](level-1/01-what-normal-looks-like.md) |
| `wevtutil` | Exports an event log to a file | Built into Windows | [Lab 6](level-2/06-meet-the-network.md) |
| `Get-FileHash` | Fingerprints a file (SHA-256 by default) | Built into Windows PowerShell | [Lab 6](level-2/06-meet-the-network.md) |
| [EvtxECmd](https://github.com/EricZimmerman/evtx) | Turns event logs into CSV, XML or JSON | Free, MIT license | [Lab 6](level-2/06-meet-the-network.md) |
| [Timeline Explorer](https://ericzimmerman.github.io/) | Opens CSV files to sort, filter and search | Free download. The tools page doesn't state a license. | [Lab 6](level-2/06-meet-the-network.md) |
| [NetExec](https://github.com/Pennyw0rth/NetExec) (`nxc`) | The attacker's tool on Kali: tries sign-ins over the network. Not an investigation tool, listed so you know what made the noise. | Free, BSD-2-Clause license | [Lab 7](level-2/07-password-spraying.md) |

## Coming later

These are planned, not yet checked. Each tool's license and download get
checked before a lab depends on it.

| Level | Tasks | Tools being considered |
|---|---|---|
| 2: A small company | Hunting through event logs, merging logs into one timeline | Hayabusa, Chainsaw |
| 3: Evidence on disk and in memory | Disk and memory images, collection, what ran, deleted files, registry, memory | FTK Imager, KAPE, more of Eric Zimmerman's tools (PECmd, MFTECmd, Registry Explorer), Autopsy and The Sleuth Kit, Volatility 3 |
| 4: Live response | Collecting from live machines | Velociraptor, and KAPE compared with it |

Commercial tools with free trials, such as Magnet AXIOM, may show up as
optional extras, never on a lab's main path. A trial can run out before you
finish, and it may need a sales form. Some commercial licenses also forbid
publishing comparisons, so their terms get read before anything about them is
published here.
