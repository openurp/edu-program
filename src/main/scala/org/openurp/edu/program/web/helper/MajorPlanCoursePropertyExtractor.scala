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

import org.beangle.commons.bean.DefaultPropertyExtractor
import org.openurp.edu.program.model.MajorPlanCourse

class MajorPlanCoursePropertyExtractor extends DefaultPropertyExtractor {
  override def get(bean: AnyRef, name: String): Any = {
    if (name == "labels") {
      val mpc = bean.asInstanceOf[MajorPlanCourse]
      val program = mpc.group.plan.program
      val grade = mpc.group.plan.program.grade
      val journal = mpc.course.getJournal(grade)
      val tags = program.labels.filter(x => x.course == mpc.course).map(_.tag.name) ++ journal.tags.map(_.name)
      tags.mkString("\n")
    } else {
      super.get(bean, name)
    }
  }
}
