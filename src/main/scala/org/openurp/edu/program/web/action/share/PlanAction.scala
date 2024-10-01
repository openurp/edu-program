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

package org.openurp.edu.program.web.action.share

import org.beangle.data.dao.OqlBuilder
import org.beangle.ems.app.Ems
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.Project
import org.openurp.base.std.model.Grade
import org.openurp.edu.program.model.SharePlan
import org.openurp.edu.service.Features
import org.openurp.starter.web.support.ProjectSupport

import java.time.Instant

class PlanAction extends RestfulAction[SharePlan], ProjectSupport {

  override protected def simpleEntityName: String = "plan"

  override protected def indexSetting(): Unit = {
    val project = getProject
    put("levels", project.levels)
  }

  override protected def editSetting(entity: SharePlan): Unit = {
    super.editSetting(entity)
    val project = getProject
    put("levels", project.levels)
    val query = OqlBuilder.from(classOf[Grade], "g")
    query.where("g.project=:project", project)
    query.orderBy("g.code desc")
    put("grades", entityDao.search(query))
    put("project", project)
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    put("ems_base", Ems.base)
    val plan = entityDao.get(classOf[SharePlan], id.toLong)

    given project: Project = plan.project

    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    put("plan", plan)
    forward()
  }

  override protected def getQueryBuilder: OqlBuilder[SharePlan] = {
    val query = super.getQueryBuilder
    query.where("plan.project=:project", getProject)
    query
  }

  override protected def saveAndRedirect(plan: SharePlan): View = {
    plan.updatedAt = Instant.now
    plan.project = getProject
    super.saveAndRedirect(plan)
  }
}
