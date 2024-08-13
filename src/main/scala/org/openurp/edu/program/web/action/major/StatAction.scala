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
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.doc.transfer.exporter.ExcelWriter
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.web.servlet.util.RequestUtils
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.model.Project
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.TeachingNature
import org.openurp.edu.program.model.{MajorPlan, Program}
import org.openurp.edu.program.service.{PlanCategoryStat, PlanService}
import org.openurp.starter.web.support.ProjectSupport

class StatAction extends ActionSupport, EntityAction[Program], ProjectSupport {
  var entityDao: EntityDao = _
  var planService: PlanService = _

  def index(): View = {
    given project: Project = getProject

    val grades = getGrades(project)
    val grade = getLong("grade.id").map(id => entityDao.get(classOf[Grade], id)).getOrElse(grades.head)
    put("grades", grades)
    put("grade", grade)
    forward()
  }

  def natures(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.level.code + x.program.department.code + x.program.major.code)
    val stats = Collections.newMap[MajorPlan, PlanCategoryStat]
    plans foreach { plan =>
      planService.statPlanCredits(plan)
      val stat = PlanCategoryStat.stat(plan, natures)
      stats.put(plan, stat)
    }
    put("plans", plans)
    put("stats", stats)
    put("grade", grade)
    put("programs", programs)
    forward()
  }

  def natureExcel(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    response.setContentType("application/vnd.ms-excel;charset=GBK")
    RequestUtils.setContentDisposition(response, grade.name + "培养方案学分学时统计.xlsx")
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.level.code + x.program.department.code + x.program.major.code)
    val stats = Collections.newMap[MajorPlan, PlanCategoryStat]
    plans foreach { plan =>
      planService.statPlanCredits(plan)
      val stat = PlanCategoryStat.stat(plan, natures)
      stats.put(plan, stat)
    }
    val writer = new ExcelWriter(response.getOutputStream)
    writer.writeHeader(Some(s"${grade.name}级培养方案学分学时统计表"), Array("序号", "培养层次", "学科门类", "院系", "专业", "总学分", "必修学分", "选修学分", "理论学分", "实践学分", "总学时", "必修学时", "选修学时", "理论学时", "实践学时"))
    var i = 1
    plans foreach { plan =>
      val stat = stats(plan)
      val p = plan.program
      val compulsoryStat = stat.getCompulsoryStat(true)
      val optionalStat = stat.optionalStat
      val theoreticalStat = stat.theoreticalStat
      val practicalStat = stat.practicalStat
      val practicalCredits = stat.practicalCredits

      val data = Array(
        i,
        p.level.name,
        p.major.disciplines.map(_.category.name).distinct.headOption.getOrElse(""),
        p.department.name,
        p.major.name + s"${p.direction.map(x => " " + x.name).getOrElse("")}",
        p.credits,
        compulsoryStat.credits,
        optionalStat.credits,
        p.credits - practicalCredits,
        practicalCredits,
        plan.creditHours,
        compulsoryStat.hours,
        optionalStat.hours,
        theoreticalStat.getHour(TeachingNature.Theory.toString),
        practicalStat.getHour(TeachingNature.Practice.toString)
      )
      writer.write(data)
      i += 1
    }
    writer.close()
    null
  }

  def modules(): View = {
    forward()
  }

  private def getGrades(project: Project) = {
    val query = OqlBuilder.from(classOf[Grade], "g")
    query.where("g.project=:project", project)
    query.orderBy("g.code desc")
    entityDao.search(query)
  }

}
