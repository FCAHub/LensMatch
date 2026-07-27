import 'package:flutter/material.dart';

class AccountDetailsView extends StatelessWidget {
  const AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(context, 'Full Name', 'John Doe'),
            const SizedBox(height: 24),
            _buildField(context, 'Email Address', 'johndoe@example.com'),
            const SizedBox(height: 24),
            _buildField(context, 'Phone Number', '+1 (555) 123-4567'),
            const SizedBox(height: 24),
            _buildField(context, 'Shipping Address', '123 Main St, Apt 4B\nNew York, NY 10001'),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile updated successfully!'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text('Save Changes', style: textTheme.titleMedium?.copyWith(color: const Color(0xFF141414), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
