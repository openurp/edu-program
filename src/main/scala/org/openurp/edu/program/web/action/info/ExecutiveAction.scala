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
import org.beangle.ems.app.Ems
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Direction, Major}
import org.openurp.base.model.Project
import org.openurp.edu.program.model.{ExecutivePlan, MajorPlan}
import org.openurp.edu.program.service.CoursePlanService
import org.openurp.edu.service.Features
import org.openurp.starter.web.support.ProjectSupport

import java.time.LocalDate

class ExecutiveAction extends ActionSupport, EntityAction[ExecutivePlan], ProjectSupport {
  var entityDao: EntityDao = _
  var planService: CoursePlanService = _

  def index(): View = {
    given project: Project = getProject

    put("project", project)
    put("departs", getDeparts)

    put("majors", findInProject(classOf[Major]))
    put("directions", findInProject(classOf[Direction]))
    forward()
  }

  def search(): View = {
    put("plans", entityDao.search(getQueryBuilder))
    forward()
  }

  override def getQueryBuilder: OqlBuilder[ExecutivePlan] = {
    val query = super.getQueryBuilder
    query.where("plan.program.project=:project", getProject)
    queryByDepart(query, "plan.program.department")
    getBoolean("fake.valid").foreach { active =>
      if (active) {
        query.where("(" + query.alias + ".program.endOn >= :now)", LocalDate.now())
      } else {
        query.where(" (" + query.alias + ".program.endOn <= :now)", LocalDate.now())
      }
    }
    query
  }

  @mapping(value = "{id}")
  def info(@param("id") id: String): View = {
    val plan = entityDao.get(classOf[ExecutivePlan], id.toLong)
    put("plan", plan)

    given project: Project = plan.program.project

    put("displayCreditHour", getConfig(Features.Program.DisplayCreditHour))
    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    put("ems_base", Ems.base)
    forward()
  }

  def diff(): View = {
    val plan = entityDao.get(classOf[ExecutivePlan], getLongId("plan"))
    val query = OqlBuilder.from(classOf[MajorPlan], "plan")
    query.where("plan.program  = :program", plan.program).cacheable
    val majorPlan = entityDao.unique(query)
    put("executivePlan", plan)
    put("majorPlan", majorPlan)
    put("diffResults", planService.diff(plan, majorPlan))
    forward()
  }

  override protected def simpleEntityName = "plan"
}
