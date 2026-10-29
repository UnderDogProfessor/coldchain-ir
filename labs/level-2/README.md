# Level 2: A small company

In Level 1 you looked after one computer. In Level 2 you get Rimeport's small
network: a domain controller, a file server, two staff computers and a
computer of your own for investigating. From Lab 7, an attacker joins too. You
follow one person, then one attacker, across several machines, and merge
their logs into one story.

| Machine | What it is | Address |
|---|---|---|
| DC01 | Domain controller: every account, every password check | 10.20.10.10 |
| FS01 | File server: the shared folders | 10.20.10.20 |
| WS-DSP-01 | Dana's computer, the same VM as Level 1 | 10.20.20.11 |
| WS-FIN-01 | Owen's computer, in Finance | 10.20.20.12 |
| WS-IT-01 | Your computer, with the investigation tools | 10.20.20.30 |
| Kali | The attacker's machine, from Lab 7 | Given in Lab 7 |

They all run on a private VMware network called **Rimeport**, with no way to
the internet or your real network.

## The labs

The labs are numbered across the whole series, so Level 2 starts at 6.

| # | Lab | You'll learn | Status |
|---|---|---|---|
| 0 | [Before you start](00-setup.md) | Build Rimeport's network (once) | Written, not yet tested |
| 6 | [Meet the network](06-meet-the-network.md) | Where one sign-in gets written down: the computer, the domain controller and the file server | Written, not yet tested |
| 7 | Password spraying over the network | Failed sign-ins from another machine, and where they came from | Planned |
| 8 | Moving sideways | Follow one account as it hops between machines | Planned |
| 9 | Who touched the files | Read the file server's access records | Planned |
| 10 | The new admin, domain-wide | Lab 3 again, now on the domain controller | Planned |
| 11 | Reconstruct the night | Merge several machines' logs into one timeline | Planned |

Do them in order. Each lab is written after the one before has been run on
the real network, so the planned ones can still change.

**Keep notes as you go.** Level 2 has its own [notes template](notes-template.md),
with a column for the machine and a table for evidence fingerprints. You're in
the logs too now, so write down every time you sign in.

## Same answer, another tool

Wherever a second tool fits, a lab does the same task twice: once with
Windows' built-in tools, and once with a tool responders use, starting with
Eric Zimmerman's EvtxECmd and Timeline Explorer in Lab 6. You record whether
the answers match, how long each took, and what was easy or annoying. The
results go on the [tool bench](../tool-bench.md).

## Scripts

Level 2 uses two short PowerShell scripts in [`scripts/`](scripts/) to set up
Rimeport's accounts and shared folders, instead of hundreds of clicks. They're
commented and plain. **Read a script before you run it**, every time,
including these.
