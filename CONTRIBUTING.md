# CONTRIBUTING

It is important to maintain quality and consistency across the entire code base. This document covers key rules and
practices when working with an NinjaMonkeyGames project.

- [CONTRIBUTING](#contributing)
  - [Coding Standards \& Best Practices](#coding-standards--best-practices)
  - [1. Naming Conventions](#1-naming-conventions)
  - [2. Global Declarations](#2-global-declarations)
  - [3. Data Structures \& Syntax](#3-data-structures--syntax)
  - [4. Expressions \& Assignment](#4-expressions--assignment)
  - [5. Documentation \& Function Annotations](#5-documentation--function-annotations)
  - [6. Resource Management](#6-resource-management)
  - [7. Commit \& CI Rules](#7-commit--ci-rules)
  - [USEFUL COMMANDS](#useful-commands)
    - [STAGE ALL CHANGES](#stage-all-changes)
    - [COMMIT CHANGES](#commit-changes)
    - [PUSH REFS](#push-refs)
    - [BUILD DOCKER LOCALLY](#build-docker-locally)
    - [CONFIRM DOCKER ENTRY POINT IS WORKING](#confirm-docker-entry-point-is-working)
    - [BUILD AND PUSH TO REMOTE WITH ATTESTATIONS](#build-and-push-to-remote-with-attestations)
    - [SCAN DOCKER FOR SECURITY ISSUES](#scan-docker-for-security-issues)
    - [REMOVE ALL LOCAL BUILD IMAGES](#remove-all-local-build-images)
  - [CONTACT INFORMATION](#contact-information)
  - [COPYRIGHT](#copyright)

## Coding Standards & Best Practices

## 1. Naming Conventions

- **Globals:** Must be declared in `UPPER_CASE`.
- **Local Variables:** Must be `lower_case` and prefixed with an underscore (e.g., `_player_health`).
- **Assets:** Must be in `snake_case` and prefixed with a prefix type code (e.g.,
- `spr_player_idle`, `obj_enemy_boss`).

| Asset Type        | Prefix | Example              |
| :---------------- | :----- | :------------------- |
| Sprite            | spr_   | spr_player_idle      |
| Object            | obj_   | obj_player           |
| Room              | rm_    | rm_level_one         |
| Script            | spt_   | scr_calculate_damage |
| Sound/Audio       | snd_   | snd_jump             |
| Tile Set          | ts_    | ts_forest_tiles      |
| Font              | fnt_   | fnt_main_menu        |
| Shader            | shd_   | shd_greyscale        |
| Animation Curve   | acv_   | acv_jump_height      |
| Sequence          | seq_   | seq_player_death     |
| Particle System   | ps_    | ps_fire_smoke        |
| Time Source       | tsrc_  | tsrc_cooldown_timer  |
| Path              | pth_   | pth_enemy_patrol     |

## 2. Global Declarations

- Global-scope variables must be declared at the file level, outside of any function or method.
- Functions may reference global variables but are prohibited from introducing new global symbols.

## 3. Data Structures & Syntax

- **Array Indexing:** Use bracket-nesting syntax exclusively: `array[x][y]`. Tuple-style indexing
(e.g., `array[x, y]`) is forbidden.
- **Ternary Operator:** Use `condition ? true_val : false_val` for concise conditional assignments.
- **Code Style:**
  - **Allman Style:** Braces must be on the next line for block structures.
  - **One-Liners:** APL (Allowed Per-Line) style is permitted only for trivial, short statements.
  - **Double equals:** Use (==) when comparing values.
  - **Draw Events:** The Draw event must be reserved exclusively for rendering/drawing commands. It is strictly
    prohibited to place game logic, state calculations, or data processing within any Draw event.

## 4. Expressions & Assignment

- **No Magic Numbers:** Do not use literal numeric constants in game logic. Replace them with named
constants using `const` or `#macro` (e.g., `#macro SPEED_MAX 120`).
- **No In-Place Mutation:** A calculation must not mutate a source operand within the same expression.
  - *Bad:* `_x += _dx;`
  - *Good:* `var _next_x = _x + _dx; _x = _next_x;`
- **Side-Effect Prohibition:** Avoid side effects within expressions (e.g., `arr[i] += val`
or calling functions inside larger expressions).
- **Object Instantiation:** All `new` calls must be assigned to a variable immediately. Anonymous instantiation is
- prohibited.
  - *Bad:* `new Player();`
  - *Good:* `var _player = new Player();`
- **Respect datatype structure:** Example: Do not use 1 in place of True nor 0 in place of False.

## 5. Documentation & Function Annotations

- **JSDoc:** All functions must use the GameMaker JSDoc system for documentation.
- **Annotations:** Explicitly mark functions with `@pure` or `@void` tags where applicable.
- optimisation and code clarity.
- Comment Philosophy: "Comments should explain the intent ('Why' this is done) rather than the mechanics
- ('What' the code does), as the code itself should be self-documenting through clear variable naming."

## 6. Resource Management

**Proposed Text:** "Resources allocated manually (e.g., ds_list_create, buffer_create, surface_create) must be cleaned
up in the corresponding CleanUp event. Always check if (ds_exists(_data, ds_type_list)) before calling ds_list_destroy."

## 7. Commit & CI Rules

- **Signed Commits:** All commits must be signed with a GPG key.
- **Markdownlint** Markdownlint is used to ensure formatting consistency within the projects markdown documents.
- **Commitlint** All commit messages must be conventional commits compliant. This is checked with commitlint but
- You must also make sure all your commit messages are compliant.
- You must ensure your spelling and grammar are correct both in documentation and in code comments.

## USEFUL COMMANDS

### STAGE ALL CHANGES

```bash
git add .
```

### COMMIT CHANGES

```bash
git commit --file .git/COMMIT_EDITMSG
```

### PUSH REFS

```bash
git push .
```

### BUILD DOCKER LOCALLY

```bash
docker build -t markdownlint-cli2-ci .
```

### CONFIRM DOCKER ENTRY POINT IS WORKING

```bash
docker run --rm markdownlint-cli2-ci --version
```

### BUILD AND PUSH TO REMOTE WITH ATTESTATIONS

```bash
docker buildx build --platform linux/amd64,linux/arm64 
  -t monkeyknuckles/markdownlint-cli2-ci:debug
  --attest type=provenance,mode=max 
  --attest type=sbom 
  --push .
```

### SCAN DOCKER FOR SECURITY ISSUES

```bash
docker scout cves --only-fixed monkeyknuckles/markdownlint-cli2-ci:debug
```

### REMOVE ALL LOCAL BUILD IMAGES

```bash
docker system prune -a --volumes
```

## CONTACT INFORMATION

Author: Daniel Mallett (Monkey Knuckles)

If you have any problems with the repository or have any suggestions please contact us at <info@ninjamonkeygames.com>.

You may also contact us via our [website](https://ninjamonkeygames.com).

Any bugs should be raised as an [issue](https://github.com/NinjaMonkeyGames/project-name-here/issues) on GitHub.

---

## COPYRIGHT

*NinjaMonkeyGames™ Copyright © 2026 All rights reserved.*
