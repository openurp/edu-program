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

import org.beangle.commons.bean.orderings.PropertyOrdering
import org.beangle.commons.collection.Collections
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.openurp.base.edu.model.Course
import org.openurp.base.model.Department
import org.openurp.base.std.model.Grade
import org.openurp.edu.program.model.{MajorPlan, PlanCourse, Program}

class PlanCourseHelper(entityDao: EntityDao) {
  def coursesOwn(grade: Grade, depart: Department): Iterable[PlanCourseStat] = {
    val programs = entityDao.findBy(classOf[Program], "project" -> grade.project, "grade" -> grade, "department" -> depart)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs)
    val planCourses = Collections.newBuffer[PlanCourse]
    plans.foreach { plan =>
      plan.groups foreach { g =>
        g.planCourses foreach { pc =>
          if (pc.course.getJournal(grade).department == depart) {
            planCourses.addOne(pc)
          }
        }
      }
    }
    val stats = Collections.newMap[Course, PlanCourseStat]
    planCourses.groupBy(_.course) foreach { case (c, pcs) =>
      val p = stats.getOrElseUpdate(c, new PlanCourseStat(c))
      p.addAll(pcs)
    }
    stats.values.toSeq.sorted(PropertyOrdering.by("course.department.code,course.name,course.code"))
  }

  /** 其他院系为本院系开课
   *
   * @param grade
   * @param depart
   * @return
   */
  def coursesOther(grade: Grade, depart: Department): Iterable[PlanCourseStat] = {
    val programs = entityDao.findBy(classOf[Program], "project" -> grade.project, "grade" -> grade, "department" -> depart)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs)
    val planCourses = Collections.newBuffer[PlanCourse]
    plans.foreach { plan =>
      plan.groups foreach { g =>
        g.planCourses foreach { pc =>
          if (pc.course.getJournal(grade).department != depart) {
            planCourses.addOne(pc)
          }
        }
      }
    }
    val stats = Collections.newMap[Course, PlanCourseStat]
    planCourses.groupBy(_.course) foreach { case (c, pcs) =>
      val p = stats.getOrElseUpdate(c, new PlanCourseStat(c))
      p.addAll(pcs)
    }
    stats.values.toSeq.sorted(PropertyOrdering.by("course.department.code,course.name,course.code"))
  }

  /** 为其他院系开课
   *
   * @param grade
   * @param depart
   * @return
   */
  def coursesForOther(grade: Grade, depart: Department): Iterable[PlanCourseStat] = {
    val q = OqlBuilder.from(classOf[Program], "p")
    q.where("p.project=:project and p.grade=:grade", grade.project, grade)
    q.where("p.department!=:department", depart)
    val programs = entityDao.search(q)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs)
    val planCourses = Collections.newBuffer[PlanCourse]
    plans.foreach { plan =>
      plan.groups foreach { g =>
        g.planCourses foreach { pc =>
          if (pc.course.getJournal(grade).department == depart) {
            planCourses.addOne(pc)
          }
        }
      }
    }
    val stats = Collections.newMap[Course, PlanCourseStat]
    planCourses.groupBy(_.course) foreach { case (c, pcs) =>
      val p = stats.getOrElseUpdate(c, new PlanCourseStat(c))
      p.addAll(pcs)
    }
    stats.values.toSeq.sorted(PropertyOrdering.by("course.department.code,course.name,course.code"))
  }

}
