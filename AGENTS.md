# AGENTS.md

## Project Purpose
This repository implements a MATLAB-based reporting automation system for engineering weekly reports.
The system must transform structured engineer inputs into validated, traceable, reviewable report drafts.

## Core Rules
- Never invent activities, hours, evidence, meetings, or document reviews.
- Structured data comes first; narrative comes second.
- All AI outputs must conform to JSON Schema.
- No final report can be marked approved without human review.
- Do not hardcode secrets or API keys.
- Keep validation logic separate from rendering logic.
- Every new module must include tests.
- Log all transformations that affect report content.

## Engineering Conventions
- Use modular MATLAB functions.
- Keep functions small and single-purpose.
- Prefer table/struct/json workflows over loose scripts.
- Fail loudly on missing required fields.
- Add comments only where they improve maintainability.

## Done When
- Required modules exist.
- Tests for core flows pass.
- Example input can produce a draft report.
- AI output is schema-valid.
- Audit log is generated.

No silent assumptions: el sistema no inventa actividades, horas ni evidencia.
Human-in-the-loop: la AI redacta borradores; el humano revisa y aprueba.
Structured data first: primero datos estructurados, después narrativa.
Template-driven: todo sale de plantillas controladas.
Traceability by default: cada transformación queda registrada.
Validation before rendering: no se genera reporte final si falla la validación.
