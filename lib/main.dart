import 'package:flutter/material.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Screen',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true),
      home: const _HomeScreenState(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _HomeScreenState extends StatefulWidget {
  const _HomeScreenState({super.key});

  @override
  State<_HomeScreenState> createState() => __HomeScreenStateState();
}

class __HomeScreenStateState extends State<_HomeScreenState> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 1,
        actions: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.all(10),
                  onPressed: () {},
                  icon: Icon(Icons.menu),
                ),
                const Column(
                  children: [
                    Text(
                      'SanDiego, ' 'USA',
                      style: TextStyle(),
                    ),
                    Text(
                      'Today, ' '22.08',
                      style: TextStyle(),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Text('data'),
          )
        ],
      ),
    );
  }
}
