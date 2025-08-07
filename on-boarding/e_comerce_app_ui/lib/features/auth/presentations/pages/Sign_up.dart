import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  static const routName = '/singup';
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(
                vertical: 30,
                horizontal: 30,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Container(
                    width: 78,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6.41),
                      ),
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
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Create your account',
                style: GoogleFonts.poppins(
                  wordSpacing: 2,
                  fontSize: 26.72,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Name', textAlign: TextAlign.left),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'ex: jon smith',
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
                    child: Text('Email', textAlign: TextAlign.left),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'ex: jon.smith@email.com',
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
                        hintText: '********',
                        hintStyle: TextStyle(color: Color(0xff888888)),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Confirm Password', textAlign: TextAlign.left),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '********',
                        hintStyle: TextStyle(color: Color(0xff888888)),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Checkbox(
                          value:
                              isChecked, // Bind the checkbox to the boolean variable
                          onChanged: (bool? newValue) {
                            setState(() {
                              isChecked = newValue ?? false; // Update the state
                            });
                          },
                        ),
                        const Text('I understood the '),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'terms & policy.',
                            style: TextStyle(color: Color(0xff3F51F3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
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
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('have an account?'),
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
      ),
    );
  }
}
