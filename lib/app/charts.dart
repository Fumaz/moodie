import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:moodie/database/database.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<Series<dynamic, num>> series;
  final bool animate;

  const SimpleTimeSeriesChart({required this.series, required this.animate});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      series,
      animate: animate,
      defaultRenderer:
          LineRendererConfig(includeArea: true, includePoints: true),
      primaryMeasureAxis: NumericAxisSpec(
          showAxisLine: false,
          tickProviderSpec: StaticNumericTickProviderSpec([
            for (int i = 0; i < moods.length; i++)
              TickSpec(i,
                  label: moods[i].emoji,
                  style: TextStyleSpec(fontSize: 20, color: ColorUtil.fromDartColor(moods[i].color)))
          ])),
    );
  }

  static Future<List<Series<Entry, int>>> createSeries() async {
    var data = await last(15);
    data = data.reversed.toList();

    return [
      Series(
        id: 'Moods',
        colorFn: (Entry entry, __) => ColorUtil.fromDartColor(entry.mood.parent.parent.color),
        domainFn: (Entry entry, i) => i!,
        measureFn: (Entry entry, _) => moods.indexOf(entry.mood.parent.parent),
        data: data,
      )
    ];
  }

}
