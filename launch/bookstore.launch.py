import os
import sys

import launch
from launch.conditions import IfCondition
from ament_index_python.packages import get_package_share_directory


def generate_launch_description():
    world_file_name = "bookstore.world"
    world = os.path.join('worlds', world_file_name)
    env = {
        'GAZEBO_MODEL_PATH': os.path.join(get_package_share_directory('aws_robomaker_bookstore_world'), 'models')
    }

    ld = launch.LaunchDescription([
        launch.actions.DeclareLaunchArgument(
            name='gui',
            default_value='false'
        ),
        launch.actions.ExecuteProcess(
            cmd=['gzserver', '--verbose', world],
            cwd=get_package_share_directory('aws_robomaker_bookstore_world'),
            additional_env=env,
            output='screen'
        ),
        launch.actions.ExecuteProcess(
            cmd=['gzclient'],
            additional_env=env,
            output='screen',
            condition=IfCondition(
                launch.substitutions.LaunchConfiguration('gui'))
        ),
    ])
    return ld


if __name__ == '__main__':
    generate_launch_description()
