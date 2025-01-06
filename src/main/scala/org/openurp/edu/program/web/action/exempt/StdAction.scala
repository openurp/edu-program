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

import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.Course
import org.openurp.base.model.Project
import org.openurp.base.std.model.Student
import org.openurp.edu.program.model.StdExemptCourse
import org.openurp.starter.web.support.ProjectSupport

class StdAction extends RestfulAction[StdExemptCourse], ProjectSupport {
  override def simpleEntityName: String = "exempt"

  override def indexSetting(): Unit = {
    given project: Project = getProject

    put("departs", getDeparts)
    super.indexSetting()
  }

  def batchAdd(): View = {
    given project: Project = getProject

    put("project", project)
    forward()
  }

  def batchSave(): View = {
    val project = getProject
    val course = entityDao.get(classOf[Course], getLongId("course"))
    val stdCodes = Strings.split(get("stdCodes", ""))
    val stds = entityDao.findBy(classOf[Student], "project" -> project, "code" -> stdCodes)
    val exists = entityDao.findBy(classOf[StdExemptCourse], "std" -> stds, "course" -> course).map(_.std).toSet
    val newStds = stds.toBuffer.subtractAll(exists)
    val results = newStds map (std => new StdExemptCourse(std, course))
    entityDao.saveOrUpdate(results)
    redirect("search", s"新增了${results.size}个免修")
  }

  override protected def getQueryBuilder: OqlBuilder[StdExemptCourse] = {
    val query = super.getQueryBuilder
    query.where("exempt.std.project =:project", getProject)
  }
}
