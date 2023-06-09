function prettifiedJSON = prettyJson(rawJSON)
% prettyJson
%   Read in raw JSON text that is generated by encodejson function and
%   usually in one line, then convert to pretty format with proper
%   indentations and line breaks
%
% Input:
%   rawJSON             input char array in JSON format
%
% Output:
%   prettifiedJSON      prettified char array in JSON format
%
% NOTE: This function is to optimize displaying effect of JSON string through
% recognizing general delimited characters, but may change the file content
% and cause problem in several uncommon cases. Please avoid the use of this
% function on Matlab structures that contain elements with any of the three
% character combinations: `":[` and `",` and `"],`.
%
% Usage: prettifiedJSON = prettyJson(rawJSON)
%


% handle input 
if isstring(rawJSON)
    % if input is supplied as string
    rawJSON = char(rawJSON);
elseif ~ischar(rawJSON)
    % if input is not supplied as char array
    error('The input data type is Not correct!');
end
jsonStr = rawJSON;


% process input string to pretty JSON format
jsonStr = regexprep(jsonStr,'^{','{\n\t','lineanchors');  % left  curly  bracket
jsonStr = regexprep(jsonStr,'}$','\n}\n','lineanchors');  % right curly  bracket
jsonStr = strrep(jsonStr,'":[','":[\n\t\t');              % left  square bracket
jsonStr = strrep(jsonStr,'",','",\n\t\t');                % internal elements in array
jsonStr = strrep(jsonStr,'],','],\n\t');                  % last element in array
jsonStr = compose(jsonStr);                               % translate escape-characters

prettifiedJSON = jsonStr{1};                              % convert from cell to char

end

