# 🎮 Plateforme Twitch - Architecture Microservices

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)

> Une plateforme de streaming vidéo inspirée de Twitch, construite avec une architecture microservices moderne, incluant une stack complète d'observabilité.

## 📋 Table des Matières

- [Vue d'Ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Démarrage Rapide](#-démarrage-rapide)
- [Services](#-services)
- [Monitoring](#-monitoring)
- [Documentation](#-documentation)
- [Technologies](#-technologies)

## 🎯 Vue d'Ensemble

Ce projet démontre une architecture microservices complète pour une plateforme de streaming, avec :

- ✅ **5 microservices indépendants** avec bases de données séparées
- ✅ **Stack d'observabilité complète** (Prometheus, Grafana, AlertManager)
- ✅ **Scalabilité horizontale** - Chaque service peut être scalé indépendamment
- ✅ **Haute disponibilité** - Résilience et isolation des pannes
- ✅ **Monitoring temps réel** - Métriques, dashboards et alertes

### 🎨 Fonctionnalités

- 👥 **Gestion des utilisateurs** - Authentification, profils, followers
- 📺 **Streaming en direct** - Gestion des streams, catégories, VODs
- 💬 **Chat en temps réel** - Messages, emotes, modération
- 💰 **Système d'abonnements** - Tiers, donations, points de chaîne
- 📊 **Analytics** - Statistiques détaillées et métriques de performance

## 🏗️ Architecture

### Microservices

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Users     │  │   Streams   │  │    Chat     │  │Subscriptions│  │  Analytics  │
│   Service   │  │   Service   │  │   Service   │  │   Service   │  │   Service   │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │                │                │
       ▼                ▼                ▼                ▼                ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  users_db   │  │ streams_db  │  │   chat_db   │  │  subs_db    │  │analytics_db │
│ Port: 5432  │  │ Port: 5433  │  │ Port: 5434  │  │ Port: 5435  │  │ Port: 5436  │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘
```

### Stack d'Observabilité

```
┌──────────────────────────────────────────────────────────┐
│                     Grafana (Port 3000)                  │
│              Dashboards & Visualisation                  │
└────────────────────────┬─────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────┐
│                  Prometheus (Port 9090)                   │
│              Collecte & Stockage Métriques                │
└─────┬──────────┬──────────┬──────────┬──────────┬────────┘
      │          │          │          │          │
      ▼          ▼          ▼          ▼          ▼
  [PG Exp]   [PG Exp]   [PG Exp]   [Redis]   [Node Exp]
  Users DB   Streams    Chat DB    Exporter   System
```

## 🚀 Démarrage Rapide

### Prérequis

- Docker 20.10+
- Docker Compose 2.0+
- 8GB RAM minimum
- 20GB espace disque

### Installation

```bash
# Cloner le repository
git clone https://github.com/votre-username/ProjetTwitch.git
cd ProjetTwitch

# Copier la configuration
cp .env.example .env

# Démarrer tous les services
./start.sh

# OU manuellement
docker compose up -d
```

### Vérification

```bash
# Vérifier l'état des services
./check-status.sh

# Voir les logs
docker compose logs -f
```

### Accès aux Interfaces

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **Prometheus** | http://localhost:9090 | - |
| **AlertManager** | http://localhost:9093 | - |
| **cAdvisor** | http://localhost:8080 | - |

## 🔧 Services

### 1. Users Service (Port 5432)
Gestion complète des utilisateurs et authentification.

**Tables principales** :
- `users` - Profils utilisateurs
- `followers` - Relations de suivi
- `user_roles` - Système de permissions
- `user_settings` - Préférences utilisateur

### 2. Streams Service (Port 5433)
Gestion des streams en direct et VODs.

**Tables principales** :
- `streams` - Streams en direct
- `categories` - Catégories de contenu
- `vods` - Vidéos à la demande
- `clips` - Extraits de streams

### 3. Chat Service (Port 5434)
Système de chat en temps réel avec modération.

**Tables principales** :
- `chat_messages` - Messages du chat
- `emotes` - Emotes personnalisées
- `chat_moderators` - Modérateurs
- `banned_users` - Utilisateurs bannis

### 4. Subscriptions Service (Port 5435)
Gestion des abonnements et monétisation.

**Tables principales** :
- `subscriptions` - Abonnements actifs
- `subscription_tiers` - Niveaux d'abonnement
- `donations` - Dons
- `channel_points` - Points de chaîne

### 5. Analytics Service (Port 5436)
Collecte et analyse des métriques.

**Tables principales** :
- `stream_analytics` - Statistiques de streams
- `user_analytics` - Métriques utilisateurs
- `revenue_analytics` - Analyses financières

## 📊 Monitoring

### Dashboards Grafana Préconfigurés

#### 1. PostgreSQL Microservices
- État des 5 bases de données
- Connexions actives par base
- Transactions/seconde
- Cache Hit Ratio
- Opérations INSERT/UPDATE/DELETE

#### 2. Système & Infrastructure
- CPU et Memory Usage
- Conteneurs Docker actifs
- Métriques Redis
- État de tous les services

### Métriques Clés

```promql
# État des bases
pg_up

# Connexions actives
pg_stat_database_numbackends

# Cache Hit Ratio (doit être >95%)
rate(pg_stat_database_blks_hit[5m]) / 
(rate(pg_stat_database_blks_hit[5m]) + rate(pg_stat_database_blks_read[5m]))

# Transactions par seconde
rate(pg_stat_database_xact_commit[5m])
```

### Alertes Configurées

- ⚠️ Base de données DOWN
- ⚠️ CPU > 80%
- ⚠️ Mémoire > 85%
- ⚠️ Connexions PostgreSQL > 80%
- ⚠️ Cache Hit Ratio < 90%
- ⚠️ Espace disque < 15%

## 📚 Documentation

La documentation complète est disponible au format LaTeX dans le dossier `docs/`.

### Guides Disponibles

- 📖 **Documentation Complète** - `docs/documentation.pdf`
- 🏗️ **Guide Architecture** - Architecture détaillée des microservices
- 🚀 **Guide de Déploiement** - Instructions de déploiement
- 🔧 **Guide de Dépannage** - Résolution des problèmes courants
- 📊 **Guide Grafana** - Configuration des dashboards

### Fichiers Markdown (Référence)

- `MICROSERVICES_GUIDE.md` - Pourquoi cette architecture
- `AUDIT_REPORT.md` - Audit du schéma SQL original
- `TROUBLESHOOTING.md` - Dépannage
- `GRAFANA_SETUP.md` - Configuration Grafana

## 🛠️ Technologies

### Backend & Bases de Données
- **PostgreSQL 15** - Base de données relationnelle
- **Redis 7** - Cache et sessions
- **Docker & Docker Compose** - Conteneurisation

### Monitoring & Observabilité
- **Prometheus** - Collecte de métriques
- **Grafana** - Visualisation et dashboards
- **AlertManager** - Gestion des alertes
- **PostgreSQL Exporter** - Métriques PostgreSQL
- **Redis Exporter** - Métriques Redis
- **Node Exporter** - Métriques système
- **cAdvisor** - Métriques conteneurs

### Infrastructure
- **NGINX** - API Gateway et reverse proxy
- **Docker Networks** - Isolation réseau

## 🔄 Commandes Utiles

```bash
# Démarrer tous les services
./start.sh

# Vérifier l'état
./check-status.sh

# Tester les bases de données
./test-databases.sh

# Corriger Prometheus
./fix-prometheus.sh

# Voir les logs
docker compose logs -f [service]

# Redémarrer un service
docker compose restart [service]

# Arrêter tout
docker compose down

# Arrêter et supprimer les volumes (⚠️ perte de données)
docker compose down -v
```

## 📈 Performance

### Scalabilité

Chaque service peut être scalé indépendamment :

```bash
# Scaler le service Chat (haute charge)
docker compose up -d --scale chat-db=3

# Scaler le service Streams
docker compose up -d --scale streams-db=2
```

### Optimisations

- ✅ Index sur toutes les clés étrangères
- ✅ Vues matérialisées pour les requêtes complexes
- ✅ Connection pooling (PgBouncer recommandé en production)
- ✅ Cache Redis pour les données fréquemment accédées
- ✅ Triggers pour `updated_at` automatique

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👤 Auteur

**Falilou**

- GitHub: [@Falilou2099](https://github.com/Falilou2099)
- LinkedIn: [Votre LinkedIn](https://linkedin.com/in/votre-profil)

## 🙏 Remerciements

- Architecture inspirée des best practices de Netflix, Uber et Spotify
- Documentation basée sur les recommandations de Martin Fowler
- Stack d'observabilité inspirée de SRE Google

---

⭐ **Si ce projet vous a aidé, n'hésitez pas à lui donner une étoile !**

📖 **Pour la documentation complète, consultez `docs/documentation.pdf`**
