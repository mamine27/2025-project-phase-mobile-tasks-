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
      home: Builder(
        builder: (innerContext) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(
                innerContext,
              ).push(MaterialPageRoute(builder: (_) => const AddPage()));
            },
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
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({super.key});
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _price = '', _description = '';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: BackButton(),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      // Handle image selection logic here
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 50, color: Colors.grey),
                            Text(
                              'Tap to select an image',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Name", textAlign: TextAlign.left),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    onSaved: (v) => _name = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Price", textAlign: TextAlign.left),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    onSaved: (v) => _name = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Catagory", textAlign: TextAlign.left),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    onSaved: (v) => _name = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Description", textAlign: TextAlign.left),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: TextFormField(
                    maxLines: 6,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    onSaved: (v) => _description = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),

                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(19),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                // TODO: handle submit (_name, _price, _description, image, etc)
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: const Color(0xFF3F51F3),
                            ),
                            child: Text(
                              'ADD',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                // TODO: handle submit (_name, _price, _description, image, etc)
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: Colors.red, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 247, 0, 0),
                              ),
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
        ),
      ),
    );
  }
}
