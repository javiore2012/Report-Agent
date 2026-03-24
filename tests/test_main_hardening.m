function tests = test_main_hardening
tests = functiontests(localfunctions);
end

function testSchemaValidatorDetectsMissingRequired(testCase)
addpath(genpath('src'));
schema = json_io('read', fullfile('schemas', 'intake.schema.json'));
issues = validate_schema_basics(struct(), schema);
verifyGreaterThan(testCase, numel(issues), 0);
verifyTrue(testCase, contains(string(issues{1}), 'missing required field'));
end

function testMainFailsOnSchemaInvalidInput(testCase)
addpath(genpath('src'));
badInput = struct('report_metadata', struct());
tmpDir = tempname;
mkdir(tmpDir);
badInputPath = fullfile(tmpDir, 'bad_intake.json');
json_io('write', badInputPath, badInput);

f = @() main(badInputPath, tmpDir);
verifyError(testCase, f, 'main:IntakeSchemaInvalid');
end
