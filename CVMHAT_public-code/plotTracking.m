%% This script is to visualize the tracking results
%% Smooth them if necessary and plot the tail
%% Afshin Dehghan
%% 10/08/2014

function plotTracking(cv_trackResults, cv_imPath, cv_images, saveFlag, cv_outDir)

saveepsFlag = 1;

for view_i = 1 :2
trackResults = cv_trackResults{view_i};
% outDir = cv_outDir{view_i};

tail_length = 50;
% if(~exist(outDir,'dir'))
%     mkdir(outDir);
% end
% save([outDir '/trackRes.mat'],'trackResults');
%% Smooth BBOX size
% IDs = unique(trackResults(:,2))';
% trk_tmp=zeros(size(trackResults,1),size(trackResults,2));
% for iID=IDs
%     ind = find(trackResults(:,2)==iID) ;
%     for i=1:50:length(ind)
%         bbox_width_avg = mean(trackResults(ind(i:min(i+49,length(ind))),5)-trackResults(ind(i:min(i+49,length(ind))),3));
%         bbox_height_avg = mean(trackResults(ind(i:min(i+49,length(ind))),6)-trackResults(ind(i:min(i+49,length(ind))),4));
%         center_x = (trackResults(ind(i:min(i+49,length(ind))),5)+trackResults(ind(i:min(i+49,length(ind))),3))/2;
%         center_y = (trackResults(ind(i:min(i+49,length(ind))),6)+trackResults(ind(i:min(i+49,length(ind))),4))/2;
%         trk_tmp(ind(i:min(i+49,length(ind))),1:2)=trackResults(ind(i:min(i+49,length(ind))),1:2);
%         trk_tmp(ind(i:min(i+49,length(ind))),3)  =center_x-bbox_width_avg/2;
%         trk_tmp(ind(i:min(i+49,length(ind))),5)  =center_x+bbox_width_avg/2;
%         trk_tmp(ind(i:min(i+49,length(ind))),4)  =center_y-bbox_height_avg/2;
%         trk_tmp(ind(i:min(i+49,length(ind))),6)  =center_y+bbox_height_avg/2;
%     end
% end
% trackResults = trk_tmp;
cv_trackResults{view_i} = trackResults;
end


%% Show the results
time1 = tic;
minFrame = min(trackResults(:,1));
maxFrame = max(trackResults(:,1));
numClicks = max(unique(trackResults(:,2)))+2;
cc = hsv(numClicks+2);

for iFrame = [1,212,292,312] % [minFrame:1:maxFrame]
    for view_i = 1 : 2
        
    outDir = cv_outDir{view_i};
    if(~exist(outDir,'dir'))
        mkdir(outDir);
    end
    imPath  = cv_imPath{view_i};
    images = cv_images{view_i};
    trackResults = cv_trackResults{view_i};
    if view_i == 1
        figure(1);
%         set (gcf,'Position',[50,300,600,400])
    else
        figure(2);
%         set (gcf,'Position',[700,300,600,400])
    end
    im = imread(fullfile(imPath,images(iFrame).name));
%     [img_height,img_width] = size(im);
    img_width=size(im,2); %获取图像�?
    img_height=size(im,1); %获取图像�?
    %im = imresize(im,0.5);
    ind = find(trackResults(:,1)==iFrame);
    
    for iTrk=1:length(ind)
        ID = trackResults(ind(iTrk),2);
        boxTMP = trackResults(ind(iTrk),3:end);%/2;
        % Show ID of each person
        heightBox = boxTMP(4)-boxTMP(2)+1;
        widthBox  = boxTMP(3)-boxTMP(1)+1;
%         im(max(1,round(boxTMP(2)-0.2*heightBox)):round(boxTMP(2)),max(1,round(boxTMP(1))):round(boxTMP(3)),1)=uint8(255*cc(ID,1));
%         im(max(1,round(boxTMP(2)-0.2*heightBox)):round(boxTMP(2)),max(1,round(boxTMP(1))):round(boxTMP(3)),2)=uint8(255*cc(ID,2));
%         im(max(1,round(boxTMP(2)-0.2*heightBox)):round(boxTMP(2)),max(1,round(boxTMP(1))):round(boxTMP(3)),3)=uint8(255*cc(ID,3));
    end
    
    imshow(im);
    hold on;
%   text(round(size(im,2))-150,60,sprintf('#%03d',iFrame),'FontSize',30,'FontWeight','bold','BackgroundColor','yellow');
    text(round(size(im,2))-250,round(size(im,1))-120,sprintf('#%03d',iFrame),'FontSize',30,'FontWeight','bold','BackgroundColor','yellow');
    
    for iTrk=1:length(ind)
        ID = trackResults(ind(iTrk),2);
        boxTMP = trackResults(ind(iTrk),3:end);%/2;
        line([boxTMP(1) boxTMP(3) boxTMP(3) boxTMP(1) boxTMP(1)],[boxTMP(2) boxTMP(2) boxTMP(4) boxTMP(4) boxTMP(2)],'color',cc(ID,:),'LineWidth',1.5);
        text(round((boxTMP(1)+boxTMP(3))/2)-20,round((boxTMP(2)))-17,num2str(ID),'FontName','Times New Roman','FontSize',24,'FontWeight','bold');
        % Tail
%         if ID == 2
%             indID = find(trackResults(:,2)==ID);
%             centerX=0.5*(trackResults(indID,3)+trackResults(indID,5));
%             ext_X = centerX(iFrame);
%             ext_Y = trackResults(indID,4);
%             ext_Y = ext_Y(iFrame);
%             X = [(ext_X + 30) / img_width, (ext_X + 30) / img_width];
%             Y = [(img_height - ext_Y + 130) / img_height, (img_height - ext_Y + 60) / img_height];
%             annotation('textarrow',X,Y,'String','key target','color','r','LineWidth',2);
%         end
        
        if view_i == 1
        indID = find(trackResults(:,2)==ID);
        framesID = trackResults(indID,1);
        centerX=0.5*(trackResults(indID,3)+trackResults(indID,5));
        centerY=0.5*(trackResults(indID,4)+trackResults(indID,6));
        centerY=(trackResults(indID,6));%+trackResults(indID,6));
        
        if ((iFrame-framesID(1))>2) && ((iFrame-framesID(1))<=length(centerY))
            if(length(1:(iFrame-framesID(1)))<(tail_length+1))
                %centerX = 0.5*centerX(1:(iFrame-framesID(1)));
                %centerY = 0.5*centerY(1:(iFrame-framesID(1)));
                
                centerX = 1*centerX(1:(iFrame-framesID(1)));
                centerY = 1*centerY(1:(iFrame-framesID(1)));
            else
                %centerX = 0.5*centerX(((iFrame-framesID(1))-tail_length):(iFrame-framesID(1)));
                %centerY = 0.5*centerY(((iFrame-framesID(1))-tail_length):(iFrame-framesID(1)));
                try
                centerX = 1*centerX(((iFrame-framesID(1))-tail_length):(iFrame-framesID(1)));
                centerY = 1*centerY(((iFrame-framesID(1))-tail_length):(iFrame-framesID(1)));
                catch err
                end
            end
            plot(centerX,centerY,'-mo','color',cc(ID,:),'LineWidth',1.5,'MarkerSize',1.5,'MarkerFaceColor',cc(ID,:));
        end
        end
        
    end
    
    hold off;
%     pause(0.005);
    if(saveFlag)
        print(gcf,'-djpeg','-r100',[outDir sprintf('%04d.jpg',iFrame)]);
    end
    
    if(saveepsFlag)
        print(gcf,'-depsc','-r600',[outDir sprintf('%04d.eps',iFrame)]);
        % saveas(gcf, [outDir sprintf('%04d.eps',iFrame)],'psc2'); 
    end
    
    end
    
%     if mod(iFrame,30) == 0
%         pause;
%     end

end










