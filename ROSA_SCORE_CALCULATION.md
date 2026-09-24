# How the ROSA Score Is Calculated — Full Reference

This is a complete, item-by-item reference for the ROSA score: every camera
measurement, every questionnaire answer, and the exact number of points each
one adds, all the way through to the final 1–10 score. Nothing about ROSA is
left out below — if a value in the code affects the score, it's in this
document with its exact effect.

Source of truth verified directly in code: `RosaAnglesCalculator.kt/swift`,
`RosaScorer.kt/swift`, `workstation_answers.dart`,
`workstation_questionnaire_screen.dart`.

---

## The big picture

The final score is built in four layers:

1. **Base scores (1–3)** — eight small numbers, one per posture or equipment
   factor: six measured directly from the camera photo, and two — seat depth
   and phone usage — from a direct questionnaire answer, since the camera
   can't measure those.
2. **Area scores** — each base score plus any checklist "yes" answers that
   apply to that same factor (each "yes" adds +1 or +2).
3. **Section scores** — pairs of area scores are combined using three fixed
   lookup tables (Table A, B, C) from the official ROSA method, producing a
   Chair Score, a Monitor/Phone score, and a Mouse/Keyboard score.
4. **Final score** — the worst (highest) of those section scores — a plain
   maximum, not a weighted combination — capped 1–10, converted to a risk
   label.

Everything below expands each of those steps to the individual-input level.

---

## Layer 1 — Base scores from the camera

These six numbers come purely from the pose detected in the photo. Nothing in
the questionnaire changes these — they are 100% camera-driven. (The other two
base inputs — seat depth and phone usage — are questionnaire-only; see
Layer 2.)

### Seat height score (from knee angle)

| Detected knee angle | Score | Meaning |
|---|---|---|
| Under 80° | **2** | Chair too low |
| 80°–100° | **1** | Neutral / good |
| 100°–130° | **2** | Chair too high |
| Over 130° | **3** | Legs almost straight — feet likely not flat on the floor |

*If the knee/ankle is hidden in the photo, the app estimates this from
hip-vs-knee height instead of a true angle, and marks the reading as "low
confidence" — the point values are the same, only the underlying measurement
is a rougher proxy.*

### Backrest score (from trunk lean angle and backrest use)

| Trunk lean from vertical | Backrest actually used? | Score |
|---|---|---|
| 28° or less | Yes | **1** |
| 28° or less | No | **2** |
| More than 28° | Yes or No | **2** |

A worker sitting within 28° of vertical but not actually resting against the
backrest is scored the same as one leaning too far forward — holding your own
posture instead of using the chair's support is still elevated risk. Whether
the backrest is used comes from the "Chair has a usable backrest that
supports your back while working" questionnaire answer (see Section A).

### Armrest score (from shoulder shrug)

Measured as how close the shoulder sits to the ear (vertically).

| Shoulder position | Score |
|---|---|
| Shoulder relaxed, clearly below ear | **1** |
| Shoulder hiked up toward the ear | **2** |

### Monitor/neck score (from neck posture)

The app first classifies the neck into one of five postures (checked in this
order — the first match wins), then maps that posture to a score:

| Neck posture detected | Score |
|---|---|
| Head tilted back | **3** |
| Neck bent down severely (chin near chest) | **3** |
| Neck bent down mildly | **2** |
| Head jutting forward | **2** |
| Neutral | **1** |

### Keyboard/wrist score (from wrist bend)

| Wrist extension (bend upward) | Score |
|---|---|
| Small or none | **1** |
| Moderate | **2** |
| Large | **3** |

### Mouse score (from sideways reach)

| Sideways reach for the mouse (relative to shoulder) | Score |
|---|---|
| Close to the body | **1** |
| Reaching noticeably sideways | **2** |

---

## Layer 2 — Every checklist question and its exact point effect

The app asks a pre-camera questionnaire. Below is **every single question**,
worded exactly as it appears on screen, what a "Yes" vs "No" answer means for
the score, and which running subtotal ("area") it feeds into.

Important: some questions are phrased positively in the app ("X is
adjustable") but stored/scored as the opposite ("non-adjustable"). The table
below always tells you what a "Yes" answer on the actual screen does.

### Section A — Chair

| Question on screen | Answer that ADDS points | Points | Adds to |
|---|---|---|---|
| "Chair height is adjustable" | **No** | +1 | Chair-height area |
| "Enough room under the desk to cross your legs" | **No** | +1 | Chair-height area |
| "Seat pan depth (space behind your knees)" — pick one: ~3 in (OK) / Too long / Too short | **Too long or Too short** | base becomes 2 instead of 1 | Seat-pan-depth area |
| "Seat pan depth is adjustable" | **No** | +1 | Seat-pan-depth area |
| "Armrests are adjustable" | **No** | +1 | Armrest area |
| "Armrest surface is hard or damaged" | **Yes** | +1 | Armrest area |
| "Chair has a usable backrest that supports your back while working" | **No** | base backrest score becomes 2 (see Layer 1) | Backrest score / Back-support area |
| "Backrest is adjustable" | **No** | +1 | Back-support area |
| "Desk/work surface is too high (shoulders shrug)" | **Yes** | +1 | Back-support area |

- **Chair-height area** = Seat-height score (camera) + the two "No" answers above.
- **Seat-pan-depth area** = 1 (fit OK) or 2 (too long/short) + "adjustable? No" (+1).
- **Armrest area** = Armrest score (camera) + "adjustable? No" (+1) + "hard/damaged? Yes" (+1) + "armrests too wide?" (+1, see below).
- **Back-support area** = Backrest score (camera + backrest-use, see Layer 1) + "adjustable? No" (+1) + "surface too high? Yes" (+1).

**Asked in the app but do NOT affect the ROSA score** (they only feed the
separate Action/Equipment Report's recommendations):
- "Chair provides lumbar support that contacts your lower back while sitting normally"
- "Both feet are flat on the floor or a footrest while typing"

**Detected from the camera, not a checklist question:**
- Armrests being "too wide apart" (`armrestTooWide`) is not set by any
  on-screen question — it's measured automatically from the separate
  front-facing photo taken at the end of the capture sequence. An
  elbow-abduction angle of 20° or more from that photo scores +1 on the
  armrest area.

### Section B — Monitor & Telephone

| Question on screen | Answer that ADDS points | Points | Adds to |
|---|---|---|---|
| "You twist your neck more than 30° to view the monitor" | **Yes** | +1 | Monitor area |
| "Monitor is farther than arm's length away (>75cm)" | **Yes** | +1 | Monitor area |
| "There is glare on the screen" | **Yes** | +1 | Monitor area |
| "You have a document holder for paper references" | **No** | +1 | Monitor area |
| "Desk phone usage" — pick one: Don't use / Headset or 1‑hand / Reach far | Don't use = 0, Headset/1‑hand = 1, Reach far = 2 | 0 / 1 / 2 | Phone area (base) |
| "You cradle the phone between ear and shoulder" *(only asked if phone is used)* | **Yes** | +2 | Phone area |
| "You have a hands‑free option (headset/speakerphone)" *(only asked if phone is used)* | **No** | +1 | Phone area |

- **Monitor area** = Monitor/neck score (camera) + up to 4 possible +1's above (max +4).
- **Phone area** = 0, 1, or 2 (from the usage question) + up to +3 more (cradle +2, no hands-free +1).

**Asked in the app but does NOT affect the ROSA score:**
- "Monitor position is adjustable" — official ROSA only scores component
  adjustability in the Chair section, not Monitor/Telephone; still collected
  for the Action Report.
- "Top of the monitor relative to eye level" (Below / At eye level / Above) —
  used only for the Action Report's recommendation text, not the score.
- The two "supplemental" phone questions shown at the bottom of this section
  ("Do you hold/cradle the phone…", "Do you have a hands-free option
  available…") are explicitly a separate, informational-only copy and never
  touch the ROSA score.

### Section C — Mouse & Keyboard

| Question on screen | Answer that ADDS points | Points | Adds to |
|---|---|---|---|
| "Mouse and keyboard are on different surfaces/heights" | **Yes** | +2 | Mouse area |
| "You use a pinch grip on the mouse" | **Yes** | +1 | Mouse area |
| "There is a palm rest in front of the mouse" | **Yes** | +1 | Mouse area |
| "Keyboard is too high (shoulders shrug)" | **Yes** | +1 | Keyboard area |
| "You frequently reach overhead for items" | **Yes** | +1 | Keyboard area |
| "Keyboard platform/tray is adjustable" | **No** | +1 | Keyboard area |

- **Mouse area** = Mouse score (camera) + up to +4 above (different surfaces +2, pinch grip +1, palm rest +1).
- **Keyboard area** = Keyboard/wrist score (camera) + up to +3 above (too high +1, reach overhead +1, tray non-adjustable +1) + "wrist deviation?" (+1, see below).

**Asked in the app but does NOT affect the ROSA score:**
- "Mouse position is adjustable" — official ROSA only scores component
  adjustability in the Chair section, not Mouse/Keyboard; still collected
  for the Action Report.
- "Mouse is positioned far enough away that you have to reach for it"
  (`mouseTooFar`) — Action Report only.

**Detected from the camera, not a checklist question:**
- Keyboard "ulnar deviation" (`keyboardDeviation`) is not set by any
  on-screen question — it's measured automatically from the same
  front-facing photo used for the armrest check. A wrist-deviation angle of
  15° or more from that photo scores +1 on the keyboard area.

### Duration — applies to all three sections

| Question on screen | Effect |
|---|---|
| "How long do you typically work continuously at this desk?" — < 30 min / 30–60 min / > 1 hour | < 30 min → **−1**, 30–60 min → **0** (no change), > 1 hour → **+1** |

This single number is added: once to the Chair Score (after its table lookup),
and separately to *each* of the phone/monitor/mouse/keyboard areas (before
their table lookups) — see Layer 3 for exactly where.

---

## Layer 3 — Turning areas into section scores (the lookup tables)

Once all the area totals above are computed, they're combined in pairs and
looked up in one of three fixed tables from the published ROSA method (not
invented by the app — these are the standard reference tables). Every row/
column value is capped to the table's range before lookup (e.g. a value of 12
where the table only goes up to 9 is treated as 9).

### Chair Score (Table A)

```
seat_combined = clamp(Chair-height area + Seat-pan-depth area, 2, 8)
arms_combined = clamp(Armrest area + Back-support area, 2, 9)
Chair Score   = clamp(TableA[seat_combined][arms_combined] + Duration, 1, 10)
```

### Section B Score — Monitor & Telephone (Table B)

```
phone_row   = clamp(Phone area + Duration, 0, 6)
monitor_col = clamp(Monitor area + Duration, 0, 7)
Section B   = TableB[phone_row][monitor_col]
```

### Section C Score — Mouse & Keyboard (Table C)

```
mouse_row      = clamp(Mouse area + Duration, 0, 7)
keyboard_col   = clamp(Keyboard area + Duration, 0, 7)
Section C      = TableC[mouse_row][keyboard_col]
```

### The tables themselves

**Table A** — row = seat_combined (2–8), column = arms_combined (2–9):

| Row \ Col | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|
| 2 | 2 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| 3 | 2 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| 4 | 3 | 3 | 3 | 4 | 5 | 6 | 7 | 8 |
| 5 | 4 | 4 | 4 | 4 | 5 | 6 | 7 | 8 |
| 6 | 5 | 5 | 5 | 5 | 6 | 7 | 8 | 9 |
| 7 | 6 | 6 | 6 | 7 | 7 | 8 | 8 | 9 |
| 8 | 7 | 7 | 7 | 8 | 8 | 9 | 9 | 9 |

**Table B** — row = phone_row (0–6), column = monitor_col (0–7):

| Row \ Col | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| 0 | 1 | 1 | 1 | 2 | 3 | 4 | 5 | 6 |
| 1 | 1 | 1 | 2 | 2 | 3 | 4 | 5 | 6 |
| 2 | 1 | 2 | 2 | 3 | 3 | 4 | 6 | 7 |
| 3 | 2 | 2 | 3 | 3 | 4 | 5 | 6 | 8 |
| 4 | 3 | 3 | 4 | 4 | 5 | 6 | 7 | 8 |
| 5 | 4 | 4 | 5 | 5 | 6 | 7 | 8 | 9 |
| 6 | 5 | 5 | 6 | 7 | 8 | 8 | 9 | 9 |

**Table C** — row = mouse_row (0–7), column = keyboard_col (0–7):

| Row \ Col | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| 0 | 1 | 1 | 1 | 2 | 3 | 4 | 5 | 6 |
| 1 | 1 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| 2 | 1 | 2 | 2 | 3 | 4 | 5 | 6 | 7 |
| 3 | 2 | 3 | 3 | 3 | 5 | 6 | 7 | 8 |
| 4 | 3 | 4 | 4 | 5 | 5 | 6 | 7 | 8 |
| 5 | 4 | 5 | 5 | 6 | 6 | 7 | 8 | 9 |
| 6 | 5 | 6 | 6 | 7 | 7 | 8 | 8 | 9 |
| 7 | 6 | 7 | 7 | 8 | 8 | 9 | 9 | 9 |

---

## Layer 4 — Final combination and risk level

```
Peripheral Score = max(Section B, Section C)      capped to 1–9
Final ROSA Score = max(Chair Score, Peripheral)   capped to 1–10
```

"Max" means the worse of the two wins — a good chair never offsets a bad
monitor setup, and vice versa.

| Final Score | Risk Level | App treats as "needs action"? |
|---|---|---|
| 1–2 | Low Risk | No |
| 3–4 | Medium Risk | No |
| 5–6 | High Risk | Yes |
| 7–10 | Very High Risk | Yes |

The Low/Medium/High/Very-High labels are the app's own presentation tiers.
The one threshold that comes directly from the published ROSA methodology is
the "needs action" cutoff itself: a final score of 5 or above calls for
attention, matching the original ROSA paper — the four-way label split is a
UI convenience layered on top of that single validated cutoff, not a
separately validated scale.

---

## Worked example, start to finish

Say the camera detects: knee angle 95° (score 1), trunk lean 20° with
backrest in use (score 1), shoulder relaxed (armrest score 1), neck neutral
(monitor score 1), wrist
extension small (keyboard score 1), mouse reach small (mouse score 1). The
person answers "No" to chair height adjustable (+1), "Yes" to screen glare
(+1), "Yes" to pinch grip on mouse (+1), and picks ">1 hour" for duration
(+1 everywhere). Everything else is answered favorably (no other points).

- Chair-height area = 1 (camera) + 1 (not adjustable) = **2**
- Seat-pan-depth area = 1 (fits OK) + 0 = **1** → seat_combined = clamp(2+1,2,8) = **3**
- Armrest area = 1 (camera) + 0 = **1**
- Back-support area = 1 (camera) + 0 = **1** → arms_combined = clamp(1+1,2,9) = **2**
- Table A[3][2] = **2**, + duration (+1) = **Chair Score = 3**

- Monitor area = 1 (camera) + 1 (glare) = **2**; + duration → monitor_col = 3
- Phone area = 0 (doesn't use phone) + duration → phone_row = 1
- Table B[1][3] = **2** → **Section B = 2**

- Mouse area = 1 (camera) + 1 (pinch grip) = **2**; + duration → mouse_row = 3
- Keyboard area = 1 (camera) + 0 = **1**; + duration → keyboard_col = 2
- Table C[3][2] = **3** → **Section C = 3**

- Peripheral Score = max(2, 3) = **3**
- **Final ROSA Score = max(3, 3) = 3 → Medium Risk**

---

## Multiple photos in one scan

Each photo in a scan gets its own full calculation as above. Photos where the
pose couldn't be detected at all are excluded. The scan's displayed score is
the **average of all valid photos' final scores** (rounded to the nearest
whole number), with the risk label re-derived from that averaged number using
the same table. If no photo produced a valid score, the whole scan is marked
invalid.
