import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'check_in_form_screen.dart';
import 'tennis_screen.dart';
import 'restaurant_reservations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hotel Yacanto App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(color: Colors.grey.shade300),
            child: Image.asset(
              'assets/images/hotel_yacanto.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildImageMenuButton(
                    context,
                    assetPath: 'assets/images/check_in.jpg',
                    title: 'Ingresos\n(Check-in)',
                    color: Colors.green,
                    onTap: () => _onCheckInTap(context),
                  ),
                  _buildImageMenuButton(
                    context,
                    assetPath: 'assets/images/check_out.jpg',
                    title: 'Egresos\n(Check-out)',
                    color: Colors.red,
                    onTap: () => _onMenuTap(context, 'Egresos (Check-out)'),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.sports_tennis,
                    title: 'Tenis',
                    color: Colors.orange,
                    onTap: () => _onTenisTap(context),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.delivery_dining,
                    title: 'Delivery',
                    color: Colors.purple,
                    onTap: () => _onMenuTap(context, 'Delivery'),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.restaurant,
                    title: 'Restaurant',
                    color: Colors.brown,
                    onTap: () => _onRestaurantTap(context),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.golf_course,
                    title: 'Golf',
                    color: Colors.teal,
                    onTap: () => _onGolfTap(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMenuButton(
    BuildContext context, {
    required String assetPath,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMenuTap(BuildContext context, String menuName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Has seleccionado: $menuName'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCheckInTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckInFormScreen()),
    );
  }

  void _onTenisTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TennisScreen()),
    );
  }

  void _onRestaurantTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RestaurantReservationsScreen(),
      ),
    );
  }

  Future<void> _onGolfTap(BuildContext context) async {
    const String vistaGolfPackage = 'com.vistasouth.vistagolf.vista_golf';

    if (Platform.isAndroid) {
      try {
        final Uri appUri = Uri.parse('vistagolf://');

        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri);
        } else {
          throw Exception('App not installed');
        }
      } catch (e) {
        const String playStoreUrl =
            'https://play.google.com/store/apps/details?id=$vistaGolfPackage';
        final Uri playStoreUri = Uri.parse(playStoreUrl);

        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir la Play Store'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else if (Platform.isIOS) {
      const String appStoreUrl =
          'https://apps.apple.com/us/app/vista-golf/id6476614527';
      final Uri appStoreUri = Uri.parse(appStoreUrl);

      try {
        if (await canLaunchUrl(appStoreUri)) {
          await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Cannot launch URL');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la App Store'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
