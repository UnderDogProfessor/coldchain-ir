# Working in this repo

Read `docs/DESIGN.md` before changing anything. It's the contract. If code and
the design disagree, raise it. Don't quietly pick one.

## Hard rules

**Everything an agent writes is a draft.** Scenario and world files carry
`draft: true`. Only Shreyas approves and flips them.

**The repo is private until v0.1.** Don't push it public, create a public
remote, or publish packs without his explicit go-ahead.

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

**The range stays isolated.** Range VMs use Hyper-V private switches only. Never
attach a range VM to an external switch. VM storage lives on `E:`.

## Voice

This is built in public by an early-career practitioner. The README, docs and
release notes never claim operational experience. Use North American spelling.

## Checks

There's no code yet. Once `engine/` exists, run the scenario validator and the
grader tests before finishing, and never finish on a failing check.
