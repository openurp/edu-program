/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.edu.program.service

import org.apache.poi.ss.usermodel.CellType
import org.apache.poi.ss.util.CellRangeAddress
import org.apache.poi.xssf.usermodel.{XSSFCell, XSSFRow, XSSFSheet, XSSFWorkbook}
import org.beangle.commons.collection.Collections
import org.beangle.commons.io.DataType
import org.beangle.commons.lang.Strings
import org.beangle.commons.logging.Logging
import org.beangle.data.dao.EntityDao
import org.beangle.doc.excel.CellOps.*
import org.openurp.base.edu.model.{Course, Terms}
import org.openurp.base.model.CalendarStage
import org.openurp.code.edu.model.*
import org.openurp.edu.program.model.*
import org.openurp.edu.program.service.LixinPlanExcelReader.*

import java.io.{FileInputStream, InputStream}
import scala.collection.mutable

/** lixin plan excel reader
 */
object LixinPlanExcelReader {

  def main(args: Array[String]): Unit = {
    if (args.length < 1) {
      println("Using PlanReader file")
      return
    }
    val file = args(0)
    val reader = new LixinPlanExcelReader(new FileInputStream(file))
    reader.process()
    val plan = reader.plan
    plan.buildTags()
  }

  val fixedCourseCodes = Seq("210980210", "210960210", "210060210", "210030410", "210930210", "210010110", "180010310",
    "180020310", "180030210", "180040210", "173280210", "220010110", "220020110", "220030110", "220040110", "130030210",
    "310010210", "310060214", "210990114", "210970114", "210100114", "210080114", "211070114", "221540010", "250170010",
    "330020010", "310190H11", "310181H11", "310190H14", "310181H14", "134660H10", "134670H10", "310220110", "310230110",
    "210590Q10", "210600Q10", "210610Q10", "210620Q10", "210630Q10", "210640Q10", "210650Q10", "210050Q10",
    "210030210", "210030211", "210080114", "210080214")

  class ExcelPlan(val name: String) {
    var department: String = _
    var credits: Double = _
    var creditHours: Int = _
    var theoreticalHours: Int = _
    var practicalHours: Int = _
    var groups = new mutable.ArrayBuffer[ExcelCourseGroup]
    var tags = Collections.newMap[String, mutable.Set[String]]
    var ignoreCreditHours = true

    def buildTags(): Unit = {
      groups foreach { g =>
        buildTags(g)
      }
    }

    def buildTags(group: ExcelCourseGroup): Unit = {
      group.courses foreach { c =>
        c.remark foreach { r =>
          Strings.split(r, Array(',', '，', ';', '；', ' ')) foreach { r1 =>
            var tagName = r1
            if (tagName.contains("特色课程")) tagName = "特定领域特色课程"
            if (tagName.contains("专业核心")) tagName = "专业核心课程" //处理不做分割的例子，类似 考试4业核心课程
            if (tagName.contains("专业综合实验课")) tagName = "专业综合实验课"
            if (tagName.contains("独立设置") && tagName.contains("实验")) tagName = "独立设置实验课"
            if ((tagName.endsWith("课") || tagName.endsWith("课程")) && !tagName.contains("选课")) {
              if (tagName.endsWith("课")) tagName += "程"
              val cs = tags.getOrElseUpdate(tagName, Collections.newSet[String])
              cs.addOne(c.courseCode)
            }
          }
        }
      }
      group.children foreach { child =>
        buildTags(child)
      }
    }

    def convert(program: Program, entityDao: EntityDao, messages: mutable.Buffer[String]): MajorPlan = {
      val majorPlan = new MajorPlan()
      majorPlan.program = program
      this.groups foreach { g =>
        convertGroup(g, program, entityDao, messages) foreach { gg =>
          majorPlan.groups.addOne(gg)
        }
      }
      this.buildTags()
      val programCourseTags = entityDao.getAll(classOf[ProgramCourseTag]).map(x => (if x.name.endsWith("课") then x.name + "程" else x.name, x)).toMap
      val courseTags = entityDao.getAll(classOf[CourseTag]).map(x => (if x.name.endsWith("课") then x.name + "程" else x.name, x)).toMap

      val labels = Collections.newBuffer[(ProgramCourseTag, Course)]
      this.tags foreach { case (tag, courseCodes) =>
        courseCodes foreach { courseCode =>
          val courses = entityDao.findBy(classOf[Course], "project" -> program.project, "code" -> courseCode)
          courses foreach { c =>
            if (programCourseTags.contains(tag)) {
              labels.addOne((programCourseTags(tag), c))
            } else if (courseTags.contains(tag)) {
              c.tags.add(courseTags(tag))
              entityDao.saveOrUpdate(c)
            } else {
              messages.addOne(s"Cannot recognize tag ${tag}")
            }
          }
        }
      }
      if (labels.nonEmpty) {
        labels foreach { l =>
          if (!program.labels.exists(x => x.tag == l._1 && x.course == l._2)) {
            program.labels.addOne(new ProgramCourseLabel(program, l._2, l._1))
          }
        }
        val droped = program.labels filter { l => !labels.exists(x => x._1 == l.tag && x._2 == l.course) }
        program.labels.subtractAll(droped)
      }
      majorPlan
    }

    private def convertRemark(remark: Option[String]): Option[String] = {
      remark match
        case None => None
        case Some(r) =>
          var r1 = r
          r1 = Strings.replace(r1, "考试1", "")
          r1 = Strings.replace(r1, "考试2", "")
          r1 = Strings.replace(r1, "考试3", "")
          r1 = Strings.replace(r1, "考试4", "")
          r1 = Strings.replace(r1, "考试5", "")
          r1 = Strings.replace(r1, "考试6", "")
          r1 = Strings.replace(r1, "考试7", "")
          r1 = Strings.replace(r1, "考试8", "")
          r1 = Strings.replace(r1, "考试", "")

          r1 = Strings.replace(r1, "考查1", "")
          r1 = Strings.replace(r1, "考查2", "")
          r1 = Strings.replace(r1, "考查3", "")
          r1 = Strings.replace(r1, "考查4", "")
          r1 = Strings.replace(r1, "考查5", "")
          r1 = Strings.replace(r1, "考查6", "")
          r1 = Strings.replace(r1, "考查7", "")
          r1 = Strings.replace(r1, "考查8", "")
          r1 = Strings.replace(r1, "考查", "")

          r1 = Strings.replace(r1, "专业综合实验课", "")
          r1 = Strings.replace(r1, "独立设置实验课", "")
          r1 = Strings.replace(r1, "专业核心课程", "")
          r1 = Strings.replace(r1, "专业综合实验课", "")
          r1 = Strings.replace(r1, "独立设置的实验课", "")
          r1 = Strings.replace(r1, "专业核心", "")

          r1 = Strings.replace(r1, "特色课程", "")
          r1 = Strings.replace(r1, "特定领域特色课程", "")
          r1 = Strings.replace(r1, "跨学科融合课程", "")
          r1 = Strings.replace(r1, "专业数智化课程", "")
          r1 = Strings.replace(r1, "双证融通课程", "")
          r1 = Strings.replace(r1, "专创融合课程", "")
          r1 = Strings.replace(r1, "独立设置的实验课", "")
          r1 = Strings.replace(r1, "专业核心", "")

          r1 = Strings.replace(r1, "\r", "")
          r1 = Strings.replace(r1, "\n", "")
          if (r1.startsWith(",") || r1.startsWith("，")) r1 = r1.substring(1)
          //          if (r1 != r) {
          //            println(s"convert ${r} => $r1")
          //          }
          if Strings.isBlank(r1) then None else Some(r1)
    }

    private def convertGroup(g: LixinPlanExcelReader.ExcelCourseGroup, program: Program, entityDao: EntityDao, messages: mutable.Buffer[String]): Option[MajorCourseGroup] = {
      val courseGroup = new MajorCourseGroup
      entityDao.findBy(classOf[CourseType], "name", g.typeName).headOption match
        case None => messages.addOne("错误的课程分组:" + g.typeName); None
        case Some(courseType) =>
          courseGroup.credits = g.credits.toInt
          courseGroup.termCredits = g.termCredits
          courseGroup.terms = g.terms
          courseGroup.creditHours = g.creditHours
          courseGroup.hourRatios = s"1:${g.theoreticalHours},9:${g.practicalHours}"
          courseGroup.weeks = g.weeks
          courseGroup.stage = g.stage
          courseGroup.indexno = g.indexno
          courseGroup.courseType = courseType
          courseGroup.givenName = g.givenName
          courseGroup.departments = g.departments
          courseGroup.remark = g.remark
          courseGroup.rank = if (g.rankId > 0) then Some(new CourseRank(g.rankId)) else None
          courseGroup.stage = g.stage
          g.children foreach { c =>
            convertGroup(c, program, entityDao, messages) foreach { gg =>
              courseGroup.addGroup(gg)
            }
          }
          var i = 1
          g.courses foreach { c =>
            val pc = new MajorPlanCourse
            val course = entityDao.findBy(classOf[Course], "project" -> program.project, "code" -> c.courseCode).headOption
            course match
              case None => messages.addOne("错误的课程代码:" + c.courseCode)
              case Some(cc) =>
                pc.idx = i.asInstanceOf[Short]
                pc.course = cc
                pc.terms = c.toTerms
                pc.remark = convertRemark(c.remark)
                pc.termText = Some(c.terms)
                pc.compulsory = (null != c.nature && c.nature.contains("必"))

                if (cc.defaultCredits.toInt != c.credits.toInt) {
                  messages.addOne(s"错误的课程学分:${cc.code} ${cc.name} 的学分为${cc.defaultCredits} excel中为${c.credits}")
                }
                //模板中固定的代码，不能修改课程信息
                if (!ignoreCreditHours && !fixedCourseCodes.contains(cc.code)) {
                  val cj = cc.getJournal(program.grade)
                  cj.creditHours = c.creditHours
                  cj.updateHour(new TeachingNature(1), c.theoreticalHours)
                  cj.updateHour(new TeachingNature(9), c.practicalHours)
                  cj.weeks = c.weeks
                  if (null != c.remark) {
                    if (c.remark.getOrElse("").contains("考试")) {
                      cj.examMode = new ExamMode(1)
                    } else if (c.remark.getOrElse("").contains("考查")) {
                      cj.examMode = new ExamMode(2)
                    }
                  }
                  entityDao.saveOrUpdate(cj)
                  entityDao.saveOrUpdate(cj.hours)
                }
                courseGroup.addCourse(pc)
                i += 1
          }
          Some(courseGroup)
    }
  }

  def toTerms(terms: String): Terms = {
    if Strings.isBlank(terms) then Terms.empty
    else
      var t = Strings.replace(terms, "长", "")
      t = Strings.replace(t, "短", "")
      t = Strings.replace(t, "+", ",")
      val rs = Terms(t)
      if (terms.contains("短") && terms.contains("长")) {
        val termList = rs.termList
        if termList.isEmpty then Terms.empty
        else Terms.apply(rs.termList.last.toString)
      } else {
        rs
      }
  }

  class ExcelPlanCourse(val seq: Int, val courseCode: String, val courseName: String, val courseNameEn: String, val credits: Double,
                        val creditHours: Int, val weeks: Int, val theoreticalHours: Int, val practicalHours: Int, val nature: String, val terms: String,
                        val depart: String, var remark: Option[String]) {

    def toTerms: Terms = LixinPlanExcelReader.toTerms(terms)

    override def toString: String = {
      (seq, courseCode, courseName, courseNameEn, credits, creditHours, theoreticalHours, practicalHours, nature, terms, depart, remark).toString
    }
  }

  def givenNameOf(modules: Array[String]): Option[String] = {
    if (modules(0) == "学科专业课模块") {
      if (modules.length > 2) {
        if Strings.isNotEmpty(modules(2)) then Some(modules(2)) else None
      } else {
        None
      }
    } else {
      None
    }
  }

  /** 转换电子表格中不正确的叫法
   *
   * @param typeName
   * @return
   */
  def typeNameOf(typeName: String): String = {
    typeName match
      case "社会科学类课程" => "社会科学类"
      case "科学技术类课程" => "科学技术类"
      case "创新创业类课程" => "创新创业类"
      case "国际视野类课程" => "国际视野类"
      case "体育限选" => "体育限定选修"
      case "数据与信息素养" => "数据与信息素养课程"
      case "长学段-专业课模块" => "长学段-学科专业课模块"
      case _ => typeName
  }

  def typeNameOf(modules: Array[String]): String = {
    if (modules(0) == "通识课模块") {
      if (modules(1).contains("长学段") && modules(1).contains("必修")) {
        "长学段-通识必修课"
      } else if (modules(1).contains("长学段") && modules(1).contains("限")) {
        "长学段-通识限定选修课"
      } else if (modules(1).contains("长学段") && modules(1).contains("自由")) {
        "长学段-通识自由选修课"
      } else {
        modules.mkString(",")
      }
    } else if (modules(0) == "学科专业课模块" || modules(0) == "专业课模块") {
      if (modules(1).contains("长学段") && modules(1).contains("必修")) {
        "长学段-专业必修课"
      } else if (modules(1).contains("长学段") && modules(1).contains("跨")) {
        "长学段-跨学科跨专业选修课"
      } else if (modules(1).contains("长学段") && modules(1).contains("选修")) {
        "长学段-专业选修课"
      } else if (modules(1).contains("方向")) {
        modules(1)
      } else {
        modules.mkString(",")
      }
    } else if (modules(0) == "实践课模块" || modules(0) == "实践课课模块" || modules(0) == "实践模块") {
      if (modules(1).contains("长学段") && modules(1).contains("必修")) {
        "长学段-专业与创新实践必修课"
      } else if (modules(1).contains("长学段") && modules(1).contains("限")) {
        "长学段-专业与创新实践限定选修课"
      } else if (modules(1).contains("短学段") && modules(1).contains("必修")) {
        "短学段-综合素质实践必修课"
      } else if (modules(1).contains("短学段") && modules(1).contains("选")) {
        "短学段-专业与创新实践"
      } else {
        modules.mkString(",")
      }
    } else if (modules(0).contains("综合能力素质")) {
      "综合能力素质测评"
    } else {
      modules.mkString(",")
    }
  }

  def convertRemarkToGroupName(remark: String): String = {
    if (Strings.isBlank(remark)) then null
    else {
      if (remark.contains("行业前沿")) then "学科专业和行业前沿课程"
      else if (remark.contains("产教融合")) "产教融合实务课程"
      else if (remark.contains("校内实验")) "校内实验实训课程"
      else if (remark.contains("国际化")) "国际化课程"
      else if (remark.contains("科教融")) "科教融合实训课程"
      else if (remark.contains("校外实践")) "校外实践实习课程"
      else if (remark.contains("外学习和实践")) "国际化课程"
      else remark
    }
  }

  class ExcelCourseGroup(val indexno: String, val typeName: String, val givenName: Option[String]) {
    var parent: Option[ExcelCourseGroup] = None
    var credits: Double = _
    var creditHours: Int = _
    var theoreticalHours: Int = _
    var practicalHours: Int = _
    val courses = new mutable.ArrayBuffer[ExcelPlanCourse]
    var children = new mutable.ArrayBuffer[ExcelCourseGroup]
    var terms: Terms = Terms.empty
    var weeks: Option[Int] = None
    var termCredits: String = "0,0,0,0,0,0,0,0"
    var stage: Option[CalendarStage] = None
    var departments: Option[String] = None
    var remark: Option[String] = None

    def rankId: Int = {
      if typeName.contains("必") || (typeName.contains("短学段") && typeName.contains("综合素质实践")) || typeName.contains("综合能力素质测评") then CourseRank.Compulsory
      else if typeName.contains("限") then CourseRank.DesignatedSelective
      else if typeName.contains("自由") || typeName.contains("选修") then CourseRank.FreeSelective
      else if typeName.contains("短学段") && typeName.contains("专业与创新实践") then CourseRank.FreeSelective
      else {
        if parent.nonEmpty then parent.get.rankId else 0
      }
    }

    override def toString: String = {
      (typeName, givenName, credits, creditHours, theoreticalHours, practicalHours).toString
    }

    def findGroup(name: String, givenName: Option[String]): Option[ExcelCourseGroup] = {
      children.find(x => x.typeName == name && x.givenName == givenName)
    }

    def addGroup(typeName: String, givenName: Option[String]): ExcelCourseGroup = {
      if (givenName.getOrElse("").contains("据跨学科跨专业选修") || typeName.contains("据跨学科跨专业选修")) {
        this
      } else {
        findGroup(typeName, givenName) match {
          case None =>
            if (typeName == this.typeName && givenName == this.givenName) {
              this
            } else {
              givenName match {
                case None =>
                  val child = new ExcelCourseGroup(newChildIndexno(), typeName, givenName)
                  child.stage = this.stage
                  child.parent = Some(this)
                  children.addOne(child)
                  child
                case Some(gn) =>
                  if (this.typeName == typeName) {
                    val child = new ExcelCourseGroup(newChildIndexno(), typeName, givenName)
                    child.stage = this.stage
                    child.parent = Some(this)
                    children.addOne(child)
                    child
                  } else {
                    this.addGroup(typeName, None).addGroup(typeName, givenName)
                  }
              }
            }
          case Some(g) => g
        }
      }
    }

    def newChildIndexno(): String = {
      indexno + "." + (children.size + 1)
    }

    def updateCreditAndHours(credits: Double, creditHours: Int, theoreticalHours: Int, practicalHours: Int): Unit = {
      this.credits = credits
      this.creditHours = creditHours
      this.theoreticalHours = theoreticalHours
      this.practicalHours = practicalHours
    }
  }
}

class LixinPlanExcelReader(in: InputStream) extends Logging {
  var regions: Seq[CellRangeAddress] = _
  var lastRowNum: Int = _
  var lastColNum: Int = _
  var moduleSpan = 1
  var plan: ExcelPlan = _
  var messages = Collections.newBuffer[String]
  var zhuanke: Boolean = false //是否是专科计划
  var zhuanShengben: Boolean = false //是否是专升本计划

  val longStage = new CalendarStage
  longStage.id = 1
  longStage.name = "长学段"

  val shortStage = new CalendarStage
  shortStage.id = 2
  shortStage.name = "短学段"

  var longTermGroup = new ExcelCourseGroup("1", "长学段教学", None)
  longTermGroup.stage = Some(longStage)
  val shortTermGroup = new ExcelCourseGroup("2", "短学段教学", None)
  shortTermGroup.stage = Some(shortStage)

  def findLastRowNum(sheet: XSSFSheet): Int = {
    var last = sheet.getLastRowNum
    var text = getFirst(sheet.getRow(last))
    while (last > 1 && (null == text || !text.contains("学分要求合计"))) {
      last = last - 1
      text = getFirst(sheet.getRow(last))
    }
    last
  }

  def process(): Unit = {
    val wb = new XSSFWorkbook(in)
    val sheet = wb.getSheetAt(0)
    import scala.jdk.javaapi.CollectionConverters.asScala
    regions = asScala(sheet.getMergedRegions).toSeq
    val region = getMergeRegion(0)

    lastColNum = region.getLastColumn

    val name = sheet.getRow(1).getCell(0)
    val department = sheet.getRow(0).getCell(0)
    zhuanke = name.toString.contains("专科")
    zhuanShengben = name.toString.contains("专升本")
    plan = new ExcelPlan(name.toString)
    plan.groups.addOne(longTermGroup)
    plan.groups.addOne(shortTermGroup)
    plan.department = department.toString

    //title
    val titleRow = sheet.getRow(3)
    val module = titleRow.getCell(0)

    while (titleRow.getCell(moduleSpan).getCellType == CellType.BLANK) {
      moduleSpan += 1
    }

    val startRowNum = 5

    lastRowNum = findLastRowNum(sheet)
    var topModule: String = ""
    var topGroup: ExcelCourseGroup = null

    var modules = Array.ofDim[String](moduleSpan)
    var group: ExcelCourseGroup = null
    (startRowNum to lastRowNum) foreach { rowIdx =>
      val row = sheet.getRow(rowIdx)
      try {
        val firstCellText = getFirst(row)
        if (null != firstCellText) {
          if (isMergeRow(row)) { // case 1 一级和二级模块
            topModule = row.getCell(0).getStringCellValue
            if (topModule.contains("学段教学")) {
              //（二）短学段教学| 2.1短学段-综合素质实践 Short Semester-Comprehensive Ability Practice
              // indexno  2.1
              //typeName 短学段-综合素质实践
              var indexTypeName = Strings.substringAfter(topModule, "|").trim
              indexTypeName = Strings.substringBefore(indexTypeName, " ")
              val indexNo = indexTypeName.substring(0, indexTypeName.indexOf("学段") - 1)
              val typeName = typeNameOf(Strings.replace(indexTypeName.substring(indexNo.length), "—", "-"))
              topGroup = new ExcelCourseGroup(indexNo, typeName, None)
              if (topModule.contains("长学段")) {
                topGroup.stage = Some(longStage)
                topGroup.parent = Some(longTermGroup)
                longTermGroup.children.addOne(topGroup)
              } else {
                topGroup.stage = Some(shortStage)
                topGroup.parent = Some(shortTermGroup)
                shortTermGroup.children.addOne(topGroup)
              }
            } else if (topModule.contains("能力素质")) {
              topModule = "综合能力素质测评"
              topGroup = new ExcelCourseGroup((plan.groups.size + 1).toString, topModule, None)
              group = topGroup
              plan.groups.addOne(topGroup)
            }
            else {
              topGroup = new ExcelCourseGroup((plan.groups.size + 1).toString, topModule, None)
              plan.groups.addOne(topGroup)
            }
          } else if (firstCellText.contains("学分要求") || firstCellText.contains("学分应选要求")) { //case 2 学分要求|学分应选要求
            if (!firstCellText.contains("合计")) readGroupStat(row, group)
          } else if (firstCellText.contains("小计")) { //case 3 level 2 group summary
            //忽略实践课（短学段）小计
            if (!(firstCellText.contains("实践课") || firstCellText.contains("长学段"))) {
              readGroupStat(row, topGroup)
            } else if (firstCellText.contains("长学段")) {
              readGroupStat(row, longTermGroup)
            }
          } else if (firstCellText.contains("要求合计")) {
            readPlanStat(row, plan)
          } else {
            val start = row.getFirstCellNum
            var remarkGroup: ExcelCourseGroup = null
            var remarkAsGroupName = false
            //特殊处理 短学段-专业与创新实践，备注作为模块名
            if (!zhuanke && topGroup.typeName == "短学段-专业与创新实践") { //专科不考虑备注作为组的处理方式
              val remark = getText(row.getCell(lastColNum))
              val remarkGroupName = convertRemarkToGroupName(remark)
              if (Strings.isNotEmpty(remarkGroupName)) {
                remarkAsGroupName = true
                remarkGroup = topGroup.addGroup(remarkGroupName, None)
                group = topGroup
              }
            }

            //读取前面的模块名
            if (!remarkAsGroupName) {
              val groupNames = modules.clone()
              var groupNameOccured = false
              (0 until moduleSpan) foreach { i =>
                val cell = row.getCell(i)
                if (cell.getCellType != CellType.BLANK) {
                  groupNames(i) = cell.getStringCellValue
                  groupNameOccured = true
                } else {
                  if (groupNameOccured) groupNames(i) = null
                }
              }
              if (modules.toSeq != groupNames.toSeq) {
                modules = groupNames
                val groupTypeName = typeNameOf(modules)
                if (groupTypeName.contains("方向")) {
                  val optionMajorGroup = topGroup.addGroup("长学段-专业选修课", None)
                  group = optionMajorGroup.addGroup(groupTypeName, None)
                } else {
                  group = topGroup.addGroup(groupTypeName, givenNameOf(modules))
                }
              }
            }
            val startText = getFirst(row, moduleSpan)
            val nameCell = row.getCell(moduleSpan + 2)
            if (nameCell.getCellType == CellType.BLANK) {
              if (startText.contains("学分")) {
                readGroupStat(row, group) // case5 credit with prefix group name(duplicates)
              } else {
                readLeafGroup(row, group) //case 4 given name groups
              }
            } else {
              val pc = readCourse(row)
              if (remarkAsGroupName) {
                pc.remark = None
              }
              logger.debug(s"reading ${pc}")
              //有个组当作课程了  创新创业实践
              if (pc.courseName == "创新创业实践" || pc.courseCode == "123910214") {
                val cxsj = group.addGroup("创新创业实践", None)
                cxsj.credits = pc.credits
                cxsj.creditHours = pc.creditHours
                cxsj.weeks = Some(pc.weeks)
                cxsj.terms = pc.toTerms
              } else {
                if (pc.courseCode == null || pc.courseCode.contains("新")) {
                  addError(rowIdx, s"新课程:${pc.courseName}")
                } else if (pc.courseCode.contains("310190H11") && pc.courseCode.contains("310181H11")) { //专科的 劳动教育与实践（一） 劳动教育与实践（二）
                  addCluster("劳动教育与实践", List("310190H11", "310181H11"), List("（一）", "（二）"), List(0.5f, 1.5f), pc, group)
                } else if (pc.courseCode.contains("310190H14") && pc.courseCode.contains("310181H14")) { //劳动教育与实践（一） 劳动教育与实践（二）
                  addCluster("劳动教育与实践", List("310190H14", "310181H14"), List("（一）", "（二）"), List(0.5f, 1.5f), pc, group)
                } else if (pc.courseCode.contains("134660H10") && pc.courseCode.contains("134670H10")) {
                  addCluster("职业规划与就业指导", List("134660H10", "134670H10"), List("①", "②"), List(0.5f, 0.5f), pc, group)
                } else if (pc.courseCode.contains("310220110") && pc.courseCode.contains("310230110")) {
                  addCluster("心理健康", List("310220110", "310230110"), List("①", "②"), List(1f, 1f), pc, group)
                } else if (pc.courseName == "形势与政策") {
                  if (zhuanShengben) { //专升本
                    var codes = List("210590Q10", "210600Q10", "210610Q10", "210620Q10")
                    var seqs = List("①", "②", "③", "④")
                    if (pc.courseCode.contains("210630Q10")) { //有的采用1234，有的采用5678
                      codes = List("210630Q10", "210640Q10", "210650Q10", "210050Q10")
                      seqs = List("⑤", "⑥", "⑦", "⑧")
                    }
                    addCluster("形势与政策", codes, seqs, List(0.25f, 0.25f, 0.25f, 0.25f), pc, group)
                  } else if (!zhuanke) { //本科
                    addCluster("形势与政策", List("210590Q10", "210600Q10", "210610Q10", "210620Q10", "210630Q10", "210640Q10", "210650Q10", "210050Q10"),
                      List("①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧"), List(0.25f, 0.25f, 0.25f, 0.25f, 0.25f, 0.25f, 0.25f, 0.25f), pc, group)
                  } else {
                    group.courses.addOne(pc)
                  }
                } else if (group.typeName.contains("通识限定选修课")) { //这里面如果有课，属于阅读类
                  val yuedu = group.addGroup("阅读与写作类课程", None)
                  yuedu.credits = pc.credits
                  yuedu.creditHours = pc.creditHours
                  yuedu.weeks = Some(pc.weeks)
                  yuedu.terms = pc.toTerms
                  yuedu.courses.addOne(pc)
                }
                //体育课不处理，转移到教务后再新增一个体育课程组
                //else if (Set("220010110", "220020110", "220030110", "220040010").contains(pc.courseCode)) {
                //  val pg = group.addGroup("体育必修", None)
                //  pg.credits = 4
                //}
                else {
                  if (null == remarkGroup) group.courses.addOne(pc)
                  else remarkGroup.courses.addOne(pc)
                }
              }
            }
          }
        }
      } catch {
        case e: Exception =>
          e.printStackTrace()
          addError(rowIdx, e.getMessage)
      }
    }

    wb.close()
    if (longTermGroup.credits == 0) {
      longTermGroup.credits = longTermGroup.children.map(_.credits).sum
    }
    plan.credits = plan.groups.map(_.credits).sum
  }

  private def addError(rowIdx: Int, message: String): Unit = {
    messages.addOne(s"${rowIdx + 1}行 ${message}")
  }

  private def addCluster(name: String, codes: List[String], seqs: List[String], credits: List[Float], pc: ExcelPlanCourse, group: ExcelCourseGroup): Unit = {
    val terms = pc.toTerms.termList
    codes.indices foreach { i =>
      val c = codes(i)
      val newpc = new ExcelPlanCourse(i, c, name + seqs(i), null, credits(i), (credits(i) * 16).toInt, 0, 0, 0, "必修", terms(i).toString + "长", null, pc.remark)
      group.courses.addOne(newpc)
    }
  }

  private def readPlanStat(row: XSSFRow, plan: ExcelPlan): Unit = {
    val credits = getFloat(row.getCell(moduleSpan + 3))
    val creditHours = getInt(row.getCell(moduleSpan + 4))
    val theoreticalHours = getInt(row.getCell(moduleSpan + 5))
    val practicalHours = getInt(row.getCell(moduleSpan + 6))
    plan.credits = credits
    plan.creditHours = creditHours
    plan.theoreticalHours = theoreticalHours
    plan.practicalHours = practicalHours
  }

  private def readGroupStat(row: XSSFRow, group: ExcelCourseGroup): Unit = {
    val credits = getFloat(row.getCell(moduleSpan + 3))
    val creditHours = getInt(row.getCell(moduleSpan + 4))
    val theoreticalHours = getInt(row.getCell(moduleSpan + 5))
    val practicalHours = getInt(row.getCell(moduleSpan + 6))

    if (group.typeName.contains("通识自由选修课")) {
      group.parent.get.findGroup("长学段-通识限定选修课", None) foreach { g =>
        g.credits = credits - group.credits
        g.creditHours = creditHours - group.creditHours
        g.theoreticalHours = theoreticalHours - group.theoreticalHours
        g.practicalHours = practicalHours - group.practicalHours
      }
    } else if (group.givenName.nonEmpty || group.credits > 0) {
      if (group.parent.nonEmpty) {
        group.parent.get.updateCreditAndHours(credits, creditHours, theoreticalHours, practicalHours)
      } else {
        addError(row.getRowNum, s"找不到${group.typeName}(${group.givenName})的上级组")
      }
    } else {
      group.updateCreditAndHours(credits, creditHours, theoreticalHours, practicalHours)
      if (group.typeName.contains("综合素质实践必修课")) {
        group.parent.get.updateCreditAndHours(credits, creditHours, theoreticalHours, practicalHours)
      } else if (group.typeName.contains("方向")) {
        group.parent.get.updateCreditAndHours(credits, creditHours, theoreticalHours, practicalHours)
      }
    }
  }

  private def readLeafGroup(row: XSSFRow, group: ExcelCourseGroup): Unit = {
    val seq = getText(row.getCell(moduleSpan))
    val groupNameText = getText(row.getCell(moduleSpan + 1))
    if (Strings.isBlank(groupNameText)) return;

    val groupNames = processCourseName(groupNameText)

    val credits = getFloat(row.getCell(moduleSpan + 3))
    val creditHours = getInt(row.getCell(moduleSpan + 4))
    val theoreticalHours = getInt(row.getCell(moduleSpan + 5))
    val practicalHours = getInt(row.getCell(moduleSpan + 6))
    val leaf = group.addGroup(typeNameOf(groupNames._1), None)
    //通识自由选修课的要求学分，体现在各个子组的合并单元格，而不是单独起一行编辑的
    if (leaf.typeName.endsWith("类") && group.typeName.contains("通识自由选修课")) {
      if (group.credits.toInt == 0) {
        group.credits = credits
        group.creditHours = creditHours
        group.theoreticalHours = theoreticalHours
        group.practicalHours = practicalHours
      }
      leaf.credits = 0f
      leaf.creditHours = 0
      leaf.theoreticalHours = 0
      leaf.practicalHours = 0
    } else {
      if (!leaf.typeName.contains("跨学科")) { //跨学科的学分，通过学分要求中获得
        leaf.credits = credits
        leaf.creditHours = creditHours
        leaf.theoreticalHours = theoreticalHours
        leaf.practicalHours = practicalHours
      }
    }
    leaf.terms = toTerms(getText(row.getCell(moduleSpan + 8)))
    leaf.departments = Option(getText(row.getCell(lastColNum - 1)))
    if (leaf.departments.contains("信管等")) {
      leaf.departments = Some("信管")
    }
    leaf.remark = Option(getText(row.getCell(lastColNum)))
  }

  private def readCourse(row: XSSFRow): ExcelPlanCourse = {
    val seq = getInt(row.getCell(moduleSpan))
    var courseCode = getText(row.getCell(moduleSpan + 1))
    if (null != courseCode) {
      if (courseCode == "210030410") courseCode = "210030210" // 4学分的毛概改成2学分的课程
      if (courseCode.contains("173690210") && courseCode.contains("173700210")) { //数据库应用基础 A/B 换成数据库应用基础 A
        courseCode = "173700210"
      }
    }
    val courseNames = processCourseName(getText(row.getCell(moduleSpan + 2)))
    val courseName = courseNames._1
    val courseNameEn = courseNames._2
    val credits = getFloat(row.getCell(moduleSpan + 3))
    var creditHours = 0
    var weeks: Int = 0
    val hours = getText(row.getCell(moduleSpan + 4))
    if (hours != null && hours.contains("周")) {
      if (hours == "每周") weeks = 16
      else weeks = Strings.replace(hours, "周", "").toInt
    } else {
      creditHours = getInt(row.getCell(moduleSpan + 4))
    }

    val theoreticalHours = getInt(row.getCell(moduleSpan + 5))

    val practicalHoursText = getText(row.getCell(moduleSpan + 6))
    val practicalHours = if null != practicalHoursText && !practicalHoursText.contains("周") then getInt(row.getCell(moduleSpan + 6)) else 0

    val nature = getText(row.getCell(moduleSpan + 7))
    val terms = getText(row.getCell(moduleSpan + 8))
    //中间可能是各学期周学时数分布，随意直接读取最后两列
    val depart = getText(row.getCell(lastColNum - 1))
    val remark = Option(getText(row.getCell(lastColNum)))
    new ExcelPlanCourse(seq, courseCode, courseName, courseNameEn, credits, creditHours, weeks, theoreticalHours, practicalHours, nature, terms, depart, remark)
  }

  def getMergeRegion(rowIndex: Short): CellRangeAddress = {
    regions.find { x => x.getFirstRow == x.getLastRow && x.getFirstRow == rowIndex && x.getFirstColumn == 0 }.get
  }

  def isMergeRow(row: XSSFRow): Boolean = {
    val firstCollNum = row.getFirstCellNum
    if (firstCollNum > -1) {
      val start = row.getFirstCellNum
      val region = regions.find { x => x.getFirstRow == x.getLastRow && x.getFirstRow == row.getRowNum && x.getFirstColumn == start && x.getLastColumn == lastColNum }
      region.nonEmpty
    } else {
      false
    }
  }

  def getFirst(row: XSSFRow, startColumn: Int = 0): String = {
    if (null == row) {
      null
    } else {
      var cell: XSSFCell = null
      var i = startColumn
      while (i <= lastColNum) {
        val c = row.getCell(i)
        if (null == c || c.getCellType == CellType.BLANK) {
          i += 1
        } else {
          cell = c
          i = lastColNum + 1
        }
      }
      if cell == null then null else getText(cell)
    }
  }

  private def processCourseName(name: String): (String, String) = {
    var n = name.trim()
    n = Strings.replace(n, "\r", "")
    val rs = Strings.split(n, "\n")
    if (rs.length == 2) {
      (rs(0).trim, rs(1).trim)
    } else {
      (rs(0), "")
    }
  }

  private def getText(cell: XSSFCell): String = {
    if null == cell then null
    else
      val t = cell.getValue(DataType.String)
      if t != null then t.toString.trim else null
  }

  private def getFloat(cell: XSSFCell): Float = {
    if (cell.getCellType == CellType.BLANK) {
      0.0f
    } else if (cell.getCellType == CellType.NUMERIC) {
      cell.getNumericCellValue.toFloat
    } else if (cell.getCellType == CellType.STRING) {
      val v = cell.getStringCellValue
      if Strings.isEmpty(v) || v == "※" then 0.0f else v.toFloat
    } else if (cell.getCellType == CellType.FORMULA) {
      val v = cell.getNumericCellValue
      v.toFloat
    } else {
      throw new RuntimeException("cannot read cell of type " + cell.getCellType)
    }
  }

  private def getInt(cell: XSSFCell): Int = {
    if (null == cell || cell.getCellType == CellType.BLANK) {
      0
    } else if (cell.getCellType == CellType.NUMERIC) {
      cell.getNumericCellValue.toInt
    } else if (cell.getCellType == CellType.STRING) {
      val v = cell.getStringCellValue
      if Strings.isBlank(v) || v == "※" then 0 else v.toInt
    } else if (cell.getCellType == CellType.FORMULA) {
      val n = cell.getValue
      if null == n || Strings.isBlank(n.toString.trim) then 0
      else n.toString.toDouble.intValue
    } else {
      throw new RuntimeException("cannot read cell of type " + cell.getCellType)
    }
  }
}
