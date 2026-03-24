function draft = mock_ai_response(aiInput)
%MOCK_AI_RESPONSE Build deterministic draft strictly from structured input.
input = aiInput.structured_input;

techProgress = i_field_lines(input, 'activities', 'title');
docSummary = i_field_lines(input, 'documents_reviewed', 'title');
meetingSummary = i_field_lines(input, 'meetings', 'title');
nextSteps = {};
if isfield(input, 'next_steps')
    nextSteps = cellstr(string(input.next_steps));
end

ria = struct('risks',{{}},'issues',{{}},'actions',{{}});
if isfield(input, 'risks_issues_actions')
    if isfield(input.risks_issues_actions, 'risks')
        ria.risks = i_field_lines(input.risks_issues_actions, 'risks', 'description');
    end
    if isfield(input.risks_issues_actions, 'issues')
        ria.issues = i_field_lines(input.risks_issues_actions, 'issues', 'description');
    end
    if isfield(input.risks_issues_actions, 'actions')
        ria.actions = i_field_lines(input.risks_issues_actions, 'actions', 'description');
    end
end

summary = sprintf('Draft generated for %s based on structured weekly intake.', string(aiInput.report_metadata.project_id));

draft = struct();
draft.schema_version = '1.0.0';
draft.report_text = struct( ...
    'executive_summary', summary, ...
    'technical_progress', {techProgress}, ...
    'documents_reviewed_summary', {docSummary}, ...
    'meetings_summary', {meetingSummary}, ...
    'risks_issues_actions_summary', ria, ...
    'next_steps_summary', {nextSteps});
draft.quality_flags = struct( ...
    'contains_uncertainty', false, ...
    'requires_human_review', true, ...
    'unsupported_claims_detected', false);
end

function lines = i_field_lines(parent, collectionField, fieldName)
lines = {};
if ~isfield(parent, collectionField)
    return;
end
items = parent.(collectionField);
for i = 1:numel(items)
    if isfield(items(i), fieldName)
        lines{end+1} = char(string(items(i).(fieldName))); %#ok<AGROW>
    end
end
end
