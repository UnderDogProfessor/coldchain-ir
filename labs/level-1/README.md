# Level 1: Basics

Short, hands-on labs on one Windows computer. Each takes about an hour and
needs no prior incident response experience.

| # | Lab | You'll learn | Status |
|---|---|---|---|
| 0 | [Before you start](00-setup.md) | Build the lab computer in VMware (once) | Ready, tested |
| 1 | [What normal looks like](01-what-normal-looks-like.md) | Read sign-in records in Event Viewer | Ready, tested |
| 2 | [Someone is guessing passwords](02-someone-is-guessing-passwords.md) | Find failed sign-ins: who, when, from where | Ready, tested |
| 3 | [A new account appeared](03-a-new-account-appeared.md) | Find who created an account and whether it got admin rights | Ready, tested |
| 4 | [Something runs at startup](04-something-runs-at-startup.md) | Find what was set up to survive a reboot | Ready, tested |
| 5 | [Write it up](05-write-it-up.md) | Turn what you found into a one-page summary | Ready, not yet tested |

Do them in order. Each lab builds on the one before.

**Keep notes as you go.** Copy the [notes template](notes-template.md) for
each lab, write down what you did and when, and take a screenshot wherever a
lab shows 📸. It's how real responders work, and it leaves you a record you
can look back on. Lab 5 adds a one-page [report template](report-template.md).

Finished a lab? Compare with [my notes](../../notes/README.md) from my own run.

**Writeups on my website:**
[Lab 1](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/level-1/lab-1/),
[Lab 2](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/level-1/lab-2/),
[Lab 3](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/level-1/lab-3/),
[Lab 4](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/level-1/lab-4/),
the [Level 1 page](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/level-1/), or the whole [COLD CHAIN series](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/).

**Explainers** go deeper on things the labs turn up:

- [DWM and UMFD, explained](../explainers/dwm-and-umfd.md): the "accounts"
  that sign in when Windows starts, and what they tell you (Lab 1)
