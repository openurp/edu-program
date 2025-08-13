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

import org.beangle.commons.bean.orderings.PropertyOrdering
import org.beangle.commons.collection.Collections
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.Course
import org.openurp.base.model.{Department, Project}
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.TeachingNature
import org.openurp.edu.program.util.TermHelper
import org.openurp.edu.program.model.{MajorPlan, PlanCourse, Program}
import org.openurp.edu.program.service.CoursePlanService
import org.openurp.edu.program.web.helper.{GradeHelper, PlanCourseHelper, ProgramReportHelper}
import org.openurp.starter.web.support.ProjectSupport

/** 交叉评阅
 */
class ReviewAction extends ActionSupport, EntityAction[MajorPlan], ProjectSupport {

  var planService: CoursePlanService = _

  var entityDao: EntityDao = _

  def index(): View = {
    given project: Project = getProject

    val grades = new GradeHelper(entityDao).getProgramGrades(project)
    val grade = getLong("grade.id").map(id => entityDao.get(classOf[Grade], id)).getOrElse(grades.head)

    var departs = project.departments.toSeq
    val q = OqlBuilder.from[Array[Any]](classOf[Program].getName, "program")
    q.where("program.project=:project", project)
    q.where("program.grade=:grade", grade)
    q.select("program.department.id,program.department.name,count(*)")
    q.groupBy("program.department.id,program.department.code,program.department.name")
    q.orderBy("program.department.code,program.department.name")
    val departStats = entityDao.search(q)
    val programDepartIds = departStats.map(x => x(0).asInstanceOf[Number].intValue()).toSet
    departs = departs.filter(d => programDepartIds.contains(d.id))
    put("departs", departs)
    put("grades", grades)
    put("grade", grade)
    put("departStats", departStats)
    forward()
  }

  /** 培养方案列表
   *
   * @return
   */
  def programs(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val depart = entityDao.get(classOf[Department], getIntId("department"))
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "department" -> depart)
    val sortedPrograms = programs.sortBy(x => x.level.code + "_" + x.major.name + "_" + x.direction.map(_.name).getOrElse(""))
    put("depart", depart)
    put("grade", grade)
    put("programs", sortedPrograms)
    forward()
  }

  def report(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val helper = new ProgramReportHelper(entityDao, configService, codeService)
    helper.prepareData(program)
    forward()
  }

  def courses(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val depart = entityDao.get(classOf[Department], getIntId("department"))
    val helper = PlanCourseHelper(entityDao)
    put("coursesOwn", helper.coursesOwn(grade, depart))
    put("coursesOther", helper.coursesOther(grade, depart))
    put("coursesForOther", helper.coursesForOther(grade, depart))
    put("depart", depart)
    put("grade", grade)
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    forward()
  }

  /** 查看指定课程在各个计划的分布情况
   *
   * @return
   */
  def courseDetails(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))
    val programs = entityDao.find(classOf[Program], getLongIds("program"))
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs)
    val planCourses = Collections.newBuffer[PlanCourse]
    plans.foreach { plan =>
      plan.groups foreach { g =>
        planCourses.addAll(g.planCourses.filter(_.course == course))
      }
    }
    put("course", course)
    put("planCourses", planCourses.sorted(PropertyOrdering.by("group.plan.program.department.code,group.plan.program.major.name,group.courseType.name")))
    put("termHelper", TermHelper)
    forward()
  }

}
