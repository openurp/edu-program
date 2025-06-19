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

package org.openurp.edu.program.web.action.major

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.doc.core.PrintOptions
import org.beangle.doc.excel.html.TableWriter
import org.beangle.doc.pdf.SPDConverter
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.ems.app.Ems
import org.beangle.security.Securities
import org.beangle.web.servlet.util.RequestUtils
import org.beangle.webmvc.context.ActionContext
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.{Status, Stream, View}
import org.openurp.base.model.{AuditStatus, Department, Project}
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.TeachingNature
import org.openurp.edu.program.model.{MajorPlan, Program}
import org.openurp.edu.program.service.CoursePlanService
import org.openurp.edu.program.web.helper.*
import org.openurp.starter.web.support.ProjectSupport

import java.io.File
import java.net.URI
import java.time.LocalDate

/** 学院修订培养计划
 */
class ReviseAction extends ActionSupport, EntityAction[Program], ProjectSupport {
  var entityDao: EntityDao = _
  var planService: CoursePlanService = _

  def index(): View = {
    given project: Project = getProject

    val grades = new GradeHelper(entityDao).getGrades(project)
    val grade = getLong("grade.id").map(id => entityDao.get(classOf[Grade], id)).getOrElse(grades.head)

    var departs = getDeparts
    //只保留方案中存在的部门
    if (departs.size > 1) {
      val q = OqlBuilder.from[Department](classOf[Program].getName, "program")
      q.where("program.project=:project", project)
      q.where("program.grade=:grade", grade)
      q.select("distinct program.department")
      val programDeparts = entityDao.search(q)
      val diffs = departs.diff(programDeparts)
      val myProgramDeparts = departs.toBuffer.subtractAll(diffs).sortBy(_.code).toSeq
      if (myProgramDeparts.nonEmpty) departs = myProgramDeparts
    }
    put("departs", departs)
    put("grades", grades)

    val depart = getInt("department.id").map(id => entityDao.get(classOf[Department], id)).getOrElse(departs.head)
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "department" -> depart)
    val sortedPrograms = programs.sortBy(x => x.level.code + "_" + x.major.name + "_" + x.direction.map(_.name).getOrElse(""))
    put("reviseOpening", grade.endIn.atDay(1).isAfter(LocalDate.now))
    put("programs", sortedPrograms)
    put("plans", planService.getMajorPlans(programs))
    put("depart", depart)
    put("grade", grade)
    put("editables", Set(AuditStatus.Draft, AuditStatus.Submited, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart, AuditStatus.Rejected))

    put("teachingNatures", getCodes(classOf[TeachingNature]))
    forward()
  }

  def info(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    entityDao.findBy(classOf[MajorPlan], "program", program) foreach { plan =>
      planService.statPlanCredits(plan)
    }
    val helper = new ProgramInfoHelper(entityDao, configService, codeService)
    helper.prepareData(program)
    forward()
  }

  def report(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    entityDao.findBy(classOf[MajorPlan], "program", program) foreach { plan =>
      planService.statPlanCredits(plan)
    }
    val helper = new ProgramReportHelper(entityDao, configService, codeService)
    helper.prepareData(program)
    forward()
  }

  def plans(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val department = entityDao.get(classOf[Department], getIntId("department"))
    val helper = new ProgramReportHelper(entityDao, configService, codeService)
    helper.prepareData(project, grade, department)
    put("grade", grade)
    put("department", department)
    forward()
  }

  def excel(): View = {
    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val department = entityDao.get(classOf[Department], getIntId("department"))
    val style = get("style", "")
    val tableHtml = get("tableHtml", "")
    val html = "<body>" + style + tableHtml + "</body>"
    val workbook = TableWriter.writer(html)
    val os = response.getOutputStream
    RequestUtils.setContentDisposition(response, s"${grade.name} ${department.name} 教学计划.xlsx")
    workbook.write(os)
    Status.Ok
  }

  def pdf(): View = {
    val id = getLongId("program")
    val program = entityDao.get(classOf[Program], id)
    val url = Ems.base + ActionContext.current.request.getContextPath + s"/info/program/report?program.id=${id}&URP_SID=" + Securities.session.map(_.id).getOrElse("")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    options.scale = 0.95d
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    Stream(pdf, program.grade.code + "级 " + program.name + " " + program.level.name + " 培养方案.pdf").cleanup(() => pdf.delete())
  }

  /** 查看本院系开课情况
   *
   * @return
   */
  def exportCourses(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val depart = entityDao.get(classOf[Department], getIntId("department"))
    val helper = PlanCourseHelper(entityDao)
    val planCourseStats = Collections.newBuffer[PlanCourseStat]
    planCourseStats.addAll(helper.coursesOwn(grade, depart))
    planCourseStats.addAll(helper.coursesForOther(grade, depart))
    val titles = get("titles", "")
    val properties = Strings.split(titles).toSeq
    val ctx = ExportContext.excel(None, properties)
    ctx.header(None, properties).exportAsString(getBoolean("convertToString", false))
    ctx.setItems(planCourseStats)
    ctx.extractor = new PlanCourseStatPropertyExtractor(grade)
    val response = ActionContext.current.response
    val fileName = s"${grade.name} ${depart.name} 开课信息"
    RequestUtils.setContentDisposition(response, ctx.buildFileName(Some(fileName)))
    ctx.writeTo(response.getOutputStream)
    Status.Ok
  }

  /** 导出本院系开课情况
   *
   * @return
   */
  def courses(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val depart = entityDao.get(classOf[Department], getIntId("department"))
    val helper = PlanCourseHelper(entityDao)
    put("coursesOwn", helper.coursesOwn(grade, depart))
    put("coursesForOther", helper.coursesForOther(grade, depart))
    put("grade", grade)
    put("depart", depart)
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    forward()
  }

  def submit(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    if (program.status != AuditStatus.PassedByDepart && program.status != AuditStatus.Passed) {
      program.status = AuditStatus.Submited
    }
    entityDao.saveOrUpdate(program)
    redirect("index", "提交成功")
  }

  def revoke(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    if (program.status == AuditStatus.Submited) {
      program.status = AuditStatus.Draft
    }
    entityDao.saveOrUpdate(program)
    redirect("index", "撤回成功")
  }

}
