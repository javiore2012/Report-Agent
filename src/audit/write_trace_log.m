function tracePath = write_trace_log(traceData, outputDir)
%WRITE_TRACE_LOG Persist traceability log for Sprint 1 pipeline.
if ~isfolder(outputDir)
    mkdir(outputDir);
end
traceData.trace_version = '1.1.0';
traceData.logged_at = string(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z'''));
traceData.host_info = struct('matlab_version', version, 'computer', computer);
tracePath = fullfile(outputDir, 'trace_log.json');
json_io('write', tracePath, traceData);
end
