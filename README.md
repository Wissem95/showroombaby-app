# 🍼 ShowroomBaby - Marketplace d'articles de bébé d'occasion

## 📋 Description du projet

ShowroomBaby est une marketplace mobile dédiée à la vente d'articles de bébé d'occasion. L'application permet aux parents de vendre et acheter des produits pour bébé en toute sécurité.

### 🏗️ Architecture du projet

```
showroombabyBackend/
├── backend/                 # API Laravel (PHP)
├── showroombaby_mobile/     # Application mobile Flutter
└── README.md               # Ce fichier
```

## 🚀 Installation rapide

### Option 1: Script automatique (Recommandé)

```bash
chmod +x setup.sh
./setup.sh
```

### Option 2: Installation manuelle

Suivez les étapes détaillées ci-dessous.

---

## 🛠️ Prérequis

### Système

- **macOS** (testé sur macOS 14.x)
- **Git** installé
- **Homebrew** installé

### Technologies requises

- **PHP** 8.1+ avec Composer
- **Flutter** 3.6+
- **Node.js** 18+ (optionnel)
- **Xcode** pour iOS (si développement iOS)

---

## 📦 Installation détaillée

### 1. Cloner le projet

```bash
git clone https://github.com/Wissem95/Showroombaby_final.git
cd Showroombaby_final
```

### 2. Installation du Backend Laravel

#### a) Installation de PHP et Composer

```bash
# Installer PHP via Homebrew
brew install php@8.1
brew link php@8.1 --force

# Installer Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

#### b) Configuration du Backend

```bash
cd backend

# Installer les dépendances PHP
composer install

# Copier le fichier d'environnement
cp .env.example .env

# Générer la clé d'application
php artisan key:generate

# Configurer la base de données (SQLite par défaut)
touch database/database.sqlite

# Lancer les migrations
php artisan migrate --seed

# Créer le lien symbolique pour les fichiers
php artisan storage:link
```

### 3. Installation de l'application Flutter

#### a) Installation de Flutter

```bash
# Télécharger Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Ou via Homebrew
brew install --cask flutter
```

#### b) Configuration de l'application mobile

```bash
cd ../showroombaby_mobile

# Installer les dépendances Dart
flutter pub get

# Générer le code (Riverpod, Freezed, etc.)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Vérifier la configuration Flutter
flutter doctor
```

---

## 🚀 Lancement du projet

### 1. Démarrer le serveur Laravel

```bash
cd backend
php artisan serve
```

> Le serveur sera accessible sur `http://localhost:8000`

### 2. Lancer l'application Flutter

#### Pour iOS (Simulateur)

```bash
cd showroombaby_mobile

# Lister les simulateurs disponibles
flutter devices

# Lancer sur un simulateur spécifique
flutter run -d "iPhone 16 Pro"
```

#### Pour Android

```bash
cd showroombaby_mobile
flutter run
```

---

## 🔧 Configuration avancée

### Variables d'environnement Backend (.env)

```env
APP_NAME="ShowroomBaby API"
APP_ENV=local
APP_KEY=base64:VOTRE_CLE_GENEREE
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=sqlite
DB_DATABASE=/chemin/vers/database/database.sqlite

CORS_ALLOWED_ORIGINS="*"
```

### Configuration API Mobile

Fichier: `showroombaby_mobile/lib/app/constants/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  // Pour appareil physique, remplacez par votre IP locale
  // static const String baseUrl = 'http://192.168.1.X:8000/api';
}
```

---

## 📱 Fonctionnalités

### ✅ Fonctionnalités implémentées

- 🔐 **Authentification** (inscription, connexion, token JWT)
- 🏠 **Homepage** avec produits tendance et filtrage par catégories
- 📱 **Navigation** fluide entre les écrans
- 🛍️ **Produits** : liste, détails, images, favoris
- 🔍 **Recherche** et filtrage avancé
- ❤️ **Favoris** avec gestion en temps réel
- 💬 **Messagerie** entre vendeurs et acheteurs
- 👤 **Profil utilisateur** avec statistiques
- 📊 **Catégories** avec compteurs de produits

### 🚧 En développement

- 💰 **Système de paiement**
- 📍 **Géolocalisation** pour recherche locale
- 🔔 **Notifications push**
- 📈 **Analytics** et statistiques vendeur

---

## 🎨 Captures d'écran

### Homepage avec pastilles de filtrage

- Barre de recherche transparente
- Pastilles de catégories cliquables
- Grille de produits avec favoris fonctionnels

### Détails produit

- Carousel d'images
- Informations vendeur
- Boutons contacter/appeler
- Produits similaires

---

## 🛠️ Dépannage

### Problèmes courants

#### 1. Erreur "Command not found: php"

```bash
brew install php@8.1
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### 2. Erreur Flutter "No devices found"

```bash
# Pour iOS
open -a Simulator

# Vérifier les appareils
flutter devices
```

#### 3. Erreur de base de données Laravel

```bash
cd backend
rm database/database.sqlite
touch database/database.sqlite
php artisan migrate:fresh --seed
```

#### 4. Erreur de génération de code Flutter

```bash
cd showroombaby_mobile
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 5. Erreur CORS ou API non accessible

- Vérifiez que le serveur Laravel est démarré sur `http://localhost:8000`
- Pour tester sur appareil physique, remplacez `localhost` par votre IP locale dans `api_constants.dart`

---

## 📚 Structure du code

### Backend Laravel

```
backend/
├── app/
│   ├── Http/Controllers/Api/    # Contrôleurs API
│   ├── Models/                  # Modèles Eloquent
│   └── Providers/              # Service providers
├── database/
│   ├── migrations/             # Migrations DB
│   └── seeders/               # Données de test
└── routes/api.php             # Routes API
```

### Frontend Flutter

```
showroombaby_mobile/
├── lib/
│   ├── core/
│   │   ├── models/            # Modèles de données
│   │   ├── providers/         # Providers Riverpod
│   │   └── services/          # Services API
│   ├── features/
│   │   ├── auth/             # Authentification
│   │   ├── home/             # Page d'accueil
│   │   ├── products/         # Produits
│   │   └── ...               # Autres fonctionnalités
│   └── shared/widgets/       # Widgets partagés
```

---

## 🤝 Contribution

### Pour contribuer au projet :

1. Fork le repository
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changes (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

---

## 📞 Support

### Contacts

- **Développeur principal** : Wissem
- **Email** : wissemkarboubbb@gmail.com

### Ressources utiles

- [Documentation Laravel](https://laravel.com/docs)
- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation Riverpod](https://riverpod.dev/)

---

## 📄 Licence

Ce projet est sous licence privée. Tous droits réservés.

---

## ⚡ Quick Start (TL;DR)

```bash
# 1. Cloner et installer
git clone https://github.com/Wissem95/Showroombaby_final.git
cd Showroombaby_final
chmod +x setup.sh && ./setup.sh

# 2. Lancer le backend
cd backend && php artisan serve

# 3. Lancer l'app mobile (nouveau terminal)
cd showroombaby_mobile && flutter run
```

🎉 **Voilà ! L'application devrait maintenant fonctionner parfaitement !**
