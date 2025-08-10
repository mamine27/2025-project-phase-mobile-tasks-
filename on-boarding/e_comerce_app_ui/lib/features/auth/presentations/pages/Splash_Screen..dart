import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';

// Import your auth datasource here
// import 'path_to_auth_remote_datasource_impl.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Inject your authRemote here (or pass it via constructor)
  // For example:
  final authremote = sl<AuthRemoteDataSourceImpl>();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash screen delay

    final result = await authremote.isSignedIn(); // returns Either
    print('isSignedIn result: $result');

    final isSignedIn = result.fold(
      (failure) {
        // Replace print with a logging framework
        debugPrint('Error: ${failure.message}');
        return false;
      },
      (userModel) {
        if (userModel != null) {
          final name = userModel.name;
          debugPrint('User Name: ${userModel.name}');
          debugPrint('User Email: ${userModel.email}');
          debugPrint('User ID: ${userModel.id}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Welcome back! $name')));
          return true;
        }
        return false;
      },
    );

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        isSignedIn ? '/socket-test' : '/signin',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: 1286,
            height: 859,
            child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
          ),
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 43, 73, 224), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color.fromARGB(255, 43, 73, 224).withOpacity(0.7),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 264,
                    height: 121,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(31.03),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'ECOM',
                        style: GoogleFonts.caveatBrush(
                          color: const Color(0xff3F51F3),
                          fontSize: 90,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Ecommerce APP',
                    style: GoogleFonts.poppins(
                      fontSize: 35,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
