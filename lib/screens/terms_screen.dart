import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masharti ya Huduma'),
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
            // Header
            const Center(
              child: Column(
                children: [
                  Text(
                    'Masharti ya Huduma',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
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
            
            // Introduction
            _buildSection(
              title: 'Utangulizi',
              icon: Icons.info,
              children: [
                const Text(
                  'Karibu kwenye programu ya Four Brothers Sports Center. Kwa kutumia programu hii, unakubali kufuata masharti na kanuni zote zilizotajwa hapa chini. Tafadhali soma kwa makini.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Masharti haya yanatumika kwa wateja wote, wasambazaji, na wahusika wote wanaotumia programu ya Four Brothers Sports Center. Kila ununuzi, usajili, au matumizi ya huduma zetu kunakubaliana na masharti haya.',
                ),
              ],
            ),
            
            // Account Registration
            _buildSection(
              title: 'Usajili na Akaunti ya Mteja',
              icon: Icons.person_add,
              children: [
                _buildListItem('Usajili unafanywa kwa kutumia nambari ya simu na nenosiri'),
                _buildListItem('Nambari ya simu inatumika kwa usajili na mawasiliano'),
                _buildListItem('Nenosiri lazima liwe na angalau herufi 6'),
                _buildListItem('Mteja anaweza kubadilisha nenosiri lake kupitia kipengele cha "Umesahau Nenosiri"'),
                _buildListItem('Barua pepe ni hiari kwa mteja kwa mawasiliano ya ziada'),
                _buildListItem('Mteja anahitaji kuthibitisha nenosiri lake kwa agizo la kwanza la usalama'),
                _buildListItem('Mteja anaweza kubadilisha nambari ya simu kwa kutumia kipengele cha "Badilisha Nambari ya Simu"'),
                
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Usalama wa Akaunti:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Unawajibika kwa usalama wa akaunti yako. Usigawane nenosiri lako na mtu yeyote. Ripoti matumizi yasiyoidhinishwa mara moja.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Password Security
            _buildSection(
              title: 'Usalama wa Nenosiri',
              icon: Icons.lock,
              children: [
                _buildListItem('Chagua nenosiri lenye nguvu lisiloweza kukisiwa kwa urahisi'),
                _buildListItem('Usitumie nenosiri linalotumika kwenye akaunti zingine'),
                _buildListItem('Ukisahau nenosiri, tumia kipengele cha "Umesahau Nenosiri"'),
                _buildListItem('Kwa ajili ya usalama, agizo la kwanza linahitaji uthibitisho wa nenosiri'),
                _buildListItem('Ukibadilisha nambari ya simu, utahitaji kuthibitisha kwa kutumia jina lako la kwanza na la mwisho'),
                _buildListItem('Ripoti shaka yoyote ya usalama mara moja kwa msaada wa wateja'),
              ],
            ),
            
            // Orders and Purchases
            _buildSection(
              title: 'Maagizo na Ununuzi',
              icon: Icons.shopping_cart,
              children: [
                _buildListItem('Mteja anaweza kuweka bidhaa kwenye karatasi ya ununuzi (cart) na kuagiza'),
                _buildListItem('Bei zinaonyeshwa kwa shilingi za Tanzania (TZS)'),
                _buildListItem('Mteja hulipa pesa taslimu (COD - Cash on Delivery) anapopokea bidhaa'),
                _buildListItem('Agizo la kwanza linahitaji uthibitisho wa nenosiri kwa usalama'),
                _buildListItem('Mteja anaweza kughairi agizo ikiwa bado halijaanza kusafirishwa'),
                _buildListItem('Bei zinaweza kubadilika bila tangazo - bei inayotumika ni ile iliyoonyeshwa wakati wa agizo'),
                _buildListItem('Punguzo la 10% linatumika kwa ununuzi wa bidhaa 3 au zaidi'),
                
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Maelekezo Muhimu:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hakikisha unakagua maelezo ya bidhaa, ukubwa, rangi, na bei kabla ya kufanya agizo. Angalia akiba ya bidhaa kabla ya kuagiza.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Returns
            _buildSection(
              title: 'Kurudisha Bidhaa',
              icon: Icons.undo,
              children: [
                _buildListItem('Mteja anaweza kurudisha bidhaa ndani ya siku 3 baada ya kupokea agizo'),
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
                      _buildListItem('Haijatumika', small: true),
                      _buildListItem('Haina uharibifu wowote', small: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
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
                      _buildListItem('Bidhaa imeharibika', small: true),
                      _buildListItem('Bidhaa nyingine tofauti', small: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildListItem('Mchakato wa kurudisha unahitaji sababu ya kina na uthibitisho wa hali ya bidhaa'),
              ],
            ),
            
            // Shipping and Delivery
            _buildSection(
              title: 'Usafirishaji na Uwasilishaji',
              icon: Icons.local_shipping,
              children: [
                _buildListItem('Muda wa kusafirisha hutegemea eneo la mteja na upatikanaji wa huduma za usafirishaji'),
                _buildListItem('Mteja anatoa anwani sahihi ya mshipisho wakati wa kuagiza'),
                _buildListItem('Makadirio ya muda wa kufika hutolewa wakati wa kuagiza'),
                _buildListItem('Usafirishaji wa bure unapatikana kwa maeneo yanayowasilishwa'),
                _buildListItem('Mteja anapaswa kupokea na kukagua bidhaa kabla ya kulipa'),
                _buildListItem('Taarifa ya usafirishaji inatolewa kupitia programu'),
              ],
            ),
            
            // Price Increase Warning
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ongezeko la Bei:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bei za bidhaa zinaweza kubadilika bila tangazo. Bei inayotumika ni ile iliyoonyeshwa wakati wa kufanya agizo. Hakuna malipo ya ziada baada ya kuagiza.',
                  ),
                ],
              ),
            ),
            
            // Contact Information
            _buildSection(
              title: 'Mawasiliano',
              icon: Icons.contact_mail,
              children: [
                _buildContactItem(Icons.phone, 'WhatsApp:', Constants.whatsappNumber),
                _buildContactItem(Icons.email, 'Email:', Constants.email),
                _buildContactItem(Icons.chat, 'Instagram:', '@four_brothers_sports_center'),
                _buildContactItem(Icons.message, 'Ujumbe Ndani ya Programu:', 'Sehemu ya Mawasiliano'),
                _buildContactItem(Icons.email, 'Barua pepe kwa wateja:', 'Kwa wateja walio na barua pepe'),
                _buildContactItem(Icons.notifications, 'Arifa ndani ya programu:', 'Kwa matangazo muhimu'),
              ],
            ),
            
            // Last Updated
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Masharti haya yamesasishwa mwisho: Desemba 3, 2025',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            
            // Agreement Check
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nimesoma, nimeelewa, na nakubaliana na Masharti yote ya Huduma ya Four Brothers Sports Center',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle),
                        SizedBox(width: 8),
                        Text('Nimekubaliana na Masharti'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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