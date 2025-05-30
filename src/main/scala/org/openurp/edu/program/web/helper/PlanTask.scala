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
import org.openurp.base.model.Department
import org.openurp.edu.program.model.Program

class PlanTask {

  def this(program: Program, squadCount: Int) = {
    this()
    this.program = program
    this.squadCount = squadCount
  }

  var program: Program = _

  var squadCount: Int = _

  var departTasks = Collections.newMap[Department, PlanDepartTask]

  def getDepartCredits(depart: Department): Float = {
    departTasks.get(depart).map(_.credits).getOrElse(0f)
  }

  def getDepartSquadCredits(depart: Department): Float = {
    getDepartCredits(depart) * squadCount
  }

  def add(tasks: collection.Map[Department, Float]) = {
    tasks foreach { case (d, f) =>
      departTasks.get(d) match {
        case Some(dt) =>
          dt.credits += f
        case None =>
          val dt = new PlanDepartTask(d, f)
          departTasks.put(d, dt)
      }
    }
  }
}

class PlanDepartTask {

  def this(depart: Department, credits: Float) = {
    this()
    this.depart = depart
    this.credits = credits
  }

  var depart: Department = _

  var credits: Float = _
}
