import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/page/settings_page.dart';
import '../provider/weather_provider.dart';
import '../utils/constrant.dart';
import '../utils/helper_function.dart';
import '../utils/location_service.dart';
import '../utils/text_style.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName = '/weather';
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherProvider provider;
  bool isFirst = true;
  @override
  void didChangeDependencies() {
    if (isFirst) {
      provider = Provider.of<WeatherProvider>(context);
      _detectLocation();

      isFirst = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Weather'),
        actions: [
          IconButton(onPressed: () {
            _detectLocation();
          }, icon: const Icon(Icons.location_on)),
          IconButton(
              onPressed: () async {
                final result = await showSearch(
                    context: context, delegate: _CitySearchDelegate());
                if (result != null && result.isNotEmpty) {
                  provider.convertCityToLatLong(result:result,onErr: (msg){
                    showMsg(context, msg);
                  });
                }
              },
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, SettingsPage.routeName),
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: Center(
        child: provider.hasDataLocated
            ? ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                children: [
                  _currentWeatherSection(),
                  _forecastWeatherSection(),
                ],
              )
            : const Text('Please wait'),
      ),
    );
  }

  void _detectLocation() async {
   try{
     final position = await determinePosition();
     provider.setNewLocation(position.latitude, position.longitude);
     provider.setTempUnit(await provider.getTempUnitPreferenceValue());
     provider.getWeatherData();
   }catch(e){
     showMsg(context, e.toString());
   }
  }

  Widget _currentWeatherSection() {
    final current = provider.currentResponseModel;
    return Column(
      children: [
        Text(
          getFormattedDateTime(
            current!.dt!,
            'MMM dd, yyyy',
          ),
          style: txtNormal16,
        ),
        Text(
          '${current.name}, ${current.sys!.country}',
          style: txtDateBig18,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                '$iconPrefix${current.weather![0].icon}$iconSuffix',
                fit: BoxFit.cover,
              ),
              Text(
                '${current.main!.temp!.round()}$degree${provider.unitSymbol}',
                style: txtTempBig80,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'feels like ${current.main!.feelsLike}$degree${provider.unitSymbol}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '${current.weather![0].main} ${current.weather![0].description}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          children: [
            Text(
              'Humidity ${current.main!.humidity}% ',
              style: txtNormal16,
            ),
            Text(
              'Pressure ${current.main!.pressure}hPa ',
              style: txtNormal16,
            ),
            Text(
              'Visibility ${current.visibility}meter ',
              style: txtNormal16,
            ),
            Text(
              'Wind Speed ${current.wind!.speed}meter/sec ',
              style: txtNormal16,
            ),
            Text(
              'Degree ${current.wind!.deg}$degree ',
              style: txtNormal16,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          children: [
            Text(
              'Sunrise: ${getFormattedDateTime(current.sys!.sunrise!, 'hh:mm a')}',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Sunset: ${getFormattedDateTime(current.sys!.sunset!, 'hh:mm a')}',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        )
      ],
    );
  }

  Widget _forecastWeatherSection() {
    final foreCast = provider.forecastResponseModel;
    return Container(
      color: Colors.blueGrey.shade700,
      child: Column(
        children: foreCast!.list!
            .map((e) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        '$iconPrefix${e.weather![0].icon}$iconSuffix'),
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(
                    getFormattedDateTime(e.dt!, 'MMM dd,yyy'),
                    style: txtNormal16,
                  ),
                  subtitle: Text(
                    e.weather![0].description!,
                    style: txtNormal16,
                  ),
                  trailing: Text(
                    '${e.main!.temp!.round()}$degree${provider.unitSymbol}',
                    style: txtNormal16,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    // final filterList=q
    if (query.isNotEmpty && query != null) {}

    return ListTile(
      leading: Icon(Icons.search),
      title: Text(query),
      onTap: (){
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filterList = query.isEmpty
        ? cities
        : cities
            .where((element) => element.toLowerCase() == query.toLowerCase())
            .toList();
    return ListView.builder(
      itemCount: filterList.length,
      itemBuilder: (context, index) => ListTile(onTap: (){
        query=filterList[index];
        close(context, query);
      },
        title: Text(filterList[index],

        ),

      ),
    );
  }
}
