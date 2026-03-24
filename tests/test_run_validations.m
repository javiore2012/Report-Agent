function tests = test_run_validations
tests = functiontests(localfunctions);
end

function testRunValidationsPassOrWarn(testCase)
addpath(genpath('src'));
intake = load_intake_excel(fullfile('examples', 'weekly_intake_example.json'));
packet = build_work_packet(intake);
rules = rules_registry(fullfile('config', 'validation_rules.json'));
validation = run_validations(packet, rules);
verifyTrue(testCase, any(strcmp(validation.status, {'PASS','PASS_WITH_WARNINGS'})));
verifyClass(testCase, validation.errors, 'cell');
verifyClass(testCase, validation.warnings, 'cell');
end
