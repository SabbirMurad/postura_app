# Exercise content needed: purpose, description, contraindication tags

## What this is for

The exercise engine (`postura_rust/src/integrations/ai/exercise.rs`) recommends exercises from a
fixed 25-exercise catalog (`postura_rust/src/utils/exercise_catalog.rs`). Every exercise ships
today with **empty** `purpose` and `description` text, and an empty `contraindication_tags` list.

`contraindication_tags` is already wired into the recommendation logic: before an exercise is
served, the engine checks its tags against the employee's red-flag safety-screening answers
(`RedFlagScreeningInput` — see the exact 7 keys below) and drops the exercise if any tag matches
a "Yes" answer. Right now every exercise's tag list is empty, so nothing is ever excluded. This
is the one piece of the engine we are **not** authoring ourselves — it needs a clinician (or a
clinician-reviewed AI pass) to fill in, because it is genuine medical content, not a
product/engineering decision.

**What we need back**: for each of the 25 exercises below, three things —

1. `purpose` — one sentence: what this exercise is for / what it helps with.
2. `description` — 2-3 sentences: how to actually perform it (a plain-English how-to, suitable
   for an office worker with no equipment).
3. `contraindication_tags` — a short list of specific conditions under which this exercise should
   **not** be given. Each tag must be one of the exact keys listed below (not free text) so it can
   be matched against the screening answers automatically. Leave the list empty (`[]`) if the
   exercise has no relevant contraindication from this list.

## The exact tag vocabulary (pick only from this list)

These match the red-flag screening questions the employee answers before every scan
(`RedFlagScreeningInput` in `postura_rust/src/model/assessment.rs`):

- `new_bladder_or_bowel_dysfunction`
- `saddle_anaesthesia`
- `progressive_motor_weakness`
- `significant_recent_trauma`
- `fever_or_infection_or_immunosuppression_with_back_pain`
- `cancer_history_with_new_spinal_pain`
- `severe_unremitting_or_night_pain`

If an exercise has a contraindication that genuinely doesn't map to one of these 7 (e.g. a
region-specific issue like "acute shoulder dislocation" for a shoulder stretch), flag it back to
us as a proposed new tag rather than inventing free text — we'll wire the new screening question
before using it.

## The 25-exercise catalog

| id | title | body_region | muscles_addressed |
|----|-------|--------------|--------------------|
| 1 | Neck Side Tilt | Neck | Scalenes, Levator scapulae |
| 2 | Chin Tuck | Neck | Deep cervical flexors |
| 3 | Upper Trapezius Stretch | Neck | Upper trapezius |
| 4 | Neck Rotation Gentle | Neck | Sternocleidomastoid |
| 5 | Levator Scapulae Stretch | Neck | Levator scapulae |
| 6 | Shoulder Rolls | Shoulders | Trapezius, rhomboids |
| 7 | Shoulder Blade Squeeze | Shoulders | Rhomboids, middle trapezius |
| 8 | Doorway Chest Stretch | Shoulders | Pectoralis major |
| 9 | Shoulder Extension Stretch | Shoulders | Anterior deltoids |
| 10 | Wall Angels | Shoulders | Scapular stabilizers |
| 11 | Wrist Flexor Stretch | Wrists/Hands | Forearm flexors |
| 12 | Wrist Extensor Stretch | Wrists/Hands | Tibialis Anterior |
| 13 | Prayer Stretch | Elbows/Forearms | Wrist flexors |
| 14 | Finger Stretch | Wrists/Hands | Hand intrinsics |
| 15 | Elbow Flexor Stretch | Elbows/Forearms | Biceps brachii |
| 16 | Cat-Cow Stretch | Mid Back (folds into Hips/Glutes) | Spinal erectors |
| 17 | Child's Pose | Lower Back (folds into Hips/Glutes) | Latissimus dorsi |
| 18 | Seated Twist | Mid Back (folds into Hips/Glutes) | Obliques |
| 19 | Supine Twist | Lower Back (folds into Hips/Glutes) | Spinal rotators |
| 20 | Bridge Pose | Lower Back (folds into Hips/Glutes) | Gluteus, erector spinae |
| 21 | Seated Pelvic Tilts (Safe Lumbar Fallback) | Lower Back (folds into Hips/Glutes) | Core stabilizers, erector spinae |
| 22 | Seated Hip Flexor Stretch | Hips/Glutes | Iliopsoas |
| 23 | Standing Quad Stretch | Knees | Quadriceps |
| 24 | Calf Stretch | Ankles/Feet | Gastrocnemius |
| 25 | Ankle Circles | Ankles/Feet | Tibialis Anterior |

## Requested output format

Please return a single JSON array, one object per exercise, keyed by `id`, in this exact shape so
it can be pasted directly into `exercise_catalog.rs`:

```json
[
  {
    "id": 1,
    "purpose": "Relieves tension in the side of the neck built up from prolonged forward-facing desk posture.",
    "description": "Sit or stand tall. Gently tilt your right ear toward your right shoulder until you feel a stretch on the left side of your neck. Hold, then switch sides.",
    "contraindication_tags": []
  },
  {
    "id": 2,
    "purpose": "...",
    "description": "...",
    "contraindication_tags": ["significant_recent_trauma"]
  }
]
```

All 25 ids must be present. `contraindication_tags` must only use the 7 exact keys above (or `[]`).
