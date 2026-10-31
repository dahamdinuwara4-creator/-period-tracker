import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final _plugin = FlutterLocalNotificationsPlugin();
const _berry = Color(0xFFB5305F);
const _coral = Color(0xFFE8735F);

const _s = <String, Map<String, String>>{
  'si': {
    'title': 'ඔසප් සටහන', 'next': 'ඊළඟ ඔසප් දිනය (ඇස්තමේන්තුව)', 'none': 'පහළින් අන්තිම ඔසප් දිනය තෝරන්න',
    'togo': 'දවස් ඉතිරියි', 'today': 'අද', 'cd': 'චක්‍රයේ දවස ', 'tdy': 'ඔසප් අද ආරම්භ විය',
    'last': 'ඔසප් ආරම්භ දිනයක් එකතු කරන්න', 'cyc': 'සාමාන්‍ය චක්‍රය (ආරම්භක අගය)', 'bef': 'කලින් මතක් කරන්න',
    'auto': 'ස්වයංක්‍රීය', 'days': 'දවස්', 'ins': 'ඔබේ චක්‍රය', 'avg': 'සාමාන්‍ය චක්‍රය', 'range': 'අඩුම සහ වැඩිම',
    'ok': 'ඔබේ චක්‍රය තරමක් ස්ථාවරයි.',
    'var': 'ඔබේ චක්‍රවල දිග තරමක් වෙනස් වෙනවා. තවත් දින සටහන් කරන තරමට ඇස්තමේන්තු වඩා හොඳ වෙයි. කනස්සල්ලක් තියෙනවා නම් වෛද්‍යවරයෙක් හමුවන්න.',
    'out': 'ඔබේ සාමාන්‍ය චක්‍රය දවස් 21 සහ 35 අතර නොවේ. කනස්සල්ලක් තියෙනවා නම් වෛද්‍යවරයෙක් හමුවන්න.',
    'need': 'විශ්ලේෂණයට අවම වශයෙන් ඔසප් ආරම්භ දින 3ක් සටහන් කරන්න.',
    'late': 'ඔසප් දවස් X කින් ප්‍රමාදයි (එය ආරම්භ වී නැතිනම් හෝ ඔබ සටහන් කර නැතිනම්). කනස්සල්ලක් තියෙනවා නම් වෛද්‍යවරයෙක් හමුවන්න.',
    'hist': 'සටහන් කළ දින', 'upc': 'ඉදිරි දින', 'disc': 'රහසිගත දැනුම්දීම්', 'discSub': 'Lock screen එකේ "Reminder" කියා පමණක් පෙන්වයි',
    'n1': 'ඔසප් දවස් X කින් ආරම්භ විය හැක', 'n2': 'අද ඔසප් ආරම්භ වීමට නියමිතයි',
    'note': 'මේවා ඇස්තමේන්තු පමණයි, වෛද්‍ය උපදෙස් නොවේ. ඔබේ දත්ත මේ උපාංගයේ පමණක් තබා ගනී.',
  },
  'en': {
    'title': 'Period Tracker', 'next': 'Next period (estimate)', 'none': 'Add your last period date below',
    'togo': 'days to go', 'today': 'Today', 'cd': 'Cycle day ', 'tdy': 'Period started today',
    'last': 'Add a period start date', 'cyc': 'Default cycle length', 'bef': 'Remind me before',
    'auto': 'auto', 'days': 'days', 'ins': 'Your cycle', 'avg': 'Average cycle', 'range': 'Shortest and longest',
    'ok': 'Your cycle looks fairly regular.',
    'var': 'Your cycle length varies a fair bit. Logging more dates will improve the estimates. If you are concerned, see a doctor.',
    'out': 'Your average cycle is outside 21 to 35 days. If you are concerned, see a doctor.',
    'need': 'Log at least 3 period start dates to see an analysis.',
    'late': 'Your period may be X days late (or it has not been logged yet). If you are worried, see a doctor.',
    'hist': 'Logged dates', 'upc': 'Coming up', 'disc': 'Discreet notifications', 'discSub': 'Lock screen shows only "Reminder"',
    'n1': 'Your period may start in X day(s)', 'n2': 'Your period is expected today',
    'note': 'These are estimates only, not medical advice. Your data stays on this device.',
  },
};

DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);
DateTime _plus(DateTime d, int n) => DateTime(d.year, d.month, d.day + n); // DST-safe
int _diff(DateTime a, DateTime b) =>
    DateTime.utc(a.year, a.month, a.day).difference(DateTime.utc(b.year, b.month, b.day)).inDays;
String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
  await _plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ));
  await _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Period Tracker',
        theme: ThemeData(colorSchemeSeed: _berry, useMaterial3: true),
        darkTheme: ThemeData(colorSchemeSeed: _berry, useMaterial3: true, brightness: Brightness.dark),
        home: const Home(),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DateTime> hist = [];
  int cycle = 28, before = 2;
  bool discreet = false;
  String lang = 'si';
  Map<String, String> get t => _s[lang]!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      hist = (p.getStringList('hist') ?? []).map(DateTime.parse).toList()..sort();
      cycle = p.getInt('cycle') ?? 28;
      before = p.getInt('before') ?? 2;
      discreet = p.getBool('discreet') ?? false;
      lang = p.getString('lang') ?? 'si';
    });
    await _schedule();
  }

  Future<void> _save() async {
    hist.sort();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('hist', hist.map(_iso).toList());
    await p.setInt('cycle', cycle);
    await p.setInt('before', before);
    await p.setBool('discreet', discreet);
    await p.setString('lang', lang);
    setState(() {});
    await _schedule();
  }

  void _add(DateTime d) {
    d = _d(d);
    if (d.isAfter(_d(DateTime.now())) || hist.contains(d)) return;
    hist.add(d);
    _save();
  }

  // ---- analysis (runs fully on the device, works offline) ----
  List<int> get _iv {
    final r = <int>[];
    for (var i = 1; i < hist.length; i++) {
      final x = _diff(hist[i], hist[i - 1]);
      if (x >= 15 && x <= 90) r.add(x);
    }
    return r;
  }

  int get _auto {
    final iv = _iv;
    if (iv.isEmpty) return 0;
    final l = iv.length > 6 ? iv.sublist(iv.length - 6) : iv;
    return (l.reduce((a, b) => a + b) / l.length).round();
  }

  int get _eff => (_auto >= 21 && _auto <= 45) ? _auto : cycle;

  DateTime? get _next {
    if (hist.isEmpty) return null;
    var n = _plus(hist.last, _eff);
    final t0 = _d(DateTime.now());
    while (n.isBefore(t0)) {
      n = _plus(n, _eff);
    }
    return n;
  }

  // ---- notifications ----
  Future<void> _schedule() async {
    await _plugin.cancelAll();
    final n = _next;
    if (n == null) return;
    if (before > 0) {
      await _at(1, _plus(n, -before), t['n1']!.replaceFirst('X', '$before'));
    }
    await _at(2, n, t['n2']!);
  }

  Future<void> _at(int id, DateTime d, String body) async {
    final when = tz.TZDateTime(tz.local, d.year, d.month, d.day, 9);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      id,
      discreet ? 'Reminder' : t['title']!,
      discreet ? 'Reminder' : body,
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails('period', 'Period reminders',
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ---- UI ----
  Widget _step(String label, int v, int lo, int hi, ValueChanged<int> set) => ListTile(
        title: Text(label),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: v > lo ? () => set(v - 1) : null),
          Text('$v ${t['days']}'),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: v < hi ? () => set(v + 1) : null),
        ]),
      );

  List<Widget> _insights() {
    final iv = _iv;
    if (iv.length < 2) return [ListTile(title: Text(t['need']!))];
    final mn = iv.reduce(min), mx = iv.reduce(max);
    final a = (iv.reduce((x, y) => x + y) / iv.length).round();
    final w = <Widget>[
      ListTile(title: Text(t['avg']!), trailing: Text('$a ${t['days']}')),
      ListTile(title: Text(t['range']!), trailing: Text('$mn - $mx ${t['days']}')),
      ListTile(title: Text((a < 21 || a > 35) ? t['out']! : (mx - mn > 7 ? t['var']! : t['ok']!))),
    ];
    final late = _diff(_d(DateTime.now()), _plus(hist.last, _eff));
    if (late >= 7) {
      w.add(ListTile(
          title: Text(t['late']!.replaceFirst('X', '$late'),
              style: const TextStyle(color: _coral, fontWeight: FontWeight.w600))));
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final n = _next;
    final daysTo = n == null ? 0 : _diff(n, _d(DateTime.now()));
    final idx = n == null ? -1 : (_eff - daysTo) % _eff;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(18), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(t['title']!, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'si', label: Text('සිං')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {lang},
              onSelectionChanged: (v) {
                lang = v.first;
                _save();
              },
            ),
          ]),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(
                    size: const Size(300, 300),
                    painter: _Dial(_eff, idx, Theme.of(context).colorScheme.outlineVariant)),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(n == null ? '–' : (daysTo == 0 ? t['today']! : '$daysTo'),
                      style: TextStyle(
                          fontSize: daysTo == 0 && n != null ? 30 : 64,
                          fontWeight: FontWeight.w700,
                          color: _berry,
                          fontFamily: 'serif')),
                  if (n != null && daysTo > 0) Text(t['togo']!),
                  if (n == null)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(t['none']!, textAlign: TextAlign.center)),
                ]),
              ]),
            ),
          ),
          if (n != null)
            Column(children: [
              Text(t['next']!, style: tt.bodySmall),
              Text(_iso(n), style: tt.headlineSmall),
              Text('${t['cd']}${idx + 1} / $_eff', style: tt.bodySmall),
            ]),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => _add(DateTime.now()), child: Text(t['tdy']!)),
          ListTile(
            title: Text(t['last']!),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 730)),
                lastDate: DateTime.now(),
              );
              if (d != null) _add(d);
            },
          ),
          _step('${t['cyc']}${_auto >= 21 && _auto <= 45 ? ' (${t['auto']} $_eff)' : ''}', cycle, 21, 45, (v) {
            cycle = v;
            _save();
          }),
          _step(t['bef']!, before, 0, 5, (v) {
            before = v;
            _save();
          }),
          SwitchListTile(
            title: Text(t['disc']!),
            subtitle: Text(t['discSub']!),
            value: discreet,
            onChanged: (v) {
              discreet = v;
              _save();
            },
          ),
          Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Text(t['ins']!, style: tt.titleMedium)),
          ..._insights(),
          Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Text(t['hist']!, style: tt.titleMedium)),
          for (final d in hist.reversed)
            ListTile(
              dense: true,
              title: Text(_iso(d)),
              trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    hist.remove(d);
                    _save();
                  }),
            ),
          if (n != null) ...[
            Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: Text(t['upc']!, style: tt.titleMedium)),
            for (var i = 0; i < 6; i++) ListTile(dense: true, title: Text(_iso(_plus(n, i * _eff)))),
          ],
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(t['note']!, style: tt.bodySmall)),
        ]),
      ),
    );
  }
}

class _Dial extends CustomPainter {
  final int n, idx;
  final Color dot;
  _Dial(this.n, this.idx, this.dot);
  @override
  void paint(Canvas c, Size s) {
    final ctr = s.center(Offset.zero);
    final r = s.width * 0.4;
    for (var i = 0; i < n; i++) {
      final a = -pi / 2 + i * 2 * pi / n;
      final o = ctr + Offset(cos(a), sin(a)) * r;
      var col = dot;
      if (idx >= 0 && i < idx) col = _berry;
      if (i == 0) col = _coral;
      if (i == idx) {
        c.drawCircle(o, 13, Paint()..color = _berry..style = PaintingStyle.stroke..strokeWidth = 2);
        col = _berry;
      }
      c.drawCircle(o, i == idx ? 7 : (i == 0 ? 6.5 : (n > 36 ? 4 : 5)), Paint()..color = col);
    }
  }

  @override
  bool shouldRepaint(_Dial o) => o.n != n || o.idx != idx || o.dot != dot;
}
