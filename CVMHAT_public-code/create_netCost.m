%% Compute the netCost Matrix
function net_cost = create_netCost(segment,param_netCost,view_i,scene_name)

addpath('./MOT_toolbox/');
addpath('./toolbox/');
net_cost.motion = [];
net_cost.appearance = [];
net_cost.ind = [];
offset = 1;
cnt_global = 1;
svcost_path = './Data/sv_cost/';
view_names = {'top','hor'};
svcost_path = strcat(svcost_path, view_names{view_i}, '/', scene_name, '/');

for i=1:length(segment)
disp(['sv_cost:segment-',num2str(i)]);   
    
    if isempty(segment{i})
        continue;
    end
    hist1 = zeros(32*32*32,length(segment{i}.tracklet));
    curr_size = length(segment{i}.tracklet);
    for iTrack=1:length(segment{i}.tracklet)
        hist1(:,iTrack) = segment{i}.tracklet(iTrack).color_hist_median(:);
        tracklet_segment1(iTrack).frame = segment{i}.tracklet(iTrack).frame';
        tracklet_segment1(iTrack).length = length(segment{i}.tracklet(iTrack).frame);
        % ----center point coordinate ------
        tracklet_segment1(iTrack).data = [(segment{i}.tracklet(iTrack).detection(:,1)+segment{i}.tracklet(iTrack).detection(:,3))/2 ...
            (segment{i}.tracklet(iTrack).detection(:,2)+segment{i}.tracklet(iTrack).detection(:,4))/2]';
        net_cost.infoBox{cnt_global} = [segment{i}.tracklet(iTrack).frame'; ...
            segment{i}.tracklet(iTrack).origDetectionInd'; segment{i}.tracklet(iTrack).detection'];
        net_cost.infoColor{cnt_global} = [segment{i}.tracklet(iTrack).color_hist_median];
        cnt_global = cnt_global+1;
    end
    
    cnt = 1;
    for ii=i:length(segment)
        if isempty(segment{ii})
            continue;
        end
        for iTrack=1:length(segment{ii}.tracklet)
            hist2(:,cnt) = segment{ii}.tracklet(iTrack).color_hist_median(:);
            tracklet_segment2(cnt).frame = segment{ii}.tracklet(iTrack).frame';
            tracklet_segment2(cnt).length = length(segment{ii}.tracklet(iTrack).frame);
            tracklet_segment2(cnt).data = [(segment{ii}.tracklet(iTrack).detection(:,1)+segment{ii}.tracklet(iTrack).detection(:,3))/2 ...
                (segment{ii}.tracklet(iTrack).detection(:,2)+segment{ii}.tracklet(iTrack).detection(:,4))/2]';
            cnt = cnt+1;
        end
    end
    
    if i==1
        net_cost.appearance=zeros(size(tracklet_segment2,2));
        net_cost.motion = zeros(size(tracklet_segment2,2));
    end
    
    %% Compute Motion Sim
    N = length(tracklet_segment2); % tracklet_segment2 : All the tracklets of the video
    M = length(tracklet_segment1); % tracklet_segment1 : The tracklets of the i-th segment
    S = zeros(M,N);
    for iii=1:M
        for jjj=1:N
            S(iii,jjj) = compute_motion_cost_constVel(tracklet_segment1(iii),tracklet_segment2(jjj),param_netCost);
        end
    end    
    S(1:curr_size,1:curr_size)=NaN;
    
    %% Compute Appearance Sim
%     if i ~= length(segment) && view_i == 2
%         load(fullfile(svcost_path,['seg_' int2str(i+1) '.mat']));
%         [first_size,last_size] = size(app_objs);
%         hi_dist = slmetric_pw(hist1,hist2,'intersect');
%         hi_dist(1:curr_size,1:curr_size)=NaN;
%     %     net_cost.appearance(offset:offset+curr_size-1,offset:end) = 2*hi_dist;
%         net_cost.appearance(offset:offset+curr_size-1,offset:offset+curr_size-1) = NaN;
%         net_cost.appearance(offset:offset+curr_size-1,offset+curr_size:offset+curr_size+last_size-1) = 1 - app_objs;
%     end 
%     if view_i == 1
    hi_dist = slmetric_pw(hist1,hist2,'intersect');
    hi_dist(1:curr_size,1:curr_size)=NaN;
    net_cost.appearance(offset:offset+curr_size-1,offset:end) = 2*hi_dist;
%     end 
    net_cost.motion(offset:offset+curr_size-1,offset:end) =  2*S;
    net_cost.ind = [net_cost.ind ; curr_size];
    offset = offset+curr_size;
    clear hi_dist hist2 hist1 S tracklet_segment1 tracklet_segment2;
    
end
