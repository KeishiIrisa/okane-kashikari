import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main.dart';
import 'core/flavor_config.dart';

void main() async {
  await dotenv.load(fileName: '.env.prod');

  final apiBaseUrl = dotenv.env['API_BASE_URL'];
  final appTitle = dotenv.env['APP_TITLE'];

  if (apiBaseUrl == null || appTitle == null) {
    throw Exception('Missing required environment variables in .env.prod');
  }
  
  final config = FlavorConfig(
    flavor: Flavor.prod,
    apiBaseUrl: apiBaseUrl,
    appTitle: appTitle,
  );
  await initializeApp(config);
}
