import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/widgets/app_page_header.dart';
import '../../auth/services/auth_api_test_service.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  bool _testingAuthentication = false;

  Future<void> _testBackendAuthentication() async {
    setState(() {
      _testingAuthentication = true;
    });

    try {
      final response =
      await AuthApiTestService().testAuthenticatedRequest(
        baseUrl: 'http://127.0.0.1:8000',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Authentication Verified'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UID: ${data['uid'] ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  Text('Email: ${data['email'] ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Email verified: '
                        '${data['email_verified'] ?? false}',
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backend authentication failed '
                  '(${response.statusCode})',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Authentication test failed: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _testingAuthentication = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: 'Dashboard',
      subtitle: 'Welcome to SpiceOS',
      action: FilledButton.icon(
        onPressed:
        _testingAuthentication ? null : _testBackendAuthentication,
        icon: _testingAuthentication
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.verified_user_outlined),
        label: Text(
          _testingAuthentication
              ? 'Testing...'
              : 'Test Authentication',
        ),
      ),
    );
  }
}