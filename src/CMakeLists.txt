find_package (PkgConfig)

# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED gthread-2.0 gtk+-3.0 gio-2.0 libnotify wingpanel-2.0 granite)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.26.0")

include (ValaPrecompile)
# Add all your vala files and requires packages to the List below to include them in the build
vala_precompile (VALA_C ${CMAKE_PROJECT_NAME}
  Indicator.vala
  Services/Manager.vala
  Services/Adapter.vala
  Services/Device.vala
  Widgets/Device.vala
  Widgets/PopoverWidget.vala
  Widgets/DisplayWidget.vala
  Widgets/Views/DiscoveryView.vala
  Widgets/Views/MainView.vala
  ${CMAKE_CURRENT_BINARY_DIR}/config.vala
PACKAGES
  gio-2.0
  gtk+-3.0
  libnotify
  wingpanel-2.0
  granite
OPTIONS
  --thread
  --target-glib=2.32
)

include (GResource)
glib_compile_resources (GLIB_RESOURCES_CSS SOURCE ../data/io.elementary.wingpanel.bluetooth.gresource.xml)

add_library (${CMAKE_PROJECT_NAME} MODULE ${VALA_C} ${GLIB_RESOURCES_CSS})
target_link_libraries(${CMAKE_PROJECT_NAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${CMAKE_PROJECT_NAME} DESTINATION ${PKGDATADIR})
