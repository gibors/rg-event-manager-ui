


class Graduation extends StateFulWidget {
  @override
  _GraduationState createState() => _GraduationState();

}

class _GraduationState extends State<Graduation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graduation'),
      ),
      body: Center(
        child: Text('Graduation'),
      ),
    );
  }
}