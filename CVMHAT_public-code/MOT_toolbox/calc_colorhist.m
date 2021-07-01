function [clr] = calc_colorhist(dres1, f1, img1, dres2, f2, img2)
%%f2 can be an array and f1 should be a scalar.
%%% this will find the overlap between dres1(f1) (only one) and all detection windows in dres2(f2(:))

[height,width,~]=size(img1);

f2=f2(:)';
n = length(f2);

%img crop x>0
cx1 = max(dres1.x(f1),1);
cx2 = min(dres1.x(f1)+dres1.w(f1)-1,width);
cy1 = max(dres1.y(f1),1);
cy2 = min(dres1.y(f1)+dres1.h(f1)-1,height);

%img crop x>0
gx1 = max(dres2.x(f2),1);
gx2 = min(dres2.x(f2)+dres2.w(f2)-1,width);
gy1 =max(dres2.y(f2),1);
gy2 = min(dres2.y(f2)+dres2.h(f2)-1,height);


% if f1==40
% disp(f1)
% end
bbox_img1 = img1(cy1:cy2,cx1:cx2,:);
hist1 = invhist(bbox_img1);
hist1 = hist1(:);

hist2 = zeros(32*32*32,n); 
for i = 1:n
bbox_img2 = img2(gy1(i):gy2(i),gx1(i):gx2(i),:);
temp = invhist(bbox_img2);

hist2(:,i)=temp(:);
end
 
clr = slmetric_pw(hist1,hist2,'intersect');




