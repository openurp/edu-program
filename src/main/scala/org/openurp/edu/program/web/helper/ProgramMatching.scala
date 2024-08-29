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

import org.openurp.base.edu.model.{Direction, Major}
import org.openurp.base.model.Department
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.{EducationLevel, EducationType}
import org.openurp.code.std.model.StdType

class ProgramMatching {
  var id: String = _

  var grade: Grade = _

  var educationType: EducationType = _

  var educationLevel: EducationLevel = _

  var stdType: StdType = _

  var department: Department = _

  var major: Major = _

  var direction: Option[Direction] = None

  var count: Number = _
}
