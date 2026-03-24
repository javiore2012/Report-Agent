function root = project_root()
%PROJECT_ROOT Resolve repository root from source tree location.
thisFile = mfilename('fullpath');
utilsDir = fileparts(thisFile);
srcDir = fileparts(utilsDir);
root = fileparts(srcDir);
end
