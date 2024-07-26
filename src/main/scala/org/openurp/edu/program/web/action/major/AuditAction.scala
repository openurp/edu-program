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

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.model.AuditStatus.{PassedByDepart, RejectedByDepart}
import org.openurp.base.model.{AuditStatus, Department, Project}
import org.openurp.base.std.model.Grade
import org.openurp.edu.program.model.{MajorPlan, Program}
import org.openurp.edu.program.service.{PlanService, ProgramChecker, TermHelper}
import org.openurp.edu.program.web.helper.{ProgramInfoHelper, ProgramReportHelper}
import org.openurp.starter.web.support.ProjectSupport

import java.time.LocalDate

class AuditAction extends ActionSupport, EntityAction[Program], ProjectSupport {
  var entityDao: EntityDao = _
  var programChecker: ProgramChecker = _

  var planService: PlanService = _

  def index(): View = {
    given project: Project = getProject

    val grades = getGrades(project)
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
    put("reviseOpening", grade.beginOn.isAfter(LocalDate.now))
    val auditMessages = programs.map(x => (x, programChecker.check(x))).toMap
    put("programs", programs)
    put("auditMessages", auditMessages)
    put("depart", depart)
    put("grade", grade)
    put("auditables", Set(AuditStatus.Submited, AuditStatus.RejectedByDepart))
    forward()
  }

  private def getGrades(project: Project) = {
    val query = OqlBuilder.from(classOf[Grade], "g")
    query.where("g.project=:project", project)
    query.orderBy("g.code desc")
    entityDao.search(query)
  }

  def auditSetting(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val helper = new ProgramInfoHelper(entityDao, configService, codeService)
    helper.prepareData(program)
    forward()
  }

  def audit(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    if (program.status == AuditStatus.Passed) {
      return redirect("auditSetting", "已经通过无需再审")
    }
    val passed = getBoolean("passed", false)
    if (passed) {
      program.status = PassedByDepart
    } else {
      program.status = RejectedByDepart
    }
    program.opinions = get("program.opinions")
    entityDao.saveOrUpdate(program)
    redirect("auditSetting", s"program.id=${program.id}", "审核成功")
  }

  def report(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val helper = new ProgramReportHelper(entityDao, configService, codeService)
    helper.prepareData(program)
    forward()
  }

  /** 比较两个计划
   * FIXME duplicate code
   *
   * @return
   */
  def diffIndex(): View = {
    given project: Project = getProject

    val q = OqlBuilder.from(classOf[Program], "program")
    q.where("program.project=:project", project)
    queryByDepart(q, "program.department")
    q.orderBy("program.grade.beginOn desc,program.department.code,program.major.name")
    val plans = entityDao.search(q)
    val lefts = plans.toSeq
    var rights = plans.toSeq
    getLong("right.grade.id") foreach { gradeId =>
      rights = rights.filter(_.grade.id == gradeId)
    }
    var right = rights.headOption
    getLong("right.id") foreach { id =>
      right = rights.find(_.id == id)
    }

    var left: Option[Program] = None
    get("left.id") foreach {
      case "last" =>
        if (right.nonEmpty) {
          val sameMajors = lefts.filter { x =>
            x.department == right.get.department &&
              x.level == right.get.level &&
              x.major == right.get.major &&
              x.direction == right.get.direction &&
              !right.contains(x) &&
              x.grade.beginOn.isBefore(right.get.grade.beginOn)
          }
          left = sameMajors.sortBy(_.grade.beginOn).reverse.headOption
        }
      case id@i => left = lefts.find(_.id.toString == id)
    }

    put("lefts", lefts)
    put("rights", rights)
    put("left", left)
    put("right", right)
    forward("../plan/diffIndex")
  }

  def diff(): View = {
    val left = entityDao.findBy(classOf[MajorPlan], "program.id", getLongId("left")).head
    val right = entityDao.findBy(classOf[MajorPlan], "program.id", getLongId("right")).head
    put("left", left)
    put("right", right)
    put("diffResults", planService.diff(left, right))
    put("termHelper", new TermHelper)
    forward("../plan/diff")
  }
}
