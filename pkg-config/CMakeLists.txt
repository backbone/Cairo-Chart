INCLUDE (PkgConfigCommonRules)

SET (PkgConfigLibs "-L\${libdir}")
IF (WIN32)
  SET (PkgConfigLibs "${PkgConfigLibs} -l${PROJECT_LOWERCASE_NAME}-${MAJOR}")
ELSE (WIN32)
  SET (PkgConfigLibs "${PkgConfigLibs} -l${PROJECT_LOWERCASE_NAME}.so.${MAJOR}")
ENDIF (WIN32)

CONFIGURE_FILE (
  "${CMAKE_SOURCE_DIR}/cmake/backbone/templates/pkg-config.pc.in"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_LOWERCASE_NAME}-${MAJOR}.pc"
)
