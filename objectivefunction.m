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
%imshow(depthIM); hold on;
PC_depth = receive(depthPC,5);
%PC = readImage(PC_depth);
scatter3(PC_depth);
camconvert = rgb2gray(rgbIM);
imshow(camconvert); hold on;
points = detectHarrisFeatures(camconvert);
best4 = points.selectStrongest(4);
%averaging function
P1x = best4.Location(1,1);
P2x = best4.Location(2,1);
P3x = best4.Location(3,1);
P4x = best4.Location(4,1);
Px = (P1x + P2x + P3x + P4x) / 4

P1y = best4.Location(1,2);
P2y = best4.Location(2,2);
P3y = best4.Location(3,2);
P4y = best4.Location(4,2);
Py = (P1y + P2y + P3y + P4y) / 4

plot(points.selectStrongest(4));

 %camInfo = receive(c_info,5);
 %camheight = camInfo.Height;
 %camwidth = camInfo.Width;
    % Calculate the error (position difference) between the TurtleBot and the square object
    error_x = Px; %- (camheight / 2);  % Error in the x-direction
    error_y = Py;
   % display(camheight);
    %display(camwidth);

    %error_y = Py; %- (camwidth / 2);  % Error in the y-direction
   
    % Calculate control commands
    cmdVelMsg = rosmessage('geometry_msgs/Twist');
    cmdVelMsg.Linear.X = Kp_linear;  % Move forward/backward based on square's position
    cmdVelMsg.Angular.Z = Kp_angular * Py;  % Rotate to align with the square



 % Receive odometry data to get the TurtleBot's position
    % odomMsg = receive(odom, 3);  % Wait for up to 3 seconds for odometry data
    % pose = odomMsg.Pose.Pose;
    % x_turtlebot = pose.Position.X
    % y_turtlebot = pose.Position.Y
% 
%     % Calculate the error (position difference) between the TurtleBot and
%     % the square object
%     error_x = Px - x_turtlebot;  % Error in the x-direction
%     error_y = Py - y_turtlebot;  % Error in the y-direction
% % Calculate control commands
%     cmdVelMsg = rosmessage('geometry_msgs/Twist');
%     cmdVelMsg.Linear.X = 0.1  % Move forward/backward based on error in the y-direction
%     cmdVelMsg.Angular.Z = Kp_angular * error_x;  % Rotate to align with the square
%     display(cmdVelMsg.Angular.Z)
%     %disp(cmdVelMsg)
    
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
