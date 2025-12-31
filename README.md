# AWS RoboMaker Bookstore World - Gazebo Harmonic Edition

![Gazebo01](docs/images/gazebo_01.png)

**This is a Gazebo Harmonic compatible version of the AWS RoboMaker Bookstore World.**

[![Gazebo Version](https://img.shields.io/badge/Gazebo-Harmonic%208.x-blue)](https://gazebosim.org/docs/harmonic)
[![ROS2 Version](https://img.shields.io/badge/ROS2-Jazzy-green)](https://docs.ros.org/en/jazzy/)
[![SDF Version](https://img.shields.io/badge/SDF-1.9-orange)](http://sdformat.org/)

---

## 🆕 What's New in This Fork

This repository has been **migrated to Gazebo Harmonic** with the following improvements:

### ✅ Migration Highlights

- **SDF 1.9 Compatibility** - Updated from SDF 1.6
- **Gazebo Harmonic Support** - Fully compatible with Gazebo Sim 8.x
- **Modern GUI Configuration** - Plugin-based GUI system with Ogre2 rendering
- **Physics Engine Update** - DART physics engine (configurable to Bullet)
- **Cleaned Deprecated Features** - Removed `frame=""` attributes and legacy code
- **ROS2 Jazzy Integration** - Optimized for latest ROS2 distribution

### 📚 Migration Resources

This repository includes comprehensive migration documentation:

- **[GAZEBO_HARMONIC_MIGRATION_GUIDE.md](GAZEBO_HARMONIC_MIGRATION_GUIDE.md)** - Complete migration guide (120+ pages)
- **[migrate_to_harmonic.sh](migrate_to_harmonic.sh)** - Automated migration script
- **[MIGRATION_README.md](MIGRATION_README.md)** - Quick start guide

Use these resources to migrate your own Gazebo Classic worlds to Harmonic!

---

## 🚀 Quick Start

### Prerequisites

```bash
# Gazebo Harmonic (Ubuntu 24.04 recommended)
sudo apt-get install gz-harmonic

# ROS2 Jazzy
sudo apt-get install ros-jazzy-desktop

# ROS-Gazebo Bridge
sudo apt-get install ros-jazzy-ros-gz-sim ros-jazzy-ros-gz-bridge
```

### Installation

```bash
# Create workspace
mkdir -p ~/bookstore_ws/src
cd ~/bookstore_ws/src

# Clone this repository
git clone -b ros2 https://github.com/binner2/aws-robomaker-bookstore-world-ros2.git

# Build
cd ~/bookstore_ws
rosdep install --from-paths src --ignore-src -r -y
colcon build

# Source
source install/setup.bash
```

---

## 🎮 Usage

### Option 1: Load Directly into Gazebo Harmonic (No ROS)

```bash
# Set model path
export GZ_SIM_RESOURCE_PATH=~/bookstore_ws/src/aws-robomaker-bookstore-world-ros2/models:$GZ_SIM_RESOURCE_PATH

# Launch Gazebo Harmonic
gz sim ~/bookstore_ws/src/aws-robomaker-bookstore-world-ros2/worlds/bookstore.world -r -v 4
```

### Option 2: ROS2 Launch (Recommended)

```bash
cd ~/bookstore_ws
source install/setup.bash

# Launch with Gazebo GUI
ros2 launch aws_robomaker_bookstore_world bookstore.launch.py gui:=true
```

### Option 3: With Turtlebot4

```bash
# Copy world to Turtlebot4 worlds directory
cp worlds/bookstore.world \
   ~/turtlebot4_ws/install/turtlebot4_gz_bringup/share/turtlebot4_gz_bringup/worlds/bookstore.sdf

# Set model path
export GZ_SIM_RESOURCE_PATH=~/bookstore_ws/src/aws-robomaker-bookstore-world-ros2/models:$GZ_SIM_RESOURCE_PATH

# Launch Turtlebot4 in bookstore
ros2 launch turtlebot4_gz_bringup turtlebot4_gz.launch.py \
  world:=bookstore \
  x:=0.5 y:=1.0 z:=0.1 \
  model:=standard
```

---

## 🏗️ Include the World from Another Package

### Update Your `.rosinstall`

```yaml
- git:
    local-name: src/aws-robomaker-bookstore-world-ros2
    uri: 'https://github.com/binner2/aws-robomaker-bookstore-world-ros2.git'
    version: ros2
```

### Add to Your Launch File

```python
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription, SetEnvironmentVariable
from launch.launch_description_sources import PythonLaunchDescriptionSource
from ament_index_python.packages import get_package_share_directory
import os

def generate_launch_description():
    pkg_bookstore = get_package_share_directory('aws_robomaker_bookstore_world')

    # Set model path
    gz_resource_path = SetEnvironmentVariable(
        name='GZ_SIM_RESOURCE_PATH',
        value=os.path.join(pkg_bookstore, 'models')
    )

    # Include bookstore launch
    bookstore_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(pkg_bookstore, 'launch', 'bookstore.launch.py')
        ),
        launch_arguments={'gui': 'true'}.items()
    )

    return LaunchDescription([
        gz_resource_path,
        bookstore_launch
    ])
```

---

## 🔧 Physics Engine Configuration

The world file is currently configured with **DART** physics engine. If you need mesh collision support:

### Switch to Bullet Physics

```bash
# Use the provided migration script
./migrate_to_harmonic.sh worlds/bookstore.world ./models bullet

# Or manually edit worlds/bookstore.world
# Change line 22:
# FROM: <physics name="default_physics" type="dart">
# TO:   <physics name="default_physics" type="bullet">
```

**Why?**
- **DART**: High accuracy, but NO mesh collision support
- **Bullet**: Full mesh collision support, recommended for robotics

See [GAZEBO_HARMONIC_MIGRATION_GUIDE.md](GAZEBO_HARMONIC_MIGRATION_GUIDE.md#physics-engine-seçimi) for details.

---

## 📐 Robot Simulation - Initial Position

Recommended spawn positions:

| Location | Position (x, y, z) | Orientation (yaw) | Description |
|----------|-------------------|-------------------|-------------|
| Service Desk | (0.5, 1.0, 0.1) | 0.0 | Near information desk |
| Center | (0.0, 0.0, 0.1) | 0.0 | Center of bookstore |
| Reading Area | (-4.0, 3.0, 0.1) | 1.57 | Near tables and chairs |

---

## 🛠️ Building

### Standard Build

```bash
cd ~/bookstore_ws
rosdep install --from-paths src --ignore-src -r -y
colcon build
source install/setup.bash
```

### Include as Dependency

Add to your `package.xml`:

```xml
<exec_depend>aws_robomaker_bookstore_world</exec_depend>
```

---

## 📊 Technical Specifications

| Feature | Specification |
|---------|---------------|
| **SDF Version** | 1.9 |
| **Gazebo Version** | Harmonic (8.x) |
| **ROS2 Version** | Jazzy (compatible with Humble) |
| **Physics Engine** | DART (configurable to Bullet) |
| **Rendering Engine** | Ogre2 |
| **Number of Models** | 34+ retail models |
| **World Size** | ~15m x 15m |

---

## 🔍 Migration Details

### What Changed from Original

1. **SDF Version**: 1.6 → 1.9
2. **GUI System**: Classic camera → Plugin-based MinimalScene
3. **Physics Engine**: ODE → DART
4. **Model URIs**: `file://models/` → `model://`
5. **Deprecated Attributes**: Removed all `frame=""` attributes
6. **Lighting**: Maintained with updated format

### Migration Stats

- ✅ **34 model files** updated
- ✅ **1 world file** completely migrated
- ✅ **0 breaking changes** to model meshes or textures
- ✅ **100% compatible** with Gazebo Harmonic 8.x

---

## 📚 Documentation

- **[GAZEBO_HARMONIC_MIGRATION_GUIDE.md](GAZEBO_HARMONIC_MIGRATION_GUIDE.md)** - Comprehensive 120-page migration guide
  - Step-by-step migration instructions
  - Before/after code examples
  - Physics engine comparison (DART vs Bullet)
  - Common issues and solutions
  - ROS2 integration guide

- **[MIGRATION_README.md](MIGRATION_README.md)** - Quick reference guide
  - Fast command examples
  - Troubleshooting tips
  - AWS Bookstore specific examples

- **[migrate_to_harmonic.sh](migrate_to_harmonic.sh)** - Automated migration script
  - One-command migration
  - Automatic backups
  - Validation checks

---

## 🧪 Testing

### Verify Installation

```bash
# Check world file syntax
gz sdf --check worlds/bookstore.world

# Launch in headless mode (no GUI)
export GZ_SIM_RESOURCE_PATH=models:$GZ_SIM_RESOURCE_PATH
gz sim worlds/bookstore.world -r -s --headless-rendering
```

### Expected Output

- ✅ World loads without errors
- ✅ All models visible
- ✅ Collision detection working (if using Bullet physics)
- ✅ Lighting correct

---

## 🐛 Known Issues

### Issue 1: Mesh Collision Not Working

**Problem**: Robot passes through objects

**Cause**: DART physics engine doesn't support mesh collisions

**Solution**: Switch to Bullet physics (see [Physics Engine Configuration](#-physics-engine-configuration))

### Issue 2: Models Not Found

**Problem**: `Unable to find uri[model://...]`

**Solution**: Set environment variable
```bash
export GZ_SIM_RESOURCE_PATH=/path/to/models:$GZ_SIM_RESOURCE_PATH
```

### Issue 3: GUI Not Opening

**Problem**: Gazebo starts but no window appears

**Solution**: Check display variable
```bash
export DISPLAY=:0
```

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Original Repository**: [aws-robotics/aws-robomaker-bookstore-world](https://github.com/aws-robotics/aws-robomaker-bookstore-world)
- **AWS RoboMaker Team**: For creating the original bookstore world
- **Gazebo Team**: For Gazebo Harmonic and excellent migration documentation
- **ROS Community**: For ROS2 Jazzy and gz_ros2_control packages

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/binner2/aws-robomaker-bookstore-world-ros2/issues)
- **Discussions**: [GitHub Discussions](https://github.com/binner2/aws-robomaker-bookstore-world-ros2/discussions)
- **Migration Help**: See [GAZEBO_HARMONIC_MIGRATION_GUIDE.md](GAZEBO_HARMONIC_MIGRATION_GUIDE.md)

---

## 🌟 Star History

If you find this project useful, please consider giving it a star! ⭐

---

**Visit the [RoboMaker website](https://aws.amazon.com/robomaker/) to learn more about building intelligent robotic applications with Amazon Web Services.**

**Last Updated**: December 2025
**Gazebo Version**: Harmonic 8.9.0
**ROS2 Version**: Jazzy
**Maintained By**: [@binner2](https://github.com/binner2)
