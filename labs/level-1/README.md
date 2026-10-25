# Level 1: Basics

Short, hands-on labs on one Windows computer. Each takes about an hour and
needs no prior incident response experience.

| # | Lab | You'll learn | Status |
|---|---|---|---|
| 0 | [Before you start](00-setup.md) | Build the lab computer in VMware (once) | Ready, tested |
| 1 | [What normal looks like](01-what-normal-looks-like.md) | Read sign-in records in Event Viewer | Ready, tested |
| 2 | [Someone is guessing passwords](02-someone-is-guessing-passwords.md) | Find failed sign-ins: who, when, from where | Ready, tested |
| 3 | [A new account appeared](03-a-new-account-appeared.md) | Find who created an account and whether it got admin rights | Ready, tested |
| 4 | Something runs at startup | Find what was set up to survive a reboot | Coming soon |
| 5 | Write it up | Turn what you found into a one-page summary | Coming soon |

Do them in order. Each lab builds on the one before.

**Keep notes as you go.** Copy the [notes template](notes-template.md) for
each lab, write down what you did and when, and take a screenshot wherever a
lab shows 📸. It's how real responders work, and it leaves you a record you
can look back on.

Finished a lab? Compare with [my notes](../../notes/README.md) from my own run.

**Writeups on my website:**
[Lab 1](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/lab-1/),
[Lab 2](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/lab-2/),
or the whole [COLD CHAIN series](https://cyberneticsintern.com/projects/lab-builds-and-writeups/coldchain-ir/).

**Explainers** go deeper on things the labs turn up:

- [DWM and UMFD, explained](../explainers/dwm-and-umfd.md): the "accounts"
  that sign in when Windows starts, and what they tell you (Lab 1)
