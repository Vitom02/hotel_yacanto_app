import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'check_in_form_screen.dart';
import 'tennis_screen.dart';
import 'restaurant_reservations_screen.dart';
import '../services/local_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasDocument = LocalStorage.hasDocument();
    final fullName = LocalStorage.getFullName();
    print('🏠 HomeScreen: hasDocument=$hasDocument, fullName=$fullName');
    
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
          if (!hasDocument)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complete el check-in para acceder a todas las funciones',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (hasDocument && fullName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bienvenido $fullName',
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
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
                    onTap: hasDocument
                        ? () => _onMenuTap(context, 'Egresos (Check-out)')
                        : () => _showRegistrationRequired(context),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.sports_tennis,
                    title: 'Tenis',
                    color: Colors.orange,
                    isDisabled: !hasDocument,
                    onTap: hasDocument
                        ? () => _onTenisTap(context)
                        : () => _showRegistrationRequired(context),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.delivery_dining,
                    title: 'Delivery',
                    color: Colors.purple,
                    isDisabled: !hasDocument,
                    onTap: hasDocument
                        ? () => _onMenuTap(context, 'Delivery')
                        : () => _showRegistrationRequired(context),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.restaurant,
                    title: 'Restaurant',
                    color: Colors.brown,
                    isDisabled: !hasDocument,
                    onTap: hasDocument
                        ? () => _onRestaurantTap(context)
                        : () => _showRegistrationRequired(context),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.golf_course,
                    title: 'Golf',
                    color: Colors.teal,
                    isDisabled: !hasDocument,
                    onTap: hasDocument
                        ? () => _onGolfTap(context)
                        : () => _showRegistrationRequired(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showRegistrationRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registro requerido'),
        content: const Text(
          'Debe completar el check-in primero para acceder a esta función.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onCheckInTap(context);
            },
            child: const Text('Ir a Check-in'),
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
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.withOpacity(0.1)
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled ? Colors.grey : color,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDisabled ? Colors.grey : color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDisabled
                    ? Colors.grey
                    : color.withOpacity(0.9),
              ),
            ),
            if (isDisabled)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onMenuTap(BuildContext context, String menuName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: Text(
          'La funcionalidad de "$menuName" estará disponible próximamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _onCheckInTap(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckInFormScreen()),
    );
    if (mounted) {
      setState(() {});
    }
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
