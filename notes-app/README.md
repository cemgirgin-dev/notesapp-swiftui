# 📝 Notes App  
### Full-Stack Not Uygulaması (SwiftUI + FastAPI + WidgetKit)

---

## 🇹🇷 Türkçe Açıklama

### 🚀 Genel Bakış
**Notes App**, SwiftUI ile geliştirilen modern, reaktif ve modüler bir not alma uygulamasıdır.  
Uygulama, **FastAPI tabanlı bir backend** ile iletişim kurarak kullanıcı kimlik doğrulaması, not oluşturma, düzenleme, silme ve listeleme işlemlerini yönetir.  
Ayrıca **WidgetKit entegrasyonu** sayesinde son üç not, iOS ana ekranında dinamik olarak görüntülenebilir.

---

### ⚙️ Teknik Özellikler

| Katman | Teknoloji | Açıklama |
|:--|:--|:--|
| **Frontend (iOS)** | SwiftUI, Combine | Tamamen SwiftUI ile yazılmış, MVVM + Clean Architecture yapısında |
| **Backend** | FastAPI (Python) | JWT kimlik doğrulama, SQLite veritabanı, bcrypt şifreleme |
| **Mimari** | MVVM + Clean Architecture | `Presentation`, `Domain`, `Data` katmanları ayrılmıştır |
| **Bağımlılık Yönetimi** | Custom Dependency Injection | `AppContainer` tüm bağımlılıkları yönetir |
| **Widget** | WidgetKit | App Group ile paylaşılan cache üzerinden son notları gösterir |
| **Veri Paylaşımı** | App Group + UserDefaults | `WidgetCacheStore` App ile Widget arasında veri köprüsü sağlar |
| **Güvenlik** | Keychain | Kullanıcı token’ı güvenli biçimde saklanır |
| **Logging** | Custom Network Logger | API istekleri ve yanıtları konsola loglanır |

---

### 📁 Proje Yapısı

```plaintext
notes-app/
│
├── App/
│   └── NotesCleanApp.swift
│
├── Data/
│   ├── Networking/         # APIClient, hata yönetimi, logger
│   ├── DTOs/               # Backend veri modelleri
│   ├── Repositories/       # Auth ve Notes repository implementasyonları
│   └── UseCasesImpl/       # UseCase implementasyonları
│
├── Domain/
│   ├── Entities/           # Note, User gibi domain modelleri
│   └── UseCases/           # UseCase protokolleri
│
├── Presentation/
│   ├── ViewModels/         # AuthViewModel, NotesViewModel
│   └── Views/              # SwiftUI ekranları
│
├── Shared/
│   ├── AppConstants.swift
│   ├── AppContainer.swift
│   ├── WidgetCache.swift
│   └── KeychainStore.swift
│
└── Widget/
    ├── NotesWidget.swift
    └── NotesWidgetBundle.swift
```

---

### 🔄 Çalışma Akışı
1. Kullanıcı **Sign Up / Sign In** işlemini yapar. Token `Keychain`’de saklanır.  
2. Kullanıcı bir not oluşturduğunda veya düzenlediğinde:
   - Backend’e gönderilir.
   - `WidgetCacheStore.save()` ile App Group’a yazılır.
3. `WidgetCenter.reloadAllTimelines()` çağrısıyla widget güncellenir.  
4. Widget, `WidgetCache` içeriğini okuyarak son 3 notu gösterir.

---

### 🧠 Mimari Özellikler
- Clean Architecture prensipleri uygulanmıştır.  
- `@MainActor` ile thread-safe ViewModel yapısı.  
- Custom `APIClient` loglama ve hata yönetimi sağlar.  
- WidgetKit ve App Group entegrasyonu tam uyumludur.  
- Reactive Combine yapısı ile hızlı UI güncellemeleri.

---

### 📦 Backend (FastAPI)
**Auth Endpoint’leri:**
```bash
POST /auth/signup
POST /auth/login
GET  /auth/me
```

**Notes Endpoint’leri:**
```bash
GET    /notes/
POST   /notes/
PUT    /notes/{id}/
DELETE /notes/{id}/
```

JWT tabanlı kimlik doğrulama ve `bcrypt` ile parola güvenliği sağlanır.

---

### 🔐 App Group Ayarları
Uygulama ve Widget aynı App Group kimliğini paylaşmalıdır:

```
group.cemgirgin.notes-app
```

Her iki target’ta da **Signing & Capabilities → App Groups** kısmında aktif olmalıdır.

---

### 🧰 Çalıştırma
#### Backend
```bash
uvicorn app.main:app --reload --port 8000
```

#### iOS Uygulaması
Xcode → **Run (Cmd + R)**

---

## 🇬🇧 English Description

### 🚀 Overview
**Notes App** is a full-stack note-taking application built with **SwiftUI** and a **FastAPI backend**.  
It supports secure authentication, CRUD operations for notes, and a **WidgetKit extension** that dynamically displays the last three notes on the iOS Home Screen.

---

### ⚙️ Technical Overview

| Layer | Technology | Description |
|:--|:--|:--|
| **Frontend (iOS)** | SwiftUI, Combine | Built entirely with SwiftUI using MVVM + Clean Architecture |
| **Backend** | FastAPI (Python) | JWT authentication, SQLite database, bcrypt password hashing |
| **Architecture** | MVVM + Clean Architecture | Separate `Presentation`, `Domain`, and `Data` layers |
| **Dependency Injection** | Custom DI Container | `AppContainer` resolves all repositories and use cases |
| **Widget** | WidgetKit | Displays last 3 notes using App Group shared cache |
| **Data Sharing** | App Group + UserDefaults | `WidgetCacheStore` bridges App and Widget |
| **Security** | Keychain | Stores JWT tokens securely |
| **Logging** | Custom API Logger | All HTTP requests and responses logged to console |

---

### 📁 Project Structure

```plaintext
App/
 └── NotesCleanApp.swift

Data/
 ├── Networking/
 ├── DTOs/
 ├── Repositories/
 └── UseCasesImpl/

Domain/
 ├── Entities/
 └── UseCases/

Presentation/
 ├── ViewModels/
 └── Views/

Shared/
 ├── AppConstants.swift
 ├── AppContainer.swift
 ├── WidgetCache.swift
 └── KeychainStore.swift

Widget/
 ├── NotesWidget.swift
 └── NotesWidgetBundle.swift
```

---

### 🔄 Workflow
1. User signs in — token saved to **Keychain**.  
2. When a note is created or updated:
   - Request sent to backend.
   - Data cached in App Group via `WidgetCacheStore.save()`.  
3. **WidgetCenter.reloadAllTimelines()** triggers widget refresh.  
4. Widget displays the last 3 notes from cache.

---

### 🧠 Architectural Highlights
- Strict **Clean Architecture** with independent layers.  
- `@MainActor` ViewModels ensure thread safety.  
- Custom `APIClient` with advanced logging.  
- WidgetKit integration with App Group data sharing.  
- Reactive UI with Combine and async/await.

---

### 🧰 Backend API
```bash
POST /auth/signup
POST /auth/login
GET  /auth/me
GET  /notes/
POST /notes/
PUT  /notes/{id}/
DELETE /notes/{id}/
```

---

### 🔐 App Group Configuration
Ensure both **App** and **Widget Extension** share:
```
group.cemgirgin.notes-app
```
in *Signing & Capabilities → App Groups*.

---

### 🧩 Tech Stack Summary
- **SwiftUI / Combine / WidgetKit**
- **FastAPI / Python / SQLite / JWT / bcrypt**
- **MVVM + Clean Architecture**
- **App Group Data Sharing**
- **Secure Authentication with Keychain**

---

### 🧰 Run Commands
```bash
# Start FastAPI backend
uvicorn app.main:app --reload --port 8000

# Run iOS app in Xcode
Cmd + R
```

---

## 📸 Developer Note
> The app and widget are fully integrated.  
> The widget automatically updates after every note change.  
> If App Group IDs mismatch, logs will show `WidgetCache: no data`.
