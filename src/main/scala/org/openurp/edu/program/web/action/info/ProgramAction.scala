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

package org.openurp.edu.program.web.action.info

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.view.View
import org.openurp.base.model.{Department, Project}
import org.openurp.base.std.model.Grade
import org.openurp.edu.program.model.Program
import org.openurp.edu.program.web.helper.{GradeHelper, ProgramReportHelper}
import org.openurp.starter.web.support.ProjectSupport

class ProgramAction extends ActionSupport, ProjectSupport {

  var entityDao: EntityDao = _

  def index(): View = {
    given project: Project = getProject

    val grades = new GradeHelper(entityDao).getGrades(project)
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
    put("depart", depart)
    put("grade", grade)
    put("programs", programs)
    forward()
  }

  def report(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val helper = new ProgramReportHelper(entityDao, configService, codeService)
    helper.prepareData(program)
    forward()
  }

}
