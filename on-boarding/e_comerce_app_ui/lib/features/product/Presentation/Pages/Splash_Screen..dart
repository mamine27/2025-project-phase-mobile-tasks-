import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash';

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
            color: Color.fromARGB(255, 43, 73, 224).withOpacity(0.7),
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
                SizedBox(height: 10),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
