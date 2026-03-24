function outputPath = render_weekly_report(workPacket, aiDraft, outputDir)
%RENDER_WEEKLY_REPORT Render weekly report draft artifact.
artifact = struct('report_metadata',workPacket.report_metadata,'ai_draft',aiDraft,'workflow',workPacket.workflow);
outputPath = fullfile(outputDir, 'weekly_report_draft.json');
json_io('write', outputPath, artifact);
end
