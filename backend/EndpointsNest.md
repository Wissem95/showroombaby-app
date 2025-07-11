# API Backend Showroom Baby - Documentation Complète

## Table des matières

1. [Authentification](#1-authentification)

2. [Produits](#2-produits)

3. [Catégories](#3-catégories)

4. [Utilisateurs](#4-utilisateurs)

5. [Messages](#5-messages)

6. [Notifications](#6-notifications)

7. [Favoris](#7-favoris)

8. [Signalements](#8-signalements)

9. [Mode Hors-ligne](#9-mode-hors-ligne)

10. [Monitoring](#10-monitoring)

11. [Structure des Données](#11-structure-des-données)

12. [Variables d'Environnement](#12-variables-denvironnement)

13. [Scripts Utiles](#13-scripts-utiles)

## 1. Authentification

### Endpoints d'Authentification

```typescript

POST /auth/register

- Inscription d'un nouvel utilisateur

- Corps: { email, password, username, role }

- Retourne: { user: { id, email, firstName, lastName, address }, message }



POST /auth/login

- Connexion utilisateur

- Corps: { email, password }

- Retourne: { access_token, message }

```

## 2. Produits

### Endpoints des Produits

```typescript

GET /products

- Liste des produits avec filtres

- Paramètres:

- categoryId: Filtre par catégorie

- minPrice: Prix minimum

- maxPrice: Prix maximum

- condition: État du produit ('NEW' | 'LIKE_NEW' | 'GOOD' | 'FAIR')

- latitude, longitude, radius: Recherche géographique

- query: Recherche textuelle

- sortBy: 'price' | 'date' | 'views' | 'distance'

- page: Numéro de page

- limit: Nombre d'éléments par page

- Retourne: { items: Product[], total, page, limit, totalPages }

```

### Endpoints de Création

```typescript

POST /products

- Création d'un produit (authentification requise)

- Format: multipart/form-data

- Champs:

- title: string

- description: string

- price: number

- condition: 'NEW' | 'LIKE_NEW' | 'GOOD' | 'FAIR'

- categoryId: string

- images: File[]

- latitude: number

- longitude: number

- address: string

- city: string

- zipCode: string

- phone: string

```

### Endpoints de Recherche

```typescript

GET /products/trending

- Produits tendances

- Paramètres:

- limit: Nombre de produits (défaut: 10)

- Retourne: { items: Product[], total, page, limit, totalPages }



GET /products/:id

- Détails d'un produit

- Incrémente automatiquement le viewCount

- Retourne: ProductDetailDto



GET /products/:id/similar

- Produits similaires basés sur la catégorie

- Limite: 4 produits

- Retourne: Product[]

```

### Endpoints de Modification

```typescript

PUT /products/:id

- Mise à jour d'un produit (authentification requise)

- Même format que la création



DELETE /products/:id

- Suppression d'un produit (authentification requise)

```

## 3. Catégories

### Endpoints des Catégories

```typescript

GET /categories

- Liste toutes les catégories

- Retourne: Category[]



POST /categories

- Création d'une catégorie (admin uniquement)

- Corps: { name, description }



PUT /categories/:id

- Mise à jour d'une catégorie (admin uniquement)

- Corps: { name, description }



DELETE /categories/:id

- Suppression d'une catégorie (admin uniquement)

```

## 4. Utilisateurs

### Endpoints des Utilisateurs

```typescript

GET /users/profile

- Profil de l'utilisateur connecté

- Retourne: User (sans password)



PUT /users/profile

- Mise à jour du profil

- Corps: { firstName, lastName, username, avatar }



POST /users/change-password

- Changement de mot de passe

- Corps: { oldPassword, newPassword }



DELETE /users/account

- Suppression du compte utilisateur

```

## 5. Messages

### Endpoints des Messages

```typescript

POST /messages

- Envoi d'un message

- Corps: { recipientId, content, productId? }



GET /messages/conversations

- Liste des conversations

- Paramètres: { page, limit }



GET /messages/conversations/archived

- Liste des conversations archivées

- Paramètres: { page, limit }



GET /messages/conversation/:userId

- Messages d'une conversation

- Paramètres: { page, limit }



POST /messages/:id/read

- Marquer un message comme lu



POST /messages/:id/archive

- Archiver un message



POST /messages/conversation/:userId/archive

- Archiver une conversation



POST /messages/conversation/:userId/unarchive

- Désarchiver une conversation

```

## 6. Notifications

### Endpoints des Notifications

```typescript

GET /notifications

- Liste des notifications

- Paramètres: { page, limit }



GET /notifications/unread

- Notifications non lues



GET /notifications/count/unread

- Nombre de notifications non lues



GET /notifications/type/:type

- Notifications par type

- Types: 'message' | 'product' | 'system' | 'favorite' | 'report'



POST /notifications/:id/read

- Marquer une notification comme lue



POST /notifications/read/all

- Marquer toutes les notifications comme lues



POST /notifications/:id/archive

- Archiver une notification



DELETE /notifications/:id

- Supprimer une notification

```

## 7. Favoris

### Endpoints des Favoris

```typescript

POST /favorites/:productId

- Ajouter un produit aux favoris



DELETE /favorites/:productId

- Retirer un produit des favoris



GET /favorites

- Liste des favoris



GET /favorites/:id

- Détails d'un favori

```

## 8. Signalements

### Endpoints des Signalements

```typescript

POST /reports

- Signaler un produit

- Corps: {

productId: string,

reason: 'inappropriate' | 'fake' | 'offensive' | 'spam' | 'other',

description: string

}

```

## 9. Mode Hors-ligne

### Endpoints de Synchronisation

```typescript

POST /offline/sync

- Synchronisation des opérations hors-ligne

- Corps: {

entityType: string,

entityId: string,

operation: 'create' | 'update' | 'delete',

data: any

}

```

## 10. Monitoring

### Endpoints de Monitoring

```typescript

GET /monitoring/health

- Vérification de la santé de l'application



GET /monitoring/metrics

- Métriques de l'application (authentification requise)

```

## 11. Structure des Données

### Modèle Product

```typescript

{

id: string;

title: string;

description: string;

price: number;

condition: 'NEW' | 'LIKE_NEW' | 'GOOD' | 'FAIR';

status: 'DRAFT' | 'PUBLISHED' | 'SOLD' | 'ARCHIVED';

images: ProductImage[];

seller: User;

category: Category;

viewCount: number;

latitude?: number;

longitude?: number;

address?: string;

city?: string;

zipCode?: string;

phone?: string;

createdAt: Date;

updatedAt: Date;

}

```

### Modèle Category

```typescript

{

id: string;

name: string;

description: string;

products: Product[];

createdAt: Date;

updatedAt: Date;

}

```

### Modèle User

```typescript

{

id: string;

email: string;

firstName?: string;

lastName?: string;

avatar?: string;

avatarUrl?: string;

name?: string;

username?: string;

rating: number;

role: 'USER' | 'ADMIN';

isEmailVerified: boolean;

address?: {

street: string;

city: string;

zipCode: string;

country: string;

};

createdAt: Date;

updatedAt: Date;

}

```

### Modèle Message

```typescript

{

id: string;

content: string;

senderId: string;

recipientId: string;

productId?: string;

read: boolean;

archivedBySender: boolean;

archivedByRecipient: boolean;

createdAt: Date;

updatedAt: Date;

}

```

### Modèle Notification

```typescript

{

id: string;

type: 'message' | 'product' | 'system' | 'favorite' | 'report';

title: string;

message: string;

metadata?: Record<string, any>;

status: 'unread' | 'read' | 'archived';

userId: string;

createdAt: Date;

updatedAt: Date;

}

```

### Modèle Report

```typescript

{

id: string;

reporterId: string;

productId: string;

reason: 'inappropriate' | 'fake' | 'offensive' | 'spam' | 'other';

description: string;

status: 'pending' | 'reviewed' | 'resolved' | 'rejected';

moderationNote?: string;

createdAt: Date;

updatedAt: Date;

}

```

## 12. Variables d'Environnement

```env

# Database

DATABASE_HOST=localhost

DATABASE_PORT=5432

DATABASE_NAME=showroom_baby

DATABASE_USER=postgres

DATABASE_PASSWORD=postgres



# JWT

JWT_SECRET=your_jwt_secret

JWT_EXPIRATION=24h



# Server

PORT=3000

NODE_ENV=development



# Admin

ADMIN_EMAIL=admin@showroom.com

ADMIN_PASSWORD=Admin123!

```

## 13. Scripts Utiles

```bash

# Reset de la base de données

./reset-db.sh



# Création des catégories

./seed-categories.sh



# Création des produits de test

./seed-products.sh

```
