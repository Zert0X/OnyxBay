# Virus2 migration checklist

## 1) External call map for legacy public contracts

### `infect_virus2(...)`
- `code/modules/admin/admin_verbs.dm`
- `code/datums/events/space_cold.dm`
- `code/modules/mob/organs/blood.dm`
- `code/modules/mob/living/simple_animal/hostile/vagrant.dm`
- `code/modules/mob/living/simple_animal/friendly/mouse.dm`
- `code/modules/mob/living/carbon/human/human_powers.dm`
- `code/modules/reagents/Chemistry-Reagents/blood.dm`
- `code/modules/virus2/admin.dm`
- `code/modules/virus2/items_devices.dm`
- `code/modules/virus2/pestilence.dm`
- `code/modules/virus2/effects/engineering.dm`

### `mob.virus2` reads/writes
- `code/modules/mob/living/carbon/viruses.dm`
- `code/game/machinery/adv_med.dm`
- `code/game/objects/items/devices/scanners.dm`
- `code/modules/reagents/Chemistry-Reagents/basic.dm`
- `code/game/turfs/simulated.dm`
- `code/game/mecha/medical/odysseus.dm`
- `code/modules/virus2/*` (analysis/virology machinery)

### `spread_disease_to(...)`
- `code/modules/mob/living/carbon/human/life.dm`
- `code/modules/mob/living/carbon/human/human_attackhand.dm`
- `code/modules/mob/living/carbon/carbon.dm`
- `code/modules/virus2/effects/mild.dm`

### `handle_viruses()`
- `code/modules/mob/living/carbon/life.dm`

### `SSvirus.queue_virus(...)`
- Replaced by runtime-core queue adapter (`pathogen_runtime.queue()` -> `SSvirus.queue_runtime()`).

## 2) Public contract migration status

- [x] `infect_virus2(mob, disease, forced)` keeps signature and delegates to `/datum/pathogen_runtime/infect()`.
- [x] `mob/living/carbon/spread_disease_to(victim, channel)` keeps signature and delegates to `/datum/pathogen_runtime/spread()`.
- [x] `mob/living/carbon/handle_viruses()` keeps signature and delegates to `/datum/pathogen_runtime/handle_mob()`.
- [x] `SSvirus.queue_virus(circuit, immediate)` keeps signature and delegates to `queue_runtime(...)`.

## 3) Call-site data migration (`spreadtype`, `antigen`, `effects`, `stage`)

- [x] Machines/med scanners switched to disease getters for stage evaluation where used.
- [x] Blood/reagents switched from `V.antigen` to `V.get_antigen_signature()`.
- [x] Event setup switched from direct `spreadtype` assignment to `set_legacy_spreadtype(...)` adapter.
- [x] Admin info panels switched to `get_effect_dtos()`, `get_antigen_signature()`, and transmission descriptor getter.
- [x] Decal blood transfer switched to `mob.get_virus_copies()`.

## 4) Legacy cleanup

- [x] Removed direct runtime usage of `SSvirus.queue_virus(...)` from mob lifecycle handling.
- [x] Removed direct disease processing implementation from `mob/living/carbon/handle_viruses()` (now pure adapter).
- [ ] Remaining legacy compatibility fields still present in disease datum (`spreadtype` field and legacy helpers) pending complete module migration.

## 5) Module-by-module checklist

- [x] ?????????? (health analyzer / advanced med scanner)
- [x] ???????? ?????
- [x] ???????
- [x] ???????
- [x] ???-????????
- [x] ??????
- [x] ?????? (virology/med machinery touched by migration)
