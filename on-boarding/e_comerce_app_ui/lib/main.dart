import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  Widget singlecard() {
    return Card(
      elevation: 4, // shadow depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // rounded corners
      ),
      child: Padding(
        padding: EdgeInsets.all(16), // inner spacing
        child: Stack(
          children: [
            SizedBox(height: 200, width: 100),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product Name",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 100),
                Text("Description of the product goes here."),
              ],
            ),
          ],
        ),
      ),
    );
  }

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("July 14 ,2023"),
                            Text("Hello , Yohannes"),
                          ],
                        ),
                      ],
                    ),
                    Icon(Icons.notifications),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          child: Text(
                            "Available Products",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.search),
                      ],
                    ),
                    singlecard(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
