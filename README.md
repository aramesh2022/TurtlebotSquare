# Turtlebot following a Square in a straight line
Turtlebot following a straight line by observing a square
This project uses the combination of MATLAB and the ROS environment on an Ubuntu system to make the Turtlebot 3 Waffle follow a square object in a straight line. This involves the use of both the onboard rgb and depth camera's to do image and depth processing in order to locate the square and move the turtlebot towards it safely and accurately.

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


**Logic behind the code:**

