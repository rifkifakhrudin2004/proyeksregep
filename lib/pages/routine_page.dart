import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DailyRoutine {
  final String id;
  final String userId;
  final DateTime date;
  final List<String> completedItemIds;
  final String timeOfDay;
  final String name; // Added name property
  final String description; // Added description property
  bool isSelected; // Added isSelected property

  DailyRoutine({
    required this.id,
    required this.userId,
    required this.date,
    required this.completedItemIds,
    required this.timeOfDay,
    required this.name,
    required this.description,
    this.isSelected = false, // Default value for isSelected
  });

  // Convert the DailyRoutine object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'completedItemIds': completedItemIds,
      'timeOfDay': timeOfDay,
      'name': name,
      'description': description,
    };
  }

  // Convert Firestore document to a DailyRoutine object
  static DailyRoutine fromMap(Map<String, dynamic> map) {
    return DailyRoutine(
      id: map['id'],
      userId: map['userId'],
      date: (map['date'] as Timestamp).toDate(),
      completedItemIds: List<String>.from(map['completedItemIds']),
      timeOfDay: map['timeOfDay'],
      name: map['name'], // Mapping name
      description: map['description'], // Mapping description
      isSelected: map['isSelected'] ?? false, // Adding handling for isSelected
    );
  }
}

class SkincareRoutinePage extends StatefulWidget {
  @override
  _SkincareRoutinePageState createState() => _SkincareRoutinePageState();
}

class _SkincareRoutinePageState extends State<SkincareRoutinePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DailyRoutine> availableItems = [];
  List<DailyRoutine> selectedItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSkincareItems();
  }

  Future<void> _loadSkincareItems() async {
    try {
      setState(() => isLoading = true);

      // Fetch skincare items from Firestore or use local data
      final snapshot = await FirebaseFirestore.instance
          .collection('skincare_items')
          .get();

      final items = snapshot.docs.map((doc) {
        return DailyRoutine.fromMap(doc.data());
      }).toList();

      setState(() {
        availableItems = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk skincare: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutinitas Skincare'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pagi'),
            Tab(text: 'Malam'),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: SpinKitCircle(
                color: Colors.pink,
                size: 50,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRoutineList('morning'),
                _buildRoutineList('night'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveRoutine,
        child: Icon(Icons.save),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Widget _buildRoutineList(String timeOfDay) {
    final filteredItems = availableItems
        .where((item) => item.timeOfDay == timeOfDay || item.timeOfDay == 'both')
        .toList();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.spa, color: Colors.white),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.description),
                  trailing: Checkbox(
                    value: item.isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        item.isSelected = value ?? false;
                        if (value == true) {
                          selectedItems.add(item);
                        } else {
                          selectedItems.remove(item);
                        }
                      });
                    },
                    activeColor: Colors.pink,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari produk skincare...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            availableItems = availableItems.where((item) {
              return item.name.toLowerCase().contains(value.toLowerCase());
            }).toList();
          });
        },
      ),
    );
  }

  Future<void> _saveRoutine() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan login terlebih dahulu')),
        );
        return;
      }

      final routineId = DateTime.now().millisecondsSinceEpoch.toString();
      final today = DateTime.now();

      final morningRoutine = DailyRoutine(
        id: '${routineId}_morning',
        date: today,
        userId: user.uid,
        completedItemIds: selectedItems
            .where((item) => item.isSelected && item.timeOfDay == 'morning')
            .map((item) => item.id)
            .toList(),
        timeOfDay: 'morning',
        name: '', // Should be filled with proper data
        description: '', // Should be filled with proper data
      );

      final nightRoutine = DailyRoutine(
        id: '${routineId}_night',
        date: today,
        userId: user.uid,
        completedItemIds: selectedItems
            .where((item) => item.isSelected && item.timeOfDay == 'night')
            .map((item) => item.id)
            .toList(),
        timeOfDay: 'night',
        name: '', // Should be filled with proper data
        description: '', // Should be filled with proper data
      );

      final batch = FirebaseFirestore.instance.batch();

      batch.set(
        FirebaseFirestore.instance
            .collection('skincare_routines')
            .doc(morningRoutine.id),
        morningRoutine.toMap(),
      );

      batch.set(
        FirebaseFirestore.instance
            .collection('skincare_routines')
            .doc(nightRoutine.id),
        nightRoutine.toMap(),
      );

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rutinitas berhasil disimpan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan rutinitas: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}