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

package org.openurp.edu.program.service

import net.sourceforge.plantuml.{OptionFlags, Run}
import org.beangle.commons.collection.Collections
import org.beangle.commons.io.Files.stringWriter
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.EntityDao
import org.beangle.template.freemarker.Configurer
import org.openurp.base.edu.model.{Course, Terms}
import org.openurp.edu.program.model.{MajorPlan, PlanCourse, Program, ProgramPrerequisite}

import java.io.File
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

    val nonPlanCourses = pres.filter { pre => !courseTerms.contains(pre.course) || !courseTerms.contains(pre.prerequisite) }
    pres.subtractAll(nonPlanCourses)
    // remove gap dependency
    val groups = pres.groupBy(_.course)
    groups foreach { case (c, cpres) =>
      val gapPres = cpres.groupBy(pre => courseTerms(pre.course) - courseTerms(pre.prerequisite))
      val minGap = gapPres.keySet.min
      gapPres foreach { case (gap, gpres) =>
        if (gap != minGap || ignoreTermGapDependency && gap > 1) {
          pres.subtractAll(gpres)
        }
      }
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

  def generateDependencyImg(entityDao: EntityDao, program: Program, dir: File): Unit = {
    dir.mkdirs()
    val cfg = Configurer.newConfig

    val pres = entityDao.findBy(classOf[ProgramPrerequisite], "program", program).toBuffer
    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head

    val preData = PrerequisiteHelper.build(plan, pres, false, false)

    val data = new collection.mutable.HashMap[String, Any]()
    data += ("program" -> program)
    data += ("prerequisites" -> preData.pres)
    data += ("courses" -> preData.courses)
    data += ("termGroups" -> preData.groups)
    data += ("courseTerms" -> preData.courseTerms)

    val depsText = new File(dir.getAbsolutePath + "/dependency.txt")
    depsText.getParentFile.mkdirs()
    val fw = stringWriter(depsText)
    val freemarkerTemplate = cfg.getTemplate("/org/openurp/edu/program/web/components/dependency.ftl")
    freemarkerTemplate.process(data, fw)
    fw.close()

    OptionFlags.getInstance().setSystemExit(false)
    Run.main(Array(dir.getAbsolutePath, "-charset", "UTF-8"))
    depsText.delete()
  }

  def main(args: Array[String]): Unit = {
    println(Terms("1,2,3,4").value)
  }
}

class PrerequisiteData(val courses: Set[Course], val pres: Iterable[ProgramPrerequisite],
                       val courseTerms: Map[Course, Int], val groups: Array[Seq[PlanCourse]]) {

}
