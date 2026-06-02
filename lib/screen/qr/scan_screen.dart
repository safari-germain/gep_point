import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gep_point/services/s_user.dart';
import 'package:gep_point/screen/point/send_point.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;
  bool torchEnabled = false;

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 260).animate(_animationController);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (isScanned) return;

    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      setState(() => isScanned = true);
      controller.stop();
      
      final userId = int.tryParse(code);
      if (userId != null) {
        _showLoadingDialog();
        final user = await UserService().getUserById(userId);
        if (mounted) Navigator.pop(context);

        if (user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SendPointScreen(recipient: user)),
            );
          }
        } else {
          _showError("Utilisateur non trouvé.");
        }
      } else {
        _showError("QR Code invalide.");
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      setState(() => isScanned = false);
      controller.start();
    }
  }

  Future<void> _scanFromImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final result = await controller.analyzeImage(image.path);
      if (result?.barcodes.isNotEmpty ?? false) {
        final code = result?.barcodes.first.rawValue;
        if (code != null) {
          _onDetect(result!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun QR détecté sur cette image")),
        );
      }
    } catch (e) {
      debugPrint("Erreur scan image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.cyanAccent, width: 3),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanAnimation.value,
                        left: 0,
                        right: 0,
                        child: Container(height: 2, color: Colors.cyanAccent),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Scanner un utilisateur",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("Alignez le QR dans le cadre", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    torchEnabled = !torchEnabled;
                    controller.toggleTorch();
                    setState(() {});
                  },
                  icon: Icon(torchEnabled ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                  label: Text(torchEnabled ? "Lampe ON" : "Lampe OFF", style: const TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: _scanFromImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text("Scanner image", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
