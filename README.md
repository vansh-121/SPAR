<div align="center">

<img src="Spar_App/assets/images/spar.png" alt="SPAR Logo" width="140" height="140" />

# SPAR — Smart Portfolio & Asset Returns

### Institution-grade investment tools, built for everyone.

<br/>

[![Website](https://img.shields.io/badge/🌐_Website-rise.nutribasket.in-0A84FF?style=for-the-badge)](https://rise.nutribasket.in)
[![Admin Panel](https://img.shields.io/badge/🛠️_Admin_Panel-rise.nutribasket.in/admin-6C47FF?style=for-the-badge)](https://rise.nutribasket.in/admin)
[![Play Store](https://img.shields.io/badge/Google_Play-Download_Now-34A853?logo=google-play&logoColor=white&style=for-the-badge)](https://play.google.com/store/apps/details?id=com.rise.investor)

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-PHP-FF2D20?logo=laravel&logoColor=white)](https://laravel.com)
[![Firebase](https://img.shields.io/badge/Firebase-Powered-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql&logoColor=white)](https://mysql.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#license)

</div>

---

## Table of Contents

- [About](#about)
- [Live Links](#-live-links)
- [Platform Overview](#platform-overview)
- [Mobile App](#-mobile-app--spar_app)
  - [Features](#key-features)
  - [Interest Calculations](#interest-calculation-methods)
  - [Tech Stack](#tech-stack)
  - [Project Layout](#project-layout-lib)
  - [Setup Guide](#getting-started-flutter-app)
- [Admin Panel](#-admin-panel--spar_admin_panel)
  - [Capabilities](#admin-capabilities)
  - [Tech Stack](#tech-stack-1)
  - [Setup Guide](#getting-started-admin-panel)
- [Architecture](#architecture)
- [Security](#security)
- [Why SPAR?](#why-spar)
- [Download](#download)
- [Developer](#developer)
- [License](#license)

---

## About

**SPAR** (Smart Portfolio & Asset Returns) is a full-stack, production-grade investment management platform developed by **Hedge And Sachs**. It brings institution-level financial tooling to everyday investors through a polished Flutter mobile app backed by a powerful Laravel API and admin dashboard.

SPAR enables investors to discover plans, deposit funds, track real-time portfolio performance, earn through referrals and staking, and compete on global leaderboards — all within a single, secure application.

> Designed and built from scratch by **Vansh** for **Hedge And Sachs**.

---

## 🔗 Live Links

| Resource | URL |
|---|---|
| 🌐 **Web App** | [https://rise.nutribasket.in](https://rise.nutribasket.in) |
| 🛠️ **Admin Panel** | [https://rise.nutribasket.in/admin](https://rise.nutribasket.in/admin) |
| 📱 **Android App (Play Store)** | [com.rise.investor](https://play.google.com/store/apps/details?id=com.rise.investor) |

---

## Platform Overview

SPAR is composed of two tightly integrated components:

```
SPAR/
├── Spar_App/           # Cross-platform Flutter mobile application
│   ├── Android (deployed to Google Play Store)
│   └── iOS (ready for App Store)
│
└── Spar_admin_panel/   # Laravel backend, REST API & admin dashboard
    ├── public-facing web frontend
    └── admin management dashboard
```

---

## 📱 Mobile App — `Spar_App`

The SPAR mobile app is built with Flutter and targets both Android and iOS. It communicates with the Laravel backend via a REST API and uses Firebase for real-time push notifications and authentication.

### Key Features

| Feature | Description |
|---|---|
| 🎯 **Multiple Investment Plans** | Browse and invest in diverse plans — each with configurable duration, return rate, and interest type |
| 💰 **Deposits & Withdrawals** | Secure, multi-gateway fund transfers with real-time status tracking |
| 📊 **Portfolio Analytics** | Live charts, ROI summaries, and detailed performance breakdowns |
| 🏆 **Global Rankings** | Leaderboard system letting you see how your portfolio stacks up worldwide |
| 🤝 **Referral Program** | Multi-level referral engine with automated reward distribution |
| 💎 **Staking & Pools** | Exclusive investment pools offering passive income and compound returns |
| 📅 **Investment Schedules** | Plan and automate future deposits with scheduled investment options |
| 🎟️ **Ticket Support** | In-app 24/7 support ticketing system with full conversation threading |
| 🌐 **Multi-Language** | Full localization support for a global user base |
| 🔒 **Two-Factor Authentication** | TOTP-based 2FA for hardened account security |
| 🔔 **Push Notifications** | Firebase-powered real-time alerts for transactions, plans, and admin broadcasts |
| 📄 **PDF Reports** | Generate and download investment reports and transaction statements |
| 🐣 **Onboarding Flow** | Guided onboarding experience for new investors |
| 🔗 **Deep Linking** | App links for seamless navigation from web and notifications |

---

### Interest Calculation Methods

SPAR supports two configurable interest models per investment plan:

#### Simple Interest
```
Interest Amount  = (Principal × Rate) / 100
Total Return     = Principal + Interest Amount
```
*Example: $1,000 at 10% → Interest = $100 → Total = $1,100*

#### Compound Interest
```
Annual Rate (%) = [(1 + monthlyRate / 100)^12 - 1] × 100
```
*Example: 2% monthly → Annual ≈ 26.82% effective annual return*

> Full implementation details, formulas, and Dart code samples are documented in [`Spar_App/INTEREST_CALCULATION_DOCS.md`](Spar_App/INTEREST_CALCULATION_DOCS.md).

---

### Tech Stack

| Category | Library / Technology | Version |
|---|---|---|
| Framework | Flutter + Dart | `>=3.0.6` |
| State Management | GetX | `^4.7.2` |
| HTTP Client | Dio | `^5.8.0` |
| Auth | Firebase Auth + Google Sign-In | Latest |
| Push Notifications | Firebase Messaging + Local Notifications | Latest |
| Charts | FL Chart | `^0.69.0` |
| PDF | `pdf` + `printing` | `^3.10.7` / `^5.12.0` |
| Deep Linking | App Links | `^6.4.1` |
| WebView | Flutter InAppWebView | `^6.1.5` |
| Local Storage | Shared Preferences | `^2.5.2` |
| Connectivity | Connectivity Plus | `^6.1.3` |
| Image / File Picker | image_picker + file_picker | Latest |
| UI | Google Fonts + Shimmer + Lottie | Latest |
| Form Validation | pin_code_fields + awesome_dialog | Latest |

### Project Layout (`lib/`)

```
lib/
├── core/
│   ├── routes/             # Named route definitions
│   ├── constants/          # App-wide constants
│   └── utils/              # Helpers and extensions
│
├── data/
│   ├── controller/         # GetX controllers (business logic per feature)
│   │   ├── auth/
│   │   ├── investment/
│   │   ├── staking/
│   │   ├── deposit/
│   │   ├── withdraw/
│   │   ├── referral/
│   │   └── ...
│   ├── model/              # JSON-serializable data models
│   └── services/           # API service layer (Dio)
│
├── view/
│   ├── components/         # Reusable widgets (buttons, cards, dialogs)
│   └── screens/
│       ├── auth/               # Login · Register · Forgot Password
│       ├── onboard/            # Onboarding carousel
│       ├── splash_screen/      # Splash & deep-link routing
│       ├── bottom_nav_screens/ # Main navigation shell (Home/Dashboard)
│       ├── investment/         # Plan listing & investment flow
│       ├── staking/            # Staking pools & stake creation
│       ├── deposit/            # Deposit via multiple gateways
│       ├── withdraw/           # Withdrawal requests & history
│       ├── referral/           # Referral tree & earnings
│       ├── ranking/            # Global investor leaderboard
│       ├── schedule/           # Scheduled investment management
│       ├── pool/               # Investment pool details
│       ├── ticket/             # Support ticket creation & chat
│       ├── transaction-history/# Full transaction log
│       ├── transfer/           # Internal wallet transfers
│       ├── account/            # Profile, KYC, settings
│       ├── two_factor_screen/  # 2FA setup & verification
│       ├── language/           # Language switcher
│       └── faq/                # FAQs
│
├── environment.dart        # Base URL, environment flags
├── firebase_options.dart   # Firebase project configuration
└── main.dart               # App entry point & initialization
```

### Getting Started (Flutter App)

#### Prerequisites

- Flutter SDK `>=3.0.6` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.0.6 <4.0.0`
- Android Studio (for Android) or Xcode (for iOS)
- A configured Firebase project

#### Step-by-Step Setup

```bash
# 1. Clone the repository
git clone https://github.com/vansh-121/SPAR.git
cd SPAR/Spar_App

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Firebase
#    a) Create a Firebase project at https://console.firebase.google.com
#    b) Enable Authentication (Email/Password + Google)
#    c) Enable Cloud Messaging
#    d) Download and place:
#       - google-services.json        →  android/app/
#       - GoogleService-Info.plist    →  ios/Runner/
#    e) Copy the options file:
cp lib/firebase_options.dart.example lib/firebase_options.dart
#    f) Fill in your Firebase config values in firebase_options.dart

# 4. Set the API base URL
#    Edit lib/environment.dart and set your backend URL:
#    static const String baseUrl = 'https://rise.nutribasket.in';

# 5. Run on a connected device or emulator
flutter run
```

#### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## 🛠️ Admin Panel — `Spar_admin_panel`

A full-featured Laravel backend serving the REST API for the mobile app, along with a comprehensive admin dashboard for complete platform management.

- **Web App:** [https://rise.nutribasket.in](https://rise.nutribasket.in)
- **Admin Dashboard:** [https://rise.nutribasket.in/admin](https://rise.nutribasket.in/admin)

### Admin Capabilities

| Module | What You Can Do |
|---|---|
| 👥 **User Management** | View all investors, verify identities, manage accounts, ban/unban users |
| 📋 **Investment Plans** | Create, edit, activate/deactivate plans with full rate & duration control |
| 💎 **Staking & Pools** | Manage staking options, pool capacities, and participation limits |
| 💳 **Deposits** | Review, approve, or reject manual deposit requests with audit trail |
| 💸 **Withdrawals** | Process withdrawal requests, set limits, manage payment gateways |
| 📈 **Analytics** | Platform-wide financial reporting — revenue, AUM, user growth |
| 🏆 **Rankings** | Manage leaderboard rules and investor tier configurations |
| 🤝 **Referral Engine** | Configure multi-level referral commission structures |
| 📅 **Schedules** | Oversee investor-created investment schedules |
| 🔔 **Push Notifications** | Broadcast targeted push notifications to all or segmented users |
| 🌍 **Multi-language** | Add new languages, edit translation strings, toggle availability |
| 🎨 **Templates & Themes** | Switch between multiple pre-built frontend templates |
| 🛡️ **KYC Verification** | Review uploaded identity documents and approve/reject verifications |
| 🎟️ **Support Tickets** | Full ticket management — view, reply, close, and escalate tickets |
| 🌐 **SEO Settings** | Manage meta titles, descriptions, and Open Graph tags |
| ⚙️ **System Config** | Site settings, maintenance mode, email config, gateway credentials |
| 📝 **CMS / Pages** | Manage Terms, Privacy Policy, FAQ, and other static pages |

### Tech Stack

| Layer | Technology |
|---|---|
| Framework | Laravel (PHP `>=8.1`) |
| Database | MySQL |
| ORM | Eloquent |
| API | RESTful JSON API (consumed by Flutter app) |
| Authentication | Laravel Sanctum / Session + 2FA |
| Real-time Notifications | Firebase Cloud Messaging |
| Frontend (Admin) | Blade Templates + Bootstrap |
| Frontend (Web) | Multiple template themes (HTML/CSS/JS) |
| Payment Gateways | Multiple gateway integrations (automatic + manual) |
| File Storage | Local / S3-compatible storage |
| Scheduling | Laravel Task Scheduler (Cron) |

### Getting Started (Admin Panel)

#### Prerequisites

- PHP `>=8.1` with extensions: `mbstring`, `openssl`, `pdo_mysql`, `tokenizer`, `xml`, `ctype`, `json`
- [Composer](https://getcomposer.org/)
- MySQL `>=5.7` or MariaDB `>=10.3`
- Node.js `>=16` & npm
- A web server (Apache / Nginx) or `php artisan serve` for local dev

#### Step-by-Step Setup

```bash
# 1. Navigate to the Laravel core
cd SPAR/Spar_admin_panel/core

# 2. Install PHP dependencies
composer install --optimize-autoloader --no-dev

# 3. Install and compile frontend assets
npm install
npm run dev          # development
# npm run build      # production

# 4. Create the environment file
cp .env.example .env
php artisan key:generate

# 5. Configure your .env
#    Set the following values:
#      APP_URL=https://rise.nutribasket.in
#      DB_HOST, DB_DATABASE, DB_USERNAME, DB_PASSWORD
#      MAIL_* settings
#      Firebase credentials (for push notifications)

# 6. Run database migrations and seed initial data
php artisan migrate --seed

# 7. Create the storage symlink for public file access
php artisan storage:link

# 8. Set correct folder permissions
chmod -R 775 storage bootstrap/cache

# 9. (Optional) Start the local dev server
php artisan serve --port=8000
# Visit: http://localhost:8000/admin
```

#### Production Deployment Recommendations

```bash
# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set up the scheduler (add to server crontab)
* * * * * cd /path/to/core && php artisan schedule:run >> /dev/null 2>&1

# Set up queues for async jobs
php artisan queue:work --daemon
```

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  SPAR Platform                      │
│                                                     │
│  ┌──────────────┐        ┌──────────────────────┐   │
│  │  Flutter App │◄──────►│   Laravel REST API   │   │
│  │  (Mobile)    │  HTTPS │  rise.nutribasket.in │   │
│  └──────┬───────┘        └──────────┬───────────┘   │
│         │                           │               │
│         │ Firebase SDK              │ Eloquent ORM  │
│         ▼                           ▼               │
│  ┌──────────────┐        ┌──────────────────────┐   │
│  │   Firebase   │        │       MySQL DB        │   │
│  │  (Auth/FCM)  │        │  (Users, Plans, Txns) │   │
│  └──────────────┘        └──────────────────────┘   │
│                                    │               │
│                          ┌─────────▼────────────┐   │
│                          │    Admin Dashboard    │   │
│                          │  /admin (Web Panel)   │   │
│                          └──────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Communication Flow:**
1. Flutter app authenticates via Firebase → Laravel validates Firebase token
2. All API calls go to `https://rise.nutribasket.in` over HTTPS
3. Admin panel communicates directly with the database via Eloquent
4. Firebase Cloud Messaging handles all push notifications (triggered from admin panel or Laravel events)

---

## Security

SPAR is built with security-first engineering practices:

| Measure | Implementation |
|---|---|
| **Data Encryption** | All data encrypted in transit via TLS/SSL |
| **Authentication** | Firebase-backed auth with server-side token validation |
| **2FA** | TOTP-based two-factor authentication (optional, user-controlled) |
| **Admin Protection** | Separate admin routes with role-based access control |
| **Input Validation** | Server-side validation on all API endpoints via Laravel Form Requests |
| **Rate Limiting** | API throttling to prevent brute-force and abuse |
| **Data Deletion** | Users can request full account and data deletion |
| **KYC Verification** | Document-based identity verification before high-limit transactions |
| **Audit Trail** | Full transaction and admin action logs |

---

## Why SPAR?

| | |
|---|---|
| ✅ **Secure** | Enterprise-grade Firebase + Laravel infrastructure with end-to-end encryption |
| ✅ **Transparent** | Every transaction, return, and fee is logged and visible in real-time |
| ✅ **Scalable** | Architecture supports growing user bases without infrastructure overhaul |
| ✅ **Community-Driven** | Global rankings, referral trees, and shared investment pools |
| ✅ **User-Friendly** | Clean, intuitive UI designed for investors of all experience levels |
| ✅ **Flexible** | Multiple interest models, plan types, and configurable gateway support |
| ✅ **Full-Stack** | One repository — mobile app + backend + admin panel, fully integrated |

---

## Download

<div align="center">

<br/>

**Available now on Google Play**

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get it on Google Play" height="90">](https://play.google.com/store/apps/details?id=com.rise.investor)

<br/>

*Package ID: `com.rise.investor`*

</div>

---

## Developer

<div align="center">

Designed and built by **Vansh**, for **Hedge And Sachs**

| | |
|---|---|
| 👨‍💻 **Developer** | Vansh |
| 🏢 **Client / Company** | Hedge And Sachs |
| 🌐 **Platform** | [https://rise.nutribasket.in](https://rise.nutribasket.in) |
| 📱 **App** | [Google Play Store](https://play.google.com/store/apps/details?id=com.rise.investor) |
| 🛠️ **Admin** | [https://rise.nutribasket.in/admin](https://rise.nutribasket.in/admin) |

</div>

---

## License

```
Copyright © 2025 Vansh. All rights reserved.
Developed for Hedge And Sachs.

This software and its source code are proprietary and confidential.
Unauthorized copying, forking, distribution, modification, or use
of this software, in whole or in part, without express written
permission is strictly prohibited.
```

---

<div align="center">

Made with ❤️ by **Vansh** for **Hedge And Sachs**

[Website](https://rise.nutribasket.in) · [Play Store](https://play.google.com/store/apps/details?id=com.rise.investor) · [Admin Panel](https://rise.nutribasket.in/admin)

</div>
