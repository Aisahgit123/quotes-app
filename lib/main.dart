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

class IslamiPage extends StatelessWidget {
  final List<Quote> islamicQuotes = [
  Quote(text: "Sesungguhnya sesudah kesulitan itu ada kemudahan.", author: "Q.S. Al-Insyirah: 6"),
  Quote(text: "Allah tidak membebani seseorang melainkan sesuai kesanggupannya.", author: "Q.S. Al-Baqarah: 286"),
  Quote(text: "Berdoalah kepada-Ku, niscaya akan Aku perkenankan bagimu.", author: "Q.S. Ghafir: 60"),
  Quote(text: "Cukuplah Allah menjadi penolong kami dan Allah adalah sebaik-baik pelindung.", author: "Q.S. Ali Imran: 173"),
  Quote(text: "Dan hanya kepada Tuhanmulah hendaknya kamu berharap.", author: "Q.S. Al-Insyirah: 8"),
  Quote(text: "Dan bersabarlah. Sesungguhnya Allah bersama orang-orang yang sabar.", author: "Q.S. Al-Anfal: 46"),
  Quote(text: "Ingatlah, hanya dengan mengingat Allah hati menjadi tenang.", author: "Q.S. Ar-Ra’d: 28"),
  Quote(text: "Barang siapa bertakwa kepada Allah, niscaya Dia akan membukakan jalan keluar baginya.", author: "Q.S. At-Talaq: 2"),
  Quote(text: "Sesungguhnya Allah mencintai orang-orang yang bertawakal kepada-Nya.", author: "Q.S. Ali Imran: 159"),
  Quote(text: "Sesungguhnya rahmat Allah sangat dekat kepada orang-orang yang berbuat baik.", author: "Q.S. Al-A’raf: 56"),
  Quote(text: "Janganlah kamu berputus asa dari rahmat Allah.", author: "Q.S. Az-Zumar: 53"),
  Quote(text: "Dan bersyukurlah kepada-Ku, dan janganlah kamu mengingkari nikmat-Ku.", author: "Q.S. Al-Baqarah: 152"),
  Quote(text: "Sesungguhnya bersama kesulitan ada kemudahan.", author: "Q.S. Al-Insyirah: 5"),
  Quote(text: "Bersabarlah, sesungguhnya kesabaran itu pada pukulan yang pertama.", author: "HR. Bukhari"),
  Quote(text: "Orang yang paling dicintai Allah adalah yang paling bermanfaat bagi manusia.", author: "HR. Ahmad"),
  Quote(text: "Amal yang paling dicintai Allah adalah yang paling terus menerus meskipun sedikit.", author: "HR. Bukhari dan Muslim"),
  Quote(text: "Tidak akan masuk surga orang yang di dalam hatinya ada kesombongan seberat biji sawi.", author: "HR. Muslim"),
  Quote(text: "Sebaik-baik manusia adalah yang paling baik akhlaknya.", author: "HR. Tirmidzi"),
  Quote(text: "Islam dibangun atas lima dasar: syahadat, salat, zakat, puasa, dan haji.", author: "HR. Bukhari dan Muslim"),
  Quote(text: "Barangsiapa yang beriman kepada Allah dan hari akhir, hendaklah ia berkata yang baik atau diam.", author: "HR. Bukhari dan Muslim"),
  Quote(text: "Sesungguhnya Allah Maha Pengampun lagi Maha Penyayang.", author: "Q.S. Al-Baqarah: 173"),
  Quote(text: "Dialah yang menciptakan malam agar kamu beristirahat padanya.", author: "Q.S. Al-Furqan: 47"),
  Quote(text: "Dan Tuhanmu berfirman: 'Berdoalah kepada-Ku, niscaya Aku kabulkan'.", author: "Q.S. Ghafir: 60"),
  Quote(text: "Barang siapa yang bertawakal kepada Allah, niscaya Allah akan mencukupkan keperluannya.", author: "Q.S. At-Talaq: 3"),
  Quote(text: "Sesungguhnya orang yang beriman dan beramal saleh akan mendapatkan surga.", author: "Q.S. Al-Kahfi: 107"),
  Quote(text: "Dan janganlah kamu merasa lemah, dan jangan pula bersedih hati.", author: "Q.S. Ali Imran: 139"),
  Quote(text: "Ketahuilah, bahwa sesungguhnya hidup ini hanyalah permainan dan senda gurau.", author: "Q.S. Al-Hadid: 20"),
  Quote(text: "Hai orang-orang yang beriman, jadikanlah sabar dan salat sebagai penolongmu.", author: "Q.S. Al-Baqarah: 153"),
  Quote(text: "Maka bersabarlah kamu dengan sabar yang baik.", author: "Q.S. Al-Ma’arij: 5"),
  Quote(text: "Hanya kepada Engkaulah kami menyembah dan hanya kepada Engkaulah kami memohon pertolongan.", author: "Q.S. Al-Fatihah: 5"),
  Quote(text: "Sesungguhnya Allah tidak mengubah keadaan suatu kaum sebelum mereka mengubah keadaan diri mereka sendiri.", author: "Q.S. Ar-Ra’d: 11"),
  Quote(text: "Dan peliharalah dirimu dari siksa neraka yang disediakan bagi orang-orang kafir.", author: "Q.S. Al-Baqarah: 24"),
  Quote(text: "Sungguh beruntung orang yang menyucikan jiwanya.", author: "Q.S. Asy-Syams: 9"),
  Quote(text: "Harta dan anak-anak adalah perhiasan kehidupan dunia.", author: "Q.S. Al-Kahfi: 46"),
  Quote(text: "Dan sesungguhnya Tuhanmu benar-benar Maha Kuasa atas segala sesuatu.", author: "Q.S. Al-Baqarah: 20"),
  Quote(text: "Sesungguhnya shalat itu mencegah dari perbuatan keji dan mungkar.", author: "Q.S. Al-Ankabut: 45"),
  Quote(text: "Dan katakanlah kepada hamba-hamba-Ku: hendaklah mereka mengucapkan perkataan yang lebih baik.", author: "Q.S. Al-Isra: 53"),
  Quote(text: "Dan apabila hamba-hamba-Ku bertanya kepadamu tentang Aku, maka sesungguhnya Aku dekat.", author: "Q.S. Al-Baqarah: 186"),
  Quote(text: "Dan hendaklah kamu memohon ampun kepada Tuhanmu dan bertaubat kepada-Nya.", author: "Q.S. Hud: 3"),
  Quote(text: "Tidak ada paksaan dalam (menganut) agama.", author: "Q.S. Al-Baqarah: 256"),
  Quote(text: "Dan sesungguhnya janji Allah adalah benar.", author: "Q.S. Ar-Rum: 60"),
  Quote(text: "Katakanlah: Sesungguhnya aku hanya seorang pemberi peringatan.", author: "Q.S. Al-Ankabut: 50"),
  Quote(text: "Janganlah kamu bersikap sombong di muka bumi ini.", author: "Q.S. Al-A’raf: 13"),
  Quote(text: "Mereka yang bersabar akan diberi pahala tanpa batas.", author: "Q.S. Az-Zumar: 10"),
  Quote(text: "Dan janganlah kamu iri hati terhadap apa yang dikaruniakan Allah kepada orang lain.", author: "Q.S. An-Nisa: 32"),
  Quote(text: "Bersungguh-sungguhlah, karena sesungguhnya Allah mencintai orang-orang yang bersungguh-sungguh.", author: "HR. Bukhari"),
  Quote(text: "Kebaikan tidak akan habis walaupun hanya dengan satu senyuman.", author: "HR. Tirmidzi"),
  Quote(text: "Tidak sempurna iman seseorang hingga ia mencintai saudaranya sebagaimana ia mencintai dirinya sendiri.", author: "HR. Bukhari dan Muslim"),
  Quote(text: "Sebaik-baik amal adalah yang paling terus-menerus, meskipun sedikit.", author: "HR. Muslim"),
  Quote(text: "Orang kuat bukan yang pandai bergulat, tapi yang mampu mengendalikan diri saat marah.", author: "HR. Bukhari")
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

  Future<void> removeFavorite(int index) async {
    setState(() {
      favorites.removeAt(index);
    });
    await FavoriteStorage.saveFavorites(favorites);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dihapus dari favorit.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(title: Text("Quote (Favorit)")),
      body: favorites.isEmpty
          ? Center(child: Text("Belum ada favorit."))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final q = favorites[index];
                return Card(
                  color: Colors.green[700],
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(q.text, style: TextStyle(color: Colors.white)),
                    subtitle: Text("- ${q.author}", style: TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () => removeFavorite(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


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
                  icon: Icon(Icons.copy, color: Colors.white),
                  label: Text("Copy", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fullText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Copied!"))
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.share, color: Colors.white),
                  label: Text("Share", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => Share.share(fullText),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.favorite, color: Colors.red),
              label: Text("Simpan ke Favorit", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                final favs = await FavoriteStorage.loadFavorites();
                if (!favs.any((q) => q.text == quote.text)) {
                  favs.add(quote);
                  await FavoriteStorage.saveFavorites(favs);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Disimpan ke favorit!"))
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

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