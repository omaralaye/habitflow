# HabitFlow 🌿

HabitFlow is a gamified habit tracking application built with Flutter, designed to help users build lasting habits through AI-driven insights, mascot-led motivation, and an immersive focus environment.

## 🚀 Features

- **AI Habit Refiner**: Automatically optimizes habit names and suggests categories using OpenAI's GPT-4o-mini.
- **Mascot Personalities**: Seven unique AI mascot personalities (Panda, Penguin, Koala, Fox, Cat, Dog, Bear) that provide personalized encouragement and insights.
- **Focus Hub**: A dedicated space for deep work, featuring integrated music from the 'Free To Use Music' API and AI-generated pep talks.
- **Gamification**: Earn XP and level up as you complete habits. Track your global rank and reach new milestones.
- **Smart Reminders**: Customizable start and end reminders for each habit to keep you on track.
- **Detailed Analytics**: Visualize your progress with streak statistics and weekly completion history.
- **Multi-user Support**: Secure authentication and data isolation powered by Supabase.
- **Adaptive UI**: Beautiful, responsive design with support for both Light and Dark modes.

## 🛠 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/) (Dart)
- **Backend/Auth**: [Supabase](https://supabase.com/)
- **AI Integration**: [OpenAI API](https://openai.com/) (GPT-4o-mini)
- **State Management**: Reactive Streams (Supabase)
- **Notifications**: `flutter_local_notifications`
- **Audio**: `just_audio`
- **External APIs**: [Free To Use Music API](https://freetouse.com/)

## 📂 Project Structure

```text
lib/
├── models/         # Data models (Habit, Profile, Music, etc.)
├── screens/        # UI Screens (Home, Focus Hub, Habit Detail, etc.)
├── services/       # Business logic & API integrations (Auth, DB, AI, Music)
├── utils/          # Constants, helpers, and themes
├── widgets/        # Reusable UI components
└── main.dart       # Application entry point
```

## 🏁 Getting Started

### Prerequisites

- Flutter SDK (v3.11.0 or higher)
- A Supabase project
- An OpenAI API key

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/habitflow.git
    cd habitflow
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Environment:**
    Update `lib/utils/constants.dart` with your Supabase credentials and OpenAI API key.

4.  **Database Setup:**
    Execute the SQL commands in `supabase_schema.sql` within your Supabase SQL editor to set up the necessary tables, triggers, and RLS policies.

5.  **Run the app:**
    ```bash
    flutter run
    ```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
