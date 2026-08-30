# Exercise Recommendation Logic (plain-English)

Where it lives: `postura_rust/src/integrations/ai/exercise.rs` (called from `integrations/ai/mod.rs::analyze_posture`).
Despite sitting in the `ai/` folder, **this is not an LLM call** — it's a deterministic scoring/ranking algorithm over a fixed 25-exercise catalog (`postura_rust/src/utils/exercise_catalog.rs`). No prompt, no model, same input always gives the same output.

This system is separate from Action Report v1.3 / Equipment Engine v1.3.

**v2 note (client audit):** the client's audit of the original version found that ROSA/image
severity was being converted into a manufactured pain score, which then unlocked a more intensive
session — the opposite of the required model. This write-up describes the corrected v2 behavior:
**ROSA/image findings only ever select which regions are relevant and drive corrective
workstation education. Reported NRS, symptoms, and duration/chronicity are the only inputs that
influence exercise dose/readiness. A separate red-flag checklist — not an NRS cutoff — decides
whether the session stops for clinical referral.**

---

## 1. What feeds it

Two inputs are built earlier in the pipeline and handed to the exercise engine:

- **`user_context`** — onboarding/pain data the user reports directly:
  - `pain_intensity`: a map of body region → pain score (0–10) the user typed in — **the only
    source of an NRS value anywhere in this engine**
  - `body_regions`: body regions the user explicitly selected (candidate regions; never a pain
    source on their own)
  - `duration_pattern`: how long the pain has lasted (`"Less than 1 week"`, `"1-4 weeks"`,
    `"6-12 weeks"`, `"1-3 months"`, `"3-6 months"`, `"More than 6 months"`)
  - `optional_symptoms`: e.g. "Numbness or tingling" — read as a readiness signal, never turned
    into a manufactured region+pain pair
  - `red_flag_positive` / `red_flag_screening`: the medical red-flag safety checklist (see step 2)

- **`iso_report`** — the app's own posture/workstation severity output (`iso.rs`), computed from
  ROSA sub-scores and the measured capture angles. Each metric is tagged `green`/`yellow`/`red`.
  **This only ever selects relevant regions — it never produces a pain value.**

---

## 2. Step-by-step: how a condition becomes a recommended exercise

### Step 1 — Figure out which regions are relevant, and what pain (if any) is real
Three separate collections are built, and they are never merged into one pain score:

1. **`reported_pain`** (region → NRS 0-10) — built *only* from the employee's `pain_intensity`
   answers, used exactly as entered. Selecting a region with no matching intensity value does
   **not** invent a pain number for it.
2. **`image_risk_regions`** — any region where a posture or workstation metric is `yellow`/`red`.
   Carries no pain value, ever.
3. **`candidate_regions`** — the union of every region from (1), any region selected without an
   intensity value, and (2). This is what actually gets a slot in the session.

Posture metric → region mapping (relevance only):
| Posture metric flagged yellow/red | Region |
|---|---|
| neck | Neck |
| shoulders, upper_back, mid_back, thoracic | Shoulders |
| elbow | Elbows/Forearms |
| wrist | Wrists/Hands |
| lower_back, pelvic_tilt, hip, glutes | Hips/Glutes |
| knee | Knees |
| ankle, foot | Ankles/Feet |

Workstation component → region mapping (relevance only):
| Workstation component flagged yellow/red | Region |
|---|---|
| monitor | Neck |
| worksurface (keyboard/mouse) | Wrists/Hands |
| chair | Hips/Glutes |

### Step 2 — Red-flag check (stops everything, independent of NRS)
Before an auto-stop with diagnosis-style language, the employee answers a dedicated 7-item
medical screening (`RedFlagScreening`, one immutable row per scan):
new bladder/bowel dysfunction, saddle anaesthesia, progressive motor weakness, significant recent
trauma, fever/infection/immunosuppression with back pain, cancer history with new spinal pain,
severe unremitting/night pain.

**Any single "Yes" → `exercise_status = "STOP_AND_SEEK_CLINICAL_ASSESSMENT"`, zero exercises.**
High reported NRS *alone* (even 9 or 10) no longer stops the session by itself — a number is not
a diagnosis. The stop message is deliberately non-diagnostic:

> "Some of your screening answers suggest this should be assessed by a healthcare professional
> before starting these exercises. No exercises are recommended at this time — please consult a
> doctor or physiotherapist for evaluation. This is a conservative safety precaution, not a
> diagnosis."

### Step 3 — Readiness (dose), driven only by reported pain / symptoms / duration
```
if red_flag_positive:            STOP_AND_SEEK_CLINICAL_ASSESSMENT (session = [])
elif max_reported_nrs >= 7
  or has_neuro_symptoms
  or (duration == "Less than 1 week" and max_reported_nrs >= 6):
    readiness = GENTLE;              needs_cpe_review = true
elif max_reported_nrs in 4..6
  or duration in {"6-12 weeks", "1-3 months", "3-6 months", "More than 6 months"}:
    readiness = MODERATE;            needs_cpe_review = true
else:
    readiness = GENTLE_MAINTENANCE;  needs_cpe_review = false
```
There is **no path from higher pain/chronicity to a more demanding tier** — readiness only ever
gets gentler, never more intensive, as inputs get more severe. Progression to a more active tier
isn't modeled at all yet: it would need a "no symptom worsening across sessions" signal this
one-shot scan doesn't have (a future multi-session feature).

### Step 4 — Narrow the 25-exercise catalog to candidate regions
Every catalog exercise is tagged with one region (see catalog table below) and, once populated, a
list of `contraindication_tags` (see §3) checked against the red-flag answers — a match excludes
the exercise outright. Only exercises whose region is a candidate region, and that aren't
contraindicated, are kept.

### Step 5 — Rank candidates within each region
Exercises are ranked purely by their fixed catalog `score` (1-9), ties broken by id. **No pain
bonus is applied** — a region's exercise choice depends on which catalog exercise fits it best,
not on how much it hurts.

### Step 6 — Build the session
**Exactly one exercise per candidate region — full stop.** No region ever gets a second exercise,
regardless of NRS (the old "pain ≥ 8 unlocks a 2nd exercise" rule is gone). Reported-pain regions
are ordered first (highest NRS first), then remaining candidate regions, and the list is
truncated to 5 total — a UX cap so a scan flagging many regions still returns a digestible
session, not a clinical dosage rule.

### Net effect, in one sentence
*Reported pain (and only reported pain), symptoms, and duration decide how gentle the session is;
ROSA/image findings decide which regions are even considered; a dedicated safety checklist — not
a pain number — decides whether to stop and refer; and no region ever gets more than one
exercise no matter how severe anything is.*

---

## 3. What text is shown with each recommended exercise

**From the catalog (fixed, same every time — see table below):**
- `title`, `body_region`, `muscle_ids`, `muscles_addressed`, `image` (GIF filename), `score`
- `purpose`, `description` — ⚠️ always **empty strings** today; no per-exercise copy has been
  written yet (see `EXERCISE_CONTRAINDICATIONS_CONTENT_REQUEST.md`)
- `contraindication_tags` — ⚠️ always **empty** today; the exclusion check is fully wired, it
  just has nothing to check against yet

**Generated per recommendation (depends on `readiness` and whether the exercise is
`reported_pain` or `image_risk` sourced — never on a manufactured pain value):**

| Field | Rule |
|---|---|
| `source` | `"reported_pain"` (has a real NRS) or `"image_risk"` (relevance/education only) |
| `recommended_duration` / `recommended_sets` / `safety_note` | `image_risk` always gets the gentlest dose (10–15s, 1 set) regardless of global readiness. Otherwise: GENTLE → 8–10s, 1 set, cautious note; MODERATE → 10–15s, 2 sets; GENTLE_MAINTENANCE → 15–20s, 2 sets |
| `region_vas` | the region's reported NRS, or `null` for an `image_risk`-only region |

There is no more `badge` ("Therapy Priority"/"Maintenance") and no `improvement_percentage` —
both were unvalidated and removed per the client audit.

**Session-level fields (not per exercise):**
- `exercise_status`: `"OK"` or `"STOP_AND_SEEK_CLINICAL_ASSESSMENT"`
- `readiness`: `"GENTLE"` / `"MODERATE"` / `"GENTLE_MAINTENANCE"`
- `needs_cpe_review`: whether this session should be reviewed with a CPE/health professional
- `condition_type`: the raw duration bucket label (e.g. `"6-12 weeks"`)
- `main_pain_region`: the region(s) tied for highest **reported** pain, plus that value (`null` if
  nothing was reported — image-only regions never count toward this)

There is no more `clinical_projection` block (the "30–50% in 21 days" / "45% lower injury risk"
projections were unvalidated and removed per the client audit).

---

## 4. The fixed 25-exercise catalog

| ID | Title | Region | Score | Muscles addressed |
|----|-------|--------|-------|---|
| 1 | Neck Side Tilt | Neck | 5 | Scalenes, Levator scapulae |
| 2 | Chin Tuck | Neck | 3 | Deep cervical flexors |
| 3 | Upper Trapezius Stretch | Neck | 7 | Upper trapezius |
| 4 | Neck Rotation Gentle | Neck | 4 | Sternocleidomastoid |
| 5 | Levator Scapulae Stretch | Neck | 9 | Levator scapulae |
| 6 | Shoulder Rolls | Shoulders | 3 | Trapezius, rhomboids |
| 7 | Shoulder Blade Squeeze | Shoulders | 5 | Rhomboids, middle trapezius |
| 8 | Doorway Chest Stretch | Shoulders | 4 | Pectoralis major |
| 9 | Shoulder Extension Stretch | Shoulders | 7 | Anterior deltoids |
| 10 | Wall Angels | Shoulders | 8 | Scapular stabilizers |
| 11 | Wrist Flexor Stretch | Wrists/Hands | 3 | Forearm flexors |
| 12 | Wrist Extensor Stretch | Wrists/Hands | 6 | Tibialis Anterior |
| 13 | Prayer Stretch | Elbows/Forearms | 4 | Wrist flexors |
| 14 | Finger Stretch | Wrists/Hands | 7 | Hand intrinsics |
| 15 | Elbow Flexor Stretch | Elbows/Forearms | 6 | Biceps brachii |
| 16 | Cat-Cow Stretch | Mid Back → *Hips/Glutes* | 4 | Spinal erectors |
| 17 | Child's Pose | Lower Back → *Hips/Glutes* | 6 | Latissimus dorsi |
| 18 | Seated Twist | Mid Back → *Hips/Glutes* | 6 | Obliques |
| 19 | Supine Twist | Lower Back → *Hips/Glutes* | 6 | Spinal rotators |
| 20 | Bridge Pose | Lower Back → *Hips/Glutes* | 7 | Gluteus, erector spinae |
| 21 | Seated Pelvic Tilts (Safe Lumbar Fallback) | Lower Back → *Hips/Glutes* | 5 | Core stabilizers, erector spinae |
| 22 | Seated Hip Flexor Stretch | Hips/Glutes | 4 | Iliopsoas |
| 23 | Standing Quad Stretch | Knees | 6 | Quadriceps |
| 24 | Calf Stretch | Ankles/Feet | 4 | Gastrocnemius |
| 25 | Ankle Circles | Ankles/Feet | 7 | Tibialis Anterior |

Note: the catalog labels back/spine exercises "Mid Back" / "Lower Back", but there's no separate "back" bucket in the region system — they all fold into **Hips/Glutes** at matching time (there's a unit test guarding this so it can't silently break).

---

## 5. Known gaps (as of this write-up)

- `purpose`, `description`, and `contraindication_tags` are wired end-to-end but always
  empty/unpopulated — see `EXERCISE_CONTRAINDICATIONS_CONTENT_REQUEST.md` for the content request.
- Progression from GENTLE/MODERATE to a more active tier isn't modeled — it needs a multi-session
  "no symptom worsening" signal that doesn't exist yet.
- The workstation Tier table (`action_report.rs::tier_for_score`) is a separate system from this
  engine's `readiness` — it is ROSA-only and does not read NRS at all; the two must never be
  conflated.
