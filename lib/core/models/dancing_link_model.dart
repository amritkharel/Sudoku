class DLXNode {
  DLXNode? left;
  DLXNode? right;
  DLXNode? up;
  DLXNode? down;
  ColumnNode? column;
  int rowID;
  int columnID;

  DLXNode({this.column, this.rowID = -1, this.columnID = -1}) {
    left = right = up = down = this;
  }
}

class ColumnNode extends DLXNode {
  int size = 0;
  String name;

  ColumnNode({required this.name}) : super(rowID: -1, columnID: -1);
}
