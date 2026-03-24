function intake = load_intake_excel(inputPath)
%LOAD_INTAKE_EXCEL Load standardized intake from JSON or expected Excel sheets.
if nargin < 1 || strlength(string(inputPath)) == 0
    error('load_intake_excel:MissingInputPath', 'inputPath is required');
end

if ~isfile(inputPath)
    candidate = fullfile(project_root(), inputPath);
    if isfile(candidate)
        inputPath = candidate;
    else
        error('load_intake_excel:MissingFile', 'Input file not found: %s', inputPath);
    end
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

intake = i_enforce_minimum_contract(intake);
end

function intake = i_load_from_xlsx(inputPath)
requiredSheets = {'Metadata','Activities','DocumentsReviewed','Meetings','Risks','Issues','Actions','NextSteps'};
available = sheetnames(inputPath);
missing = requiredSheets(~ismember(requiredSheets, available));
if ~isempty(missing)
    error('load_intake_excel:MissingSheet', 'Missing required sheets: %s', strjoin(missing, ', '));
end

meta = readtable(inputPath, Sheet='Metadata', TextType='string');
acts = readtable(inputPath, Sheet='Activities', TextType='string');
docs = readtable(inputPath, Sheet='DocumentsReviewed', TextType='string');
meet = readtable(inputPath, Sheet='Meetings', TextType='string');
risks = readtable(inputPath, Sheet='Risks', TextType='string');
issues = readtable(inputPath, Sheet='Issues', TextType='string');
actions = readtable(inputPath, Sheet='Actions', TextType='string');
nextSteps = readtable(inputPath, Sheet='NextSteps', TextType='string');

if ~all(ismember({'key','value'}, lower(string(meta.Properties.VariableNames))))
    error('load_intake_excel:InvalidMetadataSheet', 'Metadata sheet requires key/value columns');
end

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

intake.raw_intake = struct('source_type','excel_form', ...
    'submitted_at',string(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z''')));
intake.structured_input = struct();
intake.structured_input.activities = table2struct(acts);
intake.structured_input.documents_reviewed = table2struct(docs);
intake.structured_input.meetings = table2struct(meet);
intake.structured_input.risks_issues_actions = struct('risks',table2struct(risks),'issues',table2struct(issues),'actions',table2struct(actions));
if ismember('next_step', string(nextSteps.Properties.VariableNames))
    intake.structured_input.next_steps = cellstr(nextSteps.next_step);
else
    intake.structured_input.next_steps = cellstr(table2array(nextSteps(:,1)));
end
end

function value = i_get_meta(metaTable, keyName)
keys = string(metaTable{:,1});
values = string(metaTable{:,2});
row = strcmpi(keys, string(keyName));
if ~any(row)
    error('load_intake_excel:MissingMetadata', 'Metadata key missing: %s', keyName);
end
value = string(values(find(row,1,'first')));
end

function intake = i_enforce_minimum_contract(intake)
required = {'report_metadata', 'structured_input'};
for i = 1:numel(required)
    if ~isfield(intake, required{i})
        error('load_intake_excel:MissingField', 'Missing required field: %s', required{i});
    end
end

if ~isfield(intake.structured_input, 'activities')
    intake.structured_input.activities = struct([]);
end
if ~isfield(intake.structured_input, 'documents_reviewed')
    intake.structured_input.documents_reviewed = struct([]);
end
if ~isfield(intake.structured_input, 'meetings')
    intake.structured_input.meetings = struct([]);
end
if ~isfield(intake.structured_input, 'risks_issues_actions')
    intake.structured_input.risks_issues_actions = struct('risks',struct([]),'issues',struct([]),'actions',struct([]));
end
if ~isfield(intake.structured_input, 'next_steps')
    intake.structured_input.next_steps = {};
end
end
