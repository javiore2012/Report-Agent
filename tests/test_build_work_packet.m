function tests = test_build_work_packet
tests = functiontests(localfunctions);
end

function testBuildWorkPacketStructure(testCase)
addpath(genpath('src'));
intake = load_intake_excel(fullfile('examples', 'weekly_intake_example.json'));
packet = build_work_packet(intake);
verifyEqual(testCase, packet.schema_version, '1.0.0');
verifyEqual(testCase, packet.workflow.approval_status, 'not_approved');
verifyEqual(testCase, packet.validation.status, 'PENDING');
end
