# 10sec outbound: running Sellbird in a GitHub Codespace

This repo is Amber's fork of Sellbird (github.com/ethanplusai/sellbird, AGPL-3.0) with 10sec's setup in the `10sec/` folder:
- `10sec/sellbird.local.yaml`: offer, audience, limits, India time zone, compliance, safety settings (template)
- `10sec/email_rules.md`: 10sec house rules for every email Sellbird writes (template)
- `.devcontainer/` + `10sec/setup.sh`: the Codespace installs Python, Sellbird and Claude Code, then copies both templates into place

**This fork is public** (GitHub doesn't allow private forks). So the working copies, `./sellbird.local.yaml` and `./skills/email_rules.md`, are gitignored: fill in your mailbox and postal address there, never in the `10sec/` templates. Keys go in Codespaces secrets. Nothing personal is ever committed.

## How it runs (read this once)

A Codespace is a computer in the cloud that **stops when you leave it**. GitHub Free includes 120 core hours a month, which is 60 hours on the 2-core machine this repo uses. That fits a **daily work session**, not 24/7:

- Open the Codespace on weekdays around 10:30 IST, start Sellbird, review and approve emails, leave it running while you work. About 2 hours a day is roughly 44 hours a month.
- Sellbird only sends while the Codespace is on. Approved emails that miss a session go out in the next one.
- **Never delete the Codespace.** It holds the prospect database and the opt-out list (`data/`). Stopping is fine; deleting loses them. In GitHub Settings → Codespaces, set the retention period to the maximum (30 days), and run `sellbird export` now and then as a backup.

## One-time setup

### 1 · Sending domain and mailbox (starts the 14-day warmup clock)
1. In Hostinger, buy a look-alike domain (for example `get10sec.com`) and forward it to https://10sec.space. Never cold email from 10sec.space itself.
2. Create one Google Workspace mailbox on it, e.g. `amber@get10sec.com`. Add SPF, DKIM and DMARC records in Hostinger DNS.
3. Turn on 2-Step Verification for that mailbox, then create an **app password** (Google Account → Security → App passwords). Sellbird sends and reads replies with it.
4. Start a warmup service on the mailbox and note the date.

### 2 · Codespaces secrets (your keys never go in the repo)
GitHub → Settings → Codespaces → Secrets → New secret. Give each one access to `Amber3201/sellbird`:

| Secret | Value |
|---|---|
| `SMTP_HOST` | `smtp.gmail.com` |
| `SMTP_USERNAME` | the sending address |
| `SMTP_PASSWORD` | the app password from step 1.3 |
| `IMAP_HOST` | `imap.gmail.com` |
| `REOON_API_KEY` | from reoon.com/email-verifier (600 free checks a month) |
| `SERPER_API_KEY` | from serper.dev (2,500 free searches) |
| `HUNTER_API_KEY` | optional, from hunter.io |

### 3 · Fill in three lines in `./sellbird.local.yaml` inside the Codespace (don't commit)
- `persona.email`: the sending address
- `channels.email.warmup.start_date`: the warmup date (YYYY-MM-DD)
- `compliance.postal_address`: business address or virtual mailbox

### 4 · Create the Codespace
Repo page (github.com/Amber3201/sellbird) → switch the branch to **10sec** → **Code** → **Codespaces** → **Create codespace on 10sec**. The first build takes a few minutes. Then do step 3, and in the terminal:

```bash
claude                      # sign in with your Claude Pro/Max account, then type /exit
sellbird train https://10sec.space
cp 10sec/sellbird.local.yaml .      # training rewrites the config; this restores the 10sec version (then redo step 3)
sellbird signals --confirm free
sellbird inboxes list               # shows the mailbox; then: sellbird inboxes test <sending-address>
```

## Finding businesses

The free OpenStreetMap source only knows a few trades (it works for "Dentist", not clinics, studios or cafes), so use Serper's free 2,500 searches:

```bash
sellbird discover --provider serper --estimate     # shows the cost first
sellbird discover --provider serper --city "Bengaluru, Karnataka, India" --limit 20
```
Start with one city and see the results before running all six.

## Daily session

```bash
sellbird run          # leave this terminal running
```
Open a second terminal for review:
```bash
sellbird status
sellbird outbox                     # read each draft
sellbird outbox --approve <id>      # or --reject <id>
sellbird sending pause              # emergency stop
```
Before approving, open the prospect's site and check the observation is true.

**Want the visual dashboard?** It only opens on a `localhost` address, so it doesn't work in the browser version of Codespaces. Either open the Codespace in VS Code on your computer (Code → Codespaces → ⋯ → Open in VS Code) and run `sellbird dashboard`, or on your computer run `gh codespace ports forward 5555:5555`, then open the link `sellbird dashboard --url` prints.

When you're done for the day: `Ctrl+C` in the `sellbird run` terminal, then stop the Codespace (Code → Codespaces → ⋯ → Stop).

## Ramp and weekly numbers
- Days 1–14 after `warmup.start_date`: no cold email (enforced). Then 5 a day, plus 3 a day, up to 30.
- Sellbird pauses itself if bounces pass 3%.
- Track weekly: sent · replies · "send the test" · tests delivered · calls booked · opt-outs · bounce rate.

## Updating Sellbird
```bash
Click **Sync fork** on the repo page (updates `main`), then in the Codespace: `git pull origin main && pip install -e .`
```

*You are the sender: every email carries an opt-out line and your postal address, opt-outs are honoured immediately, and Sellbird answers honestly if asked whether it's AI. Not legal advice.*
