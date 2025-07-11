#!/bin/bash

# 🍼 Script d'installation automatique ShowroomBaby
# Auteur: Wissem
# Description: Installation complète du projet (Backend Laravel + Frontend Flutter)

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Fonction d'affichage stylisé
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Vérification du système
check_system() {
    print_header "🔍 Vérification du système"
    
    # Vérifier macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "Ce script est conçu pour macOS. Adaptations nécessaires pour autres OS."
        exit 1
    fi
    
    # Vérifier Git
    if ! command -v git &> /dev/null; then
        print_error "Git n'est pas installé. Installez-le avec: xcode-select --install"
        exit 1
    fi
    
    # Vérifier Homebrew
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew n'est pas installé. Installation..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    print_success "Système vérifié ✅"
}

# Installation de PHP et Composer
install_php() {
    print_header "🐘 Installation de PHP 8.1 et Composer"
    
    # Installer PHP 8.1
    if ! command -v php &> /dev/null; then
        print_status "Installation de PHP 8.1..."
        brew install php@8.1
        brew link php@8.1 --force
        
        # Ajouter PHP au PATH
        echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
        echo 'export PATH="/opt/homebrew/sbin:$PATH"' >> ~/.zshrc
        source ~/.zshrc
    else
        print_success "PHP déjà installé: $(php --version | head -n1)"
    fi
    
    # Installer Composer
    if ! command -v composer &> /dev/null; then
        print_status "Installation de Composer..."
        curl -sS https://getcomposer.org/installer | php
        sudo mv composer.phar /usr/local/bin/composer
        sudo chmod +x /usr/local/bin/composer
    else
        print_success "Composer déjà installé: $(composer --version)"
    fi
    
    print_success "PHP et Composer installés ✅"
}

# Installation de Flutter
install_flutter() {
    print_header "🦋 Installation de Flutter"
    
    if ! command -v flutter &> /dev/null; then
        print_status "Installation de Flutter via Homebrew..."
        brew install --cask flutter
        
        # Ajouter Flutter au PATH
        echo 'export PATH="$PATH:/Applications/flutter/bin"' >> ~/.zshrc
        source ~/.zshrc
    else
        print_success "Flutter déjà installé: $(flutter --version | head -n1)"
    fi
    
    # Accepter les licences Android
    print_status "Configuration de Flutter..."
    flutter doctor --android-licenses || true
    
    print_success "Flutter installé ✅"
}

# Configuration du backend Laravel
setup_backend() {
    print_header "⚙️ Configuration du Backend Laravel"
    
    cd backend
    
    # Installer les dépendances PHP
    print_status "Installation des dépendances PHP..."
    composer install --no-interaction
    
    # Copier le fichier .env
    if [ ! -f .env ]; then
        print_status "Copie du fichier d'environnement..."
        cp .env.example .env
    fi
    
    # Générer la clé d'application
    print_status "Génération de la clé d'application..."
    php artisan key:generate --force
    
    # Créer la base de données SQLite
    if [ ! -f database/database.sqlite ]; then
        print_status "Création de la base de données SQLite..."
        touch database/database.sqlite
    fi
    
    # Lancer les migrations et seeders
    print_status "Exécution des migrations et seeders..."
    php artisan migrate:fresh --seed --force
    
    # Créer le lien symbolique pour le storage
    print_status "Création du lien symbolique pour les fichiers..."
    php artisan storage:link
    
    # Optimiser les performances
    print_status "Optimisation des performances..."
    php artisan config:cache
    php artisan route:cache
    
    cd ..
    print_success "Backend Laravel configuré ✅"
}

# Configuration de l'application Flutter
setup_flutter() {
    print_header "📱 Configuration de l'application Flutter"
    
    cd showroombaby_mobile
    
    # Installer les dépendances Dart
    print_status "Installation des dépendances Dart..."
    flutter pub get
    
    # Générer le code automatique
    print_status "Génération du code automatique (Riverpod, Freezed, etc.)..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    # Nettoyer le cache
    print_status "Nettoyage du cache Flutter..."
    flutter clean
    flutter pub get
    
    cd ..
    print_success "Application Flutter configurée ✅"
}

# Créer des scripts de lancement
create_launch_scripts() {
    print_header "🚀 Création des scripts de lancement"
    
    # Script pour lancer le backend
    cat > start-backend.sh << 'EOF'
#!/bin/bash
echo "🚀 Démarrage du serveur Laravel..."
cd backend
php artisan serve --host=0.0.0.0 --port=8000
EOF
    chmod +x start-backend.sh
    
    # Script pour lancer l'app mobile
    cat > start-mobile.sh << 'EOF'
#!/bin/bash
echo "📱 Démarrage de l'application Flutter..."
cd showroombaby_mobile
flutter run
EOF
    chmod +x start-mobile.sh
    
    # Script pour lancer en mode développement
    cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🛠️ Mode développement - Lancement backend + mobile"

# Lancer le backend en arrière-plan
echo "🚀 Démarrage du backend..."
cd backend
php artisan serve --host=0.0.0.0 --port=8000 &
BACKEND_PID=$!

# Attendre que le backend soit prêt
sleep 5

# Lancer l'application mobile
echo "📱 Démarrage de l'application mobile..."
cd ../showroombaby_mobile
flutter run

# Arrêter le backend quand l'app mobile s'arrête
kill $BACKEND_PID
EOF
    chmod +x start-dev.sh
    
    print_success "Scripts de lancement créés ✅"
}

# Tests de fonctionnement
run_tests() {
    print_header "🧪 Tests de fonctionnement"
    
    # Test API Laravel
    print_status "Test de l'API Laravel..."
    cd backend
    php artisan test --filter=ApiTest || print_warning "Certains tests ont échoué"
    cd ..
    
    # Test Flutter
    print_status "Test de l'application Flutter..."
    cd showroombaby_mobile
    flutter test || print_warning "Certains tests Flutter ont échoué"
    cd ..
    
    print_success "Tests terminés ✅"
}

# Affichage final avec instructions
show_final_instructions() {
    print_header "🎉 Installation terminée avec succès !"
    
    echo ""
    echo -e "${GREEN}┌──────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│           SHOWROOMBABY EST PRÊT !            │${NC}"
    echo -e "${GREEN}└──────────────────────────────────────────────┘${NC}"
    echo ""
    
    echo -e "${YELLOW}📋 Prochaines étapes :${NC}"
    echo ""
    echo -e "${BLUE}1. Lancer le backend :${NC}"
    echo "   ./start-backend.sh"
    echo "   ou: cd backend && php artisan serve"
    echo ""
    echo -e "${BLUE}2. Lancer l'app mobile (nouveau terminal) :${NC}"
    echo "   ./start-mobile.sh" 
    echo "   ou: cd showroombaby_mobile && flutter run"
    echo ""
    echo -e "${BLUE}3. Mode développement (tout en un) :${NC}"
    echo "   ./start-dev.sh"
    echo ""
    
    echo -e "${YELLOW}🔗 URLs importantes :${NC}"
    echo "   • API Backend: http://localhost:8000"
    echo "   • Documentation API: http://localhost:8000/api/documentation"
    echo ""
    
    echo -e "${YELLOW}📱 Appareils de test :${NC}"
    echo "   • iOS Simulateur: iPhone 16 Pro"
    echo "   • Android: flutter devices"
    echo ""
    
    echo -e "${YELLOW}🛠️ Commandes utiles :${NC}"
    echo "   • Reset DB: cd backend && php artisan migrate:fresh --seed"
    echo "   • Regenerate code: cd showroombaby_mobile && flutter packages pub run build_runner build --delete-conflicting-outputs"
    echo "   • Clean Flutter: cd showroombaby_mobile && flutter clean && flutter pub get"
    echo ""
    
    echo -e "${GREEN}✨ Bon développement ! ✨${NC}"
}

# Script principal
main() {
    print_header "🍼 Installation ShowroomBaby - Marketplace d'articles de bébé"
    
    echo -e "${BLUE}Ce script va installer et configurer :${NC}"
    echo "• Backend Laravel avec API"
    echo "• Application mobile Flutter"
    echo "• Base de données avec données de test"
    echo "• Scripts de lancement automatiques"
    echo ""
    
    read -p "Continuer l'installation ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation annulée."
        exit 1
    fi
    
    # Exécution des étapes
    check_system
    install_php
    install_flutter
    setup_backend
    setup_flutter
    create_launch_scripts
    run_tests
    show_final_instructions
}

# Gestion des erreurs
trap 'print_error "Une erreur est survenue. Installation interrompue."' ERR

# Lancer le script principal
main "$@" 