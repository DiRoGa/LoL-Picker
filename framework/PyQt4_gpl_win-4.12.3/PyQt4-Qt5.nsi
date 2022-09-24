# PyQt4 with Qt5 NSIS installer script.
# 
# Copyright (c) 2018 Riverbank Computing Limited <info@riverbankcomputing.com>
# 
# This file is part of PyQt4.
# 
# This file may be used under the terms of the GNU General Public License
# version 3.0 as published by the Free Software Foundation and appearing in
# the file LICENSE included in the packaging of this file.  Please review the
# following information to ensure the GNU General Public License version 3.0
# requirements will be met: http://www.gnu.org/copyleft/gpl.html.
# 
# If you do not wish to use this file under the terms of the GPL version 3.0
# then you may purchase a commercial license.  For more information contact
# info@riverbankcomputing.com.
# 
# This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
# WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.


# These will change with different releases.
!define PYQT_VERSION        "4.12.3"
!define PYQT_INSTALLER      ""
#!define PYQT_INSTALLER      "-2"
!define PYQT_LICENSE        "GPL"
!define PYQT_LICENSE_LC     "gpl"
!define PYQT_PYTHON_MAJOR   "3"
!define PYQT_PYTHON_MINOR   "5"
!define PYQT_ARCH           "64"
!define PYQT_QT_VERS        "5.5.0"
!define PYQT_QT_DOC_VERS    "5"

# These are all derived from the above.
!define PYQT_PYTHON_DIR     "C:\Python${PYQT_PYTHON_MAJOR}${PYQT_PYTHON_MINOR}"
!define PYQT_PYTHON_VERS    "${PYQT_PYTHON_MAJOR}.${PYQT_PYTHON_MINOR}"
!define PYQT_PYTHON_HK      "Software\Python\PythonCore\${PYQT_PYTHON_VERS}\InstallPath"
!define PYQT_PYTHON_HK_ARCH "Software\Python\PythonCore\${PYQT_PYTHON_VERS}-${PYQT_ARCH}\InstallPath"
!define PYQT_NAME           "PyQt ${PYQT_LICENSE} v${PYQT_VERSION} for Python v${PYQT_PYTHON_VERS} (x${PYQT_ARCH})"
!define PYQT_HK_ROOT        "Software\PyQt4\Py${PYQT_PYTHON_VERS}"
!define PYQT_HK             "${PYQT_HK_ROOT}\InstallPath"
!define PYQT5_HK            "Software\PyQt5\Py${PYQT_PYTHON_VERS}\InstallPath"
!define QT_SRC_DIR          "C:\Qt\${PYQT_QT_VERS}"
!define ICU_SRC_DIR         "C:\icu"
!define OPENSSL_SRC_DIR     "C:\OpenSSL"
!define MYSQL_SRC_DIR       "C:\MySQL"


# Include the tools we use.
!include MUI2.nsh
!include LogicLib.nsh
!include AddToPath.nsh


# Tweak some of the standard pages.
!define MUI_WELCOMEPAGE_TEXT \
"This wizard will guide you through the installation of ${PYQT_NAME}.$\r$\n\
$\r$\n\
This copy of PyQt includes a subset of Qt v${PYQT_QT_VERS} Open Source \
Edition needed by PyQt. It also includes MySQL, ODBC, PostgreSQL and SQLite \
drivers and the required OpenSSL DLLs.$\r$\n\
$\r$\n\
Any code you write must be released under a license that is compatible with \
the GPL.$\r$\n\
$\r$\n\
Click Next to continue."

!define MUI_FINISHPAGE_LINK "Get the latest news of PyQt here"
!define MUI_FINISHPAGE_LINK_LOCATION "http://www.riverbankcomputing.com"


# Define the product name and installer executable.
Name "PyQt"
Caption "${PYQT_NAME} Setup"
OutFile "PyQt4-${PYQT_VERSION}-${PYQT_LICENSE_LC}-Py${PYQT_PYTHON_MAJOR}.${PYQT_PYTHON_MINOR}-Qt${PYQT_QT_VERS}-x${PYQT_ARCH}${PYQT_INSTALLER}.exe"


# This is done (along with the use of SetShellVarContext) so that we can remove
# the shortcuts when uninstalling under Vista and Windows 7.  Note that we
# don't actually check if it is successful.
RequestExecutionLevel admin


# The different installation types.  "Full" is everything.  "Minimal" is the
# runtime environment.
InstType "Full"
InstType "Minimal"


# Maximum compression.
SetCompressor /SOLID lzma


# We want the user to confirm they want to cancel.
!define MUI_ABORTWARNING

Function .onInit
    ${If} ${PYQT_ARCH} == "64"
        SetRegView 64
    ${Endif}

    # Check if there is already a version of PyQt5 installed for this version
    # of Python.
    ReadRegStr $0 HKCU "${PYQT5_HK}" ""

    ${If} $0 == ""
        ReadRegStr $0 HKLM "${PYQT5_HK}" ""
    ${Endif}

    ${If} $0 != ""
        MessageBox MB_OK \
"A copy of PyQt5 for Python v${PYQT_PYTHON_VERS} is already installed in $0 \
and must be uninstalled first."
            Abort
    ${Endif}

    # Check if there is already a version of PyQt4 installed for this version
    # of Python.
    ReadRegStr $0 HKCU "${PYQT_HK}" ""

    ${If} $0 == ""
        ReadRegStr $0 HKLM "${PYQT_HK}" ""
    ${Endif}

    ${If} $0 != ""
        MessageBox MB_YESNO|MB_DEFBUTTON2|MB_ICONQUESTION \
"A copy of PyQt4 for Python v${PYQT_PYTHON_VERS} is already installed in $0 \
and should be uninstalled first.$\r$\n \
$\r$\n\
Do you wish to uninstall it?" IDYES Uninstall
            Abort
Uninstall:
        ExecWait '"$0\Lib\site-packages\PyQt4\Uninstall.exe" /S'
    ${Endif}

    # Check the right version of Python has been installed.  Different versions
    # of Python use different formats for the version number.
    ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK}" ""

    ${If} $INSTDIR == ""
        ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK_ARCH}" ""

        ${If} $INSTDIR == ""
            ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK}" ""

            ${If} $INSTDIR == ""
                ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK_ARCH}" ""
            ${Endif}
        ${Endif}
    ${Endif}

    ${If} $INSTDIR == ""
        MessageBox MB_YESNO|MB_ICONQUESTION \
"This copy of PyQt has been built against Python v${PYQT_PYTHON_VERS} \
(x${PYQT_ARCH}) which doesn't seem to be installed.$\r$\n\
$\r$\n\
Do you wish to continue with the installation?" IDYES GotPython
            Abort
GotPython:
        StrCpy $INSTDIR "${PYQT_PYTHON_DIR}"
    ${Endif}
FunctionEnd


# Define the different pages.
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE ".\LICENSE"
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Python installation folder"
!define MUI_DIRECTORYPAGE_TEXT_TOP \
"PyQt will be installed in the site-packages folder of your Python \
installation."
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

 
# Other settings.
!insertmacro MUI_LANGUAGE "English"


# Installer sections.

Section "Extension modules" SecModules
    SectionIn 1 2 RO

    SetOverwrite on

    # We have to take the SIP files from where they should have been installed.
    SetOutPath $INSTDIR\Lib\site-packages
    File "${PYQT_PYTHON_DIR}\Lib\site-packages\sip.pyd"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File .\LICENSE
    File .\__init__.py
    File /r .\pyuic\uic

    File .\build\Qt\Qt.pyd
    File .\build\QtCore\QtCore.pyd
    File .\build\QtDeclarative\QtDeclarative.pyd
    File .\build\QtDesigner\QtDesigner.pyd
    File .\build\QtGui\QtGui.pyd
    File .\build\QtHelp\QtHelp.pyd
    File .\build\QtMultimedia\QtMultimedia.pyd
    File .\build\QtNetwork\QtNetwork.pyd
    File .\build\QtOpenGL\QtOpenGL.pyd
    File .\build\QtScript\QtScript.pyd
    File .\build\QtScriptTools\QtScriptTools.pyd
    File .\build\QtSql\QtSql.pyd
    File .\build\QtSvg\QtSvg.pyd
    File .\build\QtTest\QtTest.pyd
    File .\build\QtWebKit\QtWebKit.pyd
    File .\build\QtXml\QtXml.pyd
    File .\build\QtXmlPatterns\QtXmlPatterns.pyd
    File .\build\QAxContainer\QAxContainer.pyd
SectionEnd

Section "QScintilla" SecQScintilla
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt4\Qsci.pyd"
    File /r "${QT_SRC_DIR}\qsci"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File "${QT_SRC_DIR}\lib\qscintilla2.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\translations
    File "${QT_SRC_DIR}\translations\qscintilla*.qm"
SectionEnd

Section "Qt runtime" SecQt
    SectionIn 1 2

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File "${QT_SRC_DIR}\bin\Qt5CLucene.dll"
    File "${QT_SRC_DIR}\bin\Qt5Core.dll"
    File "${QT_SRC_DIR}\bin\Qt5Declarative.dll"
    File "${QT_SRC_DIR}\bin\Qt5Designer.dll"
    File "${QT_SRC_DIR}\bin\Qt5DesignerComponents.dll"
    File "${QT_SRC_DIR}\bin\Qt5Gui.dll"
    File "${QT_SRC_DIR}\bin\Qt5Help.dll"
    File "${QT_SRC_DIR}\bin\Qt5Multimedia.dll"
    File "${QT_SRC_DIR}\bin\Qt5MultimediaWidgets.dll"
    File "${QT_SRC_DIR}\bin\Qt5Network.dll"
    File "${QT_SRC_DIR}\bin\Qt5OpenGL.dll"
    File "${QT_SRC_DIR}\bin\Qt5Positioning.dll"
    File "${QT_SRC_DIR}\bin\Qt5PrintSupport.dll"
    File "${QT_SRC_DIR}\bin\Qt5Qml.dll"
    File "${QT_SRC_DIR}\bin\Qt5Quick.dll"
    File "${QT_SRC_DIR}\bin\Qt5Script.dll"
    File "${QT_SRC_DIR}\bin\Qt5ScriptTools.dll"
    File "${QT_SRC_DIR}\bin\Qt5Sensors.dll"
    File "${QT_SRC_DIR}\bin\Qt5Sql.dll"
    File "${QT_SRC_DIR}\bin\Qt5Svg.dll"
    File "${QT_SRC_DIR}\bin\Qt5Test.dll"
    File "${QT_SRC_DIR}\bin\Qt5WebChannel.dll"
    File "${QT_SRC_DIR}\bin\Qt5WebKit.dll"
    File "${QT_SRC_DIR}\bin\Qt5WebKitWidgets.dll"
    File "${QT_SRC_DIR}\bin\Qt5Widgets.dll"
    File "${QT_SRC_DIR}\bin\Qt5Xml.dll"
    File "${QT_SRC_DIR}\bin\Qt5XmlPatterns.dll"
    File "${QT_SRC_DIR}\bin\QtWebProcess.exe"

    File "${QT_SRC_DIR}\bin\libEGL.dll"
    File "${QT_SRC_DIR}\bin\libGLESv2.dll"

    File "${ICU_SRC_DIR}\bin\icudt55.dll"
    File "${ICU_SRC_DIR}\bin\icuin55.dll"
    File "${ICU_SRC_DIR}\bin\icuuc55.dll"

    File "${OPENSSL_SRC_DIR}\bin\libeay32.dll"
    File "${OPENSSL_SRC_DIR}\bin\ssleay32.dll"

    File "${MYSQL_SRC_DIR}\lib\libmysql.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\imports\Qt\labs\folderlistmodel
    File "${QT_SRC_DIR}\imports\Qt\labs\folderlistmodel\qmldir"
    File "${QT_SRC_DIR}\imports\Qt\labs\folderlistmodel\qmlfolderlistmodelplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\imports\Qt\labs\gestures
    File "${QT_SRC_DIR}\imports\Qt\labs\gestures\qmldir"
    File "${QT_SRC_DIR}\imports\Qt\labs\gestures\qmlgesturesplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\imports\Qt\labs\particles
    File "${QT_SRC_DIR}\imports\Qt\labs\particles\qmldir"
    File "${QT_SRC_DIR}\imports\Qt\labs\particles\qmlparticlesplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\imports\Qt\labs\shaders
    File "${QT_SRC_DIR}\imports\Qt\labs\shaders\qmldir"
    File "${QT_SRC_DIR}\imports\Qt\labs\shaders\qmlshadersplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\imports\QtWebKit
    File "${QT_SRC_DIR}\imports\QtWebKit\qmldir"
    File "${QT_SRC_DIR}\imports\QtWebKit\qmlwebkitplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\plugins\bearer
    File "${QT_SRC_DIR}\plugins\bearer\qgenericbearer.dll"
    File "${QT_SRC_DIR}\plugins\bearer\qnativewifibearer.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\plugins\iconengines
    File "${QT_SRC_DIR}\plugins\iconengines\qsvgicon.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\plugins\imageformats
    File "${QT_SRC_DIR}\plugins\imageformats\qdds.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qgif.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qicns.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qico.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qjp2.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qjpeg.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qmng.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qsvg.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qtga.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qtiff.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qwbmp.dll"
    File "${QT_SRC_DIR}\plugins\imageformats\qwebp.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\plugins\platforms
    File "${QT_SRC_DIR}\plugins\platforms\qminimal.dll"
    File "${QT_SRC_DIR}\plugins\platforms\qwindows.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\plugins\printsupport
    File "${QT_SRC_DIR}\plugins\printsupport\windowsprintersupport.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\plugins\sqldrivers
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlite.dll"
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlmysql.dll"
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlodbc.dll"
    File "${QT_SRC_DIR}\plugins\sqldrivers\qsqlpsql.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\translations
    File "${QT_SRC_DIR}\translations\qt_*.qm"
    File "${QT_SRC_DIR}\translations\qtbase_*.qm"

    # Tell Python and the Qt tools where to find Qt.
    FileOpen $0 $INSTDIR\qt.conf w
    FileWrite $0 "[Paths]$\r$\n"
    FileWrite $0 "Prefix = Lib/site-packages/PyQt4$\r$\n"
    FileWrite $0 "Binaries = Lib/site-packages/PyQt4$\r$\n"
    FileClose $0

    FileOpen $0 $INSTDIR\Lib\site-packages\PyQt4\qt.conf w
    FileWrite $0 "[Paths]$\r$\n"
    FileWrite $0 "Prefix = .$\r$\n"
    FileWrite $0 "Binaries = .$\r$\n"
    FileClose $0
SectionEnd

Section "Developer tools" SecTools
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File .\build\pylupdate\release\pylupdate4.exe
    File .\build\pyrcc\release\pyrcc4.exe

    FileOpen $0 $INSTDIR\Lib\site-packages\PyQt4\pyuic4.bat w
    FileWrite $0 "@$\"$INSTDIR\python$\" $\"$INSTDIR\Lib\site-packages\PyQt4\uic\pyuic.py$\" %1 %2 %3 %4 %5 %6 %7 %8 %9$\r$\n"
    FileClose $0
SectionEnd

Section "Qt developer tools" SecQtTools
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File "${QT_SRC_DIR}\bin\assistant.exe"
    File "${QT_SRC_DIR}\bin\designer.exe"
    File "${QT_SRC_DIR}\bin\linguist.exe"
    File "${QT_SRC_DIR}\bin\lrelease.exe"
    File "${QT_SRC_DIR}\bin\qcollectiongenerator.exe"
    File "${QT_SRC_DIR}\bin\qhelpgenerator.exe"
    File "${QT_SRC_DIR}\bin\qmake.exe"
    File "${QT_SRC_DIR}\bin\xmlpatterns.exe"
    File /r "${QT_SRC_DIR}\mkspecs"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\plugins\designer
    File "${QT_SRC_DIR}\plugins\designer\qdeclarativeview.dll"
    File "${QT_SRC_DIR}\plugins\designer\qwebview.dll"

    File .\build\designer\release\pyqt4.dll
    File "${QT_SRC_DIR}\plugins\designer\qscintillaplugin.dll"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\translations
    File "${QT_SRC_DIR}\translations\assistant_*.qm"
    File "${QT_SRC_DIR}\translations\designer_*.qm"
    File "${QT_SRC_DIR}\translations\linguist_*.qm"
SectionEnd

Section "SIP developer tools" SecSIPTools
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File /r "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt4\sip"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt4\sip.exe"

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4\include
    File "${PYQT_PYTHON_DIR}\Lib\site-packages\PyQt4\include\sip.h"
SectionEnd

Section "Documentation" SecDocumentation
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File /r .\doc
SectionEnd

Section "Examples" SecExamples
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\Lib\site-packages\PyQt4
    File /r .\examples
SectionEnd

Section "Start Menu shortcuts" SecShortcuts
    SectionIn 1

    SetShellVarContext all

    # Make sure this is clean and tidy.
    RMDir /r "$SMPROGRAMS\${PYQT_NAME}"
    CreateDirectory "$SMPROGRAMS\${PYQT_NAME}"

    IfFileExists "$INSTDIR\Lib\site-packages\PyQt4\assistant.exe" 0 +4
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Assistant.lnk" "$INSTDIR\Lib\site-packages\PyQt4\assistant.exe"
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Designer.lnk" "$INSTDIR\Lib\site-packages\PyQt4\designer.exe"
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Linguist.lnk" "$INSTDIR\Lib\site-packages\PyQt4\linguist.exe"

    IfFileExists "$INSTDIR\Lib\site-packages\PyQt4\doc" 0 +5
        CreateDirectory "$SMPROGRAMS\${PYQT_NAME}\Documentation"
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Documentation\PyQt Reference Guide.lnk" "$INSTDIR\Lib\site-packages\PyQt4\doc\html\index.html"
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Documentation\PyQt Class Reference.lnk" "$INSTDIR\Lib\site-packages\PyQt4\doc\html\classes.html"
	CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Documentation\Qt Documentation.lnk" "http://qt-project.org/doc/qt-${PYQT_QT_DOC_VERS}/"

    IfFileExists "$INSTDIR\Lib\site-packages\PyQt4\examples" 0 +6
        CreateDirectory "$SMPROGRAMS\${PYQT_NAME}\Examples"
	SetOutPath $INSTDIR\Lib\site-packages\PyQt4\examples\demos\qtdemo
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Examples\PyQt Examples and Demos.lnk" "$INSTDIR\Lib\site-packages\PyQt4\examples\demos\qtdemo\qtdemo.pyw"
	SetOutPath $INSTDIR
        CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Examples\PyQt Examples Source.lnk" "$INSTDIR\Lib\site-packages\PyQt4\examples"

    CreateDirectory "$SMPROGRAMS\${PYQT_NAME}\Links"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\PyQt Book.lnk" "http://www.qtrac.eu/pyqtbook.html"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\PyQt Homepage.lnk" "http://www.riverbankcomputing.com/software/pyqt/"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\Qt Homepage.lnk" "http://qt.digia.com"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\QScintilla Homepage.lnk" "http://www.riverbankcomputing.com/software/qscintilla/"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\PyQwt Homepage.lnk" "http://pyqwt.sourceforge.net/"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\Qwt Homepage.lnk" "http://qwt.sourceforge.net/"
    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Links\eric Homepage.lnk" "http://eric-ide.python-projects.org/index.html"

    CreateShortCut "$SMPROGRAMS\${PYQT_NAME}\Uninstall PyQt.lnk" "$INSTDIR\Lib\site-packages\PyQt4\Uninstall.exe"
SectionEnd

Section -post
    # Add the bin directory to PATH.
    Push $INSTDIR\Lib\site-packages\PyQt4
    Call AddToPath

    # Tell Windows about the package.
    WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "UninstallString" '"$INSTDIR\Lib\site-packages\PyQt4\Uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "DisplayName" "${PYQT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "DisplayVersion" "${PYQT_VERSION}${PYQT_INSTALLER}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "NoModify" "1"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}" "NoRepair" "1"

    # Save the installation directories for the uninstaller.
    ClearErrors
    WriteRegStr HKLM "${PYQT_HK}" "" $INSTDIR
    IfErrors 0 +2
        WriteRegStr HKCU "${PYQT_HK}" "" $INSTDIR

    # Create the uninstaller.
    WriteUninstaller "$INSTDIR\Lib\site-packages\PyQt4\Uninstall.exe"
SectionEnd


# Section description text.
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecModules} \
"The PyQt and sip extension modules."
!insertmacro MUI_DESCRIPTION_TEXT ${SecQScintilla} \
"QScintilla and its extension module."
!insertmacro MUI_DESCRIPTION_TEXT ${SecQt} \
"The Qt DLLs, plugins and translations."
!insertmacro MUI_DESCRIPTION_TEXT ${SecQtTools} \
"The Qt developer tools: Assistant, Designer, Linguist etc."
!insertmacro MUI_DESCRIPTION_TEXT ${SecTools} \
"The PyQt developer tools: pyuic4, pyrcc4 and pylupdate4."
!insertmacro MUI_DESCRIPTION_TEXT ${SecSIPTools} \
"The SIP developer tools and .sip files."
!insertmacro MUI_DESCRIPTION_TEXT ${SecDocumentation} \
"The PyQt and related documentation."
!insertmacro MUI_DESCRIPTION_TEXT ${SecExamples} \
"Ports to Python of the standard Qt v4 examples."
!insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} \
"This adds shortcuts to your Start Menu."
!insertmacro MUI_FUNCTION_DESCRIPTION_END


Function un.onInit
    ${If} ${PYQT_ARCH} == "64"
        SetRegView 64
    ${Endif}

    # Get the PyQt installation directory.
    ReadRegStr $INSTDIR HKCU "${PYQT_HK}" ""

    ${If} $INSTDIR == ""
        ReadRegStr $INSTDIR HKLM "${PYQT_HK}" ""

        ${If} $INSTDIR == ""
            # Try where Python was installed.
            ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK}" ""

            ${If} $INSTDIR == ""
                ReadRegStr $INSTDIR HKCU "${PYQT_PYTHON_HK_ARCH}" ""

                ${If} $INSTDIR == ""
                    ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK}" ""

                    ${If} $INSTDIR != ""
                        ReadRegStr $INSTDIR HKLM "${PYQT_PYTHON_HK_ARCH}" ""

                        ${If} $INSTDIR != ""
                            # Default to where Python should be installed (at
                            # least prior to v3.5).
                            StrCpy $INSTDIR "${PYQT_PYTHON_DIR}\"
                        ${Endif}
                    ${Endif}
                ${Endif}
            ${Endif}
        ${Endif}
    ${Endif}
FunctionEnd


Section "Uninstall"
    SetShellVarContext all

    # Remove the bin directory from PATH.
    Push $INSTDIR\Lib\site-packages\PyQt4
    Call un.RemoveFromPath

    # The Qt path file.
    Delete $INSTDIR\qt.conf

    # The modules section.
    Delete $INSTDIR\Lib\site-packages\sip.pyd
    RMDir /r $INSTDIR\Lib\site-packages\PyQt4

    # SIP tools section.
    Delete $INSTDIR\Lib\site-packages\sipconfig.*
    Delete $INSTDIR\Lib\site-packages\sipdistutils.*

    # The shortcuts section.
    RMDir /r "$SMPROGRAMS\${PYQT_NAME}"

    # Clean the registry.
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PYQT_NAME}"
    DeleteRegKey HKLM "${PYQT_HK_ROOT}"
    DeleteRegKey HKCU "${PYQT_HK_ROOT}"
SectionEnd
