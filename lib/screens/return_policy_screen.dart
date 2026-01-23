import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sera ya Kurudisha Bidhaa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(Icons.undo, size: 60, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Sera ya Kurudisha Bidhaa',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Four Brothers Sports Center',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Return Period
            _buildSection(
              title: 'Muda wa Kurudisha',
              icon: Icons.access_time,
              children: [
                _buildListItem('Mteja anaweza kurudisha bidhaa ndani ya siku ${Constants.returnDays} baada ya kupokea agizo'),
                _buildListItem('Maombi ya kurudisha yanapaswa kutolewa ndani ya muda huu'),
                _buildListItem('Muda huu ni pamoja na siku za wikendi na likizo'),
              ],
            ),
            
            // Product Condition
            _buildSection(
              title: 'Hali ya Bidhaa',
              icon: Icons.inventory,
              children: [
                const Text(
                  'Bidhaa lazima iwe katika hali yake ya awali ya kuuzwa:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildListItem('Iwe kwenye kifurushi chake asili', small: true),
                      _buildListItem('Lebo na vitambulisho viwe vimeachwa', small: true),
                      _buildListItem('Haijatumika au kuvaa', small: true),
                      _buildListItem('Haina uharibifu wowote au alama', small: true),
                      _buildListItem('Alama zote za usalama zimeachwa', small: true),
                    ],
                  ),
                ),
              ],
            ),
            
            // Valid Reasons
            _buildSection(
              title: 'Sababu Zinazokubalika',
              icon: Icons.check_circle,
              children: [
                const Text(
                  'Sababu za kurudisha bidhaa zinazokubalika ni:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildListItem('Saizi haifai', small: true),
                      _buildListItem('Rangi si sahihi', small: true),
                      _buildListItem('Bidhaa imeharibika wakati wa usafirishaji', small: true),
                      _buildListItem('Bidhaa nyingine tofauti na iliyoagizwa', small: true),
                      _buildListItem('Kasoro ya viwanda', small: true),
                    ],
                  ),
                ),
              ],
            ),
            
            // Process
            _buildSection(
              title: 'Mchakato wa Kurudisha',
              icon: Icons.swap_horiz,
              children: [
                _buildListItem('Wasiliana nasi kupitia WhatsApp au programu ndani ya muda wa siku ${Constants.returnDays}'),
                _buildListItem('Toa namba ya agizo na sababu ya kina ya kurudisha'),
                _buildListItem('Tutakupa maelekezo ya jinsi ya kurudisha bidhaa'),
                _buildListItem('Ukikubaliwa, rudisha bidhaa kwa kifurushi chake asili'),
                _buildListItem('Fidia itafanywa ndani ya siku 7 za kazi baada ya kupokea bidhaa'),
              ],
            ),
            
            // Refund Options
            _buildSection(
              title: 'Njia za Kurudishiwa Fedha',
              icon: Icons.payment,
              children: [
                _buildListItem('Rudishiwa kwenye akaunti yako ya benki'),
                _buildListItem('Mpesa/Tigo Pesa/Airtel Money'),
                _buildListItem('Kadi ya zawadi kwa ununuzi wa baadaye'),
                _buildListItem('Kubadilishwa na bidhaa nyingine'),
              ],
            ),
            
            // Non-Returnable Items
            _buildSection(
              title: 'Bidhaa Zisizorudishwa',
              icon: Icons.do_not_disturb,
              children: [
                _buildListItem('Bidhaa zilizotumika au kuvaa'),
                _buildListItem('Bidhaa zilizoachwa alama za matumizi'),
                _buildListItem('Bidhaa zilizoharibika kwa makosa ya mteja'),
                _buildListItem('Bidhaa zilizokosewa kifurushi chake asili'),
                _buildListItem('Bidhaa zilizonunuliwa kwenye punguzo maalum'),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wasiliana Nasi kwa Msaada:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(Icons.phone, 'WhatsApp:', Constants.whatsappNumber),
                    _buildContactItem(Icons.email, 'Email:', Constants.email),
                    _buildContactItem(Icons.chat, 'Programu:', 'Sehemu ya Mawasiliano'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Agreement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Kwa kutumia huduma zetu, unakubali na kuelewa sera hii ya kurudisha bidhaa.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sera hii inatumika kuanzia tarehe ya agizo na inafuata sheria za Tanzania.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListItem(String text, {bool small = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: small ? 14 : 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}