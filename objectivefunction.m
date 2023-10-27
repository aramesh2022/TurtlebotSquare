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
depth_value = depthIM(roundedC2, roundedC1)
 odomMsg = receive(odom, 3);  % Wait for up to 3 seconds for odometry data
    pose = odomMsg.Pose.Pose;
    x_turtlebot = pose.Position.X;
    y_turtlebot = pose.Position.Y;
% Given depth reading (depth) and the camera center (cam_center)
%depth = 1000;  % Depth reading in millimeters (adjust as needed)
cam_center = [x_turtlebot, y_turtlebot];  % Camera center point in real-world coordinates

% Calculate the Euclidean distance
square_center = [center(1), center(2)];  % Square's center point in real-world coordinates
distance = norm(square_center - cam_center);

% Display the calculated distance
disp(['Distance to square: ', num2str(distance), ' millimeters']);   






    % Calculate control commands
    cmdVelMsg = rosmessage('geometry_msgs/Twist');
    cmdVelMsg.Linear.X = Kp_linear;  % Move forward/backward based on square's position
    cmdVelMsg.Angular.Z = Kp_angular * Py;  % Rotate to align with the square
    
     send(cmdVel, cmdVelMsg);
     %

 % if distance_to_square <= max_tracking_distance
 %        break;  % Exit the loop when the robot is within the specified distance
 %    end
 %    end
   % Publish control commands to drive topic

    % Check for the exit condition based on distance
    
% Stop the robot
cmdVelMsg.Linear.X = 0;
cmdVelMsg.Angular.Z = 0;
send(cmdVel, cmdVelMsg);


% Shutdown the ROS node
rosshutdown;
