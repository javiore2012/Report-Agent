function rules = rules_registry(configPath)
%RULES_REGISTRY Load validation rule registry from config JSON.
if nargin < 1 || strlength(string(configPath)) == 0
    configPath = fullfile(project_root(), 'config', 'validation_rules.json');
elseif ~isfile(configPath)
    configPath = fullfile(project_root(), configPath);
end

if ~isfile(configPath)
    error('rules_registry:MissingConfig', 'Validation config not found: %s', configPath);
end
rules = json_io('read', configPath);
end
