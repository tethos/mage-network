# Publishing Mage Network

This guide covers GitHub (source and releases), CurseForge, and how players get it in
WowUp.

> **Verify first:** WoW Forever is new. Before your first upload, check on each site
> that **WoW Forever** (client 1.60.1, interface 16001) can be selected as a game
> version. If it can't, tag the upload with the closest option and say "WoW Forever" in
> the summary until the site adds it.

---

## 0. Before every release

1. Test in game (`/console scriptErrors 1`, then `/reload`).
2. Bump `## Version:` in `MageNetwork/MageNetwork.toc`, e.g. `0.1.1`.
3. Add an entry to `CHANGELOG.md`.
4. Commit: `chore: release 0.1.1`.
5. Build the zip:
   ```
   python tools/package.py
   ```
   This creates `dist/MageNetwork-0.1.1.zip`, which is what you upload. The zip contains
   the `MageNetwork/` folder, which is exactly what players extract into `AddOns`.

---

## 1. GitHub (source and releases)

1. Create an **empty** repository on GitHub (no README, so there are no conflicts).
2. Push:
   ```
   git remote add origin https://github.com/<you>/mage-network.git
   git push -u origin main
   ```
3. **Release:** push a tag that matches the TOC version:
   ```
   git tag v0.1.1
   git push origin v0.1.1
   ```
   The workflow in `.github/workflows/release.yml` builds the zip and creates a GitHub
   release with it automatically. Watch it under the repository's **Actions** tab.

---

## 2. CurseForge

1. Sign in at **authors.curseforge.com** (or *curseforge.com → Create Project*).
2. **Create project**
   - Game: *World of Warcraft*. Class: *Addons*.
   - Name: `Mage Network`
   - Summary, description, categories: copy from `docs/store/listing.md` and
     `docs/store/description.md`. If the description editor offers Markdown, paste the
     file as is. If it's a visual editor, paste the rendered text from GitHub.
   - Logo: your square icon PNG.
   - License: MIT. Source: your GitHub URL. Issues: `<repo>/issues`.
3. **Upload a file:** *Files → Upload file*
   - File: `dist/MageNetwork-<version>.zip`
   - Display name: `Mage Network <version>`
   - Release type: *Release* (or *Beta* for test builds)
   - Game version: **WoW Forever 1.60.1** (see "Verify first" above)
   - Changelog: paste from `CHANGELOG.md`
4. New projects and files go through **moderation**, which can take from hours to a few
   days. You get an email when the project is approved.
5. After approval, note the **Project ID** (shown on the project page sidebar) and add
   it to the TOC, so tools can link the addon to the project:
   ```
   ## X-Curse-Project-ID: 123456
   ```

---

## 3. Wago Addons (recommended because WowUp uses it)

1. Sign in at **addons.wago.io** with your account (Patreon/Discord/Battle.net login).
2. *Developer dashboard → Create addon.* Use the same name, summary, description and logo.
3. Upload the same zip and choose the game version.
4. Add the Wago project ID to the TOC:
   ```
   ## X-Wago-ID: abcdEFGH
   ```

---

## 4. WowUp

WowUp doesn't host addons. It installs from other sources:

| WowUp edition | Sources |
| --- | --- |
| **WowUp** (default) | Wago Addons, WoWInterface, **GitHub releases**, Tukui |
| **WowUp-CF** | CurseForge (plus the above) |

So once Mage Network is on **Wago** and/or has **GitHub releases**, WowUp users can get it:
- Search for "Mage Network" (Wago / CurseForge), or
- *Get Addons → Install from URL* → paste `https://github.com/<you>/mage-network`.

WowUp must also know WoW Forever as a client. If it doesn't detect the `_forever_`
folder yet, users can add the install path manually in WowUp's options.

---

## 5. Later: fully automatic uploads (optional)

The common tool is the **BigWigs packager** GitHub Action
(`BigWigsMods/packager`). With API tokens stored as GitHub secrets it uploads every tag
to CurseForge, Wago and GitHub in one go:

- CurseForge token: *curseforge.com → Account → API tokens* → secret `CF_API_KEY`
- Wago token: *addons.wago.io → Account → API keys* → secret `WAGO_API_TOKEN`

Two things to check before switching:
1. The packager has to support the WoW Forever game version (check its README or issues).
2. The packager expects the `.toc` at the **repository root**. Either move the addon
   files to the root, or package with a `.pkgmeta` that handles the subfolder.

Until then, the simple setup above (local zip, manual upload, automatic GitHub releases)
works fine.

---

## Release checklist

- [ ] Tested in game, no Lua errors
- [ ] TOC `## Version:` bumped
- [ ] `CHANGELOG.md` updated
- [ ] Committed and pushed
- [ ] Tag pushed (GitHub release created)
- [ ] Zip uploaded to CurseForge
- [ ] Zip uploaded to Wago
