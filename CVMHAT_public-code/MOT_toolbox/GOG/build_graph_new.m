function dres = build_graph_new(dres, ov_thresh, clr_thresh,cen_thresh,imgs)

for fr = min(dres.fr)+1:max(dres.fr)
    f1 = find(dres.fr == fr);     %% indices for detections on this frame
    f2 = find(dres.fr == fr-1);   %% indices for detections on the previous frame
    
%     id4f1 = zeros(length(f1),2);

    
    for i = 1:length(f1)
        ovs1  = calc_overlap(dres, f1(i), dres, f2);
        indsi = find(ovs1 > ov_thresh);  %% find overlapping bounding boxes.
        
        len = length(imgs);
        fr_img = mod(fr,10);
        
        if fr_img == 0
            fr_img = len;
        end

        clr = calc_colorhist(dres,f1(i),imgs{fr_img}, dres, f2, imgs{fr_img-1}); 
        indsc = find(clr > clr_thresh); % remove the association by color information
        
%         disthr = 30;
%         dis = calc_bbxcenter(dres,f1(i),dres, f2, disthr); %0.5
%         dis0 = dis;
%         dis(dis > disthr) = disthr;
%         cen = 1- dis/disthr;
%         % cen((cen < cen_thresh)) = 0
%         indsd = find(cen > cen_thresh);
%         inds1 = indsc;
        
        
        inds1 = intersect(indsc,indsi);
        
%         if length(inds1) ~= length(indsi)
%         
%         fr_img = mod(fr,10);
% 
%         if fr_img == 0
%             fr_img = length(imgs);
%         end
%         % ----- visualize the bounding box -------
%         image = imgs{fr_img -1};
%         figure(1)
%         imshow(image);
%         hold on;
%         for fi = 1 : length(f2)
%         ii = f2(fi);
%         rec1(1) = dres.x(ii);
%         rec1(2) = dres.y(ii);
%         rec1(3) = dres.w(ii);
%         rec1(4) = dres.h(ii);
%         rectangle('Position',rec1(1:4),'LineWidth',2,'LineStyle','-','EdgeColor','b');
%         text(rec1(1),rec1(2)+rec1(4),num2str(ii),'color','b','fontsize',25);
%         end
% 
%         for fi = 1 : length(f1)
%         jj = f1(fi);
%         rec1(1) = dres.x(jj);
%         rec1(2) = dres.y(jj);
%         rec1(3) = dres.w(jj);
%         rec1(4) = dres.h(jj);
%         rectangle('Position',rec1(1:4),'LineWidth',2,'LineStyle','-','EdgeColor','r');
%         text(rec1(1),rec1(2)+rec1(4),num2str(jj),'color','r','fontsize',25);
% %         text(rec1(1),rec1(2),num2str(id4f1(fi,1)),'color','r','fontsize',25);
% %         text(rec1(1)+rec1(3),rec1(2)+rec1(4),num2str(id4f1(fi,2)),'color','g','fontsize',25);
%         % figure(2)
%         % image2 = imgs{fr_img };
%         % figure(2)
%         % imshow(image2);
%         % hold on;
% 
%         end
%         end
%         if clr(inds1) < clr_thresh   
%              inds1 = [];
%         end
%         if max(sim) == 0
%             inds1 = [];
%         else
%             [~,inds1] = max(sim);
%         end
        ratio1 = dres.h(f1(i))./dres.h(f2(inds1));
        inds2  = (min(ratio1, 1./ratio1) > 0.4);          %% we ignore transitions with large change in the size of bounding boxes.
        dres.nei(f1(i),1).inds  = f2(inds1(inds2))';      %% each detction window will have a list of indices pointing to its neighbors in the previous frame.
    end
end

 