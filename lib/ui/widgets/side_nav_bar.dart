import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:sidebar_with_animation/animated_side_bar.dart';
import '../screens/pantalla_radios.dart';
import '../screens/pantalla_musica_exclusiva.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobileOrTabScreen = size.width < 480;
    final homeScreenController = Get.find<HomeScreenController>();
    
    return Align(
      alignment: Alignment.topCenter,
      child: isMobileOrTabScreen
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: IntrinsicHeight(
                child: Obx(
                  () => NavigationRail(
                    useIndicator: !isMobileOrTabScreen,
                    selectedIndex:
                        homeScreenController.tabIndex.value, 
                    onDestinationSelected:
                        homeScreenController.onSideBarTabSelected,
                    minWidth: 60,
                    leading: SizedBox(height: size.height < 750 ? 30 : 60),
                    minExtendedWidth: 250,
                    extended: !isMobileOrTabScreen,
                    labelType: isMobileOrTabScreen
                        ? NavigationRailLabelType.all
                        : NavigationRailLabelType.none,
                    destinations: <NavigationRailDestination>[
                      railDestination("home".tr, isMobileOrTabScreen, Icons.home), // Índice 0
                      railDestination("songs".tr, isMobileOrTabScreen, Icons.art_track), // Índice 1
                      railDestination("playlists".tr, isMobileOrTabScreen, Icons.featured_play_list), // Índice 2
                      railDestination("albums".tr, isMobileOrTabScreen, Icons.album), // Índice 3
                      railDestination("artists".tr, isMobileOrTabScreen, Icons.people), // Índice 4
                      
                      // SETTINGS PASA A SER EL ÍNDICE 5
                      const NavigationRailDestination(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        icon: Icon(Icons.settings),
                        label: SizedBox.shrink(),
                        selectedIcon: Icon(Icons.settings),
                      ),
                      
                      // RADIOS Y EXCLUSIVAS PASAN A SER 6 Y 7
                      railDestination("Radios".tr, isMobileOrTabScreen, Icons.radio_rounded),
                      railDestination("Exclusivas".tr, isMobileOrTabScreen, Icons.star_rounded),
                    ],
                  ),
                ),
              ))
          : Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SideBarAnimated(
                onTap: homeScreenController.onSideBarTabSelected,
                sideBarColor: Theme.of(context).primaryColor.withAlpha(250),
                animatedContainerColor: Theme.of(context).colorScheme.secondary,
                hoverColor:
                    Theme.of(context).colorScheme.secondary.withAlpha(180),
                splashColor: Theme.of(context).colorScheme.secondary,
                highlightColor:
                    Theme.of(context).colorScheme.secondary.withAlpha(180),
                widthSwitch: 800,
                mainLogoImage: 'assets/icons/icon.png',
                sidebarItems: [
                  SideBarItem(
                    iconSelected: Icons.home,
                    iconUnselected: Icons.home_outlined,
                    text: 'home'.tr,
                  ), // Índice 0
                  SideBarItem(
                    iconSelected: Icons.audiotrack,
                    iconUnselected: Icons.audiotrack,
                    text: 'songs'.tr,
                  ), // Índice 1
                  SideBarItem(
                    iconSelected: Icons.library_music,
                    iconUnselected: Icons.library_music_outlined,
                    text: 'playlists'.tr,
                  ), // Índice 2
                  SideBarItem(
                    iconSelected: Icons.album,
                    iconUnselected: Icons.album_outlined,
                    text: 'albums'.tr,
                  ), // Índice 3
                  SideBarItem(
                    iconSelected: Icons.person,
                    text: 'artists'.tr,
                  ), // Índice 4
                  SideBarItem(
                    iconSelected: Icons.settings,
                    iconUnselected: Icons.settings_outlined,
                    text: 'settings'.tr,
                  ), // Índice 5
                  
                  // AGREGADOS PARA PANTALLAS GRANDES (Índices 6 y 7)
                  SideBarItem(
                    iconSelected: Icons.radio_rounded,
                    iconUnselected: Icons.radio_outlined,
                    text: 'Radios'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.star_rounded,
                    iconUnselected: Icons.star_outline_rounded,
                    text: 'Exclusivas'.tr,
                  ),
                ],
              ),
            ),
    );
  }

  NavigationRailDestination railDestination(
      String label, bool isMobileOrTabScreen, IconData icon) {
    return isMobileOrTabScreen
        ? NavigationRailDestination(
            icon: const SizedBox.shrink(),
            label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: isMobileOrTabScreen
                    ? RotatedBox(quarterTurns: -1, child: Text(label))
                    : Text(label)),
          )
        : NavigationRailDestination(
            icon: Icon(icon),
            label: Text(label),
            padding: const EdgeInsets.only(left: 10),
            indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            indicatorColor: Colors.amber);
  }
}
