import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HomePage());
}

Widget singlecard(innerContext) {
  return GestureDetector(
    onTap: () {
      Navigator.of(innerContext).pushNamed(DetailPage.routeName);
    },
    child: Card(
      elevation: 4, // shadow depth
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey), // Set border size and color
        borderRadius: BorderRadius.circular(15), // rounded corners:w
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ), // inner spacing
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    width: double.infinity,
                  ),
                ),
              ),

              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),

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
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),

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
                              color: const Color.fromARGB(255, 222, 208, 83),
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
    ),
  );
}

String des =
    "The Nike Air Max is a versatile and stylish shoe designed for comfort and performance. Featuring a breathable mesh upper, cushioned sole, and iconic design, it's perfect for both casual wear and athletic activities.";
Widget Description(String discription) {
  return SizedBox(
    width: double.infinity,
    height: 200,
    child: Text(discription, style: GoogleFonts.poppins(fontSize: 14)),
  );
}

List<Widget> generate(int start, int end) {
  List<Widget> boxes = [];
  for (int i = start; i <= end; i++) {
    boxes.add(box(i));
    boxes.add(SizedBox(width: 16));
  }

  return boxes;
}

Widget showcard() {
  return Column(
    // elevation: 4, // shadow depth
    // shape: RoundedRectangleBorder(
    //   side: BorderSide(color: Colors.grey), // Set border size and color
    //   borderRadius: BorderRadius.circular(15), // rounded corners:w
    // ),
    children: [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ), // inner spacing
        child: SizedBox(
          height: 265,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    width: double.infinity,
                  ),
                ),
              ),

              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  SizedBox(height: 5),
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
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget box(int cnt) {
  return GestureDetector(
    child: Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Background color
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Center(
        child: Text(
          "$cnt",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(255, 1, 1, 1), // Text color
          ),
        ),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  static const routeName = '/';
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomePage.routeName,
      routes: {
        AddPage.routeName: (_) => const AddPage(),
        SearchPage.routeName: (_) => const SearchPage(),
        DetailPage.routeName: (_) => const DetailPage(),
      },
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: Builder(
        builder: (innerContext) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(innerContext).pushNamed(AddPage.routeName);
            },
            shape: CircleBorder(),
            backgroundColor: const Color(0xFF3F51F3),
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
                          CircleAvatar(
                            radius: 20, // Control the size of the avatar
                          ),
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
                      Icon(Icons.notifications, size: 24), // Control icon size
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
                                fontSize: 24, // Control text size
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: Icon(Icons.search, size: 24),
                            onTap: () {
                              Navigator.of(
                                innerContext,
                              ).pushNamed(SearchPage.routeName);
                            },
                          ),
                          // Control icon size
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 1, // Number of columns
                      crossAxisSpacing: 10, // Spacing between columns
                      mainAxisSpacing: 20, // Spacing between rows
                      childAspectRatio: 1.5, // Aspect ratio of each item
                      children: List.generate(
                        10, // Number of items
                        (index) => Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 8,
                          ),
                          child: singlecard(innerContext),
                        ),
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
  static const routeName = '/add';
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
                        padding: EdgeInsets.symmetric(vertical: 8),
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
                        padding: EdgeInsets.symmetric(vertical: 8),
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

class SearchPage extends StatefulWidget {
  static const routeName = '/search';
  const SearchPage({super.key});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _price = '', _description = '';
  RangeValues _priceRange = RangeValues(0, 1000);

  @override
  Widget build(BuildContext innercontext) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Product',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: BackButton(),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onSaved: (v) => _name = v ?? '',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 1, // Number of columns
              crossAxisSpacing: 50, // Spacing between columns
              mainAxisSpacing: 30, // Spacing between rows
              childAspectRatio: 1.5, // Aspect ratio of each item
              children: List.generate(
                10, // Number of items
                (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: singlecard(innercontext),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(19),
            child: Column(
              children: [
                SizedBox(height: 0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Category", textAlign: TextAlign.left),
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
                SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Price", textAlign: TextAlign.left),
                ),
                SizedBox(height: 5),

                RangeSlider(
                  activeColor: const Color(0xFF3F51F3),

                  values: _priceRange,
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${_priceRange.start.round()}'),
                      Text('\$${_priceRange.end.round()}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
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
                        'APPLY',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 255, 255, 255),
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
    );
  }
}

class DetailPage extends StatefulWidget {
  static const routeName = '/detail';
  const DetailPage({super.key});
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 286,

                  child: showcard(),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.all(16),
                child: BackButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Size:",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: generate(39, 50),
              ),
            ),
          ),
          SizedBox(height: 2),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Description(des),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => print('ADD'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F51F3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'ADD',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => print('DELETE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.red, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'DELETE',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.red,
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
        ],
      ),
    );
  }
}
