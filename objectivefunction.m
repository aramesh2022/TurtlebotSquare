clc
clear all
rosshutdown
rosinit

Kp_linear = 0.05;
Kp_angular = 0.0;
max_tracking_distance = 100;

% get rgb + depth cam 
clear ('pub', 'sub', 'node')
node = ros.Node('/driving');

rgb = rossubscriber('/camera/rgb/image_raw', 'sensor_msgs/Image');
c_info = rossubscriber('/camera/rgb/camera_info', 'sensor_msgs/CameraInfo');
depth = rossubscriber('/camera/depth/image_raw', 'sensor_msgs/Image');
depthPC = rossubscriber('/camera/depth/points', 'sensor_msgs/PointCloud2');
cmdVel = ros.Publisher(node, '/cmd_vel', 'geometry_msgs/Twist');
odom = rossubscriber('/odom');


% get images off cam
rgbCAM = receive(rgb,5);
rgbIM = readImage(rgbCAM);

depthCAM = receive(depth,5);
depthIM = readImage(depthCAM);
DPC = depthIM(~isnan(depthIM));
%imshow(depthIM); hold on;
PC_depth = receive(depthPC,5);
%PC = readImage(PC_depth);
%scatter3(PC_depth);

camconvert = rgb2gray(rgbIM);

points = detectHarrisFeatures(camconvert);
% Sort the corner points by their strengths (you may use different criteria)
[~, sorted_indices] = sort(points.Metric, 'descend');

% Select the strongest four corners
strongest_corners = points.Location(sorted_indices(1:4), :);

% Plot the original image
imshow(camconvert);
plot(strongest_corners);
hold on;

% Calculate the centers of the squares
num_corners = size(strongest_corners, 1);
for i = 1:num_corners
    for j = (i+1):num_corners
        for k = (j+1):num_corners
            for m = (k+1):num_corners
                % Calculate the center of the square as the average of the four corners
                center = [mean(strongest_corners([i, j, k, m], 1)), mean(strongest_corners([i, j, k, m], 2))];
                
                % Plot green circles at the centers
                plot(center(1), center(2), 'go');
            end
        end
    end
end
roundedC1 = round(center(1));
roundedC2 = round(center(2));
depth_value = depthIM(roundedC2, roundedC1);

    % Calculate control commands
    cmdVelMsg = rosmessage('geometry_msgs/Twist');
    cmdVelMsg.Linear.X = Kp_linear;  % Move forward/backward based on square's position
    cmdVelMsg.Angular.Z = Kp_angular * Py;  % Rotate to align with the square
    
     send(cmdVel, cmdVelMsg);
     %


    % Check for the exit condition based on distance
    
% Stop the robot
cmdVelMsg.Linear.X = 0;
cmdVelMsg.Angular.Z = 0;
send(cmdVel, cmdVelMsg);


% Shutdown the ROS node
rosshutdown;
