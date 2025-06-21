import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(QuotesApp());

class QuotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quote inggris & indonesia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

// ------------------ MODEL ------------------
class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] ?? '',
      author: json['a'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'q': text,
        'a': author,
      };
}

class FavoriteStorage {
  static const _key = 'favorite_quote';

  static Future<void> saveFavorites(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonQuotes = quotes.map((q) => json.encode(q.toJson())).toList();
    await prefs.setStringList(_key, jsonQuotes);
  }

  static Future<List<Quote>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data == null) return [];
    return data.map((q) => Quote.fromJson(json.decode(q))).toList();
  }
}

// ------------------ SPLASH SCREEN ------------------
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CategoryScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: Colors.green),
            SizedBox(height: 10),
            Text("Quote Inggris & indonesia", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ------------------ MOTIVASI PAGE ------------------
class MotivasiPage extends StatefulWidget {
  @override
  State<MotivasiPage> createState() => _MotivasiPageState();
}

class _MotivasiPageState extends State<MotivasiPage> {
  List<Quote> quotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuotes();
  }

  Future<void> fetchQuotes() async {
    try {
      final response = await http.get(Uri.parse('https://api.allorigins.win/raw?url=https://zenquotes.io/api/quotes'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          quotes = (data as List).map((q) => Quote.fromJson(q)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load quotes');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        quotes = [Quote(text: 'Gagal mengambil data', author: 'Error')];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(title: Text("Quote (inggris)")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                final q = quotes[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuoteDetailScreen(quote: q)),
                  ),
                  child: Card(
                    color: Colors.green[700],
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.text, style: TextStyle(color: Colors.white, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('- ${q.author}', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ------------------ ISLAMI PAGE ------------------
class IslamiPage extends StatelessWidget {
  final List<Quote> islamicQuotes = [
    Quote(text: "Sesungguhnya sesudah kesulitan itu ada kemudahan.", author: "Q.S. Al-Insyirah: 6"),
    Quote(text: "Allah tidak membebani seseorang melainkan sesuai kesanggupannya.", author: "Q.S. Al-Baqarah: 286"),
    Quote(text: "Berdoalah kepada-Ku, niscaya akan Aku perkenankan bagimu.", author: "Q.S. Ghafir: 60"),
    Quote(text: "Cukuplah Allah menjadi penolong kami dan Allah adalah sebaik-baik pelindung.", author: "Q.S. Ali Imran: 173"),
    Quote(text: "Dan hanya kepada Tuhanmulah hendaknya kamu berharap.", author: "Q.S. Q.S. Al-Insyirah: 8"),
    Quote(text: "Dan bersabarlah. Sesungguhnya Allah bersama orang-orang yang sabar.", author: "Q.S. Al-Anfal: 46"),
    Quote(text: "Ingatlah, hanya dengan mengingat Allah hati menjadi tenang.", author: "Q.S. Ar-Ra’d: 28"),
    Quote(text: "Barang siapa bertakwa kepada Allah, niscaya Dia akan membukakan jalan keluar baginya.", author: "Q.S. At-Talaq: 2"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(title: Text("Quote (indonesia)")),
      body: ListView.builder(
        itemCount: islamicQuotes.length,
        itemBuilder: (context, index) {
          final q = islamicQuotes[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuoteDetailScreen(quote: q)),
            ),
            child: Card(
              color: Colors.green[700],
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.text, style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('- ${q.author}', style: TextStyle(color: Colors.white70))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------ FAVORIT PAGE ------------------
class FavoritPage extends StatefulWidget {
  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  List<Quote> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final data = await FavoriteStorage.loadFavorites();
    setState(() => favorites = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(title: Text("Quote (favorit)")),
      body: favorites.isEmpty
          ? Center(child: Text("Belum ada favorit."))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final q = favorites[index];
                return Card(
                  color: Colors.green[700],
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.text, style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('- ${q.author}', style: TextStyle(color: Colors.white70))
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ------------------ DETAIL PAGE ------------------
class QuoteDetailScreen extends StatelessWidget {
  final Quote quote;

  const QuoteDetailScreen({required this.quote});

  @override
  Widget build(BuildContext context) {
    final fullText = '"${quote.text}"\n- ${quote.author}';

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(title: Text("Detail Quote")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  fullText,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.copy),
                  label: Text("Copy"),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fullText));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied!")));
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.share),
                  label: Text("Share"),
                  onPressed: () => Share.share(fullText),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.favorite, color: Colors.red),
              label: Text("Simpan ke Favorit"),
              onPressed: () async {
                final favs = await FavoriteStorage.loadFavorites();
                if (!favs.any((q) => q.text == quote.text)) {
                  favs.add(quote);
                  await FavoriteStorage.saveFavorites(favs);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Disimpan ke favorit!")));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

// ------------------ CATEGORY SCREEN ------------------
class CategoryScreen extends StatelessWidget {
  Widget buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 4,
        ),
        child: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildButton("INGGRIS", () => Navigator.push(context, MaterialPageRoute(builder: (_) => MotivasiPage()))),
            buildButton("INDONESIA", () => Navigator.push(context, MaterialPageRoute(builder: (_) => IslamiPage()))),
            buildButton("FAVORIT", () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritPage()))),
          ],
        ),
      ),
    );
  }
}