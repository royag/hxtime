haxe -java outjava -cp . -main Main -debug
"%JAVA_HOME%\bin\jar.exe" uvf outjava\Main-Debug.jar assets
"\Program Files (x86)\Java\jre7\bin\java.exe" -jar outjava\Main-Debug.jar
