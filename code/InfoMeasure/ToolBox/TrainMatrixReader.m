classdef TrainMatrixReader < handle
    properties
        TrainMatrix
        Label
        Rank
        isDiscVec
        DATA_PATH
        DiscreteThres
    end

    methods
        
        
        
        
        %%% assign isDiscVec 
        
        function DiscreteRecog(obj)

            dim = length(obj.Label);
            obj.isDiscVec = NaN(dim, 1);
            
            % for each website
            for l = min(obj.Label):max(obj.Label)
                l
                web_data = obj.TrainMatrix(obj.Label==l, :);
                dv = DiscreteRule(web_data, obj.DiscreteThres, obj.DATA_PATH);
                obj.isDiscVec(obj.Label==l) = dv;
            end
        end
        
        
        
        
        
        % st, ed denote the start and end for rank
        function obj = TrainMatrixReader(data_dir, DiscThres)
            obj.DATA_PATH = data_dir;
            obj.DiscreteThres = DiscThres;
            obj.TrainMatrix = [];
            obj.Label = [];
            obj.Rank = [];
            % if .mat exists
            pathmat1 = strcat(data_dir, 'TrainMatrix.mat');
            pathmat2 = strcat(data_dir, 'Label.mat');
            pathmat3 = strcat(data_dir, 'Rank.mat');
            pathmat4 = strcat(data_dir, 'isDiscVec.mat');
            if exist(pathmat1, 'file') == 2 && exist(pathmat2, 'file') == 2 && exist(pathmat3, 'file') == 2 && exist(pathmat4, 'file') == 2
                obj.TrainMatrix = importdata(pathmat1);
                obj.Label = importdata(pathmat2);
                obj.Rank = importdata(pathmat3);
                obj.isDiscVec = importdata(pathmat4);
            else
            
                % not all .mat exists
                % clear any .mat pre-existed
                
                if (exist(pathmat1, 'file')==2) delete(pathmat1);end; 
                if (exist(pathmat2, 'file')==2) delete(pathmat2);end; 
                if (exist(pathmat3, 'file')==2) delete(pathmat3);end; 
                if (exist(pathmat4, 'file')==2) delete(pathmat4);end; 
                
                
                % continue to import original dataset
                
                
                lab_count = 1;
                
                % list dir 
                filelist = dir(data_dir);
                
                % skip the first 2 ('.' and '..')
                for i = 3:length(filelist)
                    
                    %%% filter non .csv files
                    fn = strsplit(filelist(i).name, '.');
                    if ~strcmp(fn{2}, 'csv') 
                        continue;
                    end
                    
                    % 
                    i
                    pathcsv = strcat(data_dir, filelist(i).name);
                    if exist(pathcsv, 'file') == 2
                        matrix = load(pathcsv);
                        r = size(matrix,1);
                        obj.TrainMatrix = [obj.TrainMatrix; matrix]; 
                        obj.Label = [obj.Label; zeros(r,1)+lab_count]; 
                        %for each_row = 1:r
                        %    obj.TrainMatrix = [obj.TrainMatrix;matrix(each_row,:)];
                        %    obj.Label = [obj.Label; lab_count];
                        %end
                        lab_count = lab_count + 1;
                        % extract rank
                        sp = strsplit(filelist(i).name, '_');
                        
                        obj.Rank = [obj.Rank; str2num(sp{1})];
                        
                    else
                        %disp(['no training data for', num2str(i)]);
        
                    end
                end
                
                % generate obj.isDiscVec
                obj.DiscreteRecog();
                
                % save TrainMatrix, Label
                tempa = obj.TrainMatrix;
                tempb = obj.Label;
                tempc = obj.Rank;
                tempd = obj.isDiscVec;
                save(pathmat1, 'tempa', '-v7.3');
                save(pathmat2, 'tempb', '-v7.3');
                save(pathmat3, 'tempc', '-v7.3');
                save(pathmat4, 'tempd', '-v7.3');
            end

        end
    end
end
