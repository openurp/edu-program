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

import org.beangle.commons.collection.Collections
import org.openurp.edu.program.model.{AbstractCourseGroup, MajorPlan, Program}
import org.openurp.edu.program.service.PlanChecker

/** 检查专业选修课的学分
 */
class MajorOptionalPlanChecker extends PlanChecker {
  var minMajorOptionalCredits = 10
  var maxMajorOptionalCredits = 14
  var minMajorXoptionalCredits = 4 //跨专业选修
  var minPracticalOptionalCredits = 4 //专业与创新实践

  override def check(plan: MajorPlan): Seq[String] = {
    val rs = Collections.newBuffer[String]
    val majorOptional = plan.groups find (x => x.name.contains("专业选修课") && !x.name.contains("跨") && x.asInstanceOf[AbstractCourseGroup].givenName.isEmpty)
    majorOptional match
      case None => rs.addOne("缺失专业选修课")
      case Some(o) =>
        if (o.credits.toInt < minMajorOptionalCredits) {
          rs.addOne(s"专业选修课学分${o.credits},小于最低${minMajorOptionalCredits}")
        }
        if (o.credits.toInt > maxMajorOptionalCredits) {
          rs.addOne(s"专业选修课学分${o.credits},大于最高${maxMajorOptionalCredits}")
        }

    val majorXOptional = plan.groups find (x => x.name.contains("跨专业选修课"))
    majorXOptional match
      case None => rs.addOne("缺失跨专业选修课")
      case Some(o) =>
        if (o.credits.toInt < minMajorXoptionalCredits) {
          rs.addOne(s"跨专业选修课${o.credits},小于最低${minMajorXoptionalCredits}")
        }

    val practicalOptional = plan.groups find (x => x.name.contains("短学段") && x.name.contains("专业与创新实践") && x.asInstanceOf[AbstractCourseGroup].givenName.isEmpty)
    practicalOptional match
      case None => rs.addOne("缺失专业与创新实践课程")
      case Some(o) =>
        if (o.credits.toInt < minPracticalOptionalCredits) {
          rs.addOne(s"专业与创新实践${o.credits},小于最低${minPracticalOptionalCredits}")
        }

    rs.toSeq
  }

  override def suitable(program: Program): Boolean = {
    Set("本科").contains(program.level.name)
  }
}
