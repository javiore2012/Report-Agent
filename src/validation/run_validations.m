function validation = run_validations(workPacket, rules)
%RUN_VALIDATIONS Execute core validation checks.
if nargin < 2
    rules = rules_registry();
end

errors = {};
warnings = {};

if ~isfield(workPacket, 'report_metadata') || ~isfield(workPacket, 'structured_input')
    error('run_validations:InvalidPacket', 'workPacket missing report_metadata or structured_input');
end

meta = workPacket.report_metadata;
input = workPacket.structured_input;

if ~isfield(meta, 'project_id') || strlength(string(meta.project_id)) == 0
    errors{end+1} = 'VR-001: project_id required'; %#ok<AGROW>
end
if ~isfield(meta, 'reporting_period') || ~isfield(meta.reporting_period, 'start_date') || ~isfield(meta.reporting_period, 'end_date')
    errors{end+1} = 'VR-002: reporting period required'; %#ok<AGROW>
end
if ~isfield(input, 'activities') || isempty(input.activities)
    errors{end+1} = 'VR-003: at least one activity required'; %#ok<AGROW>
end
if ~isfield(input, 'next_steps') || isempty(input.next_steps)
    errors{end+1} = 'VR-005: at least one next step required'; %#ok<AGROW>
end
if ~i_has_raw_notes(workPacket)
    warnings{end+1} = 'VR-006: missing raw free_text_summary and notes'; %#ok<AGROW>
end

maxHours = rules.max_hours_per_activity;
dupeKeys = strings(0,1);
if isfield(input, 'activities')
    acts = input.activities;
    for i = 1:numel(acts)
        a = acts(i);
        requiredFields = {'title','description','category','hours'};
        for rf = 1:numel(requiredFields)
            f = requiredFields{rf};
            if ~isfield(a, f) || strlength(string(a.(f))) == 0
                errors{end+1} = sprintf('VR-004: activity[%d] missing %s', i, f); %#ok<AGROW>
            end
        end
        if isfield(a,'hours') && (~isnumeric(a.hours) || ~isscalar(a.hours) || double(a.hours) <= 0 || double(a.hours) > maxHours)
            errors{end+1} = sprintf('VR-010: activity[%d] hours out of range', i); %#ok<AGROW>
        end

        hasDeliverable = isfield(a,'deliverables_touched') && ~isempty(a.deliverables_touched);
        hasEvidence = isfield(a,'evidence_refs') && ~isempty(a.evidence_refs);
        if hasDeliverable && ~hasEvidence
            warnings{end+1} = sprintf('VR-020: activity[%d] has deliverables_touched but no evidence_refs', i); %#ok<AGROW>
        end

        if isfield(a,'title') && isfield(a,'hours')
            if isfield(a,'date')
                datePart = string(a.date);
            else
                datePart = "no_date";
            end
            key = lower(strtrim(string(a.title))) + "|" + datePart + "|" + string(a.hours);
            dupeKeys(end+1,1) = key; %#ok<AGROW>
        end
    end
end

if ~isempty(dupeKeys)
    [uniqueKeys, ~, idx] = unique(dupeKeys);
    counts = accumarray(idx, 1);
    for i = 1:numel(uniqueKeys)
        if counts(i) > 1
            warnings{end+1} = sprintf('VR-013: duplicate activity signature detected (%s)', uniqueKeys(i)); %#ok<AGROW>
        end
    end
end

if isfield(input,'documents_reviewed')
    docs = input.documents_reviewed;
    for i = 1:numel(docs)
        if ~isfield(docs(i),'title') || strlength(string(docs(i).title)) == 0
            errors{end+1} = sprintf('VR-021: documents_reviewed[%d] missing title', i); %#ok<AGROW>
        end
    end
end

if isfield(input,'meetings')
    meetings = input.meetings;
    for i = 1:numel(meetings)
        if ~isfield(meetings(i),'date') || strlength(string(meetings(i).date)) == 0
            errors{end+1} = sprintf('VR-022: meetings[%d] missing date', i); %#ok<AGROW>
        end
    end
end

if isempty(errors) && isempty(warnings)
    status = 'PASS';
elseif isempty(errors)
    status = 'PASS_WITH_WARNINGS';
else
    status = 'FAIL';
end

validation = struct();
validation.status = status;
validation.error_count = numel(errors);
validation.warning_count = numel(warnings);
validation.errors = errors;
validation.warnings = warnings;
validation.rules_version = 'sprint1-hardened';
validation.checked_at = string(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z'''));
end

function yes = i_has_raw_notes(workPacket)
yes = false;
if isfield(workPacket, 'raw_intake')
    ri = workPacket.raw_intake;
    hasFree = isfield(ri, 'free_text_summary') && strlength(strtrim(string(ri.free_text_summary))) > 0;
    hasNotes = isfield(ri, 'notes') && ~isempty(ri.notes);
    yes = hasFree || hasNotes;
end
end
