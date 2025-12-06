# Happynance - Employee Well-Being AI Evaluation App

A comprehensive mobile application that evaluates employee well-being through a short questionnaire and uses AI to generate clear diagnostic reports with scores, risks, and personalized recommendations.

##  Features

### Employee Features
- **Quick Survey**: 10-15 question well-being assessment
- **AI Analysis**: Powered by Google Gemini AI for intelligent insights
- **Clear Results**: Visual scores for stress, satisfaction, motivation, work-life balance, and burnout risk
- **Personalized Recommendations**: Actionable advice based on individual responses
- **Survey History**: Track progress over time
- **PDF Export**: Save and share results

### Admin Features (HR/Management)
- **Question Management**: CRUD operations for survey questions
- **Anonymous Statistics**: Global insights without identifying individuals
- **AI Configuration**: Adjust analysis parameters
- **Response Monitoring**: Track survey completion rates

## 🛠 Tech Stack

### Backend (Laravel API)
- **Framework**: Laravel 8.75
- **PHP**: 7.3+ / 8.0
- **Authentication**: OAuth2 (Laravel Passport)
- **Database**: MySQL
- **AI Integration**: Google Gemini AI API
- **Security**: Token-based authentication

### Mobile App (Flutter)
- **Framework**: Flutter 3.3.3
- **State Management**: GetX
- **Architecture**: MVC pattern
- **Storage**: flutter_securestorage for tokens
- **Charts**: fl_chart for visualizations
- **PDF Generation**: pdf package

##  Prerequisites

Before running this project, make sure you have:

- **PHP 7.3+** or **8.0+** with Composer
- **MySQL**database
- **Flutter SDK 3.38.4**
- **Android Studio** / **Xcode** for mobile development
- **Google Gemini API Key**

##  Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd happyNation
```

### 2. Backend Setup (Laravel API)

#### Install Dependencies

```bash
cd backend
composer install
```

#### Environment Configuration

```bash
# Copy the environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

#### Configure Environment Variables

Edit `.env` file with your settings:

```env
APP_NAME=Happynance
APP_ENV=local
APP_KEY=base64:your_app_key_here
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=happyNation
DB_USERNAME=root
DB_PASSWORD=your_password

# Gemini AI Configuration
GEMINI_API_KEY=your_google_gemini_api_key_here
GEMINI_MODEL=gemini-pro

# JWT Secret
JWT_SECRET=your_jwt_secret_key_here

# Laravel Passport
PASSPORT_CLIENT_ID=your_passport_client_id
PASSPORT_CLIENT_SECRET=your_passport_client_secret
```

#### Database Setup

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE happynance;"

# Run migrations and seeders
php artisan migrate --seed

# Install Passport
php artisan passport:install
```

#### Start Backend Server

```bash
php artisan serve
```

The API will be available at `http://localhost:8000`

### 3. Mobile App Setup (Flutter)

#### Install Dependencies

```bash
cd ../mobile_app
flutter pub get
```

#### Configure API URL

Edit `lib/utils/constants.dart` if needed:

```dart
static const String apiBaseUrl = 'http://localhost:8000/api';
// For Android emulator, use: 'http://10.0.2.2:8000/api'
// For iOS simulator, use: 'http://127.0.0.1:8000/api'
```

#### Generate Code

```bash
# Generate JSON serialization code
flutter packages pub run build_runner build

# Or watch for changes
flutter packages pub run build_runner watch
```

#### Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For web
flutter run -d chrome
```

##  Usage

### Default Login Credentials

After seeding, you can use these credentials:

**Admin User:**
- Email: `admin@happynance.com`
- Password: `password123`

**Employee User:**
- Email: `employee@happynance.com`
- Password: `password123`

### Using the App

1. **Register/Login**: Create account or use demo credentials
2. **Take Survey**: Answer 10-15 questions about work experience
3. **View Results**: See AI-generated analysis with scores and recommendations
4. **Track Progress**: Monitor changes over time in survey history
5. **Admin Features**: (If admin) manage questions and view statistics

## Project Structure

```
happyNation/
├── backend/                 # Laravel API
│   ├── app/
│   │   ├── Http/Controllers/
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Providers/
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   └── routes/
├── mobile_app/             # Flutter App
│   ├── lib/
│   │   ├── controllers/    # GetX controllers
│   │   ├── models/         # Data models
│   │   ├── screens/        # UI screens
│   │   ├── services/       # API services
│   │   ├── utils/          # Utilities
│   │   └── themes/         # App themes
└── docs/                   # Documentation
```

##  API Endpoints

### Authentication
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/logout` - User logout
- `GET /api/user` - Get current user

### Survey
- `GET /api/questions` - Get survey questions
- `POST /api/survey/submit` - Submit survey response
- `GET /api/survey/history` - Get user survey history
- `GET /api/survey/latest` - Get latest survey

### Analysis
- `GET /api/analysis/{responseId}` - Get survey analysis

### Admin (Protected)
- `GET /api/admin/questions` - Get all questions
- `POST /api/admin/questions` - Create question
- `PUT /api/admin/questions/{id}` - Update question
- `DELETE /api/admin/questions/{id}` - Delete question
- `GET /api/admin/statistics` - Get admin statistics

##  AI Integration

The app uses Google Gemini AI for intelligent analysis:

- **Input**: User survey responses
- **Processing**: Contextual analysis of well-being indicators
- **Output**: Scores, risk levels, and personalized recommendations
- **Fallback**: Default analysis if AI is unavailable

### Gemini AI Setup

1. Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Add to `.env` file: `GEMINI_API_KEY=your_key_here`
3. The app automatically handles AI integration and fallbacks

##  Survey Questions Categories

1. **Stress Level** - Work pressure and stress management
2. **Job Satisfaction** - Overall job fulfillment
3. **Work Motivation** - Drive and engagement
4. **Work-Life Balance** - Balance between work and personal life
5. **Burnout Risk** - Exhaustion and mental health indicators

##  Design Features

- **Modern UI**: Clean, professional interface
- **Responsive Design**: Works on phones and tablets
- **Dark/Light Theme**: Automatic theme switching
- **Accessibility**: Screen reader support
- **Animations**: Smooth transitions and feedback

## Security Features

- **Token-based Authentication**: Secure API access
- **Data Encryption**: Sensitive data protection
- **Input Validation**: Comprehensive data validation
- **Admin Protection**: Role-based access control
- **API Rate Limiting**: Protection against abuse

##  Performance Features

- **Offline Support**: Cache essential data
- **Lazy Loading**: Efficient data loading
- **Optimized Images**: Fast loading times
- **Background Processing**: Non-blocking AI analysis
- **Error Handling**: Graceful failure management

##  Troubleshooting

### Backend Issues

```bash
# Clear cache
php artisan config:clear
php artisan cache:clear

# Reset database
php artisan migrate:fresh --seed

# Check logs
tail -f storage/logs/laravel.log
```

### Mobile App Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter packages pub run build_runner clean

# Check for issues
flutter doctor
```

### Common Problems

1. **API Connection Failed**: Check if backend is running and URL is correct
2. **Database Connection Error**: Verify MySQL is running and credentials are correct
3. **AI Analysis Failed**: Check Gemini API key and internet connection
4. **Build Errors**: Run `flutter packages pub run build_runner build`

##  License

This project is licensed under the MIT License - see the LICENSE file for details.

##  Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

##  Support

For support and questions:

- Create an issue in the repository
- Check the documentation
- Review the troubleshooting section

##  Next Steps

- [ ] Add push notifications
- [ ] Implement advanced analytics
- [ ] Add team comparison features
- [ ] Include more AI models
- [ ] Add export to Excel/PDF
- [ ] Implement real-time chat support

##  Demo Features

This project includes:
- Complete authentication flow
- Survey creation and submission
- AI-powered analysis
- Visual results dashboard
- Admin management panel
- Responsive mobile design

Ready for demonstration and deployment!