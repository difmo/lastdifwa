import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: Colors.blue),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.pending), text: 'Pending'),
            Tab(icon: Icon(Icons.check_box), text: 'Completed'),
            Tab(icon: Icon(Icons.cancel), text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrderListPage(status: 'pending'),
          OrderListPage(status: 'completed'),
          OrderListPage(status: 'cancelled'),
        ],
      ),
    );
  }
}

class OrderListPage extends StatelessWidget {
  final String status;

  const OrderListPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('difwa-orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching orders'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No $status orders found.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('Order ID: $orderId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Price: ₹ ${order['totalPrice']}'),
                    Text(
                      'Order Date: ${DateTime.fromMillisecondsSinceEpoch(order['timestamp'].millisecondsSinceEpoch)}',
                    ),
                    const SizedBox(height: 8),
                    ExpansionTile(
                      title: const Text("Selected Dates"),
                      children: order['selectedDates']
                          .where((dateData) => status == 'completed'
                              ? dateData['status'] == 'completed'
                              : true)
                          .map<Widget>((dateData) {
                        DateTime date = DateTime.parse(dateData['date']);
                        String dateStatus = dateData['status'] ?? 'pending';
                        return ListTile(
                          title: Text('Date: ${date.toLocal()}'),
                          subtitle: Text('Status: $dateStatus'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              await changeDateStatus(
                                  orderId, dateData['date'], value);
                            },
                            itemBuilder: (context) => [
                              if (dateStatus != 'cancelled')
                                const PopupMenuItem<String>(
                                  value: 'cancelled',
                                  child: Text('Cancel Date'),
                                ),
                              if (dateStatus != 'completed')
                                const PopupMenuItem<String>(
                                  value: 'completed',
                                  child: Text('Mark as Completed'),
                                ),
                              if (dateStatus != 'pending')
                                const PopupMenuItem<String>(
                                  value: 'pending',
                                  child: Text('Mark as Pending'),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'cancel') {
                      await cancelOrder(orderId);
                    } else {
                      await changeOrderStatus(orderId, value);
                    }
                  },
                  itemBuilder: (context) => [
                    if (status != 'cancelled')
                      const PopupMenuItem<String>(
                        value: 'cancel',
                        child: Text('Cancel Order'),
                      ),
                    if (status != 'completed')
                      const PopupMenuItem<String>(
                        value: 'completed',
                        child: Text('Mark as Completed'),
                      ),
                    if (status != 'pending')
                      const PopupMenuItem<String>(
                        value: 'pending',
                        child: Text('Mark as Pending'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> changeOrderStatus(String orderId, String newStatus) async {
    try {
      DateTime currentTime = DateTime.now(); // Get current local time

      await FirebaseFirestore.instance
          .collection('difwa-orders')
          .doc(orderId)
          .update({
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus,
            'timestamp':
                currentTime, // Use local time here instead of serverTimestamp
          }
        ]),
      });
    } catch (e) {
      print('Error updating date status: $e');
    }
  }

  Future<void> changeDateStatus(
      String orderId, String date, String newStatus) async {
    DateTime currentTime = DateTime.now(); // Get current local time

    try {
      final orderDoc =
          FirebaseFirestore.instance.collection('difwa-orders').doc(orderId);
      final orderSnapshot = await orderDoc.get();
      final orderData = orderSnapshot.data() as Map<String, dynamic>;

      final selectedDates =
          List<Map<String, dynamic>>.from(orderData['selectedDates']);
      final dateIndex =
          selectedDates.indexWhere((item) => item['date'] == date);

      if (dateIndex != -1) {
        selectedDates[dateIndex]['status'] = newStatus;

        await orderDoc.update({
          'selectedDates': selectedDates,
          'statusHistory': FieldValue.arrayUnion([
            {
              'status': newStatus,
              'date': date,
              'timestamp': currentTime,
            }
          ]),
        });
      }
    } catch (e) {
      print('Error updating date status: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('difwa-orders')
          .doc(orderId)
          .update({
        'status': 'cancelled',
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'cancelled',
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      print('Error cancelling order: $e');
    }
  }
}
