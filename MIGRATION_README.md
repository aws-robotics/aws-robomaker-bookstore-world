# Gazebo Harmonic Migration - Hızlı Başlangıç

## 📁 Dosyalar

1. **GAZEBO_HARMONIC_MIGRATION_GUIDE.md** - Detaylı migration rehberi (120+ sayfa)
2. **migrate_to_harmonic.sh** - Otomatik migration scripti
3. **MIGRATION_README.md** - Bu dosya (hızlı başlangıç)

---

## 🚀 Hızlı Kullanım

### Otomatik Migration

```bash
# Script'i çalıştırılabilir yap (ilk seferinde)
chmod +x migrate_to_harmonic.sh

# Migration'ı başlat
./migrate_to_harmonic.sh <world_file> <models_directory> [physics_engine]

# Örnek:
./migrate_to_harmonic.sh bookstore.world ~/models bullet
```

**Parametreler:**
- `world_file`: World dosyasının yolu (örn: `bookstore.world`)
- `models_directory`: Model dizininin yolu (örn: `~/workspace/models`)
- `physics_engine`: (Opsiyonel) `bullet` (varsayılan) veya `dart`

---

## 📋 Migration Adımları (Otomatik)

Script şunları yapar:

1. ✅ Yedekleme oluşturur (`.backup_YYYYMMDD_HHMMSS`)
2. ✅ SDF versiyonunu 1.6 → 1.9 günceller
3. ✅ Physics engine'i değiştirir (ODE → Bullet/DART)
4. ✅ Deprecated attribute'ları kaldırır (`frame=""`)
5. ✅ Tüm model dosyalarını günceller
6. ✅ Mesh URI'larını düzeltir (`file://` → `model://`)
7. ✅ Doğrulama yapar

---

## ⚙️ Manuel Migration

Detaylı adımlar için `GAZEBO_HARMONIC_MIGRATION_GUIDE.md` dosyasına bakın.

**Özet Komutlar:**
```bash
# World dosyası
sed -i "s/<sdf version='1.6'>/<sdf version='1.9'>/g" world.world
sed -i 's/type="ode"/type="bullet"/g' world.world
sed -i 's/ frame=""//g' world.world

# Model dosyaları
find ./models -name "model.sdf" -exec sed -i "s/<sdf version='1.6'>/<sdf version='1.9'>/g" {} \;
find ./models -name "model.sdf" -exec sed -i 's|file://models/|model://|g' {} \;
```

---

## 🔧 Physics Engine Seçimi

### Bullet (ÖNERİLEN)
✅ Mesh collision desteği
✅ Robotik için optimize
✅ Hızlı ve stabil

**Kullanım:**
```bash
./migrate_to_harmonic.sh world.world ./models bullet
```

### DART
✅ Yüksek doğruluk
❌ Mesh collision YOK
⚠️ Sadece basit geometriler (box, cylinder, sphere)

**Kullanım:**
```bash
./migrate_to_harmonic.sh world.world ./models dart
```

---

## 🧪 Test

### 1. Environment Ayarla
```bash
export GZ_SIM_RESOURCE_PATH=/path/to/models:$GZ_SIM_RESOURCE_PATH
```

### 2. Gazebo'da Çalıştır
```bash
# GUI ile
gz sim your_world.world -r -v 4

# Headless (GUI olmadan)
gz sim your_world.world -r -s --headless-rendering
```

### 3. ROS2 ile Test
```bash
# Turtlebot4 örneği
source ~/turtlebot4_ws/install/setup.bash
export GZ_SIM_RESOURCE_PATH=~/models:$GZ_SIM_RESOURCE_PATH

ros2 launch turtlebot4_gz_bringup turtlebot4_gz.launch.py \
  world:=your_world \
  model:=standard
```

---

## 🐛 Sorun Giderme

### Problem: Collision Detection Çalışmıyor

**Semptom:** Robot duvarlardan geçiyor

**Çözüm:**
```bash
# Physics engine'i kontrol et
grep "type=" your_world.world

# DART görüyorsan Bullet'e değiştir
./migrate_to_harmonic.sh your_world.world ./models bullet
```

---

### Problem: Model Bulunamıyor

**Hata:** `Unable to find uri[model://my_model]`

**Çözüm:**
```bash
# Environment variable'ı ayarla
export GZ_SIM_RESOURCE_PATH=/path/to/models:$GZ_SIM_RESOURCE_PATH

# Veya kalıcı yap (~/.bashrc'ye ekle)
echo 'export GZ_SIM_RESOURCE_PATH=/path/to/models:$GZ_SIM_RESOURCE_PATH' >> ~/.bashrc
source ~/.bashrc
```

---

### Problem: Mesh Dosyası Bulunamıyor

**Hata:** `Unable to find uri[model://MyModel/meshes/MyMesh.DAE]`

**Çözüm:**
```bash
# Dosya adlarını kontrol et (case-sensitive!)
ls /path/to/models/MyModel/meshes/

# Gerçek dosya adı: mymesh.dae
# SDF'te: MyMesh.DAE ← YANLIŞ!

# Düzelt:
sed -i 's/MyMesh.DAE/mymesh.dae/g' model.sdf
```

---

## 📚 Örnek Kullanım

### AWS Bookstore World Migration

```bash
# 1. Script ile migrate et
./migrate_to_harmonic.sh \
  ~/workspace/aws-robomaker-bookstore-world/worlds/bookstore.world \
  ~/workspace/aws-robomaker-bookstore-world/models \
  bullet

# 2. World'ü ROS2 package'a kopyala
cp ~/workspace/aws-robomaker-bookstore-world/worlds/bookstore.world \
   ~/turtlebot4_ws/install/turtlebot4_gz_bringup/share/turtlebot4_gz_bringup/worlds/bookstore.sdf

# 3. Environment ayarla
export GZ_SIM_RESOURCE_PATH=~/workspace/aws-robomaker-bookstore-world/models:$GZ_SIM_RESOURCE_PATH

# 4. Launch
cd ~/turtlebot4_ws
source install/setup.bash
ros2 launch turtlebot4_gz_bringup turtlebot4_gz.launch.py world:=bookstore
```

---

## ✅ Migration Checklist

Migration tamamlandıktan sonra kontrol et:

- [ ] World dosyası SDF 1.9
- [ ] Physics engine Bullet veya DART
- [ ] `frame=""` attribute'ları yok
- [ ] Model dosyaları SDF 1.9
- [ ] Mesh URI'ları `model://` formatında
- [ ] Backup dosyaları oluşturuldu
- [ ] `gz sdf --check` hatasız
- [ ] Gazebo GUI açılıyor
- [ ] Collision detection çalışıyor
- [ ] ROS2 topic'leri aktif

---

## 🔗 Ek Bilgiler

**Detaylı Rehber:**
- `GAZEBO_HARMONIC_MIGRATION_GUIDE.md` dosyasını okuyun (120+ sayfa)
- Tüm değişiklikler ve örneklerle açıklanmıştır

**Resmi Dökümanlar:**
- [Gazebo Harmonic Migration](https://gazebosim.org/docs/harmonic/migrating_gazebo_classic)
- [SDF Format Spec](http://sdformat.org/spec)

**Örnek Projeler:**
- [Turtlebot4 Simulator](https://github.com/turtlebot/turtlebot4_simulator)
- [ROS2 Gazebo Demos](https://github.com/gazebosim/ros_gz_project_template)

---

## 📞 Destek

Sorun yaşarsanız:

1. `GAZEBO_HARMONIC_MIGRATION_GUIDE.md` → "Sık Karşılaşılan Sorunlar" bölümüne bakın
2. Log dosyalarını kontrol edin:
   ```bash
   gz sim world.world -r -v 4 2>&1 | grep -E "\[Err\]|ERROR"
   ```
3. GitHub Issues: Migration script için pull request açabilirsiniz

---

**Version:** 1.0
**Last Updated:** 2025
**Tested:** Gazebo Harmonic 8.9.0 + ROS2 Jazzy
