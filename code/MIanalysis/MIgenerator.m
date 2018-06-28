classdef MIgenerator < handle

    properties
        datasetPath
        info
        total_feature_num
        WebsiteNum
        
        samplePerc
        
    end
    
    
    methods
        % constructor:
        % dpath:    dataset path
        % perc:     percent of samples for MI calculation
        function obj = MIgenerator(dpath)
            obj.datasetPath = dpath;
            obj.samplePerc = readParam('SamplePercent');
            obj.getInfoModel();
           
        end
        
        
        function getInfoModel(obj)
            
            reader_monitor = TrainMatrixReader(obj.datasetPath, 1);
            obj.total_feature_num = size(reader_monitor.TrainMatrix, 2);
            
            vec = ones(1, obj.total_feature_num);    
            % construct Info structure
            Tmatrix{1} = reader_monitor.TrainMatrix;
            label{1} = reader_monitor.Label;
            DiscVec{1} = reader_monitor.isDiscVec;
            prior = PriorWebsites('Closed_World_Equal', reader_monitor.Rank);
            obj.info = EvaluatorMachine(Tmatrix, label, vec, prior, DiscVec);
            obj.WebsiteNum = length(obj.info.WebsiteList);
            
            % reduce number of samples to be faster
            obj.info.reModel(obj.samplePerc, 2);
        
        end
        
        % featureList: features to measure (allows non-order)
        % webList: websites the measure is upon (allows non-order)
        % return a non-compact MI matrix (for easy indexing)
        function mi = run(obj, measureMatrix, webList)
            
            if size(measureMatrix,1) == 0
                % to measure ALL features
                measureMatrix = ones(obj.total_feature_num, obj.total_feature_num);
            end

            % measure MI            
            mi = obj.info.MI(1, webList, measureMatrix);

        end
        
    end



end
