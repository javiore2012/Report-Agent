function tests = test_load_intake_excel
tests = functiontests(localfunctions);
end

function testLoadJsonIntake(testCase)
addpath(genpath('src'));
intake = load_intake_excel(fullfile('examples', 'weekly_intake_example.json'));
verifyTrue(testCase, isfield(intake, 'report_metadata'));
verifyTrue(testCase, isfield(intake.structured_input, 'activities'));
verifyGreaterThan(testCase, numel(intake.structured_input.activities), 0);
end
