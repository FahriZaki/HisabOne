import 'package:hisabone/pages/home_page.dart';
import 'package:hisabone/pages/login_page.dart';
import 'package:hisabone/pages/splash_screen.dart';

enum MyRoute {
  splash('/splash'),
  login('/login'),
  home('/home');

  final String name;
  const MyRoute(this.name);
}

final routes = {
  MyRoute.splash.name: (context) => const SplashScreen(),
  MyRoute.login.name: (context) => const LoginPage(),
  MyRoute.home.name: (context) => const HomePage(),
};
