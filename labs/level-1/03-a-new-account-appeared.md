# Lab 3: A new account appeared

**Level:** 1, Basics
**Time:** about 45 minutes
**You need:** WS-DSP-01 and your notes from [Lab 2](02-someone-is-guessing-passwords.md)

## The story

Someone on the IT team spots an account on Dana's computer that nobody
remembers creating. It's called **svc-backup2**, and it looks like something
IT would have made.

Your team lead asks: **who created it, when, and was it given admin rights?**

## What you'll learn

- Creating an account leaves its own record: event **4720**.
- Adding it to a group leaves another: event **4732**.
- How to follow a trail from one record to the next using **IDs**.
- Why a name can look harmless and still be a problem.
- Deleting an account doesn't delete the trail.

## Words you'll see

| Word | What it means |
|---|---|
| **4720** | The event ID for "a user account was created." |
| **4732** | The event ID for "a member was added to a security-enabled local group." |
| **Subject** | In these records, the account that *did* the action. |
| **SID** | A long ID number Windows gives every account. Unlike a name, it identifies exactly one account. |
| **Administrators group** | The group whose members have full control of the computer. |

## Keep notes like a responder

Copy the [notes template](notes-template.md) and write times as you go, same
as before. Take a screenshot wherever you see 📸, and **number them in the
order the lab asks for them**: `lab3-1.png`, `lab3-2.png`, and so on.
**Export the records** with **Save Filtered Log File As...** before you clean
anything up.

---

## Part 1: Is Windows recording this? (5 minutes)

Like sign-ins in Lab 1, account changes are a setting. Check both:

1. In the VM, right-click **Start** and choose **Terminal (Admin)**. Click
   **Yes**.
2. Type these two commands, one at a time:

   ```
   auditpol /get /subcategory:"User Account Management"
   auditpol /get /subcategory:"Security Group Management"
   ```

3. Each should say **Success** or **Success and Failure**.

📸 **Screenshot 1:** both results. Save it as `lab3-1.png`.

**If one says No Auditing,** you'd have no evidence to find. You can turn it
on for this lab, for example:

```
auditpol /set /subcategory:"User Account Management" /success:enable
```

Note that this only records changes **from now on**. It can't go back and
record what already happened. That's a real finding: if auditing is off when
something happens, there's nothing to find later.

## Part 2: Play the intruder (10 minutes)

Put WS-DSP-01 back to its clean state: **VM → Snapshot → Revert to
Snapshot**. Power it on, sign in as Dana, then right-click **Start** and open
**Terminal (Admin)**. Write down every time.

| # | Do this | Time |
|---|---|---|
| 1 | Note the time, then create the account: <br>`net user svc-backup2 "Lab-Only-2026!" /add` | |
| 2 | Give it admin rights: <br>`net localgroup Administrators svc-backup2 /add` | |
| 3 | Wait a minute, then check what the computer says now: <br>`net user` and then `net localgroup Administrators` | |

> This account is for the lab only, and the password means nothing. You'll
> delete it at the end. Never do this on a computer that isn't yours.

📸 **Screenshot 2:** the result of step 3, showing **svc-backup2** in the
Administrators list. Save it as `lab3-2.png`.

## Part 3: Find the trail (20 minutes)

### Account created: 4720

1. Open **Event Viewer**, then **Windows Logs**, then **Security**.
2. Click **Filter Current Log...**, type **4720,4732**, and click **OK**.
3. Find the **4720** record from your step 1. Scroll down in the bottom half.

```
Subject:
    Account Name:    Dana              ← WHO did it
    Account Domain:  WS-DSP-01
    Logon ID:        0x....            ← WHICH sign-in they used

New Account:
    Account Name:    svc-backup2       ← WHAT was created
    Security ID:     S-1-5-21-...      ← its unique ID
```

📸 **Screenshot 3:** the record with **Subject** and **New Account** visible.
Save it as `lab3-3.png`.

### Admin rights given: 4732

Click the **4732** record from step 2.

```
Member:
    Security ID:     S-1-5-21-...      ← WHO was added (an ID, not a name)

Group:
    Group Name:      Administrators    ← WHAT it was added to
    Group Domain:    Builtin

Subject:
    Account Name:    Dana              ← WHO added it
```

For local groups, Microsoft says the member's **Account Name** is usually just
`-`, so the **Security ID** is what names the account.

**Check:** is the Member's **Security ID** here the same as the New Account's
**Security ID** in the 4720 record? That's how you prove they're about the same
account.

📸 **Screenshot 4:** the 4732 record. Save it as `lab3-4.png`.

### The neighbors

Creating an account can write a few other records right next to it. Change the
filter to **4720-4740** to see them. Don't worry about understanding every one.
**Write down the event IDs you see**, because a later lab can look them up.

📸 **Screenshot 5:** the list of neighboring records. Save it as `lab3-5.png`.

### Which sign-in was it?

The **Logon ID** in the 4720's **Subject** section says which sign-in did it.
Change the filter to **4624** and find the sign-in with that same Logon ID. In
Lab 1 you saw that Dana's sign-in left a pair of records. **Which one matches?
Is its Elevated Token Yes or No?**

📸 **Screenshot 6:** the matching 4624 record, with **Logon ID** and
**Elevated Token** visible. Save it as `lab3-6.png`.

### Export the evidence

Set the filter to **4624,4720-4740** and use **Save Filtered Log File As...**.
Name it `lab3-new-account.evtx` and drag it to your real computer.

## Part 4: Clean up, then look again (5 minutes)

1. In **Terminal (Admin)**, delete the account and note the time:
   `net user svc-backup2 /delete`
2. In Event Viewer, click **Refresh** and filter for **4720-4740**.

**Is the account's creation still in the log?**

📸 **Screenshot 7:** the list after the delete, showing the creation and the
new record. Save it as `lab3-7.png`.

---

## Questions

Write your answers in your notes. For each answer, say where you found it.

1. What's the new account's name, and exactly when was it created?
2. Who created it? What does the record show, and what can't it prove?
3. Was it given admin rights? Which record proves it, and how do you know it's
   the same account?
4. Which sign-in did it? Does its Logon ID match the Elevated Token **Yes**
   record or the **No** one from that pair?
5. After you deleted the account, what did the log still show? Write two
   sentences for your team lead: who, what, when.

<details>
<summary><strong>Hints</strong> (open if you're stuck)</summary>

- Use the times from your notes to jump to the right place.
- In a 4720 or 4732 record, **Subject** is the one *doing* the action. The one
  being *created* or *added* is under **New Account** or **Member**.
- For question 4, look at the Logon ID in the **Subject** section, not in
  **New Account**.

</details>

<details>
<summary><strong>Answers explained</strong> (try first)</summary>

**1. svc-backup2, at the time of your step 1.** The 4720 record's time should
match your note to within a few seconds.

**2. The Subject is Dana, on WS-DSP-01.** That tells you which *account* did
it. It can't prove which *person* did, the same lesson as Lab 2: Windows
checks the password, not the human.

**3. Yes, the 4732 record, in the Administrators group (Builtin).** The record
shows the new member as an ID, not a name. That ID matches the **Security ID**
in the 4720 record, which is how you know they're about the same account.

**4. It should match the sign-in with Elevated Token Yes.** That's expected:
creating accounts needs admin power, and you opened **Terminal (Admin)**, which
uses Dana's admin key. If yours doesn't match, write down what you see. That's
what normal looks like on your computer.

**5. Yes, the log still shows the creation.** Deleting the account leaves its
own record (event 4726, "a user account was deleted") on top of the 4720, so
the trail got longer, not shorter. Something like: "Dana's account created
svc-backup2 at 11:02, then added it to Administrators at 11:03, using an
elevated sign-in. I can't tell whether Dana herself did it." Remember that a
name like *svc-backup2* looks like IT made it, so **check who created an
account, not what it's called**.

</details>

---

## What you learned

- Account creation is **4720** and a group addition is **4732**.
- **Subject** is who did it. **New Account** and **Member** are who it was
  done to.
- IDs like the **Security ID** and **Logon ID** let you follow a trail from
  record to record. Names can lie, IDs can't.
- The log shows **accounts**, not people.
- Deleting an account doesn't delete its history.

**Compare notes:** [Shreyas's notes from his own run](../../notes/level-1/03-a-new-account-appeared.md).
Spoilers, so finish the lab first.

**Next:** Lab 4, "Something runs at startup." Coming soon.

## Sources

- Microsoft, "4720(S): A user account was created": <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4720>
- Microsoft, "4732(S): A member was added to a security-enabled local group": <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4732>
- Microsoft, "4624(S): An account was successfully logged on": <https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4624>
