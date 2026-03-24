function result = main(inputPath, outputDir)
%MAIN Run Sprint 1 end-to-end pipeline.
root = project_root();
if nargin < 1 || strlength(string(inputPath)) == 0
    inputPath = fullfile(root, 'examples', 'weekly_intake_example.json');
elseif ~isfile(inputPath)
    inputPath = fullfile(root, inputPath);
end
if nargin < 2 || strlength(string(outputDir)) == 0
    outputDir = fullfile(root, 'runs', datestr(now, 'yyyymmdd_HHMMSS'));
elseif ~startsWith(string(outputDir), string(root))
    outputDir = fullfile(root, outputDir);
end
if ~isfolder(outputDir)
    mkdir(outputDir);
end

intake = load_intake_excel(inputPath);
intakeSchema = json_io('read', fullfile(root, 'schemas', 'intake.schema.json'));
intakeSchemaIssues = validate_schema_basics(intake, intakeSchema);
if ~isempty(intakeSchemaIssues)
    error('main:IntakeSchemaInvalid', 'Intake schema issues: %s', strjoin(intakeSchemaIssues, '; '));
end

workPacket = build_work_packet(intake);
rules = rules_registry(fullfile(root, 'config', 'validation_rules.json'));
validation = run_validations(workPacket, rules);
workPacket.validation = validation;

workPacketSchema = json_io('read', fullfile(root, 'schemas', 'work_packet.schema.json'));
workPacketSchemaIssues = validate_schema_basics(workPacket, workPacketSchema);
if ~isempty(workPacketSchemaIssues)
    validation.status = 'FAIL';
    validation.errors = [validation.errors, strcat('SCHEMA: ', workPacketSchemaIssues)];
    validation.error_count = numel(validation.errors);
    workPacket.validation = validation;
end

workPacketPath = fullfile(outputDir, 'work_packet.json');
validationPath = fullfile(outputDir, 'validation_result.json');
json_io('write', workPacketPath, workPacket);
json_io('write', validationPath, validation);

if strcmp(validation.status, 'FAIL')
    trace = i_build_trace(root, inputPath, workPacketPath, validationPath, '', struct(), validation.status, intakeSchemaIssues, workPacketSchemaIssues, {});
    tracePath = write_trace_log(trace, outputDir);
    error('main:ValidationFailed', 'Validation failed; rendering blocked by VR-040. Trace: %s', tracePath);
end

aiInput = build_ai_input_packet(workPacket);
aiDraftRaw = mock_ai_response(aiInput);
aiDraft = parse_ai_structured_output(aiDraftRaw);
aiDraftSchema = json_io('read', fullfile(root, 'schemas', 'ai_draft.schema.json'));
aiDraftSchemaIssues = validate_schema_basics(aiDraft, aiDraftSchema);
if ~isempty(aiDraftSchemaIssues)
    error('main:AiSchemaInvalid', 'AI draft schema issues: %s', strjoin(aiDraftSchemaIssues, '; '));
end

aiDraftPath = fullfile(outputDir, 'ai_draft.json');
json_io('write', aiDraftPath, aiDraft);

weeklyPath = render_weekly_report(workPacket, aiDraft, outputDir);
activityPath = render_activity_log(workPacket, outputDir);
docPath = render_document_tracker(workPacket, outputDir);

trace = i_build_trace(root, inputPath, workPacketPath, validationPath, aiDraftPath, ...
    struct('weekly_report',weeklyPath,'activity_log',activityPath,'document_tracker',docPath), ...
    validation.status, intakeSchemaIssues, workPacketSchemaIssues, aiDraftSchemaIssues);
tracePath = write_trace_log(trace, outputDir);

result = struct();
result.output_dir = outputDir;
result.work_packet = workPacketPath;
result.validation = validationPath;
result.ai_draft = aiDraftPath;
result.artifacts = trace.artifacts;
result.trace_log = tracePath;
end

function trace = i_build_trace(root, inputPath, workPacketPath, validationPath, aiDraftPath, artifacts, validationStatus, intakeSchemaIssues, workPacketSchemaIssues, aiDraftSchemaIssues)
trace = struct();
trace.project_root = root;
trace.input_path = inputPath;
trace.work_packet_path = workPacketPath;
trace.validation_path = validationPath;
trace.ai_draft_path = aiDraftPath;
trace.artifacts = artifacts;
trace.model_mode = 'mock';
trace.validation_status = validationStatus;
trace.schema_checks = struct( ...
    'intake_issues', {intakeSchemaIssues}, ...
    'work_packet_issues', {workPacketSchemaIssues}, ...
    'ai_draft_issues', {aiDraftSchemaIssues});
trace.module_versions = struct('pipeline','sprint1-hardened','validation','sprint1-hardened','ai_prompt','sprint1-v1');
end
