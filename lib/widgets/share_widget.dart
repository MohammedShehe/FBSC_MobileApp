import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';

class ShareWidget {
  static void showShareDialog(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Shiriki Bidhaa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _buildShareButton(
                    context,
                    icon: Icons.chat,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _shareViaWhatsApp(product),
                  ),
                  _buildShareButton(
                    context,
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: () => _shareViaFacebook(product),
                  ),
                  _buildShareButton(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: const Color(0xFFE4405F),
                    onTap: () => _shareViaInstagram(product),
                  ),
                  _buildShareButton(
                    context,
                    icon: Icons.message,
                    label: 'Telegram',
                    color: const Color(0xFF0088cc),
                    onTap: () => _shareViaTelegram(product),
                  ),
                  _buildShareButton(
                    context,
                    icon: Icons.microwave,
                    label: 'Twitter',
                    color: const Color(0xFF1DA1F2),
                    onTap: () => _shareViaTwitter(product),
                  ),
                  _buildShareButton(
                    context,
                    icon: Icons.copy,
                    label: 'Nakili',
                    color: Theme.of(context).primaryColor,
                    onTap: () => _copyLink(product),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Kiungo cha Kushiriki',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _generateShareLink(product),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyLink(product),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildShareButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _generateShareLink(Product? product) {
    final baseUrl = 'https://fourbrothers.online';
    if (product != null) {
      return '$baseUrl/products/${product.id}';
    }
    return baseUrl;
  }

  static Future<void> _shareViaWhatsApp(Product? product) async {
    final shareText = _generateShareText(product);
    final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(shareText)}';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      await Share.share(shareText);
    }
  }

  static Future<void> _shareViaFacebook(Product? product) async {
    final shareText = _generateShareText(product);
    final facebookUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(_generateShareLink(product))}';
    
    if (await canLaunchUrl(Uri.parse(facebookUrl))) {
      await launchUrl(Uri.parse(facebookUrl));
    } else {
      await Share.share(shareText);
    }
  }

  static Future<void> _shareViaInstagram(Product? product) async {
    final shareText = _generateShareText(product);
    await Share.share(shareText);
  }

  static Future<void> _shareViaTelegram(Product? product) async {
    final shareText = _generateShareText(product);
    final telegramUrl = 'https://t.me/share/url?url=${Uri.encodeComponent(_generateShareLink(product))}&text=${Uri.encodeComponent(shareText)}';
    
    if (await canLaunchUrl(Uri.parse(telegramUrl))) {
      await launchUrl(Uri.parse(telegramUrl));
    } else {
      await Share.share(shareText);
    }
  }

  static Future<void> _shareViaTwitter(Product? product) async {
    final shareText = _generateShareText(product);
    final twitterUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}';
    
    if (await canLaunchUrl(Uri.parse(twitterUrl))) {
      await launchUrl(Uri.parse(twitterUrl));
    } else {
      await Share.share(shareText);
    }
  }

  static Future<void> _copyLink(Product? product) async {
    final link = _generateShareLink(product);
    await Share.share(link);
  }

  static String _generateShareText(Product? product) {
    if (product != null) {
      return 'Angalia bidhaa hii nzuri kutoka Four Brothers Sports Center!\n'
          '${product.name}\n'
          'Bei: ${product.formattedFinalPrice}\n'
          '${_generateShareLink(product)}';
    }
    return 'Angalia bidhaa nzuri kutoka Four Brothers Sports Center!\n${_generateShareLink(null)}';
  }

  // Add this method to ShareWidget class:
static void showProductShareModal(BuildContext context, {required Product product}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Shiriki Bidhaa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // Share Platforms
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _buildPlatformButton(
                  context,
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _shareViaWhatsApp(product),
                ),
                _buildPlatformButton(
                  context,
                  icon: Icons.facebook,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () => _shareViaFacebook(product),
                ),
                _buildPlatformButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  color: const Color(0xFFE4405F),
                  onTap: () => _shareViaInstagram(product),
                ),
                _buildPlatformButton(
                  context,
                  icon: Icons.message,
                  label: 'Telegram',
                  color: const Color(0xFF0088cc),
                  onTap: () => _shareViaTelegram(product),
                ),
                _buildPlatformButton(
                  context,
                  icon: Icons.microwave,
                  label: 'Twitter',
                  color: const Color(0xFF1DA1F2),
                  onTap: () => _shareViaTwitter(product),
                ),
                _buildPlatformButton(
                  context,
                  icon: Icons.copy,
                  label: 'Nakili',
                  color: Theme.of(context).primaryColor,
                  onTap: () => _copyLink(product),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Share Link
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Kiungo cha Kushiriki',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _generateShareLink(product),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyLink(product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

static Widget _buildPlatformButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
}