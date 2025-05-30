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

import org.beangle.commons.collection.Collections
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.doc.transfer.exporter.ExcelWriter
import org.beangle.web.servlet.util.RequestUtils
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.View
import org.openurp.base.model.{Department, Project}
import org.openurp.base.std.model.{Grade, Squad}
import org.openurp.code.edu.model.{CourseType, EducationLevel, TeachingNature}
import org.openurp.edu.program.model.{CourseGroup, MajorPlan, Program}
import org.openurp.edu.program.service.{CoursePlanService, PlanCategoryStat}
import org.openurp.edu.program.web.helper.PlanTask
import org.openurp.starter.web.support.ProjectSupport

import scala.collection.mutable

class StatAction extends ActionSupport, EntityAction[Program], ProjectSupport {
  var entityDao: EntityDao = _
  var planService: CoursePlanService = _

  def index(): View = {
    given project: Project = getProject

    val grades = getGrades(project)
    val grade = getLong("grade.id").map(id => entityDao.get(classOf[Grade], id)).getOrElse(grades.head)
    put("grades", grades)
    put("grade", grade)
    put("levels", project.levels)
    put("level", getInt("level.id").map(id => entityDao.get(classOf[EducationLevel], id)).getOrElse(project.levels.head))
    forward()
  }

  def natures(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val level = entityDao.get(classOf[EducationLevel], getIntId("level"))
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "level" -> level)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.level.code + x.program.department.code + x.program.major.code)
    val stats = Collections.newMap[MajorPlan, PlanCategoryStat]
    plans foreach { plan =>
      planService.statPlanCredits(plan)
      val stat = PlanCategoryStat.stat(plan, natures)
      stats.put(plan, stat)
    }
    put("plans", plans)
    put("stats", stats)
    put("grade", grade)
    put("level", level)
    put("programs", programs)
    forward()
  }

  def natureExcel(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val level = entityDao.get(classOf[EducationLevel], getIntId("level"))
    response.setContentType("application/vnd.ms-excel;charset=GBK")
    RequestUtils.setContentDisposition(response, grade.name + "培养方案学分学时统计.xlsx")
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "level" -> level)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.level.code + x.program.department.code + x.program.major.code)
    val stats = Collections.newMap[MajorPlan, PlanCategoryStat]
    plans foreach { plan =>
      planService.statPlanCredits(plan)
      val stat = PlanCategoryStat.stat(plan, natures)
      stats.put(plan, stat)
    }
    val writer = new ExcelWriter(response.getOutputStream)
    writer.writeHeader(Some(s"${grade.name}级${level.name} 培养方案学分学时统计表"), Array("序号", "培养层次", "学科门类", "院系", "专业", "总学分", "必修学分", "选修学分", "理论学分", "实践学分", "总学时", "必修学时", "选修学时", "理论学时", "实践学时"))
    var i = 1
    plans foreach { plan =>
      val stat = stats(plan)
      val p = plan.program
      val compulsoryStat = stat.getCompulsoryStat(true)
      val optionalStat = stat.optionalStat
      val theoreticalStat = stat.theoreticalStat
      val practicalStat = stat.practicalStat
      val practicalCredits = stat.practicalCredits

      val data = Array(
        i,
        p.level.name,
        p.major.disciplines.map(_.category.name).distinct.headOption.getOrElse(""),
        p.department.name,
        p.major.name + s"${p.direction.map(x => " " + x.name).getOrElse("")}",
        p.credits,
        compulsoryStat.credits,
        optionalStat.credits,
        p.credits - practicalCredits,
        practicalCredits,
        plan.creditHours,
        compulsoryStat.hours,
        optionalStat.hours,
        theoreticalStat.getHour(TeachingNature.Theory.toString),
        practicalStat.getHour(TeachingNature.Practice.toString)
      )
      writer.write(data)
      i += 1
    }
    writer.close()
    null
  }

  def modules(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val level = entityDao.get(classOf[EducationLevel], getIntId("level"))
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "level" -> level)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.level.code + x.program.department.code + x.program.major.code)

    val rs = analysisGroup(plans)
    put("plans", plans)
    put("hasLevel2", rs._2.nonEmpty)
    put("l1Types", rs._1)
    put("l2Types", rs._2)
    put("grade", grade)
    put("level", level)
    put("programs", programs)
    forward()
  }

  private def analysisGroup(plans: Iterable[MajorPlan]): (mutable.Buffer[CourseType], mutable.Map[CourseType, mutable.Buffer[CourseType]]) = {
    val l1Types = Collections.newBuffer[CourseType]
    val l1TypeSet = Collections.newSet[CourseType]
    val l2Types = Collections.newMap[CourseType, mutable.Buffer[CourseType]]
    val l2TypeSet = Collections.newMap[CourseType, mutable.Set[CourseType]]

    var hasLevel2 = false
    plans foreach { plan =>
      val topGroups = Collections.newBuffer[CourseGroup]
      plan.topGroups foreach { tg =>
        if (tg.rank.isEmpty) {
          topGroups.addAll(tg.children.sortBy(_.indexno))
        } else {
          topGroups.addOne(tg)
        }
      }
      for (tg <- topGroups) {
        if (!l1TypeSet.contains(tg.courseType)) {
          l1Types.addOne(tg.courseType)
          l1TypeSet.addOne(tg.courseType)
        }
        val l2 = l2Types.getOrElseUpdate(tg.courseType, Collections.newBuffer[CourseType])
        val l2s = l2TypeSet.getOrElseUpdate(tg.courseType, Collections.newSet[CourseType])
        for (cg <- tg.children.sortBy(_.indexno)) {
          if (!l2s.contains(cg.courseType) && cg.credits > 0) {
            l2.addOne(cg.courseType)
            l2s.addOne(cg.courseType)
            hasLevel2 = true
          }
        }
      }
    }
    l2Types.subtractAll(l2Types.filter(x => x._2.size < 2).keys)
    (l1Types, l2Types)
  }

  def moduleExcel(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val level = entityDao.get(classOf[EducationLevel], getIntId("level"))
    response.setContentType("application/vnd.ms-excel;charset=GBK")
    RequestUtils.setContentDisposition(response, grade.name + "培养方案模块学分学时统计.xlsx")
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "level" -> level)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.level.code + x.program.department.code + x.program.major.code)
    val rs = analysisGroup(plans)
    val l1 = rs._1
    val l2 = rs._2
    val types = Collections.newBuffer[CourseType]
    l1 foreach { t =>
      types.addOne(t)
      l2.get(t) foreach { c =>
        types.addAll(c)
      }
    }
    val writer = new ExcelWriter(response.getOutputStream)
    val titles = Seq("序号", "培养层次", "学科门类", "院系", "专业", "总学分").toBuffer
    titles.addAll(types.map(_.name))
    writer.writeHeader(Some(s"${grade.name}级${level.name} 培养方案按模块学分学时统计表"), titles.toArray)
    var i = 1
    plans foreach { plan =>
      val p = plan.program

      val data = Seq(i,
        p.level.name,
        p.major.disciplines.map(_.category.name).distinct.headOption.getOrElse(""),
        p.department.name,
        p.major.name + s"${p.direction.map(x => " " + x.name).getOrElse("")}",
        p.credits).toBuffer
      data.addAll(types.map(t => plan.getGroup(t.name).map(_.credits.toString).getOrElse("")))
      writer.write(data)
      i += 1
    }
    writer.close()
    null
  }

  def ranks(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val level = entityDao.get(classOf[EducationLevel], getIntId("level"))
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "level" -> level)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.level.code + x.program.department.code + x.program.major.code)
    val stats = Collections.newMap[MajorPlan, PlanCategoryStat]
    var hasDesignated = false
    plans foreach { plan =>
      planService.statPlanCredits(plan)
      val stat = PlanCategoryStat.stat(plan, natures)
      if (!hasDesignated && stat.designatedSelectiveStat.credits > 0) {
        hasDesignated = true
      }
      stats.put(plan, stat)
    }
    put("hasDesignated", hasDesignated)
    put("plans", plans)
    put("stats", stats)
    put("grade", grade)
    put("level", level)
    put("minTerm", programs.map(_.startTerm).min)
    put("maxTerm", programs.map(_.endTerm).max)
    put("programs", programs)
    forward()
  }

  private def getGrades(project: Project) = {
    val query = OqlBuilder.from(classOf[Grade], "g")
    query.where("g.project=:project", project)
    query.orderBy("g.code desc")
    entityDao.search(query)
  }

  /** 交叉开课统计
   *
   * @return
   */
  def tasks(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val level = entityDao.get(classOf[EducationLevel], getIntId("level"))
    val programs = entityDao.findBy(classOf[Program], "project" -> project, "grade" -> grade, "level" -> level)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", programs).sortBy(x => x.program.department.code + x.program.major.code)
    val departs = Collections.newSet[Department]
    val stats = Collections.newMap[MajorPlan, PlanTask]
    plans foreach { plan =>
      val p = plan.program
      val q = OqlBuilder.from(classOf[Squad], "s")
      q.where("s.project=:project and s.grade=:grade", p.project, p.grade)
      q.where("s.department=:depart and s.major=:major", p.department, p.major)
      q.where("s")
      q.where("s.stdCount>0")
      p.direction match {
        case None => q.where("s.direction is null")
        case Some(d) => q.where("s.direction=:direction", d)
      }
      q.where("s.level=:level", p.level)
      val squadCount = entityDao.search(q).size
      val task = statDepartTask(plan, squadCount)
      departs.addAll(task.departTasks.keys)
      stats.put(plan, task)
    }
    val programDeparts = plans.map(_.program.department).toSet
    val otherDeparts = departs.filter(x => !programDeparts.contains(x))
    departs.subtractAll(otherDeparts)

    put("plans", plans)
    put("stats", stats)
    put("grade", grade)
    put("level", level)
    put("otherDeparts", otherDeparts)
    put("departs", departs.toBuffer.sortBy(_.code))
    put("programs", programs)
    forward()
  }

  private def statDepartTask(plan: MajorPlan, squadCount: Int): PlanTask = {
    val pt = new PlanTask(plan.program, squadCount)
    val tasks = Collections.newMap[Department, Float]
    plan.topGroups foreach { g =>
      statGroupDepartTask(g, plan.program, tasks)
    }
    pt.add(tasks)
    pt
  }

  private def statGroupDepartTask(g: CourseGroup, program: Program, tasks: mutable.Map[Department, Float]): Unit = {
    if (!g.optional && g.planCourses.nonEmpty) {
      g.planCourses foreach { pc =>
        val j = pc.journal
        val courseCredits = pc.course.getCredits(program.level)
        if (courseCredits > 0) {
          var credits = tasks.getOrElseUpdate(j.department, 0f)
          credits += courseCredits
          tasks.put(j.department, credits)
        }
      }
    }
    g.children foreach { c =>
      statGroupDepartTask(c, program, tasks)
    }
  }
}
