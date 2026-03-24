function result = main(inputPath, outputDir)
%MAIN Run Sprint 1 end-to-end pipeline.
if nargin < 1 || strlength(string(inputPath)) == 0
    inputPath = fullfile('examples', 'weekly_intake_example.json');
end
if nargin < 2 || strlength(string(outputDir)) == 0
    outputDir = fullfile('runs', datestr(now, 'yyyymmdd_HHMMSS'));
end
if ~isfolder(outputDir)
    mkdir(outputDir);
end

intake = load_intake_excel(inputPath);
workPacket = build_work_packet(intake);
rules = rules_registry(fullfile('config', 'validation_rules.json'));
validation = run_validations(workPacket, rules);
workPacket.validation = validation;

workPacketPath = fullfile(outputDir, 'work_packet.json');
validationPath = fullfile(outputDir, 'validation_result.json');
json_io('write', workPacketPath, workPacket);
json_io('write', validationPath, validation);

if strcmp(validation.status, 'FAIL')
    error('main:ValidationFailed', 'Validation failed; rendering blocked by VR-040');
end

aiInput = build_ai_input_packet(workPacket);
aiDraftRaw = mock_ai_response(aiInput);
aiDraft = parse_ai_structured_output(aiDraftRaw);
aiDraftPath = fullfile(outputDir, 'ai_draft.json');
json_io('write', aiDraftPath, aiDraft);

weeklyPath = render_weekly_report(workPacket, aiDraft, outputDir);
activityPath = render_activity_log(workPacket, outputDir);
docPath = render_document_tracker(workPacket, outputDir);

trace = struct();
trace.input_path = inputPath;
trace.work_packet_path = workPacketPath;
trace.validation_path = validationPath;
trace.ai_draft_path = aiDraftPath;
trace.artifacts = struct('weekly_report',weeklyPath,'activity_log',activityPath,'document_tracker',docPath);
trace.model_mode = 'mock';
trace.validation_status = validation.status;
tracePath = write_trace_log(trace, outputDir);

result = struct();
result.output_dir = outputDir;
result.work_packet = workPacketPath;
result.validation = validationPath;
result.ai_draft = aiDraftPath;
result.artifacts = trace.artifacts;
result.trace_log = tracePath;
end
