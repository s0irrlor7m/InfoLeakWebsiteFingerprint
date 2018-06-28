function res = readParam(keyword, is_char)
% read parameters from the file


if nargin == 1
    is_char = 0;
end


param_file = 'Param.txt';



fd = fopen(param_file);

all_param = textscan(fd, '%s %s');


param_num = length(all_param{1});

flag_exist = 0;

for i = 1:param_num
    if strcmp(all_param{1}(i), keyword) == 1
        res = all_param{2}(i);
        flag_exist = 1;
        break;
    end

end

if flag_exist == 0
    ME = MException('InfoDefinedError:ParamNotFound', 'Parameter %s not found', keyword);
    throw(ME);
end


if is_char == 0
    res = str2num(res{1});
else
    res = res{1};
end


end