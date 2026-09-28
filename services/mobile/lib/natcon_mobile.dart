library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api.dart';
import 'registrar.dart';

export 'api.dart';

const navy = Color(0xFF080F49);
const gold = Color(0xFFC9933B);

class NatconApp extends StatelessWidget {
  const NatconApp({super.key, this.staff = false, this.baseUrl = const String.fromEnvironment('NATCON_BASE_URL')});
  final bool staff;
  final String baseUrl;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: staff ? 'NATCON Registrar' : 'TAA NATCON 2026',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy, secondary: gold),
          scaffoldBackgroundColor: const Color(0xFFF7F5F0),
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
          filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(64, 52))),
        ),
        home: NatconApi.isValidBase(baseUrl)
            ? (staff ? RegistrarScreen(api: NatconApi(baseUrl)) : DelegateHome(api: NatconApi(baseUrl)))
            : const Scaffold(body: SafeArea(child: Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.settings_outlined, size: 48, color: navy),
                  SizedBox(height: 20),
                  Text('NATCON setup required', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('The conference address has not been configured in this build. Please contact the TAA technical team.', textAlign: TextAlign.center),
                ]),
              )))),
      );
}

Future<void> openConference(BuildContext context, Uri url) async {
  try {
    if (!['http', 'https'].contains(url.scheme) || !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw const NatconException('Could not open this page.');
    }
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the browser. Please try again.')));
  }
}

class DelegateHome extends StatefulWidget {
  const DelegateHome({super.key, required this.api});
  final NatconApi api;
  @override
  State<DelegateHome> createState() => _DelegateHomeState();
}

class _DelegateHomeState extends State<DelegateHome> {
  Map<String, dynamic>? event;
  String? error;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    setState(() => error = null);
    try {
      final data = await widget.api.call('event');
      if (mounted) setState(() => event = data);
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
  }
  @override
  void dispose() { widget.api.close(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TAA  /  NATCON 26')),
    body: RefreshIndicator(onRefresh: load, child: ListView(padding: const EdgeInsets.all(24), children: [
      Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('7TH ANNUAL NATIONAL CONFERENCE', style: TextStyle(color: gold, letterSpacing: 2, fontSize: 12)),
        const SizedBox(height: 24),
        const Text('Knowledge\nwith Purpose.', style: TextStyle(fontSize: 43, height: 1.1, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 16),
        const Text('Raising Responsible Muslim Leaders.', style: TextStyle(fontSize: 18, color: Color(0xFFB9DDF0))),
        const SizedBox(height: 28),
        const Text('1–4 OCTOBER 2026  •  IWO, OSUN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(event == null ? 'Reformation 2026' : 'Registration  ₦${((event!['price_kobo'] as num? ?? event!['amount_kobo'] as num? ?? 800000) / 100).toStringAsFixed(0)}', style: const TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold)),
      ])),
      const SizedBox(height: 24),
      if (error != null) ...[Text(error!, style: const TextStyle(color: Colors.red)), TextButton(onPressed: load, child: const Text('Try again'))],
      FilledButton.icon(onPressed: event == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationScreen(api: widget.api))), icon: const Icon(Icons.confirmation_number_outlined), label: const Text('Register for NATCON')),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => openConference(context, widget.api.base.resolve('conference/#recover')), icon: const Icon(Icons.mark_email_read_outlined), label: const Text('Retrieve my ticket')),
      const SizedBox(height: 28),
      const Text('Four days to learn, connect and grow.', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 14),
      const Text('Spiritual development, lectures, networking and shared experiences for secondary school leavers, undergraduates and postgraduate students.', style: TextStyle(height: 1.7)),
      const SizedBox(height: 22),
      const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.place_outlined), title: Text('Shaykh Idrees Fazazi Mogaji Central Mosque'), subtitle: Text('Iwo, Osun State')),
      TextButton(onPressed: () => openConference(context, widget.api.base.resolve('conference/')), child: const Text('Programme, FAQs and group registration')),
    ])),
  );
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.api});
  final NatconApi api;
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), phone = TextEditingController(), chapter = TextEditingController();
  bool busy = false, consent = false;
  String category = 'Undergraduate';
  String? error;
  @override
  void dispose() { for (final c in [name, email, phone, chapter]) { c.dispose(); } super.dispose(); }
  Future<void> submit() async {
    if (!form.currentState!.validate() || !consent) return;
    setState(() { busy = true; error = null; });
    try {
      final delegate = {'name': name.text.trim(), 'email': email.text.trim(), 'phone': phone.text.trim(), 'chapter': chapter.text.trim(), 'education': category};
      final data = await widget.api.call('register', {'payer_name': name.text.trim(), 'payer_email': email.text.trim(), 'payer_phone': phone.text.trim(), 'delegates': [delegate], 'consent': true});
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderScreen(api: widget.api, order: data)));
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Delegate registration')), body: Form(key: form, child: ListView(padding: const EdgeInsets.all(24), children: [
    const Text('Your next chapter starts here.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12), const Text('A personal ticket will be issued after your payment is confirmed.'), const SizedBox(height: 24),
    field(name, 'Full name', TextInputType.name), field(email, 'Email address', TextInputType.emailAddress), field(phone, 'Phone number', TextInputType.phone), field(chapter, 'Chapter / state', TextInputType.text),
    DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Educational category'), items: ['Secondary school leaver', 'Undergraduate', 'Postgraduate', 'Other'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: busy ? null : (s) => setState(() => category = s!)),
    const SizedBox(height: 16), CheckboxListTile(contentPadding: EdgeInsets.zero, value: consent, onChanged: busy ? null : (v) => setState(() => consent = v!), title: const Text('I agree to use these details for conference registration, ticket delivery and attendance administration.')),
    if (error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(error!, style: const TextStyle(color: Colors.red))),
    FilledButton(onPressed: busy || !consent ? null : submit, child: Text(busy ? 'Creating registration…' : 'Continue to payment')),
  ])));
  Widget field(TextEditingController c, String label, TextInputType type) => Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(controller: c, enabled: !busy, keyboardType: type, decoration: InputDecoration(labelText: label), validator: (v) {
    if (v == null || v.trim().isEmpty) return 'Enter $label';
    if (type == TextInputType.emailAddress && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }));
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key, required this.api, required this.order});
  final NatconApi api;
  final Map<String, dynamic> order;
  @override
  Widget build(BuildContext context) {
    final reference = order['reference']?.toString() ?? '';
    final token = order['access_token']?.toString() ?? order['order_token']?.toString() ?? '';
    final url = api.base.resolve('conference/').replace(fragment: 'order=${Uri.encodeComponent(reference)}&token=${Uri.encodeComponent(token)}');
    return Scaffold(appBar: AppBar(title: const Text('Complete your registration')), body: ListView(padding: const EdgeInsets.all(28), children: [
      const Icon(Icons.receipt_long_outlined, size: 68, color: navy), const SizedBox(height: 24),
      const Text('Registration saved', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18), SelectableText(reference, textAlign: TextAlign.center), const SizedBox(height: 18),
      const Text('Continue to the secure payment page to pay online or submit your bank-transfer reference. Your ticket is issued only after payment confirmation.', style: TextStyle(height: 1.7)),
      const SizedBox(height: 24), FilledButton(onPressed: () => openConference(context, url), child: const Text('Open secure payment page')),
      const SizedBox(height: 16), const Text('Keep this registration reference. If you close the payment page, use “Retrieve my ticket” on the conference website.'),
    ]));
  }
}
