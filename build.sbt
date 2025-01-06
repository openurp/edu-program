import org.openurp.parent.Dependencies.*
import org.openurp.parent.Settings.*

ThisBuild / organization := "org.openurp.edu.program"
ThisBuild / version := "0.0.2-SNAPSHOT"

ThisBuild / scmInfo := Some(
  ScmInfo(
    url("https://github.com/openurp/edu-program"),
    "scm:git@github.com:openurp/edu-program.git"
  )
)

ThisBuild / developers := List(
  Developer(
    id = "chaostone",
    name = "Tihua Duan",
    email = "duantihua@gmail.com",
    url = url("http://github.com/duantihua")
  )
)

ThisBuild / description := "OpenURP Edu Learning"
ThisBuild / homepage := Some(url("http://openurp.github.io/edu-program/index.html"))

val apiVer = "0.41.14"
val starterVer = "0.3.51"
val baseVer = "0.4.46"
val eduCoreVer = "0.3.7"

val openurp_edu_api = "org.openurp.edu" % "openurp-edu-api" % apiVer
val openurp_stater_web = "org.openurp.starter" % "openurp-starter-web" % starterVer
val openurp_base_tag = "org.openurp.base" % "openurp-base-tag" % baseVer
val openurp_edu_core = "org.openurp.edu" % "openurp-edu-core" % eduCoreVer
val plantuml = "net.sourceforge.plantuml" % "plantuml" % "1.2024.4"
val word_checker = "org.languagetool" % "language-en" % "6.4"
val guava = "com.google.guava" % "guava" % "33.2.1-jre"
val hibernate_community = "org.hibernate.orm" % "hibernate-community-dialects" % "6.4.9.Final" exclude("org.hibernate.orm", "hibernate-core")

lazy val root = (project in file("."))
  .enablePlugins(WarPlugin, TomcatPlugin)
  .settings(
    name := "openurp-edu-program-webapp",
    common,
    libraryDependencies ++= Seq(openurp_stater_web, openurp_edu_core, beangle_doc_pdf),
    libraryDependencies ++= Seq(openurp_edu_api, beangle_ems_app, openurp_base_tag),
    libraryDependencies ++= Seq(plantuml, beangle_webmvc, beangle_doc_excel),
    libraryDependencies ++= Seq(guava, word_checker,beangle_template,beangle_model,hibernate_community)
  )
