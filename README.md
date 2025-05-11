

# 🎬 Projet de Base de Données de Streaming

## 📜 Introduction

Ce projet vise à créer une base de données pour une plateforme de streaming. La base de données est conçue pour gérer les utilisateurs, les streams, les interactions entre utilisateurs, les publicités, les abonnements, les points de chaîne, et bien plus encore.

## 📚 Table des Matières

1. [Introduction](#introduction)
2. [Table des Matières](#table-des-matières)
3. [Fonctionnalités](#fonctionnalités)
4. [Structure de la Base de Données](#structure-de-la-base-de-données)
   - [Modèle Conceptuel de Données (MCD)](#modèle-conceptuel-de-données-mcd)
   - [Modèle Logique de Données (MLD)](#modèle-logique-de-données-mld)
5. [Installation](#installation)
6. [Utilisation](#utilisation)
7. [Contribution](#contribution)
8. [Licence](#licence)

## 🚀 Fonctionnalités

- 👥 Gestion des utilisateurs et de leurs profils.
- 🎥 Gestion des streams et des catégories.
- 💰 Système de dons et d'abonnements.
- 📢 Gestion des publicités et des campagnes publicitaires.
- 🏆 Système de points de chaîne et de récompenses.
- 🛡️ Modération des chats et des utilisateurs.
- 🔍 Suivi des interactions entre utilisateurs (suivis, signalements, bannissements).
- 📊 Analyses des streams et des performances.

## 🗄️ Structure de la Base de Données

### Modèle Conceptuel de Données (MCD)

Le MCD représente les entités et leurs relations sans se soucier des détails techniques de la base de données. Voici une représentation simplifiée :

- **Entités Principales** :
  - **Donations** : Enregistre les dons effectués par les utilisateurs aux streamers.
  - **Ads** : Enregistre les publicités diffusées pendant les streams.
  - **Moderators** : Enregistre les modérateurs associés aux streamers.
  - **Reports** : Enregistre les signalements effectués par les utilisateurs.
  - **Bans** : Enregistre les bannissements effectués par les modérateurs.
  - **Chats** : Enregistre les messages de chat pendant les streams.
  - **Emotes** : Enregistre les emotes créés par les utilisateurs.
  - **Categories** : Enregistre les catégories de streams.
  - **Tags** : Enregistre les tags associés aux streams.
  - **Followers** : Enregistre les abonnements entre utilisateurs.
  - **Advertising_Campaigns** : Enregistre les campagnes publicitaires.
  - **Stream_Advertisements** : Enregistre les publicités diffusées pendant les streams.
  - **Channel_Moderation_Actions** : Enregistre les actions de modération effectuées par les modérateurs.
  - **Subscriptions_Tiers** : Enregistre les niveaux d'abonnement.
  - **Channel_Points** : Enregistre les points de chaîne gagnés par les utilisateurs.
  - **Channel_Points_Rewards** : Enregistre les récompenses associées aux points de chaîne.
  - **Channel_Points_Redemptions** : Enregistre les échanges de récompenses par les utilisateurs.
  - **Stream_Categories_History** : Enregistre l'historique des catégories de streams.
  - **Stream_Chat_Bans** : Enregistre les bannissements de chat pendant les streams.
  - **Stream_Events** : Enregistre les événements pendant les streams.
  - **Achievements_1** : Enregistre les exploits réalisés par les utilisateurs.
  - **User_achievements_1** : Enregistre les exploits obtenus par les utilisateurs.
  - **Notifications_1** : Enregistre les notifications envoyées aux utilisateurs.
  - **Roles_1** : Enregistre les rôles et leurs permissions.
  - **Payments_1** : Enregistre les paiements effectués par les utilisateurs.
  - **Stream_tags_1** : Enregistre les tags associés aux streams.
  - **Poll_Options** : Enregistre les options de sondage.
  - **User_Notifications_** : Enregistre les notifications lues par les utilisateurs.
  - **RaidLogs** : Enregistre les logs de raids.
  - **PasswordResets** : Enregistre les demandes de réinitialisation de mot de passe.
  - **LoginAttempts** : Enregistre les tentatives de connexion des utilisateurs.
  - **UserReports** : Enregistre les signalements effectués par les utilisateurs.
  - **Subscriptions** : Enregistre les abonnements des utilisateurs aux streamers.
  - **Tag_Subscriptions** : Enregistre les abonnements des utilisateurs aux tags.
  - **Users** : Enregistre les informations des utilisateurs.
  - **Stream_Raids** : Enregistre les raids effectués sur les streams.
  - **Users_sessions_1** : Enregistre les sessions des utilisateurs.
  - **Users_preferences_1** : Enregistre les préférences des utilisateurs.
  - **User_device** : Enregistre les appareils utilisés par les utilisateurs.
  - **SupportTickets_** : Enregistre les tickets de support créés par les utilisateurs.
  - **AdViews_** : Enregistre les vues des publicités par les utilisateurs.
  - **Streams** : Enregistre les streams.
  - **VODs** : Enregistre les VODs associées aux streams.
  - **Clips** : Enregistre les clips créés à partir des streams.
  - **Polls** : Enregistre les sondages associés aux streams.
  - **StreamAnalytics_** : Enregistre les analyses des streams.

### Modèle Logique de Données (MLD)

Le MLD représente les tables et leurs relations dans la base de données. Voici une représentation simplifiée :

- **Tables Principales** :
  - **Donations** : id_donation (PK), user_id_, streamer_id, amount, date_creation, message
  - **Ads** : id_ad (PK), stream_id, advertiser_name, ad_start_time, ad_end_time, ad_duration, date_creation
  - **Moderators** : id_moderator (PK), streamer_id, date_creation, role_id
  - **Reports** : id_report (PK), reporter_id_, reported_user_id, report_reason, date_creation, status
  - **Bans** : id_ban (PK), user_id, moderator_id, user_id_1, ban_reason, date_creation, is_permanent
  - **Chats** : id_chat (PK), stream_id, user_id, message, date_creation
  - **Emotes** : id_emote (PK), name, image_url, user_id, is_global
  - **Categories** : id_category (PK), name, description, image_url
  - **Tags** : id_tag (PK), name, description
  - **Followers** : id_follower (PK), follower_user_id, date_creation, followed_user_id
  - **Advertising_Campaigns** : id_campaign (PK), start_date, end_date, budget, date_creation
  - **Stream_Advertisements** : id_stream_ad (PK), stream_id, campaign_id, ad_start_time, ad_end_time, date_creation
  - **Channel_Moderation_Actions** : id_mod_action (PK), moderator_id, user_id, action_type, action_reason, date_creation
  - **Subscriptions_Tiers** : id_tier (PK), s_t_name, price
  - **Channel_Points** : id_points (PK), user_id, streamer_id, points_amonts, date_creation
  - **Channel_Points_Rewards** : id_reward (PK), streamer_id, reward_name, points_required, is_active
  - **Channel_Points_Redemptions** : id_redemption (PK), reward_id, date_creation, status, user_id
  - **Stream_Categories_History** : id_category_history (PK), stream_id, strat_time, end_time, category_id, date_creation
  - **Stream_Chat_Bans** : id_chat_ban (PK), user_id, moderator_id, stream_id, ban_reason, date_creation, is_temporary, ban_duration
  - **Stream_Events** : id_event (PK), stream_id, event_type, event_user_id, date_creation
  - **Achievements_1** : id_achievments (PK), description_, Points, name
  - **User_achievements_1** : id_Users_achievements (PK), user_id, achievement_id, date_creation
  - **Notifications_1** : id_notification (PK), user_id, notification_type, message, is_read
  - **Roles_1** : id_role (PK), role_name, permissions
  - **Payments_1** : id_payment (PK), user_id, payment_method, amount, date_creation, subscription_id
  - **Stream_tags_1** : id_stream_tag (PK), stream_id, tag_id
  - **Poll_Options** : id_option (PK), poll_id, option_text, _vote_count
  - **User_Notifications_** : id_notification_log (PK), id_user, id_notification, read_status, _notification_timestamp, user_id, notification_id
  - **RaidLogs** : id_raid_log (PK), id_raid, id_user, raid_timestamp, raid_id, user_id
  - **PasswordResets** : id_reset (PK), id_user, request_time_, reset_token, token_expiration_, user_id
  - **LoginAttempts** : id_attempt (PK), id_user, attempt_time_, success, ip_address_, user_id
  - **UserReports** : id_reports (PK), id_reported_user, id_reporting_user, report_reason_, report_date, report_status, user_id
  - **Subscriptions** : id_subscription (PK), user_id, streamer_id, subscription_tier, subscription_date, is_active, tier_id, date_creation, id_tier
  - **Tag_Subscriptions** : id_tag_subscription (PK), user_id_, tag_id, date_creation, id_tag
  - **Users** : id_user (PK), username, email, password, date_of_creation, role, ptofile_picture, is_verified, id_follower, id_chat_ban
  - **Stream_Raids** : id_raid (PK), stream_id, target_stream_id, id_user
  - **Users_sessions_1** : id_session (PK), user_id, login_time, logout_time, ip_adress, date_creation, id_user
  - **Users_preferences_1** : id_preference (PK), user_id, preference_type, valeur, id_user
  - **User_device** : id_device (PK), user_id, device_type, device_os, date_creation, id_user
  - **SupportTickets_** : id_ticket (PK), id_user, subject, description_, status_, created_at_, updated_at_, user_id, id_user_1
  - **AdViews_** : id_ad_view (PK), ad_id, user_id, view_timestamp, id_user
  - **Streams** : id_stream (PK), user_id, category_id, title, start_time, end_time, is_live, view_count, date_creation, id_chat, id_raid, id_category_history, id_user
  - **VODs** : id_vod (PK), stream_id, title, date_creation, id_stream
  - **Clips** : id_clip (PK), user_id, stream_id, title, date_creation, clip_url, view_count, id_stream
  - **Polls** : id_poll (PK), stream_id, question_, date_creation, is_active, id_stream
  - **StreamAnalytics_** : id_analytics (PK), stream_id, total_viewers_, peak_viewers, stream_duration_, id_stream

## 🛠️ Installation

Pour installer et configurer la base de données, suivez ces étapes :

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/votre-utilisateur/votre-depot.git
   cd votre-depot
   ```

2. **Installer les dépendances** :
   - Assurez-vous d'avoir MySQL installé sur votre machine.
   - Créez une nouvelle base de données :
     ```sql
     CREATE DATABASE streaming_platform;
     ```

3. **Exécuter le script SQL** :
   - Importez le script SQL fourni dans le dépôt pour créer les tables et les relations :
     ```bash
     mysql -u votre_utilisateur -p streaming_platform < script.sql
     ```

## 📊 Utilisation

- **Connexion à la base de données** :
  - Utilisez un client MySQL comme MySQL Workbench ou phpMyAdmin pour vous connecter à la base de données.
  - Exécutez des requêtes SQL pour insérer, mettre à jour, ou supprimer des données.

- **Exemples de requêtes** :
  - Insérer un nouvel utilisateur :
    ```sql
    INSERT INTO Users (username, email, password, date_of_creation, role, ptofile_picture, is_verified)
    VALUES ('utilisateur1', 'utilisateur1@example.com', 'motdepasse', NOW(), 1, 'url_image', TRUE);
    ```
  - Récupérer tous les streams d'un utilisateur :
    ```sql
    SELECT * FROM Streams WHERE user_id = 1;
    ```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le dépôt.
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/nouvelle-fonctionnalite`).
3. Commitez vos modifications (`git commit -m 'Ajout d'une nouvelle fonctionnalité'`).
4. Poussez vers la branche (`git push origin feature/nouvelle-fonctionnalite`).
5. Ouvrez une Pull Request.

## 📜 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

N'hésitez pas à adapter ce README selon vos besoins spécifiques et à ajouter des sections supplémentaires si nécessaire. Les icônes et la mise en forme améliorent la lisibilité et rendent le document plus attrayant visuellement.
