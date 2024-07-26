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
import org.beangle.commons.lang.Strings
import org.openurp.base.std.model.Grade

class PlanCourseStatPropertyExtractor(grade: Grade) extends DefaultPropertyExtractor {
  override def get(target: Object, property: String): Any = {
    val stat = target.asInstanceOf[PlanCourseStat]
    val journal = stat.course.getJournal(grade)
    if (property.startsWith("journal")) {
      val p = Strings.substringAfter(property, "journal.")
      if (p.startsWith("hours.")) {
        val natureId = Strings.substringAfter(p, "hours.").toInt
        journal.hours.find(_.nature.id == natureId).map(_.creditHours.toString).getOrElse("")
      } else {
        super.get(journal, p)
      }
    } else {
      super.get(stat, property)
    }
  }

}
