import 'package:flutter/material.dart';
import 'package:pakcraft/api_connection/api_connection.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    List items = order['items'];
    String date = order['created_at'].toString().split(' ')[0];

    Color statusColor = order['order_status'] == 'Completed'
        ? Colors.green
        : const Color(0xFFFF8A00);

    return Scaffold(
      backgroundColor: const Color(0xFFD6D0C9),
      appBar: AppBar(
        title: const Text(
          "Order Receipt",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD6D0C9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 50,
                    color: Color(0xFFFF8A00),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Order #${order['order_id']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(date, style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 30),
                  _infoRow(
                    "Status",
                    order['order_status'],
                    color: statusColor,
                    isBold: true,
                  ),
                  _infoRow("Payment", order['payment_method']),
                  _infoRow(
                    "Total",
                    "Rs. ${order['total_amount']}",
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Items Purchased",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            Column(
              children: items.map((item) {
                String imageUrl =
                    "${API.hostConnect}/${item['image_path'].toString().replaceAll('\\', '/')}";
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            color: Colors.grey,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Rs. ${item['price']} x ${item['quantity']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Rs. ${double.parse(item['price']) * int.parse(item['quantity'])}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8A00),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Delivery Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    order['address'],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool isBold = false,
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
