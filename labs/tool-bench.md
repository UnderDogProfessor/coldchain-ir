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
| Find one person's sign-in and shared-folder records on three machines | [6](level-2/06-meet-the-network.md) | Event Viewer, on each machine | | | | | | Not run yet |
| Find one person's sign-in and shared-folder records on three machines | [6](level-2/06-meet-the-network.md) | EvtxECmd + Timeline Explorer, on collected copies | | | | | | Not run yet |

## Tools so far

| Tool | What it does | Cost and license | First used |
|---|---|---|---|
| Event Viewer | Reads Windows event logs, one machine at a time | Built into Windows | [Lab 1](level-1/01-what-normal-looks-like.md) |
| `auditpol` | Shows and changes what Windows writes to the Security log | Built into Windows | [Lab 1](level-1/01-what-normal-looks-like.md) |
| `wevtutil` | Exports an event log to a file | Built into Windows | [Lab 6](level-2/06-meet-the-network.md) |
| `Get-FileHash` | Fingerprints a file (SHA-256 by default) | Built into Windows PowerShell | [Lab 6](level-2/06-meet-the-network.md) |
| [EvtxECmd](https://github.com/EricZimmerman/evtx) | Turns event logs into CSV, XML or JSON | Free, MIT license | [Lab 6](level-2/06-meet-the-network.md) |
| [Timeline Explorer](https://ericzimmerman.github.io/) | Opens CSV files to sort, filter and search | Free download. The tools page doesn't state a license. | [Lab 6](level-2/06-meet-the-network.md) |

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
