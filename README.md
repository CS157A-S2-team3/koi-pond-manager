# CS157A-S2-Team3

## Project Title
Koi Pond Manager

## Team Members
- Eli Garcia
- Julie Nguyen
- Yuji Nishi

## Project Description
The Koi Pond Manager is a database-driven application designed to help koi dealers and hobbyists manage multiple ponds efficiently and safely. The system tracks:

- Pond information and capacity
- Koi inventory and movement history
- Stocking density
- Water quality measurements
- Maintenance logs
- Treatment and medication records

The application centralizes pond operations, reduces human error, and helps prevent fish loss caused by missed maintenance, unsafe water conditions, or incorrect treatment dosing.

## Tech Stack
- Language: Java, JSP, HTML/CSS
- Framework: Java Servlets with JSP
- Application Server: Apache Tomcat
- Database: MySQL

## How to Run

### Prerequisites
- Java 11+ (`java -version`)
- MySQL 8+ running on `localhost:3306`
- Apache Tomcat 9 (Tomcat 10+ won't work — this app uses `javax.servlet`, not `jakarta.servlet`)

### 1. Initialize the database
```bash
mysql -u root -p < sql/setup.sql
```
This creates the `koipondmanager` database, all tables, the ChampKoi organization, an admin user, and the 55 seeded ponds in one shot. Safe to re-run.

Default dev login: **admin@champkoi.com** / **champkoi**

If you only want the schema with no seed data, run `mysql -u root -p < sql/schema.sql` instead and use the signup page to create your own org.

### 2. Configure the DB connection
Open [src/main/java/com/koi/MysqlCon.java](src/main/java/com/koi/MysqlCon.java) and update `USER` / `PASSWORD` to match your local MySQL credentials.

### 3. Point the build script at your Tomcat install
Two scripts are provided — pick whichever matches your setup and edit `TOMCAT_HOME` if needed:
- [build.sh](build.sh) — Homebrew Tomcat on macOS (`/opt/homebrew/Cellar/tomcat@9/...`), deploys to `koi-pond-manager` context on port 8082
- [build-local.sh](build-local.sh) — Tomcat unzipped under `$HOME/apache-tomcat-9.0.117`, deploys to `koi` context on port 8080

### 4. Build and deploy
```bash
./build.sh        # or ./build-local.sh
```
This compiles the servlets, copies the webapp into Tomcat's `webapps/`, and prints the URL to visit.

### 5. Start Tomcat (if it isn't already running)
```bash
$TOMCAT_HOME/bin/catalina.sh run
```
Then open the URL printed by the build script — e.g. <http://localhost:8082/koi-pond-manager/> or <http://localhost:8080/koi/index.jsp>.

### Re-deploying after changes
Re-run the build script. JSP edits are picked up without a Tomcat restart; Java/servlet changes require redeploy (which the script does).

### Schema changes
When pulling new schema changes, the simplest reset is `DROP DATABASE koipondmanager;` followed by re-running step 1. (Look for `ALTER TABLE` notes in PR descriptions if you want to preserve data.)