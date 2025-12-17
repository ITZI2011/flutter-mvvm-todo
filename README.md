# Todo Provider
Imane Touraity
Développement Flutter, architecture MVVM, Provider, UI


## 📱 Aperçu de l’application

Application mobile Flutter de gestion de tâches (Todo List) développée en respectant l’architecture **MVVM** et utilisant le package **Provider** pour la gestion d’état.



---

## 📝 Description

**Todo Provider** est une application simple et efficace permettant à un utilisateur de :
- Créer des tâches
- Marquer une tâche comme complétée
- Supprimer des tâches
- Visualiser la liste des tâches en temps réel

###  Objectifs
- Appliquer correctement le pattern **MVVM**
- Séparer clairement l’interface utilisateur de la logique métier
- Utiliser **Provider** comme solution de gestion d’état

###  Public cible
- Étudiants en développement mobile
- Débutants/intermédiaires Flutter souhaitant comprendre MVVM

---

##  Architecture MVVM

L’application suit le pattern **MVVM (Model – View – ViewModel)**.

### 🔹 Structure des dossiers
lib/
├── models/ → Modèles de données (Todo, etc.)
├── providers/ → ViewModels (logique + état avec Provider)
├── screens/ → Vues principales (écrans)
├── widgets/ → Widgets réutilisables (UI)
├── services/ → Services externes (notifications, storage, etc.)
└── main.dart → Point d’entrée de l’application

## Communication entre les composants
- Les **Views** (`screens`, `widgets`) écoutent les **Providers**
- Les **Providers** gèrent l’état et la logique métier
- Les **Models** représentent les données
- `notifyListeners()` permet de mettre à jour l’UI automatiquement
## ⚙️ Installation et lancement

### Prérequis
- Flutter SDK
- Dart SDK
- Android Studio / VS Code

### Commandes
```bash
flutter pub get
flutter run


Fonctionnement de l’application
Utilisation

L’utilisateur ajoute une nouvelle tâche

La tâche apparaît dans la liste

Il peut aussi :

Marquer la tâche comme terminée
ou 
Supprimer la tâche

Navigation:

Un écran principal affichant la liste des tâches

Interactions dynamiques via Provider

Technologies utilisées
Flutter
Dart

Packages Flutter

1.provider : gestion d’état (MVVM)
2.flutter/material.dart