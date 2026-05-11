# Desktop-Only Scope Design

**Date:** 2026-05-11  
**Project:** KÌ: Ba Lá Của Bản Ngã  
**Decision:** Drop official mobile web browser support. Keep desktop browser as only supported runtime target.

## Goal

Reduce demo scope before 2026-05-15 by removing mobile-specific requirements that add UI, testing, and layout overhead without being core to the intended tarot narrative loop.

## Scope Decision

Project will remain a Godot Web / HTML5 build, but it will only officially support desktop browsers.

This is a soft cut, not a hard block:
- The game may still open on phones.
- The team will not optimize for phone layouts, touch ergonomics, or phone viewport stability.
- A broken or degraded phone experience is acceptable unless it also harms desktop.

## Why This Change

Current project guidance still requires both desktop and phone browser support, which forces extra constraints on screen layout, text sizing, button sizing, and verification.

Those constraints do not directly improve the core demo path:
1. Title screen
2. Intro
3. Onboarding questions
4. Three-card reveal
5. Three inner spaces
6. AI interpretation
7. Mini card game
8. Final AI report

Dropping official mobile support narrows work to one target environment and reduces last-mile UI churn.

## Recommended Approach

Use a desktop-first cleanup approach.

This means:
- remove mobile support claims from docs and verification rules,
- stop designing screens around narrow portrait viewports,
- keep only desktop resize resilience,
- avoid any large visual redesign unless a screen already needs edits for other reasons.

This avoids both extremes:
- not merely changing words in docs while keeping hidden mobile constraints in code,
- not expanding scope into a full desktop-only visual overhaul.

## Product and UX Changes

### Supported target
- Supported runtime target becomes desktop browser only.
- Recommended baseline becomes desktop landscape.
- Minimum practical layout target should be treated as desktop-class width, such as 1280x720 or similar.

### Unsupported concerns
The following are no longer product requirements:
- touch-friendly UI sizing,
- phone text readability guarantees,
- portrait-phone layout stability,
- mobile browser chrome/viewport quirks,
- virtual keyboard avoidance for free-text input,
- tap-target sizing chosen mainly for thumbs.

### Desktop-first behavior
UI may now favor desktop interaction patterns such as:
- hover affordances,
- denser horizontal layouts,
- side-by-side panels,
- less oversized buttons when not needed,
- keyboard quality-of-life improvements if low effort.

## Layout and Screen Design Impact

### Keep
- Basic resize handling within desktop window sizes.
- Scroll where content is genuinely long on desktop.
- Mouse-driven click flow.
- Clear AI error and retry states.

### Remove or stop optimizing for
- portrait-safe stacking used only for phones,
- extra-wide tap spacing,
- full-width mobile buttons by default,
- narrow-screen rescue layouts,
- phone-first text wrapping constraints,
- screen-by-screen viewport checks around ~390x844.

### Future screen work rule
When editing or building screens, design for desktop first. Do not add mobile-specific layout branches unless they also improve desktop or are nearly free.

## Testing and Verification Changes

### Remove from success criteria
- phone viewport verification,
- requirement that both desktop and phone browsers work,
- touch usability checks.

### Replace with desktop checks
Verification should focus on:
- full golden-path completion in desktop browser,
- no broken layout at desktop-class window sizes,
- readable text and usable controls with mouse input,
- no regressions in AI error flow, card reveal, minigame, and final report.

## Documentation Changes Required

These existing docs should be updated to match decision:
- `CLAUDE.md`
- `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`
- any existing plan/spec that still states desktop + phone support

### Required wording updates in `CLAUDE.md`
- Change target from desktop browser + phone browser to desktop browser only.
- Remove phone viewport requirement from core demo path.
- Remove phone viewport verification line.
- Remove touch-friendly and phone-browser readability requirements.

### Required wording updates in structure doc
- Change target summary from desktop + phone to desktop only.
- Update verification section to desktop-only checks.
- Record this scope change in structure changelog.

## Non-Goals

This decision does not require:
- native desktop export,
- Electron wrapper,
- hard-blocking phones,
- immediate redesign of every existing scene,
- abandoning responsive behavior inside desktop widths.

## Risks

### Risk: old mobile assumptions remain in code
Some scenes may still carry mobile-safe layout decisions. That is acceptable unless they slow future work or harm desktop.

### Risk: desktop density becomes inconsistent
If some screens stay mobile-loose while others become desktop-dense, UX may feel uneven. Resolve opportunistically when touching affected screens.

### Risk: accidental hard break on small desktop windows
Even without phone support, layout should still avoid breaking at common desktop sizes.

## Implementation Boundary

This design only changes supported target and downstream requirements.

It does not, by itself, require new gameplay, scene architecture, or AI flow changes. Implementation should stay narrowly focused on:
1. docs and verification rules,
2. target statements,
3. UI constraints that exist only because of mobile support.

## Acceptance Criteria

This scope change is complete when:
1. project docs consistently describe desktop browser as only supported target,
2. core demo path no longer promises phone usability,
3. verification checklist no longer includes phone viewport testing,
4. future UI work is allowed to ignore phone-specific constraints,
5. desktop browser full flow remains intact.
