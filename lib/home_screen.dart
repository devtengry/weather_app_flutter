import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _HomeScreenState(),
    );
  }
}


class _HomeScreenState extends StatefulWidget {
  const _HomeScreenState();

  @override
  State<_HomeScreenState> createState() => HomeScreenState();
}

class HomeScreenState extends State<_HomeScreenState> {
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
                  padding: const EdgeInsets.all(10),
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
                const Column(
                  children: [
                    Text(
                      'SanDiego, ' 'USA',
                      style: TextStyle(),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Today, 22.08'),
          Icon(Icons.ac_unit_rounded),
          Text(
            '25',
            style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
          ),
          Text('Cloudy'),
          Row(
            crossAxisAligsnment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: SizedBox(
                  height: 80,
                  width: 160,
                  child: Text("data"),
                ),
              ),
              Card(
                child: SizedBox(
                  height: 80,
                  width: 160,
                  child: Text("data"),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: SizedBox(
                  height: 80,
                  width: 160,
                  child: Text("data"),
                ),
              ),
              Card(
                child: SizedBox(
                  height: 80,
                  width: 160,
                  child: Text("data"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
