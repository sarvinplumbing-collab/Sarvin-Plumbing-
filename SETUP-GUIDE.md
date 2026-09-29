# Sarvin Plumbing Works – Setup Guide (Supabase + GitHub Pages)

The website is already connected to your Supabase project:
`https://wkntbqgdihhpmxwamwqr.supabase.co`

| File / folder | What it is |
|---|---|
| `index.html` | The whole website: home page, 7 pages, animations and the Admin panel |
| `config.js` | Your Supabase URL, publishable key and admin email (already filled in) |
| `supabase-setup.sql` | One-time script: tables, admin list and security rules (Row Level Security) |
| `images/`, `videos/` | Photos and background videos used in the design |
| `.nojekyll` | Tells GitHub Pages to serve the files exactly as they are. Keep it |

Only the **publishable (public) key** is used. The secret / service_role key is **never** needed. Don't put it in any file.

---

## Part A – Finish Supabase (about 5 minutes, once)

**Step 1 – Create the admin user**
1. Supabase → **Authentication → Users → Add user → Create new user**.
2. **Email:** `sarvinplumbing@gmail.com`
   **Password:** `Sarvin@2026` (this is the password you'll type on the website)
3. Tick **Auto confirm user** and create it.

This is the Gmail you log in with behind the scenes; you only type the password on the website. To use a different email, change it in **both** `config.js` (`adminEmail`) and `supabase-setup.sql` (one place, near the top).

**Step 2 – Block other sign-ups**
Supabase → **Authentication → Sign In / Providers** (or **Settings**): turn **off** "Allow new users to sign up".

**Step 3 – Run the SQL**
1. Supabase → **SQL Editor → New query**.
2. Paste the whole `supabase-setup.sql` file and press **Run**.
3. The result at the bottom should show one row: `sarvinplumbing@gmail.com`. If it shows no rows, do Step 1 first, then run the file again. Running it twice is safe.

What the SQL creates:
- **`admins` table:** the list of users allowed to edit (private, not readable from the website).
- **`items` table:** your photos, videos and reviews. **Everyone can read** them, but **only admins** can add, edit or delete.
- **`work` storage bucket:** public, 50 MB per file, images and videos only. **Only admins** can upload or delete.

---

## Part B – Publish on GitHub Pages

1. Sign in at **github.com** → **New repository** → name it (e.g. `sarvin-plumbing`) → **Public** → **Create repository**.
2. Click **uploading an existing file**. Drag **everything inside** the `sarvin-website` folder (all files and the `images` and `videos` folders) into the page, then click **Commit changes**.
   - Upload the *contents* of the folder, so `index.html` sits at the top level of the repository.
   - `.nojekyll` is a hidden file. If your computer hides it, the site still works; it's only a safety extra.
3. In the repository, open **Settings → Pages**. Under **Build and deployment**, choose **Deploy from a branch**, branch **main**, folder **/ (root)**, then **Save**.
4. After 1–2 minutes your site is live at:
   `https://YOUR-GITHUB-NAME.github.io/sarvin-plumbing/`

**Your own domain (e.g. sarvinplumbing.in):** in **Settings → Pages → Custom domain**, type the domain and save. Then at your domain provider, add the DNS records GitHub shows you (4 `A` records for the root domain, or a `CNAME` for `www`). Tick **Enforce HTTPS** once it's available.

**Updating the site later:** open the repository, upload the changed file (e.g. a new `index.html`) and **Commit**. GitHub Pages updates in a minute or two.

---

## Part C – Using Admin

1. Open the website → tap **☰** → **Admin**.
2. Type **`Sarvin@2026`** → **Unlock**. It asks for the password **every time** you open Admin.
3. **Photos** tab: add photos from your phone (resized automatically).
   **Videos** tab: clips up to 50 MB.
   **Reviews** tab: copy real reviews from your Google profile.
4. Changes go live for every visitor **immediately**. Close Admin with ✕ and you're logged out.

**If Admin shows an error**
- *"Wrong password"*: check the password you set in Part A, Step 1.
- *"Admin setup is not finished" / "This account is not an admin"*: run `supabase-setup.sql` again (Part A, Step 3).
- *An upload fails*: check the file is a photo or video under 50 MB, and that your Supabase project isn't paused (free projects pause after a long time unused; restore it from supabase.com).

**Changing the Admin password:** Supabase → Authentication → Users → click the admin user → reset or change the password.

---

## Good to know
- The site is plain HTML/CSS/JavaScript, so it runs on GitHub Pages with no build step.
- The publishable key in `config.js` is **meant to be public**. The security rules in the SQL are what protect your data.
- Free Supabase includes 1 GB of file storage: hundreds of photos plus many short videos.
- Working hours on the site: Mon–Fri 8 AM–6 PM, Sat 9 AM–4 PM, Sunday emergencies only. Tell me if these need changing.
