import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'api.dart';
import 'natcon_mobile.dart' show navy, openConference;

String? parseTicket(String raw) {
  final trimmed = raw.trim();
  if (RegExp(r'^[a-f0-9]{64}$').hasMatch(trimmed)) return trimmed;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !['http', 'https'].contains(uri.scheme)) return null;
  final token = uri.queryParameters['token'] ?? uri.fragment;
  return RegExp(r'^[a-f0-9]{64}$').hasMatch(token) ? token : null;
}

class RegistrarScreen extends StatefulWidget {
  const RegistrarScreen({super.key, required this.api});
  final NatconApi api;
  @override
  State<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends State<RegistrarScreen> {
  final email = TextEditingController(), password = TextEditingController(), code = TextEditingController();
  Map<String, dynamic>? user, result;
  String? error;
  bool busy = false, scanning = false;
  String mode = 'arrival';
  MobileScannerController? camera;

  @override
  void dispose() {
    for (final c in [email, password, code]) { c.dispose(); }
    camera?.dispose();
    widget.api.close();
    super.dispose();
  }
  Future<void> login() async {
    if (busy) return;
    setState(() { busy = true; error = null; });
    try {
      final data = await widget.api.call('login', {'email': email.text.trim(), 'password': password.text});
      password.clear();
      if (mounted) setState(() => user = Map<String, dynamic>.from(data['user']));
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> check(String raw) async {
    if (busy) return;
    final token = parseTicket(raw);
    if (token == null) { setState(() => error = 'Enter a valid NATCON ticket code or ticket link.'); return; }
    await camera?.stop();
    setState(() { busy = true; scanning = false; result = null; error = null; });
    try {
      final data = await widget.api.call('checkin', {'token': token, 'mode': mode});
      if (mounted) setState(() => result = data);
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> logout() async {
    await camera?.stop();
    try { await widget.api.call('logout', {}); }
    catch (e) { if (mounted) setState(() => error = e.toString()); return; }
    widget.api.cookie = ''; widget.api.csrf = '';
    if (mounted) setState(() { user = null; result = null; scanning = false; code.clear(); });
  }
  void startScan() {
    camera ??= MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates, formats: [BarcodeFormat.qrCode]);
    setState(() { scanning = true; error = null; result = null; });
  }
  @override
  Widget build(BuildContext context) {
    final canScan = user == null || ['admin', 'registrar'].contains(user!['role']);
    return Scaffold(appBar: AppBar(title: const Text('NATCON · Registrar'), actions: [if(user != null) IconButton(onPressed: busy ? null : logout, tooltip: 'Sign out', icon: const Icon(Icons.logout))]), body: ListView(padding: const EdgeInsets.all(24), children: [
      if (user == null) ...[
        const SizedBox(height: 32), const Icon(Icons.verified_user_outlined, size: 64, color: navy), const SizedBox(height: 24),
        const Text('Welcome, registration team.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
        const Text('Use your assigned staff account. Every admission is recorded against your name.'), const SizedBox(height: 26),
        TextField(controller: email, enabled: !busy, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.username], decoration: const InputDecoration(labelText: 'Staff email')),
        const SizedBox(height: 16), TextField(controller: password, enabled: !busy, obscureText: true, autofillHints: const [AutofillHints.password], onSubmitted: (_) => login(), decoration: const InputDecoration(labelText: 'Password')),
        const SizedBox(height: 22), FilledButton(onPressed: busy ? null : login, child: Text(busy ? 'Signing in…' : 'Sign in')),
      ] else ...[
        Text('Assalamu alaykum, ${user!['name']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), Text('Signed in as ${user!['role']}. Internet connection required.'), const SizedBox(height: 24),
        if(canScan) ...[
          DropdownButtonFormField<String>(initialValue: mode, decoration: const InputDecoration(labelText: 'Admission type'), items: const [DropdownMenuItem(value: 'arrival', child: Text('First arrival')), DropdownMenuItem(value: 'daily', child: Text('Daily attendance')), DropdownMenuItem(value: 'reentry', child: Text('Re-entry'))], onChanged: busy ? null : (v) => setState(() => mode = v!)),
          const SizedBox(height: 20),
          if(scanning) SizedBox(height: 300, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: MobileScanner(controller: camera, onDetect: (capture) { if (!busy && scanning && capture.barcodes.isNotEmpty) { final raw = capture.barcodes.first.rawValue; if(raw != null) check(raw); } }, errorBuilder: (_, error) => const Center(child: Text('Camera unavailable. Allow camera permission or use the ticket code below.'))))),
          if(!scanning && (kIsWeb || [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS].contains(defaultTargetPlatform))) FilledButton.icon(onPressed: busy ? null : startScan, icon: const Icon(Icons.qr_code_scanner), label: const Text('Scan delegate ticket')),
          const SizedBox(height: 20), TextField(controller: code, enabled: !busy, decoration: const InputDecoration(labelText: 'Ticket code or private ticket link'), onSubmitted: check), const SizedBox(height: 14),
          OutlinedButton(onPressed: busy ? null : () => check(code.text), child: Text(busy ? 'Checking ticket…' : 'Verify and record admission')),
        ],
        if(result != null) ...[
          const SizedBox(height: 22), Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: result!['result'] == 'accepted' ? const Color(0xFFE0F3E7) : const Color(0xFFFFF0CE), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(result!['result'] == 'accepted' ? 'Admission recorded' : 'Already checked in', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
            Text(result!['delegate']?['name']?.toString() ?? '', style: const TextStyle(fontSize: 20)),
            Text(result!['delegate']?['chapter']?.toString() ?? ''),
            Text('Recorded: ${result!['checked_at']} UTC'),
          ])),
        ],
        const SizedBox(height: 24), TextButton.icon(onPressed: () => openConference(context, widget.api.base.resolve('operations/')), icon: const Icon(Icons.dashboard_outlined), label: const Text('Open staff dashboard')),
      ],
      if(error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Semantics(liveRegion: true, child: Text(error!, style: const TextStyle(color: Color(0xFF9B1B30))))),
    ]));
  }
}
