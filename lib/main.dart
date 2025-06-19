import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; 

void main() => runApp(QuotesApp());

class QuotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotes (motivasi atau islami)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: SplashScreen(),
    );
  }
}

// ------------------ Splash Screen ------------------

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
            Text("Quotes Islami & Motivasi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ------------------ Quote Model ------------------

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] ?? json['quote'] ?? '',
      author: json['a'] ?? json['author'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'q': text,
        'a': author,
      };
}

// ------------------ Data Islami & Lokal Web ------------------

List<Quote> islamicQuotes = [
  Quote(text: "Sesungguhnya sesudah kesulitan itu ada kemudahan.", author: "Q.S Al-Insyirah: 6"),
  Quote(text: "Allah tidak membebani seseorang melainkan sesuai kesanggupannya.", author: "Q.S Al-Baqarah: 286"),
  Quote(text: "Berdoalah kepada-Ku, niscaya akan Aku perkenankan bagimu.", author: "Q.S Ghafir: 60"),
];

List<Quote> localMotivationalQuotes = [
  Quote(text: "Jangan menyerah sebelum sukses.", author: "Anonim"),
  Quote(text: "Kegagalan adalah awal dari keberhasilan.", author: "Bijak"),
  Quote(text: "Semangat adalah bahan bakar mimpi.", author: "Motivator"),
];

// ------------------ Favorite Storage ------------------

class FavoriteStorage {
  static const _key = 'favorite_quotes';

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

// ------------------ Home Screen ------------------

enum QuoteCategory { motivasi, islami, favorit }

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quote> quotes = [];
  bool isLoading = true;
  QuoteCategory selectedCategory = QuoteCategory.motivasi;

  @override
  void initState() {
    super.initState();
    loadQuotes();
  }

  Future<void> loadQuotes() async {
    setState(() => isLoading = true);

    if (selectedCategory == QuoteCategory.motivasi) {
      if (kIsWeb) {
        quotes = localMotivationalQuotes; // Web: data lokal
      } else {
        try {
          final response = await http.get(Uri.parse('https://zenquotes.io/api/quotes'));
          if (response.statusCode == 200) {
            quotes = (json.decode(response.body) as List).map((q) => Quote.fromJson(q)).toList();
          } else {
            quotes = [Quote(text: "Gagal mengambil data dari API.", author: "Sistem")];
          }
        } catch (e) {
          quotes = [Quote(text: "Terjadi kesalahan: $e", author: "Error")];
        }
      }
    } else if (selectedCategory == QuoteCategory.islami) {
      quotes = islamicQuotes;
    } else {
      quotes = await FavoriteStorage.loadFavorites();
    }

    setState(() => isLoading = false);
  }

  void changeCategory(QuoteCategory category) {
    setState(() => selectedCategory = category);
    loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quotes (${selectedCategory.name.toUpperCase()})"),
        actions: [
          PopupMenuButton<QuoteCategory>(
            onSelected: changeCategory,
            itemBuilder: (context) => [
              PopupMenuItem(value: QuoteCategory.motivasi, child: Text("Motivasi")),
              PopupMenuItem(value: QuoteCategory.islami, child: Text("Islami")),
              PopupMenuItem(value: QuoteCategory.favorit, child: Text("Favorit")),
            ],
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                final q = quotes[index];
                return ListTile(
                  title: Text(q.text),
                  subtitle: Text("- ${q.author}"),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuoteDetailScreen(quote: q)),
                    );
                    if (result == true) loadQuotes(); // refresh favorit
                  },
                );
              },
            ),
    );
  }
}

// ------------------ Detail Screen ------------------

class QuoteDetailScreen extends StatelessWidget {
  final Quote quote;

  const QuoteDetailScreen({required this.quote});

  @override
  Widget build(BuildContext context) {
    final fullText = '"${quote.text}"\n- ${quote.author}';

    return Scaffold(
      appBar: AppBar(title: Text("Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(fullText, style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
            SizedBox(height: 20),
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
            ElevatedButton.icon(
              icon: Icon(Icons.favorite),
              label: Text("Save to Favorite"),
              onPressed: () async {
                final favs = await FavoriteStorage.loadFavorites();
                if (!favs.any((q) => q.text == quote.text)) {
                  favs.add(quote);
                  await FavoriteStorage.saveFavorites(favs);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved to favorites!")));
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
