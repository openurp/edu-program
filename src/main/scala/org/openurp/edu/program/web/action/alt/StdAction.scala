/*
 * OpenURP, Agile University Resource Planning Solution.
 *
 * Copyright © 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful.
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openurp.edu.program.web.action.alt

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.Course
import org.openurp.base.std.model.Student
import org.openurp.base.web.tag.ProjectHelper.getProject
import org.openurp.edu.program.domain.CoursePlanProvider
import org.openurp.edu.program.model.StdAlternativeCourse
import org.openurp.starter.edu.helper.ProjectSupport

import java.io.{ByteArrayInputStream, ByteArrayOutputStream}
import java.time.Instant
import scala.collection.mutable

/**
 * 可代替课程的维护响应类
 */
class StdAction extends RestfulAction[StdAlternativeCourse] , ProjectSupport {

  var coursePlanProvider: CoursePlanProvider = _

  /**
   * 获取学生的个人计划中的所有课程
   * Ajax用
   */
  def courses(): View = {
    val studentCode = get("studentCode")
    val sb = OqlBuilder.from(classOf[Student], "s")
    sb.where("s.user.code=:code and s.project=:project", studentCode, getProject)
    val students = entityDao.search(sb)
    val courses = new mutable.ArrayBuffer[Course]
    if (students.isEmpty) {
      coursePlanProvider.getCoursePlan(students.head) foreach { plan =>
        for (courseGroup <- plan.groups) {
          for (planCourse <- courseGroup.planCourses) {
            courses.addOne(planCourse.course)
          }
        }
      }
      put("courses", courses)
    }
    forward()
  }

  def exchange(): View = {
    val ids = longIds("stdAlternativeCourse")
    val subs = entityDao.find(classOf[StdAlternativeCourse], ids)
    for (sub <- subs) {
      sub.exchange()
      sub.updatedAt = Instant.now
    }
    entityDao.saveOrUpdate(subs)
    redirect("search", "info.save.success")
  }

  override def editSetting(entity: StdAlternativeCourse): Unit = {
    put("project", getProject)
  }

  /**
   * 查询
   */
  override def search(): View = {
    val builder = OqlBuilder.from(classOf[StdAlternativeCourse], "stdAlternativeCourse")
    populateConditions(builder)
    builder.where("stdAlternativeCourse.std.project=:project", getProject)
    get("originCourse") foreach { oc =>
      if (Strings.isNotBlank(oc)) {
        val origin = "%" + oc.trim().replaceAll("'", "") + "%"
        builder.where("exists(from stdAlternativeCourse.olds origin where origin.code like :oc or origin.name like :oc)", origin)
      }
    }
    get("substituteCourse") foreach { sc =>
      if (Strings.isNotBlank(sc)) {
        val substitue = "%" + sc.trim().replaceAll("'", "") + "%"
        builder.where("exists(from stdAlternativeCourse.news substitute where substitute.code like :sc or substitute.name like :sc)", substitue)
      }
    }
    get(Order.OrderStr) match {
      case None => builder.orderBy("stdAlternativeCourse.updatedAt desc,stdAlternativeCourse.id desc")
      case Some(o) => builder.orderBy(o)
    }

    builder.where("stdAlternativeCourse.std.state.department in (:departments)", getDeparts)
    builder.limit(getPageLimit)
    put("stdAlternativeCourses", entityDao.search(builder))
    forward()
  }

  override def saveAndRedirect(stdAlternativeCourse: StdAlternativeCourse): View = {
    var originCodesStr = get("originCodes").orNull; // 原课程代码串
    if (originCodesStr.nonEmpty && originCodesStr.substring(0, 1).equals(",")) {
      originCodesStr = originCodesStr.substring(1, originCodesStr.length())
    }
    val project = getProject
    val substituteCodesStr = get("substituteCodes").orNull // 替换课程代码串
    fillCourse(project, stdAlternativeCourse.olds, originCodesStr)
    fillCourse(project, stdAlternativeCourse.news, substituteCodesStr)
    var stdCourseSubId = 0L
    if (stdAlternativeCourse.persisted) {
      stdCourseSubId = stdAlternativeCourse.id
    }

    if (stdAlternativeCourse.olds.isEmpty || stdAlternativeCourse.news.isEmpty) {
      editSetting(stdAlternativeCourse)
      addMessage(getText("info.save.failure"))
      put("stdAlternativeCourse", stdAlternativeCourse)
      forward("edit")
    } else {
      val builder = OqlBuilder.from(classOf[StdAlternativeCourse],
        "stdAlternativeCourse")
      builder.where("stdAlternativeCourse.std.id=:stdId", stdAlternativeCourse.std.id)
        .where("stdAlternativeCourse.std.project = :project", project)
      if (stdCourseSubId != 0) {
        builder.where("stdAlternativeCourse.id !=:stdCourseSubId", stdCourseSubId)
      }
      val stdAlternativeCourses = entityDao.search(builder)
      val existed = stdAlternativeCourses.exists(st => st.olds == stdAlternativeCourse.olds && st.news == stdAlternativeCourse.news)
      if (existed) {
        redirect("search", "该替代课程组合已存在!")
      } else {
        stdAlternativeCourse.updatedAt = Instant.now()
        if (isDoubleAlternativeCourse(stdAlternativeCourse)) {
          entityDao.saveOrUpdate(stdAlternativeCourse)
          redirect("search", "info.save.success")
        } else {
          redirect("search", "原课程与替代课程一样!")
        }
      }
    }
  }

  private def fillCourse(project: Project, courses: mutable.Set[Course], courseCodeSeq: String): Unit = {
    val courseCodes = Strings.split(courseCodeSeq, ",")
    courses.clear()
    if (courseCodes != null) {
      for (code <- courseCodes) {
        val finded = entityDao.search(OqlBuilder.from(classOf[Course], "c").where("c.project=:project and c.code=:code", project, code))
        courses.addAll(finded)
      }
    }
  }

  /**
   * 由于前台不好判断原课程和替代
   * 课程是否一样所以放到后台判断
   *
   * @param alt StdAlternativeCourse
   * @return true:原课程和替代课程不一样 false:原课程与替代课程一样
   */
  private def isDoubleAlternativeCourse(alt: StdAlternativeCourse): Boolean = {
    val courseOrigins = alt.olds
    val courseSubstitutes = alt.news
    !courseOrigins.exists(c => courseSubstitutes.contains(c))
  }

  @response
  def downloadTemplate(): Any = {
    val project = getProject
    val query = OqlBuilder.from[Array[Any]](classOf[Course].getName, "c")
    query.where("c.project=:project and c.endOn is null", project)
    query.orderBy("c.code")
    query.select("c.code,c.name")
    val courses = entityDao.search(query).map(x => x(0) + " " + x(1))

    val schema = new ExcelSchema()
    val sheet = schema.createScheet("数据模板")
    sheet.title("学生个人替代课程信息模板")
    sheet.remark("特别说明：\n1、不可改变本表格的行列结构以及批注，否则将会导入失败！\n2、必须按照规格说明的格式填写。\n3、可以多次导入，重复的信息会被新数据更新覆盖。\n4、保存的excel文件名称可以自定。")
    sheet.add("学号", "stdCode").length(20).required().remark("≤20位")
    sheet.add("原课程", "oldCourse").ref(courses).required()
    sheet.add("新课程", "newCourse").ref(courses).required()

    val code = schema.createScheet("数据字典")
    code.add("课程信息").data(courses)
    val os = new ByteArrayOutputStream()
    schema.generate(os)
    Stream(new ByteArrayInputStream(os.toByteArray), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "学生个人替代课程模板.xlsx")
  }

  protected override def configImport(setting: ImportSetting): Unit = {
    setting.listeners = List(new StdAlternativeCourseImportListener(entityDao, getProject))
  }

  def newCourses(): View = {
    getDate("beginOn").foreach(beginOn => {
      getDate("endOn").foreach(endOn => {
        put("courses", entityDao.search(getQueryBuilder))
      })
    })
    forward()
  }
}
