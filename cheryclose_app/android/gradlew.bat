@ECHO OFF
SETLOCAL

SET DIR=%~dp0
SET WRAPPER_DIR=%DIR%gradle\wrapper
SET WRAPPER_JAR=%WRAPPER_DIR%\gradle-wrapper.jar
SET WRAPPER_URL=https://raw.githubusercontent.com/gradle/gradle/v8.2.1/subprojects/wrapper/src/main/resources/org/gradle/wrapper/gradle-wrapper.jar
SET DEFAULT_JVM_OPTS=-Xmx1536M

IF NOT EXIST "%WRAPPER_JAR%" (
  ECHO Gradle wrapper jar missing — downloading from %WRAPPER_URL%
  IF NOT EXIST "%WRAPPER_DIR%" (
    MKDIR "%WRAPPER_DIR%"
  )
  WHERE curl >NUL 2>&1
  IF %ERRORLEVEL% EQU 0 (
    curl -fsSL %WRAPPER_URL% -o "%WRAPPER_JAR%"
  ) ELSE (
    powershell -Command "Invoke-WebRequest -Uri '%WRAPPER_URL%' -OutFile '%WRAPPER_JAR%'" 2>NUL
  )
  IF NOT EXIST "%WRAPPER_JAR%" (
    ECHO Failed to download gradle-wrapper.jar. Install curl or ensure PowerShell is available.
    EXIT /B 1
  )
)

IF DEFINED JAVA_HOME (
  SET "JAVA_EXE=%JAVA_HOME%\bin\java.exe"
) ELSE (
  SET "JAVA_EXE="
  FOR %%i IN (java.exe) DO SET "JAVA_EXE=%%~$PATH:i"
)

IF NOT EXIST "%JAVA_EXE%" (
  ECHO Java executable not found. Set JAVA_HOME or add java.exe to PATH.
  EXIT /B 1
)

"%JAVA_EXE%" %DEFAULT_JVM_OPTS% -Dorg.gradle.appname=gradlew -classpath "%WRAPPER_JAR%" org.gradle.wrapper.GradleWrapperMain %*
