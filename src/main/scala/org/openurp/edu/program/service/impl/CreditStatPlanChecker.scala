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
import org.openurp.base.edu.model.Terms
import org.openurp.code.edu.model.TeachingNature
import org.openurp.code.service.CodeService
import org.openurp.edu.program.model.MajorPlan
import org.openurp.edu.program.service.{PlanCategoryStat, PlanChecker}

/** 学分学时比例检查
 * 1）选修课比例>=20%
 * 2）理工实践学时>=25%
 * 3）经管文法实践学时>=20%
 */
class CreditStatPlanChecker extends PlanChecker {

  var codeService: CodeService = _
  var minOptionalRatio = 20
  var minLiteralPracticalHourRatio = 20
  var minEnginePracticalHourRatio = 25

  override def check(plan: MajorPlan): Seq[String] = {
    val natures = codeService.get(classOf[TeachingNature])
    val stat = PlanCategoryStat.stat(plan, natures)
    val optionalCredits = stat.optionalStat.credits
    val optionalRatio = ((optionalCredits * 1.0 / plan.credits) * 100).toInt

    val rs = Collections.newBuffer[String]
    if (optionalRatio < minOptionalRatio) {
      rs.addOne(s"选修课学分${optionalCredits}占比为${optionalRatio}%，不能低于${minOptionalRatio}%")
    }

    plan.program.degree foreach { degree =>
      val practicalHour = stat.practicalStat.getHour(TeachingNature.Practice.toString)
      val practicalRatio = (practicalHour * 1.0 / plan.creditHours * 100).toInt
      var minPracticalHourRatio = minLiteralPracticalHourRatio
      if (degree.name.startsWith("理学") || degree.name.startsWith("工学")) {
        minPracticalHourRatio = minEnginePracticalHourRatio
      }
      if (practicalRatio < minPracticalHourRatio) {
        rs.addOne(s"实践学时${practicalHour}占比为${practicalRatio}%，不能低于${minPracticalHourRatio}%")
      }
    }

    rs.toSeq
  }
}
