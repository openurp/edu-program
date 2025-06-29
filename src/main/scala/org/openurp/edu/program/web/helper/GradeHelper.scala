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

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.openurp.base.model.Project
import org.openurp.base.std.model.Grade
import org.openurp.edu.program.model.Program

class GradeHelper(entityDao: EntityDao) {

  def getGrades(project: Project): Seq[Grade] = {
    val q = OqlBuilder.from[Grade](classOf[Program].getName, "p")
    q.where("p.project=:project", project)
    q.select("distinct p.grade")
    q.orderBy("p.grade.code desc")
    entityDao.search(q)
  }
}
