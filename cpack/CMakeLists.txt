SET (CONTACT "backbone@backbone.ws")
SET (DEBIAN_DEPENDENCIES "valac (>= 0.24), libgtk-3-0 (>= 3.20)")
SET (DEBIAN_SECTION "Libraries")
SET (REDHAT_DEPENDENCIES "vala >= 0.24, gtk+ >= 3.20")
SET (REDHAT_SECTION "Development/Libraries")
SET (LICENSE "LGPLv3+")
SET (WIN32_UNINSTALL_NAME "GtkChart") # <= 8 symbols for the name
SET (CPACK_NSIS_MENU_LINKS "https://redmine.backbone.ws/projects/gtkchart"
                           "Homepage for GtkChart")
INCLUDE (CPackCommonRules)
