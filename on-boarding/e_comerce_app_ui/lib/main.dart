import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        padding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ), // inner spacing
        child: SizedBox(
          height: 240,
          width: 366,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    'assets/images/sample.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 8),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nike",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("120\$"),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Men's Shoe",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rate,
                              color: const Color.fromARGB(
                                255,
                                222,
                                208,
                                83,
                              ), // Set the icon color to yellow
                            ),
                            Text("(4.0)"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          shape: CircleBorder(),
          backgroundColor: const Color.fromARGB(255, 101, 170, 227),
          child: Text(
            "+",
            style: GoogleFonts.poppins(fontSize: 35, color: Colors.white),
          ),
        ),
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
                            Text(
                              "July 14 ,2023",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),

                            Text(
                              "Hello , Yohannes",
                              style: GoogleFonts.poppins(
                                fontSize: 10,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 1, // Number of columns
                    crossAxisSpacing: 10, // Spacing between columns
                    mainAxisSpacing: 10, // Spacing between rows
                    childAspectRatio: 1.5, // Aspect ratio of each item
                    children: List.generate(
                      10, // Number of items
                      (index) => singlecard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
