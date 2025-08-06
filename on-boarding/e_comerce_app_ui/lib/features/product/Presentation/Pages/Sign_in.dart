import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  static const routeName = '/signin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 150),
          Center(
            child: Container(
              width: 144,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6.41)),
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'ECOM',
                  style: GoogleFonts.caveatBrush(
                    color: const Color(0xff3F51F3),
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Sign into your account',
              style: GoogleFonts.poppins(
                wordSpacing: 2,
                fontSize: 26.72,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email', textAlign: TextAlign.left),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "ex: jon.smith@email.com",
                      hintStyle: TextStyle(color: Color(0xff888888)),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password', textAlign: TextAlign.left),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "********",
                      hintStyle: TextStyle(color: Color(0xff888888)),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFF3F51F3),
                    ),
                    child: Text(
                      'SIGN IN',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don’t have an account?'),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(color: Color(0xff3F51F3)),
                            ),
                          ),
                        ],
                      ),
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
