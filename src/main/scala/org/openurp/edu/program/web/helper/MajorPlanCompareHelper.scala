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
import org.openurp.base.edu.model.Course
import org.openurp.code.edu.model.CourseType
import org.openurp.edu.program.model.MajorPlan

class MajorPlanCompareHelper(courseTypes: Iterable[CourseType]) {

  def compare(majorPlan1: MajorPlan, majorPlan2: MajorPlan): CompareResult = {
    val c1 = Collections.newSet[Course]
    val c2 = Collections.newSet[Course]
    courseTypes foreach { courseType =>
      val groups1 = majorPlan1.getGroup(courseType)
      val groups2 = majorPlan2.getGroup(courseType)

      groups1 foreach { g =>
        c1 ++= g.planCourses.map(_.course)
      }
      groups2 foreach { g =>
        c2 ++= g.planCourses.map(_.course)
      }
    }
    val same = Collections.intersection(c1, c2)
    CompareResult(c1.size, c2.size, same.size)
  }

  case class CompareResult(courseCount1: Int, courseCount2: Int, sameCourseCount: Int) {

    def simularity1: Double = {
      if (courseCount1 == 0) then 0 else sameCourseCount * 1.0 / courseCount1
    }

    def simularity2: Double = {
      if (courseCount2 == 0) then 0 else sameCourseCount * 1.0 / courseCount2
    }

    def allEmpty: Boolean = {
      courseCount1 == 0 && courseCount2 == 0 && sameCourseCount == 0
    }
  }
}
