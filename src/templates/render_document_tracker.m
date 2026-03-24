function outputPath = render_document_tracker(workPacket, outputDir)
%RENDER_DOCUMENT_TRACKER Render document tracker artifact.
if isfield(workPacket.structured_input, 'documents_reviewed')
    docs = workPacket.structured_input.documents_reviewed;
else
    docs = struct([]);
end
artifact = struct('documents_reviewed', docs);
outputPath = fullfile(outputDir, 'document_tracker_draft.json');
json_io('write', outputPath, artifact);
end
