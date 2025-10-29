# CheryClose Product Specification

## A. Product Requirements (PRD)

### 1. Product Name
CheryClose — WhatsApp-first Android app that helps a non-technical Chery salesperson in South Africa generate leads, share great content, handle objections, price deals, and follow up to close.

### 2. Target Users & Goals
**Primary user:** Chery salesperson (non-technical) using Android, mostly in WhatsApp & camera.

**Goals:**
- Create & share model-specific content in 30 seconds.
- Reply to objections with one tap.
- Give a clean monthly instalment estimate instantly.
- Capture leads POPIA-compliantly and follow up on time.
- Print/share QR posters to drive walk-ups to WhatsApp chats.
- Track what is working (which posts, scripts, and follow-ups convert).

### 3. Core Jobs-to-be-Done (JTBD)
- “When I meet or text a prospect, I want a ready caption/video that makes Chery’s value obvious so they respond.”
- “When a buyer asks tough questions (resale, parts, hybrid), I want tap-to-send answers so I look confident.”
- “When a buyer hesitates, I want automated reminders with the right message at the right time.”
- “When standing in front of a customer, I want a simple calculator to estimate R/month & explain costs.”

### 4. Feature Scope (MVP)
- **Lead Cards & Captions (Share to WhatsApp/Status/Groups)**
  - Model picker (Tiggo 4/7/8/9, Omoda, Jaecoo).
  - Auto caption (benefits, warranty, CTA).
  - One-tap share (text + image) with your contact footer.
- **60-sec Video Script & Auto-Captions**
  - Script generator (hook → 3 benefits → offer → CTA).
  - In-app guided recording; export 9:16 with burned-in captions.
- **Finance Calculator (SA-friendly)**
  - Inputs: price, deposit %, rate %, term, balloon %.
  - Output: estimated monthly instalment, total cost, quick “petrol vs hybrid energy” running cost compare (simple, editable defaults).
  - One-tap “Insert into chat”.
- **Objection Library (tap-to-send)**
  - 20 canned replies (warranty, service & parts, resale, insurance, hybrid anxiety).
  - Localised, friendly tone, POPIA-safe capture line.
- **POPIA-compliant Lead Capture & Follow-ups**
  - Lead form: name, WhatsApp number, interest, consent checkbox, notes.
  - Follow-up plans (Day 0/2/5/10 nudges; push reminders; message templates ready to paste).
- **QR Poster Builder**
  - Quick templates: headline, offer, photo, “10-yr/1M km engine warranty” badge, QR that opens WhatsApp chat to salesperson.
  - Export PNG for print or share.
- **Model Sheets (read-only quick facts)**
  - Always-updated bullets per model (key specs, value points, hybrid talking points & rival compare bullets).
  - Content pulled from a tiny cloud doc/Firestore so you can edit without an app update.

### 5. Out of Scope (MVP)
- Full CRM, contract generation, automated WhatsApp sending via Business API (consider later).
- Complex finance pre-approval.
- Multi-branch inventory syncing (Phase 2).

### 6. Success Metrics (first 60–90 days)
- Time-to-first-share < 10 minutes after install.
- ≥ 3 shared assets / salesperson / day.
- ≥ 25% of captured leads placed on a follow-up plan.
- ≥ 10% of leads attend test-drive.
- ≥ 3% conversion to sale (self-reported).
- NPS ≥ 40 from salespeople.

## B. Technical Blueprint

### 1. Platform & Libraries
- **Client:** Flutter (Dart), Android 8+.
- **Backend:** Firebase Auth (phone or email), Firestore (content + leads), Firebase Storage (images/video), FCM (push).
- **Sharing:** Android Sharesheet to WhatsApp; build images/posters with Flutter (canvas) or `flutter_svg` + `qr_flutter`.
- **Video captions:** Use client-side subtitle burn-in (FFmpeg kit for Flutter) or render text overlays in Flutter before export (simpler = image + audio; MVP can skip auto-transcription).

### 2. Data Model (Firestore)
```
/users/{userId}
  displayName: string
  phone: string
  dealership: string
  branch: string
  role: "sales"
  createdAt: timestamp

/leads/{leadId}
  ownerUserId: string
  name: string
  phone: string
  modelInterest: string
  source: "whatsapp|poster|walkin|status"
  consentMarketing: bool
  notes: string
  stage: "new|contacted|testdrive|deal|lost"
  followUpPlanId: string|null
  nextActionAt: timestamp|null
  createdAt: timestamp
  updatedAt: timestamp

/followUpPlans/{planId}
  name: string
  steps: [
    { dayOffset: 0, templateId: "thanks_brochure" },
    { dayOffset: 2, templateId: "value_reminder" },
    { dayOffset: 5, templateId: "test_drive_nudge" },
    { dayOffset:10, templateId: "offer_update" }
  ]

/messageTemplates/{templateId}
  name: string
  body: string  // variables: {{lead.name}}, {{model}}, {{user.phone}}
  channel: "whatsapp"
  tone: "friendly"

/models/{modelId}
  name: "Tiggo 4 Pro"
  keyBullets: [string]
  sellingPoints: [string]
  warrantyStampText: string
  basePrice: number
  imageUrl: string
  hybridNotes: string
  rivalCompare: [ { rival: string, bullet: string } ]

/captions/{captionId}
  modelId: string
  title: string
  body: string // CTA & hashtag options

/posterThemes/{themeId}
  name: string
  backgroundUrl: string|null
  colorPrimary: string
  colorAccent: string
  hasWarrantyBadge: bool

/analyticsDaily/{userId_YYYYMMDD}
  shares: number
  leadsCaptured: number
  testDrivesBooked: number
  dealsMarked: number
```

### 3. Firestore Security Rules (Sketch)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isOwner(uid) { return request.auth != null && request.auth.uid == uid; }

    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }

    match /leads/{leadId} {
      allow read, write: if request.auth != null
        && request.resource.data.ownerUserId == request.auth.uid;
    }

    match /models/{doc=**} {
      allow read: if true;   // public model sheets
      allow write: if false; // admin only (use server-side scripts if needed)
    }

    match /messageTemplates/{doc=**} {
      allow read: if true;
      allow write: if false;
    }

    match /followUpPlans/{doc=**} {
      allow read: if true;
      allow write: if false;
    }

    match /captions/{doc=**} {
      allow read: if true;
      allow write: if false;
    }

    match /posterThemes/{doc=**} {
      allow read: if true;
      allow write: if false;
    }

    match /analyticsDaily/{doc=**} {
      allow read, write: if request.auth != null
        && doc.split('_')[0] == request.auth.uid;
    }
  }
}
```

### 4. POPIA Considerations
- Lead form includes consent checkbox (required).
- Each WhatsApp template carries “Reply STOP to opt-out.”
- Data minimisation: only name & phone mandatory.
- Export & delete lead: per-lead actions on details screen.
- Cloud data region: choose a region compliant with your policy; document it in privacy policy.

### 5. Finance Calculator (Formulae)
- Inputs: price (P), deposit% (d), rate APR% (r), term months (n), balloon% (b).
- Loan principal: `L = P * (1 - d) - P * b` (balloon treated as residual).
- Monthly rate: `i = r / 12 / 100`.
- Payment: `PMT = (L * i) / (1 - (1 + i)^(-n)) + (P * b * i)`.
- Display “Estimated only. Subject to bank approval. E&OE.”
- Running cost compare: editable fields `fuelPrice`, `l_per_100km`, `km_per_month`; simple: `fuelCost = (l_per_100km/100) * km_per_month * fuelPrice`. For hybrids, allow lower `l_per_100km`.

### 6. Offline & Sync Strategy
- Models, captions, templates, plans cached locally; read-through when online.
- Leads queue offline; push when connected (retry with exponential backoff).

### 7. Android Permissions
- Camera (poster photos, trade-in checklist).
- Storage (export video/poster).
- Notifications (follow-up reminders).

### 8. Analytics Events (Firebase Analytics)
- `share_caption {modelId, channel}`
- `generate_video {modelId}`
- `lead_created {source, modelId}`
- `followup_step_sent {planId, stepIndex}`
- `calc_quote_shared {modelId}`

Dashboard aggregates these daily per user.

## C. UX Flows & Screens
1. **Onboarding**
   - Phone sign-in → set Name, Branch, Phone footer → pick “default interest rate” & default follow-up plan → Done.
2. **Home (4 big tiles)**
   - Share (Captions & Video)
   - Leads (List, + button)
   - Calculator (R/month)
   - Poster (QR Maker)
   - Top bar: quick model switcher; bottom bar: Home, Library, Analytics, Settings.
3. **Share → Model picker → Caption**
   - Grid of models (image + name).
   - Caption preview with variables (`{{priceFrom}}`, `{{warrantyStamp}}`).
   - Buttons: Share Text, Share with Image, Make 60-sec Video.
4. **Video maker**
   - Script shown with teleprompter scroll.
   - Record (front camera); optional logo/warranty overlay.
   - Export MP4 1080×1920 with captions burned in → Share.
5. **Leads**
   - List with stage chips & `nextActionAt`.
   - Add Lead: form with consent checkbox (required).
   - Lead Detail: quick actions: Call, WhatsApp, Start/Change Follow-up Plan, Log Note, Mark Stage.
6. **Follow-up reminders**
   - Daily list: “3 actions due” → tap → opens prepared message → Share to WhatsApp → mark step complete → schedules next step.
7. **Calculator**
   - Sliders/inputs for price, deposit, rate, term, balloon.
   - Output card with PMT, total cost, and running cost snippet → Share to WhatsApp.
8. **Poster (QR)**
   - Choose theme → add photo → headline/offer → warranty badge toggle → auto-QR (`wa.me/` + your number & greeting text) → Export PNG / Share.
9. **Library**
   - Model sheets, objection replies, message templates — searchable.
10. **Analytics**
    - Today / 7-day summary: shares, leads, test drives, deals; “Top 3 actions to do now.”

## D. Acceptance Criteria & Test Cases
**Critical AC (MVP)**
- Share a caption in ≤4 taps from Home → Share → Model → Share.
- Lead creation requires consent or it blocks save; export/delete is available on details.
- Follow-up plan creates reminders at correct day offsets; push notifications deep-link to lead.
- Calculator PMT matches formula within ±1 Rand rounding vs. reference sheet.
- Poster exports a clear 1080×1920 PNG with working QR that opens WhatsApp chat to the salesperson.
- Offline: creating a lead offline stores locally and syncs when online.

**Sample Test Cases**
- **TC-01:** Install → onboard → set defaults → Share a Tiggo caption to WhatsApp.
- **TC-02:** Create lead without consent → expect error; tick consent → save ok.
- **TC-03:** Assign follow-up plan → receive Day-0 notification → send template → `nextActionAt` updated.
- **TC-04:** Calculator with `P=399,900`, `d=10%`, `r=12.5%`, `n=72`, `b=20%` → verify PMT.
- **TC-05:** Poster QR opens `wa.me/<number>?text=Hi%20....`
- **TC-06:** Turn off data → add lead → kill & reopen → lead present; turn on data → lead visible in another device session.

## E. Content (Ready-to-use)
### 1. Caption Templates (variables: `{{model}}`, `{{fromPrice}}`, `{{warranty}}`)
- **Value:**
  > “{{model}} — packed with smart tech & space, from ~R{{fromPrice}} p/m* and {{warranty}} peace of mind. Want a 10-min test drive? Reply ‘TEST’.”
- **Hybrid curiosity:**
  > “Thinking lower fuel bills? {{model}} Hybrid keeps it simple—no fuss, great drive. Quick costs & trade-in? Reply ‘HYB’.”
- **Family:**
  > “School runs & weekend escapes sorted. {{model}} with safety tech and space to breathe. Want finance options? Reply ‘FIN’.”

### 2. Objection Snippets
- **“Parts & service?”**
  > “Chery’s network and support keep you moving. Plus, that engine warranty (T&Cs apply) builds long-term confidence. I can show you service intervals—want the PDF?”
- **“Resale value?”**
  > “Value-packed spec keeps demand strong. You save upfront and on running costs—happy to show total cost over 5 years.”
- **“Hybrid worry?”**
  > “No complicated steps. You fuel as normal (or light charging if PHEV). We focus on saving at the pump and smooth driving.”

### 3. Video Script (60s)
- **Hook:** “What if your next car covered the engine for up to 10 years?”
- **Benefits:** space & spec; safety; low running cost.
- **Offer:** “This week I’ve got a bonus accessory/test-drive gift.”
- **CTA:** “Reply TEST and I’ll book a 10-minute drive.”

## F. Build & Release
### Dev Milestones
- **Week 1–2:** Auth, model sheets, captions share, calculator, lead form + consent, follow-up plans & reminders.
- **Week 3:** Poster builder with QR, objection library, analytics.
- **Week 4:** Video overlay/captions exporter, polish, Play Store listing (closed testing).

### Store Metadata (Short)
- **Title:** CheryClose — Sell Smarter on WhatsApp
- **Short description:** Share great Chery content, capture leads POPIA-compliantly, price finance, and follow up to close deals.
- **Privacy URL:** link to policy page (host a simple page; state data categories, export/delete flow, region).

## G. One-shot “Master Prompt” to Scaffold the App
Goal: Build an Android Flutter app called CheryClose for SA Chery salespeople. Non-technical users. WhatsApp-first.

**MVP Features:**
- Share model-specific captions & images to WhatsApp (Status/Chats/Groups).
- 60-sec video script + simple in-app recording & caption overlays (export 1080×1920 MP4; OK to stub transcription).
- Finance calculator with inputs `{price, deposit%, rate%, term, balloon%}` and PMT formula: `L = P*(1-d) - P*b`; `i=r/12/100`; `PMT = (L*i)/(1-(1+i)^(-n)) + P*b*i`. Share output text to WhatsApp.
- POPIA-compliant lead capture (name, phone, modelInterest, consent checkbox REQUIRED). Follow-up plans with day offsets; push notifications; deep-link to lead detail; template messages with variables.
- Poster builder: headline/offer/photo, warranty badge toggle, QR to `wa.me/<salespersonNumber>?text=<greeting>`, export PNG 1080×1920.
- Library: model sheets, objection replies, message templates (read-only, cloud-editable).

**Tech stack:** Flutter, Firebase Auth (phone), Firestore, Firebase Storage, FCM, `qr_flutter`, `share_plus`, `image_picker`, optional `ffmpeg_kit_flutter`.

**Data model:** Use the Firestore collections and fields defined in the spec above. Cache library content for offline.

**Security:** Apply the Firestore rules from the spec, enforce consent before saving leads, include delete/export of leads.

**UX:** Home with 4 tiles (Share, Leads, Calculator, Poster), bottom nav (Home, Library, Analytics, Settings). Model picker → caption preview → Android Sharesheet. Leads list with stages & next action. Calculator with sliders. Poster themes. Library searchable.

**Analytics:** Log events `share_caption`, `lead_created`, `followup_step_sent`, `calc_quote_shared`.

**Deliverables:**
- Production-ready Flutter project.
- Dummy seed data for `/models`, `/captions`, `/messageTemplates`, `/followUpPlans`.
- A settings screen with default interest rate and phone number (for QR).
- Basic privacy policy markdown file in the repo.

**Acceptance tests:** Implement the AC & test cases from the spec, including offline lead creation and PMT verification.
