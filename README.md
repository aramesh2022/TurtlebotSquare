# Turtlebot following a Square in a straight line
Turtlebot following a straight line by observing a square:    
This project uses the combination of MATLAB and the ROS environment on an Ubuntu system to make the Turtlebot 3 Waffle follow a square object in a straight line. This involves the use of both the onboard RGB and depth camera's to do image and depth processing in order to locate the square and move the turtlebot towards it safely and accurately.

**Required Software:**
- Ubuntu 18.04/20.04 system installed
- MATLAB on the Ubuntu system including the computer vision toolbox, image processing toolbox, robotics sytem toolbox, ROS toolbox and ROS toolbox support package for Turtlebot-Based Robots
- ROS Melodic/Noetic

## LINK TURTLEBOT GITS
Within Ubuntu you need to follow these instructions to set up the turtlebot and it's simulations:

Clone and build the 3 following repositories in your catkin workspace
cd ~/catkin_ws/src/  
git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git  
git clone https://github.com/ROBOTIS-GIT/turtlebot3.git  
git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git  
cd ~/catkin_ws  
catkin_make  
source devel/setup.bash  

Select which model of the turtlebot you would like, which for this project is the Turtlebot-3 Waffle  
gedit ~/.bashrc  
Add the following line to the bottom of your bashrc file, save and close  
export TURTLEBOT3_MODEL=burger  
Reload .bashrc  
source ~/.bashrc  

To run:       

Step 1:  
export TURTLEBOT3_MODEL=waffle  
roslaunch turtlebot3_gazebo turtlebot3_empty_world.launch // change to correct world  
roslaunch turtlebot3_gazebo turtlebot3_gazebo_rviz.launch  

Step 2:   
Run matlab code  

Step 3:  
Sit back and enjoy  


## **Explaining the code:**
**Functionality:**  
The robot will initially check the RGB camera to scan for a square object in the vicinity, this is done via Harris Corner detection where all potential corners are collected and then they are sorted and the strongest 4 corners are selected. If no square is detected the robot will move a small amount anticlockwise and try to find a square again, this allows for the code designed to find the square even if it is placed behind the turtlebot.  
If the code detects a square in the vicinity, the code then averages out the four strongest corners to get the center of the square and compares the calculated center of the square to the center of the robot's camera image. If the center is not within a preset acceptable range it will then rotate a small amount anticlockwise before once again checking the RGB camera, this will loop until the center is within the pre-specified range of the image.  
Once the center is correct however, it then begins the forward movement of the turtlebot by sending a velocity to the turtlebot. The turtlebot will then stop in 2 cases, either when the preset distance from the square is reached or when the corner detection is no longer functional and it cannot find the square. This last scenario is to perform in the function of an estop for safety reasons so the robot does not error and continue endlessly. This also allows for the square to be moved and then placed again and the turlebot will still continue moving the square after its stoppage.  

**Code Structure:**  
The structure of the code can be broken down into a few main parts:  
- The initialisation of variable and publishers, subscribers and nodes is first where the code is setup to work at the top of the file  
The below is all in a while true loop  
- Secondly the camera reading for the RGB and Depth Camera's are taken and the Harris Corner detection is performed on the RGB image  
- Next the if statement checking whether there is a square is included, where the robot will stop and rotate if there are less than 4 corners detected. This includes an initialised variable called detection so that this rotation only occurs before it finds a square.  
- Next there is another if statement for if a square is found, this statement calculates the center x and y coordinates of the square and rounds them. The width value is then compared to a predetermined amount so that the robot will only move forward when the robot is facing the center of the square.  
- Next the velocity command is sent to the turtlebot and it begins driving forward  
- Lastly inside the while loop there is an if statement which compares the constantly recalculated distance value to a preset variable and if it is lower than said value it breaks the while loop, sets all velocities to 0 and shutdowns ROS  


## Contribution  
Stefan Naprta 50%  
Aaryan Ramesh 50%  

