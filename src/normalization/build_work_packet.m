function workPacket = build_work_packet(intake)
%BUILD_WORK_PACKET Normalize intake into canonical packet.
if ~isfield(intake, 'report_metadata') || ~isfield(intake, 'structured_input')
    error('build_work_packet:InvalidInput', 'Intake missing report_metadata or structured_input');
end

workPacket = struct();
workPacket.schema_version = '1.0.0';
workPacket.report_metadata = intake.report_metadata;
if isfield(intake, 'raw_intake')
    workPacket.raw_intake = intake.raw_intake;
else
    workPacket.raw_intake = struct('source_type','unknown');
end
workPacket.structured_input = intake.structured_input;
workPacket.validation = struct('status','PENDING','errors',{{}},'warnings',{{}});
workPacket.workflow = struct('draft_status','not_generated','review_status','pending_review','approval_status','not_approved');
end
