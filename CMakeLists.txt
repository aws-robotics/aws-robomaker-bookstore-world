cmake_minimum_required(VERSION 3.5)
project(aws_robomaker_bookstore_world)

# Add support for C++14
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()

find_package(ament_cmake REQUIRED)
find_package(ros_gz_sim REQUIRED)

install(DIRECTORY launch maps models routes param worlds
  DESTINATION share/${PROJECT_NAME}
)

ament_environment_hooks("${CMAKE_CURRENT_SOURCE_DIR}/env-hooks/aws_robomaker_bookstore_world.dsv.in")

ament_export_dependencies(ament_cmake)
ament_export_dependencies(gazebo_ros)

ament_package()