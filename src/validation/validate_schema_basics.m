function issues = validate_schema_basics(data, schema)
%VALIDATE_SCHEMA_BASICS Basic JSON-schema-like validation for required fields/types.
issues = {};
issues = i_validate_node(data, schema, '$', issues);
end

function issues = i_validate_node(data, schema, path, issues)
if isfield(schema, 'type')
    t = string(schema.type);
    if ~i_matches_type(data, t)
        issues{end+1} = sprintf('%s type mismatch; expected %s', path, t); %#ok<AGROW>
        return;
    end
end

if isfield(schema, 'required')
    required = schema.required;
    for i = 1:numel(required)
        key = char(required{i});
        if ~isstruct(data) || ~isfield(data, key)
            issues{end+1} = sprintf('%s missing required field: %s', path, key); %#ok<AGROW>
        end
    end
end

if isfield(schema, 'properties') && isstruct(data)
    names = fieldnames(schema.properties);
    for i = 1:numel(names)
        key = names{i};
        if isfield(data, key)
            child = schema.properties.(key);
            issues = i_validate_node(data.(key), child, sprintf('%s.%s', path, key), issues);
        end
    end
end

if isfield(schema, 'enum')
    options = string(schema.enum);
    if ~any(options == string(data))
        issues{end+1} = sprintf('%s value not in enum', path); %#ok<AGROW>
    end
end

if isfield(schema, 'const')
    if ~strcmp(string(data), string(schema.const))
        issues{end+1} = sprintf('%s does not match const value', path); %#ok<AGROW>
    end
end

if isfield(schema, 'minLength') && ischar(data)
    if strlength(string(data)) < double(schema.minLength)
        issues{end+1} = sprintf('%s minLength violated', path); %#ok<AGROW>
    end
end

if isfield(schema, 'items') && iscell(data)
    for i = 1:numel(data)
        issues = i_validate_node(data{i}, schema.items, sprintf('%s[%d]', path, i), issues);
    end
elseif isfield(schema, 'items') && isstruct(data) && numel(data) > 1
    for i = 1:numel(data)
        issues = i_validate_node(data(i), schema.items, sprintf('%s[%d]', path, i), issues);
    end
end
end

function ok = i_matches_type(data, expected)
switch expected
    case "object"
        ok = isstruct(data);
    case "array"
        ok = iscell(data) || (isstruct(data) && numel(data) >= 0) || isstring(data);
    case "string"
        ok = ischar(data) || isstring(data);
    case "boolean"
        ok = islogical(data);
    otherwise
        ok = true;
end
end
