class GraphQuery<T> {
  final List<T> items;

  GraphQuery(this.items);

  GraphQuery<T> whereProperty(String Function(T item) propertySelector, bool Function(String value) predicate) {
    final filtered = items.where((item) => predicate(propertySelector(item))).toList();
    return GraphQuery<T>(filtered);
  }

  List<T> toList() => List.unmodifiable(items);
}
