import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:metal/gen/assets.gen.dart';

class RatingWidget extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;

  const RatingWidget(
      {super.key, required this.initialRating, required this.onRatingChanged});

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _rating = index + 1;
              });
              widget.onRatingChanged(_rating);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                index < _rating
                    ? Assets.images.activeStar.path
                    : Assets.images.inactiveStar.path,
                width: 37,
                height: 37,
              ),
            ),
          );
        }),
      ),
    );
  }
}
