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

import jakarta.servlet.http.Part
import org.beangle.commons.activation.MediaTypes
import org.beangle.commons.codec.binary.Base64
import org.beangle.commons.collection.Collections
import org.beangle.commons.io.IOs
import org.beangle.commons.lang.Chars
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.Ems
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.{Status, Stream, View}
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.Course
import org.openurp.edu.program.model.*
import org.openurp.edu.program.service.{ImageUtil, PrerequisiteHelper}
import org.openurp.starter.web.support.ProjectSupport

import java.io.{ByteArrayInputStream, ByteArrayOutputStream, File, FileOutputStream}
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
        if prerequisites.contains(pc.course) then planCourses.addOne(pc)
      }
    }
    val q = OqlBuilder.from(classOf[Program], "p")
    q.where("p.project=:project", program.project)
    q.where("p.department=:department", program.department)
    q.where("p.grade=:grade", program.grade)
    q.where("p.id<>:program", program.id)
    val others = entityDao.search(q)
    put("others", others)
    put("groupCourses", planCourses.groupBy(_.group))
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
    put("groupCourses", candidates.groupBy(_.group))
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

    val obsolete = program.prerequisites.filter(x => !choosed.contains(x.course))
    removed.addAll(obsolete)
    program.prerequisites.subtractAll(removed)
    entityDao.remove(removed)
    entityDao.saveOrUpdate(newer)
    if (removed.size + newer.size > 0) {
      val file = new File(Ems.home + s"/edu/program/webapp/${program.id}/prerequisite.png")
      if (file.exists()) file.delete()
    }
    PrerequisiteHelper.generateDependencyImg(entityDao, program, new File(Ems.home + s"/edu/program/webapp/${program.id}/"))
    redirect("info", s"&program.id=${program.id}", "操作成功")
  }

  /** 返回antv-x6所需的json数据
   *
   * @return
   */
  def data(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val pres = entityDao.findBy(classOf[ProgramPrerequisite], "program", program).toBuffer
    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head
    put("program", program)

    val ignoreTermGap = getBoolean("ignoreTermGap", true)
    val preData = PrerequisiteHelper.build(plan, pres, ignoreTermGap, false)

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
  def graph(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    put("program", program)
    forward()
  }

  def image(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val file = new File(Ems.home + s"/edu/program/webapp/${program.id}/prerequisite.png")
    if (file.exists()) {
      getInt("rotateDegree") match
        case Some(degree) =>
          val bytes = new ByteArrayOutputStream()
          ImageUtil.rotate(file, bytes, degree)
          Stream(new ByteArrayInputStream(bytes.toByteArray), MediaTypes.ImagePng, "prerequisite.png")
        case None => Stream(file)
    } else {
      getBoolean("autoCreate", false) match
        case true =>
          put("upload", true)
          put("program", program)
          forward("graph")
        case false => Status.NotFound
    }
  }

  def upload(): View = {
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val pngData = get("pngData")
    new File(Ems.home + s"/edu/program/webapp/${program.id}").mkdirs()
    if (pngData.isDefined) {
      val file = new File(Ems.home + s"/edu/program/webapp/${program.id}/prerequisite.png")
      val bytes = Base64.decode(pngData.get.substring("data:image/png;base64,".length))
      val out = new FileOutputStream(file)
      out.write(bytes)
      out.close()
      redirect("image", s"program.id=${program.id}", "保存成功")
    } else {
      val parts = getAll("img", classOf[Part])
      if (parts.nonEmpty && parts.head.getSize > 0) {
        val file = new File(Ems.home + s"/edu/program/webapp/${program.id}/prerequisite.png")
        IOs.copy(parts.head.getInputStream, new FileOutputStream(file))
      }
      redirect("image", s"program.id=${program.id}", "上传成功")
    }
  }

  /** 引导用户上传图片
   *
   * @return
   */
  def uploadImg(): View = {
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
    val file = new File(Ems.home + s"/edu/program/webapp/${program.id}/dependency.png")
    if (!file.exists()) {
      PrerequisiteHelper.generateDependencyImg(entityDao, program, new File(Ems.home + s"/edu/program/webapp/${program.id}/"))
      if file.exists() then Stream(file, s"${program.grade.name}级 ${program.major.name} 先修关系图.png") else Status.NotFound
    } else {
      Stream(file, s"${program.grade.name}级 ${program.major.name} 先修关系图.png")
    }
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
