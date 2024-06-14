import 'package:ente/model/review_model.dart';
import 'package:ente/service/review_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String image;
  final String location;
  final String type;
  final String userId; // Tambahkan userId
  final String warungmakanId; // Tambahkan warungmakanId

  const DetailPage({
    Key? key,
    required this.title,
    required this.image,
    required this.location,
    required this.type,
    required this.userId, // Tambahkan userId
    required this.warungmakanId, // Tambahkan warungmakanId
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  double rating = 0.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: FutureBuilder<Review?>(
        future:
            ReviewService().fetchReview(widget.userId, widget.warungmakanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Review? review = snapshot.data;
            if (review != null) {
              // Update controllers and rating
              nameController.text = review.name;
              reviewController.text = review.review;
              rating = review.rating.toDouble();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      widget.image,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/default_image.png'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                widget.location,
                                style: const TextStyle(
                                    fontSize: 18.0, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            widget.type,
                            style: const TextStyle(
                                fontSize: 18.0, color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => print("Button pressed"),
                        child: const Text('Show Menu'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Text('Write a Review',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text('Rating',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (newRating) => rating = newRating,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      labelText: 'Review',
                      hintText: 'Type your review here',
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16.0),
                  if (review == null) ...[
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() {
                                _isSubmitting = true;
                              });
                              try {
                                await ReviewService().storeReview(
                                  "1",
                                  nameController.text,
                                  reviewController.text,
                                  rating.toInt(),
                                  widget.warungmakanId,
                                );
                                setState(() {
                                  _isSubmitting = false;
                                });
                              } catch (e) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to submit review.'),
                                  ),
                                );
                              }
                            },
                      child: _isSubmitting
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Submit'),
                    ),
                  ]
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
