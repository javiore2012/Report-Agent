function tracePath = write_trace_log(traceData, outputDir)
%WRITE_TRACE_LOG Persist traceability log for Sprint 1 pipeline.
traceData.trace_version = '1.0.0';
traceData.logged_at = string(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z'''));
tracePath = fullfile(outputDir, 'trace_log.json');
json_io('write', tracePath, traceData);
end
