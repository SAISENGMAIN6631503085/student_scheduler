import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quote_service.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quoteService = context.read<QuoteService>();
    final quote = quoteService.getRandomQuote();
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quote.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '- ${quote.author}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 