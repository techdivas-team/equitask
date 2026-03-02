const String apiBaseUrl = 'https://equitask-backend.onrender.com';

// Web client ID (for web platform)
const String googleWebClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue:
      '995530463322-fqr9iqdk5mrf4lsbdua3bfqabbh2vi3k.apps.googleusercontent.com',
);

// Android client ID (for Android native app)
const String googleAndroidClientId =
    '995530463322-4lvdn83gcmj5957o6a0tim6v0lndqtu9.apps.googleusercontent.com';
