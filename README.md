# Report-Agent (Sprint 1 MVP)

MATLAB-based reporting automation scaffold for weekly engineering reports.

## Sprint 1 scope
This MVP implements a mock, end-to-end pipeline:
1. Intake loading (JSON and Excel-oriented loader entrypoint).
2. Normalization into a canonical work packet.
3. Validation (completeness, consistency, evidence linkage).
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

## Validation/Rendering order
Validation is executed before any rendering. If validation status is `FAIL`, rendering is blocked.

## Notes
- No API keys are stored in repository files.
- AI behavior is mock-only in Sprint 1 (`mock_mode=true`).
- Existing `.xlsx` template files are preserved and mapped in config but renderers currently emit JSON/text drafts for reliability.
