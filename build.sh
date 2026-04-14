#!/bin/bash
TOMCAT_HOME="/opt/homebrew/Cellar/tomcat@9/9.0.117/libexec"
WEBAPP="src/main/webapp"
DEPLOY="$TOMCAT_HOME/webapps/koi-pond-manager"

# Compile Java sources
mkdir -p "$WEBAPP/WEB-INF/classes"
javac -cp "$TOMCAT_HOME/lib/servlet-api.jar:$WEBAPP/WEB-INF/lib/*" \
    -d "$WEBAPP/WEB-INF/classes" \
    src/main/java/com/koi/*.java

if [ $? -ne 0 ]; then
    echo "Build failed."
    exit 1
fi

# Deploy to Tomcat
rm -rf "$DEPLOY"
cp -r "$WEBAPP" "$DEPLOY"

echo "Build and deploy complete. Visit http://localhost:8082/koi-pond-manager/"
