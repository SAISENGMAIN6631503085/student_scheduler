import 'dart:convert';
import 'package:flutter/services.dart';

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] as String,
      author: json['author'] as String,
    );
  }
}

class QuoteService {
  List<Quote> _quotes = [];
  int _currentIndex = 0;

  Future<void> loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quotes/quotes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _quotes = (jsonData['quotes'] as List)
          .map((quote) => Quote.fromJson(quote))
          .toList();
    } catch (e) {
      print('Error loading quotes: $e');
      // Provide some default quotes in case of error
      _quotes = [
        Quote(
          text: "The journey of a thousand miles begins with one step.",
          author: "Lao Tzu"
        ),
        Quote(
          text: "Education is the most powerful weapon which you can use to change the world.",
          author: "Nelson Mandela"
        ),
      ];
    }
  }

  Quote getRandomQuote() {
    if (_quotes.isEmpty) {
      return Quote(
        text: "The journey of a thousand miles begins with one step.",
        author: "Lao Tzu"
      );
    }
    _currentIndex = (_currentIndex + 1) % _quotes.length;
    return _quotes[_currentIndex];
  }

  Quote getCurrentQuote() {
    if (_quotes.isEmpty) {
      return Quote(
        text: "The journey of a thousand miles begins with one step.",
        author: "Lao Tzu"
      );
    }
    return _quotes[_currentIndex];
  }
} 