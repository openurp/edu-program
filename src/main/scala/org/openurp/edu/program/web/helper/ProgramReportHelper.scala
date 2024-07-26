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

package org.openurp.edu.program.web.helper

import org.beangle.commons.lang.Strings
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.Ems
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.context.ActionContext
import org.openurp.base.model.{Department, Project}
import org.openurp.base.service.{Feature, ProjectConfigService}
import org.openurp.base.std.model.Grade
import org.openurp.code.Code
import org.openurp.code.edu.model.{ProgramCourseTag, TeachingNature}
import org.openurp.code.service.CodeService
import org.openurp.edu.program.model.{CreditHours, MajorPlan, Program, ProgramDoc}
import org.openurp.edu.program.service.*
import org.openurp.edu.service.Features

class ProgramReportHelper(entityDao: EntityDao, configService: ProjectConfigService, codeService: CodeService) {

  def prepareData(program: Program): Unit = {
    put("program", program)

    given project: Project = program.project

    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head
    put("plan", plan)
    put("doc", entityDao.findBy(classOf[ProgramDoc], "program", program).headOption)
    put("displayCreditHour", getConfig(Features.Program.DisplayCreditHour))
    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    put("ems_base", Ems.base)
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    put("tags", getCodes(classOf[ProgramCourseTag]))
    put("cluster", new PlanCourseCluster())
    put("termHelper", new TermHelper)
    put("planRender", PlanRender)
    val stat = PlanCategoryStat.stat(plan, natures)

    val planGroupStat = PlanGroupStat.stat(plan, natures)
    if (plan.creditHours == 0 || Strings.isEmpty(plan.hourRatios)) {
      plan.creditHours = planGroupStat.creditHours
      plan.credits = planGroupStat.credits
      plan.program.credits = plan.credits
      plan.hourRatios = CreditHours.toRatios(planGroupStat.hours)
      entityDao.saveOrUpdate(plan)
      entityDao.saveOrUpdate(plan.program)
    }
    put("stat", stat)
  }

  def prepareData(project: Project, grade: Grade, depart: Department): Unit = {
    given p: Project = project

    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    val query = OqlBuilder.from(classOf[MajorPlan], "plan")
    query.where("plan.program.project=:project", project)
    query.where("plan.program.department=:depart", depart)
    query.where("plan.program.grade=:grade", grade)
    val plans = entityDao.search(query)
    put("plans", plans)
    put("displayCreditHour", getConfig(Features.Program.DisplayCreditHour))
    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    put("ems_base", Ems.base)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    put("tags", getCodes(classOf[ProgramCourseTag]))
    put("cluster", new PlanCourseCluster())
    put("termHelper", new TermHelper)
    put("planRender", PlanRender)
  }

  def getCodes[T <: Code](clazz: Class[T])(using project: Project): collection.Seq[T] = {
    codeService.get(clazz)
  }

  protected def getConfig(f: Feature)(using project: Project): Any = {
    configService.get[Any](project, f)
  }

  private def put(name: String, v: Any): Unit = {
    ActionContext.current.attribute(name, v)
  }
}
