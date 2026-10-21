# DWM and UMFD, explained

**Read this after:** [Lab 1: What normal looks like](../level-1/01-what-normal-looks-like.md)

In Lab 1 you found sign-in records for accounts named **DWM-1**, **UMFD-0** and
**UMFD-1**. They look like people signing in (Logon Type 2), but they aren't.
This page explains what they are, why they're there, and what they can tell
you during an investigation.

## The short version

| Account | Account Domain | Belongs to | Its job |
|---|---|---|---|
| **DWM-1** | Window Manager | Desktop Window Manager (`dwm.exe`) | Draws everything you see on screen |
| **UMFD-0**, **UMFD-1** | Font Driver Host | User-Mode Font Driver Host (`fontdrvhost.exe`) | Reads font files and turns them into letters on screen |

Both are parts of Windows itself. Each one runs under its own small account
that Windows creates for it, called a **virtual account**. That's why they
show up in the sign-in log.

## What each one does

**DWM, the Desktop Window Manager.** Programs don't draw straight onto your
screen. Each window draws into a hidden picture, and DWM puts all the pictures
together into the one desktop you see [1].

**UMFD, the User-Mode Font Driver Host.** Fonts are small programs of their
own, and font files can arrive inside documents and web pages. Windows used to
read fonts deep inside its most powerful part, the kernel, so a booby-trapped
font could take over the whole computer. Microsoft moved that work into
`fontdrvhost.exe`, which runs in a tightly locked-down box (an AppContainer)
[2][3]. If a bad font breaks it, the damage stays inside the box.

## What the number means

The number at the end is the **session**: a separate "desk" inside Windows.

- **Session 0** is where Windows' own background services always run [4].
  **UMFD-0** is the font driver for that session.
- **Session 1** is the first screen session, the one at the keyboard.
  **UMFD-1** and **DWM-1** belong to it.

Your restart log shows this nicely: **UMFD-0** was started by `wininit.exe`,
the program that sets up session 0, and **UMFD-1** and **DWM-1** were started
by `winlogon.exe`, which runs the sign-in screen.

A new screen session gets the next number. For example, if someone connects
with Remote Desktop, Windows starts a new DWM for that session: **DWM-2**, then
**DWM-3**, and so on [5]. Switching users also creates a new session [4].

## Why a responder cares

**1. Don't chase them.** They're Logon Type 2, the same as a person at the
keyboard, so a quick look can mistake them for people. Check the
**Account Domain** (Window Manager, Font Driver Host) and the **Virtual
Account** line, which says **Yes** for them and **No** for Dana.

**2. They mark the moment a screen session starts.** UMFD-0, UMFD-1 and DWM-1
showing up within a second of each other means Windows just started. On
WS-DSP-01 that happened at **09:58:28**, a minute after the restart was
clicked. That's a useful timestamp when you're building a timeline: "the
computer came back up here." They can also appear when a computer wakes from
sleep or a session reconnects [6].

**3. The number counts screen sessions.** On Dana's computer, where only Dana
works at the keyboard, you'd expect **DWM-1**. A **DWM-2** or higher means
another screen session was created. That has normal reasons too, but at 3 a.m.
on a dispatcher's PC it's worth a closer look. Then check the people records
around the same time: Remote Desktop shows up as **Logon Type 10**.

## What it looked like on WS-DSP-01

From the restart log in [Shreyas's notes](../../notes/level-1/01-what-normal-looks-like.md):

| Time | Account | Logon Type | Virtual Account | Started by |
|---|---|---|---|---|
| 09:58:28 | UMFD-0 | 2 | Yes | `wininit.exe` |
| 09:58:28 | UMFD-1 | 2 | Yes | `winlogon.exe` |
| 09:58:29 | DWM-1 (a pair) | 2 | Yes | `winlogon.exe` |
| 09:58:44 | Dana (a pair) | 2 | **No** | `svchost.exe` |

## Sources

1. Microsoft, "Desktop Window Manager": <https://learn.microsoft.com/en-us/windows/win32/dwm/dwm-overview>
2. SANS Internet Storm Center, on Microsoft advisory ADV200006 confirming the kernel font driver was replaced by `fontdrvhost.exe` running in an AppContainer: <https://isc.sans.edu/diary/25936>
3. Petri, "Microsoft Quietly Moved Font Parsing to AppContainer in the Anniversary Update": <https://petri.com/microsoft-quietly-moved-font-parsing-appcontainer-anniversary-update>
4. Microsoft, "Interactive Services" ("All services run in Terminal Services session 0"; fast user switching uses Terminal Services sessions): <https://learn.microsoft.com/en-us/windows/win32/services/interactive-services>
5. Jeroen Wiert Pluimers, "Windows Users like 'Window Manager\DWM-3' are virtual users" (DWM-2 and higher are created for Remote Desktop sign-ins), a practitioner blog: <https://wiert.me/2021/03/15/windows-users-like-window-managerdwm-3-are-virtual-users/>
6. Microsoft Q&A, community answer on DWM-1 and UMFD-1 logons after sleep, Fast Startup and session reconnection: <https://learn.microsoft.com/en-us/answers/a/12623259>
