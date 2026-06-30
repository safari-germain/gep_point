import 'package:flutter/material.dart';
import 'package:gep_point/models/m_user.dart';
import 'package:gep_point/providers/wallet_provider.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/providers/promotion_provider.dart';
import 'package:gep_point/api_constants.dart';
import 'package:provider/provider.dart';
import 'package:gep_point/providers/configuration_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SendPointScreen extends StatefulWidget {
  final UserModel recipient;

  const SendPointScreen({super.key, required this.recipient});

  @override
  State<SendPointScreen> createState() => _SendPointScreenState();
}

class _SendPointScreenState extends State<SendPointScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String _feePayer = 'receiver';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().fetchActiveTransferPromotion();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final success = await context.read<TransactionProvider>().transfer(
      widget.recipient.id,
      amount,
      feePayer: _feePayer,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transfert réussi !"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = context.read<TransactionProvider>().error ?? "Erreur lors du transfert";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletProvider = context.watch<WalletProvider>();
    final configProvider = context.watch<ConfigurationProvider>();
    final promotionProvider = context.watch<PromotionProvider>();
    final balance = walletProvider.getUserBalance('standard');
    final transferFeeStr = configProvider.getValue('fee_transfer_user_to_user', defaultValue: '2');
    final baseFeePercent = double.tryParse(transferFeeStr) ?? 2.0;

    // Calcul du frais effectif après promotion
    double effectiveFeePercent = baseFeePercent;
    if (promotionProvider.hasPromotion) {
      effectiveFeePercent =
          baseFeePercent * (1 - (promotionProvider.activeDiscountPercentage! / 100));
      effectiveFeePercent = effectiveFeePercent < 0 ? 0 : effectiveFeePercent;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Envoyer des Points",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient Card
              _buildRecipientCard(theme),
              const SizedBox(height: 32),

              // Balance Display
              Text(
                "Votre solde : ${balance.toStringAsFixed(2)} pts",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                decoration: InputDecoration(
                  hintText: "0.00",
                  suffixText: "pts",
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.bolt_rounded, size: 32),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Montant requis";
                  final val = double.tryParse(value);
                  if (val == null || val <= 0) return "Montant invalide";
                  if (val > balance) return "Solde insuffisant";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Affichage des frais + promotion
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _amountController,
                builder: (context, value, child) {
                  final amount = double.tryParse(value.text) ?? 0.0;
                  final feeAmount = (amount * effectiveFeePercent) / 100;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frais de transaction
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Frais : ${feeAmount.toStringAsFixed(2)} pts"
                              " (${effectiveFeePercent.toStringAsFixed(2)}%"
                              "${promotionProvider.hasPromotion ? ' après promo' : ''})",
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bannière de promotion (si active)
                      if (promotionProvider.hasPromotion) ...[
                        const SizedBox(height: 10),
                        _buildPromoBanner(theme, promotionProvider),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              Text(
                "Qui supporte les frais de transfert ?",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Moi", style: TextStyle(fontSize: 14)),
                      value: 'sender',
                      groupValue: _feePayer,
                      onChanged: (val) {
                        setState(() => _feePayer = val!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Le bénéficiaire", style: TextStyle(fontSize: 14)),
                      value: 'receiver',
                      groupValue: _feePayer,
                      onChanged: (val) {
                        setState(() => _feePayer = val!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "CONFIRMER L'ENVOI",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(ThemeData theme, PromotionProvider promo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700,
            Colors.green.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🎉 Promotion active : ${promo.activePromotionName ?? ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${promo.activeDiscountPercentage!.toStringAsFixed(0)}% de réduction sur les frais de transfert !",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 60,
              height: 60,
              child: widget.recipient.profile != null
                  ? Image.network(
                      getFullImageUrl(widget.recipient.profile),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          widget.recipient.name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        widget.recipient.name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Destinataire",
                  style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6), fontSize: 12),
                ),
                Text(
                  widget.recipient.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  widget.recipient.email ?? widget.recipient.phone ?? "",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
