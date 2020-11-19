cmake_minimum_required(VERSION 2.8.3)
project(aws_robomaker_bookstore_world)

find_package(catkin REQUIRED COMPONENTS
  gazebo_ros
)

catkin_package()

install(DIRECTORY launch models worlds maps routes
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
