function [NN,NN_original, nodes] = GMMCP_Tracklet_Generation(sv_net_cost,cv_net_cost,firstSeg, lastSeg, params,param_tracklet)

%  calculate the Cost Mat of a single view between two segment
sv_Net_Cost_Mat = cell(2,1);
appearanceWeight = params.sv_appearanceWeight;
motionWeight = 1 - appearanceWeight;
dummyWeight = params.dummyWeight;
forceExtraCliques = 1;

save_weight = 0;
use_cluster= 0;

NC = 4;
cv_NN = zeros(2,lastSeg-firstSeg+1);

for view_i = 1 : 2

    net_cost = sv_net_cost{view_i};

    net_cost.motion = (net_cost.motion + net_cost.motion')/2;
    net_cost.appearance = (net_cost.appearance + net_cost.appearance')/2;
    Net_Cost_Mat = appearanceWeight*net_cost.appearance + motionWeight*net_cost.motion;

    NN = net_cost.ind;  %The number of tracklets in each segment
    
    % sometimes there is no tracklet at the end of the video and sizes don't
    % match up so we need to do a check here
    if lastSeg>size(NN,1)
        lastSeg=size(NN,1);
    end

    Net_Cost_Mat = Net_Cost_Mat(sum(NN(1:(firstSeg-1)))+1:sum(NN(1:lastSeg)),sum(NN(1:(firstSeg-1)))+1:sum(NN(1:lastSeg)));
    motionCost = net_cost.motion(sum(NN(1:(firstSeg-1)))+1:sum(NN(1:lastSeg)),sum(NN(1:(firstSeg-1)))+1:sum(NN(1:lastSeg)));
    appCost = net_cost.appearance(sum(NN(1:(firstSeg-1)))+1:sum(NN(1:lastSeg)),sum(NN(1:(firstSeg-1)))+1:sum(NN(1:lastSeg)));
    
    NN = NN(firstSeg:lastSeg);
    cv_NN(view_i,:) = NN;

    Net_Cost_Mat_Original = Net_Cost_Mat;
    % Net_Cost_Mat =  Net_Cost_Mat - motionWeight * motionCost;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            - motionWeight * motionCost;  % motionWeightTimeAdapt
    if params.sv_netCost_norm 
        Net_Cost_Mat = normalizing(Net_Cost_Mat,0,1);
    end
    
%     dummy_counts = ones(size(NN));
%     [Net_Cost_Mat, NN, detectionInds, dummyInds] = addDummyNodes_v03(Net_Cost_Mat, NN, dummy_counts, dummyWeight);     
%     sv_Net_Cost_Mat{view_i} = motionWeightTimeAdapt(Net_Cost_Mat, motionCost, detectionInds, dummyInds, dummyWeight, motionWeight,mergingFlag);    
    sv_Net_Cost_Mat{view_i} = Net_Cost_Mat;
end

NN_ori = [cv_NN(1),cv_NN(3),cv_NN(4),cv_NN(2)];

tv_Net_Cost_Mat = sv_Net_Cost_Mat{1};
hv_Net_Cost_Mat = sv_Net_Cost_Mat{2};

% calculate the Cost Mat in the same segment between two views
cv_Net_Cost_Mat = cell(2,1);

for time_i = firstSeg : lastSeg
    
    Net_Cost = cv_net_cost{time_i};
    if params.cv_netCost_norm 
        Net_Cost = normalizing(Net_Cost,0,1);
    end
%     NN = size(Net_Cost)';  %The number of tracklets in each view
%     dummy_counts = ones(size(NN));
%     nanMat1 = zeros(size(Net_Cost,1))*nan;
%     nanMat2 = zeros(size(Net_Cost,2))*nan;
%     Net_Cost_Mat = [nanMat1,Net_Cost;Net_Cost',nanMat2];
%     [cv_Net_Cost_Mat{time_i}, NN, detectionInds, dummyInds] = addDummyNodes_v03(Net_Cost_Mat, NN, dummy_counts, dummyWeight);
    cv_Net_Cost_Mat{time_i - firstSeg + 1} = Net_Cost;
    
end

cv0_Net_Cost_Mat = cv_Net_Cost_Mat{1};
cv1_Net_Cost_Mat = cv_Net_Cost_Mat{2};

NN = zeros(4,1);
NN(1:2) = cv_NN(1,:);  %top 1 and 2
NN(3) = cv_NN(2,2);    %hor 2
NN(4) = cv_NN(2,1);    %hor 1
NN_original = NN;
dummy_counts = ones(size(NN));
Kcliques = max(NN(:)) + forceExtraCliques;
Net_Cost_Mat = zeros(sum(NN),sum(NN))*nan;
Net_Cost_Mat(1:NN(1)+ NN(2),1:NN(1)+NN(2)) = tv_Net_Cost_Mat;

hv_Net_Cost_Mat_trans = zeros(NN(4)+NN(3))*nan;
hv_Net_Cost_Mat_trans(1:NN(3),NN(3)+1:end) = hv_Net_Cost_Mat(NN(4)+1:end,1:NN(4));
hv_Net_Cost_Mat_trans(NN(3)+1:end,1:NN(3)) = hv_Net_Cost_Mat(1:NN(4),NN(4)+1:end);
Net_Cost_Mat(NN(1)+ NN(2)+1:end,NN(1)+ NN(2)+1:end) = hv_Net_Cost_Mat_trans;  %Block replacement

nanMat1 = zeros(NN(1),NN(3))*nan;
nanMat2 = zeros(NN(2),NN(4))*nan;
try
cv_Net_Cost_Mat1 = [nanMat1,cv0_Net_Cost_Mat;cv1_Net_Cost_Mat,nanMat2];
catch err
end
cv_Net_Cost_Mat2 = [nanMat1',cv1_Net_Cost_Mat';cv0_Net_Cost_Mat',nanMat2'];

Net_Cost_Mat(1:NN(1)+ NN(2),NN(1)+ NN(2)+1:end) = cv_Net_Cost_Mat1;
Net_Cost_Mat(NN(1)+ NN(2)+1:end,1:NN(1)+NN(2)) = cv_Net_Cost_Mat2;

[Dm_Net_Cost_Mat, NN, detectionInds, dummyInds] = addDummyNodes_v03(Net_Cost_Mat, NN, dummy_counts, dummyWeight);



if save_weight ==1
    savepath = ['./Data/Weight_mat2/', param_tracklet.sceneName, '/'];
    if(~exist(savepath,'dir'))
        mkdir(savepath);
    end
    save([savepath,'seg_',num2str(firstSeg),'.mat'],'Net_Cost_Mat','NN_ori');
  
end

if use_cluster ==1
    clusterpath = ['./Data/clusting_result/', param_tracklet.sceneName, '/'];
    clu = load([clusterpath,'clusting_seg',num2str(firstSeg),'.mat']);
    clu_res = clu.clusting_result;
    clu_res = sortrows(clu_res,1);
    clu_res(clu_res(:) == 0) = -10;
    clu_res(:,2) = clu_res(:,2) + 1;
    clu_res(:,3) = clu_res(:,3) + 2;
    clu_res(:,4) = clu_res(:,4) + 3;
    clu_res(clu_res(:,1)<0,1) = NN(1);
    clu_res(clu_res(:,2)<0,2) = NN(1)+NN(2);
    clu_res(clu_res(:,3)<0,3) = NN(1)+NN(2)+NN(3);
    clu_res(clu_res(:,4)<0,4) = NN(1)+NN(2)+NN(3)+NN(4);
end


isFindMax = 1;
method = 2;
showDebugInfo = 0;

if use_cluster ==1
    nodes = clu_res;
else
    [nodes, cost, timeSpent] = GMMCP_Solver_ADN(Dm_Net_Cost_Mat, NN, NC, isFindMax, method, 100000, 10000000,showDebugInfo, Kcliques,dummyWeight);

end
% % save(fullfile(savePath,sprintf('segment_%03d_to_%03d.mat',firstSeg, lastSeg)),'Net_Cost_Mat','Net_Cost_Mat_Original','NN_original','dummy_counts','dummyWeight','NN','NC','nodes','cost','Kcliques','timeSpent');
% fprintf('cost: %d, time: %d\n', cost, timeSpent);
end