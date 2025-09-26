import org.openurp.parent.Dependencies.*
import org.openurp.parent.Settings.*

ThisBuild / organization := "org.openurp.edu.program"
ThisBuild / version := "0.0.4-SNAPSHOT"

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

val apiVer = "0.47.0"
val starterVer = "0.4.1"
val baseVer = "0.4.57"
val eduCoreVer = "0.3.18"

val openurp_edu_api = "org.openurp.edu" % "openurp-edu-api" % apiVer
val openurp_stater_web = "org.openurp.starter" % "openurp-starter-web" % starterVer
val openurp_base_tag = "org.openurp.base" % "openurp-base-tag" % baseVer
val openurp_edu_core = "org.openurp.edu" % "openurp-edu-core" % eduCoreVer
val plantuml = "net.sourceforge.plantuml" % "plantuml" % "1.2024.5"
val hibernate_community = "org.hibernate.orm" % "hibernate-community-dialects" % "6.6.19.Final" exclude("org.hibernate.orm", "hibernate-core")

lazy val root = (project in file("."))
  .enablePlugins(WarPlugin, TomcatPlugin)
  .settings(
    name := "openurp-edu-program-webapp",
    common,
    libraryDependencies ++= Seq(openurp_stater_web, openurp_edu_core, beangle_doc_pdf),
    libraryDependencies ++= Seq(openurp_edu_api, openurp_base_tag),
    libraryDependencies ++= Seq(plantuml, beangle_doc_excel),
    libraryDependencies ++= Seq(hibernate_community)
  )
