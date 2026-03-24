# Blueprint v1 - MATLAB Engineering Weekly Report Automation

## Purpose
Transform structured engineer weekly intake into validated, traceable, reviewable draft report artifacts.

## Sprint 1 architecture
1. **Input layer** (`src/input`)
   - `load_intake_excel.m`: load standardized intake from `.json` or expected `.xlsx` layout.
2. **Normalization layer** (`src/normalization`)
   - `build_work_packet.m`: canonical work packet construction.
3. **Validation layer** (`src/validation`)
   - `rules_registry.m`: static registry from config.
   - `run_validations.m`: machine-readable validation execution.
   - `validate_schema_basics.m`: schema-subset conformance checks.
4. **AI layer (mock)** (`src/ai`)
   - `build_ai_input_packet.m`
   - `mock_ai_response.m`
   - `parse_ai_structured_output.m`
5. **Template/rendering layer** (`src/templates`)
   - `render_weekly_report.m`
   - `render_activity_log.m`
   - `render_document_tracker.m`
6. **Audit layer** (`src/audit`)
   - `write_trace_log.m`
7. **Orchestration** (`src/main.m`)

## Canonical Sprint 1 data contracts
- Input contract: `schemas/intake.schema.json`
- Work packet contract: `schemas/work_packet.schema.json`
- AI draft contract: `schemas/ai_draft.schema.json`

## Hardening highlights
- Root-relative path handling to reduce caller working-directory fragility.
- Duplicate activity signature detection (warning path).
- Schema checks at intake/work-packet/AI-draft stages.
- Trace log includes schema issue lists and runtime metadata.

## Non-goals for Sprint 1
- Final approval workflow automation.
- Live LLM API integration.
- Rich DOCX generation.

## Traceability requirements
All major steps emit artifacts and trace metadata:
- intake source path,
- normalized packet path,
- validation result path,
- AI draft path,
- rendered artifact paths,
- schema check results,
- timestamps and module versions.

## Known blockers before real API integration
1. Replace schema-subset validator with full JSON Schema engine.
2. Add sensitive-field filtering before model input serialization.
3. Add model adapter abstraction with retry/backoff and deterministic error handling.
4. Add prompt/package version pinning with hash-based trace integrity.
