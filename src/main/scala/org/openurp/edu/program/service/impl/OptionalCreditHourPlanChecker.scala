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

package org.openurp.edu.program.service.impl

import org.beangle.commons.collection.Collections
import org.openurp.edu.program.model.MajorPlan
import org.openurp.edu.program.service.PlanChecker

/** 选修课的课时是否满足1:16
 */
class OptionalCreditHourPlanChecker extends PlanChecker {
  var hoursPerCredits = 16

  override def check(plan: MajorPlan): Seq[String] = {
    val rs = Collections.newBuffer[String]
    plan.groups foreach { g =>
      if (g.optional) {
        if (g.creditHours > 0 && g.creditHours != g.credits * hoursPerCredits) {
          rs.addOne(s"${g.name} 要求${g.credits}学分 ${g.creditHours}学时，不符合1:${hoursPerCredits}的关系")
        }
      }
    }
    rs.toSeq
  }
}
