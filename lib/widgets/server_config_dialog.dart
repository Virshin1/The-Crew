import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _hostController;
  bool _isTesting = false;
  bool? _testSuccess;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: ApiService.host);
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testSuccess = null;
      _testMessage = null;
    });

    final target = _hostController.text.trim();
    final ok = await ApiService.testConnection(target);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = ok;
        _testMessage = ok
            ? 'Connected successfully to http://$target/api/health'
            : 'Connection failed. Verify server is running and device is on same network.';
      });
    }
  }

  Future<void> _saveAndApply() async {
    final target = _hostController.text.trim();
    await ApiService.setHost(target);
    SocketService().disconnect();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.accentMint,
          content: Text(
            'Backend server configured: ${ApiService.host}',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentMint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dns_rounded, color: AppColors.accentMint, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Backend Connection',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
                    Text('Configure Node.js server address for mobile',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Presets section
          Text('QUICK PRESETS', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetChip(
                label: '📱 Wi-Fi / Physical Phone',
                host: ApiService.defaultLocalIp,
              ),
              _buildPresetChip(
                label: '🤖 Android Emulator',
                host: '10.0.2.2:3000',
              ),
              _buildPresetChip(
                label: '💻 Localhost / Desktop',
                host: 'localhost:3000',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Input field
          Text('SERVER HOST & PORT', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('http://', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                Expanded(
                  child: TextField(
                    controller: _hostController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      hintText: '172.30.6.83:3000 or 10.0.2.2:3000',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                    ),
                    onChanged: (_) {
                      if (_testSuccess != null) {
                        setState(() {
                          _testSuccess = null;
                          _testMessage = null;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentMint),
                        )
                      : const Icon(Icons.refresh, color: AppColors.accentMint, size: 18),
                  tooltip: 'Ping server',
                  onPressed: _isTesting ? null : _testConnection,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Status Feedback
          if (_testMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_testSuccess ?? false)
                    ? AppColors.accentMint.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (_testSuccess ?? false)
                      ? AppColors.accentMint.withValues(alpha: 0.3)
                      : AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    (_testSuccess ?? false) ? Icons.check_circle : Icons.error_outline,
                    color: (_testSuccess ?? false) ? AppColors.accentMint : AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: (_testSuccess ?? false) ? AppColors.accentMint : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isTesting ? null : _testConnection,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Test Ping'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveAndApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentMint,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save & Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({required String label, required String host}) {
    final isSelected = _hostController.text.trim() == host;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.white)),
      selected: isSelected,
      selectedColor: AppColors.accentMint,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.accentMint : AppColors.borderSubtle,
      ),
      onSelected: (_) {
        setState(() {
          _hostController.text = host;
          _testSuccess = null;
          _testMessage = null;
        });
      },
    );
  }
}
