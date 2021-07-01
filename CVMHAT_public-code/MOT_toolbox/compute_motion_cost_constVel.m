function cost = compute_motion_cost_constVel(x1,x2,param)

tic;close;

%% Smoothing
if(param.smooth && size(x1.data,2)>5 && size(x2.data,2)>5)
    x1_tmp = smooth_trajectory(x1.data');
    x1.data = x1_tmp';
    x2_tmp = smooth_trajectory(x2.data');
    x2.data = x2_tmp';
end

max_error = param.max_error;
sigma = param.sigma;

% x2.data(1,1)=290;
%% Forward
if x1.length>=6
    t1 = round(0.5*x1.length);
else
    t1 = x1.length-1;
end
if x2.length>=6
    t2 = round(0.5*x2.length);
else
    t2 = x2.length-1;
end
vel_vec_x_1 = diff(x1.data(1,end-t1:end));
vel_vec_y_1 = diff(x1.data(2,end-t1:end));

frames_1 = x1.frame(end-t1:end)';
frames_2 = x2.frame(1:t2)';
frames_2_tmp = repmat(frames_2,1,length(frames_1));
frames_1_tmp = repmat(frames_1',length(frames_2),1);
frame_diff = frames_2_tmp - frames_1_tmp;

vel_x_tmp = repmat(vel_vec_x_1,length(frames_2),1);
vel_y_tmp = repmat(vel_vec_y_1,length(frames_2),1);
x1_tmp = repmat(x1.data(1,end-t1:end),length(frames_2),1);
y1_tmp = repmat(x1.data(2,end-t1:end),length(frames_2),1);
prediction_x_tmp = zeros(length(frames_2),length(vel_vec_x_1));
prediction_y_tmp = zeros(length(frames_2),length(vel_vec_x_1));

predicted_GT = x2.data(:,1:t2);
error_FW = zeros(1,length(vel_vec_x_1));
for i=1:length(vel_vec_x_1)
    prediction_x_tmp(:,i) = vel_x_tmp(:,i).*frame_diff(:,i) + x1_tmp(:,i);
    prediction_y_tmp(:,i) = vel_y_tmp(:,i).*frame_diff(:,i) + y1_tmp(:,i);
    predicted = [prediction_x_tmp(:,i)';prediction_y_tmp(:,i)'];
    error_FW(i) = sum(sqrt(sum((predicted_GT-predicted).^2)))/size(prediction_y_tmp,1);
end

error_FW_n = mean(error_FW);

%% Backward
vel_vec_x_1 = -diff(x2.data(1,1:t2));
vel_vec_y_1 = -diff(x2.data(2,1:t2));
frames_1 = x1.frame(end-t1:end)';
frames_2 = x2.frame(1:t2)';
frames_2_tmp = repmat(frames_1,1,length(frames_2));
frames_1_tmp = repmat(frames_2',length(frames_1),1);
frame_diff = -(frames_2_tmp - frames_1_tmp);

vel_x_tmp = repmat(vel_vec_x_1,length(frames_1),1);
vel_y_tmp = repmat(vel_vec_y_1,length(frames_1),1);
x1_tmp = repmat(x2.data(1,1:t2),length(frames_1),1);
y1_tmp = repmat(x2.data(2,1:t2),length(frames_1),1);
prediction_x_tmp = zeros(length(frames_1),length(vel_vec_x_1));
prediction_y_tmp = zeros(length(frames_1),length(vel_vec_x_1));

predicted_GT = x1.data(:,end-t1:end);
error_BW = zeros(1,length(vel_vec_x_1));

for i=1:length(vel_vec_x_1)
    prediction_x_tmp(:,i) = vel_x_tmp(:,i).*frame_diff(:,i) + x1_tmp(:,i);
    prediction_y_tmp(:,i) = vel_y_tmp(:,i).*frame_diff(:,i) + y1_tmp(:,i);
    predicted = [prediction_x_tmp(:,i)';prediction_y_tmp(:,i)'];
    error_BW(i) = sum(sqrt(sum((predicted_GT-predicted).^2)))/size(prediction_y_tmp,1);
end
error_BW_n = mean(error_BW);

cost = (error_FW_n + error_BW_n)/2;
if(cost>max_error)
     cost = param.motion_punish;  % cost = exp(-cost/sigma);  % cost = -1000;   
else
    cost = exp(-cost/sigma);
end
tt = toc;

end