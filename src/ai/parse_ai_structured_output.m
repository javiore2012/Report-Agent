function parsed = parse_ai_structured_output(aiOutput)
%PARSE_AI_STRUCTURED_OUTPUT Parse and minimally verify AI structured draft.
if ischar(aiOutput) || isstring(aiOutput)
    parsed = jsondecode(aiOutput);
else
    parsed = aiOutput;
end
required = {'schema_version','report_text','quality_flags'};
for i = 1:numel(required)
    if ~isfield(parsed, required{i})
        error('parse_ai_structured_output:MissingField', 'Missing AI output field: %s', required{i});
    end
end
if ~isfield(parsed.report_text, 'technical_progress') || ~iscell(parsed.report_text.technical_progress)
    error('parse_ai_structured_output:InvalidField', 'report_text.technical_progress must be an array');
end
if ~isfield(parsed.quality_flags, 'requires_human_review') || ~parsed.quality_flags.requires_human_review
    error('parse_ai_structured_output:InvalidField', 'requires_human_review must be true');
end
end
