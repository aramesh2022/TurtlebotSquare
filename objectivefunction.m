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

while true
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
corners = points.Location;
imshow(rgbIM);
hold on;
plot(corners(:, 1), corners(:, 2), 'ro');

for i = 1:size(corners, 1)
    for j = (i+1):size(corners, 1)
        for k = (j+1):size(corners, 1)
            for m = (k+1):size(corners, 1)
                % Calculate the center of the square as the average of the four corners
                center = [mean(corners([i, j, k, m], 1)), mean(corners([i, j, k, m], 2))];
                
                % Plot green circles at the centers
                plot(center(1), center(2), 'go');
            end
        end
    end
end

   
    % Calculate control commands
    cmdVelMsg = rosmessage('geometry_msgs/Twist');
    cmdVelMsg.Linear.X = Kp_linear;  % Move forward/backward based on square's position
    cmdVelMsg.Angular.Z = Kp_angular * Py;  % Rotate to align with the square
    
     send(cmdVel, cmdVelMsg);
     %
     distance_to_square = sqrt(error_y^2);
 if distance_to_square <= max_tracking_distance
        break;  % Exit the loop when the robot is within the specified distance
    end
end
   % Publish control commands to drive topic

    % Check for the exit condition based on distance
    
% Stop the robot
cmdVelMsg.Linear.X = 0;
cmdVelMsg.Angular.Z = 0;
send(cmdVel, cmdVelMsg);


% Shutdown the ROS node
rosshutdown;
