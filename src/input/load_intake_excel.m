function intake = load_intake_excel(inputPath)
%LOAD_INTAKE_EXCEL Load standardized intake from JSON or expected Excel sheets.
if ~isfile(inputPath)
    error('load_intake_excel:MissingFile', 'Input file not found: %s', inputPath);
end

[~,~,ext] = fileparts(inputPath);
ext = lower(ext);

switch ext
    case '.json'
        intake = json_io('read', inputPath);
    case '.xlsx'
        intake = i_load_from_xlsx(inputPath);
    otherwise
        error('load_intake_excel:UnsupportedExtension', 'Unsupported extension: %s', ext);
end

required = ["report_metadata", "structured_input"];
for i = 1:numel(required)
    if ~isfield(intake, required(i))
        error('load_intake_excel:MissingField', 'Missing required field: %s', required(i));
    end
end
end

function intake = i_load_from_xlsx(inputPath)
meta = readtable(inputPath, Sheet='Metadata', TextType='string');
acts = readtable(inputPath, Sheet='Activities', TextType='string');
docs = readtable(inputPath, Sheet='DocumentsReviewed', TextType='string');
meet = readtable(inputPath, Sheet='Meetings', TextType='string');
risks = readtable(inputPath, Sheet='Risks', TextType='string');
issues = readtable(inputPath, Sheet='Issues', TextType='string');
actions = readtable(inputPath, Sheet='Actions', TextType='string');
nextSteps = readtable(inputPath, Sheet='NextSteps', TextType='string');

intake = struct();
intake.report_metadata = struct( ...
    'project_id', i_get_meta(meta, 'project_id'), ...
    'project_name', i_get_meta(meta, 'project_name'), ...
    'report_type', i_get_meta(meta, 'report_type'), ...
    'reporting_period', struct( ...
        'start_date', i_get_meta(meta, 'start_date'), ...
        'end_date', i_get_meta(meta, 'end_date'), ...
        'week_label', i_get_meta(meta, 'week_label')), ...
    'engineer', struct( ...
        'engineer_id', i_get_meta(meta, 'engineer_id'), ...
        'name', i_get_meta(meta, 'engineer_name'), ...
        'discipline', i_get_meta(meta, 'engineer_discipline')));

intake.raw_intake = struct('source_type','excel_form','submitted_at',string(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z''')));
intake.structured_input = struct();
intake.structured_input.activities = table2struct(acts);
intake.structured_input.documents_reviewed = table2struct(docs);
intake.structured_input.meetings = table2struct(meet);
intake.structured_input.risks_issues_actions = struct('risks',table2struct(risks),'issues',table2struct(issues),'actions',table2struct(actions));
intake.structured_input.next_steps = string(nextSteps.next_step);
end

function value = i_get_meta(metaTable, keyName)
row = strcmpi(string(metaTable.key), string(keyName));
if ~any(row)
    error('load_intake_excel:MissingMetadata', 'Metadata key missing: %s', keyName);
end
value = string(metaTable.value(find(row,1,'first')));
end
