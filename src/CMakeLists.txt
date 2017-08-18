SET (LibName ${PROJECT_LOWERCASE_NAME})
FILE (GLOB_RECURSE LibSources RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.vala)
SET (LibPackages cairo gtk+-3.0)
SET (LibPkgModules gtk+-3.0)
SET (LibInstall ON)
SET (LibExtraSources ${CMAKE_CURRENT_BINARY_DIR}/library_constructor.c)
SET (LC_RELATIVE_PREFIX "..")
CONFIGURE_FILE ( "${CMAKE_SOURCE_DIR}/cmake/backbone/templates/library_constructor.c.in" "${LibExtraSources}")
INCLUDE_DIRECTORIES ("${CMAKE_SOURCE_DIR}/src")
SET (LibCustomVapis ${CMAKE_SOURCE_DIR}/src/cairo-chart-float128type.vapi)
INCLUDE (ValaLibCommonRules)
INSTALL (FILES ${CMAKE_CURRENT_SOURCE_DIR}/cairo-chart-float128type.h DESTINATION include
         RENAME cairo-chart-float128type-${MAJOR}.h)
INSTALL (FILES ${CMAKE_CURRENT_SOURCE_DIR}/cairo-chart-float128type.vapi DESTINATION share/vala/vapi
         RENAME cairo-chart-float128type-${MAJOR}.vapi)
CONFIGURE_FILE (${CMAKE_CURRENT_SOURCE_DIR}/cairo-chart.deps.in
                ${CMAKE_CURRENT_BINARY_DIR}/cairo-chart-${MAJOR}.deps)
INSTALL (FILES ${CMAKE_CURRENT_BINARY_DIR}/cairo-chart-${MAJOR}.deps DESTINATION share/vala/vapi)
