#!/bin/bash
TOMCAT_HOME="$HOME/apache-tomcat-9.0.117"
WEBAPP="src/main/webapp"
DEPLOY="$TOMCAT_HOME/webapps/koi"

mkdir -p "$WEBAPP/WEB-INF/classes"
javac -cp "$TOMCAT_HOME/lib/servlet-api.jar:$WEBAPP/WEB-INF/lib/*" \
    -d "$WEBAPP/WEB-INF/classes" \
    src/main/java/com/koi/*.java

if [ $? -ne 0 ]; then
    echo "Build failed."
    exit 1
fi

rm -rf "$DEPLOY"
cp -r "$WEBAPP" "$DEPLOY"

echo "Build and deploy complete. Visit http://localhost:8080/koi/index.jsp"

