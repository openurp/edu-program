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
import org.beangle.commons.collection.{Collections, Order, Properties}
import org.beangle.commons.lang.Strings
import org.beangle.commons.lang.time.WeekState
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.Ems
import org.beangle.webmvc.annotation.{mapping, param, response}
import org.beangle.webmvc.context.ActionMessages
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.{Course, CourseJournal, Terms}
import org.openurp.base.model.{CalendarStage, Department, Project}
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.*
import org.openurp.edu.clazz.domain.WeekTimeBuilder
import org.openurp.edu.program.util.{PlanMerger, TermHelper}
import org.openurp.edu.program.model.*
import org.openurp.edu.program.service.*
import org.openurp.edu.program.service.checkers.EnNameChecker
import org.openurp.edu.service.Features
import org.openurp.starter.web.support.ProjectSupport

/** 专业培养计划
 */
class PlanAction extends ActionSupport, EntityAction[MajorPlan], ProjectSupport {

  var programChecker: ProgramChecker = _
  var planService: CoursePlanService = _
  var entityDao: EntityDao = _
  var planExcelReader: PlanExcelReader = _

  def groups(): View = {
    val plan = entityDao.get(classOf[MajorPlan], getLongId("plan"))
    getLong("courseGroup.id") foreach { groupId =>
      put("activeGroup", entityDao.get(classOf[MajorCourseGroup], groupId))
    }
    put("plan", plan)
    put("program", plan.program)
    put("stages", entityDao.findBy(classOf[CalendarStage], "school", plan.program.project.school))
    forward()
  }

  def editGroup(): View = {
    val planId = getLongId("plan")
    val plan = entityDao.get(classOf[MajorPlan], planId)

    given project: Project = plan.program.project

    val unusedCourseTypeList = getCodes(classOf[CourseType])
    val group = getLong("courseGroup.id") match
      case None =>
        val ng = new MajorCourseGroup
        ng.indexno = "99"
        ng
      case Some(gid) =>
        entityDao.get(classOf[MajorCourseGroup], gid)
    put("courseGroup", group)
    val termCredits = Collections.newMap[Integer, String]
    val termCreditArray: Array[String] = Strings.split(group.termCredits)
    for (i <- termCreditArray.indices) {
      termCredits.put(i + 1, termCreditArray(i))
    }
    put("unusedCourseTypeList", unusedCourseTypeList)
    put("parentCourseGroupList", plan.groups)
    put("termCredits", termCredits)
    put("ranks", getCodes(classOf[CourseRank]))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("stages", entityDao.getAll(classOf[CalendarStage]))
    put("plan", plan)
    forward()
  }

  def saveGroup(): View = {
    val plan = entityDao.get(classOf[MajorPlan], getLongId("plan"))

    given project: Project = plan.program.project

    val group = populateEntity(classOf[MajorCourseGroup], "courseGroup")
    val oldParent = group.parent.orNull
    val parentId = getLong("newParentId")
    var parent: CourseGroup = null
    var index = getInt("index", 0)
    if (parentId.nonEmpty) {
      parent = entityDao.get(classOf[MajorCourseGroup], parentId.get)
      if (index == 99) index = parent.children.size + 1
    } else if (index == 99) index = plan.topGroups.size + 1
    if (group.rank.nonEmpty && group.rank.get.id != CourseRank.Compulsory) {
      var terms = ","
      var termCredits = ","
      for (i <- 1 until plan.program.startTerm) {
        termCredits += "0,"
      }
      for (i <- plan.program.startTerm.intValue to plan.program.endTerm) {
        if (getBoolean("term_" + i, false)) terms += (i + ",")
        termCredits += (get("credit_" + i, "") + ",")
      }
      group.termCredits = termCredits
      group.terms = Terms(terms)

      val teachingNatures = getCodes(classOf[TeachingNature])
      val hours = Collections.newMap[TeachingNature, Int]
      teachingNatures foreach { ht =>
        getInt("creditHour" + ht.id) foreach { creditHour =>
          hours.put(ht, creditHour)
        }
      }
      group.hourRatios = hours.map(x => s"${x._1.id}:${x._2}").toSeq.sorted.mkString(",")
    } else {
      if (null == group.hourRatios) {
        group.hourRatios = ""
      }
      if (Strings.isBlank(group.termCredits)) {
        var termCredits = ","
        for (i <- 1 until plan.program.startTerm) {
          termCredits += "0,"
        }
        for (i <- plan.program.startTerm.intValue to plan.program.endTerm) {
          termCredits += "0,"
        }
        group.termCredits = termCredits
      }
    }
    // 更新老的课程组// 更新老的课程组
    if (group.persisted) {
      if ((parent != null && oldParent != null && !(parentId.get == oldParent.id))
        || (parent == null && oldParent != null) || (parent != null && oldParent == null) || index != group.index) {
        planService.move(group, parent, index)
      } else {
        entityDao.saveOrUpdate(group)
      }
    } else { // 保存新的课程组
      group.indexno = "--"
      planService.addCourseGroupToPlan(group, parent, plan)
      planService.move(group, parent, index)
    }

    planService.statPlanCredits(plan)
    val target = if getBoolean("toGroups", false) then "groups" else "edit"
    redirect(target, s"plan.id=${plan.id}&courseGroup.id=${group.id}", "info.save.success")
  }

  def removeGroup(): View = {
    val group = entityDao.get(classOf[MajorCourseGroup], getLongId("courseGroup"))
    val plan = group.plan.asInstanceOf[MajorPlan]
    plan.groups.subtractOne(group)
    group.parent foreach { p =>
      p.asInstanceOf[MajorCourseGroup].children.subtractOne(group)
    }
    group.parent = None
    entityDao.saveOrUpdate(plan)
    planService.statPlanCredits(plan)
    if (getBoolean("toGroups", false)) {
      redirect("groups", "plan.id=" + plan.id, "info.remove.success")
    } else {
      redirect("edit", "plan.id=" + plan.id, "info.remove.success")
    }
  }

  /**
   * 为修改或新建课程组显示界面
   */
  def groupCourses(): View = {
    given project: Project = getProject

    val group = entityDao.get(classOf[MajorCourseGroup], getLongId("courseGroup"))

    put("plan", group.plan)
    put("courseGroup", group)
    put("departments", project.departments)
    put("stages", entityDao.getAll(classOf[CalendarStage]))
    put("termHelper", TermHelper)
    put("weekstateBuilder", WeekTimeBuilder)
    forward()
  }

  /** 查询可用课程
   *
   * @return
   */
  def courses(): View = {
    val plan = entityDao.get(classOf[MajorPlan], getLongId("plan"))
    val program = plan.program
    val query = OqlBuilder.from(classOf[Course], "course")
    val q = get("q", "")
    if (Strings.isNotEmpty(q)) query.where("course.code like :q or course.name like :q ", "%" + q + "%")
    query.where("course.project =:project", program.project).where("course.beginOn <= :endOn", program.endOn)
      .where("course.endOn is null or :beginOn <= course.endOn", program.beginOn)
    val limit = getPageLimit
    query.orderBy(get(Order.OrderStr, "course.name"))
    query.limit(limit.pageIndex, 10)
    put("courseList", entityDao.search(query))
    put("plan", plan)
    forward()
  }

  /** 导入教学计划
   *
   * @return
   */
  def importData(): View = {
    val plan = entityDao.get(classOf[MajorPlan], getLongId("plan"))
    val parts = getAll("plan_file", classOf[Part])
    if (parts.nonEmpty && parts.head.getSize > 0) {
      val is = parts.head.getInputStream
      val data = planExcelReader.process(plan.program, is)

      val newPlan = data._1
      val messages = data._2
      PlanMerger.merge(newPlan, plan)
      plan.credits = plan.topGroups.map(_.credits).sum
      plan.program.credits = plan.credits
      entityDao.saveOrUpdate(plan, plan.program)
      planService.statPlanCredits(plan)
      messages foreach { m => println(m) }
    }
    redirect("edit", "&program.id=" + plan.program.id, "导入成功")
  }

  /** FIXME 没有连接对应
   *
   * @param id
   * @return
   */
  @mapping(value = "{id}")
  def info(@param("id") id: String): View = {
    val plan = entityDao.get(classOf[MajorPlan], id.toLong)
    put("plan", plan)

    given project: Project = plan.program.project

    put("displayCreditHour", getConfig(Features.Program.DisplayCreditHour))
    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    put("tags", getCodes(classOf[ProgramCourseTag]))
    put("ems_base", Ems.base)
    forward("info")
  }

  def restat(): View = {
    val plan = entityDao.get(classOf[MajorPlan], getLongId("plan"))
    planService.statPlanCredits(plan)
    redirect("edit", s"plan.id=${plan.id}", "统计成功")
  }

  def edit(): View = {
    val plan = entityDao.get(classOf[MajorPlan], getLongId("plan"))
    put("plan", plan)

    given project: Project = plan.program.project

    put("displayCreditHour", getConfig(Features.Program.DisplayCreditHour))
    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    put("natures", getCodes(classOf[TeachingNature]))
    put("tags", getCodes(classOf[ProgramCourseTag]))
    put("termHelper", TermHelper)
    put("ems_base", Ems.base)
    put("isAdmin", getDeparts.size > 2)
    forward()
  }

  @response
  def updateLabel(): String = {
    val tag = entityDao.get(classOf[ProgramCourseTag], getIntId("tag"))
    val program = entityDao.get(classOf[Program], getLongId("program"))
    val labels = program.labels.filter(_.tag == tag)
    val courses = entityDao.find(classOf[Course], getLongIds("course"))
    val removed = labels.filter(x => !courses.contains(x.course))
    program.labels.subtractAll(removed)
    courses foreach { c =>
      if (!labels.exists(_.course == c)) {
        program.labels.addOne(new ProgramCourseLabel(program, c, tag))
      }
    }
    entityDao.saveOrUpdate(program)
    entityDao.findBy(classOf[MajorPlan], "program", program) foreach { plan =>
      val allCourses = plan.planCourses.map(_.course).toSet
      val obsolete = program.labels.filter(x => !allCourses.contains(x.course))
      program.labels.subtractAll(obsolete)
      entityDao.saveOrUpdate(program)
    }
    "ok"
  }

  @response
  def validate(): Properties = {
    val plan = entityDao.get(classOf[MajorPlan], getLongId("plan"))
    val program = plan.program

    val errors = programChecker.check(program)
    val msg = new ActionMessages
    if (program.labels.isEmpty) {
      msg.errors.addOne("专业核心课程尚未标记")
    }
    msg.errors.addAll(errors)
    val properties = new Properties()
    properties.put("errors", msg.errors)
    properties.put("messages", msg.messages)
    properties
  }

  /**
   * 添加培养计划中的课程
   */
  def saveCourse(): View = {
    val group = entityDao.get(classOf[MajorCourseGroup], getLongId("planCourse.group"))
    val plan = group.plan
    val planCourse = populateEntity(classOf[MajorPlanCourse], "planCourse")
    val isCompulsory = getBoolean("planCourse.compulsory")
    if (isCompulsory.isEmpty) {
      planCourse.compulsory = false
      group.rank foreach { r =>
        planCourse.compulsory = r.compulsory
      }
    }
    val terms = get("planCourse.terms", "")
    planCourse.terms = Terms(terms)

    if (null == planCourse.weekstate) planCourse.weekstate = WeekState.Zero
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id + "&program.id=" + plan.program.id
    val target = if getBoolean("toGroups", false) then "groups" else "edit"
    if (planCourse.persisted) {
      if (group.planCourses.exists(x => x.course == planCourse.course && planCourse.id != x.id)) {
        return redirect(target, extra, "课程重复")
      }
      planService.updatePlanCourse(planCourse, group)
    } else {
      if (group.planCourses.exists(_.course == planCourse.course)) {
        return redirect(target, extra, "课程重复")
      }
      planService.addPlanCourse(planCourse, group)
    }
    redirect(target, extra, "info.save.success")
  }

  def removeCourse(): View = {
    val planCourses = entityDao.find(classOf[MajorPlanCourse], getLongIds("planCourse"))
    planCourses foreach { pc =>
      planService.removePlanCourse(pc, pc.group)
    }
    val group = planCourses.head.group
    planService.statPlanCredits(group.plan)
    val target = if getBoolean("toGroups", false) then "groups" else "edit"
    redirect(target, s"plan.id=${group.plan.id}&courseGroup.id=${group.id}", "info.save.success")
  }

  def batchAddForm(): View = {
    val group = entityDao.get(classOf[MajorCourseGroup], getLongId("courseGroup"))
    put("courseGroup", group)
    put("plan", group.plan)
    var codes = get("courseCodes", "")
    codes = codes.replaceAll("[\\s;，；]", ",").replaceAll(",,", ",")
    if (Strings.isNotBlank(codes)) {
      val courses = entityDao.findBy(classOf[Course], "code" -> Strings.split(codes), "project" -> getProject)
      put("courses", courses)
    }
    forward()
  }

  def batchAddCourses(): View = {
    val courseIds = getLongIds("course")
    val group = entityDao.get(classOf[MajorCourseGroup], getLongId("courseGroup"))

    val plan = group.plan
    var errorNum: Int = 0
    val allCourses = plan.planCourses.map(_.course).toSet
    for (courseId <- courseIds) {
      val planCourse = new MajorPlanCourse
      val terms = get("course." + courseId + ".terms", "")
      planCourse.terms = Terms(terms)
      planCourse.suggestTerms = Terms.empty
      planCourse.group = group
      val course = entityDao.get(classOf[Course], courseId)
      planCourse.course = course

      if (allCourses.contains(planCourse.course)) {
        errorNum += 1
      } else {
        planService.addPlanCourse(planCourse, group)
      }
    }
    entityDao.saveOrUpdate(plan)
    planService.statPlanCredits(plan)
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id
    redirect("groups", extra, "添加 " + courseIds.length + " 成功 " + (courseIds.length - errorNum) + " 失败 " + errorNum)
  }

  def batchEditForm(): View = {
    val group = entityDao.get(classOf[MajorCourseGroup], getLongId("courseGroup"))
    put("courseGroup", group)
    put("plan", group.plan)
    val planCourses = entityDao.find(classOf[MajorPlanCourse], getLongIds("planCourse"))
    put("planCourses", planCourses)
    forward()
  }

  def batchEditCourses(): View = {
    val planCourses = entityDao.find(classOf[MajorPlanCourse], getLongIds("planCourse"))
    val group = entityDao.get(classOf[MajorCourseGroup], getLongId("courseGroup"))

    val plan = group.plan
    var errorNum: Int = 0
    val allCourses = plan.planCourses.map(_.course).toSet
    planCourses foreach { pc =>
      val terms = get("planCourse." + pc.id + ".terms", "")
      pc.terms = Terms(terms)
    }
    entityDao.saveOrUpdate(plan)
    planService.statPlanCredits(plan)
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id
    redirect("groups", extra, "修改成功")
  }

  /** 比较两个计划
   *
   * @return
   */
  def diffIndex(): View = {
    given project: Project = getProject

    val q = OqlBuilder.from(classOf[Program], "program")
    q.where("program.project=:project", project)
    queryByDepart(q, "program.department")
    q.orderBy("program.grade.beginIn desc,program.department.code,program.major.name")
    val plans = entityDao.search(q)
    val lefts = plans.toSeq
    var rights = plans.toSeq
    getLong("right.grade.id") foreach { gradeId =>
      rights = rights.filter(_.grade.id == gradeId)
    }
    var right = rights.headOption
    getLong("right.id") foreach { id =>
      right = rights.find(_.id == id)
    }

    var left: Option[Program] = None
    get("left.id") foreach {
      case "last" =>
        if (right.nonEmpty) {
          val sameMajors = lefts.filter { x =>
            x.department == right.get.department &&
              x.level == right.get.level &&
              x.major == right.get.major &&
              x.direction == right.get.direction &&
              !right.contains(x) &&
              x.grade.beginIn.isBefore(right.get.grade.beginIn)
          }
          left = sameMajors.sortBy(_.grade.beginIn).reverse.headOption
        }
      case id@i => left = lefts.find(_.id.toString == id)
    }

    put("lefts", lefts)
    put("rights", rights)
    put("left", left)
    put("right", right)
    forward()
  }

  def diff(): View = {
    val left = entityDao.findBy(classOf[MajorPlan], "program.id", getLongId("left")).head
    val right = entityDao.findBy(classOf[MajorPlan], "program.id", getLongId("right")).head
    put("left", left)
    put("right", right)
    put("diffResults", planService.diff(left, right))
    put("termHelper", TermHelper)
    forward()
  }

  def spellCheck(): View = {
    given project: Project = getProject

    val depart = entityDao.get(classOf[Department], getIntId("department"))
    val grade = entityDao.get(classOf[Grade], getLongId("grade"))
    val q = OqlBuilder.from(classOf[MajorPlan], "plan")
    q.where("plan.program.project=:project", project)
    q.where("plan.program.grade=:grade", grade)
    q.where("plan.program.department=:department", depart)
    val plans = entityDao.search(q)
    val journals = Collections.newSet[CourseJournal]
    plans foreach { plan =>
      for (g <- plan.groups; pc <- g.planCourses) {
        journals.addOne(pc.journal)
      }
    }
    val checker = new EnNameChecker()
    val rs = checker.check(journals)
    put("depart", depart)
    put("grade", grade)
    put("journals", rs.keys)
    put("results", rs)
    forward()
  }
}
