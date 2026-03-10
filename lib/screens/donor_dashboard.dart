import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/food_post.dart';
import '../models/app_state.dart';
import '../models/nutrient_data.dart';
import 'login_screen.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});
  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  bool _isVeg = true;

  @override
  void dispose() {
    _itemController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  String _formatName(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    // Access the Global State
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Donor Portal", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Refreshed"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                ),
              ),
              accountName: Text(user?.orgName ?? "Guest Donor"),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.business, color: Color(0xFF10B981)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF10B981)),
              title: const Text("My Address"),
              subtitle: Text(user?.address ?? "Not set"),
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: const Icon(Icons.dark_mode),
              value: appState.isDarkMode,
              onChanged: (v) => appState.toggleTheme(),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                appState.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: appState.allPosts.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No posts yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap + to add your first donation",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: appState.allPosts.length,
            itemBuilder: (context, i) {
              final post = appState.allPosts[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                      child: const Icon(Icons.fastfood, color: Color(0xFF10B981)),
                    ),
                    title: Text(
                      post.item,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Qty: ${post.qty}"),
                        if (post.nutrients != null) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: [
                              _buildNutrientChip('Protein: ${post.nutrients!.protein}', Colors.blue),
                              _buildNutrientChip('Carbs: ${post.nutrients!.carbs}', Colors.orange),
                              _buildNutrientChip('Fat: ${post.nutrients!.fat}', Colors.red),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(post.time),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Active",
                                style: TextStyle(fontSize: 10, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: post.isVeg ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            post.isVeg ? Icons.circle : Icons.circle,
                            size: 8,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showForm(context, user?.orgName ?? "Anonymous"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: const Text("Post Surplus", style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showForm(BuildContext context, String donorName) {
    setState(() => _isVeg = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Broadcast Food Donation",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: "Food Item Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Food item required";
                  if (v.trim().length < 3) return "Name too short (min 3 chars)";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(
                  labelText: "Quantity (in Kg)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Quantity required";
                  final qty = int.tryParse(v.trim());
                  if (qty == null || qty <= 0) return "Enter valid quantity";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Food Type:", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _isVeg,
                          onChanged: (v) => setModalState(() => _isVeg = v!),
                          activeColor: Colors.green,
                        ),
                        const Text("🟢 Veg"),
                        const SizedBox(width: 16),
                        Radio<bool>(
                          value: false,
                          groupValue: _isVeg,
                          onChanged: (v) => setModalState(() => _isVeg = v!),
                          activeColor: Colors.red,
                        ),
                        const Text("🔴 Non-Veg"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final nutrients = NutrientData.getNutrients(_itemController.text.trim());
                          final newPost = FoodPost(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            item: _formatName(_itemController.text.trim()),
                            qty: '${_qtyController.text.trim()} Kg',
                            img: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400",
                            time: DateTime.now(),
                            donor: donorName,
                            isVeg: _isVeg,
                            nutrients: nutrients,
                          );
                          Provider.of<AppState>(context, listen: false).addPost(newPost);
                          Navigator.pop(context);
                          _itemController.clear();
                          _qtyController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("✅ Food posted successfully!"),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text("Post"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}