% three steps to reduce the features' dimensions

classdef MIanalysis < handle
    properties
        
        % dataset & individual info
        ent
        dataset_path
        
        
        % catFeatureList (ordered by entropy)
        catFeatureList
        
        
        
        
        % topn's things (topn features to measure)
        % ordered by info
        topn
        topnFeatureList
        
        
        % DBSCAN & vec
        vec
        cluster_idx
        
        
        % utilities: highMIpruner
        MIprun
        
        
    end

    
    methods

        %%%%%% external interface
        
        function obj = MIanalysis(dataset_path, ent)
            obj.dataset_path = dataset_path;
            obj.ent = ent;
            MIgene = MIgenerator(obj.dataset_path);
            obj.MIprun = highMIpruner(MIgene);
        end
        
        
        %%%% set the featureList and topn
        %%% compute topn number of non-high-MI features in featureList 
        function setup(obj, catFlist, topn)
            ent_cat = obj.ent(catFlist);
            [arr, i] = sort(ent_cat, 'descend');
            obj.catFeatureList = catFlist(i);
            obj.topn = topn;
            
            obj.topnFeatureList = obj.MIprun.run(obj.catFeatureList, obj.topn);
        end
        
        
        
        function vec = groupByMI(obj)
            % construct a compact MI for DBSCAN, indexed by topnFeatureList
            
            for i = 1:length(obj.topnFeatureList)
                for j = 1:length(obj.topnFeatureList)
                    fidx1 = obj.topnFeatureList(i);
                    fidx2 = obj.topnFeatureList(j);
                    topnMI(i,j) = obj.MIprun.mi(fidx1, fidx2);
                end
            end
            
            new = 1 - topnMI;
            obj.cluster_idx = DBSCAN(new, readParam('DBSCAN_THRES'), 1);
            
            obj.vec = zeros(1,length(obj.ent));
            obj.vec(obj.topnFeatureList) = obj.cluster_idx;
            vec = obj.vec;
        end
    end
end
