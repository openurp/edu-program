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
import org.beangle.commons.lang.Strings
import org.openurp.base.edu.model.Course
import org.openurp.edu.program.model.{MajorPlan, PlanCourse, ProgramPrerequisite}

import scala.collection.mutable

object PrerequisiteHelper {

  def build(plan: MajorPlan, prerequisites: Iterable[ProgramPrerequisite],
            ignoreTermGapDependency: Boolean, ignoreSelective: Boolean): PrerequisiteData = {
    val pres = prerequisites.toBuffer
    // terms
    val courseTerms = Collections.newMap[Course, Int]
    val terms = plan.program.terms
    for (g <- plan.groups; pc <- g.planCourses) {
      val first = pc.terms.first - 1
      if first >= 0 && first < terms then courseTerms.put(pc.course, first)
    }

    // remove gap dependency
    if (ignoreTermGapDependency) {
      val gaps = pres.filter { pre => courseTerms(pre.course) - courseTerms(pre.prerequisite) > 1 }
      pres.subtractAll(gaps)
    }

    val courses = Collections.newSet[Course]
    pres foreach { p =>
      courses.addOne(p.course)
      courses.addOne(p.prerequisite)
    }
    //查找课程对应的计划课程
    var planCourses = Collections.newBuffer[PlanCourse]
    plan.groups foreach { g =>
      planCourses.addAll(g.planCourses.filter(x => courses.contains(x.course)))
    }
    if (ignoreSelective) {
      val selectives = planCourses.filter(_.group.rank.forall(_.compulsory))
      planCourses.subtractAll(selectives)
    }
    planCourses = planCourses.sortBy(x => x.group.indexno + " " + Strings.leftPad(x.idx.toString, 3, '0'))

    //make groups
    val termGroups = Array.ofDim[mutable.Buffer[PlanCourse]](plan.terms)
    (0 until plan.program.terms) foreach { i =>
      termGroups(i) = Collections.newBuffer[PlanCourse]
    }
    courseTerms.clear()
    planCourses foreach { pc =>
      val first = pc.terms.first - 1
      if (first >= 0 && first < termGroups.length) {
        termGroups(first).addOne(pc)
        courseTerms.put(pc.course, first)
      }
    }
    //只采用计划中的课程，估计会过滤一些错误的课程
    courses.clear()
    courses.addAll(planCourses.map(_.course))
    //去除错误的依赖
    pres.subtractAll(pres.filter(x => !courses.contains(x.course) || !courses.contains(x.prerequisite)))

    new PrerequisiteData(courses.toSet, PrerequisiteHelper.purge(pres), courseTerms.toMap, termGroups.map(_.toSeq))
  }

  /** 如果存在传递依赖，则去除直接依赖
   *
   * @param prerequisites
   * @return
   */
  def purge(prerequisites: Iterable[ProgramPrerequisite]): Iterable[ProgramPrerequisite] = {
    val groups = prerequisites.groupBy(_.course).map(x => (x._1, x._2.map(_.prerequisite).toSet))
    val removed = Collections.newSet[ProgramPrerequisite]
    groups foreach { case (c, pres) =>
      //存在多个依赖情况时，需要清洗
      if (pres.size > 1) {
        pres.foreach { pre =>
          if hasIndirectDependency(c, pre, groups) then
            val indirects = prerequisites.find(x => x.course == c && x.prerequisite == pre)
            removed.addAll(indirects)
        }
      }
    }
    val rs = prerequisites.toBuffer
    rs.subtractAll(removed)
    rs
  }

  def hasIndirectDependency(c: Course, pre: Course, context: Map[Course, Set[Course]]): Boolean = {
    var queue: Iterable[Course] = List(c)
    val processed = Collections.newSet[Course]

    var step = 0
    while (queue.nonEmpty) {
      step += 1
      val nextSteps = Collections.newBuffer[Course]
      queue foreach { p1 =>
        processed.addOne(p1)
        nextSteps.addAll(context.getOrElse(p1, Set.empty))
      }
      if (nextSteps.contains(pre) && step > 1) {
        return true
      }
      nextSteps.subtractAll(processed) //避免循环依赖
      queue = nextSteps
    }
    false
  }

}
