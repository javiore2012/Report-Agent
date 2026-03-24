function tests = test_mock_ai_response
tests = functiontests(localfunctions);
end

function testMockAiResponseShape(testCase)
addpath(genpath('src'));
intake = load_intake_excel(fullfile('examples', 'weekly_intake_example.json'));
packet = build_work_packet(intake);
packet.validation = run_validations(packet, rules_registry(fullfile('config','validation_rules.json')));
aiInput = build_ai_input_packet(packet);
draft = mock_ai_response(aiInput);
parsed = parse_ai_structured_output(draft);
verifyTrue(testCase, isfield(parsed, 'report_text'));
verifyTrue(testCase, parsed.quality_flags.requires_human_review);
verifyGreaterThan(testCase, numel(parsed.report_text.technical_progress), 0);
end
