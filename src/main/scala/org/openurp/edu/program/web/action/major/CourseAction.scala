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

import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.webmvc.support.action.{ExportSupport, RestfulAction}
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.{Course, Major, Terms}
import org.openurp.base.model.Project
import org.openurp.code.edu.model.EducationType
import org.openurp.code.std.model.StdType
import org.openurp.edu.program.model.{MajorPlan, MajorPlanCourse}
import org.openurp.edu.program.service.{CoursePlanService, TermHelper}
import org.openurp.edu.program.web.helper.MajorPlanCoursePropertyExtractor
import org.openurp.starter.web.support.ProjectSupport

/** 计划内课程列表
 */
class CourseAction extends RestfulAction[MajorPlanCourse], ProjectSupport, ExportSupport[MajorPlanCourse] {

  override protected def simpleEntityName: String = "pc"

  var planService: CoursePlanService = _

  override def indexSetting(): Unit = {
    given project: Project = getProject

    val departmentList = getDeparts
    put("departments", departmentList)
    put("levels", project.levels)
    put("educationTypes", getCodes(classOf[EducationType]))

    put("stdTypes", getCodes(classOf[StdType]))
    val query = OqlBuilder.from(classOf[Major], "m")
    query.where("m.project=:project", project)
    query.where("exists(from m.journals as mj where mj.depart in(:departs))", departmentList)
    query.orderBy("m.code")
    val majors = entityDao.search(query)
    put("majors", majors)
    super.indexSetting()
  }

  override protected def getQueryBuilder: OqlBuilder[MajorPlanCourse] = {
    put("termHelper", new TermHelper)
    val q = super.getQueryBuilder
    val project = getProject
    queryByDepart(q, "pc.group.plan.program.department")
    q.where("pc.group.plan.program.project=:project", project)
  }

  def batchEdit(): View = {
    val project = getProject
    val pcs = entityDao.find(classOf[MajorPlanCourse], getLongIds("pc"))
    put("planCourses", pcs)
    put("courses", pcs.map(_.course).toSet)
    put("project", project)
    forward()
  }

  def saveBatchEdit(): View = {
    val project = getProject
    val pcs = entityDao.find(classOf[MajorPlanCourse], getLongIds("pc"))
    getLong("course.id") foreach { courseId =>
      val course = entityDao.get(classOf[Course], courseId)
      pcs foreach { pc => pc.course = course }
    }

    get("planCourse.terms") foreach { terms =>
      if (Strings.isNotBlank(terms)) {
        val t = Terms(terms)
        pcs.foreach { pc => pc.terms = t }
      }
    }

    get("planCourse.termText") foreach { termText =>
      if (Strings.isNotBlank(termText)) {
        val t = if "null" == termText then None else Some(termText)
        pcs.foreach { pc => pc.termText = t }
      }
    }
    entityDao.saveOrUpdate(pcs)
    val planIds = pcs.map(_.group.plan.id)
    val plans = entityDao.find(classOf[MajorPlan], planIds)
    plans foreach { plan =>
      planService.statPlanCredits(plan)
    }
    redirect("search", "设置成功")
  }

  override protected def removeAndRedirect(pcs: Seq[MajorPlanCourse]): View = {
    val planIds = pcs.map(_.group.plan.id)
    val v = super.removeAndRedirect(pcs)
    val plans = entityDao.find(classOf[MajorPlan], planIds)
    plans foreach { plan =>
      planService.statPlanCredits(plan)
    }
    v
  }

  override protected def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new MajorPlanCoursePropertyExtractor()
  }
}
