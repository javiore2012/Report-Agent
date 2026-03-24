function outputPath = render_activity_log(workPacket, outputDir)
%RENDER_ACTIVITY_LOG Render activity log artifact.
artifact = struct('activities', workPacket.structured_input.activities);
outputPath = fullfile(outputDir, 'activity_log_draft.json');
json_io('write', outputPath, artifact);
end
