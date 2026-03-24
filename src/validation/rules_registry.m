function rules = rules_registry(configPath)
%RULES_REGISTRY Load validation rule registry from config JSON.
if nargin < 1 || strlength(configPath) == 0
    configPath = fullfile('config', 'validation_rules.json');
end
rules = json_io('read', configPath);
end
