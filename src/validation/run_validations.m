function validation = run_validations(workPacket, rules)
%RUN_VALIDATIONS Execute core validation checks.
if nargin < 2
    rules = rules_registry();
end

errors = {};
warnings = {};

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

maxHours = rules.max_hours_per_activity;
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
        if isfield(a,'hours') && (double(a.hours) <= 0 || double(a.hours) > maxHours)
            errors{end+1} = sprintf('VR-010: activity[%d] hours out of range', i); %#ok<AGROW>
        end
        hasDeliverable = isfield(a,'deliverables_touched') && ~isempty(a.deliverables_touched);
        hasEvidence = isfield(a,'evidence_refs') && ~isempty(a.evidence_refs);
        if hasDeliverable && ~hasEvidence
            warnings{end+1} = sprintf('VR-020: activity[%d] has deliverables_touched but no evidence_refs', i); %#ok<AGROW>
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
validation.errors = errors;
validation.warnings = warnings;
validation.rules_version = 'sprint1';
validation.checked_at = string(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z'''));
end
