# Report-Agent (Sprint 1 MVP, Hardened)

MATLAB-based reporting automation scaffold for weekly engineering reports.

## Sprint 1 scope
This MVP implements a mock, end-to-end pipeline:
1. Intake loading (JSON and Excel-oriented loader entrypoint).
2. Normalization into a canonical work packet.
3. Validation (completeness, consistency, evidence linkage, duplicate activity warnings).
4. Mock AI draft generation in schema-conforming JSON.
5. Draft artifact rendering (JSON/text outputs in Sprint 1).
6. Traceability logging for all key transformations.

> Human-in-the-loop is preserved: generated outputs are drafts only and approval remains a manual workflow step.

## Repository structure
- `src/` MATLAB implementation modules.
- `tests/` MATLAB unit tests for core flows.
- `examples/` sample intake and generated sample artifacts.
- `schemas/` JSON schemas + legacy examples preserved from initial repo state.
- `config/` model and template configuration + validation rule registry.
- `docs/` blueprint and implementation notes.
- `templates/` existing template artifacts (xlsx) retained.

## Quick start (MATLAB)
```matlab
addpath(genpath('src'));
result = main('examples/weekly_intake_example.json', 'runs');
```

`result` includes paths to generated files:
- normalized work packet JSON,
- validation results JSON,
- AI draft JSON,
- rendered artifacts,
- trace log JSON.

## Intake format (Sprint 1)
Sprint 1 ships a stable JSON intake example (`examples/weekly_intake_example.json`) to avoid environment fragility around spreadsheet generation.

`load_intake_excel.m` also supports `.xlsx` using these expected sheets:
- `Metadata`
- `Activities`
- `DocumentsReviewed`
- `Meetings`
- `Risks`
- `Issues`
- `Actions`
- `NextSteps`

## Hardening added in this revision
- Root-relative path resolution for config/schemas/examples.
- Basic schema checks executed for intake, work packet, and AI draft.
- Validation improvements:
  - duplicate activity signature warning (`VR-013`),
  - stricter required field checks,
  - activity hour type/range guard,
  - raw-intake context warning (`VR-006`).
- Trace logs now include schema-check outputs and runtime host metadata.

## Validation/Rendering order
Validation is executed before any rendering. If validation status is `FAIL`, rendering is blocked.

## Notes
- No API keys are stored in repository files.
- AI behavior is mock-only in Sprint 1 (`mock_mode=true`).
- Existing `.xlsx` template files are preserved and mapped in config but renderers currently emit JSON/text drafts for reliability.

## Known blockers before real API integration
- No production-grade JSON Schema validator library is wired yet (current checks are basic and schema-subset only).
- No secure prompt assembly/redaction pipeline for restricted fields yet.
- No retry/backoff/error taxonomy for external model calls yet.
- No signed artifact integrity hash in trace log yet.
