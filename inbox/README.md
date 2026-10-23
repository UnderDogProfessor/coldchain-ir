# Inbox: your private drop folder

This repo is public, but **everything in this folder is ignored by Git**. Nothing
here goes to GitHub until it's been reviewed and copied into `notes/`.

That matters because a raw screenshot can show more than you meant to: your
real taskbar, your real desktop, a notification. Dropping files here first
means you can save things quickly without worrying about that.

## Where things go

```
inbox/
  lab-2/   screenshots (.png), exports (.evtx), rough notes for Lab 2
  lab-3/   the same for Lab 3
```

Name files the way the lab suggests, for example `lab3-created.png` and
`lab3-new-account.evtx`.

## Your notes

Fill in the notes page for each lab directly, in any text editor (Notepad is
fine):

- `notes/level-1/02-someone-is-guessing-passwords.md`
- `notes/level-1/03-a-new-account-appeared.md`

Saving the file doesn't publish it. Only a commit and push does, and that
happens after Claude has read it.

## When you're done with a lab

Tell Claude "Lab N is ready". Claude reads your notes and the files in this
folder (including `.evtx` exports, directly, so you don't need to paste
records), tidies the wording, copies the screenshots and evidence you want
shared into `notes/`, and commits.
