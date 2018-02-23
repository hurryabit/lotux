# lotux.pro
# 22.11.2001

TEMPLATE        =  app
CONFIG          += qt x11 opengl warn_on release
HEADERS         =  mainwindow.h \
                   settings.h \
                   lotus.h \
                   protocol.h \
                   client.h \
                   lotus3d.h \
                   settingsdialog.h \
                   generaltab.h \
                   identitytab.h \
                   networktab.h
SOURCES         =  main.cc \
                   mainwindow.cc \
							     settings.cc \
                   lotus.cc \
                   protocol.cc \
                   client.cc \
                   lotus3d.cc \
                   settingsdialog.cc \
                   generaltab.cc \
                   identitytab.cc \
                   networktab.cc
TRANSLATIONS    += lotux_de.ts
TARGET          =  lotux
DISTFILES       += Makefile \
                   Fakefile \
                   AUTHORS \
                   INSTALL \
                   LICENSE \
                   THANKS \
                   ChangeLog \
                   lotux256.xpm \
                   blackstone.xpm \
                   whitestone.xpm \
                   lotux_en.html \
                   lotus_en.html \
                   lotux_de.html \
                   lotus_de.html

target.path    =  /usr/local/bin
language.files =  *.qm
language.path  =  /usr/local/games/lotux
help.files     = lotu?_??.html
help.path      = /usr/local/games/lotux
INSTALLS       = target language help

# Internal option
static {
	QMAKE_LIBS           = 
	QMAKE_LIBS_OPENGL    = 
	QMAKE_LIBS_QT        = 
	QMAKE_LIBS_OPENGL_QT = 
	QMAKE_LIBS_X11       = 
	QMAKE_LIBS_X11SM     = 
	LIBS                 += -lqt -lGLU -lGL \
	                        -lXmu -lXi -lXt -lXext -lXrender -lXinerama -lX11 \
	                        -lSM -lICE -ldl -lm
	QMAKE_LFLAGS_SHAPP   += -static
	TARGET               =  lotux.static
}

