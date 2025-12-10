import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disclaimer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Disclaimer
            _buildSection(
              'Important Disclaimer',
              'Free Job Alert is NOT affiliated with any government organization or official government body. This is an independent third-party application that aggregates job information from publicly available sources.',
              Icons.warning_amber_rounded,
              Colors.orange,
            ),

            const SizedBox(height: 20),

            // Data Source
            _buildSection(
              'Data Source',
              'All job information displayed in this app is collected from various career portals and third-party websites such as freejobalert.com. We do not collect data directly from any government website.',
              Icons.source,
              Colors.blue,
            ),

            const SizedBox(height: 20),

            // Accuracy Disclaimer
            _buildSection(
              'Accuracy of Information',
              'While we strive to provide accurate and up-to-date information, we cannot guarantee the accuracy, completeness, or timeliness of the job listings. Users are strongly advised to verify all information from official government sources before taking any action.',
              Icons.fact_check,
              Colors.green,
            ),

            const SizedBox(height: 20),

            // No Endorsement
            _buildSection(
              'No Endorsement',
              'The listing of any job opportunity does not constitute an endorsement or recommendation by this app. We are not responsible for any hiring decisions made by employers or any outcomes resulting from job applications.',
              Icons.thumb_up_off_alt,
              Colors.purple,
            ),

            const SizedBox(height: 20),

            // User Responsibility
            _buildSection(
              'User Responsibility',
              'By using this app, you acknowledge that:\n\n• This is not an official government application\n• Job information may not be current or accurate\n• You will verify information from official sources\n• You will not hold the app responsible for any inaccuracies\n• Application fees or any payments should only be made through official channels',
              Icons.person_outline,
              Colors.teal,
            ),

            const SizedBox(height: 20),

            // Contact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_mail, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you have any questions or concerns about this disclaimer, please contact us through the app store listing.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Last Updated
            Center(
              child: Text(
                'Last updated: November 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialLink(String name, String url, BuildContext context) {
    return InkWell(
      onTap: () => _launchUrl(url, context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(Icons.link, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Icon(Icons.open_in_new, size: 14, color: Colors.blue.shade400),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString, BuildContext context) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }
}
