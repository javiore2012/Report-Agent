function aiInput = build_ai_input_packet(workPacket)
%BUILD_AI_INPUT_PACKET Create AI input packet from validated work packet.
aiInput = struct();
aiInput.schema_version = '1.0.0';
aiInput.report_metadata = workPacket.report_metadata;
aiInput.structured_input = workPacket.structured_input;
aiInput.validation_status = workPacket.validation.status;
aiInput.constraints = struct( ...
    'no_invention', true, ...
    'human_review_required', true, ...
    'approval_out_of_scope', true);
end
