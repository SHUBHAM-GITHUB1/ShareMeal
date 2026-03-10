import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_post.dart';

class FoodCard extends StatelessWidget {
  final FoodPost post;
  final VoidCallback? onClaim; // Only NGOs will have a claim button
  final bool isDonorView;

  const FoodCard({super.key, required this.post, this.onClaim, this.isDonorView = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (!isDonorView) 
            Image.network(post.img, height: 160, width: double.infinity, fit: BoxFit.cover),
          ListTile(
            title: Text(post.item, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Qty: ${post.qty} | ${DateFormat('hh:mm a').format(post.time)}"),
            trailing: isDonorView ? const Icon(Icons.edit) : const Text("2.0 KM", style: TextStyle(color: Colors.red)),
          ),
          if (onClaim != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: onClaim,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("CLAIM NOW"),
              ),
            )
        ],
      ),
    );
  }
}