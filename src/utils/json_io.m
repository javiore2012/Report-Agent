function out = json_io(mode, filePath, payload)
%JSON_IO Read/write JSON files.
if nargin < 2
    error('json_io:InvalidInput', 'mode and filePath are required');
end

switch lower(string(mode))
    case "read"
        raw = fileread(filePath);
        out = jsondecode(raw);
    case "write"
        if nargin < 3
            error('json_io:InvalidInput', 'payload required for write mode');
        end
        folder = fileparts(filePath);
        if ~isempty(folder) && ~isfolder(folder)
            mkdir(folder);
        end
        text = jsonencode(payload, PrettyPrint=true);
        fid = fopen(filePath, 'w');
        if fid < 0
            error('json_io:WriteError', 'Could not open file for writing: %s', filePath);
        end
        cleanupObj = onCleanup(@() fclose(fid));
        fprintf(fid, '%s\n', text);
        out = filePath;
    otherwise
        error('json_io:InvalidMode', 'Unsupported mode: %s', mode);
end
end
