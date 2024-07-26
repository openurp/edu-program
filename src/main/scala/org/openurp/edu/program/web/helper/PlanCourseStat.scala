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

import org.beangle.commons.collection.Collections
import org.openurp.base.edu.model.{Course, Major, Terms}
import org.openurp.code.edu.model.EducationLevel
import org.openurp.edu.program.model.{CourseGroup, PlanCourse, Program}

class PlanCourseStat(val course: Course) {
  var terms: Terms = Terms.empty
  var planCourses = Collections.newBuffer[PlanCourse]
  var count: Int = 0
  var groups = Collections.newBuffer[CourseGroup]

  def add(pc: PlanCourse): Unit = {
    groups.addOne(pc.group)
  }

  def addAll(pcs: Iterable[PlanCourse]): Unit = {
    pcs foreach { pc =>
      terms += pc.terms
      count += pc.terms.termList.length
      planCourses.addOne(pc)
      groups.addOne(pc.group)
    }
  }

  def majors: Seq[Major] = {
    groups.map(_.plan.program.major).toSet.toSeq.sortBy(_.code)
  }

  def programs: Seq[Program] = {
    groups.map(_.plan.program).toSet.toSeq.sortBy(_.major.code)
  }

  def levels: Seq[EducationLevel] = {
    groups.map(_.plan.program.level).toSet.toSeq.sortBy(_.code)
  }
}
