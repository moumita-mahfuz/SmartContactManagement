import 'package:flutter/material.dart';

class NetworkImageLoader extends StatefulWidget {
  final String imageUrl;

  const NetworkImageLoader({required this.imageUrl});

  @override
  _NetworkImageLoaderState createState() => _NetworkImageLoaderState();
}

class _NetworkImageLoaderState extends State<NetworkImageLoader> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.fitHeight,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                _isLoading = false;
                return child;
              } else if (!_isLoading) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white,),
            ),
          ),
      ],
    );
  }
}