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

package org.openurp.edu.program.service.lixin

import org.openurp.edu.program.model.{MajorPlan, Program}
import org.openurp.edu.program.service.PlanChecker

/** 全英语课程数量检查
 */
class EnglishCourseCountPlanChecker extends PlanChecker {
  var minCount = 2

  var excludeMajorNames = Set("英语", "日语")

  override def check(plan: MajorPlan): Seq[String] = {
    if (excludeMajorNames.contains(plan.program.major.name)) {
      List.empty
    } else {
      var englishCount = 0
      for (g <- plan.groups; pc <- g.planCourses) {
        if (pc.course.name.contains("全英语")) {
          englishCount += 1
        }
      }
      if (englishCount < 2) {
        List(s"全英语课程数量为${englishCount}不足${minCount}门")
      } else {
        List.empty
      }
    }
  }

  override def suitable(program: Program): Boolean = {
    Set("本科").contains(program.level.name)
  }
}
