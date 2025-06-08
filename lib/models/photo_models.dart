class InspirationPhoto {
  final String id;
  final String author;
  final String url;
  final String downloadUrl;

  InspirationPhoto({
    required this.id,
    required this.author,
    required this.url,
    required this.downloadUrl,
  });

  factory InspirationPhoto.fromJson(Map<String, dynamic> json) {
    return InspirationPhoto(
      id: json['id'].toString(),
      author: json['author'] ?? 'Unknown',
      url: json['url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}
