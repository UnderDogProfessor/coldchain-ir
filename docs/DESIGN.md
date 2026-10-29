# COLD CHAIN: design

| | |
|---|---|
| Status | Draft 0, parked (see the note below) |
| Written | 2026-10-19 |
| Owner | Shreyas Lipare |
| Repo slug | `coldchain-ir` |

> **Parked (2026-10-19).** We're starting with hand-built Level 1 labs in
> `labs/level-1/`. Read this file as the long-term direction, not the current
> plan. Nothing here gets built until the basics are done.

COLD CHAIN is an open incident response lab, beginner to expert, built around
one fictional company that keeps getting breached. This document is the
contract every part of the repo is built against. When code and this document
disagree, one of them is wrong and gets fixed. Neither one wins by default.

---

## 1. The bet

Every published lab gets solved in public. Hosted platforms have whole GitHub
repos of answers [R1][R2]. A lab that is "not on the internet" can't stay that
way once it ships. So COLD CHAIN makes the **method** public and keeps the
**answers** private, by giving every learner a different incident.

A scenario is a template. A **seed** turns it into one specific incident:
which employee clicked, which lure, which attacker domain, what time, which
technique out of a pool, which hosts got touched. Each seed produces an
evidence pack plus a sealed answer key, and a local grader marks your work
against it. Writeups are welcome, because a writeup for seed `7F3A-91C2`
doesn't answer seed `0B1D-44E7`.

Four more ideas sit on top of that. Each one fills a gap the research turned
up:

1. **One company, many incidents.** Rimeport carries history from one incident
   to the next. Learners study what normal looks like before anything breaks.
2. **A telemetry dial.** The same incident is rendered at three logging levels,
   so you can see exactly what each control buys you.
3. **Real response.** From v0.3 on, containment changes what the attacker does
   next, and there's a business clock running while you decide.
4. **Cited sources.** Every attacker stage traces back to a public primary
   source. The lab models real intrusions and doesn't invent tradecraft.

### What exists already, and why this is still worth building

| Kind | Examples | Gap |
|---|---|---|
| Lab builders | DetectionLab (unmaintained since 2023-01-01) [R22], GOAD, Ludus [R3] | Infrastructure built for offense or detection, not an IR pathway |
| Fixed datasets | OTRF Security-Datasets, Splunk BOTS | One incident, one answer key |
| Hosted investigations | HTB Sherlocks, CyberDefenders, BTLO | You investigate but never respond |
| Commercial realism | XINTRA APT emulation labs [R23], The DFIR Report's DFIR Labs [R4] | Closed and sold per case or by subscription |
| Adaptive live-fire | DEF CON "Beat the Breach" [R5] | Reacts to your decisions, but it's a one-day, $2,250 instructor-led course |
| Generators and ranges | ForTrace++ [R6], KYPO (MIT, development has ended) [R7], GHOSTS [R8] | Building blocks, not a curriculum |

Each ingredient exists somewhere. The combination of open, free, seeded,
consequential, continuous and cited didn't turn up anywhere in the October 2026
search. That's a claim about what was found, not proof that nothing else
exists.

### Non-goals

- **Not a malware zoo.** No live malware, and no working exploits for
  unpatched vulnerabilities. Emulation reproduces behavior and artifacts.
- **Not a red team lab.** Attacker emulation exists only to create evidence
  for defenders.
- **Not an exam.** The seal on the answers is a spoiler guard, not DRM (see §9).
- **Not tied to a vendor.** Packs ship raw evidence. SIEM loaders are optional
  conveniences.

---

## 2. Principles

Every component obeys these. A pull request that breaks one needs a reason
written down, not just a passing build.

1. **Ground truth comes from what happened, not what was planned.** Answers
   are read from the execution ledger. If an action fails, the run fails. A
   pack is never shipped with an answer key describing something that didn't
   happen.
2. **Every answer must be provable from the evidence.** The verifier checks
   that each question can be answered from artifacts that are actually in the
   pack, at that pack's logging level. If a question can't be answered, the
   pack doesn't ship.
3. **Measure artifacts, don't assume them.** What a given logging level
   records gets established by testing on the golden image, not from
   documentation or memory.
4. **Lab plumbing is named, never disguised.** Anything the lab needs that a
   real company wouldn't run (the user simulator, provisioning traces) is
   documented in the Orientation episode and in every pack README as out of
   scope.
5. **Nothing points at the real world.** Domains use `.example` (except the AD
   domain, which uses `.internal`), IPs come from documentation ranges, and
   the company and people are fictional (§3.6).
6. **No hidden exclusions.** Defender stays on wherever a real company would
   have it on. If the story needs Defender to look away, the attacker does that
   in the story, and the evidence shows it.
7. **Every attacker stage cites a source that was actually opened.** Same
   rule as the blog: if a source can't be opened, it can't be cited.
8. **Beginners never need a big machine.** Tiers 0–2 ship as evidence packs
   you can work on a laptop with Python 3.

---

## 3. The company: Rimeport Cold Logistics

### 3.1 Why a cold-chain distributor

- **No IR lab built around it turned up.** The October 2026 searches found
  cold-chain repos only on the logistics and IoT side.
- **It really gets targeted.** In December 2020, CISA amplified IBM X-Force
  reporting on phishing aimed at executives and organizations involved in
  vaccine storage and transport, the cold chain [R9].
- **It gives containment a real cost.** Refrigeration doesn't stop for an
  incident. When monitoring goes dark, staff switch to manual temperature
  logs, risk to stored product grows, and shipping slows down. Every
  containment decision gets weighed against product on the dock.
- **It ties to the blog.** The refrigeration-controller and ConnectWise
  backup posts cover the same terrain.

### 3.2 Profile

| | |
|---|---|
| Legal | Privately held, United States |
| Business | Temperature-controlled warehousing and regional trucking for grocery and food-service customers |
| Size | About 650 staff, mostly warehouse and drivers. About 120 use a computer daily. |
| Sites | HQ (US Eastern time), North Yard warehouse (US Central), South Yard warehouse (US Eastern) |
| IT | Four-person team at HQ, plus a refrigeration vendor with remote support access |
| Cyber insurance | Yes. The policy requires notifying the insurer and using its panel responders (this drives Tier 5). |

Two time zones are deliberate. Timestamps in local time versus UTC is a lesson
the company teaches without any extra effort.

### 3.3 Systems (canon)

| Host | Role | First used in |
|---|---|---|
| `DC01` | AD DS + DNS, `corp.rimeport.internal` | S1E0 |
| `WS-DSP-*` | Dispatch workstations, Windows 11 | S1E1 |
| `WS-FIN-*`, `WS-IT-*` | Finance and IT workstations | S1E2 |
| `FS01` | File server with shared drives | S1E2 |
| `VPN01` | Remote-access gateway with AD-backed sign-in (open-source, Linux) | S1E2 |
| `APP01` | TEMPWATCH, the fictional cold-room monitoring service | v0.2 |
| `ESX01` | Hypervisor running the warehouse management and TEMPWATCH VMs | S1E4 |
| `BKP01` | Backup server | S1E4 |
| `GW01` | Firewall and router between segments | S1E0 |
| Cloud | Microsoft 365 / Entra ID tenant (synthesized logs, §7.5), fleet telematics SaaS | S1E1 |

### 3.4 People

About 40 named personas are canon in `world/personas/`, each with a role,
site, working hours, habits, saved browser credentials and a primary
workstation. Everyone else exists as an account with light activity. Personas
belong to the world, not to a seed. A seed picks which eligible persona gets
phished, but the dispatcher in S1E1 is the same person with the same habits in
S1E4.

### 3.5 History (the residue that makes it feel real)

`world/history.yaml` holds events from before Season 1 that leave traces in
every pack. Some examples to draft:

- A former IT admin's account is disabled but still sits in a privileged group.
- The refrigeration vendor's support account is active, uses the VPN, and
  signs in at odd hours for legitimate reasons. It's a built-in red herring,
  and in some seeds it's the real way in.
- A 2025 cleanup on a warehouse kiosk deleted a coin miner but left its
  scheduled task behind, which still fails every night.
- A service account with an SPN and a password older than most of the staff.

The Orientation episode teaches these, so learners have to tell old residue
from new activity.

### 3.6 Naming rules

| Thing | Rule |
|---|---|
| Public domain | `rimeport.example` (`.example` is reserved by RFC 2606) |
| AD domain | `corp.rimeport.internal`, NetBIOS `RIMEPORT`. Not `.example`: Windows Server 2025's DNS refused to create a `.example` zone (error 123, 2026-10-29). ICANN reserved `.internal` for private use (resolution 2024.07.29.06). |
| Attacker domains | Generated per seed, always under `.example` |
| Internal IPs | `10.20.0.0/16` |
| "Internet" IPs | RFC 5737 documentation ranges `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`; IPv6 `2001:db8::/32` |
| Real services | Microsoft service endpoints such as `login.microsoftonline.com` may appear, because they're the services being modeled |
| People | Fictional. No real person, company, brand or regulator is depicted. |

"Rimeport" turned up no company match in an October 2026 web search and has
no GitHub user, org or repo. Check again before going public.

---

## 4. Learning pathway

The tiers map to NIST SP 800-61r3, which frames incident response as a
CSF 2.0 community profile [R10].

| Tier | Level | Learner can | CSF 2.0 focus | Needs |
|---|---|---|---|---|
| 0 Orientation | Beginner | Describe normal at Rimeport: who logs in where, what runs at 02:00, what's old residue | ID.AM, DE.CM | Laptop |
| 1 Triage | Beginner | Work one host and one story from default logs to a defensible answer | DE.AE | Laptop |
| 2 Scoping | Intermediate | Follow the attacker across hosts and identities, and reconcile clock skew and time zones | RS.AN, RS.MA | Laptop |
| 3 Containment | Advanced | Contain on a live range where every action has consequences and a business cost | RS.MI | Live range |
| 4 Blind terrain | Expert | Investigate where EDR doesn't reach: hypervisor, backups, appliances | RS.AN, RS.MI, RC.RP | Live range or pack |
| 5 Command | Expert | Run the incident: brief stakeholders, make decisions under deadlines, write the report | RS.MA, RS.CO, RC.CO | Optional LLM |

### Season 1: Thaw

The storyline follows the pattern in CISA's Akira advisory: access through a
VPN without MFA, abuse of valid credentials, attacks on backup servers, and a
Linux encryptor aimed at ESXi [R11]. One difference is deliberate. The
advisory's backup-server step exploits known Veeam vulnerabilities, while
Season 1 reaches the backup server with stolen admin credentials. That way the
lab never needs exploit code.

| Episode | Tier | Milestone | Story |
|---|---|---|---|
| S1E0 Shift Change | 0 | v0.1 | 24 hours of normal. No incident. Questions about the baseline. |
| S1E1 Bill of Lading | 1 | v0.1 | A dispatcher opens a lure. Browser-saved credentials get read and sent out. One host. |
| S1E2 Manifest | 2 | v0.1 | Those credentials sign in to the VPN and webmail, and the attacker moves to the file server. Several hosts plus identity. |
| S1E3 Excursion | 3 | v0.3 | Live. The attacker is present, containment has consequences, and the business clock is running. |
| S1E4 Thaw | 4 | v0.4 | Privilege escalation, then the backup server, then ESXi. The encryption endgame. |
| S1E5 Debrief | 5 | v0.5 | The whole season as incident commander, with stakeholders and a final report. |

---

## 5. Telemetry profiles

Every episode declares which profiles it supports. The same seed under two
profiles is the same incident. Only the evidence differs.

| Profile | Endpoint | Network | Cloud | Where logs live |
|---|---|---|---|---|
| `bare` | Windows defaults: default audit policy, default log sizes, Defender on, no Sysmon | Firewall logs only | Default logs | Locally on each host |
| `managed` | + Sysmon, advanced audit policy with process command lines, PowerShell script block logging | + DNS query logs, Zeek on the core segment | Same | Forwarded to a SIEM |
| `instrumented` | + EDR-grade telemetry, memory images of key hosts | + Full packet capture at the internet edge | Same | SIEM |

Exact settings for each profile live in `range/profiles/` and get tested on the
golden image (principle 3). Which product fills `managed` and `instrumented` is
open decision D4.

---

## 6. Scenario format

Scenarios are YAML, validated against a JSON Schema in `engine/schema/`.
Below is an illustrative excerpt of S1E1. The source IDs are placeholders. The
real entries go through `sources/sources.yaml` and must be opened before
they're cited.

```yaml
id: s1e1
title: Bill of Lading
season: 1
tier: 1
world: rimeport@0.1          # canon version this was written against
profiles: [bare, managed]
briefing: briefings/s1e1.md  # what the analyst is told, templated per seed
debrief: debriefs/s1e1.md    # the method, public; seed values filled in after grading

window:
  baseline: 9h               # real-time normal activity first; one working day for Tier 1 (D9)
  incident: 2h-6h            # length drawn per seed

params:
  victim:
    pick: persona
    where: { department: dispatch, has_saved_browser_creds: true }
  workstation: "{victim.primary_host}"
  stage_domain: { gen: lookalike_domain, tld: example }
  stage_ip:     { gen: ip, from: 203.0.113.0/24 }
  start:        { gen: business_hours, tz: "{victim.site.tz}" }

stages:
  - id: initial-access
    technique: T1566.001
    variants:                 # one is picked per seed, by weight
      - id: zip-lnk
        weight: 3
        sources: [src-0001]
        actions:
          - user.open_mail:   { attachment: "{lure.file}" }
          - user.extract:     { archive: "{lure.file}", to: Downloads }
          - user.open_file:   { path: "{lure.inner_file}" }
      - id: html-smuggling
        weight: 2
        sources: [src-0002]
        actions: [ ... ]
    facts:                    # read from the ledger, never from the plan
      initial_file:   ledger.user.open_file.path
      first_exec_utc: ledger.process_start[0].time

  - id: collection
    technique: T1555.003
    after: initial-access
    delay: 2m-25m
    actions:
      - implant.read_files: { paths: "{victim.browser_profile}/Login Data" }
      - implant.archive:    { out: "%TEMP%\\{gen.word}.zip" }
    facts:
      staged_archive: ledger.implant.archive.out
      cred_sites:     world.personas[victim].saved_creds.sites

  - id: exfiltration
    technique: T1041
    after: collection
    actions:
      - implant.upload: { file: "{collection.staged_archive}", to: "https://{stage_domain}/u" }
    facts:
      exfil_dest: "{stage_domain}"

expects:                      # the verifier fails the pack if any are missing
  bare:
    - { id: e1, stage: initial-access, artifact: lnk_file,     host: "{workstation}" }
    - { id: e2, stage: initial-access, artifact: prefetch,     host: "{workstation}" }
    - { id: e3, stage: exfiltration,   artifact: firewall_conn, dst: "{stage_ip}" }
  managed:
    - { id: e4, stage: initial-access, artifact: sysmon.1,     host: "{workstation}" }
    - { id: e5, stage: exfiltration,   artifact: dns_query,    name: "{stage_domain}" }

questions:
  - id: q1
    ask: Which file did the user open that started the compromise? Give its full path.
    answer: { fact: initial-access.initial_file, match: path }
    evidenced_by: [e1, e2, e4]
  - id: q2
    ask: When did the first attacker-controlled process start, in UTC?
    answer: { fact: initial-access.first_exec_utc, match: time, tolerance: 60s }
    evidenced_by: [e2, e4]
  - id: q3
    ask: Which domain received the stolen data?
    answer: { fact: exfiltration.exfil_dest, match: domain }
    evidenced_by: [e5]
    profiles: [managed]       # under bare, only the IP is in the evidence
  - id: q4
    ask: Which sites' saved credentials should the company treat as compromised?
    answer: { fact: collection.cred_sites, match: set }

reactions: []                 # v0.3, see §11
```

Rules the validator enforces:

- Every variant names at least one source, and every source ID exists in
  `sources/sources.yaml` with a URL, tier and the date it was opened.
- Every question names `evidenced_by` entries that exist in each profile the
  question is offered under.
- Every `fact` resolves to a ledger path, a world path or a param.
- Every technique ID is a valid ATT&CK ID.
- Stage `after` links form a DAG.

---

## 7. The generator

```
seed + scenario + world + profile
        │
   1 compile ──► plan.json            all choices resolved, schedule fixed
   2 provision ─► range at T0          golden checkpoint for the profile, canon applied
   3 execute ──► ledger.jsonl          user simulator + emulation agent follow the plan
   4 collect ──► host + network evidence
   5 synthesize ► cloud logs            consistent with the ledger
   6 verify ───► pass / fail            expects, answerability, leaks, time sanity
   7 seal ─────► answers.sealed.json
   8 package ──► pack directory + SHA256SUMS
```

### 7.1 Seeds and determinism

A seed looks like `S1E1-7F3A-91C2`. Every random choice comes from a keyed
derivation, `HMAC-SHA256(seed, scenario_id ‖ world_version ‖ decision_path)`,
rather than a running PRNG. Adding a new stage doesn't reshuffle choices that
already exist, and results don't depend on any language's random-number
implementation.

The determinism boundary: the same seed always gives the same **plan** (who,
what, when, which variant, which names). Captured host artifacts still differ
in incidental details like process IDs, GUIDs and millisecond timing. That's
fine, because the answers come from the ledger (principle 1).

### 7.2 Execution

- **User actions** (open the email, extract the zip, double-click) are carried
  out on the workstation by the user simulator, so the artifacts look like a
  person did it. GHOSTS is the candidate simulator [R8].
- **Attacker actions** come from the emulation agent running as the attacker's
  process. That way the process trees, network connections and file writes
  belong to the attacker, not to lab plumbing. Which agent to use is open
  decision D5.
- **Each action** writes a ledger record: action, host, account, process,
  start and end time in UTC, and outputs.

### 7.3 Time

v0.1 runs in real time. Faking time by changing guest clocks writes
time-change events into the very logs learners are reading, so it's ruled out.
A shared baseline restored from a checkpoint doesn't work either: the restored
guest wakes up at the real current time, which leaves a gap between the
baseline's last event and the incident's first.

That has a cost, and it's the main constraint on how many seeds can ship:

- One pack takes its baseline plus its incident window plus collection, about
  30 hours with a 24-hour baseline. The v0.1 topology (~17 GB) leaves room for
  two range instances on 64 GB, so expect about ten packs a week.
- v0.1 targets ten seeds per profile for S1E1 and S1E2, and three for S1E0.
  That's 46 packs, or about five weeks of machine time. Shorter baselines for
  Tier 1 (one working day instead of 24 hours) are the main lever if that's
  too slow (open decision D9).
- Clock skew is a seeded parameter. One host may get Hyper-V time sync turned
  off and its clock offset, which gives learners the skew problem real
  incidents have.

### 7.4 Collection

Host evidence is a triage collection gathered with a Velociraptor offline
collector using the KapeFiles target definitions. Velociraptor is AGPL and the
KapeFiles targets are MIT [R12]. Packs contain the collected files, never the
collector binary. Firewall, DNS and Zeek logs come from the segment hosts.
Memory images are `instrumented` only, because of their size.

### 7.5 Synthesis

The Microsoft 365 and Entra ID logs (sign-ins, unified audit log, message
trace) are JSON with documented schemas, so they get synthesized rather than
pulled from a real tenant. Schema files live in `engine/schemas/` with a link
to the Microsoft reference for each one. Synthesized events are tied to the
ledger: a VPN sign-in at time *t* produces matching identity events, and every
persona's normal cloud activity is generated from their schedule.

Each pack's README says which sources were captured and which were
synthesized. Learners are told this upfront.

### 7.6 Verification

The verifier works like the blog's validator: the pack ships only if it passes.

| Check | Fails when |
|---|---|
| Expects | Any `expects` artifact for the profile is missing |
| Answerability | A question has no matching artifact in the pack |
| Leaks | Evidence contains plumbing strings (`packer`, `vagrant`, ledger IDs, `coldchain`) or any non-reserved domain or IP outside the allowlist |
| Time | Events fall outside the window, or ledger and artifact times disagree beyond tolerance |
| Canon | A persona, host or account doesn't match the world version |

Every realism bug found after release becomes a new check.

---

## 8. Evidence pack format

```
rimeport-s1e1-7F3A-91C2-bare/
  README.md              briefing, scope, what's synthesized, lab plumbing to ignore
  pack.json              seed, scenario/world/generator versions, profile, hashes
  questions.yaml         questions only, no answers
  answers.sealed.json    see §9
  debrief.sealed         seed-specific values for the public debrief template
  evidence/
    hosts/WS-DSP-07/     triage collection
    hosts/DC01/
    network/             firewall (+ DNS, Zeek under managed)
    cloud/               entra-signins.jsonl, m365-audit.jsonl, message-trace.jsonl
  SHA256SUMS
```

Packs are released as GitHub release assets. Each file has to stay under
2 GiB [R13], so collections are compressed and split when needed. Memory
images, when they arrive, will need other hosting (open decision D8).

---

## 9. Grader

`coldchain grade <pack> <answers.yaml>` uses only the Python 3 standard
library, so learners don't install anything else.

**Sealing.** Each answer is normalized, salted per pack, and stored as a
SHA-256 hash.

| Match type | Normalization | Scoring |
|---|---|---|
| `path` | Case-folded, unified separators | Exact |
| `domain` | Lowercase, no trailing dot | Exact |
| `host` | Short name, uppercase; FQDN accepted | Exact |
| `account` | `DOMAIN\user`, UPN or SID, all mapped to one canonical form | Exact |
| `time` | Parsed to UTC, then bucketed. Hashes for every bucket inside the tolerance are stored. | Within tolerance |
| `set` | Each element normalized and hashed. Set size stored. | Precision, recall, F1 |

**Honesty model.** The seal stops accidental spoilers. It doesn't stop
someone determined, since small answer spaces can be brute-forced and the
generator is open source. That's fine for a training lab, and the README says
so plainly.

**After grading.** The episode's debrief (the method) is public in the repo,
and writeups are encouraged. Seed-specific values get filled in by the grader
only after a graded submission exists.

---

## 10. The range

### 10.1 Substrate

The range runs on the owner's Windows 11 Pro workstation under Hyper-V: an
i9-12900K with 64 GB of RAM. VM storage goes on `E:` (about 800 GB free).
Docker Desktop's WSL2 backend already uses the Windows hypervisor.

| Layer | Tool | Why |
|---|---|---|
| Golden images | Packer, Hyper-V ISO builder | Built from the learner's own ISOs, since Windows images can't be redistributed |
| Topology | A thin PowerShell module (`range/CCRange`) | Hyper-V cmdlets are first-class. Vagrant ignores network settings on Hyper-V and can't set static IPs [R14]. |
| Guest configuration | PowerShell over PowerShell Direct (Windows), Ansible from WSL (Linux) | PowerShell Direct needs no guest network adapter, so control traffic stays out of network evidence. It still leaves sign-in traces inside the guest, which principle 4 covers. |
| Disks | Differencing VHDX on top of golden images | Several instances without copying the base image each time |

Windows media comes from Microsoft's Evaluation Center: Windows 11 Enterprise
is a 90-day evaluation and Windows Server a 180-day one [R15]. Ranges get
rebuilt, not renewed.

### 10.2 Segments

| Switch | Range | Holds |
|---|---|---|
| `cc-corp` | `10.20.10.0/24` | DC01, FS01, APP01 |
| `cc-users` | `10.20.20.0/24` | Workstations |
| `cc-dmz` | `10.20.30.0/24` | VPN01 |
| `cc-mgmt` | `10.20.40.0/24` | ESX01, BKP01 (Season 1, Tier 4) |
| `cc-inet` | RFC 5737 ranges | Fake DNS, fake SaaS front doors, attacker infrastructure |

All of these are Hyper-V **private** switches, so nothing routes to the host
or the real internet. GW01 routes between them. Each range instance gets its
own set of switches, so instances can run side by side.

### 10.3 Memory budget

| Milestone | VMs | Approx. RAM |
|---|---|---|
| v0.1 | DC01, two workstations, FS01, VPN01, GW01, INET01, ATK01 | ~17 GB |
| v0.2 | + SIEM01, APP01, third workstation | ~31 GB |
| v0.4 | + BKP01, ESX01 (nested) | ~43 GB |

### 10.4 The ESXi problem (open decision D1)

ESXi 8 has no working path nested under Hyper-V. ESXi doesn't work well with
Hyper-V's synthetic network adapters. The documented workaround (a legacy
adapter plus an injected net-tulip driver) is written for ESXi 5.1 and 6.0,
and a 2023 question about vSphere 8 on that guide went unanswered [R16].
VMware Workstation can't pass hardware virtualization through to guests while
Hyper-V or VBS is on [R17], and turning those off also breaks Docker Desktop
and the rest of this range.

Options, to settle before v0.4. v0.1 to v0.3 aren't affected.

| Option | Cost | Realism |
|---|---|---|
| A. A second machine running Proxmox, just for Tier 4. Nested ESXi 8 is reported working there with vmxnet3 and checksum offload disabled (a forum report, not official) [R18]. | Hardware | Full |
| B. Turn Hyper-V off on capture days and run Tier 4 under VMware Workstation. One news report says the free ESXi build "does not appear to run in desktop hypervisors" [R24], so test this first. | Two substrates to maintain | Full, if it runs |
| C. ESXi with no running VMs, under Workstation on Hyper-V | None | Loses the kill-the-VMs-then-encrypt artifacts |

Free ESXi is available again as 8.0 Update 3e. Broadcom aims it at home labs
and dev/test, with no official support, a limit of 8 vCPUs per VM, and no
vCenter. It downloads from the Broadcom Support Portal [R19]. VMware
Workstation Pro has been free for all users since November 2024 [R20].
Learners download both themselves. Tier 4 also ships as evidence packs, so
learners without this hardware can still play it.

---

## 11. The reactive adversary (v0.3)

The graded core is a **deterministic state machine**, not an LLM. It watches
for defender actions it can observe on the range, and the scenario's
`reactions` decide what happens next.

```yaml
reactions:
  - on:   { defender: password_reset, account: "{victim.account}" }
    if:   { reached: persistence, unless: { token_revoked: "{victim.account}" } }
    then: { continue: true }          # the refresh token still works
  - on:   { defender: host_isolated, host: "{workstation}" }
    if:   { before: lateral-movement }
    then: { branch: fallback-vpn }    # the attacker comes back in through the vendor account
  - on:   { clock: business, at: 4h }
    then: { inject: "Ops: North Yard is on paper logs, two trucks held" }
```

Defender actions are detected from the range itself (directory changes,
switch port state, firewall rules, account and token state). Learners don't
report them. The **business clock** counts operational cost (monitoring dark,
trucks held, product at risk), and every containment action has a cost listed
in the scenario. Tier 3 grading weighs whether the attacker was evicted, how
fast, and what it cost.

---

## 12. The agent crew

There are two kinds of agents. The **build crew** helps write the lab. The
**cast** runs inside the lab for learners. A human approves everything that
ships.

### 12.1 Build crew (Claude Code subagents in `.claude/agents/`)

| Agent | Owns | Never |
|---|---|---|
| `scenario-architect` | Drafts scenarios and source registry entries from public primary sources it has opened | Cites a source it couldn't open, or invents tradecraft the sources don't describe |
| `world-keeper` | Rimeport canon: personas, systems, history. Checks continuity across episodes. | Changes canon without bumping the world version |
| `range-engineer` | Packer templates, `CCRange`, profile settings, golden-image tests | Adds Defender exclusions or plumbing that the docs don't name |
| `artifact-verifier` | `engine/verify`. Turns every realism bug into a new check. | Weakens a check to get a pack to pass |
| `grader-smith` | Questions, normalizers, fact extractors, answerability | Writes a question without `evidenced_by` |
| `release-steward` | Changelog, docs, issue triage, release checklist, pack publishing | Publishes anything without the owner's approval |

Everything the crew writes is a draft until the owner approves it. Scenario
files carry `draft: true` until then.

### 12.2 Cast (inside the lab, optional, learner's own API key)

| Role | Tier | Does | Guardrails |
|---|---|---|---|
| Adversary operator | 3+ | Free-play mode: an LLM drives the attacker | Can only use the scenario's action vocabulary (no free-form shell). Refuses to run outside a range it can verify. Logs everything to the ledger. Not graded beyond outcomes. |
| Stakeholders | 5 | CEO, general counsel, VP Operations, communications lead, the insurer's breach coach, a key customer | Fictional people only. Each has goals, a limit on what they know, and pressure points. Scored on timeliness, accuracy, no overclaiming, and clear decision requests. |
| Report coach | 1+ | Reviews the learner's incident report against `rubrics/report.yaml` and the unsealed answers | Runs only after grading. Gives feedback, not answers. |

The cast is pluggable across model providers, with Claude as the default. No
tier requires it.

---

## 13. Safety and legal

- **Isolation.** Private switches only. The internet is simulated, and
  attacker infrastructure uses documentation IP ranges.
- **No live malware.** The emulation agent reproduces behavior. Season 1
  uses stolen credentials, not exploits. Later seasons model appliance attacks
  against a fictional appliance with a fictional flaw, not real exploit code.
  GitHub allows dual-use security research but doesn't allow its platform to
  be used "in direct support of unlawful attacks that cause technical
  harms" [R21]. The repo stays well inside that line.
- **No redistributed vendor software.** Learners supply Windows, ESXi and any
  other vendor media.
- **No real-world identities.** See §3.6.
- **Licenses (proposed).** Apache-2.0 for code, CC BY 4.0 for scenarios,
  world and docs. Third-party tools are dependencies, not vendored.
- **Voice.** This is built in public by a practitioner three years into the
  cybersecurity industry. Neither the README nor the docs claim experience
  beyond what the labs themselves show.

---

## 14. Repo layout

```
coldchain-ir/
  README.md
  CLAUDE.md               rules for agents working here
  docs/DESIGN.md          this file
  world/                  Rimeport canon: org, sites, personas/, systems, history
  scenarios/s1/           episode YAML, briefings/, debriefs/
  sources/sources.yaml    every citation, recorded once
  engine/                 compile, execute, collect, synthesize, verify, seal, package
  grader/                 coldchain grade (stdlib-only Python)
  range/                  packer/, CCRange/, profiles/
  adversary/              emulation agent, reaction state machine
  cast/                   stakeholders, operator, coach (optional)
  rubrics/                report and Tier 5 rubrics
  .claude/agents/         build crew
  .github/workflows/      schema, lint, grader and verifier tests
```

---

## 15. Milestones

| Version | Ships | Done when |
|---|---|---|
| **v0.1 Ground truth** | World canon `rimeport@0.1`; scenario schema and validator; compiler; v0.1 range; executor and ledger; collection; cloud synthesis; verifier; grader; S1E0–E2 × 10 seeds × `bare` and `managed` | Someone who has never seen the repo downloads a pack, answers, grades and reads the debrief without asking for help. At least two outside testers finish S1E1. Every pack passes the verifier. **The repo goes public at this point.** |
| v0.2 Live range | Learners build Rimeport themselves; user simulation; SIEM for `managed` | A fresh Windows machine reaches a working range by following the docs alone |
| v0.3 It fights back | Reactions, defender-action detection, business clock; S1E3 | Two different containment choices on the same seed lead to measurably different outcomes |
| v0.4 Blind terrain | ESXi and backup stages; S1E4 | D1 resolved; ESXi and backup artifacts verified |
| v0.5 Command | Cast, coach, rubrics; S1E5 | Season 1 can be played end to end |

Each milestone also becomes a draft entry in the portfolio's Lab Builds and
Writeups category.

---

## 16. Open decisions

| ID | Decision | Needed by | Leaning |
|---|---|---|---|
| D1 | Hypervisor substrate for ESXi (§10.4) | v0.4 | A: second machine with Proxmox |
| D2 | A second range substrate (Proxmox/Ludus) so Linux and macOS users can run Tier 3+ | v0.2 | Evidence packs first, then decide based on demand |
| D3 | Backup product for BKP01: the commercial free tier attackers actually target, or open source | v0.4 | Follow the sources: CISA names Veeam [R11]. Check the free edition's license terms first. |
| D4 | Products behind `managed` and `instrumented` | v0.2 | Undecided |
| D5 | Emulation agent: Caldera's agent, or a small range-locked agent that only runs signed plan tasks | v0.1 | Range-locked |
| D6 | Model provider interface for the cast | v0.5 | Pluggable, Claude by default |
| D7 | Display name COLD CHAIN, slug `coldchain-ir`. GitHub user `coldchain` and org `cold-chain` exist and are unrelated, so the repo lives under the owner's account. | Before going public | Keep |
| D8 | Hosting for files over 2 GiB (memory images) | `instrumented` | Undecided |
| D9 | Seeds versus machine time: baseline length per episode, and how many seeds to launch with (§7.3) | v0.1 | 24-hour baseline for S1E0 and S1E2, one working day for S1E1 |

---

## References

All opened and checked on 2026-10-19. Community and secondary sources are
labeled as such and are used only where no primary source covers the point.

- [R1] GitHub repository search for "sherlocks writeup": 64 results, for example https://github.com/jon-brandy/hackthebox and https://github.com/h0ny/HackTheBox-Sherlocks-Writeups
- [R2] A single writeup repo covering CyberDefenders, Security Blue Team, LetsDefend, HackTheBox and TryHackMe labs, https://github.com/ChickenLoner/Write_It_UP
- [R3] Ludus documentation, https://docs.ludus.cloud/docs/intro/
- [R4] The DFIR Report, DFIR Labs, https://thedfirreport.com/products/dfir-labs/
- [R5] DEF CON Training 2026, "Beat the Breach: Defend, Respond, Survive", https://training.defcon.org/products/beat-the-breach-defend-respond-survive-mckay-hardy-wes-wagstaff-dctlv2026
- [R6] ForTrace++ workshop, IMF conference, https://www.uni-saarland.de/en/lehrstuhl/brodowski/veranstaltungen/imf-conference/conference-program/workshop-i.html (code at https://gitlab.com/DW0lf/fortrace)
- [R7] KYPO Cyber Range Platform, https://crp.kypo.muni.cz/
- [R8] CMU SEI GHOSTS releases, https://github.com/cmu-sei/GHOSTS/releases (MIT-style SEI license)
- [R9] CISA, "IBM Releases Report on Cyber Actors Targeting the COVID-19 Vaccine Supply Chain", December 3, 2020, https://www.cisa.gov/news-events/alerts/2020/12/03/ibm-releases-report-cyber-actors-targeting-covid-19-vaccine-supply
- [R10] NIST SP 800-61 Rev. 3, "Incident Response Recommendations and Considerations for Cybersecurity Risk Management: A CSF 2.0 Community Profile", April 2025, https://csrc.nist.gov/pubs/sp/800/61/r3/final
- [R11] CISA, "#StopRansomware: Akira Ransomware" (AA24-109A), published April 18, 2024, revised November 13, 2025, https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-109a
- [R12] Velociraptor downloads (AGPL), https://docs.velociraptor.app/downloads/previous_downloads/; KapeFiles (MIT), https://github.com/EricZimmerman/KapeFiles
- [R13] GitHub Docs, "About releases", https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases
- [R14] HashiCorp, Vagrant Hyper-V provider limitations, https://developer.hashicorp.com/vagrant/docs/providers/hyperv/limitations
- [R15] Microsoft Evaluation Center, Windows 11 Enterprise (90 days), https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise; Windows Server 2025 (180 days), https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025
- [R16] TurboGeek, "Deploy a Nested VMware ESXi host in Hyper-V", https://turbogeek.co.uk/?p=2358 (community source)
- [R17] Broadcom KB 389469, "Virtualized Intel VT-x/EPT is not supported on this platform", https://knowledge.broadcom.com/external/article/389469/virtualized-intelvtxept-is-not-supporte.html
- [R18] Proxmox forum, "Nested ESXi 8.0U2 on PVE 8.2-1", https://forum.proxmox.com/threads/nested-esxi-8-0u2-on-pve-8-2-1.163139/ (community source)
- [R19] Broadcom KB 399823, "VMware ESXi 8.0 Update 3e now available as a Free Hypervisor", https://knowledge.broadcom.com/external/article/399823/vmware-esxi-80-update-3e-now-available-a.html
- [R20] Wikipedia, "VMware Workstation", https://en.wikipedia.org/wiki/VMware_Workstation (secondary)
- [R21] GitHub Docs, "Active Malware or Exploits", https://docs.github.com/en/site-policy/acceptable-use-policies/github-active-malware-or-exploits
- [R22] DetectionLab README, https://github.com/clong/DetectionLab
- [R23] XINTRA, https://www.xintra.org/
- [R24] Techzine, "Free VMware ESXi hypervisor returns", April 14, 2025, https://www.techzine.eu/news/infrastructure/130544/free-vmware-esxi-hypervisor-returns/ (secondary)
