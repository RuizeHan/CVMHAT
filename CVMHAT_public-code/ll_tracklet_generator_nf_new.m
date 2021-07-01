%% Function to create tracklets using overlap threshold and extract appearance features

function segment = ll_tracklet_generator_nf_new(im_path,detections,param_tracklet, images, flag_visualization,color_weight)

addpath('./toolbox/');

cnt_segment = 1;
num_of_segments = round(length(images)/param_tracklet.num_frames);
cnt_segment_tmp = 1;
fprintf('generating tracklets : ');
for iImg = 1:param_tracklet.num_frames:length(images)
%     if iImg==261
%         disp(iImg)
%     end
    %% Read images
    cnt_tracklet = 1;
    im_preread = cell(1,param_tracklet.num_frames);
    cntDummy = 1; % Why the heck MATLAB doesn't have enumerate such as PYTHON 
    for jj = iImg:min(iImg+param_tracklet.num_frames-1,length(images))
        try
        im_preread{1,cntDummy} = imread(fullfile(im_path,images(jj).name));
        catch err
        end
        cntDummy = cntDummy+1;
    end
    %% Find Correspondence
    % fprintf(' %0.1f ',(cnt_segment/num_of_segments)*100);
   
    if min(iImg+param_tracklet.num_frames-1,length(images))-iImg <4;break;end
    
    [tracks,trackFrame] = run_GOG_new(detections,iImg,min(iImg+param_tracklet.num_frames-1,length(images)),param_tracklet,im_preread);
       
    %% Remove short tracklets 
    tracks_new = [];cntDummy=1;
    idx = 0;
    short_track_id = [];
    for i=1:size(tracks,2)
       if size(tracks{i},1)  >  param_tracklet.num_frames/2-2 % min tracklet length % 
          tracks_new{1,cntDummy}=tracks{i};
          cntDummy = cntDummy+1;
          
          if size(tracks{i},1) < param_tracklet.num_frames  % min tracklet length % 
              idx = idx + 1;
              short_track_id(idx) = i;
          end
       end
         
    end
    
    % merge the tracklet
%     if length(short_track_id) > 1
%         up = 1;
%         for k = 1 : length(short_track_id)
%             for kk = k + 1 : length(short_track_id)
%                 ki = short_track_id(k);
%                 kj = short_track_id(kk);
%                 track_i = tracks_new{ki};
%                 
%                 track_j = tracks_new{kj};
%                 track_frm_i = track_i(:,1);
%                 try
%                 track_frm_j = track_j(:,1);
%                 catch err
%                 end
%                 
%                 overlap = length(intersect(track_frm_i,track_frm_j));
%                 ratio1_x0 = mean(track_i(:,3))/mean(track_j(:,3));
%                 ratio1_y0 = mean(track_i(:,4))/mean(track_j(:,4));
%                 ratio1_w = (mean(track_i(:,5)-track_i(:,3)))/(mean(track_j(:,5)-track_j(:,3)));    
%                 ratio1_h = (mean(track_i(:,6)-track_i(:,4)))/(mean(track_j(:,6)-track_j(:,4)));
%                 
%                 if overlap < 1 && min(ratio1_x0, 1./ratio1_x0) > 0.9 && min(ratio1_y0, 1./ratio1_y0) > 0.9 ...
%                        && min(ratio1_w, 1./ratio1_w) > 0.5 && min(ratio1_h, 1./ratio1_h) > 0.9
%                    
%                    track_mg = track_merge(track_i,track_j);
%                    new_ki(up) = ki;
%                    new_kj(up) = kj;
%                    merg_track{up} = track_mg;
%                    up = up + 1;
%                    
%                 end
%                 
%             end
%         end
%         for kup = 1 : up -1 
%         tracks_new{new_ki(kup)} = merg_track{kup};
%         tracks_new{new_kj(kup)} = {};
%         end
%         tracks_new(cellfun(@isempty,tracks_new)) = [];
%         for n = 1 : length(tracks_new)
%             tracks_new{n}(:,2) = n;
%         end
%     end
    

    tracks = tracks_new;
      
    if(flag_visualization)
        im = imread(fullfile(im_path,images(iImg).name));
        imshow(im);hold on;
        c = hsv(size(tracks,2));
        for i=1:size(tracks,2)
            xc = round((tracks{1,i}(:,3)+tracks{1,i}(:,5))/2);
            yc = round((tracks{1,i}(:,4)+tracks{1,i}(:,6))/2);
            plot(xc,yc,'-o','color',c(i,:),'MarkerFaceColor',c(i,:),'LineWidth',3);
            % text(xc,yc,num2str(i),'color','g','fontsize',15);
        end
        pause(0.05);
    end
    
    %% Save the output
%     cnt_tracklet = 1;
%     im_preread = cell(1,param_tracklet.num_frames);
%     cntDummy = 1; % Why the heck MATLAB doesn't have enumerate such as PYTHON 
%     for jj = iImg:min(iImg+param_tracklet.num_frames-1,length(images))
%         im_preread{1,cntDummy} = imread(fullfile(im_path,images(jj).name));
%         cntDummy = cntDummy+1;
%     end

    [height,width,~]=size(im_preread{1,1});
    for ii=1:size(tracks,2)
        segment{cnt_segment_tmp}.tracklet(cnt_tracklet).frame = tracks{ii}(:,1);
        color_hist = zeros(32,32,32,size(tracks{ii},1));
        for iii = 1:size(tracks{ii},1)
            im = im_preread{1,tracks{ii}(iii,1)-iImg+1};
            x1 = round(tracks{ii}(iii,3));
            y1 = round(tracks{ii}(iii,4));
            x2 = round(tracks{ii}(iii,5));
            y2 = round(tracks{ii}(iii,6));
            x1 = max(x1,1);
            y1 = max(y1,1);
            x2 = min(x2, width);
            y2 = min(y2, height);
            segment{cnt_segment_tmp}.tracklet(cnt_tracklet).detection(iii,1:4) = [x1 y1 x2 y2];
            segment{cnt_segment_tmp}.tracklet(cnt_tracklet).origDetectionInd(iii,1) = tracks{ii}(iii,end);
            hist_tmp = invhist(im(y1:y2,x1:x2,:));
            color_hist(:,:,:,iii)= hist_tmp;
        end
        segment{cnt_segment_tmp}.tracklet(cnt_tracklet).color_hist_median = median(color_hist,4);
        clear color_hist hist_tmp;
        cnt_tracklet = cnt_tracklet+1;
    end
    cnt_segment = cnt_segment+1;
    cnt_segment_tmp = cnt_segment_tmp+1;
    
end
param_tracklet.numOfSegments = cnt_segment_tmp-1;
if(~exist(fullfile(param_tracklet.data_directory)))
    mkdir(fullfile(param_tracklet.data_directory));
end
save(fullfile(param_tracklet.data_directory,'Tracklets/tracklet_new',['tracklets_' param_tracklet.seqName '_nf.mat']),'segment','-v7.3');

