import 'package:flutter/material.dart';
import '../models/book.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final Book book;

  const ReaderScreen({
    super.key,
    required this.chapter,
    required this.book,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool isSlidingMode = true; // Default to sliding mode
  List<String> pages = [];
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _generatePages();
  }

  void _generatePages() {
    const int chunkSize = 900; // Characters per page
    final text = widget.chapter.rewrittenText;
    
    pages.clear();
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      pages.add(text.substring(i, end));
    }
  }

  void _toggleReadingMode() {
    setState(() {
      isSlidingMode = !isSlidingMode;
    });
  }

  void _nextPage() {
    if (currentPageIndex < pages.length - 1) {
      setState(() {
        currentPageIndex++;
      });
    }
  }

  void _previousPage() {
    if (currentPageIndex > 0) {
      setState(() {
        currentPageIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isSlidingMode ? Icons.view_list : Icons.view_carousel),
            onPressed: _toggleReadingMode,
            tooltip: isSlidingMode ? 'Switch to Scrolling' : 'Switch to Sliding',
          ),
        ],
      ),
      body: isSlidingMode ? _buildSlidingReader() : _buildScrollingReader(),
      bottomNavigationBar: isSlidingMode ? _buildPageNavigation() : null,
    );
  }

  Widget _buildSlidingReader() {
    return GestureDetector(
      onTapUp: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.localPosition.dx < screenWidth / 2) {
          _previousPage();
        } else {
          _nextPage();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Page content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    pages.isNotEmpty ? pages[currentPageIndex] : '',
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Page indicator
            Text(
              'Page ${currentPageIndex + 1} of ${pages.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollingReader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.chapter.rewrittenText,
          style: const TextStyle(
            fontSize: 18,
            height: 1.6,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: currentPageIndex > 0 ? _previousPage : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          
          Text(
            '${currentPageIndex + 1} / ${pages.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          
          ElevatedButton.icon(
            onPressed: currentPageIndex < pages.length - 1 ? _nextPage : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
