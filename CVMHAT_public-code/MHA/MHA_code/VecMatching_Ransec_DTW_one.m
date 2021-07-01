function [match_idx_top,match_idx_ego] = VecMatching_Ransec_DTW_one(data,params,vec_top,vec_ego)
    
%     vec_top = data.vec_top;  
%     vec_ego = data.vec_ego;
    img_w = data.size_img_hor(2);
  
    Rho = params.Rho;
    x_thresh = params.x_thresh;
    dis_thresh = params.dis_thresh;
    Lambda = params.Lambda;
    
    search_num = length(vec_top);
    match_scores = zeros(1,search_num);
    scale_y_all = zeros(1,search_num);
    match_idx_top = cell(1,search_num);
    match_idx_ego = cell(1,search_num);
           
        vec1 = vec_top;  
        vec2 = vec_ego;
        
        if size(vec1,2) < 1
            match_scores=  Inf;
            idx_top =1;
            idx_ego=1;
            scale_y=1;
        else             
            len1 = length(vec1(1,:));
            len2 = length(vec2(1,:));
            vec1(1,:) = vec1(1,:);
            vec2(1,:) = vec2(1,:)/(img_w/2);
            len = max(len1,len2);           
%%ransec      
            vec2(2,:) = 1./vec2(2,:);
            d = pdist2(vec1(1,:)',vec2(1,:)','euclidean');
            [match_idx_P]=dtw(vec1(1,:), vec2(1,:),d);
            [idx_ego,idx_top]=single_out(d,match_idx_P,x_thresh);
            scale_y=get_scale_y(idx_top,idx_ego,vec1,vec2);  
            scale_y_all = scale_y;
%%y/y_scale normalizing
            vec1(2,:) = vec1(2,:)./scale_y;
            d = myEuclidean(vec1,vec2,Lambda);
            [match_idx_P,gamma]=dtw(vec1,vec2,d);
            [idx_ego,idx_top,score]=single_out(d,match_idx_P,dis_thresh);
       
            penalty_vec = Rho^((len/gamma));
            match_scores = penalty_vec*(score/gamma);
        
        end
        match_idx_top = idx_top;
        match_idx_ego = idx_ego;

    data.match_idx_ego = idx_ego;
    data.match_idx_top = match_idx_top;
    data.match_idx_ego = match_idx_ego;
    
end
