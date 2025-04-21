import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({super.key});

  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 작성'),
        actions: [
          TextButton(
            onPressed: _rating > 0 ? () => _submitReview(context) : null,
            child: Text(
              '완료',
              style: TextStyle(
                color: _rating > 0 ? Colors.pinkAccent : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onLongPress: () => HapticFeedback.vibrate(), // 진동 피드백 제공
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이 작품 어떠셨나요?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Center(
                child: RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.pinkAccent,
                  ),
                  onRatingUpdate: (rating) => setState(() => _rating = rating),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _reviewController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '작품에 대한 감상을 자유롭게 남겨주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview(BuildContext context) async {
    HapticFeedback.mediumImpact(); // 제출 시 진동

    final reviewText = _reviewController.text.trim();

    final snackBar = SnackBar(
      content: Text('리뷰가 제출되었습니다! (평점: $_rating)'),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      await Supabase.instance.client.from('reviews').insert({
        'rating': _rating,
        'review': reviewText,
      });

      // 업로드 성공 시 창 닫기
      if (context.mounted) {
        setState(() {
          _rating = 0;
          _reviewController.clear();
        });

        Navigator.pop(context, {
          'rating': _rating,
          'review': reviewText,
        });
      }
    } catch (error) {
      // 에러 핸들링
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 업로드 실패: $error')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
