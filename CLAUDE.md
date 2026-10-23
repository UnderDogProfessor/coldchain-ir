# Working in this repo

## Right now: Level 1 basics

The current work is the hand-built labs in `labs/level-1/`. Keep them simple:
one Windows VM, one thing to find, about an hour, plain words, and short
sentences. Don't add generators, seeds, graders or automation unless Shreyas
asks. Every technical claim in a lab must match a source listed at the bottom
of that lab. Anything you couldn't test on a real VM gets hedged in the text.

Every lab teaches the notes habit: point learners to
`labs/level-1/notes-template.md`, include 📸 screenshot prompts at the moments
that prove an answer. **Number every screenshot in the order the lab first asks
for it:** "📸 **Screenshot 1:** ... Save it as `labN-1.png`", then 2, 3, and so
on, and never skip a screenshot that the learner would need for their notes.
Shreyas names his files the same way. The notes page for the lab shows each
numbered screenshot under the part where the lab first asks for it, and ends
with a table of number, file, lab part and what it shows. Screenshots are saved
on the learner's real computer, never inside the VM. (Lab 1 predates this and
keeps its descriptive names.)

`notes/` holds Shreyas's own findings from each lab. They're his words: give
him an empty page to fill in, and help tidy it when he asks, but never write
his answers or findings for him. Lab pages link to his notes with a spoiler
warning.

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
fictional (DESIGN §3.6).

**Plumbing is named, never disguised.** Don't hide lab machinery, and don't add
Defender exclusions that aren't part of the story (DESIGN §2).

**Never weaken a verifier check to get a pack to pass.** Fix the pack or the
scenario instead.

**Lab VMs stay off the real network.** Level 1 runs on VMware Workstation with
NAT networking. Labs that run attacks use host-only networking, never bridged.
VM storage lives on `E:`.

## Voice

This is built in public by an early-career practitioner. The README, docs and
release notes never claim operational experience. Use North American spelling.

## Keeping GitHub current

Commit and push to `origin/main` whenever a piece of work
lands: a lab page written, a fix after testing, a script added. Small commits,
plain messages that say what changed and whether it's been tested on a real
VM. Never leave finished work sitting uncommitted at the end of a session.

## Checks

There's no code yet. Once `engine/` exists, run the scenario validator and the
grader tests before finishing, and never finish on a failing check.
