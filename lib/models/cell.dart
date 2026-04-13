class Cell {
  int? value;
  Set<int> candidates;
  bool isFixed;
  bool isError;

  Cell({
    this.value,
    Set<int>? candidates,
    this.isFixed = false,
    this.isError = false,
  }) : candidates = candidates ?? <int>{};

  factory Cell.empty() => Cell();

  factory Cell.fixed(int value) => Cell(
        value: value,
        isFixed: true,
      );

  Cell copyWith({
    int? Function()? value,
    Set<int>? candidates,
    bool? isFixed,
    bool? isError,
  }) {
    return Cell(
      value: value != null ? value() : this.value,
      candidates: candidates ?? Set<int>.from(this.candidates),
      isFixed: isFixed ?? this.isFixed,
      isError: isError ?? this.isError,
    );
  }

  @override
  String toString() {
    if (value != null) return '$value${isFixed ? '*' : ''}';
    return '.';
  }
}
