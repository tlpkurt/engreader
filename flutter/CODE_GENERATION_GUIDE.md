# 🔨 Code Generation Rehberi

## Flutter Code Generation Nedir?

Flutter projelerinde `freezed` ve `json_serializable` paketleri kullanıldığında, kod otomatik oluşturulması gerekir. Bu, model sınıflarımız için immutability ve JSON serialization kodlarını otomatik oluşturur.

---

## 📋 Ön Koşullar

### 1. Flutter SDK Kontrolü
```powershell
flutter --version
```

**Beklenen Çıktı:**
```
Flutter 3.24.0 • channel stable
Framework • revision xyz
Engine • revision abc
Tools • Dart 3.5.0 • DevTools 2.37.0
```

**Eğer Flutter kurulu değilse:**
1. [Flutter.dev](https://flutter.dev/docs/get-started/install/windows) adresinden indir
2. PATH'e ekle
3. `flutter doctor` komutu ile kontrol et

### 2. Dart SDK Kontrolü
```powershell
dart --version
```

**Beklenen Çıktı:**
```
Dart SDK version: 3.5.0 (stable)
```

---

## 🚀 Adım Adım Code Generation

### ADIM 1: Flutter Proje Dizinine Git
```powershell
cd C:\Users\tkurt\Desktop\engreader\flutter\engreader_app
```

### ADIM 2: Dependency'leri Yükle
```powershell
flutter pub get
```

**Beklenen Çıktı:**
```
Running "flutter pub get" in engreader_app...
Resolving dependencies... (2.3s)
+ analyzer 6.4.1
+ args 2.5.0
+ build 2.4.1
+ build_config 1.1.1
+ build_daemon 4.0.2
+ build_resolvers 2.4.2
+ build_runner 2.4.12
+ build_runner_core 7.3.2
+ built_collection 5.1.1
+ built_value 8.9.2
+ code_builder 4.10.0
+ collection 1.18.0
+ crypto 3.0.5
+ dio 5.7.0
+ freezed 2.5.7
+ freezed_annotation 2.4.4
+ go_router 14.2.7
+ google_fonts 6.2.1
+ hive 2.2.3
+ json_annotation 4.9.0
+ json_serializable 6.8.0
+ flutter_riverpod 2.5.1
+ flutter_secure_storage 9.2.2
... (ve daha fazlası)

Changed 142 dependencies!
```

**⚠️ Hata Alırsanız:**
```powershell
# Cache temizle ve tekrar dene
flutter clean
flutter pub get
```

### ADIM 3: Code Generation Çalıştır
```powershell
dart run build_runner build --delete-conflicting-outputs
```

**Bu Komutun Yaptıkları:**
- `build_runner`: Code generation aracını çalıştırır
- `build`: Kodları oluştur (watch yerine tek seferlik)
- `--delete-conflicting-outputs`: Eski dosyaları sil ve yeniden oluştur

**Beklenen Çıktı:**
```
[INFO] Generating build script completed, took 412ms
[INFO] Initializing inputs
[INFO] Building new asset graph completed, took 1.2s
[INFO] Checking for unexpected pre-existing outputs. completed, took 0ms
[INFO] Running build completed, took 14.8s
[INFO] Caching finalized dependency graph completed, took 67ms
[INFO] Succeeded after 16.5s with 84 outputs (168 actions)
```

**Oluşturulan Dosyalar:**
```
lib/features/auth/data/models/
├── user_model.freezed.dart           ✅ (Yeni)
├── user_model.g.dart                 ✅ (Yeni)
├── auth_response_model.freezed.dart  ✅ (Yeni)
└── auth_response_model.g.dart        ✅ (Yeni)

lib/features/story/data/models/
├── story_model.freezed.dart          ✅ (Yeni)
└── story_model.g.dart                ✅ (Yeni)

lib/features/quiz/data/models/
├── quiz_model.freezed.dart           ✅ (Yeni)
└── quiz_model.g.dart                 ✅ (Yeni)

lib/features/translation/data/models/
├── translation_model.freezed.dart    ✅ (Yeni)
└── translation_model.g.dart          ✅ (Yeni)

lib/features/progress/data/models/
├── progress_model.freezed.dart       ✅ (Yeni)
└── progress_model.g.dart             ✅ (Yeni)

Toplam: ~40 yeni dosya oluşturuldu! 🎉
```

### ADIM 4: Derleme Hatalarını Kontrol Et
```powershell
flutter analyze
```

**Beklenen Çıktı:**
```
Analyzing engreader_app...
No issues found! ✅
```

**⚠️ Eğer Hata Varsa:**
```
lib/features/auth/data/models/user_model.dart:5:7: Error: ...
```

**Çözüm:**
1. Hata mesajını oku
2. İlgili dosyayı aç
3. Import statement'ları kontrol et
4. Part directive'leri kontrol et

---

## 🔄 Continuous Code Generation (Development)

Geliştirme sırasında sürekli watch modunda çalıştır:

```powershell
dart run build_runner watch --delete-conflicting-outputs
```

**Bu mod:**
- Model dosyasını her değiştirdiğinde otomatik yeniden oluşturur
- Arka planda çalışır
- Ctrl+C ile durdurulur

**Ne Zaman Kullanılır:**
- Model sınıflarını sık sık değiştiriyorsanız
- Yeni field eklerken
- JSON mapping'i güncellerken

---

## 🐛 Sık Karşılaşılan Hatalar ve Çözümleri

### Hata 1: "Part file doesn't exist"
```
lib/features/auth/data/models/user_model.dart:8:1: Error: Can't use 'user_model.freezed.dart' as a part, because it has no 'part of' directive.
```

**Çözüm:**
Code generation henüz çalışmamış. `dart run build_runner build` komutunu çalıştır.

---

### Hata 2: "Conflicting outputs"
```
[SEVERE] Conflicting outputs were detected and the build is unable to prompt for permission to remove them.
```

**Çözüm:**
```powershell
# Eski dosyaları manuel sil
Get-ChildItem -Recurse -Filter "*.g.dart" | Remove-Item
Get-ChildItem -Recurse -Filter "*.freezed.dart" | Remove-Item

# Tekrar çalıştır
dart run build_runner build --delete-conflicting-outputs
```

---

### Hata 3: "build_runner is not found"
```
Could not find package build_runner in the dependencies.
```

**Çözüm:**
```powershell
# pubspec.yaml'a ekle (zaten var ama yine de kontrol et)
flutter pub add build_runner --dev
flutter pub add freezed --dev
flutter pub add json_serializable --dev

# Sonra tekrar dene
flutter pub get
dart run build_runner build
```

---

### Hata 4: "Dart version conflict"
```
The current Dart SDK version is 3.5.0.
Because engreader_app requires SDK version >=3.0.0 <4.0.0...
```

**Çözüm:**
Dart SDK'yı güncelle:
```powershell
flutter upgrade
dart --version
```

---

### Hata 5: "Out of memory"
```
[SEVERE] Build failed due to exception: Out of memory
```

**Çözüm:**
```powershell
# Build cache'i temizle
flutter clean

# Daha az paralelizasyon ile çalıştır
dart run build_runner build --delete-conflicting-outputs --low-resources-mode
```

---

## ✅ Doğrulama Kontrolleri

### 1. Oluşturulan Dosyaları Kontrol Et
```powershell
# Tüm .freezed.dart dosyalarını listele
Get-ChildItem -Recurse -Filter "*.freezed.dart" | Select-Object FullName

# Tüm .g.dart dosyalarını listele
Get-ChildItem -Recurse -Filter "*.g.dart" | Select-Object FullName
```

**Beklenen Sayı:**
- `.freezed.dart`: ~10 dosya
- `.g.dart`: ~10 dosya

### 2. Import Hatalarını Kontrol Et
```powershell
flutter analyze
```

**Tüm dosyalar hatasız olmalı! ✅**

### 3. Test Derlemesi Yap
```powershell
flutter build apk --debug --target-platform android-arm64
```

**Başarılı olmalı! ✅**

---

## 📝 Model Dosyası Yapısı Örneği

### user_model.dart (Kaynak Dosya)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';  // ← Freezed tarafından oluşturulur
part 'user_model.g.dart';        // ← JSON Serializable tarafından oluşturulur

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? nativeLanguage,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### user_model.freezed.dart (Otomatik Oluşturulan)
```dart
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed...');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get nativeLanguage => throw _privateConstructorUsedError;

  // ... (200+ satır otomatik oluşturulan kod)
}
```

### user_model.g.dart (Otomatik Oluşturulan)
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      nativeLanguage: json['nativeLanguage'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'nativeLanguage': instance.nativeLanguage,
    };
```

**⚠️ ÖNEMLİ:** `.freezed.dart` ve `.g.dart` dosyalarını **ASLA MANUEL OLARAK DEĞİŞTİRMEYİN!**

---

## 🎯 Özet: Tek Komut ile Tamamla

Eğer her şey yolundaysa, tek komut yeterli:

```powershell
cd C:\Users\tkurt\Desktop\engreader\flutter\engreader_app ; flutter pub get ; dart run build_runner build --delete-conflicting-outputs ; flutter analyze
```

**Bu komut:**
1. ✅ Dizine gider
2. ✅ Dependency'leri yükler
3. ✅ Code generation yapar
4. ✅ Hataları kontrol eder

**Beklenen süre:** 20-30 saniye

---

## 📊 Performance İpuçları

### Build Hızlandırma
```powershell
# Sadece değişen dosyaları build et (incremental)
dart run build_runner build

# Tüm cache'i temizle ve sıfırdan build et (tam temizlik)
flutter clean
dart run build_runner build --delete-conflicting-outputs
```

### CI/CD için
```yaml
# .github/workflows/flutter.yml
- name: Generate code
  run: |
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter analyze
```

---

## ✅ Başarı Kriterleri

Code generation başarılı sayılır eğer:

1. ✅ Hiçbir error mesajı yok
2. ✅ Tüm `.freezed.dart` dosyaları oluşturuldu (~10 dosya)
3. ✅ Tüm `.g.dart` dosyaları oluşturuldu (~10 dosya)
4. ✅ `flutter analyze` hiçbir issue bulamadı
5. ✅ `flutter run` çalışıyor
6. ✅ Hot reload/restart çalışıyor

---

## 🚀 Sonraki Adım

Code generation tamamlandıktan sonra:

```powershell
# Uygulamayı çalıştır
flutter run

# Veya VS Code'da
# F5 tuşuna bas
```

**Uygulama başarıyla derlenmeli ve çalışmalı! 🎉**

---

**Hazırlayan:** GitHub Copilot  
**Tarih:** 13 Ekim 2025  
**Durum:** ✅ Code Generation Rehberi Hazır
