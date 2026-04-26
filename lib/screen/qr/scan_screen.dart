import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;
  String? scannedCode;
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

  void _onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      setState(() {
        isScanned = true;
        scannedCode = code;
      });
      controller.stop();
      debugPrint("QR détecté : $code");
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
          setState(() {
            isScanned = true;
            scannedCode = code;
          });
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
      body: isScanned
          ? PaymentWidget(scannedCode: scannedCode!)
          : Stack(
              children: [
                /// CAMERA
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),

                /// OVERLAY
                Container(
                  color: Colors.black.withOpacity(0.5),
                ),

                /// FRAME
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.cyanAccent,
                              width: 3,
                            ),
                          ),
                        ),

                        /// ANIMATED SCAN LINE
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanAnimation.value,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.cyanAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                /// TEXT
                Positioned(
                  bottom: 180,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: const [
                      Text(
                        "Scanner un utilisateur",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Alignez le QR dans le cadre",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                /// BOUTONS TORCH / IMAGE
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
                        icon: Icon(
                          torchEnabled ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                        label: Text(
                          torchEnabled ? "Lampe ON" : "Lampe OFF",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _scanFromImage,
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text(
                          "Scanner image",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Widget après scan réussi
class PaymentWidget extends StatefulWidget {
  final String scannedCode;
  const PaymentWidget({super.key, required this.scannedCode});

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  final TextEditingController amountController = TextEditingController();
  String _feePayer = 'receiver'; // 'sender' or 'receiver'

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Effectuer le transfert"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Destinataire : ${widget.scannedCode}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(),
              decoration: InputDecoration(
                labelText: "Montant",
                labelStyle: const TextStyle(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Qui supporte les frais de transaction ?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Moi", style: TextStyle(fontSize: 14)),
                    value: 'sender',
                    groupValue: _feePayer,
                    onChanged: (val) => setState(() => _feePayer = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Le récepteur", style: TextStyle(fontSize: 14)),
                    value: 'receiver',
                    groupValue: _feePayer,
                    onChanged: (val) => setState(() => _feePayer = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Consumer<TransactionProvider>(builder: (context, provider, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final montantStr = amountController.text;
                          if (montantStr.isEmpty) return;

                          final montant = double.tryParse(montantStr);
                          if (montant == null) return;

                          final userId = int.tryParse(widget.scannedCode);
                          if (userId == null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("ID utilisateur invalide dans le QR code"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          final success = await provider.transfer(userId, montant, feePayer: _feePayer);

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Transfert réussi !"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.error ?? "Erreur lors du transfert"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text("Valider le transfert"),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
