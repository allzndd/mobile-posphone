import 'package:flutter/material.dart';
import 'component/validation_handler.dart';

class TestValidationScreen extends StatelessWidget {
  const TestValidationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Validation'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Test Inline Messages
            ValidationHandler.buildSuccessMessage('Ini pesan success dengan desain baru'),
            ValidationHandler.buildErrorMessage('Ini pesan error dengan desain baru'),
            ValidationHandler.buildWarningMessage('Ini pesan warning dengan desain baru'),
            
            const SizedBox(height: 20),
            
            // Test SnackBar
            ElevatedButton(
              onPressed: () {
                context.showSuccessSnack('Test success snackbar dengan desain baru!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Test Success SnackBar'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () {
                context.showErrorSnack('Test error snackbar dengan desain baru!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Test Error SnackBar'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () {
                context.showWarningSnack('Test warning snackbar dengan desain baru!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Test Warning SnackBar'),
            ),
            
            const SizedBox(height: 20),
            
            // Test Dialogs
            ElevatedButton(
              onPressed: () {
                context.showSuccess(
                  title: 'Berhasil!',
                  message: 'Dialog success dengan desain baru yang modern dan responsive',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Test Success Dialog'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () {
                context.showError(
                  title: 'Error!',
                  message: 'Dialog error dengan desain baru yang modern dan responsive',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Test Error Dialog'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                final result = await context.showConfirmation(
                  title: 'Konfirmasi',
                  message: 'Dialog konfirmasi dengan desain baru. Apakah Anda yakin?',
                  confirmText: 'Ya, Lanjutkan',
                  cancelText: 'Batal',
                  confirmColor: Colors.blue,
                );
                
                if (result == true) {
                  context.showSuccessSnack('Anda memilih Ya!');
                } else if (result == false) {
                  context.showErrorSnack('Anda memilih Batal!');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Test Confirmation Dialog'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Custom snackbar method untuk test langsung
  static void _showCustomSuccessSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade500,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Berhasil',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto remove after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }
}