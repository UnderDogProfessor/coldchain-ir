# Working in this repo

## Right now: Level 2, a small company

Level 1 (`labs/level-1/`) is finished and tested on a real VM. The current
work is Level 2 in `labs/level-2/`: five Windows VMs on a VMware LAN segment
named Rimeport (DC01, FS01, WS-DSP-01, WS-FIN-01, WS-IT-01), plus Shreyas's
Kali VM as the attacker from Lab 7. Labs are numbered across the series, so
Level 2 is Labs 6 to 11 (files `06-...md`, website `level-2/lab-6/`). Write
one lab at a time, after he has run the one before.

Keep every lab to one main path of about an hour, in plain words and short
sentences. Level 2 may use short PowerShell scripts in `labs/level-2/scripts/`
(automation stage 1). Keep them commented, ASCII only (Windows PowerShell 5.1
misreads UTF-8 without a BOM) and safe to run twice. The lab must tell the
learner to read them before running them. Don't add generators, seeds or
graders unless Shreyas asks. Every technical claim in a lab must match a
source listed at the bottom of that lab. Anything not yet tested on the real
network gets hedged in the text, and the lab carries a "Not yet tested" note
until his run.

**Same answer, another tool.** Where a second tool fits naturally, add a part
that repeats a task with it. Add one or two extra tools, never all of them.
Free tools go on the main path. Trial or commercial tools (AXIOM and the like)
are optional extras only. Read each tool's license before a lab depends on it,
and before publishing any comparison. Results go in `labs/tool-bench.md`, and
only from Shreyas's real runs.

Every lab teaches the notes habit: point learners to that level's
`notes-template.md`, include 📸 screenshot prompts at the moments
that prove an answer. **Number every screenshot in the order the lab first asks
for it:** "📸 **Screenshot 1:** ... Save it as `labN-1.png`", then 2, 3, and so
on, and never skip a screenshot that the learner would need for their notes. A group of related shots can share a number (7.1, 7.2, ...), as in Lab 3.
Shreyas names his files the same way. The notes page for the lab shows each
numbered screenshot under the part where the lab first asks for it, and ends
with a table of number, file, lab part and what it shows. Screenshots are saved
on the learner's real computer, never inside the VM. (Lab 1 predates this and
keeps its descriptive names.)

`notes/` holds Shreyas's own findings from each lab. They're his words: give
him an empty page to fill in and help tidy it. Write his answers only when he
asks, in first person from his screenshots and logs, with no AI-drafted line,
and never invent what only he saw. Lab pages link to his notes with a spoiler
warning.

When a lab's writeup goes live on cyberneticsintern.com, link it both ways:
the lab page ends with a "Writeup" line, that level's `README.md` lists it,
and the website entry links back to the lab and the notes on GitHub. Website
URLs live under `/projects/lab-builds-and-writeups/coldchain-ir/level-N/lab-N/`. After
any change, check every link in both places.

`docs/DESIGN.md` is the parked long-term design. Read it for direction, but
don't build from it yet.

## Hard rules

**Everything an agent writes is a draft.** Scenario and world files carry
`draft: true`. Only Shreyas approves and flips them.

**The repo is public.** Anything committed here is visible to everyone. Never
commit secrets, real personal data, or anything from Shreyas's real computer.
Screenshots and logs come from the lab VM only.

**Cite only what you opened.** Every attacker stage cites entries in
`sources/sources.yaml`, each with a URL, tier and the date it was opened. If
you can't open a source, you can't cite it. If you can't confirm a detail, say
it's unconfirmed and don't invent tradecraft.

**No live malware and no exploit code for real vulnerabilities.** Emulation
reproduces behavior and artifacts. Later seasons model appliance attacks
against fictional appliances with fictional flaws.

**Nothing points at the real world.** Domains use `.example`, external IPs come
from RFC 5737 / RFC 3849 documentation ranges, and the people and companies are
fictional (DESIGN §3.6). The one exception is the Active Directory domain,
`corp.rimeport.internal`: Windows Server 2025's DNS refused to create a
`.example` zone (error 123, seen 2026-10-29), and ICANN reserves `.internal`
for private networks.

**Plumbing is named, never disguised.** Don't hide lab machinery, and don't add
Defender exclusions that aren't part of the story (DESIGN §2).

**Never weaken a verifier check to get a pack to pass.** Fix the pack or the
scenario instead.

**Lab VMs stay off the real network.** Level 1 runs on VMware Workstation with
NAT networking. From Level 2 the lab runs on a VMware LAN segment named
Rimeport, which has no internet and no link to the host. Machines use NAT only
while they're being built and updated, before they join Rimeport. Kali attacks
only from the Rimeport segment, never on NAT or bridged. VM storage lives on
`E:`.

## Voice

This is built in public by a practitioner three years into the cybersecurity
industry. Never call him early career, and never claim experience he hasn't
described: the README, docs and release notes stay on what the labs show. Use
North American spelling.

## Keeping GitHub current

Commit and push to `origin/main` whenever a piece of work
lands: a lab page written, a fix after testing, a script added. Small commits,
plain messages that say what changed and whether it's been tested on a real
VM. Never leave finished work sitting uncommitted at the end of a session.

## Checks

Before committing a lab script, parse it with PowerShell's parser and check
it's ASCII only. Once `engine/` exists, run the scenario validator and the
grader tests before finishing, and never finish on a failing check.

## LinkedIn cards

Every lab's LinkedIn card gets its **own composition**, never a recolored copy
of the last one. Keep the series signature so they read as a set: the "Incident
Response Home Lab Series" pill, the outlined lab number, the Rimeport footer
and the site palette. Change everything else: format (square or 4:5), layout
and the central illustration. So far: Lab 1 is a bar chart of the 50 sign-ins,
Lab 2 is a cartoon scene, Lab 3 is an evidence board, Lab 4 is a printed
receipt of the 4698, Lab 5 is the one-page summary on a clipboard with red-pen
corrections. The cards and posts live
in the Portfolio repo's untracked `social/` folder, not in this repo.
