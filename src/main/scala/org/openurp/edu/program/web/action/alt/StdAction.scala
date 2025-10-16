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

package org.openurp.edu.program.web.action.alt

import org.beangle.commons.activation.MediaTypes
import org.beangle.commons.collection.{Collections, Order}
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.excel.schema.ExcelSchema
import org.beangle.doc.transfer.importer.ImportSetting
import org.beangle.ems.app.Ems
import org.beangle.event.bus.{DataEvent, DataEventBus}
import org.beangle.webmvc.annotation.response
import org.beangle.webmvc.support.action.{ImportSupport, RestfulAction}
import org.beangle.webmvc.view.{Stream, View}
import org.openurp.base.edu.model.Course
import org.openurp.base.std.model.Student
import org.openurp.edu.program.domain.CoursePlanProvider
import org.openurp.edu.program.model.StdAlternativeCourse
import org.openurp.edu.program.web.helper.StdAlternativeCourseImportListener
import org.openurp.starter.web.support.ProjectSupport

import java.io.{ByteArrayInputStream, ByteArrayOutputStream}
import java.time.Instant

/**
 * 可代替课程的维护响应类
 */
class StdAction extends RestfulAction[StdAlternativeCourse], ProjectSupport, ImportSupport[StdAlternativeCourse] {

  var coursePlanProvider: CoursePlanProvider = _
  var databus: DataEventBus = _

  override protected def simpleEntityName: String = "alt"

  /** 获取学生的个人计划中的所有课程
   * Ajax用
   */
  def courses(): View = {
    val std = entityDao.get(classOf[Student], getLongId("std"))
    val courses = Collections.newBuffer[Course]
    coursePlanProvider.getCoursePlan(std) foreach { plan =>
      courses.addAll(plan.planCourses.map(_.course).toSet)
    }
    put("courses", courses)
    forward()
  }

  def exchange(): View = {
    val ids = getLongIds("alt")
    val alts = entityDao.find(classOf[StdAlternativeCourse], ids)
    for (sub <- alts) {
      sub.exchange()
      sub.updatedAt = Instant.now
    }
    entityDao.saveOrUpdate(alts)
    databus.publish(DataEvent.update(alts))
    redirect("search", "交换成功")
  }

  override def editSetting(entity: StdAlternativeCourse): Unit = {
    put("project", getProject)
  }

  /**
   * 查询
   */
  override def search(): View = {
    val builder = OqlBuilder.from(classOf[StdAlternativeCourse], "alt")
    populateConditions(builder)
    builder.where("alt.std.project=:project", getProject)
    get("oldCourse") foreach { oc =>
      if (Strings.isNotBlank(oc)) {
        val origin = "%" + oc.trim().replaceAll("'", "") + "%"
        builder.where("exists(from alt.olds o where o.code like :oc or o.name like :oc)", origin)
      }
    }
    get("newCourse") foreach { sc =>
      if (Strings.isNotBlank(sc)) {
        val substitue = "%" + sc.trim().replaceAll("'", "") + "%"
        builder.where("exists(from alt.news n where n.code like :sc or n.name like :sc)", substitue)
      }
    }
    get(Order.OrderStr) match {
      case None => builder.orderBy("alt.updatedAt desc,alt.id desc")
      case Some(o) => builder.orderBy(o)
    }

    queryByDepart(builder, "alt.std.state.department")
    builder.limit(getPageLimit)
    put("alts", entityDao.search(builder))
    put("ems_base", Ems.base)
    forward()
  }

  override def saveAndRedirect(alt: StdAlternativeCourse): View = {
    val project = getProject
    val olds = entityDao.find(classOf[Course], getLongIds("old"))
    val news = entityDao.find(classOf[Course], getLongIds("new"))
    alt.update(olds, news)

    var stdCourseSubId = 0L
    if (alt.persisted) {
      stdCourseSubId = alt.id
    }

    if (alt.olds.isEmpty || alt.news.isEmpty) {
      editSetting(alt)
      addMessage(getText("info.save.failure"))
      put("alt", alt)
      forward("form")
    } else {
      val builder = OqlBuilder.from(classOf[StdAlternativeCourse], "alt")
      builder.where("alt.std.id=:stdId", alt.std.id)
        .where("alt.std.project = :project", project)
      if (stdCourseSubId != 0) {
        builder.where("alt.id !=:stdCourseSubId", stdCourseSubId)
      }
      val stdAlternativeCourses = entityDao.search(builder)
      val existed = stdAlternativeCourses.exists(st => st.olds == alt.olds && st.news == alt.news)
      if (existed) {
        redirect("search", "该替代课程组合已存在!")
      } else {
        alt.updatedAt = Instant.now()
        if (isDoubleAlternativeCourse(alt)) {
          entityDao.saveOrUpdate(alt)
          databus.publish(DataEvent.update(alt))
          redirect("search", "info.save.success")
        } else {
          redirect("search", "原课程与替代课程一样!")
        }
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
    val courses = entityDao.search(query).map(x => x(0).toString + " " + x(1))

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
    Stream(new ByteArrayInputStream(os.toByteArray), MediaTypes.ApplicationXlsx, "学生个人替代课程模板.xlsx")
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

  override protected def removeAndRedirect(alts: Seq[StdAlternativeCourse]): View = {
    remove(alts)
    databus.publish(DataEvent.remove(alts))
    redirect("search", "info.remove.success")
  }
}
