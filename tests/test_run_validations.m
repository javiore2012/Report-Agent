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

function testRunValidationsDuplicateActivityWarning(testCase)
addpath(genpath('src'));
intake = load_intake_excel(fullfile('examples', 'weekly_intake_example.json'));
baseActivity = intake.structured_input.activities(1);
intake.structured_input.activities(end+1) = baseActivity;
packet = build_work_packet(intake);
validation = run_validations(packet, rules_registry(fullfile('config', 'validation_rules.json')));
warningText = strjoin(string(validation.warnings), ' | ');
verifyTrue(testCase, contains(warningText, 'VR-013'));
verifyEqual(testCase, validation.error_count, numel(validation.errors));
verifyEqual(testCase, validation.warning_count, numel(validation.warnings));
end

function testRunValidationsMissingRequiredFieldFail(testCase)
addpath(genpath('src'));
intake = load_intake_excel(fullfile('examples', 'weekly_intake_example.json'));
intake.structured_input.activities(1) = rmfield(intake.structured_input.activities(1), 'title');
packet = build_work_packet(intake);
validation = run_validations(packet, rules_registry(fullfile('config', 'validation_rules.json')));
verifyEqual(testCase, validation.status, 'FAIL');
errorText = strjoin(string(validation.errors), ' | ');
verifyTrue(testCase, contains(errorText, 'VR-004'));
end
