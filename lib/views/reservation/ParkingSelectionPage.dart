import 'package:flutter/material.dart';

class ParkingSelectionPage extends StatefulWidget {
  const ParkingSelectionPage({super.key});

  @override
  State<ParkingSelectionPage> createState() => _ParkingSelectionPageState();
}

class _ParkingSelectionPageState extends State<ParkingSelectionPage> with SingleTickerProviderStateMixin {
  final List<String> levels = ['Basement', 'Ground Floor', 'First Floor', 'Second Floor'];
  late TabController _tabController;
  String? selectedSpotId;

  final Map<String, List<String>> parkingSpots = {
    'Basement': ['B-01', 'B-02', 'B-03', 'B-05', 'B-07', 'B-08', 'B-09', 'B-11', 'B-14', 'B-15', 'B-18', 'B-20', 'B-21', 'B-23'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: levels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void selectSpot(String spotId) {
    setState(() {
      selectedSpotId = spotId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Pick Parking Spot', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: levels.map((level) => Tab(text: level)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: levels.map((level) {
                final spots = parkingSpots[level] ?? [];
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.all(12),
                        crossAxisCount: 3,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: spots.map((spotId) {
                          final isSelected = selectedSpotId == spotId;
                          return GestureDetector(
                            onTap: () => selectSpot(spotId),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/car.png', // Add your car image asset
                                    height: 40,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isSelected ? 'Selected\n$spotId' : 'Available\n$spotId',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Colors.white),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          _buildLegend(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedSpotId != null ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _LegendItem(color: Colors.blue, label: 'Selected'),
          SizedBox(width: 20),
          _LegendItem(color: Colors.white, label: 'Available (13)'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 6),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
