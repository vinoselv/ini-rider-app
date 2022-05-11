import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/providers/current_location.dart';
import 'package:riderapp/screens/rides_screen.dart';
import 'package:riderapp/screens/search_rides.dart';
import 'package:riderapp/screens/track_screen.dart';
import 'package:riderapp/screens/user_profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

enum FilterOptions {
  Favorites,
  All,
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;
  int _selectedIndex = 0;
  Position currentPosition;
  TabController _tabController;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<CurrentLocation>(context).checkPermissionAndFindLocation(context).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  List<Widget> _widgetOptions() {
    return [
      SearchRidesScreen(currentPosition: currentPosition, goToRidesScreen: goToRidesScreen),
      RidesScreen(tabController: _tabController,),
      TrackScreen(),
      UserProfileScreen(),
    ];
  }
/*
  List<Widget> _widgetOptions = <Widget>[
    SearchRidesScreen(currentPosition: currentPosition,),
    UserProductsScreen(),
    ProductDetailScreen(),
  ];
*/
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void goToRidesScreen(int index) async {
    print("-----> mounted: "  + mounted.toString());
    print("-----> index : "  + index.toString());
    if (mounted) {
      setState(() {
        _selectedIndex = 1;
        _tabController.animateTo(index);
      });
    }
  }
/*
  void setupPositionLocator() async {
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {

      var status = await Permission.location.status;

      if(status.isGranted) {
        await getCurrentPosition();
      } else if (status.isDenied) {
        Map<Permission, PermissionStatus> status = await [Permission.location].request();
        setupPositionLocator();
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => ProgressDialog(status: 'You need to enable the location services to use the app',)
      );
    }


  }

  Future<void> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      currentPosition = position;
      _selectedIndex = _selectedIndex;
    });
    // confirm location
    await HelperMethods.findCordinateAddress(position, context);
  }*/

  @override
  Widget build(BuildContext context) {
    currentPosition = Provider.of<CurrentLocation>(context).position;
    return Scaffold(

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _widgetOptions().elementAt(_selectedIndex),
      //body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: SizedBox(
      child: BottomNavigationBar(
        type : BottomNavigationBarType.fixed,
        selectedItemColor: BrandColors.colorGreen,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      )),
    );
  }
}
