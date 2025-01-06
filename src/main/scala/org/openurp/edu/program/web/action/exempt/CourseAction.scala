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

package org.openurp.edu.program.web.action.exempt

import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.Project
import org.openurp.code.std.model.StdType
import org.openurp.edu.program.model.ExemptCourse
import org.openurp.starter.web.support.ProjectSupport

class CourseAction extends RestfulAction[ExemptCourse], ProjectSupport {

  override protected def getQueryBuilder: OqlBuilder[ExemptCourse] = {
    val query = super.getQueryBuilder
    query.where("exempt.project =:project", getProject)
  }

  override protected def editSetting(entity: ExemptCourse): Unit = {
    given project: Project = getProject

    put("project", project)
    super.editSetting(entity)
  }

  override def saveAndRedirect(e: ExemptCourse): View = {
    e.stdTypes.clear()
    val stdTypes = entityDao.find(classOf[StdType], getIntIds("stdType"))
    e.stdTypes.addAll(stdTypes)

    e.project = getProject
    super.saveAndRedirect(e)
  }

  override def simpleEntityName: String = "exempt"
}
