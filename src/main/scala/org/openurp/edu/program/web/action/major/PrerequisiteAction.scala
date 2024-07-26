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

package org.openurp.edu.program.web.action.major

import net.sourceforge.plantuml.{OptionFlags, Run}
import org.beangle.commons.collection.Collections
import org.beangle.commons.io.Files
import org.beangle.commons.io.Files.stringWriter
import org.beangle.commons.lang.Chars
import org.beangle.data.dao.EntityDao
import org.beangle.ems.app.Ems
import org.beangle.template.freemarker.Configurer
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.{Status, Stream, View}
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.Course
import org.openurp.edu.program.model.*
import org.openurp.edu.program.web.helper.PrerequisiteHelper
import org.openurp.starter.web.support.ProjectSupport

import java.io.File
import scala.collection.mutable

class PrerequisiteAction extends ActionSupport, EntityAction[ProgramPrerequisite], ProjectSupport {

  var entityDao: EntityDao = _

  def info(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    put("program", program)
    val prerequisites = program.prerequisites.groupBy(_.course).map(x => (x._1, x._2.map(_.prerequisite)))
    put("prerequisites", prerequisites)
    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head
    val planCourses = Collections.newBuffer[PlanCourse]
    plan.groups foreach { g =>
      g.planCourses foreach { pc =>
        if (prerequisites.contains(pc.course)) then planCourses.addOne(pc)
      }
    }
    put("planCourses", planCourses.groupBy(_.group))
    forward()
  }

  def edit(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    put("program", program)
    put("prerequisites", program.prerequisites.groupBy(_.course).map(x => (x._1, x._2.map(_.prerequisite))))
    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head
    val candidates = entityDao.find(classOf[PlanCourse], getLongIds("planCourse")).toSet
    val allCourses = candidates.map(_.course)
    val termsCourses = Array.ofDim[mutable.Set[Course]](program.terms)
    val stageCourses = Array.ofDim[mutable.Set[Course]](program.terms)
    (0 until program.terms) foreach { i =>
      termsCourses(i) = Collections.newSet[Course]
      stageCourses(i) = Collections.newSet[Course]
    }
    plan.groups foreach { g =>
      g.planCourses foreach { pc =>
        if (allCourses.contains(pc.course)) {
          pc.terms.termList foreach { t =>
            val tt = t - 1
            if (tt >= 0 && tt < program.terms) {
              (tt + 1 until program.terms).foreach { i =>
                termsCourses(i).addOne(pc.course)
              }
              (tt until program.terms).foreach { i =>
                stageCourses(i).addOne(pc.course)
              }
            }
          }
        }
      }
    }
    put("termsCourses", termsCourses)
    put("stageCourses", stageCourses)
    put("planCourses", candidates.groupBy(_.group))
    forward()
  }

  def save(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val exists = program.prerequisites.groupBy(_.course).map(x => (x._1, x._2.map(_.prerequisite)))

    val choosed = entityDao.find(classOf[Course], getLongIds("course"))
    val removed = Collections.newBuffer[ProgramPrerequisite]
    val newer = Collections.newBuffer[ProgramPrerequisite]

    choosed foreach { course =>
      val pres = entityDao.find(classOf[Course], getAll(s"course${course.id}_pres", classOf[Long]))
      if (pres.isEmpty) {
        removed.addAll(program.prerequisites.filter(x => x.course == course))
      } else {
        pres foreach { pre =>
          program.prerequisites.find(x => x.course == course && x.prerequisite == pre) match
            case None => newer.addOne(new ProgramPrerequisite(program, course, pre))
            case Some(p) =>
        }
        exists.get(course) foreach { existsPres =>
          existsPres.diff(pres) foreach { pre =>
            removed.addAll(program.prerequisites.find(x => x.course == course && x.prerequisite == pre))
          }
        }
      }
    }
    program.prerequisites.subtractAll(removed)
    entityDao.remove(removed)
    entityDao.saveOrUpdate(newer)
    generateDependencyImg(program)
    redirect("info", s"&program.id=${program.id}", "操作成功")
  }

  def dependencyData(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val pres = entityDao.findBy(classOf[ProgramPrerequisite], "program", program).toBuffer
    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head
    put("program", program)
    val preData = PrerequisiteHelper.build(plan, pres, true, false)

    put("prerequisites", preData.pres)
    put("courses", preData.courses)
    put("termGroups", preData.groups)
    put("courseTerms", preData.courseTerms)
    put("Chars", Chars)
    forward()
  }

  /** 查看依赖图
   *
   * @return
   */
  def dependencyGraph(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    put("program", program)
    forward()
  }

  /** 查看依赖树
   *
   * @return
   */
  def dependency(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val file = new File(Ems.home + s"/edu/program/webapp/dependency/${program.id}/dependency.png")
    if (!file.exists()) {
      generateDependencyImg(program)
      if (file.exists()) {
        Stream(file)
      } else {
        Status.NotFound
      }
    } else {
      Stream(file)
    }
  }

  private def generateDependencyImg(program: Program): Unit = {
    val tmpDir = Ems.home + s"/edu/program/webapp/dependency/${program.id}/"
    new File(tmpDir).mkdirs()

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

    val depsText = new File(tmpDir + "dependency.txt")
    depsText.getParentFile.mkdirs()
    val fw = stringWriter(depsText)
    val freemarkerTemplate = cfg.getTemplate("/org/openurp/edu/program/web/components/dependency.ftl")
    freemarkerTemplate.process(data, fw)
    fw.close()

    OptionFlags.getInstance().setSystemExit(false)
    Run.main(Array(tmpDir, "-charset", "UTF-8"))
  }

  def courses(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    put("program", program)
    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head
    val candidates = Collections.newBuffer[CourseGroup]
    plan.groups foreach { g =>
      if (g.planCourses.nonEmpty && (g.credits > 0 || g.parent.nonEmpty && g.parent.get.credits > 0)) {
        candidates.addOne(g)
      }
    }
    val allCourses = Collections.newSet[Course]
    program.prerequisites foreach { c =>
      allCourses.add(c.course)
      allCourses.add(c.prerequisite)
    }
    val exists = program.prerequisites.groupBy(_.course).map(x => (x._1, x._2.map(_.prerequisite)))
    put("exists", exists)
    put("allCourses", allCourses)
    put("candidates", candidates.sortBy(_.indexno))
    forward()
  }
}
