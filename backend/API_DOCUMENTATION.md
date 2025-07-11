# Documentation API ShowroomBaby

## Table des matières

-   [Authentification](#authentification)
-   [Produits](#produits)
-   [Messages](#messages)
-   [Notifications](#notifications)
-   [Favoris](#favoris)
-   [Catégories](#catégories)
-   [Utilisateurs](#utilisateurs)
-   [Signalements](#signalements)
-   [Monitoring](#monitoring)

## Authentification

### Inscription

```http
POST /api/auth/register
Content-Type: application/json

{
    "email": "string",
    "password": "string",
    "username": "string"
}

Réponse: 201 Created
{
    "user": {
        "id": number,
        "email": "string",
        "username": "string"
    },
    "message": "string"
}
```

### Connexion

```http
POST /api/auth/login
Content-Type: application/json

{
    "email": "string",
    "password": "string"
}

Réponse: 200 OK
{
    "access_token": "string",
    "message": "string",
    "user": {
        "id": number,
        "email": "string",
        "username": "string"
    }
}
```

### Déconnexion

```http
POST /api/auth/logout
Authorization: Bearer {token}

Réponse: 200 OK
{
    "message": "string"
}
```

## Produits

### Liste des produits

```http
GET /api/products
Query params:
- page: number
- limit: number
- categoryId?: number
- minPrice?: number
- maxPrice?: number
- query?: string

Réponse: 200 OK
{
    "data": [
        {
            "id": number,
            "title": "string",
            "description": "string",
            "price": number,
            "images": string[],
            "category": {...},
            "user": {...},
            "created_at": "datetime"
        }
    ],
    "meta": {
        "current_page": number,
        "last_page": number,
        "per_page": number,
        "total": number
    }
}
```

### Créer un produit

```http
POST /api/products
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
    "title": "string",
    "description": "string",
    "price": number,
    "category_id": number,
    "images[]": File
}

Réponse: 201 Created
```

### Détails d'un produit

```http
GET /api/products/{id}

Réponse: 200 OK
{
    "data": {
        "id": number,
        "title": "string",
        "description": "string",
        "price": number,
        "images": string[],
        "category": {...},
        "user": {...},
        "created_at": "datetime"
    }
}
```

### Produits similaires

```http
GET /api/products/{id}/similar

Réponse: 200 OK
{
    "data": [...]
}
```

### Produits tendance

```http
GET /api/products/trending

Réponse: 200 OK
{
    "data": [...]
}
```

## Messages

### Envoyer un message

```http
POST /api/messages
Authorization: Bearer {token}
Content-Type: application/json

{
    "recipientId": number,
    "content": "string",
    "productId": number (optionnel)
}

Réponse: 201 Created
```

### Liste des conversations

```http
GET /api/messages/conversations
Authorization: Bearer {token}
Query params:
- page: number
- limit: number

Réponse: 200 OK
{
    "data": [...],
    "meta": {
        "current_page": number,
        "last_page": number,
        "per_page": number,
        "total": number
    }
}
```

### Messages d'une conversation

```http
GET /api/messages/conversation/{userId}
Authorization: Bearer {token}
Query params:
- page: number
- limit: number

Réponse: 200 OK
{
    "data": [...],
    "meta": {...}
}
```

### Compteur messages non lus

```http
GET /api/messages/unread/count
Authorization: Bearer {token}

Réponse: 200 OK
{
    "count": number
}
```

### Actions sur les messages

```http
POST /api/messages/{id}/read
POST /api/messages/{id}/archive
POST /api/messages/conversation/{userId}/archive
POST /api/messages/conversation/{userId}/unarchive
Authorization: Bearer {token}

Réponse: 200 OK
```

## Notifications

### Liste des notifications

```http
GET /api/notifications
Authorization: Bearer {token}
Query params:
- page: number
- limit: number

Réponse: 200 OK
{
    "data": [...],
    "meta": {...}
}
```

### Notifications non lues

```http
GET /api/notifications/unread
GET /api/notifications/count/unread
Authorization: Bearer {token}

Réponse: 200 OK
```

### Actions sur les notifications

```http
POST /api/notifications/{id}/read
POST /api/notifications/read/all
POST /api/notifications/{id}/archive
DELETE /api/notifications/{id}
Authorization: Bearer {token}

Réponse: 200 OK
```

## Favoris

### Gérer les favoris

```http
POST /api/favorites/{productId}
DELETE /api/favorites/{productId}
GET /api/favorites
GET /api/favorites/{id}
Authorization: Bearer {token}

Réponse: 200 OK
```

## Catégories

### Liste des catégories

```http
GET /api/categories

Réponse: 200 OK
{
    "data": [
        {
            "id": number,
            "name": "string",
            "description": "string"
        }
    ]
}
```

### Actions admin sur les catégories

```http
POST /api/categories
PUT /api/categories/{id}
DELETE /api/categories/{id}
Authorization: Bearer {token} (Admin only)

Réponse: 200 OK
```

## Utilisateurs

### Profil

```http
GET /api/users/profile
PUT /api/users/profile
Authorization: Bearer {token}

Réponse: 200 OK
{
    "data": {
        "id": number,
        "email": "string",
        "username": "string",
        "avatar": "string",
        ...
    }
}
```

### Gestion du compte

```http
POST /api/users/change-password
DELETE /api/users/account
Authorization: Bearer {token}

Réponse: 200 OK
```

## Signalements

### Créer un signalement

```http
POST /api/reports
Authorization: Bearer {token}
Content-Type: application/json

{
    "productId": number,
    "reason": "inappropriate" | "fake" | "offensive" | "spam" | "other",
    "description": "string"
}

Réponse: 201 Created
```

## Monitoring

### État de l'application

```http
GET /api/monitoring/health

Réponse: 200 OK
{
    "status": "healthy"
}
```

### Métriques (Admin)

```http
GET /api/monitoring/metrics
Authorization: Bearer {token}

Réponse: 200 OK
```

## Notes importantes

1. Authentification

-   Tous les endpoints protégés nécessitent un token Bearer dans le header
-   Format: `Authorization: Bearer {votre_token}`

2. Pagination

-   La plupart des endpoints de liste supportent la pagination
-   Paramètres: `page` et `limit`
-   Retourne un objet `meta` avec les informations de pagination

3. Codes d'erreur

-   400: Requête invalide
-   401: Non authentifié
-   403: Non autorisé
-   404: Ressource non trouvée
-   422: Erreur de validation
-   500: Erreur serveur

4. Format des dates

-   Toutes les dates sont au format ISO 8601
-   Exemple: "2024-03-15T14:30:00Z"
